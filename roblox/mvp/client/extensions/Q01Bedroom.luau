-- Optional PCW-18 presentation extension. Server descriptors remain authoritative.
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
