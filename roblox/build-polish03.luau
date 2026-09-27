-- Draft 03 static environment authoring. Run in Studio Edit mode after Draft 02.
-- Replaces only CozyWorld_Draft01.VisualPolish03 after the complete stage validates.
-- No imports, runtime scripts, world movement, lighting changes, or functional parts.
local RunService = game:GetService("RunService")
assert(not RunService:IsRunning(), "VisualPolish03 must be authored in Edit mode")
local root = workspace:WaitForChild("CozyWorld_Draft01")
local home = root:WaitForChild("Home")
local floor = home:WaitForChild("Floor")
assert(floor:IsA("BasePart"), "Expected Home.Floor placement anchor")
local V, CF = Vector3.new, CFrame.new
local worldOffset = floor.Position - V(-28, .12, -108)
local sourceName = "roblox/build-polish03.luau"
local P = {}
-- Exact approved values from verification/palette.json, not sampled from imagery.
for token, hex in {
	forest = "365744", sage = "A8B995", cream = "F5F0E4", wood = "95674B",
	blossom = "E8B7C6", brick = "B66C68", golden = "E8C779", ink = "26382E",
} do P[token] = Color3.fromHex(hex) end

local context = root:WaitForChild("SurroundingContext"):WaitForChild("NeighborhoodDetails02")
local stores = context:WaitForChild("Storefronts")
local park = context:WaitForChild("JasperDogPark")
local arrival = root:WaitForChild("Arrival")
local routeDefinitions = root:WaitForChild("Paths"):WaitForChild("RouteDefinitions")
local routes = {}
for _, definition in routeDefinitions:GetChildren() do
	local a, b, width = definition:GetAttribute("From"), definition:GetAttribute("To"), definition:GetAttribute("Width")
	assert(typeof(a) == "Vector3" and typeof(b) == "Vector3" and typeof(width) == "number", "Missing route metadata")
	table.insert(routes, {name = definition.Name, a = a - worldOffset, b = b - worldOffset, width = width})
end
assert(#routes >= 20, "Expected the reviewed Quad cross, diagonals and destination links")
-- The arrival plaza's final walking lane is an additional protected continuation.
table.insert(routes, {name = "ArrivalClearLane03", a = V(8, 0, 151), b = V(8, 0, 170), width = 10})

local function model(name, parent)
	local object = Instance.new("Model")
	object.Name = name
	object.Parent = parent
	return object
end

-- An unparented stage leaves the current scene intact if construction/checks fail.
local stage = Instance.new("Folder")
stage.Name = "VisualPolish03"
stage:SetAttribute("VerificationTicket", "MAP-03")
stage:SetAttribute("AuthoringVersion", "03")
stage:SetAttribute("BuilderSource", sourceName)
stage:SetAttribute("WorldOffset", worldOffset)
stage:SetAttribute("OwnedScope", "Low gardens, window boxes, shop accents and Jasper rest-corner decor")

local count = 0
local function part(name, size, placement, token, parent, material)
	assert(P[token], "Unknown palette token: " .. tostring(token))
	assert(not parent:FindFirstChild(name), "Duplicate stable name: " .. parent.Name .. "." .. name)
	local object = Instance.new("Part")
	object.Name = name
	object.Size = size
	object.CFrame = (typeof(placement) == "CFrame" and placement or CF(placement)) + worldOffset
	object.Color = P[token]
	object:SetAttribute("PaletteToken", token)
	object.Material = material or Enum.Material.SmoothPlastic
	object.Anchored = true
	object.CanCollide = false
	object.CanTouch = false
	object.CanQuery = false
	object.CastShadow = false
	object.TopSurface = Enum.SurfaceType.Smooth
	object.BottomSurface = Enum.SurfaceType.Smooth
	object.Parent = parent
	count += 1
	return object
end

local function ellipsoid(name, size, placement, token, parent, material)
	local object = part(name, size, placement, token, parent, material)
	-- A native sphere mesh respects these three independent silhouette dimensions.
	-- Part.Shape Ball would turn thin petals/leaves into unwanted round masses.
	local mesh = Instance.new("SpecialMesh")
	mesh.Name = "NativeEllipsoid"
	mesh.MeshType = Enum.MeshType.Sphere
	mesh.Scale = V(1, 1, 1)
	mesh.Parent = object
	return object
end

local function cylinder(name, radius, height, position, token, parent)
	local object = part(name, V(height, radius * 2, radius * 2), CF(position) * CFrame.Angles(0, 0, math.pi / 2), token, parent)
	object.Shape = Enum.PartType.Cylinder
	return object
end

local function flower(name, parent, position, height, token, angle, scale)
	local cluster = model(name, parent)
	local base = CF(position) * CFrame.Angles(0, angle, 0)
	local s = scale or 1
	part("Stem", V(.10 * s, height, .10 * s), base * CF(0, height / 2, 0), "forest", cluster)
	for i, side in {-1, 1} do
		ellipsoid("StemLeaf" .. i, V(.82 * s, .12 * s, .32 * s),
			base * CF(side * .32 * s, height * (.43 + i * .06), 0) * CFrame.Angles(0, side * .3, side * .32),
			i == 1 and "forest" or "sage", cluster)
	end
	for i = 1, 5 do
		local a = (i - 1) * math.pi * 2 / 5
		ellipsoid("Petal" .. i, V(.53 * s, .14 * s, .85 * s),
			base * CF(math.cos(a) * .33 * s, height, math.sin(a) * .33 * s)
				* CFrame.Angles(0, math.pi / 2 - a, .05 * (i % 2)), token, cluster)
	end
	ellipsoid("GoldenCenter", V(.33 * s, .19 * s, .33 * s), base * CF(0, height + .055 * s, 0), "golden", cluster)
end

-- Forty-one parts per bed: soil, six edge stones, seven overlapping leaves,
-- and three nine-part flowers. Every cluster is deterministic and deliberately low.
local function gardenBed(name, parent, x, z, width, depth, yaw, variant)
	local bed = model(name, parent)
	local base = CF(x, .075, z) * CFrame.Angles(0, math.rad(yaw), 0)
	bed:SetAttribute("DetailType", "LayeredLowPlanting")
	ellipsoid("Mulch", V(width, .14, depth), base * CF(0, .035, 0), "wood", bed, Enum.Material.Ground)
	for i = 1, 6 do
		local a = (i - 1) * math.pi / 3 + .14 * variant
		ellipsoid("EdgeStone" .. i, V(.78 + .10 * (i % 2), .25, .52),
			base * CF(math.cos(a) * width * .43, .075, math.sin(a) * depth * .42)
				* CFrame.Angles(0, -a, 0), "cream", bed)
	end
	for i = 1, 7 do
		local a = i * 2.39996 + variant * .61
		local r = i % 3 == 0 and .14 or .27
		ellipsoid("LowLeaf" .. i, V(width * .32, .30 + .055 * (i % 3), depth * .21),
			base * CF(math.cos(a) * width * r, .29 + .045 * (i % 2), math.sin(a) * depth * r)
				* CFrame.Angles(.08 * (i % 2), -a, .11 * ((i % 3) - 1)),
			i % 3 == 0 and "sage" or "forest", bed)
	end
	for i, site in {{-.28, .05}, {.01, -.18}, {.28, .11}} do
		local point = (base * CF(site[1] * width, .14, site[2] * depth)).Position
		flower("Flower" .. i, bed, point, .98 + .16 * ((i + variant) % 3),
			(i + variant) % 3 == 0 and "cream" or "blossom", variant * .31 + i * .47, .96 + .06 * (i % 2))
	end
	return bed
end

local function windowBox(name, parent, glass, width, variant)
	local box = model(name, parent)
	-- The original front glass and its sill locate each box, even after translation.
	local p = glass.Position - worldOffset
	-- Seat the brackets into the existing wall face; keep foliage in front of glass.
	local base = CF(p.X, 2.92, p.Z + .85)
	part("PaintedBox", V(width, .86, 1.32), base, "sage", box)
	part("Soil", V(width - .35, .09, 1.06), base * CF(0, .46, 0), "wood", box, Enum.Material.Ground)
	part("FrontLip", V(width + .18, .16, .16), base * CF(0, .47, .68), "cream", box)
	part("BackLip", V(width + .18, .16, .16), base * CF(0, .47, -.68), "cream", box)
	for i, side in {-1, 1} do
		part("Bracket" .. i, V(.23, .55, 1.75), base * CF(side * width * .32, -.48, -.53), "wood", box, Enum.Material.Wood)
	end
	part("FrontInset", V(width - .5, .20, .08), base * CF(0, -.07, .71), "forest", box)
	for i = 1, 4 do
		ellipsoid("TrailingLeaf" .. i, V(1.0, .14, .46),
			base * CF((i - 2.5) * width / 4.4, .47 - .10 * (i % 2), .53)
				* CFrame.Angles(-.48, .23 * (i % 2), .08), i % 2 == 0 and "sage" or "forest", box)
	end
	for i = 1, 3 do
		flower("WindowFlower" .. i, box, (base * CF((i - 2) * width * .29, .50, .40)).Position,
			.69 + .10 * ((i + variant) % 3), i == 2 and "cream" or "blossom", i * .61, .83)
	end
end

local function shopPlanter(name, parent, position, token, variant)
	local pot = model(name, parent)
	cylinder("PaintedPot", .82, 1.24, position + V(0, .62, 0), token, pot)
	cylinder("PaleRim", .94, .19, position + V(0, 1.24, 0), "cream", pot)
	cylinder("Soil", .76, .08, position + V(0, 1.37, 0), "wood", pot)
	for i = 1, 4 do
		local a = i * math.pi / 2 + variant * .24
		ellipsoid("UprightLeaf" .. i, V(.40, 1.03, .70),
			CF(position + V(math.cos(a) * .32, 1.61, math.sin(a) * .32)) * CFrame.Angles(math.sin(a) * .32, a, math.cos(a) * .32),
			i % 2 == 0 and "sage" or "forest", pot)
	end
	flower("AccentFlower", pot, position + V(.08, 1.40, -.03), .91, variant % 2 == 0 and "cream" or "blossom", variant * .71, .82)
end

local function paw(name, parent, x, z, yaw)
	local motif = model(name, parent)
	local base = CF(x, .13, z) * CFrame.Angles(0, math.rad(yaw), 0)
	ellipsoid("Pad", V(.94, .045, .80), base, "wood", motif)
	for i, p in {{-.49, -.37}, {-.19, -.64}, {.19, -.64}, {.49, -.37}} do
		ellipsoid("Toe" .. i, V(.32, .045, .39), base * CF(p[1], 0, p[2]) * CFrame.Angles(0, (i - 2.5) * -.16, 0), "wood", motif)
	end
end

-- Physical, original landmarks supply the composition origins; no old object changes.
local sign = arrival:WaitForChild("BirthdaySign"):WaitForChild("GreenFrame")
local signPosition = sign.Position - worldOffset
local porch = home:WaitForChild("PorchDeck")
local porchPosition = porch.Position - worldOffset
local gardens = model("ArrivalAndPorchGardens", stage)
gardenBed("SignLeftBed", gardens, signPosition.X - 8, signPosition.Z + 7, 9, 4.2, -8, 1)
gardenBed("SignRightBed", gardens, signPosition.X + 7, signPosition.Z + 7, 8, 4.2, 10, 2)
gardenBed("PorchWestBed", gardens, porchPosition.X - 34, porchPosition.Z + 3, 8, 4.2, -7, 3)
gardenBed("PorchEastBed", gardens, porchPosition.X + 36, porchPosition.Z + 3, 8, 4.2, 8, 4)

local boxes = model("CottageWindowBoxes", stage)
local windows = {}
for _, object in home:GetChildren() do
	if object.Name:match("^WindowGlass") and object:IsA("BasePart") then table.insert(windows, object) end
end
table.sort(windows, function(a, b) return a.Position.X < b.Position.X end)
assert(#windows == 2, "Expected the two reviewed front cottage windows")
for i, glass in windows do
	windowBox(i == 1 and "WestWindowBox" or "EastWindowBox", boxes, glass, glass.Size.X - 3, i)
end

-- Compact islands sit beside four existing reading areas, beyond route edges.
-- Their sites are fixed relative to the preserved floor anchor, not to model pivots.
local quad = model("QuadSittingGardens", stage)
for i, site in {{-51, -52.5, -8}, {24, 22, 7}, {-45, 50, -12}, {27, 122, 9}} do
	gardenBed("ReadingIsland" .. i, quad, site[1], site[2], 7, 3.8, site[3], i + 4)
end

local shopDetails = model("StorefrontFinishing", stage)
local keepouts = {
	{name = "CottageDoorApproach", x1 = -26, x2 = -14, z1 = -86, z2 = -66},
	{name = "ParkUpperGate", x1 = 68, x2 = 89, z1 = -97, z2 = -87},
	{name = "ParkLowerGate", x1 = 68, x2 = 89, z1 = -57, z2 = -47},
	{name = "ParkFetchCenter", x1 = 89, x2 = 145, z1 = -121, z2 = -62},
}
for i, specification in {{"FOB", "forest"}, {"HeyTea", "forest"}, {"Aladdins", "brick"}} do
	local shop = stores:WaitForChild(specification[1])
	local doorPosition = shop:GetAttribute("DoorCenter")
	assert(typeof(doorPosition) == "Vector3", "Expected unchanged shop DoorCenter metadata")
	local door = doorPosition - worldOffset
	local z = door.Z - 17
	local details = model(specification[1], shopDetails)
	shopPlanter("DoorstepFlowers", details, V(door.X + 2.15, .35, door.Z - 7), specification[2], i)
	shopPlanter("DisplaySideFlowers", details, V(door.X + 2.15, .35, z - 17), specification[2], i + 1)
	part("ApronPinstripe", V(.12, .18, 30), V(door.X + .29, .85, z - 7.5), "cream", details)
	for j, dz in {-21, 6} do
		part("ApronEndAccent" .. j, V(.14, 1.05, .27), V(door.X + .31, 1.7, z + dz), "golden", details)
	end
	for j, dz in {-24, 24} do
		part("CorniceEndBlock" .. j, V(.80, .48, 1.4), V(door.X + .65, 18.0, z + dz), "cream", details)
	end
	table.insert(keepouts, {name = specification[1] .. "DoorApproach", x1 = door.X - 8.5, x2 = -134, z1 = door.Z - 4.5, z2 = door.Z + 4.5})
end

-- Locate the existing north bench by its actual seat positions, retaining all seats.
local northSeat
for _, object in park:GetDescendants() do
	if object:IsA("Seat") and (not northSeat or object.Position.Z < northSeat.Position.Z) then northSeat = object end
end
assert(northSeat, "Expected Jasper park's reviewed north bench")
local northBench = northSeat.Parent
local seatSum, seatCount = V(0, 0, 0), 0
for _, object in northBench:GetDescendants() do
	if object:IsA("Seat") then seatSum += object.Position; seatCount += 1 end
end
local benchCenter = seatSum / seatCount - worldOffset
local rest = model("JasperRestCorner", stage)
ellipsoid("RestCornerInset", V(24, .06, 10), V(benchCenter.X + 5, .08, benchCenter.Z - .6), "cream", rest)
gardenBed("BehindBenchBed", rest, benchCenter.X, benchCenter.Z - 4.7, 8, 3.4, 0, 9)
gardenBed("SideGarden", rest, benchCenter.X + 12, benchCenter.Z - 1.7, 7, 3.8, -9, 10)
for i, p in {{14, 2, -56}, {10.9, 3.8, -67}, {7.4, 5.1, -78}, {4, 5.7, -83}} do
	paw("PawMotif" .. i, rest, benchCenter.X + p[1], benchCenter.Z + p[2], p[3])
end

local function distanceToRoute(point, route)
	local a, b = Vector2.new(route.a.X, route.a.Z), Vector2.new(route.b.X, route.b.Z)
	local direction = b - a
	local t = math.clamp((point - a):Dot(direction) / direction:Dot(direction), 0, 1)
	return (point - (a + direction * t)).Magnitude
end

-- Validate the complete staged content before replacing any owned scene object.
local actualCount, usedPaths, tokenCounts = 0, {}, {}
for _, object in stage:GetDescendants() do
	assert(not object:IsA("LuaSourceContainer"), "Source containers are forbidden in visual decor")
	assert(object:IsA("Model") or object:IsA("Part") or object:IsA("SpecialMesh"), "Unexpected decor instance: " .. object.ClassName)
	local path = object:GetFullName()
	assert(not usedPaths[path], "Duplicate stable full path: " .. path)
	usedPaths[path] = true
	if object:IsA("SpecialMesh") then
		assert(object.MeshType == Enum.MeshType.Sphere and object.MeshId == "" and object.TextureId == "", "Only untextured native sphere meshes are allowed")
	elseif object:IsA("BasePart") then
		actualCount += 1
		local token = object:GetAttribute("PaletteToken")
		assert(P[token] and object.Color == P[token], "Exact palette mismatch: " .. path)
		assert(object.Anchored and not object.CanCollide and not object.CanTouch and not object.CanQuery, "Decor must remain static and noninteractive: " .. path)
		assert(object.MaterialVariant == "", "Custom material variants are not permitted")
		tokenCounts[token] = (tokenCounts[token] or 0) + 1
		local point = object.Position - worldOffset
		local right, up, look, half = object.CFrame.RightVector, object.CFrame.UpVector, object.CFrame.LookVector, object.Size / 2
		local hx = math.abs(right.X) * half.X + math.abs(up.X) * half.Y + math.abs(look.X) * half.Z
		local hz = math.abs(right.Z) * half.X + math.abs(up.Z) * half.Y + math.abs(look.Z) * half.Z
		local radius = math.sqrt(hx * hx + hz * hz)
		for _, route in routes do
			assert(distanceToRoute(Vector2.new(point.X, point.Z), route) - radius >= route.width / 2 + .55,
				"Decor encroaches on route " .. route.name .. ": " .. path)
		end
		for _, zone in keepouts do
			assert(point.X + hx <= zone.x1 or point.X - hx >= zone.x2 or point.Z + hz <= zone.z1 or point.Z - hz >= zone.z2,
				"Decor enters protected approach/activity space " .. zone.name .. ": " .. path)
		end
	end
end
assert(actualCount == count and count == 618, "Unexpected deterministic part count: " .. count .. "/" .. actualCount)
assert(count <= 750, "VisualPolish03 exceeds its 750 BasePart budget")
stage:SetAttribute("PartCount", count)
stage:SetAttribute("RouteDefinitionCount", #routes - 1)
stage:SetAttribute("MinimumRouteBorderGap", .55)
for token, total in tokenCounts do stage:SetAttribute("PaletteCount_" .. token, total) end

local previous = root:FindFirstChild("VisualPolish03")
if previous then
	assert(previous:IsA("Folder") and previous:GetAttribute("BuilderSource") == sourceName, "Refusing to replace an unrecognized VisualPolish03 owner")
	previous:Destroy()
end
stage.Parent = root
game:GetService("ChangeHistoryService"):SetWaypoint("Draft 03 low gardens and environment polish")
return "VisualPolish03 installed: " .. count .. " anchored, noninteractive exact-palette parts; ten low beds, two window boxes, six shop planters, three facade accents and Jasper rest corner. Offset preserved: " .. tostring(worldOffset)
