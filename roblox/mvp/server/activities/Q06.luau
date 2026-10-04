-- Guided, shared food assembly. Only SessionService grants progress and rewards.
local Q06 = {}
Q06.__index = Q06
Q06.ActivityId = "Q06"
Q06.ReservationSeconds = 30
Q06.StepIds = { "base", "protein", "toppings", "sauce", "settingA", "settingB" }
local SLOTS = {
	base = { label = "Base", venue = "FOB", items = { "rice" } },
	protein = { label = "Protein", venue = "FOB", items = { "tofu", "chicken", "mushroom" } },
	toppings = { label = "Fresh topping", venue = "FOB", items = { "greens", "cucumber", "carrot" } },
	sauce = { label = "Sauce", venue = "Aladdins", items = { "sauce", "sesame" } },
	settingA = { label = "Left table setting", venue = "Serving", items = { "plate", "napkin" } },
	settingB = { label = "Right table setting", venue = "Serving", items = { "cup", "napkin" } },
}
local ITEMS = {
	rice = { label = "Rice", detail = "A soft rice base for the shared bowl." },
	tofu = { label = "Tofu", detail = "Add small tofu cubes." },
	chicken = { label = "Chicken", detail = "Add warm chicken pieces." },
	mushroom = { label = "Mushroom", detail = "Add a few mushroom slices." },
	greens = { label = "Greens", detail = "Add a handful of leafy greens." },
	cucumber = { label = "Cucumber", detail = "Add crisp cucumber rounds." },
	carrot = { label = "Carrot", detail = "Add a few carrot strips." },
	sauce = { label = "Sauce", detail = "Drizzle sauce over the bowl." },
	sesame = { label = "Sesame", detail = "Finish the bowl with sesame seeds." },
	plate = { label = "Plate", detail = "Set a cream plate to the left of the bowl." },
	cup = { label = "Cup", detail = "Set a cup to the right of the bowl." },
	napkin = { label = "Napkin", detail = "Place a folded napkin at this table spot." },
}
local VENUES = {
	FOB = { label = "FOB", anchor = "Q06FOBCounter", detail = "Choose rice, a protein and a fresh topping at FOB. Friends can help with different parts." },
	Aladdins = { label = "Aladdins", anchor = "Q06AladdinsCounter", detail = "The bowl is built! Visit Aladdins and choose sauce or sesame." },
	Serving = { label = "the serving table", anchor = "Q06Serving", detail = "The bowl is ready. Set the left and right table spots to finish your shared meal." },
}
local RECIPE = "Build a bowl at FOB, add sauce at Aladdins, then set the serving table. Choose a card, preview your choice, then Add or Place."
local function clone(value)
	if type(value) ~= "table" then return value end
	local copy = {}; for key, child in pairs(value) do copy[key] = clone(child) end; return copy
end
local function contains(list, value) for _, item in ipairs(list) do if item == value then return true end end; return false end
local function stage(round)
	if not round or not round.accepted.base or not round.accepted.protein or not round.accepted.toppings then return "FOB" end
	if not round.accepted.sauce then return "Aladdins" end
	return "Serving"
end

function Q06.new(options)
	assert(options and options.session and options.clock and options.context, "Q06 dependencies are required")
	return setmetatable({ session = options.session, clock = options.clock, context = options.context,
		feedback = options.feedback, rounds = {}, currentRoundId = nil, expiryRevision = 0,
	}, Q06)
end
function Q06:GetVenue(actor)
	-- Main supplies a read-only function derived from the actual live character.
	return self.context.foodVenue and self.context.foodVenue(actor) or nil
end
function Q06:_round() return self.currentRoundId and self.rounds[self.currentRoundId] or nil end
function Q06:_render(round)
	if self.feedback then self.feedback:Render(round.roundId, round.accepted, stage(round), round.state == "COMPLETED") end
end
function Q06:CreateRound(request)
	assert(request.sessionId == self.session.sessionId and request.activityId == self.ActivityId and self.session:IsPresent(request.actorUserId), "Q06 canonical actor/session required")
	assert(type(request.roundId) == "string" and not self.rounds[request.roundId], "Q06 requires a new round ID")
	local prior = self:_round()
	assert(not prior or prior.state == "COMPLETED" and request.replay == true, "Q06 requires completed round and explicit replay")
	assert(prior or request.replay ~= true, "Q06 first round cannot be replay")
	if request.replay then self.session:StartNextRound(self.ActivityId, request.roundId, request.actorUserId)
	else self.session:CreateRound(self.ActivityId, request.roundId, request.actorUserId) end
	local round = { roundId = request.roundId, state = "IN_PROGRESS", isReplay = request.replay == true,
		accepted = {}, reservations = {}, heldByActor = {}, contributors = {}, actions = {} }
	self.rounds[request.roundId], self.currentRoundId = round, request.roundId
	local ok,err=pcall(self._render,self,round)
	if not ok then warn("Food round presentation needs attention",err) end
	return { activityId = self.ActivityId, roundId = round.roundId, replay = round.isReplay }
end
function Q06:ReleaseActor(actor, roundId)
	local round = self:_round()
	if not round or roundId and roundId ~= round.roundId then return end
	local hold = round.heldByActor[actor]
	if hold then round.reservations[hold.slotId], round.heldByActor[actor] = nil, nil end
end
function Q06:ExpireReservations(at)
	local round, changed = self:_round(), false
	if round then for actor, hold in pairs(round.heldByActor) do
		if hold.expiresAt <= (at or self.clock()) then self:ReleaseActor(actor); changed = true end
	end end
	if changed then self.expiryRevision += 1 end
	return changed
end
function Q06:_change(request, round)
	local payload, actor = request.payload, request.actorUserId
	local slotId, itemId = payload.slotId, payload.itemId
	local slot = SLOTS[slotId]
	if not slot or request.stepId ~= slotId then return false, "INVALID_SLOT", "Choose a labeled ingredient or table spot." end
	if payload.action == "cancel" then self:ReleaseActor(actor); return true, "CANCELLED", "Selection put back. The shared dish is saved." end
	if round.state ~= "IN_PROGRESS" then return false, "ROUND_COMPLETED", "Done! Your meal is saved. You can help with another activity." end
	if payload.action ~= "select" and payload.action ~= "add" then return false, "INVALID_ACTION", "Preview an ingredient, then use Add or Place." end
	if not contains(slot.items, itemId) then return false, "INVALID_ITEM", "Choose one of the ingredient cards for this spot." end
	if round.accepted[slotId] then return false, "ALREADY_ACCEPTED", "A friend already finished that part. Your shared dish is up to date." end
	local nextVenue = stage(round)
	if slot.venue ~= nextVenue or self:GetVenue(actor) ~= slot.venue then
		return false, "NEXT_COUNTER", "Your next step is at " .. VENUES[nextVenue].label .. ". Use Track next counter to get there."
	end
	local reservation = round.reservations[slotId]
	if reservation and reservation.actorUserId ~= actor then return false, "SLOT_BUSY", "A friend is choosing for this spot. Pick another part or try again shortly." end
	if payload.action == "select" then
		self:ReleaseActor(actor)
		local hold = { slotId = slotId, itemId = itemId, actorUserId = actor, expiresAt = self.clock() + self.ReservationSeconds }
		round.reservations[slotId], round.heldByActor[actor] = hold, hold
		return true, "SELECTED", ITEMS[itemId].label .. " is selected. Use " .. (slot.venue == "Serving" and "Place" or "Add") .. " when you are ready."
	end
	if not reservation or reservation.actorUserId ~= actor or reservation.itemId ~= itemId then
		return false, "HOLD_EXPIRED", "Your selection was put back. Preview the ingredient again, then add it."
	end
	-- Add commits the exact held variant. No default food replaces the request.
	local accepted = self.session:ApplyStep(request)
	local receipt = { roundId = round.roundId, stepId = slotId, actionId = request.actionId,
		actorUserId = actor, itemId = itemId, roleId = slot.venue, accepted = true, acceptedStep = accepted }
	round.accepted[slotId], round.contributors[actor] = receipt, true
	self:ReleaseActor(actor)
	local complete = true
	for _, id in ipairs(self.StepIds) do if not round.accepted[id] then complete = false; break end end
	if complete then
		receipt.completion = self.session:CompleteRound({ sessionId = self.session.sessionId, activityId = self.ActivityId,
			roundId = round.roundId, actionId = "complete:" .. round.roundId, actorUserId = actor })
		round.state = "COMPLETED"
		round.reservations, round.heldByActor = {}, {}
	end
	self:_render(round)
	return true, complete and "ROUND_COMPLETED" or "STEP_ACCEPTED", complete and "Done! Your shared meal is ready." or ITEMS[itemId].label .. " added to the shared meal.", receipt
end
function Q06:Apply(request)
	if type(request) ~= "table" or request.sessionId ~= self.session.sessionId or request.activityId ~= self.ActivityId
		or not self.session:IsPresent(request.actorUserId) or type(request.actionId) ~= "string" or request.actionId == ""
		or type(request.payload) ~= "table" then return { ok = false, code = "BadAction", message = "Reopen the food activity to see fresh choices." } end
	local round = self:_round()
	if not round or request.roundId ~= round.roundId then return { ok = false, code = "ROUND_CHANGED", message = "This food round changed. Reopen it to see the current dish." } end
	local prior = round.actions[request.actionId]
	if prior then
		if prior.actor ~= request.actorUserId or prior.step ~= request.stepId or prior.action ~= request.payload.action
			or prior.slot ~= request.payload.slotId or prior.item ~= request.payload.itemId then return { ok = false, code = "BadAction" } end
		return { ok = prior.ok, code = "DUPLICATE", message = prior.message, receipt = clone(prior.receipt), view = self:GetView(request.actorUserId) }
	end
	-- Protect against reusing a SessionService receipt from another activity.
	if self.session.receipts[request.actionId] or self.session.acceptedSteps[request.actionId] then return { ok = false, code = "BadAction" } end
	self:ExpireReservations()
	local ok, code, message, receipt = self:_change(request, round)
	round.actions[request.actionId] = { actor = request.actorUserId, step = request.stepId, action = request.payload.action,
		slot = request.payload.slotId, item = request.payload.itemId, ok = ok, message = message, receipt = clone(receipt) }
	return { ok = ok, code = code, message = message, receipt = clone(receipt), view = self:GetView(request.actorUserId) }
end

function Q06:RecoveryState()
	local round=self:_round()
	return {roundId=self.currentRoundId,state=round and round.state,accepted=round and round.accepted,reservations=round and round.reservations}
end
function Q06:RecoverRelease(request)
	self.session:AssertRecovery(request)
	local round=self:_round()
	if round then round.reservations,round.heldByActor={},{}; self.expiryRevision+=1 end
end
function Q06:RecoverRestart(request,newRoundId)
	self.session:RecoverCancel(request); self:RecoverRelease(request)
	self.currentRoundId=nil
	self:CreateRound({sessionId=request.sessionId,activityId="Q06",roundId=newRoundId,actorUserId=request.actorUserId})
	self:_round().isReplay=self.session.rounds[newRoundId].isReplay
	return newRoundId
end
function Q06:RecoverComplete(request)
	self.session:AssertRecovery(request); self:RecoverRelease(request)
	local round=assert(self:_round(),"missing food round")
	for _,slot in ipairs(self.StepIds) do
		local accepted=self.session:RecoverStep(request,slot)
		round.accepted[slot]=round.accepted[slot] or {roundId=round.roundId,stepId=slot,actorUserId=request.actorUserId,
			itemId=SLOTS[slot].items[1],roleId=SLOTS[slot].venue,accepted=true,acceptedStep=accepted,recovery=true}
	end
	local receipt=self.session:RecoverCompleteRound(request)
	round.state="COMPLETED"; round.contributors[request.actorUserId]=true
	local ok,err=pcall(self._render,self,round)
	if not ok then warn("PCW-24 food recovery presentation",err) end
	return receipt
end

function Q06:GetView(actor)
	self:ExpireReservations()
	local round, venue = self:_round(), self:GetVenue(actor)
	local nextVenue = stage(round)
	local nextInfo, actions, groups, accepted, summary = VENUES[nextVenue], {}, {}, {}, {}
	local done = round and round.state == "COMPLETED" or false
	local hold = round and round.heldByActor[actor]
	local atCounter = venue == nextVenue
	local function descriptor(id, label, slotId, itemId, operation, extra)
		local value = { id = id, label = label, stepId = slotId, enabled = true, groupId = slotId,
			payload = { action = operation, slotId = slotId, itemId = itemId } }
		for key, child in pairs(extra or {}) do value[key] = child end
		table.insert(actions, value)
	end
	if hold and atCounter and not done then
		local label = ITEMS[hold.itemId].label
		local verb = nextVenue == "Serving" and "Place" or "Add"
		table.insert(groups, { id = "placement", title = verb .. " your selected " .. string.lower(label), detail = "This is still a preview. Only " .. verb .. " saves it for everyone." })
		descriptor("add-" .. hold.slotId .. "-" .. hold.itemId, verb .. " " .. string.lower(label), hold.slotId, hold.itemId, "add",
			{ groupId = "placement", primary = true, description = label .. " → " .. SLOTS[hold.slotId].label .. " at " .. nextInfo.label })
		descriptor("cancel-selection", "Cancel selection", hold.slotId, hold.itemId, "cancel", { groupId = "placement", description = "Put back this selection. Keep the shared dish." })
	end
	for _, slotId in ipairs(self.StepIds) do
		local slot, receipt = SLOTS[slotId], round and round.accepted[slotId]
		table.insert(summary, { slotId = slotId, itemId = receipt and receipt.itemId, label = slot.label,
			detail = receipt and ITEMS[receipt.itemId].label or "Choose at " .. VENUES[slot.venue].label, complete = receipt ~= nil })
		if receipt then table.insert(accepted, slotId)
		elseif round and atCounter and slot.venue == nextVenue and not done then
			local busy = round.reservations[slotId]
			local blocked = busy ~= nil and busy.actorUserId ~= actor
			table.insert(groups, { id = slotId, title = slot.label, detail = blocked and "A friend is choosing here. Other parts are available." or "Choose a card and preview it. Nothing is added until you use Add or Place." })
			for _, itemId in ipairs(slot.items) do
				descriptor("select-" .. slotId .. "-" .. itemId, "Preview " .. string.lower(ITEMS[itemId].label), slotId, itemId, "select",
					{ enabled = not blocked, selected = hold ~= nil and hold.slotId == slotId and hold.itemId == itemId,
						description = ITEMS[itemId].detail, reason = blocked and "In use · a friend is choosing here" or nil, confirm = false })
			end
		end
	end
	local nextActivity
	if done then
		if not self.session.petals.Q05 and self.session.fundBalance >= 20 then nextActivity = "Q05"
		else for _, id in ipairs({ "Q01", "Q02", "Q03", "Q04", "Q05" }) do if not self.session.petals[id] then nextActivity = id; break end end end
		nextActivity = nextActivity or "Cake"
	end
	local detail = done and "Done! Your meal is saved for everyone. You can help with another activity or visit the Labubu booth. Replay is optional."
		or not atCounter and "Next: " .. nextInfo.label .. ". Track the counter, walk over and open its prompt. Your shared dish stays saved."
		or hold and ("Selected: " .. ITEMS[hold.itemId].label .. ". Check the preview, then " .. (nextVenue == "Serving" and "Place" or "Add") .. ".")
		or nextInfo.detail
	return { activityId = self.ActivityId, roundId = round and round.roundId, state = round and round.state or "NOT_STARTED",
		title = "Something Delicious", actorUserId = actor, instructions = RECIPE, recipe = RECIPE, currentVenue = venue,
		nextVenue = nextVenue, atCounter = atCounter, nextActivity = nextActivity,
		progress = { done = #accepted, total = 6 }, availableActions = actions, acceptedStepIds = accepted,
		contributors = clone(round and round.contributors or {}), canReplay = done,
		foodDisplay = clone(round and round.accepted or {}), dishSummary = summary,
		held = hold and { slotId = hold.slotId, itemId = hold.itemId, label = ITEMS[hold.itemId].label,
			destination = SLOTS[hold.slotId].label .. " at " .. VENUES[SLOTS[hold.slotId].venue].label, expiresAt = hold.expiresAt } or nil,
		busyReason = not atCounter and not done and "Track next counter to continue. Your accepted ingredients stay saved." or nil,
		guide = { headline = done and "Done · your shared meal is ready!" or "Make a meal together",
			detail = detail, stepLabel = #accepted .. " of 6 steps · " .. (done and "Meal ready" or "Next: " .. nextInfo.label),
			nextAnchor = not done and nextInfo.anchor or nil, groups = groups },
	}
end
return Q06
