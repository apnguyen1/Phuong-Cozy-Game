-- Server-owned room activity. Only the seven bed steps earn Q01.
local Q01 = {}
Q01.__index = Q01
Q01.ActivityId = "Q01"
Q01.StepIds = { "blanket_left", "blanket_right", "blanket_foot", "pillow_left", "pillow_right", "plush_dog", "plush_dinosaur" }
Q01.StepLabels = {
	blanket_left = "Smooth the left blanket edge", blanket_right = "Smooth the right blanket edge",
	blanket_foot = "Fold the cream quilt", pillow_left = "Place the left pillow", pillow_right = "Place the right pillow",
	plush_dog = "Tuck in the round-bellied dog", plush_dinosaur = "Tuck in the dinosaur plush",
}
local ITEMS = {
	blanket_left = { label = "Left blanket edge", destination = "Left side of the sage bed", verb = "Tuck" },
	blanket_right = { label = "Right blanket edge", destination = "Right side of the sage bed", verb = "Tuck" },
	blanket_foot = { label = "Cream quilt", destination = "Foot of the sage bed", verb = "Fold" },
	pillow_left = { label = "Left cream pillow", destination = "Left pillow spot", verb = "Place" },
	pillow_right = { label = "Right cream pillow", destination = "Right pillow spot", verb = "Place" },
	plush_dog = { label = "Round-bellied dog plush", destination = "Dog's spot beside the pillows", verb = "Tuck" },
	plush_dinosaur = { label = "Dinosaur plush", destination = "Dinosaur's spot beside the pillows", verb = "Tuck" },
}
local SHELF_ITEMS = { { id = "book_sage", label = "Sage book" }, { id = "book_cream", label = "Cream book" }, { id = "small_figure", label = "Small shelf figure" } }
local SHELF_SLOTS = { { id = "left", label = "Top shelf · left" }, { id = "middle", label = "Top shelf · middle" }, { id = "right", label = "Top shelf · right" } }
Q01.ReservationSeconds = 30
local function now(self) return self.clock and self.clock() or os.clock() end
local function find(list, id) for _, item in ipairs(list) do if item.id == id then return item end end end
local function copyMap(source) local result = {}; for k, v in pairs(source) do result[k] = v end; return result end

function Q01.new(context)
	assert(context and context.session, "Q01 requires a shared session")
	return setmetatable({ session = context.session, clock = context.clock, feedback = context.feedback,
		reserved = {}, reservationByActor = {}, visibleState = {}, currentRoundId = nil, finishedPreview = nil,
		finalChoices = { soft_snug = "Soft and snug", neat_layered = "Neatly layered" },
		shelfSlots = {}, shelfHolds = {}, shelfItemHolds = {}, shelfSlotHolds = {}, actions = {}, expiryRevision = 0,
	}, Q01)
end
Q01.New = Q01.new
function Q01:_round() return self.currentRoundId and self.session.rounds[self.currentRoundId] or nil end
function Q01:_active(roundId)
	local round = self:_round()
	return roundId == self.currentRoundId and round and round.state == "IN_PROGRESS" and round or nil
end
function Q01:_host(actor)
	return actor == self.session.phuongUserId or (self.session.hostUserId ~= 0 and actor == self.session.hostUserId)
end
function Q01:_releaseBed(actor)
	local hold = self.reservationByActor[actor]
	if hold then self.reserved[hold.stepId] = nil; self.reservationByActor[actor] = nil end
end
function Q01:_releaseShelf(actor)
	local hold = self.shelfHolds[actor]
	if hold then
		self.shelfItemHolds[hold.itemId] = nil
		if hold.slotId then self.shelfSlotHolds[hold.slotId] = nil end
		self.shelfHolds[actor] = nil
	end
end
function Q01:ReleaseActor(actor, roundId)
	-- A delayed close from an older round must not release a new-round choice.
	if roundId and roundId ~= self.currentRoundId then return end
	self:_releaseBed(actor); self:_releaseShelf(actor)
end
function Q01:ExpireReservations(at)
	local timestamp, changed = at or now(self), false
	for actor, hold in pairs(self.reservationByActor) do
		if hold.expiresAt <= timestamp then self:_releaseBed(actor); changed = true end
	end
	for actor, hold in pairs(self.shelfHolds) do
		if hold.expiresAt <= timestamp then self:_releaseShelf(actor); changed = true end
	end
	if changed then self.expiryRevision += 1 end
	return changed
end
function Q01:CreateRound(request)
	assert(not self:_round() or self:_round().state ~= "IN_PROGRESS", "Q01 round already active")
	assert(not self:_round() or request.replay == true or request.isReplay == true, "explicit replay required")
	self.session:CreateRound(self.ActivityId, request.roundId, request.actorUserId)
	self.currentRoundId = request.roundId
	self.reserved, self.reservationByActor, self.visibleState = {}, {}, {}
	self.shelfHolds, self.shelfItemHolds, self.shelfSlotHolds = {}, {}, {}
	self.finishedPreview = nil
	-- Committed shelf layout intentionally persists across bed replays.
	if self.feedback then
		local ok,err=pcall(self.feedback.BeginRound,self.feedback,request.roundId)
		if not ok then warn("Bedroom round presentation needs attention",err) end
	end
	return self:GetView(request.actorUserId)
end
Q01.Start = Q01.CreateRound

function Q01:_bed(request, action)
	local actor, stepId = request.actorUserId, request.stepId
	local round = self:_active(request.roundId)
	if not round then return false, "ROUND_CHANGED", "This bed round changed. Reopen it to see the current tasks." end
	if not ITEMS[stepId] then return false, "INVALID_STEP", "Choose one of the bed task cards." end
	if action == "cancel" then self:_releaseBed(actor); return true, "CANCELLED" end
	if round.steps[stepId] then return false, "ALREADY_DONE", "That spot is already tidy. Choose another bed task." end
	local held = self.reserved[stepId]
	if action == "reserve" then
		if held and held.actorUserId ~= actor then return false, "IN_USE", "A friend is using that spot. Choose another task or try again shortly." end
		self:_releaseBed(actor); self:_releaseShelf(actor)
		local hold = { actorUserId = actor, stepId = stepId, expiresAt = now(self) + self.ReservationSeconds }
		self.reserved[stepId], self.reservationByActor[actor] = hold, hold
		return true, "RESERVED"
	end
	if action ~= "place" then return false, "UNKNOWN_ACTION", "Choose a bed task, then use Place or Tuck." end
	if not held or held.actorUserId ~= actor then return false, "HOLD_EXPIRED", "Your item was put back. Choose its card again, then place it." end
	self.session:ApplyStep(request)
	self:_releaseBed(actor)
	self.visibleState[stepId] = true
	if self.feedback then self.feedback:ApplyStep(stepId) end
	return true, "ACCEPTED"
end

function Q01:_shelf(request, action)
	local actor, payload = request.actorUserId, request.payload
	if not self.feedback or not self.feedback.shelfReady then return false, "SHELF_UNAVAILABLE", "The bedroom shelf is not ready. You can still help with the bed." end
	if action == "shelf_cancel" then self:_releaseShelf(actor); return true, "CANCELLED" end
	local function itemSlot(itemId) for slot, item in pairs(self.shelfSlots) do if item == itemId then return slot end end end
	if action == "shelf_select" then
		local item = find(SHELF_ITEMS, payload.itemId)
		if not item then return false, "INVALID_ITEM", "Choose a book or the small shelf figure." end
		if itemSlot(item.id) and not self:_host(actor) then return false, "HOST_ONLY", "Phuong or Andrew can rearrange displayed items. Choose an item that has not been placed." end
		local owner = self.shelfItemHolds[item.id]
		if owner and owner ~= actor then return false, "IN_USE", "A friend is holding that item. Choose another one." end
		-- A displayed item's current slot may already be reserved by another host.
		local sourceSlot = itemSlot(item.id)
		if sourceSlot and self.shelfSlotHolds[sourceSlot] and self.shelfSlotHolds[sourceSlot] ~= actor then return false, "IN_USE", "A friend is arranging that spot. Choose another item." end
		self:_releaseShelf(actor); self:_releaseBed(actor)
		self.shelfHolds[actor] = { itemId = item.id, expiresAt = now(self) + self.ReservationSeconds }
		self.shelfItemHolds[item.id] = actor
		return true, "SHELF_SELECTED"
	end
	local hold = self.shelfHolds[actor]
	if not hold then return false, "HOLD_EXPIRED", "Your shelf item was put back. Choose it again." end
	if action == "shelf_slot" then
		if not find(SHELF_SLOTS, payload.slotId) then return false, "INVALID_SLOT", "Choose a labeled top shelf spot." end
		local occupied, owner = self.shelfSlots[payload.slotId], self.shelfSlotHolds[payload.slotId]
		if owner and owner ~= actor or occupied and self.shelfItemHolds[occupied] and self.shelfItemHolds[occupied] ~= actor then
			return false, "IN_USE", "A friend is arranging that spot. Choose another or try again shortly."
		end
		if occupied and occupied ~= hold.itemId and not self:_host(actor) then return false, "SLOT_FULL", "That spot already has an item. Choose an empty spot." end
		if hold.slotId then self.shelfSlotHolds[hold.slotId] = nil end
		hold.slotId, hold.expiresAt = payload.slotId, now(self) + self.ReservationSeconds
		self.shelfSlotHolds[hold.slotId] = actor
		return true, "SHELF_SLOT_SELECTED"
	end
	if action ~= "shelf_place" or not hold.slotId or self.shelfSlotHolds[hold.slotId] ~= actor then
		return false, "CHOOSE_SLOT", "Choose a labeled shelf spot before placing your item."
	end
	local oldSlot, occupant = itemSlot(hold.itemId), self.shelfSlots[hold.slotId]
	if (oldSlot or occupant and occupant ~= hold.itemId) and not self:_host(actor) then return false, "HOST_ONLY", "Phuong or Andrew can change the shared display. Guests can fill empty spots." end
	if occupant and self.shelfItemHolds[occupant] and self.shelfItemHolds[occupant] ~= actor then return false, "IN_USE", "A friend is holding the item in that spot. Try another spot." end
	if oldSlot then self.shelfSlots[oldSlot] = nil end
	self.shelfSlots[hold.slotId] = hold.itemId
	self:_releaseShelf(actor)
	self.feedback:RenderShelf(self.shelfSlots)
	return true, "SHELF_PLACED"
end

function Q01:_finish(request)
	local round = self:_active(request.roundId)
	if not round then return false, "ROUND_CHANGED", "The bed is already finished. Choose Play again to begin a new round." end
	if not self.session:CanSpend(request.actorUserId, self.session.presence) then return false, "PHUONG_FINISH", "Phuong chooses the final style. Andrew can help when she is away." end
	local choice = request.payload.choiceId
	if not self.finalChoices[choice] then return false, "INVALID_STYLE", "Choose one of the two finishing styles." end
	for _, step in ipairs(self.StepIds) do if not round.steps[step] then return false, "STEPS_REMAIN", "Finish all seven bed tasks before choosing the final style." end end
	local receipt = self.session:CompleteRound(request)
	self.finishedPreview = { choiceId = choice, choiceLabel = self.finalChoices[choice] }
	if self.feedback then self.feedback:Finish(choice) end
	return true, "FINISHED", nil, receipt
end
function Q01:Apply(request)
	if request.sessionId ~= self.session.sessionId or request.activityId ~= self.ActivityId or not self.session:IsPresent(request.actorUserId)
		or type(request.actionId) ~= "string" or request.actionId == "" or type(request.payload) ~= "table" then
		return { ok = false, code = "BadAction", message = "Reopen the bed activity to get fresh choices." }
	end
	local prior = self.actions[request.actionId]
	if prior then
		if prior.actor ~= request.actorUserId or prior.roundId ~= request.roundId then return { ok = false, code = "BadAction" } end
		return { ok = prior.ok, code = "DUPLICATE", message = prior.message, receipt = prior.receipt, view = self:GetView(request.actorUserId) }
	end
	if request.roundId ~= self.currentRoundId then return { ok = false, code = "ROUND_CHANGED", message = "This round changed. Reopen the bed activity." } end
	self:ExpireReservations()
	local action = request.payload.action
	local ok, code, message, receipt
	if action == "finish" and request.stepId == "finish" then ok, code, message, receipt = self:_finish(request)
	elseif type(action) == "string" and string.sub(action, 1, 6) == "shelf_" and request.stepId == "shelf" then ok, code, message = self:_shelf(request, action)
	elseif action == "reserve" or action == "place" or action == "cancel" then ok, code, message = self:_bed(request, action)
	else ok, code, message = false, "UNKNOWN_ACTION", "Choose an available bed or shelf action." end
	self.actions[request.actionId] = { actor = request.actorUserId, roundId = request.roundId, ok = ok, message = message, receipt = receipt }
	return { ok = ok, code = code, message = message, receipt = receipt, view = self:GetView(request.actorUserId) }
end

function Q01:RecoveryState()
	return { roundId = self.currentRoundId, reserved = self.reserved, shelfHolds = self.shelfHolds, visible = self.visibleState, finished = self.finishedPreview }
end
function Q01:RecoverRelease(request)
	self.session:AssertRecovery(request)
	self.reserved, self.reservationByActor = {}, {}
	self.shelfHolds, self.shelfItemHolds, self.shelfSlotHolds = {}, {}, {}
	self.expiryRevision += 1
end
function Q01:RecoverRestart(request, newRoundId)
	self.session:RecoverCancel(request); self:RecoverRelease(request)
	self.currentRoundId = nil
	self:CreateRound({ sessionId = request.sessionId, activityId = "Q01", roundId = newRoundId, actorUserId = request.actorUserId })
	return newRoundId
end
function Q01:RecoverComplete(request)
	self.session:AssertRecovery(request); self:RecoverRelease(request)
	for _, step in ipairs(self.StepIds) do self.session:RecoverStep(request, step); self.visibleState[step] = true end
	local receipt = self.session:RecoverCompleteRound(request)
	self.finishedPreview = self.finishedPreview or { choiceId = "soft_snug", choiceLabel = self.finalChoices.soft_snug }
	if self.feedback then
		local ok, err = pcall(function()
			for _, step in ipairs(self.StepIds) do self.feedback:ApplyStep(step) end
			self.feedback:Finish(self.finishedPreview.choiceId)
		end)
		if not ok then warn("PCW-24 bedroom recovery presentation", err) end
	end
	return receipt
end

function Q01:GetView(actor)
	self:ExpireReservations()
	local round, accepted, completed = self:_round(), {}, 0
	if round then for step in pairs(round.steps) do accepted[step] = true; completed += 1 end end
	local phase = not round and "INACTIVE" or round.state == "COMPLETED" and "FINISHED" or completed == 7 and "READY_FOR_PHUONG" or "IN_PROGRESS"
	local actions, doneLabels = {}, {}
	local held = actor and self.reservationByActor[actor]
	local shelfHold = actor and self.shelfHolds[actor]
	local function add(id, label, step, payload, group, enabled, reason, description, primary)
		local descriptor = { id = id, label = label, stepId = step, payload = payload, groupId = group,
			enabled = enabled ~= false, reason = reason, description = description, primary = primary == true }
		table.insert(actions, descriptor); return descriptor
	end
	for _, step in ipairs(self.StepIds) do
		local item, reservation = ITEMS[step], self.reserved[step]
		if accepted[step] then table.insert(doneLabels, self.StepLabels[step])
		elseif round and phase ~= "FINISHED" then
			if held and held.stepId == step then
				add("place:" .. step, item.verb .. " " .. string.lower(item.label), step, { action = "place" }, "placement", true, nil, "Highlighted destination: " .. item.destination, true)
				add("cancel:" .. step, "Put item back", step, { action = "cancel" }, "placement", true, nil, "Release this item so someone else can help.")
			else
				add("reserve:" .. step, "Pick up " .. string.lower(item.label), step, { action = "reserve" }, "bed", reservation == nil, reservation and "In use · choose another task", item.destination)
			end
		end
	end
	if phase == "READY_FOR_PHUONG" then
		local canFinish = actor and self.session:CanSpend(actor, self.session.presence)
		for _, choice in ipairs({ "soft_snug", "neat_layered" }) do
			local descriptor = add("finish:" .. choice, self.finalChoices[choice], "finish", { action = "finish", choiceId = choice }, "finish", canFinish == true, "Phuong chooses; Andrew can help when she is away.", "Save this style and complete the bed petal.")
			descriptor.confirm = { title = "Finish the bed?", detail = "Save this style for everyone and add the bed's shared reward once.", label = "Finish " .. string.lower(self.finalChoices[choice]) }
		end
	end
	local shelfView = { ready = self.feedback ~= nil and self.feedback.shelfReady == true, slots = {}, items = {}, optional = true }
	if shelfView.ready then
		for _, item in ipairs(SHELF_ITEMS) do
			local placed = false; for _, itemId in pairs(self.shelfSlots) do if itemId == item.id then placed = true end end
			local owner = self.shelfItemHolds[item.id]
			local enabled = (not owner or owner == actor) and (not placed or self:_host(actor))
			table.insert(shelfView.items, { id = item.id, label = item.label, placed = placed })
			if not shelfHold then add("shelf_select:" .. item.id, "Choose " .. string.lower(item.label), "shelf", { action = "shelf_select", itemId = item.id }, "shelf", enabled, owner and "In use" or "Displayed · Phuong or Andrew can rearrange", "Optional top shelf tidying · no fund or petal reward.") end
		end
		for _, slot in ipairs(SHELF_SLOTS) do
			local item = find(SHELF_ITEMS, self.shelfSlots[slot.id])
			local owner = self.shelfSlotHolds[slot.id]
			table.insert(shelfView.slots, { id = slot.id, label = slot.label, itemLabel = item and item.label, busy = owner ~= nil and owner ~= actor })
			if shelfHold then
				local itemHeldBy = item and self.shelfItemHolds[item.id]
				local busy = owner and owner ~= actor or itemHeldBy and itemHeldBy ~= actor
				local enabled = not busy and (not item or item.id == shelfHold.itemId or self:_host(actor))
				local descriptor = add("shelf_slot:" .. slot.id, slot.label, "shelf", { action = "shelf_slot", slotId = slot.id }, "shelf", enabled, busy and "In use" or "Occupied · choose an empty spot", item and "Currently: " .. item.label or "Empty spot")
				descriptor.selected = shelfHold.slotId == slot.id
			end
		end
		if shelfHold then
			local item = find(SHELF_ITEMS, shelfHold.itemId)
			shelfView.held = { itemId = item.id, label = item.label, slotId = shelfHold.slotId, expiresAt = shelfHold.expiresAt, targetName = shelfHold.slotId and "ShelfTarget_" .. shelfHold.slotId }
			if shelfHold.slotId then
				local slot = find(SHELF_SLOTS, shelfHold.slotId)
				local descriptor = add("shelf_place", "Place " .. string.lower(item.label), "shelf", { action = "shelf_place" }, "placement", true, nil, slot.label .. " · everyone will see it here", true)
				descriptor.confirm = { title = "Place this shelf item?", detail = item.label .. " → " .. slot.label .. ". Any replaced item returns to the tidy tray. No funds or petals change.", label = "Place item" }
			end
			add("shelf_cancel", "Put shelf item back", "shelf", { action = "shelf_cancel" }, "shelf", true)
		end
	end
	local heldView = held and { stepId = held.stepId, label = ITEMS[held.stepId].label, destination = ITEMS[held.stepId].destination, targetName = "BedTarget_" .. held.stepId, expiresAt = held.expiresAt }
	local detail = heldView and "Holding " .. heldView.label .. ". Follow the highlighted spot, then choose Place or Tuck."
		or shelfHold and "Choose a labeled shelf spot, then confirm placement. The shelf is optional."
		or phase == "READY_FOR_PHUONG" and "All seven tasks are done. Phuong can choose the finishing style."
		or phase == "FINISHED" and "The bed petal is saved. You can tidy the shelf or choose Play again together."
		or "Choose a blanket, pillow or plush card. Pick it up, see its highlighted spot, then Place or Tuck."
	return { activityId = self.ActivityId, roundId = self.currentRoundId, state = phase, title = "Everything Tucked In", instructions = detail,
		progress = { done = completed, total = 7 }, availableActions = actions, acceptedStepIds = accepted,
		contributors = round and copyMap(round.contributors) or {}, canReplay = phase == "FINISHED", visibleState = copyMap(self.visibleState),
		finishedPreview = self.finishedPreview, held = heldView, doneLabels = doneLabels, shelf = shelfView, reservationSeconds = self.ReservationSeconds,
		guide = { headline = phase == "FINISHED" and "The room feels cozier together" or "A cozy bed, one small task at a time", detail = detail,
			stepLabel = string.format("%d of 7 bed tasks done · %d remaining", completed, 7 - completed), nextAnchor = shelfHold and "Q01Shelf" or "Q01Bed",
			groups = { { id = "placement", title = "Place your held item" }, { id = "bed", title = "Choose a bed task" },
				{ id = "finish", title = "Phuong's finishing style" }, { id = "shelf", title = "Optional · tidy the bedroom shelf", detail = "Choose an item, choose a top shelf spot, then confirm. Phuong and Andrew can rearrange; guests fill empty spots." } },
		},
	}
end
return Q01
