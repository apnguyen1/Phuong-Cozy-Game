_G.__PCW25ContractText..=[==[
        sfx.Position,sfx.Size=UDim2.fromOffset(musicWidth+118,4),UDim2.fromOffset(64,48)
    end
    table.insert(connections,overlay:GetPropertyChangedSignal("AbsoluteSize"):Connect(layout))
    if activityPanel then table.insert(connections,activityPanel:GetPropertyChangedSignal("Visible"):Connect(function() expanded=false; layout(); drawControls() end)) end
    for _,attribute in ipairs({"CozyMusicMuted","CozyMusicVolume","CozyEffectsEnabled"}) do
        table.insert(connections,player:GetAttributeChangedSignal(attribute):Connect(refresh))
    end
    table.insert(connections,player:GetAttributeChangedSignal("BirthdayLocation"):Connect(refresh))
    table.insert(connections,initial.gui:GetAttributeChangedSignal("FinaleSkippedSessionId"):Connect(refresh))
    table.insert(connections,initial.gui:GetAttributeChangedSignal("FinaleSkippedGeneration"):Connect(refresh))
    registry.RegisterObserver("MusicController",function(payload,context)
        if destroyed then return end
        local state=payload.cake or payload.snapshot and payload.snapshot.cake or context.snapshot.cake
        if type(state)=="table" then latest=state end
        if payload.kind=="FinaleCameraSkipped" and payload.sessionId==context.sessionId and type(payload.generation)=="number" and payload.generation>0 then
            local key=finaleKey(payload,payload.sessionId)
            runs[key]=runs[key] or {}; runs[key].skipped=true
        end
        refresh()
    end)
    registry.RegisterPanel("AudioStatus",{
        title="Audio status",label="Audio status",
        visible=function(context) return context.snapshot.host and context.snapshot.host.authorized==true end,
        render=function(container)
            UI.Label(container,"AudioStatusTitle","Music and sound effects · this listener",20,UI.Palette.forest).LayoutOrder=1
            UI.Label(container,"AudioMode","Current music: "..mode.." · "..configuration,16).LayoutOrder=2
            for index,name in ipairs({"Birthday","World"}) do
                local track=tracks[name]
                UI.Label(container,name.."Load",track.spec.title.." · "..track.spec.id.." · "..track.status,16).LayoutOrder=index+2
            end
            local effects=SoundService:FindFirstChild("CozySoundEffectsLocal")
            for index,name in ipairs({"SoftClick","SuccessChime","JasperBark","JasperPant"}) do
                UI.Label(container,name.."Load",name..": "..tostring(effects and effects:GetAttribute(name.."Status") or "Client unavailable"),15).LayoutOrder=index+4
            end
            UI.Label(container,"AudioLimit","Unavailable or timed out audio stays quiet for this session. Asset access must be checked in the published experience. Loading is not an audition.",15).LayoutOrder=10
        end,
    })
    local tick=0
    table.insert(connections,RunService.Heartbeat:Connect(function(dt)
        if destroyed then return end
        for _,track in pairs(tracks) do
            local progress=math.clamp((os.clock()-track.fadeAt)/config.CrossfadeSeconds,0,1)
            local eased=progress*progress*(3-2*progress)
            track.sound.Volume=track.from+(track.target-track.from)*eased
            if track.name=="Birthday" and mode=="Finale" and latest and type(latest.endsAt)=="number" then
                local remaining=math.clamp((latest.endsAt-workspace:GetServerTimeNow())/config.CrossfadeSeconds,0,1)
                track.sound.Volume*=remaining -- Land softly at the shared end, not an abrupt twelve-second cut.
            end
            if progress==1 and not track.wanted then pause(track) end
        end
        tick+=dt
        if tick>=.1 then tick=0; refresh() end -- Ends on shared time even without another snapshot.
    end))
    local function destroy()
        if destroyed then return end
        destroyed=true
        for _,connection in ipairs(connections) do connection:Disconnect() end
        for _,track in pairs(tracks) do
            if track.loaded then track.loaded:Disconnect() end
            cancelThread(track.worker); cancelThread(track.timeout)
            track.sound:Stop()
        end
        registry.observers.MusicController=nil; registry.panels.AudioStatus=nil
        if initial.gui.Parent then initial.gui:SetAttribute("AudioControlsInset",nil) end
        folder:Destroy(); overlay:Destroy(); instance=nil
    end
    table.insert(connections,initial.gui.Destroying:Connect(destroy))
    table.insert(connections,overlay.Destroying:Connect(destroy))
    table.insert(connections,folder.Destroying:Connect(destroy))
    table.insert(connections,script.Destroying:Connect(destroy))
    instance={Destroy=destroy}
    layout(); refresh()
    return instance
end
return Module
]=],
["roblox/mvp/client/extensions/Q01Bedroom.luau"] = [=[-- Optional PCW-18 presentation extension. Server descriptors remain authoritative.
local Module = {}
local function ownedRoot()
	local world = workspace:FindFirstChild("CozyWorld_Draft01")
	local mvp = world and world:FindFirstChild("MVP")
	local runtime = mvp and mvp:FindFirstChild("RuntimePresentation")
	return runtime and runtime:FindFirstChild("BedroomFeedback")
end
local function bedSource(step)
	local world = workspace:FindFirstChild("CozyWorld_Draft01")
	local home = world and world:FindFirstChild("Home")
	local room = home and home:FindFirstChild("Bedroom")
	local bed = room and room:FindFirstChild("SageBed")
	if not bed then return nil end
	local names = { blanket_left = "SageDuvet", blanket_right = "SageDuvet", blanket_foot = "FoldedCreamQuilt", pillow_left = "CreamSleepingPillow", pillow_right = "CreamSleepingPillow_002" }
	if names[step] then return bed:FindFirstChild(names[step]) end
	local plushies = bed:FindFirstChild("BedPlushies")
	local plushName = step == "plush_dog" and "WeightedDog" or step == "plush_dinosaur" and "WeightedDinosaur"
	return plushies and plushName and plushies:FindFirstChild(plushName)
end
local function preview(parent, source, UI)
	if not source then return end -- Streamed/missing art never blocks a task.
	local viewport = Instance.new("ViewportFrame")
	viewport.Name, viewport.Size, viewport.LayoutOrder = "HeldItemPreview", UDim2.new(1, 0, 0, 105), 2
	viewport.BackgroundColor3, viewport.BorderSizePixel = UI.Palette.cream, 0
	viewport.Ambient, viewport.LightColor = UI.Palette.cream, UI.Palette.golden
	viewport.LightDirection = Vector3.new(-1, -1, -1)
	viewport.Parent = parent; UI.Corner(viewport, 10)
	local model = Instance.new("Model"); model.Parent = viewport
	local cloned = source:Clone()
	if not cloned then viewport:Destroy(); return end
	for _, child in ipairs(cloned:GetDescendants()) do
		if child:IsA("BasePart") then child.Anchored, child.CanCollide, child.CanTouch, child.CanQuery = true, false, false, false
		elseif not child:IsA("SpecialMesh") and not child:IsA("Model") and not child:IsA("Folder") then child:Destroy() end
	end
	cloned.Parent = model
	local frame, size = model:GetBoundingBox()
	local camera = Instance.new("Camera")
	camera.FieldOfView = 34
	local distance = math.max(size.X, size.Y, size.Z) * 2.05
	camera.CFrame = CFrame.lookAt(frame.Position + Vector3.new(.4, .6, 1).Unit * distance, frame.Position)
	camera.Parent = viewport; viewport.CurrentCamera = camera
end

function Module.Init(getContext, registry)
	local activeCue, activeBillboard
	local function clearCue()
		if activeCue then activeCue:Destroy(); activeCue = nil end
		if activeBillboard then activeBillboard:Destroy(); activeBillboard = nil end
	end
	-- Main keeps its hidden content mounted on Close. Clear world adornments
	-- immediately when the containing panel hides, as well as on mount teardown.
	local panel = getContext().gui:FindFirstChild("ActivityPanel")
	if panel then panel:GetPropertyChangedSignal("Visible"):Connect(function() if not panel.Visible then clearCue() end end) end
	registry.RegisterActivity("Q01", function(container, view, context)
		clearCue()
		local UI, held = context.UI, view.held or (view.shelf and view.shelf.held)
		UI.List(container, 8)
		if held then
			local card = UI.Card(container, "HeldItem", "golden")
			UI.Label(card, "Holding", "Holding · " .. held.label, 17, UI.Palette.forest).LayoutOrder = 1
			local source = held.stepId and bedSource(held.stepId)
			local root = ownedRoot()
			if not source and root and held.itemId then
				local names = { book_sage = "SageBook", book_cream = "CreamBook", small_figure = "SmallShelfFigure" }
				local shelf = root:FindFirstChild("Shelf")
				source = shelf and names[held.itemId] and shelf:FindFirstChild(names[held.itemId])
			end
			preview(card, source, UI)
			UI.Label(card, "Destination", held.destination or (held.slotId and "Destination · top shelf " .. held.slotId or "Next · choose a labeled top shelf spot"), 15).LayoutOrder = 3
			UI.Label(card, "NoRush", "If the item is put back, choose it again. Closing frees the spot for a friend.", 13).LayoutOrder = 4
			local target = root and held.targetName and root:FindFirstChild(held.targetName, true)
			if target and target:IsA("BasePart") then
				local cue = Instance.new("BoxHandleAdornment")
				cue.Name, cue.Adornee, cue.Size = "BedroomDestinationCue", target, target.Size + Vector3.new(.15, .15, .15)
				cue.AlwaysOnTop, cue.ZIndex, cue.Transparency, cue.Color3 = true, 4, .35, UI.Palette.golden
				cue.Parent = context.gui; activeCue = cue
				local billboard = Instance.new("BillboardGui")
				billboard.Name, billboard.Adornee, billboard.AlwaysOnTop = "BedroomPlaceHere", target, true
				billboard.Size, billboard.StudsOffsetWorldSpace, billboard.MaxDistance = UDim2.fromOffset(160, 42), Vector3.new(0, 1.8, 0), 42
				billboard.Parent = context.gui; activeBillboard = billboard
				local text = Instance.new("TextLabel")
				text.Size, text.Text, text.TextSize, text.Font = UDim2.fromScale(1, 1), "Place here", 17, Enum.Font.GothamBold
				text.TextColor3, text.BackgroundColor3, text.BorderSizePixel = UI.Palette.cream, UI.Palette.forest, 0
				text.Parent = billboard; UI.Corner(text, 10)
				-- Capture this render's objects; destroying an old mount cannot clear
				-- the new render's cue after a live activity update.
				container.Destroying:Connect(function()
					cue:Destroy(); billboard:Destroy()
					if activeCue == cue then activeCue = nil end
					if activeBillboard == billboard then activeBillboard = nil end
				end)
			end
		end
		if view.doneLabels and #view.doneLabels > 0 then
			local done = UI.Card(container, "CompletedBedTasks", "sage"); done.LayoutOrder = 2
			local detail = UI.Label(done, "DoneList", "✓ " .. table.concat(view.doneLabels, "\n✓ "), 14)
			detail.Visible, detail.LayoutOrder = false, 2
			UI.Button(done, "ToggleDone", "Done · " .. #view.doneLabels .. " bed tasks", function() detail.Visible = not detail.Visible end, true).LayoutOrder = 1
		end
		if view.shelf and view.shelf.ready then
			local shelf = UI.Card(container, "SharedShelf", "cream"); shelf.LayoutOrder = 3
			UI.Label(shelf, "ShelfTitle", "Optional bedroom shelf", 17, UI.Palette.forest).LayoutOrder = 1
			for index, slot in ipairs(view.shelf.slots or {}) do
				UI.Label(shelf, "ShelfSlot" .. index, slot.label .. " · " .. (slot.busy and "In use" or slot.itemLabel or "Empty"), 14).LayoutOrder = index + 1
			end
			UI.Label(shelf, "ShelfHelp", "Open the optional shelf cards below to choose an item. Shelf tidying adds no petals or money.", 13).LayoutOrder = 5
		end
	end)
	registry.RegisterObserver("Q01Bedroom", function(payload, context)
		if payload.kind == "CharacterRemoving" or payload.kind == "LocationChanged" and not payload.inWorld then clearCue() end
		if payload.activityId == "Q01" and payload.ok == false and type(payload.result) == "table" and type(payload.result.message) == "string" then
			-- Only this recipient's rejected action includes result; broadcasts carry
			-- own views without private action receipts or error toasts.
			getContext().toast(payload.result.message, true)
		end
	end)
end
return Module
]=],
["roblox/mvp/client/extensions/Q05Labubu.luau"] = [=[-- PCW-18 extension: cards preview locally; only canonical server descriptors
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
]=],
["roblox/mvp/client/extensions/Q06Food.luau"] = [=[-- PCW-18 extension. Preview selection is local; shared food is server-authored.
local FoodPresentation = require(script.Parent.Parent.Parent.shared.FoodPresentation)
local Guidance = require(script.Parent.Parent.Parent.shared.Guidance)
local Module = {}

local function preview(parent, view, UI)
	local viewport = Instance.new("ViewportFrame")
	viewport.Name, viewport.Size, viewport.LayoutOrder = "FoodPreview", UDim2.new(1, 0, 0, 140), 2
	viewport.BackgroundColor3, viewport.BorderSizePixel = UI.Palette.cream, 0
	viewport.Ambient, viewport.LightColor = UI.Palette.cream, UI.Palette.golden
	viewport.LightDirection = Vector3.new(-1, -1, -1)
	viewport.Parent = parent; UI.Corner(viewport, 10)
	local model = FoodPresentation.Build(view.foodDisplay or {}, view.held)
	model.Parent = viewport
	local camera = Instance.new("Camera")
	camera.FieldOfView = 34
	camera.CFrame = CFrame.lookAt(Vector3.new(1, 8, 10.5), Vector3.new(0, .3, 0))
	camera.Parent = viewport; viewport.CurrentCamera = camera
end

function Module.Init(getContext, registry)
	local panel = getContext().gui:FindFirstChild("ActivityPanel")
	registry.RegisterActivity("Q06", function(container, view, context)
		local UI = context.UI
		UI.List(container, 8)
		-- Keep the preview ahead of the explicit Add/Place button. The PCW-18
		-- activity mount owns no remote behavior; generic descriptors still submit.
		container.LayoutOrder = 6
		local main = container.Parent:FindFirstChild("MainAction")
		if main and (view.state == "COMPLETED" or not view.atCounter) then main.Visible = false end
		local track = container.Parent:FindFirstChild("TrackNextStep")
		if track and track:IsA("TextButton") then track.Text = "Track next counter" end
		local recipe = UI.Card(container, "RecipeRoute", "cream"); recipe.LayoutOrder = 1
		UI.Label(recipe, "RecipeTitle", "The recipe · three stops", 17, UI.Palette.forest).LayoutOrder = 1
		UI.Label(recipe, "RecipeText", view.recipe or "Build a bowl at FOB, add sauce at Aladdins, then set the serving table.", 14).LayoutOrder = 2
		UI.Label(recipe, "YourLocation", "You are at · " .. (view.currentVenue == "Serving" and "the serving table" or view.currentVenue or "the neighborhood"), 14).LayoutOrder = 3
		local food = UI.Card(container, "YourSharedMeal", view.held and "golden" or "sage"); food.LayoutOrder = 2
		UI.Label(food, "DishTitle", view.held and "Preview · " .. view.held.label .. " selected" or "Your shared meal", 17, UI.Palette.forest).LayoutOrder = 1
		preview(food, view, UI)
		if view.held then
			UI.Label(food, "PreviewStatus", "Not added yet · " .. view.held.destination, 14).LayoutOrder = 3
			UI.Label(food, "PreviewHelp", "Use Add or Place to save this exact choice. Cancel or Close puts the selection back; accepted ingredients stay.", 13).LayoutOrder = 4
		end
		local saved = {}
		for _, item in ipairs(view.dishSummary or {}) do
			if item.complete then table.insert(saved, "✓ " .. item.label .. " · " .. item.detail) end
		end
		UI.Label(food, "AcceptedIngredients", #saved > 0 and table.concat(saved, "\n") or "The shared bowl is empty. Choose rice, a protein or a topping to begin.", 14).LayoutOrder = 5
		if view.state == "COMPLETED" and view.nextActivity then
			local info = Guidance.Activities[view.nextActivity]
			if info then
				local nextCard = UI.Card(container, "NextActivity", "cream"); nextCard.LayoutOrder = 3
				UI.Label(nextCard, "Done", "Done! Everyone's meal is ready.", 17, UI.Palette.forest).LayoutOrder = 1
				UI.Button(nextCard, "TrackAnotherActivity", "Next · " .. info.title, function()
					local fresh = getContext(); fresh.track(view.nextActivity); fresh.close()
				end).LayoutOrder = 2
				UI.Label(nextCard, "OptionalReplay", "Your petal and shared reward are saved. Playing again is optional.", 13).LayoutOrder = 3
			end
		end
	end)
	registry.RegisterObserver("Q06Food", function(payload, context)
		if payload.activityId ~= "Q06" or type(payload.result) ~= "table" or type(payload.result.message) ~= "string" then return end
		-- Only a current visible Q06 response gets a toast. Late replies after
		-- close/reset/lobby must not interrupt exploration or another activity.
		if not panel or not panel.Visible or not panel:FindFirstChild("YourSharedMeal", true) then return end
		if context.player:GetAttribute("BirthdayLocation") ~= "World" then return end
		getContext().toast(payload.result.message, payload.ok == false)
	end)
end
return Module
]=],
["roblox/mvp/client/extensions/WorldActivities.luau"] = [=[-- Q02/Q03/Q04 presentation using PCW-18's function-based extension context.
-- The world and descriptors remain server-authored; no camera/avatar control.
local Module = {}
local function runtime()
	local world=workspace:FindFirstChild("CozyWorld_Draft01")
	local mvp=world and world:FindFirstChild("MVP")
	return mvp and mvp:FindFirstChild("RuntimePresentation")
end
local function craftRoot()
	local root=runtime(); local feedback=root and root:FindFirstChild("WorldFeedback")
	return feedback and feedback:FindFirstChild("Craft")
end
local function preview(parent, source, UI)
	if not source or not source:IsA("Model") then return end
	local viewport=Instance.new("ViewportFrame"); viewport.Name="MiniaturePreview"
	viewport.Size=UDim2.new(1,0,0,155); viewport.BackgroundColor3=UI.Palette.cream; viewport.BorderSizePixel=0
	viewport.Ambient,viewport.LightColor=UI.Palette.cream,UI.Palette.golden
	viewport.LightDirection=Vector3.new(-1,-1,-1); viewport.LayoutOrder=2; viewport.Parent=parent; UI.Corner(viewport,10)
	local clone=source:Clone(); if not clone then viewport:Destroy(); return end
	for _, child in ipairs(clone:GetDescendants()) do
		if child:IsA("BasePart") then child.Anchored,child.CanCollide,child.CanTouch,child.CanQuery=true,false,false,false
		elseif not child:IsA("SpecialMesh") and not child:IsA("Model") and not child:IsA("Folder") then child:Destroy() end
	end
	clone.Parent=viewport
	local frame,size=clone:GetBoundingBox(); local camera=Instance.new("Camera"); camera.FieldOfView=34
	local distance=math.max(size.X,size.Y,size.Z)*1.8
	camera.CFrame=CFrame.lookAt(frame.Position+source:GetPivot():VectorToWorldSpace(Vector3.new(0,4,7)).Unit*distance,frame.Position)
	camera.Parent=viewport; viewport.CurrentCamera=camera
end
function Module.Init(getContext, registry)
	local panel=getContext().gui:FindFirstChild("ActivityPanel")
	local activeCue, noteBuffer
	local function clearCue()
		if activeCue then activeCue:Destroy(); activeCue=nil end
	end
	if panel then panel:GetPropertyChangedSignal("Visible"):Connect(function()
		if not panel.Visible then clearCue(); noteBuffer=nil end
	end) end
	registry.RegisterActivity("Q02",function(container,view,context)
		local UI=context.UI; UI.List(container,8); container.LayoutOrder=10
		local main=container.Parent:FindFirstChild("MainAction")
		if main and not view.atStation then main.Visible=false end
		local card=UI.Card(container,"JasperProgress","cream")
		UI.Label(card,"JasperStep","Jasper's day together",17,UI.Palette.forest).LayoutOrder=1
		local steps={{"greet","Bedroom hello"},{"rabbitFound","Rabbit found in a numbered basket"},{"rabbitReturned","Rabbit returned to Jasper"},{"fetch1","First toy returned"},{"fetch2","Second toy returned"},{"fetch3","Third toy returned"},{"greenie","Greenie + shared petal saved"}}
		local lines={}
		for _,step in ipairs(steps) do table.insert(lines,(view.acceptedStepIds and view.acceptedStepIds[step[1]] and "✓ " or "○ ")..step[2]) end
		UI.Label(card,"SavedSteps",table.concat(lines,"\n"),14).LayoutOrder=2
		UI.Label(card,"SharedPlay","Everyone nearby sees Jasper move and fetch. Friends can take turns; accepted steps stay saved if anyone closes or leaves.",14).LayoutOrder=3
		if view.state=="FETCH" then UI.Label(card,"GentleThrow","Tap Pick up toy + gentle throw. The marked target is forgiving; no dragging, aim or timing is required.",14).LayoutOrder=4 end
	end)
	registry.RegisterActivity("Q03",function(container,view,context)
		clearCue()
		local UI=context.UI; UI.List(container,8); container.LayoutOrder=10
		local craft=view.craft or {}; local held=craft.held
		local card=UI.Card(container,"SharedMiniature",held and "golden" or "cream")
		UI.Label(card,"MiniatureTitle",held and ("Selected · "..held.label.." · "..tostring(held.orientation*90).."°") or "One shared miniature",17,UI.Palette.forest).LayoutOrder=1
		local function refreshPreview()
			if not card.Parent then return end
			local root=craftRoot(); local source=root and (root:FindFirstChild("Booth") or root:FindFirstChild("Bedroom"))
			local old=card:FindFirstChild("MiniaturePreview"); if old then old:Destroy() end
			preview(card,source,UI)
		end
		refreshPreview()
		-- A remote view can precede world replication. One bounded refresh handles
		-- that arrival; no render loop, delayed request or authority is introduced.
		task.delay(.2,refreshPreview)
		local lines={}
		for _,piece in ipairs(craft.pieces or {}) do table.insert(lines,(piece.complete and "✓ " or piece.busy and "○ " or "· ")..piece.label..(piece.complete and " placed" or piece.busy and " selected" or " ready")) end
		UI.Label(card,"Assembly",table.concat(lines,"\n"),14).LayoutOrder=3
		UI.Label(card,"SharedState","The booth and bedroom show the same accepted pieces. Translucent pieces are selections; use Place to keep one.",14).LayoutOrder=4
		if held then
			local rotate={}
			for _,descriptor in ipairs(view.availableActions or {}) do if descriptor.payload and descriptor.payload.action=="rotate" then table.insert(rotate,descriptor) end end
			for index,descriptor in ipairs(rotate) do
				local button=UI.Button(card,"Turn"..index,descriptor.label,function() getContext().runAction(descriptor,false) end,true)
				button.LayoutOrder=4+index; UI.SetEnabled(button,not context.pending,true)
			end
			local root=craftRoot(); local cue,watcher; local alive=true
			local function refreshCue()
				if not alive or not container.Parent or not panel or not panel.Visible then return end
				local best,distance
				local character=context.player.Character; local playerRoot=character and character:FindFirstChild("HumanoidRootPart")
				for _,name in ipairs({"Booth","Bedroom"}) do
					local model=root and root:FindFirstChild(name); local target=model and model:FindFirstChild(held.socketId)
					if target and target:IsA("BasePart") then
						local d=playerRoot and (target.Position-playerRoot.Position).Magnitude or 0
						if not best or d<distance then best,distance=target,d end
					end
				end
				if cue then cue:Destroy(); if activeCue==cue then activeCue=nil end; cue=nil end
				if best then
					cue=Instance.new("BoxHandleAdornment"); cue.Name="CraftMatchingSocket"; cue.Adornee=best
					cue.Size=best.Size+Vector3.new(.12,.12,.12); cue.Color3=UI.Palette.golden; cue.Transparency=.3
					cue.AlwaysOnTop=true; cue.ZIndex=4; cue.Parent=context.gui; activeCue=cue
				end
			end
			refreshCue(); task.delay(.2,refreshCue)
			if root then watcher=root.DescendantAdded:Connect(function(item) if item.Name==held.socketId then task.defer(refreshCue) end end) end
			container.Destroying:Connect(function()
				alive=false; if watcher then watcher:Disconnect() end
				if cue then cue:Destroy(); if activeCue==cue then activeCue=nil end end
			end)
			UI.Label(card,"ReservationHelp","Close, Put back, or leaving releases this selection. If it returns to its tray, simply pick it up again.",13).LayoutOrder=8
		elseif craft.needsFinishing then
			UI.Label(card,"PhuongFinish","Ready for Phuong · choose the lamp's final look at the bedroom keepsake. The petal is already saved.",16,UI.Palette.forest).LayoutOrder=5
		end
	end)
	registry.RegisterActivity("Q04",function(container,view,context)
		local UI=context.UI; UI.List(container,8); container.LayoutOrder=12
		local summary=view.readingSummary or {}; local draft=view.draft or {}
		local card=UI.Card(container,"ReadingSavedChoices","cream")
		UI.Label(card,"SavedTitle","Your saved reading choices",17,UI.Palette.forest).LayoutOrder=1
		UI.Label(card,"SavedSummary",((summary.highlights and #summary.highlights>0) and "✓ "..table.concat(summary.highlights,", ") or "○ Choose a highlight")
			.."\n"..(summary.reaction and "✓ "..summary.reaction or "○ Choose a reaction")
			.."\n"..(summary.bookmark and "✓ "..summary.bookmark or "○ Choose a bookmark"),15).LayoutOrder=2
		UI.Label(card,"SaveHelp","Each choice stays saved when you close. Save re]==]
return #_G.__PCW25ContractText