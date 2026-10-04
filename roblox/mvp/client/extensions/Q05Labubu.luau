-- PCW-18 extension: cards preview locally; only canonical server descriptors
-- confirm wishes/purchases. Reveal/Skip never send an award acknowledgement.
local TweenService = game:GetService("TweenService")
local Catalog = require(script.Parent.Parent.Parent.shared.FigureCatalog)
local Presentation = require(script.Parent.Parent.Parent.shared.FigurePresentation)
local Guidance = require(script.Parent.Parent.Parent.shared.Guidance)
local Module = {}
local REVEAL_SECONDS = 1.6

local function viewport(parent, UI, figureId, height)
	local frame = Instance.new("ViewportFrame")
	frame.Name, frame.Size, frame.BackgroundColor3, frame.BorderSizePixel = "ToyPreview", UDim2.new(1, 0, 0, height), UI.Palette.cream, 0
	frame.Ambient, frame.LightColor, frame.LightDirection = UI.Palette.cream, UI.Palette.golden, Vector3.new(-1, -1, -1)
	frame.Parent = parent; UI.Corner(frame, 8)
	local camera = Instance.new("Camera")
	camera.FieldOfView = 34; camera.CFrame = CFrame.lookAt(Vector3.new(.4, 1.9, -6), Vector3.new(0, 1.5, 0))
	camera.Parent = frame; frame.CurrentCamera = camera
	if Catalog.ById[figureId] then local figure = Presentation.Build(figureId); figure.Parent = frame end
	return frame
end
local function descriptor(view, step, id)
	for _, action in ipairs(view.availableActions or {}) do
		if action.stepId == step and (not id or action.payload.figureId == id) then return action end
	end
	return nil
end
function Module.Init(getContext, registry)
	local selected, version, sessionId, expanded, skippedReceipt
	local panel = getContext().gui:FindFirstChild("ActivityPanel")
	registry.RegisterActivity("Q05", function(container, view, context)
		local UI = context.UI
		if sessionId ~= context.sessionId then selected, version, expanded, skippedReceipt = nil, nil, nil, nil; sessionId = context.sessionId end
		if version ~= view.wishVersion then selected, expanded = view.wantedFigureId, not view.wantedFigureId; version = view.wishVersion end
		if expanded == nil then expanded = not view.wantedFigureId end
		container.LayoutOrder = 6; UI.List(container, 8)
		-- This activity supplies its own seven visual cards and prominent actions.
		-- Keep the common confirmation, request lock, Back/Close and scroll shell.
		-- The generic renderer adds groups after mounting us; scope that listener
		-- to this mount so other activities keep their normal generic controls.
		local function customize(child)
			if child.Name == "MainAction" or child.Name == "SelectedDetail" or child.Name == "WaitingForNext" or string.match(child.Name, "^ChoiceGroup%d+$") then
				if child:IsA("GuiObject") then child.Visible = false end
			elseif child.Name == "HelpAndExit" and child:IsA("TextLabel") then
				child.Text = "Close or Skip anytime. Confirmed wishes, figures and shared spending stay saved for this server session."
			end
		end
		for _, child in ipairs(container.Parent:GetChildren()) do customize(child) end
		local added = container.Parent.ChildAdded:Connect(customize)
		local tweens = {}; local alive = true
		container.Destroying:Connect(function() alive = false; added:Disconnect(); for _, tween in ipairs(tweens) do tween:Cancel() end end)

		local summary = UI.Card(container, "LabubuSummary", "sage"); summary.LayoutOrder = 1
		UI.Label(summary, "SharedBalance", "Shared fund · " .. tostring(view.sharedFundBalance or 0) .. "     Collection · " .. tostring(view.collectionCount or 0) .. " copies", 17, UI.Palette.forest).LayoutOrder = 1
		UI.Label(summary, "Wish", "Confirmed wish · " .. view.wantedLabel, 16).LayoutOrder = 2
		UI.Label(summary, "HowItWorks", "Friends earn together. A box costs 20. Five first activity completions fund all five possible boxes; no replay is needed for the first wish.", 14).LayoutOrder = 3
		UI.Label(summary, "Odds", "Each regular: 16.5% · Secret: 1%. Your selected wish, including the secret, is guaranteed by box five.", 13).LayoutOrder = 4
		if view.wantedFigureId then
			UI.Label(summary, "Guarantee", view.wishFulfilled and "✓ Wish received" or tostring(view.attemptsRemaining) .. " boxes or fewer until " .. view.wantedLabel .. " · " .. tostring(view.rollCount) .. " opened for this wish", 15, UI.Palette.forest).LayoutOrder = 5
		end
		if not view.canControl then
			UI.Label(summary, "FriendsHelp", "You are watching and helping. " .. view.controlMessage, 15).LayoutOrder = 6
		end

		local latest = view.latestResult
		local remaining = latest and math.max(0, REVEAL_SECONDS - (workspace:GetServerTimeNow() - latest.awardedAt)) or 0
		local revealing = latest and remaining > 0 and skippedReceipt ~= latest.receiptId
		if latest then
			local result = UI.Card(container, "SavedLabubuResult", "golden"); result.LayoutOrder = 2
			UI.Label(result, "ResultTitle", revealing and "Opening your saved box…" or "Latest result · " .. latest.awardLabel, 18, UI.Palette.forest).LayoutOrder = 1
			local shownFigure = not revealing and latest.awardFigureId or nil
			local frame = viewport(result, UI, shownFigure, 145); frame.LayoutOrder = 2
			if revealing then
				local capsule = Presentation.Capsule(1.25); capsule.Parent = frame
				local top = capsule:FindFirstChild("Upper")
				local progress = math.clamp(1 - remaining / REVEAL_SECONDS, 0, 1)
				top.CFrame = CFrame.new(0, 1.275 + progress * 1.3, 0)
				local tween = TweenService:Create(top, TweenInfo.new(remaining, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), { CFrame = CFrame.new(0, 2.575, 0) })
				table.insert(tweens, tween); tween:Play()
				local function finishReveal()
					if not alive then return end
					skippedReceipt = latest.receiptId; getContext().refresh()
				end
				UI.Button(result, "SkipReveal", "Skip reveal · show my figure", finishReveal, true).LayoutOrder = 3
				task.delay(remaining, finishReveal)
			end
			UI.Label(result, "SavedAward", "Saved · " .. latest.awardLabel .. " ×" .. tostring(latest.copies) .. " in the collection. " .. (latest.recovery and "Host recovery · no fund spent." or tostring(latest.cost or 20) .. " spent once."), 15).LayoutOrder = 4
			UI.Label(result, "ResultMeaning", latest.recovery and "✓ A host restored the confirmed wish. Paid box count and guarantee were preserved; the birthday petal is saved." or latest.wantedFulfilled and "✓ This box fulfilled the confirmed wish. Your birthday petal stays saved." or "A new copy for the shared collection. The confirmed wish is still guaranteed.", 14).LayoutOrder = 5
		end

		if view.nextActivity and (view.q05Petal or not view.canControl or (view.sharedFundBalance or 0) < 20) then
			local info = Guidance.Activities[view.nextActivity]
			if info then
				local nextCard = UI.Card(container, "LabubuNextGoal", "cream"); nextCard.LayoutOrder = 3
				UI.Label(nextCard, "NextGoalTitle", view.q05Petal and "Birthday wish complete · continue the story" or "Help the group earn the next box", 17, UI.Palette.forest).LayoutOrder = 1
				UI.Button(nextCard, "TrackNextGoal", "Next · " .. info.title, function() local fresh = getContext(); fresh.track(view.nextActivity); fresh.close() end).LayoutOrder = 2
				UI.Label(nextCard, "NextGoalDetail", view.q05Petal and "Any more collecting is optional. It cannot remove this petal or relock cake." or info.reward, 14).LayoutOrder = 3
			end
		end
		local roll = descriptor(view, "roll")
		if roll then
			local actionCard = UI.Card(container, "OpenLabubuBox", "cream"); actionCard.LayoutOrder = 4
			local button = UI.Button(actionCard, "GetLabubu", context.pending and "Saving your box…" or "Get a Labubu - 20", function() getContext().runAction(roll) end)
			button.LayoutOrder = 1; UI.SetEnabled(button, roll.enabled ~= false and not context.pending and not revealing)
			UI.Label(actionCard, "BoxHelp", revealing and "Your figure is already saved. Skip or finish the reveal before choosing another box." or roll.enabled == false and roll.reason or "Review the shared spend before opening. Your confirmed wish stays locked until you receive it.", 14).LayoutOrder = 2
		end

		local gallery = UI.Card(container, "LabubuGallery", "cream"); gallery.LayoutOrder = 5
		local title = not view.wantedFigureId and view.canChooseWish and "Choose your wish · seven figures" or view.q05Petal and "Optional collection · seven figures" or "See all seven figures"
		UI.Button(gallery, "ShowFigures", (expanded and "▾ " or "▸ ") .. title, function() expanded = not expanded; getContext().refresh() end, true).LayoutOrder = 1
		if expanded then
			UI.Label(gallery, "SimplifiedPreview", "Simplified toy previews · world palette. Tap a card to preview; this does not spend or confirm anything.", 13).LayoutOrder = 2
			if view.wantedFigureId and not view.wishFulfilled then
				UI.Label(gallery, "WishLocked", "The confirmed wish stays locked until received. These cards are free previews.", 14).LayoutOrder = 3
			end
			for index, entry in ipairs(view.figures or {}) do
				local row = Instance.new("Frame")
				row.Name, row.Size, row.BackgroundColor3, row.BorderSizePixel, row.LayoutOrder = "FigureCard" .. index, UDim2.new(1, 0, 0, 88), UI.Palette.sage, 0, index + 4
				row.Parent = gallery; UI.Corner(row, 8)
				local frame = viewport(row, UI, entry.id, 80)
				frame.Size, frame.Position = UDim2.fromOffset(74, 80), UDim2.fromOffset(4, 4)
				local isSelected = selected == entry.id
				local choose = isSelected and descriptor(view, "select-wanted", entry.id) or nil
				local button = UI.Button(row, "PreviewFigure", (isSelected and "✓ " or "") .. entry.label, function() selected = entry.id; getContext().refresh() end, not isSelected)
				button.Position, button.Size = UDim2.fromOffset(86, 4), UDim2.new(1, -90, 0, 52)
				UI.SetEnabled(button, not context.pending, not isSelected)
				local detail = UI.Label(row, "OddsAndCopies", entry.odds .. " · ×" .. tostring(entry.copies), 13)
				detail.AutomaticSize, detail.Position, detail.Size = Enum.AutomaticSize.None, UDim2.fromOffset(86, 60), UDim2.new(1, -90, 0, 26)
				if isSelected then local stroke = Instance.new("UIStroke"); stroke.Color, stroke.Thickness, stroke.Parent = UI.Palette.forest, 2, row end
				if choose then
					-- Confirm sits inside the selected card, so a phone user never
					-- needs to hunt above seven cards after choosing the last one.
					row.Size = UDim2.new(1, 0, 0, 184)
					local hint = UI.Label(row, "NotConfirmed", "Preview only · wish not confirmed yet", 13)
					hint.AutomaticSize, hint.Position, hint.Size = Enum.AutomaticSize.None, UDim2.fromOffset(8, 92), UDim2.new(1, -16, 0, 28)
					local confirm = UI.Button(row, "ConfirmWish", "Confirm wish · " .. entry.label, function() getContext().runAction(choose) end)
					confirm.Position, confirm.Size = UDim2.fromOffset(8, 124), UDim2.new(1, -16, 0, 52)
					UI.SetEnabled(confirm, not context.pending and not revealing)
				end
			end
		end
		UI.Label(container, "SessionCollection", "The shared collection is displayed on its own bedroom shelf ledge. Copies stay for this running server session.", 13).LayoutOrder = 6
	end)
	registry.RegisterObserver("Q05Labubu", function(payload, context)
		if payload.kind == "CharacterRemoving" or payload.kind == "LocationChanged" and not payload.inWorld then selected, version, expanded = nil, nil, nil; return end
		if payload.activityId ~= "Q05" or type(payload.result) ~= "table" or type(payload.result.message) ~= "string" then return end
		if not panel or not panel.Visible or not panel:FindFirstChild("LabubuSummary", true) then return end
		if context.player:GetAttribute("BirthdayLocation") ~= "World" then return end
		getContext().toast(payload.result.message, payload.ok == false)
	end)
end
return Module
