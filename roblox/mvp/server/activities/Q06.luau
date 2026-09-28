-- Q06 server activity: venue-inspired bowl/plate assembly near FOB and Aladdins.
-- Owns activity validation and visible round state; SessionService owns petals/fund.
local Q06 = {}
Q06.__index = Q06

local ACTIVITY_ID = "Q06"
local REQUIRED_STEPS = {
	base = "rice",
	toppings = "greens",
	protein = "tofu",
	sauce = "sauce",
	settingA = "plate",
	settingB = "cup",
}
local VALID_ITEMS = {
	base = { rice = true },
	toppings = { greens = true, cucumber = true, carrot = true },
	protein = { tofu = true, chicken = true, mushroom = true },
	sauce = { sauce = true, sesame = true },
	settingA = { plate = true, napkin = true },
	settingB = { cup = true, napkin = true },
}
local ROLE_FOR_SLOT = {
	base = "FOB",
	toppings = "FOB",
	protein = "FOB",
	sauce = "Aladdins",
	settingA = "Serving",
	settingB = "Serving",
}

local function clone(source)
	local result = {}
	for key, value in pairs(source) do
		if type(value) == "table" then result[key] = clone(value) else result[key] = value end
	end
	return result
end

local function requireRequest(request)
	assert(request and request.sessionId and type(request.sessionId) == "string", "Q06 sessionId is required")
	assert(request.activityId == ACTIVITY_ID and type(request.activityId) == "string", "Q06 activityId is required")
	assert(type(request.roundId) == "string" and type(request.actionId) == "string" and type(request.stepId) == "string", "Q06 round/action/step IDs are required")
	assert(type(request.actorUserId) == "number", "Q06 actorUserId must be numeric")
end

function Q06.new(options)
	assert(options and options.session and options.actor and options.clock and options.context, "Q06 dependencies are required")
	return setmetatable({
		session = options.session,
		actor = options.actor,
		clock = options.clock,
		context = options.context,
		rounds = {},
		currentRoundId = nil,
	}, Q06)
end

function Q06:CreateRound(request)
	requireRequest(request)
	assert(not self.rounds[request.roundId], "Q06 round already exists")
	local prior = self.session.rounds[request.roundId]
	assert(not prior, "Q06 round already exists")
	if request.replay then
		self.session:StartNextRound(ACTIVITY_ID, request.roundId, request.actorUserId)
	else
		self.session:CreateRound(ACTIVITY_ID, request.roundId, request.actorUserId, false)
	end
	self.rounds[request.roundId] = {
		roundId = request.roundId,
		state = "IN_PROGRESS",
		isReplay = request.replay == true,
		accepted = {},
		reservations = {},
		contributors = {},
	}
	self.currentRoundId = request.roundId
	return { activityId = ACTIVITY_ID, roundId = request.roundId, actorUserId = request.actorUserId, replay = request.replay == true }
end

function Q06:_round(roundId)
	local round = self.rounds[roundId]
	assert(round, "unknown Q06 round")
	assert(round.state == "IN_PROGRESS", "Q06 round is not active")
	return round
end

function Q06:_expireReservations(round)
	local now = self.clock()
	for slotId, reservation in pairs(round.reservations) do
		if reservation.expiresAt <= now then round.reservations[slotId] = nil end
	end
end

function Q06:Apply(request)
	requireRequest(request)
	local round = self:_round(request.roundId)
	self:_expireReservations(round)
	local payload = request.payload or {}
	assert(payload.slotId and payload.itemId, "Q06 slot and item are required")
	local slotId = payload.slotId
	local itemId = payload.itemId
	assert(REQUIRED_STEPS[slotId], "unknown Q06 slot")
	assert(VALID_ITEMS[slotId][itemId], "invalid item for Q06 slot")
	if round.accepted[slotId] then return { ok = true, code = "ALREADY_ACCEPTED", receipt = clone(round.accepted[slotId]), view = self:GetView(request.actorUserId) } end
	local reservation = round.reservations[slotId]
	if reservation and reservation.actorUserId ~= request.actorUserId then
		return { ok = false, code = "SLOT_BUSY", receipt = nil, view = self:GetView(request.actorUserId) }
	end
	local accepted = self.session:ApplyStep({
		sessionId = self.session.sessionId,
		activityId = ACTIVITY_ID,
		roundId = request.roundId,
		stepId = slotId,
		actionId = request.actionId,
		actorUserId = request.actorUserId,
	})
	local result = {
		roundId = request.roundId,
		stepId = slotId,
		actionId = request.actionId,
		actorUserId = request.actorUserId,
		itemId = itemId,
		roleId = ROLE_FOR_SLOT[slotId],
		accepted = true,
		acceptedStep = accepted,
	}
	round.accepted[slotId] = result
	round.reservations[slotId] = nil
	round.contributors[request.actorUserId] = true
	if self:_isComplete(round) then
		local completion = self.session:CompleteRound({ sessionId = self.session.sessionId, activityId = ACTIVITY_ID, roundId = request.roundId, actionId = "complete:" .. request.roundId, actorUserId = request.actorUserId })
		round.state = "COMPLETED"
		result.completion = completion
	end
	return { ok = true, code = result.completion and "ROUND_COMPLETED" or "STEP_ACCEPTED", receipt = clone(result), view = self:GetView(request.actorUserId) }
end

function Q06:Reserve(request)
	requireRequest(request)
	local round = self:_round(request.roundId)
	self:_expireReservations(round)
	local slotId = request.payload and request.payload.slotId
	assert(REQUIRED_STEPS[slotId], "unknown Q06 slot")
	assert(not round.accepted[slotId], "Q06 slot already accepted")
	local current = round.reservations[slotId]
	if current and current.actorUserId ~= request.actorUserId then return { accepted = false, busyReason = "slot-in-use" } end
	local reservation = { slotId = slotId, actorUserId = request.actorUserId, expiresAt = self.clock() + 15 }
	round.reservations[slotId] = reservation
	return clone(reservation)
end

function Q06:Cancel(request)
	requireRequest(request)
	local round = self:_round(request.roundId)
	local slotId = request.payload and request.payload.slotId
	local reservation = round.reservations[slotId]
	if reservation and reservation.actorUserId == request.actorUserId then round.reservations[slotId] = nil end
	return { roundId = request.roundId, slotId = slotId, cancelled = true }
end

function Q06:_isComplete(round)
	for slotId in pairs(REQUIRED_STEPS) do
		if not round.accepted[slotId] then return false end
	end
	return true
end

function Q06:GetView(actorUserId)
	local round = self.currentRoundId and self.rounds[self.currentRoundId] or nil
	if not round then
		return { activityId = ACTIVITY_ID, roundId = nil, state = "NOT_STARTED", title = "Something Delicious", instructions = "Choose an ingredient, choose a slot, and confirm.", progress = { done = 0, total = 6 }, availableActions = {}, acceptedStepIds = {}, contributors = {}, busyReason = nil, errorText = nil, canReplay = false }
	end
	self:_expireReservations(round)
	local accepted, available = {}, {}
	for slotId in pairs(REQUIRED_STEPS) do
		if round.accepted[slotId] then
			table.insert(accepted, slotId)
		else
			local busy = round.reservations[slotId]
			for itemId in pairs(VALID_ITEMS[slotId]) do
				table.insert(available, { id = "choose-" .. slotId .. "-" .. itemId, label = "" .. slotId .. ": " .. itemId, stepId = slotId, payload = { slotId = slotId, itemId = itemId }, enabled = busy == nil, reason = busy and "Slot is being used" or "Tap to add, then confirm" })
			end
		end
	end
	return {
		activityId = ACTIVITY_ID,
		roundId = round.roundId,
		state = round.state,
		title = "Something Delicious",
		instructions = "Choose an ingredient, choose a slot, and confirm.",
		progress = { done = #accepted, total = 6 },
		availableActions = available,
		acceptedStepIds = accepted,
		contributors = clone(round.contributors),
		busyReason = nil,
		errorText = nil,
		canReplay = round.state == "COMPLETED",
		actorUserId = actorUserId,
		foodDisplay = clone(round.accepted),
	}
end

return Q06
