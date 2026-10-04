_G.__PCW25ContractText..=[==[rn true, "RESERVED"
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
]=],
["roblox/mvp/server/activities/Q02.luau"] = [=[-- Q02 Jasper's Favorite Things. Server-owned activity adapter.
-- Does not own fund/petal logic; SessionService is the only reward authority.

local Activity = {}
Activity.__index = Activity

local STEPS = {"greet", "rabbitFound", "rabbitReturned", "fetch1", "fetch2", "fetch3", "greenie"}
local FETCH_STEPS = {fetch1 = true, fetch2 = true, fetch3 = true}
local function clone(value)
    if type(value) ~= "table" then return value end
    local result = {}
    for key, item in pairs(value) do result[key] = clone(item) end
    return result
end

function Activity.new(ctx)
    assert(ctx and ctx.session and ctx.world, "Q02 requires session and world context")
    local self = setmetatable({
        session = ctx.session,
        context = ctx.world,
        clock = ctx.clock or os.clock,
        round = nil,
        state = "IDLE",
        rabbitBasket = nil,
        accepted = {},
        actionReceipts = {},
        actionIdentities = {},
        contributors = {},
        busyThrowAction = nil,
        busyThrowActor = nil,
        targetIndex = 0,
        reservations = {},
        replayCount = 0,
        jasperMode = "BEDROOM",
        lastError = nil,
    }, Activity)
    return self
end

function Activity:_feedback(name, ...)
    local hook = self.context[name]
    if hook then local ok, err = pcall(hook, ...); if not ok then warn("PCW-22 Jasper feedback", name, err) end end
end

local function identity(request)
    local p = request.payload or {}
    return table.concat({tostring(request.actorUserId), tostring(request.roundId), tostring(request.stepId), tostring(p.basketIndex), tostring(p.targetIndex)}, ":")
end

function Activity:_actorId(request)
    assert(request and type(request.actorUserId) == "number" and request.actorUserId > 0 and request.actorUserId % 1 == 0, "authenticated actorUserId is required")
    return request.actorUserId
end

function Activity:_present(actorUserId)
    if self.context.isPresent then return self.context.isPresent(actorUserId) end
    return self.session:IsPresent(actorUserId)
end

function Activity:_action(request)
    assert(request and request.actionId and request.roundId and request.stepId, "Q02 action fields are required")
    assert(self.round and request.roundId == self.round.roundId, "Q02 round is not active")
    local prior = self.actionReceipts[request.actionId]
    if prior then return prior end
    assert(self:_present(self:_actorId(request)), "actor is not present")
end

function Activity:CreateRound(request)
    assert(request and request.sessionId == self.session.sessionId and request.activityId == "Q02" and request.roundId, "Q02 round request is invalid")
    assert(not self.round or self.state == "COMPLETED", "Q02 already has an active round")
    assert(not self.round or request.replay == true, "replay must be explicit")
    assert(self:_present(self:_actorId(request)), "actor is not present")
    local created = self.session:CreateRound("Q02", request.roundId, self:_actorId(request))
    self.round = { activityId = "Q02", roundId = request.roundId, startedBy = created.startedBy, isReplay = created.isReplay }
    self.replayCount = request.replay == true and self.replayCount + 1 or self.replayCount
    self.state, self.jasperMode = "GREETING", "BEDROOM"
    self.rabbitBasket, self.targetIndex = nil, 0
    self.accepted, self.actionReceipts, self.actionIdentities, self.contributors, self.reservations = {}, {}, {}, {}, {}
    self.busyThrowAction, self.busyThrowActor = nil, nil
    self.lastError = nil
    self:_feedback("resetJasper", request.roundId)
    return clone(self.round)
end

function Activity:_accept(request)
    local actorUserId = self:_actorId(request)
    local prior = self.actionReceipts[request.actionId]
    if prior then return prior end
    assert(not self.accepted[request.stepId], "step already accepted")
    local accepted = self.session:ApplyStep({sessionId = self.session.sessionId, activityId = "Q02", roundId = request.roundId, stepId = request.stepId, actionId = request.actionId, actorUserId = actorUserId})
    if accepted.receipt then accepted = accepted.receipt end
    self.accepted[request.stepId] = accepted
    self.actionReceipts[request.actionId] = accepted
    self.actionIdentities[request.actionId] = identity(request)
    self.contributors[actorUserId] = true
    return accepted
end

function Activity:_requirePrevious(stepId)
    local index
    for position, step in ipairs(STEPS) do if step == stepId then index = position end end
    assert(index, "unknown Q02 step")
    for position = 1, index - 1 do assert(self.accepted[STEPS[position]], "previous Q02 step is incomplete") end
end

function Activity:_basketForRound()
    local chooser = self.context.chooseRabbitBasket
    local value = chooser and chooser(self.round.roundId) or 1
    return math.clamp(tonumber(value) or 1, 1, 3)
end

function Activity:Apply(request)
    assert(request and request.sessionId == self.session.sessionId and request.activityId == "Q02", "invalid Q02 session")
    assert(self.round and request.roundId == self.round.roundId, "Q02 round is not active")
    local prior = request and request.actionId and self.actionReceipts[request.actionId]
    if prior then
        assert(self.actionIdentities[request.actionId] == identity(request), "action identity changed")
        return {ok = true, code = "duplicate", receipt = prior, view = self:GetView(self:_actorId(request))}
    end
    assert(not (self.session.receipts and self.session.receipts[request.actionId]) and not (self.session.acceptedSteps and self.session.acceptedSteps[request.actionId]), "action belongs to another receipt")
    self:_action(request)
    local actorUserId = self:_actorId(request)
    local stepId = request.stepId
    if stepId == "greet" then
        assert(self.state == "GREETING", "greeting is closed")
        local receipt = self:_accept(request)
        self.state, self.jasperMode = "LEADING", "LEADING_TO_YARD"
        self:_feedback("moveJasperToYard")
        return {ok = true, code = "accepted", receipt = receipt, view = self:GetView(actorUserId)}
    elseif stepId == "rabbitFound" then
        self:_requirePrevious(stepId)
        assert(self.state == "LEADING" or self.state == "RABBIT", "rabbit search is not available")
        if not self.rabbitBasket then self.rabbitBasket = self:_basketForRound() end
        if tonumber(request.payload and request.payload.basketIndex) ~= self.rabbitBasket then
            return {ok = false, code = "empty_basket", receipt = {activityId = "Q02", roundId = self.round.roundId, stepId = "rabbitFound", actionId = request.actionId, accepted = false}, view = self:GetView(actorUserId)}
        end
        local receipt = self:_accept(request)
        self.state = "RABBIT"
        self:_feedback("showRabbitPickup", self.rabbitBasket)
        return {ok = true, code = "accepted", receipt = receipt, view = self:GetView(actorUserId)}
    elseif stepId == "rabbitReturned" then
        self:_requirePrevious(stepId)
        assert(self.state == "RABBIT", "rabbit is not ready for return")
        local reservation = self.reservations.rabbit
        if reservation and reservation ~= actorUserId then error("rabbit is being carried by another player") end
        self.reservations.rabbit = nil
        local receipt = self:_accept(request)
        self.state, self.jasperMode = "FETCH", "FETCH_READY"
        self:_feedback("returnRabbit")
        self:_feedback("presentFetchTarget", 1)
        return {ok = true, code = "accepted", receipt = receipt, view = self:GetView(actorUserId)}
    elseif FETCH_STEPS[stepId] then
        self:_requirePrevious(stepId)
        assert(self.state == "FETCH", "fetch is not available")
        local expected = self.targetIndex + 1
        assert(stepId == "fetch" .. expected and expected <= 3, "wrong fetch step")
        assert(tonumber(request.payload and request.payload.targetIndex) == expected, "wrong fetch target")
        assert(not self.busyThrowAction, "fetch target is occupied")
        self.busyThrowAction, self.busyThrowActor = request.actionId, actorUserId
        local accepted = self:_accept(request)
        self.busyThrowAction, self.busyThrowActor = nil, nil
        self.targetIndex = expected
        self:_feedback("fetchJasper", expected)
        self:_feedback("presentFetchTarget", expected < 3 and expected + 1 or nil)
        if expected == 3 then self.state = "GREENIE" end
        return {ok = true, code = "accepted", receipt = accepted, view = self:GetView(actorUserId)}
    elseif stepId == "greenie" then
        self:_requirePrevious(stepId)
        assert(self.state == "GREENIE", "Greenie is not available")
        local receipt = self:_accept(request)
        self.state, self.jasperMode = "COMPLETED", "CELEBRATING"
        local completed = self.session:CompleteRound({sessionId = self.session.sessionId, activityId = "Q02", roundId = self.round.roundId, actionId = request.actionId .. ":complete", actorUserId = actorUserId})
        self:_feedback("giveJasperTreat")
        return {ok = true, code = "completed", receipt = completed, view = self:GetView(actorUserId)}
    elseif stepId == "pet" then
        assert(self.state == "COMPLETED", "petting is available after Greenie")
        local receipt = {activityId = "Q02", roundId = self.round.roundId, stepId = "pet", actionId = request.actionId, reward = 0, petalGranted = false}
        self.actionReceipts[request.actionId], self.actionIdentities[request.actionId] = receipt, identity(request)
        self:_feedback("petJasper", actorUserId)
        return {ok = true, code = "petted", receipt = receipt, view = self:GetView(actorUserId)}
    end
    error("unknown Q02 action: " .. tostring(stepId))
end

function Activity:ReleaseActor(actorUserId)
    for key, value in pairs(self.reservations) do if value == actorUserId then self.reservations[key] = nil end end
    if self.busyThrowActor == actorUserId then self.busyThrowAction, self.busyThrowActor = nil, nil end
end

function Activity:RecoveryState()
    return { roundId = self.round and self.round.roundId, state = self.state, accepted = self.accepted, reservations = self.reservations }
end
function Activity:RecoverComplete(request)
    self.session:AssertRecovery(request)
    for _, step in ipairs(STEPS) do self.accepted[step] = self.session:RecoverStep(request, step) end
    local receipt = self.session:RecoverCompleteRound(request)
    self.state, self.jasperMode, self.targetIndex = "COMPLETED", "CELEBRATING", 3
    self.contributors[request.actorUserId] = true
    self.reservations, self.busyThrowAction, self.busyThrowActor = {}, nil, nil
    self:_feedback("resetJasper", request.roundId)
    self:_feedback("moveJasperToYard")
    self:_feedback("returnRabbit")
    self:_feedback("presentFetchTarget", nil)
    self:_feedback("giveJasperTreat")
    return receipt
end

function Activity:GetView(actorUserId)
    local actions = {}
    if self.state == "GREETING" then actions = {{id="greet", label="Say hi to Jasper", stepId="greet", payload={}, enabled=true}}
    elseif self.state == "LEADING" then actions = {
        {id="rabbitFound-1", label="Inspect basket 1", stepId="rabbitFound", payload={basketIndex=1}, enabled=true},
        {id="rabbitFound-2", label="Inspect basket 2", stepId="rabbitFound", payload={basketIndex=2}, enabled=true},
        {id="rabbitFound-3", label="Inspect basket 3", stepId="rabbitFound", payload={basketIndex=3}, enabled=true},
    }
    elseif self.state == "RABBIT" then actions = {{id="rabbitReturned", label="Return rabbit to Jasper", stepId="rabbitReturned", payload={}, enabled=true}}
    elseif self.state == "FETCH" then actions = {{id="fetch" .. tostring(self.targetIndex + 1), label="Pick up toy + gentle throw " .. tostring(self.targetIndex + 1), stepId="fetch" .. tostring(self.targetIndex + 1), payload={targetIndex=self.targetIndex + 1}, enabled=self.busyThrowAction == nil, reason=self.busyThrowAction and "Target occupied" or nil}}
    elseif self.state == "GREENIE" then actions = {{id="greenie", label="Give Greenie", stepId="greenie", payload={}, enabled=true}}
    elseif self.state == "COMPLETED" then actions = {{id="pet", label="Pet Jasper", stepId="pet", payload={}, enabled=true}} end
    local indoor = self.state == "GREETING" or self.state == "IDLE"
    local required = indoor and "Bedroom" or "Yard"
    local atStation = not self.context.jasperVenue or self.context.jasperVenue(actorUserId) == required
    local detail = ({GREETING="Say hello, then follow Jasper's marker to the yard.", LEADING="Meet Jasper in the yard. Inspect the numbered baskets to find his rabbit.", RABBIT="The rabbit is found. Anyone nearby can return it to Jasper.", FETCH="Choose a gentle throw. Jasper fetches and brings the toy back; there is no aiming or timing test.", GREENIE="Three toys returned! Give Jasper his Greenie.", COMPLETED="Jasper is happy. Your shared petal and reward are saved. Petting and replay are optional."})[self.state] or "Say hello to Jasper in the bedroom."
    if not atStation then detail = "Next · " .. (indoor and "Phuong's bedroom" or "Jasper's yard") .. ". Track the marker, then open Jasper's prompt. Shared progress stays saved." end
    for _, action in ipairs(actions) do action.primary=#actions==1; action.confirm=false; if not atStation then action.enabled=false; action.reason="Walk to " .. (indoor and "the bedroom" or "Jasper's yard") .. " first." end end
    local done=0; for _ in pairs(self.accepted) do done+=1 end
    return {activityId = "Q02", roundId = self.round and self.round.roundId, state = self.state, title = "Jasper's Favorite Things", instructions = detail, progress = {done = done, total = #STEPS}, fetchCount=self.targetIndex, atStation=atStation,
        guide={headline=self.state=="COMPLETED" and "Jasper's favorite things · done!" or "Visit Jasper · "..(indoor and "bedroom" or "yard"), detail=detail, nextAnchor=indoor and "JasperBedroomStart" or "JasperFetchYard"},
        availableActions = actions, acceptedStepIds = clone(self.accepted), contributors = clone(self.contributors), busyReason = self.busyThrowAction and "fetch_target_occupied" or nil, errorText = self.lastError, canReplay = self.state == "COMPLETED"}
end

return Activity
]=],
["roblox/mvp/server/activities/Q03.luau"] = [=[-- One shared miniature. SessionService retains the original six-part reward timing.
local Q03 = {}; Q03.__index = Q03
local PARTS = {"rug", "chair", "bookcase", "side_table", "plant", "lamp"}
local SOCKETS = {rug="rugSocket", chair="chairSocket", bookcase="bookcaseSocket", side_table="sideTableSocket", plant="plantSocket", lamp="lampSocket"}
local LABELS = {rug="Rug", chair="Chair", bookcase="Bookcase", side_table="Side table", plant="Plant", lamp="Lamp"}
local function copy(t) local r={}; for k,v in pairs(t) do r[k]=type(v)=="table" and copy(v) or v end; return r end
local function validId(value) return type(value)=="string" and value~="" end
local function validActorId(value) return type(value)=="number" and value>0 and value%1==0 end
local function identity(r)
    local p=r.payload or {}
    return table.concat({tostring(r.actorUserId),tostring(r.roundId),tostring(r.stepId),tostring(p.action),tostring(p.partId),tostring(p.socketId),tostring(p.direction),tostring(p.presentation)},":")
end
local function free(entry)
    entry.status="AVAILABLE"; entry.ownerUserId=nil; entry.partId=nil; entry.orientation=nil; entry.lastActivity=nil
end
function Q03.new(options)
    assert(options and options.session and options.clock and options.context,"Q03 context dependencies are required")
    return setmetatable({session=options.session,actorResolver=options.actorResolver,clock=options.clock,context=options.context,rounds={},actions={},actionIdentities={},stateByRound={},currentRoundId=nil,expiryRevision=0},Q03)
end
function Q03:_actor(request)
    local actor=self.actorResolver and self.actorResolver(request) or request.actorUserId
    return actor and actor==request.actorUserId and self.session:IsPresent(actor)
end
function Q03:_canFinalize(actor)
    if not self.session:IsPresent(actor) then return false end
    return actor==self.session.phuongUserId or (not self.session:IsPresent(self.session.phuongUserId) and self.session.hostUserId~=0 and actor==self.session.hostUserId)
end
function Q03:_round(request) return self.stateByRound[request.roundId] end
function Q03:_committedParts(state) local r={}; for _,id in ipairs(PARTS) do if state.committed[id] then table.insert(r,id) end end; return r end
function Q03:_render(state)
    if not self.context.renderCraft then return end
    local ok,err=pcall(self.context.renderCraft,self.currentRoundId,state.committed,state.reservations,state.finalPresentation)
    if not ok then warn("PCW-22 craft presentation",err) end
end
function Q03:_view(roundId,actor,errorText)
    local state=self.stateByRound[roundId]; local actions,accepted,contributors,pieces={},{},{},{}
    local done=state and #self:_committedParts(state) or 0
    local held
    for _,id in ipairs(PARTS) do
        local socket=SOCKETS[id]; local entry=state and state.sockets[socket]
        local committed=state and state.committed[id]
        if committed then table.insert(accepted,id) end
        table.insert(pieces,{id=id,label=LABELS[id],socketId=socket,complete=committed~=nil,orientation=committed and committed.orientation or 0,busy=entry and entry.status=="RESERVED" or false})
        if entry and entry.status=="RESERVED" and entry.ownerUserId==actor then held={partId=id,label=LABELS[id],socketId=socket,orientation=entry.orientation,expiresAt=entry.lastActivity+15} end
        if state and state.status=="IN_PROGRESS" and not committed then
            local available=entry.status=="AVAILABLE"
            table.insert(actions,{id="reserve:"..id,label="Pick up "..LABELS[id],stepId="reserve:"..id,payload={action="reserve",socketId=socket,partId=id},enabled=available,
                reason=available and nil or entry.ownerUserId==actor and "Already selected. Turn it or place it below." or "A friend is using this socket.",groupId="parts",description="Fits the labeled "..LABELS[id].." socket. Preview before placing.",confirm=false})
        end
    end
    if state then for id in pairs(state.contributors) do table.insert(contributors,id) end end
    if held then
        for _,direction in ipairs({-1,1}) do
            local side=direction<0 and "left" or "right"
            table.insert(actions,{id="rotate-"..side..":"..held.partId,label="Turn "..held.label.." "..side.." · 90°",stepId="rotate-"..side..":"..held.partId,payload={action="rotate",socketId=held.socketId,direction=direction},enabled=true,groupId="placement",confirm=false})
        end
        table.insert(actions,{id="place:"..held.partId,label="Place "..held.label,stepId="place:"..held.partId,payload={action="place",socketId=held.socketId,partId=held.partId},enabled=true,groupId="placement",primary=true,description="Save this orientation in the shared miniature at both locations.",confirm=false})
        table.insert(actions,{id="cancel:"..held.partId,label="Put "..held.label.." back",stepId="cancel:"..held.partId,payload={action="cancel",socketId=held.socketId},enabled=true,groupId="placement",confirm=false})
    end
    if state and state.status=="COMPLETED" and not state.finalizationReceipt then
        local allowed=self:_canFinalize(actor)
        for _,option in ipairs({{id="lamp_on",label="A warm golden lamp"},{id="lamp_off",label="A quiet cream lamp"}}) do
            table.insert(actions,{id="finalize:"..option.id,label=option.label,stepId="finalize:"..option.id,payload={action="finalize",presentation=option.id},enabled=allowed,reason=allowed and nil or "Phuong adds the finishing touch. Andrew can help when Phuong is away.",groupId="finish",description="Choose how the completed keepsake is displayed. Your petal is already saved.",confirm={title="Finish the shared keepsake?",detail=option.label.." will appear at the booth and in the bedroom.",label="Save finishing touch"}})
        end
    end
    local finishing=state and state.status=="COMPLETED" and not state.finalizationReceipt
    local detail=finishing and "All six parts are placed. Find the bedroom keepsake for Phuong's finishing touch; Andrew can help when Phuong is away. The shared reward is already saved."
        or state and state.finalizationReceipt and "The shared keepsake is finished at the booth and in the bedroom. Your petal is saved; another round is optional."
        or held and (held.label.." selected · turn left or right, then Place. The golden socket and translucent piece are a preview.")
        or "Pick a labeled piece. Match its socket, turn it if you like, then Place. Friends can work on different pieces together."
    return {activityId="Q03",roundId=roundId,state=state and state.status or "NONE",title="A Tiny World of Her Own",instructions=detail,progress={done=done,total=#PARTS},availableActions=actions,
        acceptedStepIds=accepted,contributors=contributors,errorText=errorText,canReplay=state and state.status=="COMPLETED" or false,
        craft={pieces=pieces,held=held,finalPresentation=state and state.finalPresentation,needsFinishing=finishing==true}]==]
return #_G.__PCW25ContractText