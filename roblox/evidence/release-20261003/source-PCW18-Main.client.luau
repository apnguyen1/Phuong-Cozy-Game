-- PCW-18: presentation only. The server owns every quest, purchase and permission.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local root = ReplicatedStorage:WaitForChild("PhuongMVP")
local action = root:WaitForChild("Action")
local client = root:WaitForChild("client")
local UI = require(client:WaitForChild("UI"))
local Guidance = require(root:WaitForChild("shared"):WaitForChild("Guidance"))
local Navigator = require(client:WaitForChild("Navigator"))
local Extensions = require(client:WaitForChild("Extensions"))
local P = UI.Palette

local gui = Instance.new("ScreenGui")
gui.Name = "PhuongMVPHud"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.DisplayOrder = 12
gui.ScreenInsets = Enum.ScreenInsets.CoreUISafeInsets
gui.Parent = player:WaitForChild("PlayerGui")

local hud = Instance.new("Frame")
hud.Name = "ExploreHud"
hud.BackgroundColor3 = P.cream
hud.BorderSizePixel = 0
hud.AnchorPoint = Vector2.new(.5, 0)
hud.Position = UDim2.new(.5, 0, 0, 8)
hud.Parent = gui
UI.Corner(hud)
local goal = UI.Label(hud, "BirthdayGoal", "Together for Phuong's Labubu + birthday cake", 16, P.forest)
goal.Position = UDim2.fromOffset(12, 9)
goal.Size = UDim2.new(1, -24, 0, 22)
goal.AutomaticSize = Enum.AutomaticSize.None
local fund = UI.Label(hud, "FundBalance", "Shared fund · 0", 14)
fund.Position = UDim2.fromOffset(12, 36)
fund.Size = UDim2.new(.56, -12, 0, 20)
fund.AutomaticSize = Enum.AutomaticSize.None
local flower = UI.Label(hud, "FlowerProgress", "0 / 6 petals", 14, P.forest)
flower.Position = UDim2.new(.56, 0, 0, 36)
flower.Size = UDim2.new(.44, -12, 0, 20)
flower.AutomaticSize = Enum.AutomaticSize.None
flower.TextXAlignment = Enum.TextXAlignment.Right
local nextObjective = UI.Label(hud, "NextObjective", "Enter the birthday world to begin", 15)
nextObjective.Position = UDim2.fromOffset(12, 61)
nextObjective.Size = UDim2.new(1, -24, 0, 23)
nextObjective.AutomaticSize = Enum.AutomaticSize.None
local direction = UI.Label(hud, "Direction", "", 13, P.forest)
direction.Position = UDim2.fromOffset(12, 87)
direction.Size = UDim2.new(1, -24, 0, 20)
direction.AutomaticSize = Enum.AutomaticSize.None
local journalButton = UI.Button(hud, "JournalButton", "Journal", function() end, true)
journalButton.Position = UDim2.fromOffset(12, 111)
journalButton.Size = UDim2.new(.5, -16, 0, 48)
local trackButton = UI.Button(hud, "TrackButton", "Track", function() end)
trackButton.Position = UDim2.new(.5, 4, 0, 111)
trackButton.Size = UDim2.new(.5, -16, 0, 48)

local panel = Instance.new("Frame")
panel.Name = "ActivityPanel"
panel.AnchorPoint = Vector2.new(.5, 0)
panel.Position = UDim2.new(.5, 0, 0, 8)
panel.BackgroundColor3 = P.cream
panel.BorderSizePixel = 0
panel.Visible = false
panel.Parent = gui
UI.Corner(panel, 16)
local title = UI.Label(panel, "Title", "", 20, P.forest)
title.Font = Enum.Font.GothamBold
title.Position = UDim2.fromOffset(14, 12)
title.Size = UDim2.new(1, -28, 0, 48)
title.AutomaticSize = Enum.AutomaticSize.None
local scroll = Instance.new("ScrollingFrame")
scroll.Name = "ActivityContent"
scroll.Position = UDim2.fromOffset(12, 64)
scroll.Size = UDim2.new(1, -24, 1, -134)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 5
scroll.ScrollBarImageColor3 = P.forest
scroll.CanvasSize = UDim2.new()
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
scroll.ScrollingDirection = Enum.ScrollingDirection.Y
scroll.Parent = panel
UI.List(scroll, 10)
local contentPadding = UI.Padding(scroll, 2)
contentPadding.PaddingRight = UDim.new(0, 9)
local back = UI.Button(panel, "Back", "Back", function() end, true)
back.Position = UDim2.new(0, 12, 1, -60)
back.Size = UDim2.new(.5, -18, 0, 48)
local close = UI.Button(panel, "Close", "Close", function() end)
close.Position = UDim2.new(.5, 6, 1, -60)
close.Size = UDim2.new(.5, -18, 0, 48)

local toast = UI.Label(gui, "StatusToast", "", 16, P.cream)
toast.AnchorPoint = Vector2.new(.5, 0)
toast.BackgroundColor3 = P.forest
toast.BackgroundTransparency = 0
toast.AutomaticSize = Enum.AutomaticSize.Y
toast.TextXAlignment = Enum.TextXAlignment.Center
toast.ZIndex = 20
toast.Visible = false
UI.Padding(toast, 12)
UI.Corner(toast)

local navigator = Navigator.new(player, gui)
local sessionId, currentView, pending, selectedAction, confirmation
local lastSnapshot, viewCache = {}, {}
local cakeState = { finaleState = "LOCKED" }
local panelMode, epoch, sequence = "closed", 0, 0
local explicitTrack, recommended, activeGroup, activeExtension
local trackedWasComplete = false
local toastSerial, heartbeatElapsed = 0, 0
local renderActivity, renderJournal, renderCake, closeActivity, requestView, refreshHud, extensionContext

local function inWorld() return player:GetAttribute("BirthdayLocation") == "World" end
local function freshId()
	sequence += 1
	return string.format("client-%d-%d-%d", player.UserId, math.floor(os.clock() * 1000), sequence)
end

local function showToast(message, isError)
	toastSerial += 1
	local token = toastSerial
	toast.Text = Guidance.Text(message, "Please try that step again.")
	toast.BackgroundColor3 = isError and P.brick or P.forest
	toast.TextColor3 = isError and P.ink or P.cream
	toast.Visible = inWorld()
	task.delay(4.5, function() if toastSerial == token then toast.Visible = false end end)
end

local function layout()
	local size = gui.AbsoluteSize
	local width, height = math.max(280, size.X), math.max(240, size.Y)
	local compact = height < 500
	hud.Size = UDim2.fromOffset(math.min(432, width - 24), 171)
	goal.Text = width < 460 and "Phuong's Labubu → birthday cake" or "Together for Phuong's Labubu + birthday cake"
	goal.TextSize = width < 460 and 14 or 16
	-- Leave the lower control band uncovered. No full-screen input backdrop,
	-- camera replacement, player warp or movement disable is installed here.
	local panelWidth = math.min(580, width - 24)
	if width > height and compact then panelWidth = math.min(510, width - 204) end
	panel.Size = UDim2.fromOffset(math.max(280, panelWidth), math.max(192, math.min(740, height - (compact and 92 or 120))))
	toast.Size = UDim2.fromOffset(math.min(460, width - 36), 0)
	toast.Position = UDim2.new(.5, 0, 0, panel.Visible and panel.Size.Y.Offset + 14 or 181)
end
gui:GetPropertyChangedSignal("AbsoluteSize"):Connect(layout)

local function setMode(mode)
	panelMode = mode
	panel.Visible = mode ~= "closed" and inWorld()
	hud.Visible = mode == "closed" and inWorld()
	layout()
end

local function clearContent() UI.Clear(scroll) end
local function addLabel(name, value, order, size, color)
	local label = UI.Label(scroll, name, value, size or 16, color)
	label.LayoutOrder = order
	return label
end

local function releaseCurrent()
	local view = currentView
	local id = view and view.activityId or (pending and pending.activityId)
	if id and sessionId then
		action:FireServer({ kind = "CloseActivity", sessionId = sessionId, activityId = id, roundId = view and view.roundId, actionId = freshId() })
	end
end

closeActivity = function()
	releaseCurrent()
	epoch += 1
	pending, currentView, selectedAction, confirmation, activeGroup, activeExtension = nil, nil, nil, nil, nil, nil
	setMode("closed")
	navigator:Clear()
	refreshHud()
end

local function send(request)
	if pending then showToast("Saving your last choice…"); return false end
	if not sessionId and request.kind ~= "RequestSnapshot" then showToast("Connecting to the birthday session…"); return false end
	request.actionId = freshId()
	request.sessionId = sessionId
	-- Actor identity is always stamped by the authenticated server.
	request.actorUserId, request.player = nil, nil
	pending = { id = request.actionId, epoch = epoch, kind = request.kind, activityId = request.activityId, payloadAction = request.payload and request.payload.action }
	local expected = pending
	action:FireServer(request)
	task.delay(8, function()
		if pending ~= expected then return end
		pending = nil
		showToast("The response is taking longer than expected. Reopen this activity before trying again.", true)
		-- Never automatically retry a purchase with a new action ID.
		closeActivity()
		action:FireServer({ kind = "RequestSnapshot", actionId = freshId() })
	end)
	return true
end

local function track(id, anchorName)
	if not Guidance.Activities[id] then return end
	explicitTrack = id
	trackedWasComplete = Guidance.Complete(lastSnapshot, id)
	if anchorName then
		viewCache[id] = viewCache[id] or { activityId = id }
		viewCache[id].guide = viewCache[id].guide or {}
		viewCache[id].guide.nextAnchor = anchorName
	end
	navigator:SetTarget(id, viewCache[id])
	refreshHud()
end

refreshHud = function()
	local count = Guidance.PetalCount(lastSnapshot.petals)
	fund.Text = "Shared fund · " .. tostring(tonumber(lastSnapshot.fundBalance or lastSnapshot.fund) or 0)
	flower.Text = string.format("✿ %d / 6 petals", count)
	if explicitTrack and explicitTrack ~= "Cake" and not trackedWasComplete and Guidance.Complete(lastSnapshot, explicitTrack) then explicitTrack = nil end
	recommended = Guidance.Recommend(lastSnapshot, navigator:Distances(viewCache), viewCache)
	local id = explicitTrack or recommended
	local info = Guidance.Activities[id]
	if info then
		nextObjective.Text = "Next · " .. info.short
		trackButton.Text = "Track destination"
		if inWorld() then navigator:SetTarget(id, viewCache[id]) else navigator:Clear() end
	end
	direction.Text = navigator:Update()
	hud.Visible = inWorld() and panelMode == "closed"
end

local function actionLabel(descriptor)
	local label = Guidance.Text(descriptor.label, "Choose this option")
	-- Compatibility copy; subsequent ticket descriptors supply friendly labels.
	label = string.gsub(label, "_", " ")
	label = string.gsub(label, "settingA", "Plate setting")
	label = string.gsub(label, "settingB", "Cup setting")
	return label
end

local function unavailableReason(descriptor)
	return Guidance.Text(descriptor.reason, "Follow the next step first, or let Phuong make this choice.")
end

local function groupsFor(view)
	local actions = view.availableActions or {}
	local groups, assigned, byId = {}, {}, {}
	for _, descriptor in ipairs(actions) do if descriptor.id then byId[descriptor.id] = descriptor end end
	local supplied = view.guide and view.guide.groups
	if type(supplied) == "table" then
		for index, group in ipairs(supplied) do
			local entry = { id = group.id or tostring(index), title = Guidance.Text(group.title, "Choose an option"), detail = Guidance.Text(group.detail), kind = group.kind or "choices", actions = {} }
			for _, id in ipairs(group.actionIds or {}) do
				if byId[id] then table.insert(entry.actions, byId[id]); assigned[id] = true end
			end
			for _, descriptor in ipairs(actions) do
				if descriptor.groupId == group.id and not assigned[descriptor.id] then table.insert(entry.actions, descriptor); assigned[descriptor.id] = true end
			end
			if #entry.actions > 0 then table.insert(groups, entry) end
		end
	end
	local defaults = {}
	local function fallback(descriptor)
		local step, payload = descriptor.stepId, descriptor.payload or {}
		if view.activityId == "Q04" then
			local names = { highlight = "1 · Highlight a moment", reaction = "2 · Choose your reaction", bookmark = "3 · Pick a bookmark", reading = "4 · Save your reading" }
			return step, names[step] or "Reading choices"
		elseif view.activityId == "Q06" then
			local names = { base = "1 · Choose a bowl base", toppings = "2 · Add a topping", protein = "3 · Add a protein", sauce = "4 · Sauce at Aladdins", settingA = "5 · Set a plate", settingB = "6 · Set a cup" }
			return payload.slotId or "meal", names[payload.slotId] or "Build your meal"
		elseif view.activityId == "Q05" then
			if step == "select-wanted" then return "wish", "Choose Phuong's wanted Labubu" end
			if step == "roll" then return "box", "Open a surprise box" end
			return "collection", "Look at the collection"
		elseif payload.action == "rotate" or payload.action == "place" or payload.action == "cancel" then
			return "placement", "Place your selected piece"
		elseif payload.action == "finish" or payload.action == "finalize" then return "finish", "Phuong's finishing touch" end
		return "choices", "Choose how to help"
	end
	for _, descriptor in ipairs(actions) do
		if not assigned[descriptor.id] then
			local key, label = fallback(descriptor)
			key = key or "choices"
			if not defaults[key] then
				defaults[key] = { id = key, title = label, kind = "choices", actions = {} }
				table.insert(groups, defaults[key])
			end
			table.insert(defaults[key].actions, descriptor)
		end
	end
	return groups
end

local function runDescriptor(view, descriptor, confirmed)
	if descriptor.enabled == false then showToast(unavailableReason(descriptor)); return end
	if pending then showToast("Saving your last choice…"); return end
	local confirm = Guidance.Confirmation(descriptor)
	if confirm and not confirmed then
		confirmation = { descriptor = descriptor, copy = confirm }
		renderActivity(view)
		return
	end
	confirmation = nil
	if send({ kind = "ActivityAction", activityId = view.activityId, roundId = view.roundId or "", stepId = descriptor.stepId or "", payload = descriptor.payload or {} }) then renderActivity(view, true) end
end

local function previewCards(preview, order)
	if type(preview) ~= "table" then return end
	local card = UI.Card(scroll, "ActivityPreview", "sage")
	card.LayoutOrder = order
	UI.Label(card, "PreviewTitle", Guidance.Text(preview.title, "Your shared creation"), 17, P.forest).LayoutOrder = 1
	local summary = Guidance.Text(preview.detail or preview.text)
	if summary ~= "" then UI.Label(card, "PreviewDetail", summary, 15).LayoutOrder = 2 end
	for index, item in ipairs(preview.items or {}) do
		if type(item) == "table" then
			local state = item.complete and "✓ " or item.selected and "● " or "○ "
			UI.Label(card, "PreviewItem" .. index, state .. Guidance.Text(item.label or item.title, "A shared choice") .. (Guidance.Text(item.detail) ~= "" and " · " .. item.detail or ""), 15).LayoutOrder = index + 2
		end
	end
end

renderActivity = function(view, preserveScroll)
	if type(view) ~= "table" or not Guidance.Activities[view.activityId] then return end
	local oldScroll = scroll.CanvasPosition
	currentView = view
	viewCache[view.activityId] = view
	if confirmation then
		local fresh
		for _, descriptor in ipairs(view.availableActions or {}) do
			if descriptor.id == confirmation.descriptor.id and descriptor.enabled ~= false then fresh = descriptor; break end
		end
		if fresh then confirmation.descriptor = fresh
		else confirmation = nil; showToast("That choice changed. Please choose an available option.", true) end
	end
	setMode("activity")
	clearContent()
	local info = Guidance.Activities[view.activityId]
	local guide = type(view.guide) == "table" and view.guide or {}
	title.Text = Guidance.Text(view.title, info.title)
	local completed = view.canReplay == true or view.state == "COMPLETED" or view.state == "FINISHED" or view.state == "ROUND_COMPLETE" or view.state == "FULFILLED"
	local progress = view.progress or {}
	local done, total = tonumber(progress.done) or 0, tonumber(progress.total) or 0
	addLabel("Headline", Guidance.Text(guide.headline, completed and "Petal complete — thank you for helping!" or info.short), 1, 18, P.forest)
	addLabel("Instructions", Guidance.Text(guide.detail, Guidance.Text(view.instructions, info.hint)), 2)
	addLabel("Progress", Guidance.Text(guide.stepLabel, total > 0 and string.format("%d of %d steps complete", done, total) or "Help at your own pace"), 3, 14, P.forest)
	local meter = Instance.new("Frame")
	meter.Name = "ProgressTrack"
	meter.Size = UDim2.new(1, 0, 0, 7)
	meter.BackgroundColor3 = P.sage
	meter.BorderSizePixel = 0
	meter.LayoutOrder = 4
	meter.Parent = scroll
	UI.Corner(meter, 4)
	local fill = Instance.new("Frame")
	fill.Name = "ProgressFill"
	fill.Size = UDim2.fromScale(total > 0 and math.clamp(done / total, 0, 1) or 0, 1)
	fill.BackgroundColor3 = P.forest
	fill.BorderSizePixel = 0
	fill.Parent = meter
	UI.Corner(fill, 4)
	if guide.nextAnchor then
		UI.Button(scroll, "TrackNextStep", "Show me where to go", function() track(view.activityId, guide.nextAnchor); closeActivity() end, true).LayoutOrder = 5
	end
	if confirmation then
		local copy, descriptor = confirmation.copy, confirmation.descriptor
		local card = UI.Card(scroll, "ConfirmChoice", "golden")
		card.LayoutOrder = 6
		UI.Label(card, "ConfirmTitle", Guidance.Text(copy.title, "Confirm this choice?"), 18).LayoutOrder = 1
		UI.Label(card, "ConfirmDetail", Guidance.Text(copy.detail, "Save this choice for the shared birthday session."), 16).LayoutOrder = 2
		UI.Button(card, "Confirm", Guidance.Text(copy.label, "Confirm"), function() runDescriptor(view, descriptor, true) end).LayoutOrder = 3
		UI.Button(card, "KeepChoosing", "Keep choosing", function() confirmation = nil; renderActivity(view) end, true).LayoutOrder = 4
		scroll.CanvasPosition = Vector2.zero
		return
	end
	local groups = groupsFor(view)
	local selected
	for _, descriptor in ipairs(view.availableActions or {}) do
		if descriptor.id == selectedAction and descriptor.enabled ~= false then selected = descriptor; break end
	end
	if not selected then
		selectedAction = nil
		for _, descriptor in ipairs(view.availableActions or {}) do
			if descriptor.primary and descriptor.enabled ~= false then selected = descriptor; break end
		end
	end
	if not selected then
		local only, count = nil, 0
		for _, descriptor in ipairs(view.availableActions or {}) do if descriptor.enabled ~= false then only = descriptor; count += 1 end end
		if count == 1 then selected = only end
	end
	local primary = UI.Button(scroll, "MainAction", pending and "Saving your choice…" or selected and actionLabel(selected) or "Choose a card below", function() if selected then runDescriptor(view, selected) end end)
	primary.LayoutOrder = 7
	UI.SetEnabled(primary, selected ~= nil and pending == nil)
	if selected and Guidance.Text(selected.description) ~= "" then addLabel("SelectedDetail", selected.description, 8, 14) end
	previewCards(guide.preview, 9)
	local extension = Extensions.activities[view.activityId]
	if extension then
		local preview = Instance.new("Frame")
		preview.Name = "WorldPreview"
		preview.BackgroundTransparency = 1
		preview.Size = UDim2.new(1, 0, 0, 0)
		preview.AutomaticSize = Enum.AutomaticSize.Y
		preview.LayoutOrder = 10
		preview.Parent = scroll
		local ok, err = pcall(extension, preview, view, extensionContext())
		if not ok then preview:Destroy(); warn("Activity preview failed", view.activityId, err) end
	end
	-- Preserve the server's complete reading passage; no compulsory typing.
	if type(view.reading) == "table" and type(view.reading.text) == "string" then
		local reading = UI.Card(scroll, "ReadingPassage", "sage")
		reading.LayoutOrder = 11
		UI.Label(reading, "ReadingTitle", Guidance.Text(view.reading.title, "A quiet page"), 18, P.forest).LayoutOrder = 1
		UI.Label(reading, "ReadingText", view.reading.text, 17).LayoutOrder = 2
	end
	local groupExists = activeGroup == "collapsed"
	for _, group in ipairs(groups) do if group.id == activeGroup then groupExists = true end end
	if not groupExists then
		activeGroup = nil
		for _, group in ipairs(groups) do if group.id == "placement" then activeGroup = group.id; break end end
		if not activeGroup then
			for _, group in ipairs(groups) do
				for _, descriptor in ipairs(group.actions) do if descriptor.enabled ~= false then activeGroup = group.id; break end end
				if activeGroup then break end
			end
		end
		activeGroup = activeGroup or (groups[1] and groups[1].id)
	end
	for groupIndex, group in ipairs(groups) do
		local frame = UI.Card(scroll, "ChoiceGroup" .. groupIndex, "cream")
		frame.LayoutOrder = 20 + groupIndex
		local groupTitle = (activeGroup == group.id and "▾ " or "▸ ") .. group.title
		UI.Button(frame, "GroupHeading", groupTitle, function() activeGroup = activeGroup == group.id and "collapsed" or group.id; renderActivity(view, true) end, true).LayoutOrder = 1
		if activeGroup == group.id then
			if group.detail and group.detail ~= "" then UI.Label(frame, "GroupDetail", group.detail, 15).LayoutOrder = 2 end
			for index, descriptor in ipairs(group.actions) do
				local choice = UI.Card(frame, "Choice" .. index, "sage")
				choice.LayoutOrder = index + 3
				local isSelected = descriptor.selected == true or selectedAction == descriptor.id
				local button = UI.Button(choice, "ChoiceButton", (isSelected and "✓ " or "") .. actionLabel(descriptor), function()
					if pending then showToast("Saving your last choice…"); return end
					if descriptor.enabled == false then showToast(unavailableReason(descriptor)); return end
					selectedAction = descriptor.id
					renderActivity(view)
				end, not isSelected)
				button.LayoutOrder = 1
				UI.SetEnabled(button, descriptor.enabled ~= false and pending == nil, not isSelected)
				if isSelected then
					local outline = Instance.new("UIStroke")
					outline.Color = P.forest
					outline.Thickness = 2
					outline.Parent = choice
				end
				local detail = descriptor.enabled == false and unavailableReason(descriptor) or Guidance.Text(descriptor.description)
				if detail ~= "" then UI.Label(choice, "ChoiceDetail", detail, 14).LayoutOrder = 2 end
			end
		end
	end
	if #(view.availableActions or {}) == 0 then addLabel("WaitingForNext", Guidance.Text(view.busyReason, completed and "Your petal is saved. Close this panel to find another activity." or "A friend may be finishing this step. Refresh to see the latest choices."), 80) end
	UI.Button(scroll, "RefreshActivity", "Refresh available choices", function() requestView(view.activityId, false) end, true).LayoutOrder = 90
	if view.canReplay then
		UI.Button(scroll, "Replay", "Play again together · +10 shared fund", function() confirmation = nil; requestView(view.activityId, true) end, true).LayoutOrder = 91
	end
	addLabel("HelpAndExit", "Close releases any unfinished spot you are holding. Shared progress stays saved for this session.", 99, 13)
	scroll.CanvasPosition = preserveScroll and oldScroll or Vector2.zero
	if not completed then track(view.activityId) else refreshHud() end
end

requestView = function(id, replay)
	if pending then showToast("Please wait for your last choice to save."); return end
	if not sessionId then showToast("Connecting to the birthday session…"); return end
	if currentView then releaseCurrent() end
	epoch += 1
	currentView, selectedAction, confirmation, activeGroup, activeExtension = nil, nil, nil, nil, nil
	setMode("loading")
	clearContent()
	title.Text = Guidance.Activities[id] and Guidance.Activities[id].title or "Birthday activity"
	addLabel("Loading", "Opening the shared activity…", 1)
	send({ kind = "RequestView", activityId = id, replay = replay == true })
end

renderJournal = function(snapshot, preserveScroll)
	local previous = scroll.CanvasPosition
	setMode("journal")
	clearContent()
	title.Text = "Birthday journal"
	addLabel("JournalGoal", "Help Phuong get her wanted Labubu, then gather for cake. All six petals unlock the birthday table.", 1, 17, P.forest)
	addLabel("JournalFund", string.format("Shared fund: %d · %d of 6 petals complete", tonumber(snapshot.fundBalance or snapshot.fund) or 0, Guidance.PetalCount(snapshot.petals)), 2)
	for index, id in ipairs(Guidance.Order) do
		local info, view = Guidance.Activities[id], viewCache[id]
		local completed = Guidance.Complete(snapshot, id)
		local card = UI.Card(scroll, "Journal" .. id, completed and "sage" or "cream")
		card.LayoutOrder = index + 3
		UI.Label(card, "ActivityTitle", (completed and "✓ " or "○ ") .. info.title, 18, P.forest).LayoutOrder = 1
		UI.Label(card, "Destination", info.destination, 14).LayoutOrder = 2
		local hint = view and view.guide and Guidance.Text(view.guide.detail, info.hint) or info.hint
		UI.Label(card, "Objective", completed and "Petal complete. Replay is optional." or hint, 15).LayoutOrder = 3
		if view and type(view.progress) == "table" then
			UI.Label(card, "Progress", string.format("%d / %d steps", tonumber(view.progress.done) or 0, tonumber(view.progress.total) or 0), 14).LayoutOrder = 4
		end
		UI.Label(card, "Reward", info.reward, 13).LayoutOrder = 5
		UI.Button(card, "Track", completed and "Visit again" or "Track this activity", function() closeActivity(); track(id); showToast("Follow the marker to " .. info.destination .. ".") end).LayoutOrder = 6
	end
	local unlocked = Guidance.PetalCount(snapshot.petals) == 6
	local cake = UI.Card(scroll, "CakeDestination", "blossom")
	cake.LayoutOrder = 20
	UI.Label(cake, "CakeTitle", unlocked and "✓ Birthday cake is ready" or "Birthday cake · complete all six petals", 18, P.ink).LayoutOrder = 1
	UI.Button(cake, "TrackCake", "Find the birthday table", function() closeActivity(); track("Cake") end).LayoutOrder = 2
	local panelIds = {}
	for id in pairs(Extensions.panels) do table.insert(panelIds, id) end
	table.sort(panelIds)
	for _, id in ipairs(panelIds) do
		local descriptor = Extensions.panels[id]
		local visible = true
		if descriptor.visible then local ok, result = pcall(descriptor.visible, extensionContext()); visible = ok and result == true end
		if visible then
			UI.Button(scroll, "ExtraPanel" .. id, Guidance.Text(descriptor.label, "More birthday options"), function()
				setMode("extension")
				activeExtension = id
				clearContent()
				title.Text = Guidance.Text(descriptor.title or descriptor.label, "Birthday options")
				local ok, err = pcall(descriptor.render, scroll, extensionContext())
				if not ok then warn("Birthday panel failed", id, err); showToast("These controls are not ready. Please reopen them.", true) end
			end, true).LayoutOrder = 30
		end
	end
	scroll.CanvasPosition = preserveScroll and previous or Vector2.zero
end

renderCake = function(state, preserveScroll)
	cakeState = state or cakeState
	setMode("cake")
	local previous = scroll.CanvasPosition
	clearContent()
	title.Text = "Happy Birthday, Phuong!"
	local phases = {
		LOCKED = "Complete all six petals, including Phuong's wanted Labubu, to unlock cake.",
		INVITED = "The birthday table is ready. Walk to the patio and gather together.",
		CUT = "The cake is cut! Choose a slice and enjoy the moment together.",
		EATING = "Enjoy your cake and take a photo with your friends.",
	}
	addLabel("CakeNextStep", Guidance.Text(cakeState.guide and cakeState.guide.detail, phases[cakeState.finaleState] or "Gather around the birthday table."), 1, 17)
	UI.Button(scroll, "TrackPatio", "Show the birthday table", function() closeActivity(); track("Cake") end, true).LayoutOrder = 2
	local custom = Extensions.activities.Cake
	if custom then
		local ok, err = pcall(custom, scroll, cakeState, extensionContext())
		if not ok then warn("Birthday cake presentation failed", err) end
	else
		local host = player.UserId == lastSnapshot.phuongUserId or player.UserId == lastSnapshot.hostUserId
		local phase = cakeState.finaleState
		local methods = {}
		if phase == "INVITED" and host then methods = { { "Cut", "Cut the birthday cake" }, { "CancelInvite", "Cancel the invitation" } }
		elseif phase == "CUT" or phase == "EATING" then methods = { { "Eat", "Enjoy a slice of cake" } }
		elseif host and Guidance.PetalCount(lastSnapshot.petals) >= 6 then methods = { { "Invite", "Invite everyone for cake" } } end
		for index, method in ipairs(methods) do
			local button = UI.Button(scroll, "CakeAction" .. index, pending and "Saving…" or method[2], function() if send({ kind = "Cake", action = method[1] }) then renderCake(cakeState, true) end end)
			button.LayoutOrder = index + 3
			UI.SetEnabled(button, pending == nil)
		end
	end
	scroll.CanvasPosition = preserveScroll and previous or Vector2.zero
end

extensionContext = function()
	return {
		UI = UI, gui = gui, player = player, snapshot = lastSnapshot, sessionId = sessionId,
		pending = pending ~= nil, toast = showToast, track = track, close = closeActivity,
		send = send, requestView = requestView,
		runAction = function(descriptor, confirmed) if currentView then runDescriptor(currentView, descriptor, confirmed) end end,
		refresh = function()
			if panelMode == "activity" and currentView then renderActivity(currentView, true)
			elseif panelMode == "cake" then renderCake(cakeState, true)
			elseif panelMode == "extension" and activeExtension and Extensions.panels[activeExtension] then
				clearContent(); Extensions.panels[activeExtension].render(scroll, extensionContext())
			end
		end,
	}
end

local function mergeSnapshot(snapshot)
	if type(snapshot) ~= "table" then return end
	local oldCount = Guidance.PetalCount(lastSnapshot.petals)
	for key, value in pairs(snapshot) do lastSnapshot[key] = value end
	-- Future server integrations can provide actor-specific views for the
	-- journal/markers without opening their activity panels.
	if type(snapshot.activityViews) == "table" then
		for id, view in pairs(snapshot.activityViews) do
			if Guidance.Activities[id] and type(view) == "table" then viewCache[id] = view end
		end
	end
	if type(snapshot.sessionId) == "string" and snapshot.sessionId ~= "" then sessionId = snapshot.sessionId end
	if snapshot.cake then cakeState = snapshot.cake end
	local count = Guidance.PetalCount(lastSnapshot.petals)
	if count > oldCount then
		showToast(count == 6 and "All six petals are complete! Everyone head to the birthday table." or string.format("Another petal! %d of 6 complete together.", count))
		if count == 6 then explicitTrack = "Cake"; trackedWasComplete = false end
	end
	refreshHud()
end

action.OnClientEvent:Connect(function(payload)
	if type(payload) ~= "table" then return end
	if type(payload.sessionId) == "string" and payload.sessionId ~= "" then sessionId = payload.sessionId end
	local expected = pending
	local matched = expected ~= nil and payload.actionId == expected.id
	if matched then pending = nil end
	if payload.snapshot then mergeSnapshot(payload.snapshot) end
	if payload.cake then cakeState = payload.cake end
	if inWorld() then
		local currentResponse = matched and expected.epoch == epoch
		local unsolicitedActiveView = payload.actionId == nil and panelMode == "activity" and currentView and payload.view and payload.view.activityId == currentView.activityId
		if payload.view and ((currentResponse and (expected.kind == "RequestView" or expected.kind == "ActivityAction")) or unsolicitedActiveView) then
			if currentResponse then
				selectedAction, confirmation = nil, nil
				if expected.payloadAction == "reserve" or expected.payloadAction == "place" or expected.payloadAction == "cancel" then activeGroup = nil end
			end
			if Guidance.Activities[payload.view.activityId] then
				renderActivity(payload.view, unsolicitedActiveView or expected and expected.kind == "ActivityAction")
			else
				closeActivity()
				showToast("This activity is not ready. Try another petal or ask a host for help.", true)
			end
		elseif currentResponse and expected.kind == "RequestView" then
			closeActivity()
			if payload.ok ~= false then showToast("The activity did not send its choices. Please reopen it.", true) end
		end
		if currentResponse and expected.kind == "ActivityAction" and not payload.view and currentView then renderActivity(currentView, true) end
		if panelMode == "journal" and payload.snapshot then renderJournal(lastSnapshot, true) end
		if payload.journal and currentResponse and panelMode == "journal" then renderJournal(payload.journal) end
		if panelMode == "cake" and (payload.cake or payload.snapshot and payload.snapshot.cake) then renderCake(cakeState, true) end
		if payload.kind == "Result" and currentResponse then
			if payload.ok == false then showToast(Guidance.FriendlyError(payload.code, payload.errorText), true)
			elseif expected.kind == "ActivityAction" then showToast("Your choice is saved for the group.") end
		end
	end
	if matched and panelMode == "extension" then extensionContext().refresh() end
	Extensions.Notify(payload, extensionContext())
end)

journalButton.Activated:Connect(function()
	closeActivity()
	renderJournal(lastSnapshot)
	send({ kind = "RequestJournal" })
end)
trackButton.Activated:Connect(function()
	track(explicitTrack or recommended)
	local info = Guidance.Activities[explicitTrack or recommended]
	if info then showToast(info.destination .. " · follow the marker.") end
end)
close.Activated:Connect(closeActivity)
back.Activated:Connect(function()
	if confirmation then confirmation = nil; renderActivity(currentView)
	elseif panelMode == "journal" then closeActivity()
	else closeActivity(); renderJournal(lastSnapshot) end
end)

local bound = setmetatable({}, { __mode = "k" })
local function bind(prompt)
	if not prompt:IsA("ProximityPrompt") or bound[prompt] then return end
	local id = prompt:GetAttribute("ActivityId") or (prompt.Parent and prompt.Parent:GetAttribute("ActivityId"))
	if not Guidance.Activities[id] then return end
	bound[prompt] = true
	prompt.Triggered:Connect(function(who)
		if who and who ~= player then return end
		if not inWorld() then return end
		if id == "Cake" then closeActivity(); renderCake(cakeState)
		else requestView(id) end
	end)
end
for _, instance in ipairs(workspace:GetDescendants()) do bind(instance) end
workspace.DescendantAdded:Connect(bind)

UserInputService.InputBegan:Connect(function(input, processed)
	if processed then return end
	if input.KeyCode == Enum.KeyCode.Escape and panel.Visible then closeActivity(); return end
	if input.KeyCode == Enum.KeyCode.J and inWorld() then
		if panelMode == "journal" then closeActivity() else closeActivity(); renderJournal(lastSnapshot) end
		return
	end
	if not currentView or not panel.Visible or confirmation or pending then return end
	local directionValue = input.KeyCode == Enum.KeyCode.Q and -1 or input.KeyCode == Enum.KeyCode.E and 1
	if not directionValue then return end
	for _, descriptor in ipairs(currentView.availableActions or {}) do
		local payload = descriptor.payload or {}
		if descriptor.enabled ~= false and payload.action == "rotate" and payload.direction == directionValue then runDescriptor(currentView, descriptor); break end
	end
end)

local function locationChanged()
	if not inWorld() then
		closeActivity()
		explicitTrack, recommended = nil, nil
		navigator:Clear()
		toast.Visible = false
	else refreshHud() end
	Extensions.Notify({ kind = "LocationChanged", inWorld = inWorld() }, extensionContext())
end
player:GetAttributeChangedSignal("BirthdayLocation"):Connect(locationChanged)
player.CharacterRemoving:Connect(function()
	navigator.suspended = true
	closeActivity()
	explicitTrack = nil
	navigator:Clear()
	Extensions.Notify({ kind = "CharacterRemoving" }, extensionContext())
end)
player.CharacterAdded:Connect(function(character)
	task.spawn(function()
		character:WaitForChild("HumanoidRootPart", 10)
		if player.Character == character then navigator.suspended = false; refreshHud() end
	end)
end)

-- Optional modules under client.extensions export Init(getContext, Extensions).
-- getContext() returns fresh state; registered renderers/observers also receive it.
local loaded = setmetatable({}, { __mode = "k" })
local function loadExtension(module)
	if not module:IsA("ModuleScript") or loaded[module] then return end
	loaded[module] = true
	local ok, result = pcall(require, module)
	if ok and type(result) == "table" and type(result.Init) == "function" then
		local initOk, err = pcall(result.Init, extensionContext, Extensions)
		if not initOk then warn("Birthday extension initialization failed", module.Name, err) end
	elseif not ok then warn("Birthday extension load failed", module.Name, result) end
end
local function loadExtensionFolder(folder)
	if folder.Name ~= "extensions" then return end
	local modules = folder:GetChildren()
	table.sort(modules, function(a, b) return a.Name < b.Name end)
	for _, module in ipairs(modules) do loadExtension(module) end
	folder.ChildAdded:Connect(loadExtension)
end
local extensionFolder = client:FindFirstChild("extensions")
if extensionFolder then loadExtensionFolder(extensionFolder) end
client.ChildAdded:Connect(loadExtensionFolder)

RunService.Heartbeat:Connect(function(delta)
	heartbeatElapsed += delta
	if heartbeatElapsed < .25 then return end
	heartbeatElapsed = 0
	if inWorld() then refreshHud() else navigator:Clear() end
end)
layout()
locationChanged()
action:FireServer({ kind = "RequestSnapshot", actionId = freshId() })
