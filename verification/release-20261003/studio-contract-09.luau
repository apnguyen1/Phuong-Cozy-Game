_G.__PCW25ContractText..=[==[wish and opens the boxes. Friends help earn the shared fund; Andrew can help while Phuong is away."
	return { activityId = "Q05", roundId = self.roundId, state = storyComplete and "FULFILLED" or "READY", title = "A Labubu Wish",
		instructions = "Friends earn together. Phuong confirms her wish. Each box costs 20; the wish arrives by box five. Collection copies: " .. tostring(total),
		progress = { done = storyComplete and 1 or 0, total = 1 }, availableActions = actions, acceptedStepIds = storyComplete and { "wanted-fulfilled" } or {}, contributors = {},
		busyReason = controlMessage, errorText = nil, canReplay = false, sharedFundBalance = snapshot.fundBalance,
		wantedFigureId = self.wanted, wantedLabel = self.wanted and Catalog.Label(self.wanted) or "No wish confirmed yet", wishVersion = self.wishVersion,
		unsuccessfulRollCount = self.misses, rollCount = self.rolls, attemptsRemaining = remaining, wishFulfilled = self.fulfilled,
		q05Petal = storyComplete, collection = clone(self.collection), collectionCount = total, figures = figures,
		canControl = controller, canChooseWish = selectable, controlMessage = controlMessage,
		latestResult = self.latestResult and clone(self.latestResult) or nil, nextActivity = nextActivity,
		guide = { headline = storyComplete and "Phuong's Labubu wish is complete!" or self.wanted and "Your wish is confirmed · " .. Catalog.Label(self.wanted) or "Choose Phuong's birthday wish",
			detail = storyComplete and "Your petal is saved. Continue the birthday story; any more collecting is optional and cannot relock cake." or controlMessage,
			stepLabel = self.fulfilled and "Wish received · petal saved" or self.wanted and tostring(remaining) .. " boxes or fewer until your wish" or "Preview a card → Confirm wish → Get a Labubu",
			groups = { { id = "wish", title = "Choose a wish", kind = "choices" }, { id = "open", title = "Open a box", kind = "actions" } } } }
end
Q05.Figures = Figures
return Q05
]=],
["roblox/mvp/server/activities/Q06.luau"] = [=[-- Guided, shared food assembly. Only SessionService grants progress and rewards.
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
]=],
["roblox/mvp/server/BedroomFeedback.luau"] = [=[-- PCW-19 owns this runtime presentation and narrowly selected bed details only.
-- Never rebuild the bedroom or move the bookcase's original furnishings.
local BedroomFeedback = {}
BedroomFeedback.__index = BedroomFeedback
local P = {
	forest = Color3.fromRGB(54, 87, 68), sage = Color3.fromRGB(168, 185, 149), cream = Color3.fromRGB(245, 240, 228),
	wood = Color3.fromRGB(149, 103, 75), blossom = Color3.fromRGB(232, 183, 198), brick = Color3.fromRGB(182, 108, 104),
	golden = Color3.fromRGB(232, 199, 121), ink = Color3.fromRGB(38, 56, 46),
}
local function folder(parent, name)
	local value = Instance.new("Folder"); value.Name = name; value.Parent = parent; return value
end
local function part(parent, name, size, frame, token)
	local value = Instance.new("Part")
	value.Name, value.Size, value.CFrame = name, size, frame
	value.Anchored, value.CanCollide, value.CanTouch, value.CanQuery = true, false, false, false
	value.Color, value.Material, value.CastShadow = P[token], Enum.Material.SmoothPlastic, false
	value:SetAttribute("PaletteToken", token); value:SetAttribute("VerificationTicket", "PCW-19")
	value.Parent = parent; return value
end
local function baseName(name, prefix) return name == prefix or string.sub(name, 1, #prefix + 1) == prefix .. "_" end
local function namedParts(parent, name)
	local list = {}
	if parent then for _, child in ipairs(parent:GetChildren()) do if child:IsA("BasePart") and baseName(child.Name, name) then table.insert(list, child) end end end
	return list
end
local function allParts(value)
	if not value then return {} end
	if value:IsA("BasePart") then return { value } end
	local list = {}; for _, child in ipairs(value:GetDescendants()) do if child:IsA("BasePart") then table.insert(list, child) end end; return list
end
local function capture(parts)
	local result = {}
	for _, value in ipairs(parts) do result[value] = { frame = value.CFrame, size = value.Size } end
	return result
end
local function restore(saved)
	for value, baseline in pairs(saved) do if value.Parent then value.CFrame, value.Size = baseline.frame, baseline.size end end
end

function BedroomFeedback.new(root, mvp)
	local runtime = mvp:FindFirstChild("RuntimePresentation") or folder(mvp, "RuntimePresentation")
	assert(not runtime:FindFirstChild("BedroomFeedback"), "BedroomFeedback is already running")
	local owned = folder(runtime, "BedroomFeedback")
	owned:SetAttribute("VerificationTicket", "PCW-19")
	local home = root:FindFirstChild("Home")
	local bedroom = home and home:FindFirstChild("Bedroom")
	local self = setmetatable({ root = owned, bed = bedroom and bedroom:FindFirstChild("SageBed"),
		bookcase = bedroom and bedroom:FindFirstChild("FilledBookcase"), tasks = {}, baseline = {}, wrinkles = {},
		shelfObjects = {}, shelfFrames = {}, trayFrames = {}, legacy = {}, shelfReady = false,
	}, BedroomFeedback)
	self.targets = folder(owned, "Targets")
	self.bedOverlays = folder(owned, "BedDetails")
	self.shelfRoot = folder(owned, "Shelf")
	self:_bindBed()
	self:_buildShelf()
	return self
end

function BedroomFeedback:_bindBed()
	if not self.bed then warn("PCW-19 detailed SageBed missing; bed presentation unavailable"); return end
	local duvet = self.bed:FindFirstChild("SageDuvet")
	if not duvet or not duvet:IsA("BasePart") then warn("PCW-19 SageDuvet missing"); return end
	self.duvet = duvet
	local drapes, pillows, hems = namedParts(self.bed, "DuvetSideDrape"), namedParts(self.bed, "CreamSleepingPillow"), namedParts(self.bed, "PillowHem")
	local function localLeft(a, b) return duvet.CFrame:PointToObjectSpace(a.Position).X < duvet.CFrame:PointToObjectSpace(b.Position).X end
	table.sort(drapes, localLeft); table.sort(pillows, localLeft); table.sort(hems, localLeft)
	self.tasks.blanket_left = drapes[1] and { drapes[1] } or {}
	self.tasks.blanket_right = drapes[2] and { drapes[2] } or {}
	self.tasks.pillow_left = pillows[1] and { pillows[1] } or {}
	self.tasks.pillow_right = pillows[2] and { pillows[2] } or {}
	if hems[1] then table.insert(self.tasks.pillow_left, hems[1]) end
	if hems[2] then table.insert(self.tasks.pillow_right, hems[2]) end
	-- Include the quilt's authored decoration so it moves as a coherent layer.
	self.tasks.blanket_foot = {}
	for _, child in ipairs(self.bed:GetChildren()) do
		for _, name in ipairs({ "FoldedCreamQuilt", "SoftQuiltFold", "QuiltPiping", "FloralThrow", "PrintedStem", "PrintedHydrangea", "PrintedLeaf" }) do
			if child:IsA("BasePart") and baseName(child.Name, name) then table.insert(self.tasks.blanket_foot, child); break end
		end
	end
	local plushies = self.bed:FindFirstChild("BedPlushies")
	self.tasks.plush_dog = allParts(plushies and plushies:FindFirstChild("WeightedDog"))
	self.tasks.plush_dinosaur = allParts(plushies and plushies:FindFirstChild("WeightedDinosaur"))
	for step, parts in pairs(self.tasks) do
		if #parts == 0 then warn("PCW-19 missing bed task geometry", step) end
		local source = parts[1]
		local position = source and source.Position or duvet.Position
		if step == "blanket_left" or step == "blanket_right" then
			local side = step == "blanket_left" and -1 or 1
			position = (duvet.CFrame * CFrame.new(side * (duvet.Size.X / 2 - 1), .5, 0)).Position
			local wrinkle = part(self.bedOverlays, "Wrinkle_" .. step, Vector3.new(1.6, .3, duvet.Size.Z * .64), CFrame.new(position) * duvet.CFrame.Rotation * CFrame.Angles(0, 0, math.rad(side * 13)), "sage")
			wrinkle.Material, wrinkle.Transparency = Enum.Material.Fabric, 1
			self.wrinkles[step] = wrinkle
		end
		local target = part(self.targets, "BedTarget_" .. step, Vector3.new(2.6, .14, 2.1), CFrame.new(position + Vector3.new(0, .5, 0)) * duvet.CFrame.Rotation, "golden")
		target.Transparency = 1; target:SetAttribute("StepId", step)
	end
	-- The old MVP duplicate is owned station geometry, not the detailed room.
	-- Hide it at runtime only, preserving all source instances for edit mode.
	local mvp = self.root.Parent.Parent
	local stations = mvp:FindFirstChild("Stations")
	local legacy = stations and stations:FindFirstChild("Q01Station")
	if legacy then for _, value in ipairs(legacy:GetDescendants()) do
		if value:IsA("BasePart") then
			self.legacy[value] = { transparency = value.Transparency, collide = value.CanCollide, touch = value.CanTouch, query = value.CanQuery }
			value.Transparency, value.CanCollide, value.CanTouch, value.CanQuery = 1, false, false, false
		end
	end end
end

function BedroomFeedback:BeginRound(roundId)
	if self.roundId == roundId then return end
	-- Replay restores exactly the prior round's task geometry, then takes a fresh
	-- baseline. Other room models, display slots and colliders are untouched.
	for _, saved in pairs(self.baseline) do restore(saved) end
	self.baseline, self.roundId = {}, roundId
	for step, parts in pairs(self.tasks) do self.baseline[step] = capture(parts) end
	if not self.duvet then return end
	local rotation = self.duvet.CFrame.Rotation
	local adjustments = {
		blanket_left = CFrame.new(0, .25, .22) * CFrame.Angles(0, 0, math.rad(-7)),
		blanket_right = CFrame.new(0, .25, -.22) * CFrame.Angles(0, 0, math.rad(7)),
		blanket_foot = CFrame.new(0, .18, -.7) * CFrame.Angles(0, math.rad(6), 0),
		pillow_left = CFrame.new(.45, .1, 1.1) * CFrame.Angles(0, math.rad(-12), 0),
		pillow_right = CFrame.new(-.45, .1, .8) * CFrame.Angles(0, math.rad(11), 0),
		plush_dog = CFrame.new(-1.2, 0, 1.2) * CFrame.Angles(0, math.rad(-18), 0),
		plush_dinosaur = CFrame.new(-.7, 0, 1.4) * CFrame.Angles(0, math.rad(16), 0),
	}
	for step, saved in pairs(self.baseline) do
		local parts = self.tasks[step]
		local reference = parts[1]
		if reference then
			local pivot = CFrame.new(reference.Position) * rotation
			local delta = pivot * adjustments[step] * pivot:Inverse()
			for value, baseline in pairs(saved) do if value.Parent then value.CFrame = delta * baseline.frame end end
		end
	end
	for _, wrinkle in pairs(self.wrinkles) do wrinkle.Transparency = 0 end
	self.root:SetAttribute("BedRoundId", roundId); self.root:SetAttribute("BedStyle", nil)
end
function BedroomFeedback:ApplyStep(step)
	if self.baseline[step] then restore(self.baseline[step]) end
	if self.wrinkles[step] then self.wrinkles[step].Transparency = 1 end
end
function BedroomFeedback:Finish(choice)
	-- Styles are small poses of the same approved items, never replacement art.
	if choice == "soft_snug" then
		for _, step in ipairs({ "plush_dog", "plush_dinosaur" }) do
			for value, baseline in pairs(self.baseline[step] or {}) do
				if value.Parent then value.CFrame = baseline.frame + self.duvet.CFrame.LookVector * .45 end
			end
		end
	end
	self.root:SetAttribute("BedStyle", choice)
end

function BedroomFeedback:_book(name, token)
	local model = Instance.new("Model"); model.Name = name; model.Parent = self.shelfRoot
	part(model, "Pages", Vector3.new(.55, 1.05, .65), CFrame.new(0, .565, 0), "cream")
	for _, side in ipairs({ -1, 1 }) do part(model, "Cover", Vector3.new(.05, 1.16, .78), CFrame.new(side * .3, .565, 0), token) end
	part(model, "Spine", Vector3.new(.65, 1.16, .06), CFrame.new(0, .565, .36), token)
	model.WorldPivot = CFrame.identity
	return model
end
function BedroomFeedback:_buildShelf()
	if not self.bookcase then warn("PCW-19 FilledBookcase missing; optional shelf unavailable"); return end
	local shelves = namedParts(self.bookcase, "Shelf")
	table.sort(shelves, function(a, b) return a.Position.Y < b.Position.Y end)
	local top = shelves[#shelves]
	local figure = self.bookcase:FindFirstChild("ShelfFigure")
	if not top or not figure or not figure:IsA("Model") then warn("PCW-19 shelf surface or approved figure missing"); return end
	local frame = top.CFrame * CFrame.new(0, top.Size.Y / 2 + .025, 0)
	local anchor = part(self.shelfRoot, "Q01Shelf", Vector3.new(1, 1, 1), frame * CFrame.new(0, -6, 2), "forest")
	anchor.Transparency = 1; self.shelfAnchor = anchor
	local prompt = Instance.new("ProximityPrompt")
	prompt.Name, prompt.ActionText, prompt.ObjectText = "MVPProximityPrompt", "Tidy the shelf", "Optional bedroom tidying"
	prompt.KeyboardKeyCode, prompt.HoldDuration, prompt.MaxActivationDistance, prompt.RequiresLineOfSight = Enum.KeyCode.E, 0, 12, false
	prompt:SetAttribute("ActivityId", "Q01"); prompt.Parent = anchor
	-- Top-shelf front is free in the supplied scene. The original plant at +2.95
	-- and all lower miniature/collectible displays stay where they are.
	for index, id in ipairs({ "left", "middle", "right" }) do
		local x = ({ -2.8, -.65, 1.35 })[index]
		self.shelfFrames[id] = frame * CFrame.new(x, 0, .65)
		local target = part(self.targets, "ShelfTarget_" .. id, Vector3.new(1.5, .06, 1.05), self.shelfFrames[id], "golden")
		target.Transparency = .65; target:SetAttribute("ShelfSlotId", id)
	end
	local tray = part(self.shelfRoot, "TidyTray", Vector3.new(5.5, .08, .9), frame * CFrame.new(-.65, .04, -.8), "wood")
	tray:SetAttribute("OptionalRoomTidying", true)
	self.shelfObjects.book_sage, self.shelfObjects.book_cream = self:_book("SageBook", "sage"), self:_book("CreamBook", "cream")
	local clone = figure:Clone(); clone.Name = "SmallShelfFigure"
	for _, child in ipairs(clone:GetDescendants()) do
		if child:IsA("BasePart") then child.Anchored, child.CanCollide, child.CanTouch, child.CanQuery = true, false, false, false; child:SetAttribute("VerificationTicket", "PCW-19")
		elseif not child:IsA("SpecialMesh") and not child:IsA("Model") and not child:IsA("Folder") then child:Destroy() end
	end
	local bounds, size = clone:GetBoundingBox()
	clone.WorldPivot = CFrame.new(bounds.Position - Vector3.new(0, size.Y / 2, 0)) * top.CFrame.Rotation
	clone.Parent = self.shelfRoot; self.shelfObjects.small_figure = clone
	for index, id in ipairs({ "book_sage", "book_cream", "small_figure" }) do self.trayFrames[id] = frame * CFrame.new(-2.45 + (index - 1) * 1.6, .09, -.8) end
	self.shelfReady = true
	self:RenderShelf({})
end
function BedroomFeedback:RenderShelf(slots)
	if not self.shelfReady then return end
	for itemId, model in pairs(self.shelfObjects) do
		local destination, slotId = self.trayFrames[itemId], nil
		for id, occupant in pairs(slots) do if occupant == itemId then destination, slotId = self.shelfFrames[id], id; break end end
		model:PivotTo(destination)
		model:SetAttribute("ShelfSlotId", slotId)
	end
end
function BedroomFeedback:Destroy()
	for _, saved in pairs(self.baseline) do restore(saved) end
	for value, saved in pairs(self.legacy) do
		if value.Parent then value.Transparency, value.CanCollide, value.CanTouch, value.CanQuery = saved.transparency, saved.collide, saved.touch, saved.query end
	end
	self.root:Destroy()
end
return BedroomFeedback
]=],
["roblox/mvp/server/CakeService.luau"] = [=[-- Session-only authority. No camera, animation or audio acknowledgement gates progress.
local CakeService = {}
CakeService.__index = CakeService
local DURATION = 12
local NORMAL = { Arm = true, Delay = true, Cut = true, TakeSlice = true, Eat = true, Bite = true }
local ALIASES = { Invite = "Arm", CancelInvite = "Delay" }
local RECOVERY = { RecoverStart = true, RecoverCut = true }

function CakeService.new(session, options)
    options = options or {}
    return setmetatable({
        session = session, clock = options.clock or function() return workspace:GetServerTimeNow() end,
        runtime = {}, phase = "LOCKED", generation = 0, revision = 0, delayed = false,
        participants = {}, receipts = {}, lastRequest = {},
    }, CakeService)
end

function CakeService:SetRuntime(runtime)
    self.runtime = runtime or {}
end

function CakeService:_present(actor)
    return self.session:IsPresent(actor) and self.runtime.isWorld and self.runtime.isWorld(actor) == true
end

function CakeService:_host(actor)
    return self:_present(actor) and (actor == self.session.phuongUserId or actor == self.session.hostUserId)
end

function CakeService:_begin(actor, recovered)
    if self.startedAt or not self.session:AllPetalsComplete() then return false end
    self.generation += 1
    self.startedAt = self.clock()
    self.endsAt = self.startedAt + DURATION
    self.startedBy = actor
    self.recoveredStart = recovered == true
    self.phase = "CELEBRATING"
    self.delayed = false
    self.revision += 1
    return true
end

function CakeService:Tick()
    local before = self.revision
    if self.phase == "LOCKED" and self.session:AllPetalsComplete() then
        self.unlockedAt = self.clock()
        self.phase = self.delayed and "READY" or "GATHERING"
        self.revision += 1
    end
    if self.phase == "GATHERING" and not self.startedAt and self.runtime.occupant then
        -- Also evaluates an already-seated Phuong on unlock and after a delay.
        local actor = self.runtime.occupant()
        if actor == self.session.phuongUserId and self:_present(actor) then self:_begin(actor, false) end
    end
    if self.phase == "CELEBRATING" and self.clock() >= self.endsAt then
        self.phase = "CAKE_READY"
        self.revision += 1
    end
    return before ~= self.revision
end

local function reject(code, message)
    return { ok = false, code = code, message = message }
end

function CakeService:_apply(request, recovery)
    if type(request) ~= "table" or request.sessionId ~= self.session.sessionId
        or type(request.actionId) ~= "string" or #request.actionId == 0 or #request.actionId > 128
        or type(request.actorUserId) ~= "number" or type(request.action) ~= "string"
        or type(request.generation) ~= "number" then
        return reject("BadCakeRequest", "Reopen the birthday table for its current choices.")
    end
    local actor, original = request.actorUserId, request.action
    local operation = ALIASES[original] or original
    if not self:_present(actor) then return reject("NotPresent", "Enter the birthday world first.") end
    if recovery then
        if not RECOVERY[operation] or not self:_host(actor) then return reject("CakePermission", "Only Phuong or Andrew can recover the celebration.") end
    elseif not NORMAL[operation] then
        return reject("UnsupportedCakeAction", "That birthday action is unavailable.")
    end
    local prior = self.receipts[request.actionId]
    if prior then
        if prior.actorUserId ~= actor or prior.action ~= original or prior.generation ~= request.generation or prior.recovery ~= recovery then
            return reject("CakeIdentityMismatch", "That request was already used for a different choice.")
        end
        return { ok = true, code = "DUPLICATE_ACTION", message = prior.message, receipt = prior }
    end
    if self.session.receipts[request.actionId] or self.session.acceptedSteps[request.actionId] then
        return reject("CakeIdentityMismatch", "That request was already used. Reopen the table.")
    end
    self:Tick()
    if request.generation ~= self.generation then return reject("CakeChanged", "The celebration has moved on. Please choose again.") end
    local now = self.clock()
    if self.lastRequest[actor] and now - self.lastRequest[actor] < .3 then return reject("CakeTooQuick", "Let your last choice settle for a moment.") end
    self.lastRequest[actor] = now
    local hostAction = operation == "Arm" or operation == "Delay"
    if hostAction and not self:_host(actor) then return reject("CakePermission", "Phuong and Andrew can change the gathering time.") end
    if not recovery and not hostAction and not (self.runtime.isAtPatio and self.runtime.isAtPatio(actor)) then
        return reject("TooFar", "Walk to the birthday table first; your cake stays saved.")
    end
    l]==]
return #_G.__PCW25ContractText