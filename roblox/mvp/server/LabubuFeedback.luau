-- Owns only runtime previews/result/collection. It never invokes a world builder.
local Catalog = require(script.Parent.Parent.shared.FigureCatalog)
local Presentation = require(script.Parent.Parent.shared.FigurePresentation)
local LabubuFeedback = {}; LabubuFeedback.__index = LabubuFeedback
local function folder(parent, name)
	local value = Instance.new("Folder"); value.Name = name; value.Parent = parent; return value
end
local function caption(parent, name, cf, width, text, back)
	local plate = Presentation.Part(parent, name, Vector3.new(width, .23, .035), cf, "cream")
	local gui = Instance.new("SurfaceGui")
	gui.Name, gui.Face, gui.CanvasSize = "FigureLabel", back and Enum.NormalId.Back or Enum.NormalId.Front, Vector2.new(260, 70)
	gui.Parent = plate
	local label = Instance.new("TextLabel")
	label.Name, label.Size, label.BackgroundTransparency = "Caption", UDim2.fromScale(1, 1), 1
	label.Font, label.TextScaled, label.TextWrapped = Enum.Font.GothamBold, true, true
	label.TextColor3, label.Text, label.Parent = Presentation.Palette.ink, text, gui
	return label
end
function LabubuFeedback.new(root, mvp, anchors)
	local runtime = mvp:FindFirstChild("RuntimePresentation") or folder(mvp, "RuntimePresentation")
	assert(not runtime:FindFirstChild("LabubuFeedback"), "LabubuFeedback is already running")
	local owned = folder(runtime, "LabubuFeedback"); owned:SetAttribute("VerificationTicket", "PCW-21")
	local self = setmetatable({ root = owned, hidden = {}, previews = {}, collectionLabels = {} }, LabubuFeedback)
	self.machine = folder(owned, "Machine"); self.resultRoot = folder(owned, "LatestResult")
	self.collectionRoot = folder(owned, "BedroomCollection"); self.ownedFigures = folder(self.collectionRoot, "OwnedFigures")
	local machine = anchors.Q05UDistrictVending
	if machine and machine:IsA("BasePart") then
		self.machineFrame = machine.CFrame
		local stations = mvp:FindFirstChild("Stations")
		local cabinet = stations and stations:FindFirstChild("Q05Station")
		for index, entry in ipairs(Catalog.Figures) do
			-- The saved FigureSlot markers are rectangles. Hide only those exact
			-- placeholders at runtime, retaining restorable authored properties.
			local marker = cabinet and cabinet:FindFirstChild("FigureSlot" .. index, true)
			if marker and marker:IsA("BasePart") then self.hidden[marker] = marker.Transparency; marker.Transparency = 1 end
			local x = (index - 4) * .62
			local toy = Presentation.Build(entry.id, .4)
			toy.Name = "Preview" .. index; toy.Parent = self.machine
			toy:PivotTo(machine.CFrame * CFrame.new(x, 4.35, -1.46))
			self.previews[entry.id] = caption(self.machine, "Label" .. index, machine.CFrame * CFrame.new(x, 4.14, -1.67), .6, entry.label)
		end
		local cue = Presentation.Part(self.machine, "ResultCue", Vector3.new(.1, .1, .1), machine.CFrame * CFrame.new(0, 8, -.1), "forest")
		cue.Transparency = 1
		local board = Instance.new("BillboardGui")
		board.Name, board.Size, board.MaxDistance, board.AlwaysOnTop = "SharedWish", UDim2.fromOffset(300, 104), 32, false
		board.Adornee, board.Parent = cue, cue
		local text = Instance.new("TextLabel")
		text.Name, text.Size, text.BorderSizePixel, text.Font, text.TextSize = "WishAndResult", UDim2.fromScale(1, 1), 0, Enum.Font.GothamMedium, 14
		text.BackgroundColor3, text.TextColor3, text.TextWrapped, text.Parent = Presentation.Palette.cream, Presentation.Palette.ink, true, board
		self.machineText = text
	else warn("PCW-21 vending anchor unavailable; shared figure state remains available in the UI") end
	local home = root:FindFirstChild("Home")
	local bedroom = home and home:FindFirstChild("Bedroom")
	local bookcase = bedroom and bedroom:FindFirstChild("FilledBookcase")
	local shelves = {}
	if bookcase then
		for _, item in ipairs(bookcase:GetChildren()) do
			if item:IsA("BasePart") and (item.Name == "Shelf" or string.match(item.Name, "^Shelf_%d+$")) then table.insert(shelves, item) end
		end
	end
	table.sort(shelves, function(a, b) return a.Position.Y < b.Position.Y end)
	-- The fourth shelf carries craft jars behind its front edge. Our shallow
	-- exterior ledge projects .675 studs beyond that edge, below the fifth shelf.
	-- Q01 owns the very top; Q03/miniature owns the lower shelf. Neither is moved.
	local shelf = #shelves >= 6 and shelves[4] or nil
	if shelf then
		self.shelfFrame = shelf.CFrame * CFrame.new(0, shelf.Size.Y / 2 + .04, shelf.Size.Z / 2 + .35)
		Presentation.Part(self.collectionRoot, "CollectionLedge", Vector3.new(7.2, .1, .65), self.shelfFrame, "wood")
		self.collectionRoot:SetAttribute("OwnedRegion", "Fourth shelf front extension; Q01 top and Q03 lower shelf untouched")
		for index, entry in ipairs(Catalog.Figures) do
			self.collectionLabels[entry.id] = caption(self.collectionRoot, "CollectionLabel" .. index,
				self.shelfFrame * CFrame.new((index - 4) * 1, -.08, .35), .94, entry.label .. " ×0", true)
		end
	else warn("PCW-21 bedroom shelf unavailable; collection remains saved and visible in the UI") end
	self:Render(nil, false, {}, nil, false)
	return self
end
function LabubuFeedback:Render(wanted, fulfilled, collection, latest, storyComplete)
	self.root:SetAttribute("WantedFigureId", wanted); self.root:SetAttribute("WishFulfilled", fulfilled)
	self.root:SetAttribute("StoryComplete", storyComplete)
	if self.machineText then
		self.machineText.Text = (storyComplete and "Wish complete · more collecting is optional" or "Friends earn together · Phuong chooses")
			.. "\nWish · " .. Catalog.Label(wanted)
			.. "\n" .. (latest and "Latest · " .. Catalog.Label(latest.awardFigureId) .. " · saved to the bedroom collection" or "20 per box · selected wish by box five")
	end
	for _, entry in ipairs(Catalog.Figures) do
		local label = self.previews[entry.id]
		if label then label.Text = (wanted == entry.id and "✓ " or "") .. entry.label end
		local shelfLabel = self.collectionLabels[entry.id]
		if shelfLabel then shelfLabel.Text = entry.label .. " ×" .. tostring(collection[entry.id] or 0) end
	end
	local receiptId = latest and latest.receiptId
	-- Selection changes only captions; an awarded box rebuilds bounded models.
	if receiptId == self.lastReceipt then return end
	self.lastReceipt = receiptId
	self.resultRoot:ClearAllChildren(); self.ownedFigures:ClearAllChildren()
	if latest and self.machineFrame then
		local figure = Presentation.Build(latest.awardFigureId, .72)
		figure.Name = "AwardedFigure"; figure:SetAttribute("ReceiptId", receiptId); figure.Parent = self.resultRoot
		figure:PivotTo(self.machineFrame * CFrame.new(.7, 1.63, -1.37))
		local capsule = Presentation.Capsule(.53, true); capsule.Parent = self.resultRoot
		capsule:PivotTo(self.machineFrame * CFrame.new(-1.2, 1.63, -1.3))
		caption(self.resultRoot, "ResultLabel", self.machineFrame * CFrame.new(0, 1.38, -1.7), 3.4, "Latest · " .. Catalog.Label(latest.awardFigureId))
	end
	if self.shelfFrame then
		for index, entry in ipairs(Catalog.Figures) do
			if (collection[entry.id] or 0) > 0 then
				local figure = Presentation.Build(entry.id, .4)
				figure.Name = "Collected" .. index; figure:SetAttribute("Copies", collection[entry.id]); figure.Parent = self.ownedFigures
				figure:PivotTo(self.shelfFrame * CFrame.new((index - 4) * 1, .055, 0) * CFrame.Angles(0, math.pi, 0))
			end
		end
	end
end
function LabubuFeedback:Destroy()
	for part, transparency in pairs(self.hidden) do if part.Parent then part.Transparency = transparency end end
	self.root:Destroy()
end
return LabubuFeedback
