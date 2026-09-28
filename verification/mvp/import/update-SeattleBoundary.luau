local HttpService=game:GetService("HttpService")
local parent=assert(game:GetService("ServerStorage").PhuongMVPTools.builders);local old=assert(parent:FindFirstChild("SeattleBoundary"));assert(old:IsA("ModuleScript") and old:GetAttribute("PhuongMVPImportOwned"),"owned module required")
local expectedSource=HttpService:JSONDecode(HttpService:JSONEncode([=[-- Task 10 Seattle perimeter builder.
-- Run in Studio Edit mode by the designated integrator after Task 01 resolves live anchors.
-- Owns only CozyWorld_Draft01.MVP.MvpSeattleBoundary; no lighting, scripts, interiors, or gameplay.

return function(context)
	assert(context and context.Root and context.MVP and context.Anchors, "SeattleBoundary context is incomplete")
	assert(type(context.SafeReplace) == "function", "SeattleBoundary requires context.SafeReplace")
	local RunService = game:GetService("RunService")
	assert(not RunService:IsRunning(), "SeattleBoundary must be authored in Edit mode")

	local root = context.Root
	local mvp = context.MVP
	local anchors = context.Anchors
local required = { "GameplayBedroomArrival", "Q05UDistrictVending", "Q04QuadReading", "FinalePatio" }
for _, name in required do
	local marker = anchors[name] or (anchors.FindFirstChild and anchors:FindFirstChild(name, true))
	assert(marker and marker:IsA("BasePart"), "Missing live anchor: " .. name)
	assert(marker:GetAttribute("PlacementStatus") ~= "UNRESOLVED_LIVE_ANCHOR", "Unresolved live anchor: " .. name)
end

local palette = context.Palette or {
	forest = Color3.fromHex("365744"), sage = Color3.fromHex("A8B995"),
	cream = Color3.fromHex("F5F0E4"), wood = Color3.fromHex("95674B"),
	blossom = Color3.fromHex("E8B7C6"), brick = Color3.fromHex("B66C68"),
	golden = Color3.fromHex("E8C779"), ink = Color3.fromHex("26382E"),
}

	local stage = Instance.new("Folder")
stage.Name = "SeattleBoundary"
stage:SetAttribute("VerificationTicket", "PCW-03/MAP-02/MAP-03")
stage:SetAttribute("BuilderSource", "roblox/mvp/builders/SeattleBoundary.luau")
stage:SetAttribute("Status", "Static perimeter; Studio/device/group verification pending")
stage:SetAttribute("CollisionPolicy", "Visual-only; integrator owns any invisible world boundary")
stage:SetAttribute("SkylinePolicy", "Open upper sky band; no roof")
	stage:SetAttribute("Owner", "Task10")
	stage:SetAttribute("SourceBuilder", "SeattleBoundary")
	stage:SetAttribute("AnchorName", "WorldBoundsFromTask01")
	stage:SetAttribute("Footprint", "Derived outer facade ring; no playable interior")
	stage:SetAttribute("ApproachClearance", "Validated by Task13 against live routes")

local count = 0
local function part(name, size, cf, token, parent, material)
	assert(palette[token], "Unknown palette token: " .. tostring(token))
	local object = Instance.new("Part")
	object.Name = name
	object.Size = size
	object.CFrame = cf
	object.Color = palette[token]
	object.Material = material or Enum.Material.SmoothPlastic
	object.Anchored = true
	object.CanCollide = false
	object.CanTouch = false
	object.CanQuery = false
	object.CastShadow = false
	object.TopSurface = Enum.SurfaceType.Smooth
	object.BottomSurface = Enum.SurfaceType.Smooth
	object:SetAttribute("PaletteToken", token)
	object:SetAttribute("BoundaryOwner", "Task10")
	object:SetAttribute("VerificationTicket", "PCW-03/MAP-02/MAP-03")
	object:SetAttribute("MVPBuilder", "SeattleBoundary")
	object.Parent = parent
	count += 1
	return object
end

local function model(name, parent)
	local object = Instance.new("Model")
	object.Name = name
	object.Parent = parent
	return object
end

-- Prefer Task 01's frozen bounds. Otherwise derive them from original scene parts,
-- explicitly excluding all generated MVP geometry so reruns cannot expand the ring.
local supplied = context.Options and context.Options.WorldBounds
local minX, maxX, minZ, maxZ, centerY
if supplied then
	minX, maxX, minZ, maxZ, centerY = supplied.minX, supplied.maxX, supplied.minZ, supplied.maxZ, supplied.centerY
else
	local minVector = Vector3.new(math.huge, math.huge, math.huge)
	local maxVector = Vector3.new(-math.huge, -math.huge, -math.huge)
	local found = false
	for _, object in root:GetDescendants() do
		if object:IsA("BasePart") and not object:IsDescendantOf(mvp) then
			local p = object.Position
			local half = object.Size / 2
			minVector = Vector3.new(math.min(minVector.X, p.X - half.X), math.min(minVector.Y, p.Y - half.Y), math.min(minVector.Z, p.Z - half.Z))
			maxVector = Vector3.new(math.max(maxVector.X, p.X + half.X), math.max(maxVector.Y, p.Y + half.Y), math.max(maxVector.Z, p.Z + half.Z))
			found = true
		end
	end
	assert(found, "No original world BaseParts found for stable Seattle boundary bounds")
	minX, maxX, minZ, maxZ, centerY = minVector.X, maxVector.X, minVector.Z, maxVector.Z, (minVector.Y + maxVector.Y) / 2
end
assert(minX and maxX and minZ and maxZ and centerY, "WorldBounds must provide minX/maxX/minZ/maxZ/centerY")
local pad = 12
local y = centerY + 8
local wallHeight = 18
stage:SetAttribute("WorldBounds", string.format("%.2f,%.2f,%.2f,%.2f", minX, maxX, minZ, maxZ))
stage:SetAttribute("FacadeSetback", pad)

local function facadeRow(name, x, z, length, yaw, parent, variant)
	local row = model(name, parent)
	local segment = 28
	local pieces = math.max(1, math.ceil(length / segment))
	for i = 1, pieces do
		local along = (i - (pieces + 1) / 2) * (length / pieces)
		local base = CFrame.new(x, y + 8 + ((i + variant) % 3) * 1.5, z) * CFrame.Angles(0, yaw, 0) * CFrame.new(along, 0, 0)
		local width = length / pieces - 1
		part("Shell" .. i, Vector3.new(width, 16 + ((i + variant) % 3) * 3, 2.4), base, i % 2 == 0 and "cream" or "brick", row, Enum.Material.SmoothPlastic)
		part("Roofline" .. i, Vector3.new(width + .7, .65, 3.1), base * CFrame.new(0, 9.1 + ((i + variant) % 3) * 1.5, 0), "wood", row, Enum.Material.Wood)
		for window = -1, 1, 2 do
			part("Window" .. i .. "_" .. window, Vector3.new(2.6, 3.2, .18), base * CFrame.new(window * width * .22, 1.2, -1.28), "golden", row, Enum.Material.Neon)
		end
	end
	return row
end

local west = model("WestUDistrictBackdrop", stage)
facadeRow("WestFacade", minX - pad, (minZ + maxZ) / 2, maxZ - minZ, math.pi / 2, west, 1)
local north = model("NorthHouseJasperBackdrop", stage)
facadeRow("NorthFacade", (minX + maxX) / 2, minZ - pad, maxX - minX, 0, north, 2)
local east = model("EastQuadBackdrop", stage)
facadeRow("EastFacade", maxX + pad, (minZ + maxZ) / 2, maxZ - minZ, math.pi / 2, east, 3)
local south = model("SouthArrivalPatioBackdrop", stage)
facadeRow("SouthFacade", (minX + maxX) / 2, maxZ + pad, maxX - minX, 0, south, 4)

-- Low natural terminators mark the existing play boundary without implying doors or interiors.
local terminators = model("NaturalStreetTerminators", stage)
local stops = {
	{ "WestStop", Vector3.new(minX + 7, y + 3, minZ + 42), 0 },
	{ "EastStop", Vector3.new(maxX - 7, y + 3, maxZ - 42), math.pi / 2 },
	{ "SouthStop", Vector3.new(minX + 42, y + 3, maxZ - 7), 0 },
	{ "NorthStop", Vector3.new(maxX - 42, y + 3, minZ + 7), math.pi / 2 },
}
for _, stop in stops do
	local name, position, yaw = stop[1], stop[2], stop[3]
	local stopModel = model(name, terminators)
	part("Wall", Vector3.new(14, 6, 2.2), CFrame.new(position) * CFrame.Angles(0, yaw, 0), "brick", stopModel)
	part("Cap", Vector3.new(15, .55, 2.8), CFrame.new(position + Vector3.new(0, 3.25, 0)) * CFrame.Angles(0, yaw, 0), "cream", stopModel)
end

-- Two compressed skyline cues; narrow, noninteractive, and lower contrast than landmarks.
local skyline = model("CompressedSeattleSkyline", stage)
for i, spec in { { "TowerWest", minX - 30, minZ - 30, 52, 8 }, { "TowerEast", maxX + 30, maxZ + 30, 44, 7 } } do
	local name, x, z, height, width = spec[1], spec[2], spec[3], spec[4], spec[5]
	local tower = model(name, skyline)
	part("Body", Vector3.new(width, height, width), CFrame.new(x, y + height / 2 - 2, z), "forest", tower)
	part("Crown", Vector3.new(width + 2, 1.2, width + 2), CFrame.new(x, y + height - 1.4, z), "brick", tower)
	for window = 1, 3 do
		part("Window" .. window, Vector3.new(1.2, 3, .15), CFrame.new(x - width / 2 - .08, y + height * (window / 4), z - 1), "golden", tower, Enum.Material.Neon)
	end
end

assert(count <= 250, "Seattle boundary exceeds proposed 250 BasePart budget: " .. count)
local tokenCounts = {}
for _, object in stage:GetDescendants() do
	assert(not object:IsA("LuaSourceContainer"), "Scripts are forbidden in Seattle boundary")
	if object:IsA("BasePart") then
		local token = object:GetAttribute("PaletteToken")
		assert(palette[token] and object.Color == palette[token], "Palette mismatch: " .. object:GetFullName())
		assert(object.Anchored and not object.CanCollide and not object.CanTouch and not object.CanQuery, "Boundary must be noninteractive: " .. object:GetFullName())
		tokenCounts[token] = (tokenCounts[token] or 0) + 1
	end
end
stage:SetAttribute("PartCount", count)
for token, total in tokenCounts do stage:SetAttribute("PaletteCount_" .. token, total) end
local installed = context.SafeReplace("SeattleBoundary", function()
		return stage
	end)
	if installed then stage = installed end
	game:GetService("ChangeHistoryService"):SetWaypoint("MVP Seattle boundary staged")
	return {
		folder = stage,
		manifest = {
			Owner = "Task10",
			SourceBuilder = "SeattleBoundary",
			AnchorName = "WorldBoundsFromTask01",
			Footprint = "Derived outer facade ring; no playable interior",
			ApproachClearance = "Validated by Task13 against live routes",
			PartCount = count,
			WorldBounds = string.format("%.2f,%.2f,%.2f,%.2f", minX, maxX, minZ, maxZ),
			Segments = { "WestUDistrictBackdrop", "NorthHouseJasperBackdrop", "EastQuadBackdrop", "SouthArrivalPatioBackdrop", "NaturalStreetTerminators", "CompressedSeattleSkyline" },
			Status = "Live camera and route checks pending",
		},
	}
end
]=]));local n=Instance.new("ModuleScript");n.Name="SeattleBoundary";n:SetAttribute("PhuongMVPImportOwned",true);n:SetAttribute("PhuongMVPSourceSHA256","76B6827E49000B1C6486EAF519501157FF9BC0C81811A0A12AA188A0D73B4EA3");n.Source=expectedSource;assert(n.Source==expectedSource,"source readback mismatch");n.Parent=parent;old:Destroy();return true
