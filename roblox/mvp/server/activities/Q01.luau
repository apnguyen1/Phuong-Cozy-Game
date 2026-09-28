-- Q01 Everything Tucked In. Server-owned activity rules; no currency or petal ownership here.
local Q01 = {}
Q01.__index = Q01

Q01.ActivityId = "Q01"
Q01.StepIds = { "blanket_left", "blanket_right", "blanket_foot", "pillow_left", "pillow_right", "plush_dog", "plush_dinosaur" }
Q01.StepLabels = {
	blanket_left = "Smooth the left blanket",
	blanket_right = "Smooth the right blanket",
	blanket_foot = "Fold the foot blanket",
	pillow_left = "Place the left pillow",
	pillow_right = "Place the right pillow",
	plush_dog = "Tuck in the round-bellied dog",
	plush_dinosaur = "Tuck in the dinosaur plush",
}
Q01.ReservationSeconds = 15

local function now(context)
	return context.clock and context.clock() or os.clock()
end

function Q01.new(context)
	assert(context and context.session, "Q01 requires a shared session")
	local self = setmetatable({
		session = context.session,
		clock = context.clock,
		reserved = {},
		reservationByActor = {},
		finalChoices = { soft_snug = "Soft and snug", neat_layered = "Neatly layered" },
		visibleState = {},
		currentRoundId = nil,
		finishedPreview = nil,
	}, Q01)
	return self
end

Q01.New = Q01.new

function Q01:_round()
	return self.currentRoundId and self.session.rounds[self.currentRoundId] or nil
end

function Q01:_requireRound(roundId)
	assert(roundId == self.currentRoundId, "stale Q01 round")
	local round = self.session.rounds[roundId]
	assert(round and round.activityId == self.ActivityId and round.state == "IN_PROGRESS", "Q01 round is not active")
	return round
end

function Q01:CreateRound(request)
	local actorUserId = request.actorUserId
	local roundId = request.roundId
	local isReplay = request.isReplay
	assert(not self.currentRoundId or not self:_round() or self:_round().state ~= "IN_PROGRESS", "Q01 round already active")
	local round = self.session:CreateRound(self.ActivityId, roundId, actorUserId, isReplay == true)
	self.currentRoundId = roundId
	self.reserved = {}
	self.reservationByActor = {}
	self.visibleState = {}
	return self:GetView(request.actorUserId)
end

Q01.Start = Q01.CreateRound

function Q01:Reserve(request)
	local round = self:_requireRound(request.roundId)
	if not self.StepLabels[request.stepId] then
		return { ok = false, code = "INVALID_STEP", message = "That is not a bed task—choose a highlighted step" }
	end
	local existing = round.steps[request.stepId]
	if existing then return { ok = false, code = "ALREADY_DONE", message = "That spot is already handled—choose another bed task", accepted = existing } end
	local prior = self.reserved[request.stepId]
	local timestamp = now(self)
	if prior and prior.expiresAt > timestamp and prior.actorUserId ~= request.actorUserId then
		return { ok = false, code = "IN_USE", message = "Someone else is handling that spot; choose another bed task" }
	end
	if prior then self.reservationByActor[prior.actorUserId] = nil end
	local reservation = { actorUserId = request.actorUserId, stepId = request.stepId, expiresAt = timestamp + self.ReservationSeconds }
	self.reserved[request.stepId] = reservation
	self.reservationByActor[request.actorUserId] = reservation
	return { ok = true, code = "RESERVED", reservation = reservation, label = self.StepLabels[request.stepId] }
end

function Q01:Cancel(request)
	local reservation = self.reserved[request.stepId]
	if reservation and reservation.actorUserId == request.actorUserId then
		self.reserved[request.stepId] = nil
		self.reservationByActor[request.actorUserId] = nil
	end
	return self:GetView()
end

function Q01:ReleaseActor(actorUserId)
	local reservation = self.reservationByActor[actorUserId]
	if reservation then
		self.reserved[reservation.stepId] = nil
		self.reservationByActor[actorUserId] = nil
	end
	return self:GetView(actorUserId)
end

function Q01:ExpireReservations(at)
	local timestamp = at or now(self)
	for stepId, reservation in pairs(self.reserved) do
		if reservation.expiresAt <= timestamp then
			self.reserved[stepId] = nil
			if self.reservationByActor[reservation.actorUserId] == reservation then self.reservationByActor[reservation.actorUserId] = nil end
		end
	end
end

function Q01:Apply(request)
	local action = request.payload and request.payload.action
	if not request.stepId and request.payload then request.stepId = request.payload.stepId end
	if action == "reserve" and self.reserved[request.stepId] and self.reserved[request.stepId].actorUserId == request.actorUserId then action = "place" end
	if action == "reserve" then
		local result = self:Reserve(request)
		result.view = self:GetView(request.actorUserId)
		return result
	elseif action == "cancel" then
		return { ok = true, code = "CANCELLED", view = self:Cancel(request) }
	elseif action == "finish" then
		return self:Finish(request)
	end
	local round = self:_requireRound(request.roundId)
	assert(request.actionId and request.actorUserId, "Q01 action identity is required")
	self:ExpireReservations()
	local existing = round.steps[request.stepId]
	if existing then return { ok = false, code = "ALREADY_DONE", message = "That spot is already handled—choose another bed task", accepted = existing } end
	local reservation = self.reserved[request.stepId]
	assert(reservation and reservation.actorUserId == request.actorUserId, "reserve this bed spot first")
	local accepted = self.session:ApplyStep({ sessionId = self.session.sessionId, activityId = self.ActivityId, roundId = request.roundId, stepId = request.stepId, actionId = request.actionId, actorUserId = request.actorUserId })
	self.reserved[request.stepId] = nil
	self.reservationByActor[request.actorUserId] = nil
	self.visibleState[request.stepId] = true
	return { ok = true, code = "ACCEPTED", accepted = accepted, view = self:GetView(request.actorUserId) }
end

function Q01:Finish(request)
	local prior = request.actionId and self.session.receipts[request.actionId]
	if prior then return { ok = true, code = "DUPLICATE", receipt = prior, preview = self.finishedPreview, view = self:GetView(request.actorUserId) } end
	local round = self:_requireRound(request.roundId)
	local choiceId = request.choiceId or (request.payload and request.payload.choiceId)
	local presence = self.session.presence or {}
	local authorized = self.session:IsPresent(request.actorUserId) and self.session:CanSpend(request.actorUserId, presence)
	assert(authorized, "only present Phuong or fallback host can finish Q01")
	assert(self.finalChoices[choiceId], "unknown Q01 finishing choice")
	for _, stepId in ipairs(self.StepIds) do assert(round.steps[stepId], "all seven Q01 steps are required") end
	local receipt = self.session:CompleteRound({ sessionId = self.session.sessionId, activityId = self.ActivityId, roundId = request.roundId, actionId = request.actionId, actorUserId = request.actorUserId })
	self.finishedPreview = { choiceId = choiceId, choiceLabel = self.finalChoices[choiceId], receipt = receipt }
	self.currentRoundId = request.roundId
	return { ok = true, code = "FINISHED", receipt = receipt, preview = self.finishedPreview, view = self:GetView(request.actorUserId) }
end

function Q01:GetView(actorUserId)
	self:ExpireReservations()
	local round = self:_round()
	local accepted = {}
	if round then for stepId in pairs(round.steps) do accepted[stepId] = true end end
	local phase = "INACTIVE"
	if round then phase = round.state == "COMPLETED" and "FINISHED" or (next(accepted) and "IN_PROGRESS" or "OPEN") end
	if round and #Q01.StepIds == 7 then
		local complete = true
		for _, stepId in ipairs(Q01.StepIds) do if not accepted[stepId] then complete = false break end end
		if complete and round.state == "IN_PROGRESS" then phase = "READY_FOR_PHUONG" end
	end
	local completed = 0
	for _ in pairs(accepted) do completed += 1 end
	local actions = {}
	for _, stepId in ipairs(self.StepIds) do
		local done = accepted[stepId] ~= nil
		local reservation = self.reserved[stepId]
		local held = reservation ~= nil
		local owned = held and reservation.actorUserId == actorUserId
		local action = owned and "place" or "reserve"
		table.insert(actions, { id = action .. ":" .. stepId, label = self.StepLabels[stepId], stepId = stepId, payload = { action = action, stepId = stepId }, enabled = not done and (not held or owned), reason = done and "Already handled" or (held and not owned and "In use" or nil) })
		if owned then table.insert(actions, { id = "cancel:" .. stepId, label = "Cancel " .. self.StepLabels[stepId], stepId = stepId, payload = { action = "cancel", stepId = stepId }, enabled = true }) end
	end
	if phase == "READY_FOR_PHUONG" then
		local presence = self.session.presence or {}
		local canFinish = actorUserId and self.session:IsPresent(actorUserId) and self.session:CanSpend(actorUserId, presence)
		for choiceId, choiceLabel in pairs(self.finalChoices) do
			table.insert(actions, { id = "finish:" .. choiceId, label = choiceLabel, stepId = "finish", payload = { action = "finish", choiceId = choiceId }, enabled = canFinish == true, reason = canFinish and nil or "Phuong chooses the finishing style" })
		end
	end
	return { activityId = self.ActivityId, roundId = self.currentRoundId, state = phase, title = "Everything Tucked In", instructions = phase == "READY_FOR_PHUONG" and "Choose how Phuong finishes the bed" or "Help with an available bed step", progress = { done = completed, total = 7 }, availableActions = actions, acceptedStepIds = accepted, contributors = round and round.contributors or {}, busyReason = nil, errorText = nil, canReplay = phase == "FINISHED", visibleState = self.visibleState, finishedPreview = self.finishedPreview, reservationSeconds = self.ReservationSeconds }
end

return Q01
