-- PCW-19 owns this runtime presentation and narrowly selected bed details only.
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
