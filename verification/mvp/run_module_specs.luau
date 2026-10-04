-- GENERATED TEST-ONLY ADAPTER. Do not install in Roblox.
-- It loads original source strings and supplies synthetic ModuleScript nodes.
local sources = {
    ["roblox/mvp/build-world.luau"] = [=[-- Edit-mode anchor builder. Creates/updates only MVP.Anchors; never destroys MVP or world content.
local root = assert(workspace:FindFirstChild("CozyWorld_Draft01"), "Existing CozyWorld_Draft01 is required")
local mvp = root:FindFirstChild("MVP") or Instance.new("Folder")
mvp.Name = "MVP"; mvp:SetAttribute("Source", "roblox/mvp/build-world.luau"); mvp.Parent = root
local anchors = mvp:FindFirstChild("Anchors") or Instance.new("Folder")
anchors.Name = "Anchors"; anchors.Parent = mvp
local names = {"GameplayBedroomArrival","Q01Bed","JasperBedroomStart","JasperFetchYard","Q03FairCraft","Q03BedroomDisplay","Q04QuadReading","Q04BedroomKindle","Q05UDistrictVending","Q06FOBCounter","Q06AladdinsCounter","Q06Serving","FinalePatio","BirthdayLobbyQueue"}
for _, name in names do
    local marker = anchors:FindFirstChild(name) or Instance.new("Part")
    marker.Name = name; marker.Size = marker.Size.Magnitude > 0 and marker.Size or Vector3.new(1,.15,1)
    marker.Anchored = true; marker.CanCollide = false; marker.CanTouch = false; marker.CanQuery = true; marker.Transparency = 1
    marker:SetAttribute("PlacementStatus", marker:GetAttribute("PlacementStatus") or "UNRESOLVED_LIVE_ANCHOR"); marker.Parent = anchors
end
print("MVP anchor subtree updated; unresolved anchors remain rejected by resolver")
]=],
    ["roblox/mvp/builders/CakeFinale.luau"] = [=[-- Edit-mode builder for the two missing end seats at the existing birthday table.
-- Requiring this module has no live-world side effects; the integrator invokes
-- the returned function with the shared builder context.

return function(context)
    assert(context and context.Root and context.MVP and context.Anchors and context.Palette,
        "CakeFinale context requires Root, MVP, Anchors and Palette")
    assert(context.SafeReplace, "CakeFinale requires SafeReplace")
    local patioMarker = assert(context.Anchors.FinalePatio, "FinalePatio anchor is required")
    local courtyard = patioMarker:FindFirstAncestor("BirthdayCourtyard")
        or context.Root:FindFirstChild("BirthdayCourtyard", true)
    assert(courtyard, "Existing BirthdayCourtyard is required")
    local gatheringTable = assert(courtyard:FindFirstChild("GatheringTable", true), "Existing GatheringTable is required")
    assert(gatheringTable:IsA("BasePart"), "GatheringTable must be a BasePart")
    local cake = assert(courtyard:FindFirstChild("BirthdayCake", true), "Existing BirthdayCake is required")
    local existingSeats = {}
    for _, object in courtyard:GetDescendants() do
        if object:IsA("Seat") or object:IsA("VehicleSeat") then table.insert(existingSeats, object) end
    end
    assert(#existingSeats == 8, "CakeFinale expects exactly 8 existing seats; found " .. #existingSeats)
    local seatHeight = existingSeats[1].Position.Y
    local tableHalfX = gatheringTable.Size.X / 2
    local seatOffset = tableHalfX + 4
    local V, CF = Vector3.new, CFrame.new
    local candidates = {
        {name = "EndSeatWest", sign = -1},
        {name = "EndSeatEast", sign = 1},
    }

    local function candidateCFrame(sign)
        local localPosition = V(sign * seatOffset, seatHeight - gatheringTable.Position.Y, 0)
        return gatheringTable.CFrame * CF(localPosition) * CFrame.Angles(0, sign * math.pi / 2, 0)
    end

    local overlapParams = OverlapParams.new()
    overlapParams.FilterType = Enum.RaycastFilterType.Exclude
    overlapParams.FilterDescendantsInstances = {courtyard, context.MVP}
    for _, candidate in candidates do
        local seatCFrame = candidateCFrame(candidate.sign)
        local blockers = workspace:GetPartBoundsInBox(seatCFrame, V(3, 4, 3), overlapParams)
        assert(#blockers == 0, "CakeFinale seat conflict before mutation: " .. candidate.name)
    end

    for _, token in {"forest", "sage", "cream", "wood", "blossom", "brick", "golden", "ink"} do
        assert(context.Palette[token], "CakeFinale missing palette token: " .. token)
    end

    local folder = Instance.new("Folder")
    folder.Name = "CakeFinale"
    folder:SetAttribute("Owner", "Task09")
    folder:SetAttribute("MVPBuilder", "CakeFinale")
    folder:SetAttribute("SourceBuilder", "roblox/mvp/builders/CakeFinale.luau")
    folder:SetAttribute("VerificationTicket", "PCW-14")
    folder:SetAttribute("Status", "Source authored; Studio collision/route verification pending")
    folder:SetAttribute("Preserves", "BirthdayCourtyard.BirthdayCake, GatheringTable, and 8 existing seats")
    folder:SetAttribute("SeatCountAdded", 2)
    folder:SetAttribute("SeatCountExpected", 10)

    local seatManifest = {}
    local function makePart(name, size, cframe, token, parent, canCollide)
        local part = Instance.new("Part")
        part.Name = name
        part.Size = size
        part.CFrame = cframe
        part.Color = context.Palette[token]
        part:SetAttribute("PaletteToken", token)
        part:SetAttribute("Owner", "Task09")
        part:SetAttribute("MVPBuilder", "CakeFinale")
        part:SetAttribute("VerificationTicket", "PCW-14")
        part:SetAttribute("SourceBuilder", "roblox/mvp/builders/CakeFinale.luau")
        part.Anchored = true
        part.CanCollide = canCollide
        part.CanTouch = canCollide
        part.CanQuery = canCollide
        part.Parent = parent
        return part
    end

    for _, candidate in candidates do
        local model = Instance.new("Model")
        model.Name = candidate.name
        model:SetAttribute("Owner", "Task09")
        model:SetAttribute("Interaction", "OptionalEatOrSit")
        model:SetAttribute("ApproachRule", "Voluntary walk; no auto-warp or camera lock")
        model.Parent = folder
        local seatCFrame = candidateCFrame(candidate.sign)
        local seat = Instance.new("Seat")
        seat.Name = "Seat"
        seat.Size = V(2, 0.4, 2)
        seat.CFrame = seatCFrame
        seat.Color = context.Palette.wood
        seat:SetAttribute("PaletteToken", "wood")
        seat:SetAttribute("Owner", "Task09")
        seat:SetAttribute("MVPBuilder", "CakeFinale")
        seat:SetAttribute("VerificationTicket", "PCW-14")
        seat:SetAttribute("SourceBuilder", "roblox/mvp/builders/CakeFinale.luau")
        seat:SetAttribute("AnchorName", "FinalePatio")
        seat.Anchored = true
        seat.Parent = model
        makePart("Back", V(2, 2.2, 0.35), seatCFrame * CF(0, 1.1, 0.8), "sage", model, true)
        table.insert(seatManifest, "BirthdayCourtyard.CakeFinale." .. candidate.name .. ".Seat")
    end

    local installed = context.SafeReplace("CakeFinale", function()
        return folder
    end)
    return {
        folder = installed,
        manifest = {
            name = "CakeFinale",
            sourceBuilder = "roblox/mvp/builders/CakeFinale.luau",
            preserved = {"BirthdayCourtyard.BirthdayCake", "BirthdayCourtyard.GatheringTable", "8 existing Seat instances"},
            addedSeatReferences = seatManifest,
            expectedTotalSeats = 10,
            tableDerivedSeatOffset = seatOffset,
            tableDerivedSeatHeight = seatHeight,
            runtimeHooks = {"FinalePatio proximity", "CakeService Invite/CancelInvite/Cut/Eat"},
            pendingEngineChecks = {"route clearance", "collision overlap", "ten-player seating", "post-cut free play"},
        },
    }
end
]=],
    ["roblox/mvp/builders/GrassDecoration.luau"] = [=[-- Grass and outer-Quad decoration builder.
-- Requiring this ModuleScript is side-effect free. The integrator invokes the
-- returned function with the shared context in Studio Edit mode.
-- This builder never edits Paths or the existing QuadPlanting tree set.

return function(context)
    assert(context and context.Root and context.MVP and context.Anchors and context.Palette,
        "GrassDecoration context requires Root, MVP, Anchors and Palette")
    assert(context.SafeReplace, "GrassDecoration requires SafeReplace")
    local options = assert(context.Options, "GrassDecoration Options are required")
    assert(options.OuterQuadBounds, "Task01 OuterQuadBounds anchor is required")
    assert(options.Keepouts, "Task01 activity/facade Keepouts are required")
    local root = context.Root
    local mvp = context.MVP
    local anchors = context.Anchors
    local palette = context.Palette
    for _, name in {"Q03FairCraft", "Q04QuadReading", "Q05UDistrictVending", "Q06FOBCounter", "Q06AladdinsCounter", "FinalePatio", "JasperFetchYard", "GameplayBedroomArrival"} do
        local anchor = anchors[name]
        assert(anchor, "Required station/route anchor missing: " .. name)
        assert(anchor:GetAttribute("PlacementStatus") ~= "UNRESOLVED_LIVE_ANCHOR", "Unresolved anchor: " .. name)
    end
    local RunService = game:GetService("RunService")
    assert(not RunService:IsRunning(), "GrassDecoration must run in Studio Edit mode")
    local paths = assert(root:FindFirstChild("Paths"), "Existing Quad Paths are required")
    local landscape = assert(root:FindFirstChild("Landscape"), "Existing Landscape is required")
    local lawn = assert(landscape:FindFirstChild("QuadGround"), "Existing QuadGround is required")
    assert(lawn:IsA("BasePart"), "QuadGround must be a BasePart")

    local V, CF = Vector3.new, CFrame.new
    local expectedPalette = {

    forest = Color3.fromHex("365744"),
    sage = Color3.fromHex("A8B995"),
    cream = Color3.fromHex("F5F0E4"),
    wood = Color3.fromHex("95674B"),
    blossom = Color3.fromHex("E8B7C6"),
    brick = Color3.fromHex("B66C68"),
    golden = Color3.fromHex("E8C779"),
    ink = Color3.fromHex("26382E"),
    }
    for token, color in expectedPalette do
        assert(palette[token] == color, "Shared palette mismatch for " .. token)
    end

local function sourcePartCount(instance)
    local count = 0
    for _, object in instance:GetDescendants() do
        if object:IsA("BasePart") then count += 1 end
    end
    return count
end

local function routeDefinitions()
    local metadata = paths:FindFirstChild("RouteDefinitions")
    assert(metadata, "RouteDefinitions are required; no guessed routes are allowed")
    local result = {}
    for _, definition in metadata:GetChildren() do
        local from = definition:GetAttribute("From")
        local to = definition:GetAttribute("To")
        local width = definition:GetAttribute("Width")
        if typeof(from) == "Vector3" and typeof(to) == "Vector3" and typeof(width) == "number" then
            table.insert(result, {from = from, to = to, width = width, name = definition.Name})
        end
    end
    assert(#result > 0, "No usable route definitions found")
    return result
end

local routes = routeDefinitions()
local baseline = {
    PathsParts = sourcePartCount(paths),
    QuadGroundCFrame = lawn.CFrame,
    QuadGroundSize = lawn.Size,
}

local folder = Instance.new("Folder")
folder.Name = "MVPGrassDecoration"
folder:SetAttribute("Source", "roblox/mvp/builders/GrassDecoration.luau")
folder:SetAttribute("VerificationTicket", "PCW-06/MAP-03")
folder:SetAttribute("Status", "Source authored; Studio install and visual verification pending")
folder:SetAttribute("Owns", "Grass edge clumps and outer Quad tree silhouettes only")
folder:SetAttribute("MaxBaseParts", 250)
folder:SetAttribute("TexturePolicy", "No external textures; no community-tree exception")

local partCount = 0
local function part(name, size, placement, token, parent, material)
    assert(palette[token], "Unknown palette token: " .. tostring(token))
    local object = Instance.new("Part")
    object.Name = name
    object.Size = size
    object.CFrame = placement
    object.Color = palette[token]
    object:SetAttribute("PaletteToken", token)
    object:SetAttribute("DecorationOwner", "GrassDecoration12")
    object:SetAttribute("VerificationTicket", "PCW-06/MAP-03")
    object:SetAttribute("MVPBuilder", "GrassDecoration")
    object:SetAttribute("AnchorName", "OuterQuadBounds")
    object:SetAttribute("Footprint", "Noninteractive grass/tree decoration")
    object:SetAttribute("ApproachClearance", "RouteDefinitions plus Task01 Keepouts")
    object:SetAttribute("Owner", "Task12")
    object:SetAttribute("SourceBuilder", "roblox/mvp/builders/GrassDecoration.luau")
    object.Material = material or Enum.Material.SmoothPlastic
    object.Anchored = true
    object.CanCollide = false
    object.CanTouch = false
    object.CanQuery = false
    object.CastShadow = false
    object.TopSurface = Enum.SurfaceType.Smooth
    object.BottomSurface = Enum.SurfaceType.Smooth
    object.Parent = parent
    partCount += 1
    return object
end

local function sphere(name, size, placement, token, parent)
    local object = part(name, size, placement, token, parent)
    local mesh = Instance.new("SpecialMesh")
    mesh.Name = "NativeSphere"
    mesh.MeshType = Enum.MeshType.Sphere
    mesh.Parent = object
    return object
end

local function distanceToRoute(point, route)
    local a = Vector2.new(route.from.X, route.from.Z)
    local b = Vector2.new(route.to.X, route.to.Z)
    local direction = b - a
    local t = math.clamp((point - a):Dot(direction) / direction:Dot(direction), 0, 1)
    return (point - (a + direction * t)).Magnitude
end

local function routeClear(position, radius, margin)
    for _, route in routes do
        if distanceToRoute(Vector2.new(position.X, position.Z), route) - radius < route.width / 2 + margin then
            return false
        end
    end
    return true
end

local function grassClump(name, position, scale, variant, parent)
    local model = Instance.new("Model")
    model.Name = name
    model:SetAttribute("DetailType", "GrassClump")
    model.Parent = parent
    local yaw = variant * .73
    for index = 1, 3 do
        local angle = yaw + (index - 2) * .42
        local height = (.28 + (index % 2) * .09) * scale
        sphere("Blade" .. index, V(.16 * scale, height, .34 * scale),
            CF(position + V(math.cos(angle) * .16 * scale, height / 2, math.sin(angle) * .16 * scale))
                * CFrame.Angles(math.sin(angle) * .20, angle, math.cos(angle) * .08),
            index == 2 and "forest" or "sage", model)
    end
    return model
end

local function outerTree(name, position, height, variant, parent)
    local tree = Instance.new("Model")
    tree.Name = name
    tree:SetAttribute("DetailType", "OuterQuadTree")
    tree:SetAttribute("AnchorRule", "Measured outside Quad perimeter; provisional until Task01 live anchors")
    tree.Parent = parent
    local trunkHeight = height * .58
    part("Trunk", V(height * .075, trunkHeight, height * .075),
        CF(position + V(0, trunkHeight / 2, 0)) * CFrame.Angles(0, variant * .3, .025), "wood", tree, Enum.Material.Wood)
    local crown = Instance.new("Model")
    crown.Name = "UntexturedCrown"
    crown.Parent = tree
    for index, offset in {{0, 0, 0}, {-.34, .05, .06}, {.34, .08, -.05}} do
        sphere("Canopy" .. index, V(height * .31, height * .24, height * .31),
            CF(position + V(offset[1] * height, trunkHeight + height * (.14 + offset[2]), offset[3] * height)),
            index == 2 and "blossom" or "blossom", crown)
    end
    tree:SetAttribute("TextureID", "")
    return tree
end

-- Candidate positions are deliberately relative to the current QuadGround bounds.
-- The integrator must replace/confirm them from Task01 anchors before installation.
local halfX, halfZ = lawn.Size.X / 2, lawn.Size.Z / 2
local edgeY = lawn.Position.Y + lawn.Size.Y / 2
local bounds = options.OuterQuadBounds
assert(bounds:IsA("BasePart"), "OuterQuadBounds must be a measured BasePart anchor")
local candidates = {
    {"NorthWest", bounds.Position + V(-bounds.Size.X / 2, 0, -bounds.Size.Z / 2), 15, 1},
    {"NorthEast", bounds.Position + V(bounds.Size.X / 2, 0, -bounds.Size.Z / 2), 14, 2},
    {"SouthWest", bounds.Position + V(-bounds.Size.X / 2, 0, bounds.Size.Z / 2), 16, 3},
    {"SouthEast", bounds.Position + V(bounds.Size.X / 2, 0, bounds.Size.Z / 2), 15, 4},
}

local trees = Instance.new("Folder")
trees.Name = "OuterQuadTrees"
trees.Parent = folder
for _, candidate in candidates do
    local name, position, height, variant = table.unpack(candidate)
    if routeClear(position, height * .22, 1.5) and not options.Keepouts[name] then
        outerTree("Tree_" .. name, V(position.X, edgeY, position.Z), height, variant, trees)
    end
end

local grass = Instance.new("Folder")
grass.Name = "GrassClumps"
grass.Parent = folder
local offsets = {{-.30, -.22}, {0, .16}, {.28, -.06}, {-.12, .31}}
for index, factor in ipairs(offsets) do
    local position = lawn.Position + V(factor[1] * halfX, lawn.Size.Y / 2, factor[2] * halfZ)
    if routeClear(position, .55, 1.5) and not options.Keepouts["Grass_" .. index] then
        grassClump("Grass_" .. index, V(position.X, edgeY, position.Z), .9 + (index % 2) * .15, index, grass)
    end
end

assert(partCount <= 250, "GrassDecoration exceeds 250 BaseParts: " .. partCount)
assert(sourcePartCount(paths) == baseline.PathsParts, "Existing route geometry changed during decoration build")
assert(lawn.CFrame == baseline.QuadGroundCFrame and lawn.Size == baseline.QuadGroundSize,
    "Existing QuadGround changed during decoration build")
folder:SetAttribute("PartCount", partCount)
folder:SetAttribute("RouteCountChecked", #routes)
folder:SetAttribute("BaselinePathsParts", baseline.PathsParts)
folder:SetAttribute("BaselineQuadGroundSize", tostring(baseline.QuadGroundSize))
folder:SetAttribute("BaselineQuadGroundCFrame", tostring(baseline.QuadGroundCFrame))

local installedFolder = context.SafeReplace("GrassDecoration", function()
    return folder
end)
return {
    folder = installedFolder,
    manifest = {
        name = "GrassDecoration",
        partCount = partCount,
        routeCount = #routes,
        baselinePathsParts = baseline.PathsParts,
        baselineQuadGroundSize = tostring(baseline.QuadGroundSize),
        baselineQuadGroundCFrame = tostring(baseline.QuadGroundCFrame),
        sourceBuilder = "roblox/mvp/builders/GrassDecoration.luau",
        preserved = {"Paths", "Landscape.QuadGround", "QuadPlanting"},
    },
}
end
]=],
    ["roblox/mvp/builders/LobbyQueue.luau"] = [=[-- Detached lobby queue builder. Task 01 supplies the prebound MVP SafeReplace helper.
local TICKET = "PCW-17"
local BUILDER = "LobbyQueue"

local function metadata(part, token, anchor, footprint, clearance)
	part:SetAttribute("VerificationTicket", TICKET)
	part:SetAttribute("PaletteToken", token)
	part:SetAttribute("MVPBuilder", BUILDER)
	part:SetAttribute("AnchorName", anchor)
	part:SetAttribute("Footprint", footprint)
	part:SetAttribute("ApproachClearance", clearance)
	part:SetAttribute("Owner", "Task08")
	part:SetAttribute("SourceBuilder", BUILDER)
end

local function part(parent, name, size, frame, token, footprint, clearance)
	local value = Instance.new("Part")
	value.Name = name
	value.Size = size
	value.CFrame = frame
	value.Anchored = true
	value.CanCollide = true
	metadata(value, token, "BirthdayLobbyQueue", footprint, clearance)
	value.Parent = parent
end

local function validate(context)
	assert(type(context) == "table", "LobbyQueue requires context")
	assert(type(context.SafeReplace) == "function", "LobbyQueue requires prebound SafeReplace")
	assert(type(context.ValidateAnchors) == "function", "LobbyQueue requires shared anchor validator")
	assert(context:ValidateAnchors({ "BirthdayLobbyQueue" }), "BirthdayLobbyQueue anchor validation failed")
	local anchor = context.Anchors and context.Anchors.BirthdayLobbyQueue
	assert(typeof(anchor) == "Instance" and anchor:IsA("BasePart"), "BirthdayLobbyQueue must be a measured BasePart")
	if context.RequiredPalette then
		assert(context.RequiredPalette.forest and context.RequiredPalette.cream, "queue palette unavailable")
	end
end

local function factory(anchorCFrame)
	local folder = Instance.new("Folder")
	folder.Name = "LobbyQueue"
	folder:SetAttribute("VerificationTicket", TICKET)
	folder:SetAttribute("MVPBuilder", BUILDER)
	folder:SetAttribute("Owner", "Task08")
	folder:SetAttribute("SourceBuilder", BUILDER)
	part(folder, "QueueFloor", Vector3.new(12, 0.2, 12), anchorCFrame, "forest", "12x12 opt-in square", "16 studs")
	part(folder, "QueueSign", Vector3.new(8, 4, 0.2), anchorCFrame * CFrame.new(0, 3, -6), "cream", "8x4 readable sign", "12 studs")
	return folder
end

return function(context)
	validate(context)
	local anchorCFrame = context.Anchors.BirthdayLobbyQueue.CFrame
	assert(typeof(anchorCFrame) == "CFrame", "BirthdayLobbyQueue requires measured CFrame")
	local installedFolder = context.SafeReplace("LobbyQueue", function()
		return factory(anchorCFrame)
	end)
	return {
		folder = installedFolder,
		manifest = { Ticket = TICKET, Builder = BUILDER, Owner = "Task08", AnchorName = "BirthdayLobbyQueue", Footprint = "12x12 square plus sign", ApproachClearance = "16 studs / 12 studs", QueueRule = "one opt-in queue, max 10, shared deadline" },
	}
end
]=],
    ["roblox/mvp/builders/NightLighting.luau"] = [=[-- Edit-mode builder. Requiring this module has no live-world side effects.
-- Canonical integration shape: return function(context).
local COLORS={golden=Color3.fromRGB(232,199,121),cream=Color3.fromRGB(245,240,228),forest=Color3.fromRGB(54,87,68),ink=Color3.fromRGB(38,56,46)}
local DEFINITIONS={
 Bedroom={anchor="GameplayBedroomArrival",offset=CFrame.new(0,7,0),range=24,brightness=1.35,shadows=true}, BedroomBedside={anchor="Q01Bed",offset=CFrame.new(2,3,1),range=14,brightness=.8,shadows=false}, Lobby={anchor="BirthdayLobbyQueue",offset=CFrame.new(0,6,0),range=20,brightness=1.1,shadows=true}, Craft={anchor="Q03FairCraft",offset=CFrame.new(0,5,0),range=18,brightness=1,shadows=false}, Vending={anchor="Q05UDistrictVending",offset=CFrame.new(0,5,0),range=16,brightness=1,shadows=false}, Food={anchor="Q06Serving",offset=CFrame.new(0,5,0),range=20,brightness=1.1,shadows=true}, Quad={anchor="Q04QuadReading",offset=CFrame.new(0,7,0),range=22,brightness=.8,shadows=false}, Patio={anchor="FinalePatio",offset=CFrame.new(0,6,0),range=22,brightness=1.1,shadows=true}, RouteBedroom={anchor="GameplayBedroomArrival",offset=CFrame.new(0,2,-10),range=12,brightness=.45,shadows=false}, RouteDistrict={anchor="Q03FairCraft",offset=CFrame.new(0,2,-10),range=12,brightness=.45,shadows=false}, RouteQuad={anchor="Q04QuadReading",offset=CFrame.new(0,2,-10),range=12,brightness=.45,shadows=false}, RoutePatio={anchor="FinalePatio",offset=CFrame.new(0,2,-10),range=12,brightness=.45,shadows=false},
}
local REQUIRED={"GameplayBedroomArrival","Q01Bed","BirthdayLobbyQueue","Q03FairCraft","Q05UDistrictVending","Q06Serving","Q04QuadReading","FinalePatio"}
local GLOBAL_KEYS={"ClockTime","Brightness","ExposureCompensation","GlobalShadows","Ambient","OutdoorAmbient","EnvironmentDiffuseScale","EnvironmentSpecularScale","ShadowSoftness"}
local function findAnchor(context,name) return context.Anchors[name] or context.Root:FindFirstChild(name,true) end
local function preflight(context)
 assert(context and context.Root and context.MVP and context.Anchors and context.Palette,"NightLighting context is required")
 for _,name in REQUIRED do local anchor=findAnchor(context,name); assert(anchor and anchor:IsA("BasePart"),"NightLighting missing required anchor: "..name); assert(anchor:GetAttribute("PlacementStatus")~="UNRESOLVED_LIVE_ANCHOR","NightLighting unresolved anchor: "..name) end
 for _,token in {"forest","sage","cream","wood","blossom","brick","golden","ink"} do assert(context.Palette[token],"NightLighting missing palette token: "..token) end
end
local function captureLighting(lighting) local result={}; for _,key in GLOBAL_KEYS do result[key]=lighting[key] end; return result end
local function restoreLighting(lighting,values) for key,value in values do lighting[key]=value end end
local function buildDetached(context,options)
 local folder=Instance.new("Folder"); folder.Name="NightLighting"; folder:SetAttribute("Owner","Task11"); folder:SetAttribute("MVPBuilder","NightLighting"); folder:SetAttribute("Source","roblox/mvp/builders/NightLighting.luau"); folder:SetAttribute("Status","Implementation delivered; Studio/device verification pending"); folder:SetAttribute("HighShadowBudget",12); folder:SetAttribute("LowShadowBudget",6)
 local created,shadowCount={},0
 for name,definition in DEFINITIONS do
  local anchor=findAnchor(context,definition.anchor); assert(anchor and anchor:IsA("BasePart"),"NightLighting anchor changed during build: "..definition.anchor)
  local part=Instance.new("Part"); part.Name=name; part.Size=Vector3.new(.25,.25,.25); part.Transparency=1; part.Anchored=true; part.CanCollide=false; part.CanTouch=false; part.CanQuery=false; part.CFrame=anchor.CFrame*definition.offset; part:SetAttribute("VerificationTicket","PCW-01"); part:SetAttribute("PaletteToken","golden"); part:SetAttribute("MVPBuilder","NightLighting"); part:SetAttribute("AnchorName",definition.anchor); part:SetAttribute("Footprint","0.25x0.25x0.25 invisible fixture"); part:SetAttribute("ApproachClearance","No collision; does not alter route"); part:SetAttribute("Owner","Task11"); part:SetAttribute("SourceBuilder","roblox/mvp/builders/NightLighting.luau"); part.Parent=folder
  local light=Instance.new("PointLight"); light.Name="WarmFixture"; light.Color=COLORS.golden; light.Brightness=options.lowGraphics and math.min(definition.brightness,1) or definition.brightness; light.Range=definition.range; light.Shadows=options.lowGraphics and false or definition.shadows; light.Parent=part
  table.insert(created,name); if light.Shadows then shadowCount+=1 end
 end
 folder:SetAttribute("CreatedFixtureCount",#created); folder:SetAttribute("ShadowFixtureCount",shadowCount); return folder,created,shadowCount
end
local function applyGlobals(lighting)
 lighting.ClockTime=22; lighting.Brightness=2; lighting.ExposureCompensation=.1; lighting.GlobalShadows=true; lighting.Ambient=COLORS.forest; lighting.OutdoorAmbient=COLORS.ink; lighting.EnvironmentDiffuseScale=.45; lighting.EnvironmentSpecularScale=.15; lighting.ShadowSoftness=.85
 local atmosphere=lighting:FindFirstChild("MVPNightAtmosphere"); local created=false; if not atmosphere then atmosphere=Instance.new("Atmosphere"); atmosphere.Name="MVPNightAtmosphere"; atmosphere.Parent=lighting; created=true end
 local original={Density=atmosphere.Density,Haze=atmosphere.Haze,Glare=atmosphere.Glare,Color=atmosphere.Color,Decay=atmosphere.Decay}; atmosphere.Density=.07; atmosphere.Haze=.08; atmosphere.Glare=0; atmosphere.Color=COLORS.cream; atmosphere.Decay=COLORS.forest
 return atmosphere,created,original
end
return function(context)
 preflight(context)
 local lighting=context.Lighting or game:GetService("Lighting"); local options=context.Options or {}; local folder,created,shadowCount=buildDetached(context,options); local originalLighting=captureLighting(lighting); local atmosphere,atmosphereCreated,originalAtmosphere=applyGlobals(lighting)
 local restored=false
 local function restoreOwned() if restored then return end; restored=true; restoreLighting(lighting,originalLighting); if atmosphere and atmosphere.Parent then if atmosphereCreated then atmosphere:Destroy() else for key,value in originalAtmosphere do atmosphere[key]=value end end end end
 local ok,installed=pcall(function() return context.SafeReplace("NightLighting",function() return folder end) end)
 if not ok then restoreOwned(); error(installed) end
 return {folder=installed,manifest={Owner="Task11",SourceBuilder="roblox/mvp/builders/NightLighting.luau",VerificationTicket="PCW-01",RequiredAnchors=REQUIRED,Created=created,ShadowCount=shadowCount,HighShadowBudget=12,LowShadowBudget=6,GlobalLightingProperties=GLOBAL_KEYS},Restore=restoreOwned}
end
]=],
    ["roblox/mvp/builders/Q01Station.luau"] = [=[-- Native, installable Q01 bed/station visuals. Task 01 owns actual Studio installation.
local Q01Station = {}

local COLORS = {
	Forest = Color3.fromRGB(54, 87, 68), Sage = Color3.fromRGB(168, 185, 149), Cream = Color3.fromRGB(245, 240, 228),
	Wood = Color3.fromRGB(149, 103, 75), Golden = Color3.fromRGB(232, 199, 121), Ink = Color3.fromRGB(38, 56, 46),
}

local function part(parent, name, size, cframe, color, canCollide)
	local p = Instance.new("Part")
	p.Name, p.Size, p.CFrame, p.Color, p.Anchored, p.CanCollide = name, size, cframe, color, true, canCollide ~= false
	p.Material = Enum.Material.SmoothPlastic
	p:SetAttribute("VerificationTicket", "PCW-07")
	p:SetAttribute("PaletteToken", color == COLORS.Sage and "sage" or color == COLORS.Wood and "wood" or color == COLORS.Cream and "cream" or color == COLORS.Forest and "forest" or color == COLORS.Golden and "golden" or "ink")
	p:SetAttribute("MVPBuilder", "Q01Station")
	p.Parent = parent
	return p
end

function Q01Station.Build(anchorCFrame)
	assert(anchorCFrame, "Q01Station.Build requires Q01Bed CFrame")
	local model = Instance.new("Model")
	model.Name = "Q01EverythingTuckedIn"
	model:SetAttribute("ActivityId", "Q01")
	model:SetAttribute("VerificationTicket", "PCW-07")
	local base = anchorCFrame
	part(model, "BedFrame", Vector3.new(7, 1, 10), base * CFrame.new(0, 0.5, 0), COLORS.Wood)
	part(model, "SageBedding", Vector3.new(6.7, 0.55, 8.6), base * CFrame.new(0, 1.25, 0.2), COLORS.Sage)
	part(model, "Headboard", Vector3.new(7, 4, 0.5), base * CFrame.new(0, 2.5, -4.7), COLORS.Cream)
	local pillows = { { "PillowLeft", -1.7 }, { "PillowRight", 1.7 } }
	for _, data in ipairs(pillows) do part(model, data[1], Vector3.new(2.5, 0.45, 1.5), base * CFrame.new(data[2], 1.75, -3), COLORS.Cream, false) end
	part(model, "RoundBelliedDog", Vector3.new(1.7, 1.6, 1.7), base * CFrame.new(-2.1, 2, -0.6), COLORS.Golden, false)
	part(model, "DinosaurPlush", Vector3.new(1.5, 1.8, 2), base * CFrame.new(2.1, 2.1, -0.4), COLORS.Forest, false)
	local socketOffsets = { blanket_left = Vector3.new(-3.8, 1.5, 0), blanket_right = Vector3.new(3.8, 1.5, 0), blanket_foot = Vector3.new(0, 1.5, 5.1), pillow_left = Vector3.new(-1.7, 1.9, -3), pillow_right = Vector3.new(1.7, 1.9, -3), plush_dog = Vector3.new(-2.1, 2.2, -0.6), plush_dinosaur = Vector3.new(2.1, 2.2, -0.4) }
	for stepId, offset in pairs(socketOffsets) do
		local socket = part(model, "Socket_" .. stepId, Vector3.new(2.2, 0.15, 1.8), base * CFrame.new(offset), COLORS.Golden, false)
		socket.Transparency = 0.65
		socket:SetAttribute("StepId", stepId)
	end
	model.PrimaryPart = model:FindFirstChild("BedFrame")
	return model
end

return function(context)
	assert(context and context.Root and context.MVP and context.Anchors and context.SafeReplace, "Q01Station context is incomplete")
	local anchor = context.Anchors.Q01Bed
	assert(anchor, "Q01Station requires resolved Q01Bed anchor")
	local placementStatus = anchor:GetAttribute("PlacementStatus")
	assert(placementStatus and not string.find(placementStatus, "UNRESOLVED", 1, true), "Q01Bed anchor lacks valid live placement provenance")
	local anchorCFrame = anchor:IsA("BasePart") and anchor.CFrame or CFrame.new(anchor.Position)
	local manifest = {
		AnchorName = "Q01Bed",
		Footprint = "7x10 bed; sockets remain outside collision",
		ApproachClearance = "Measured by integrator from live anchor",
		Owner = "Task02",
		SourceBuilder = "roblox/mvp/builders/Q01Station.luau",
	}
	local installedFolder = context.SafeReplace("Q01Station", function()
		local model = Q01Station.Build(anchorCFrame)
		model:SetAttribute("Owner", manifest.Owner)
		model:SetAttribute("MVPBuilder", "Q01Station")
		model:SetAttribute("AnchorName", manifest.AnchorName)
		model:SetAttribute("Footprint", manifest.Footprint)
		model:SetAttribute("ApproachClearance", manifest.ApproachClearance)
		model:SetAttribute("SourceBuilder", manifest.SourceBuilder)
		return model
	end)
	return { folder = installedFolder, manifest = manifest }
end
]=],
    ["roblox/mvp/builders/Q02Station.luau"] = [=[-- Q02 edit-mode builder. The integrator supplies the frozen builder context.
return function(context)
    assert(context and context.Root and context.MVP and context.Anchors and context.Palette, "Q02 builder context is required")
    assert(type(context.SafeReplace) == "function", "Q02 requires SafeReplace(name, factory)")
    local bedroom = context.Anchors.JasperBedroomStart
    local yard = context.Anchors.JasperFetchYard
    assert(bedroom and yard, "Q02 requires JasperBedroomStart and JasperFetchYard")
    assert(bedroom:GetAttribute("PlacementStatus") ~= "UNRESOLVED_LIVE_ANCHOR" and yard:GetAttribute("PlacementStatus") ~= "UNRESOLVED_LIVE_ANCHOR", "Q02 anchors cannot be unresolved")
    local requiredPalette = {"forest", "sage", "cream", "wood", "golden", "ink"}
    for _, token in ipairs(requiredPalette) do assert(context.Palette[token], "Q02 palette token is missing: " .. token) end

    local function factory()
        local folder = Instance.new("Folder")
        folder.Name = "Q02"
        folder:SetAttribute("VerificationTicket", "PCW-08")
        folder:SetAttribute("MVPBuilder", "Q02Station")
        folder:SetAttribute("Owner", "Q02")
        folder:SetAttribute("Status", "Source authored; Studio install and play verification pending")
        folder:SetAttribute("PalettePolicy", "Exact world palette until approved Jasper figure profile")
        local function marker(name, position, size, token, action, anchorName, footprint, clearance)
            local part = Instance.new("Part")
            part.Name, part.Size, part.CFrame = name, size, CFrame.new(position)
            part.Color, part.Anchored, part.CanCollide, part.CanTouch, part.CanQuery = context.Palette[token], true, false, false, true
            part.Transparency, part.Material = .45, Enum.Material.SmoothPlastic
            part:SetAttribute("VerificationTicket", "PCW-08")
            part:SetAttribute("PaletteToken", token)
            part:SetAttribute("MVPBuilder", "Q02Station")
            part:SetAttribute("Owner", "Q02")
            part:SetAttribute("AnchorName", anchorName)
            part:SetAttribute("Footprint", footprint)
            part:SetAttribute("ApproachClearance", clearance)
            part:SetAttribute("Q02Action", action)
            part.Parent = folder
        end
        local bedroomPosition, yardPosition = bedroom.Position, yard.Position
        marker("JasperBedroomGreeting", bedroomPosition, Vector3.new(5, 2, 5), "golden", "greet", "JasperBedroomStart", "5x2x5", "2 studs")
        marker("JasperFetchLane", yardPosition, Vector3.new(10, .3, 5), "forest", "throw", "JasperFetchYard", "10x0.3x5", "3 studs")
        for index = 1, 3 do marker("JasperRabbitBasket" .. string.char(64 + index), yardPosition + Vector3.new((index - 2) * 4, 1, 5), Vector3.new(2, 2, 2), "wood", "inspect", "JasperFetchYard", "2x2x2", "2 studs") end
        marker("JasperRabbitHandoff", yardPosition + Vector3.new(0, 1, -3), Vector3.new(3, 2, 3), "sage", "return_rabbit", "JasperFetchYard", "3x2x3", "2 studs")
        marker("JasperGreenie", yardPosition + Vector3.new(0, 1, -5), Vector3.new(3, 2, 2), "golden", "greenie", "JasperFetchYard", "3x2x2", "2 studs")
        folder:SetAttribute("PromptBindings", "JasperBedroomStart:greet; JasperFetchYard:inspect,throw,return_rabbit,greenie")
        folder:SetAttribute("SourceAnchorState", "validated")
        return folder
    end
    local installed = context.SafeReplace("Q02Station", factory)
    return {folder = installed, manifest = {ticket = "PCW-08", builder = "Q02Station", owner = "Q02", anchorNames = {"JasperBedroomStart", "JasperFetchYard"}, promptBindings = {"bedroom:greet", "yard:inspect", "yard:throw", "yard:return_rabbit", "yard:greenie"}, paletteTokens = requiredPalette, sourceReference = "Existing Jasper identity is preserved; this builder stages interaction markers only.", verification = "Studio install, navigation, figure identity, touch/desktop and group play remain pending."}}
end
]=],
    ["roblox/mvp/builders/Q03Station.luau"] = [=[return function(context)
    assert(context and context.Root and context.MVP and context.MVP.Stations, "Q03Station context is incomplete")
    assert(type(context.SafeReplace) == "function", "Q03Station requires SafeReplace")
    local anchors = assert(context.Anchors, "Q03Station Anchors required")
    local boothAnchor = assert(anchors.Q03FairCraft, "Q03FairCraft anchor required")
    local homeAnchor = assert(anchors.Q03BedroomDisplay, "Q03BedroomDisplay anchor required")
    assert(boothAnchor:GetAttribute("PlacementStatus") ~= "UNRESOLVED_LIVE_ANCHOR", "Q03FairCraft anchor unresolved")
    assert(homeAnchor:GetAttribute("PlacementStatus") ~= "UNRESOLVED_LIVE_ANCHOR", "Q03BedroomDisplay anchor unresolved")
    local palette = assert(context.Palette, "Q03Station palette required")
    for _, token in ipairs({"forest", "sage", "cream", "wood", "blossom", "golden", "ink"}) do assert(palette[token], "missing palette token: " .. token) end
    local manifest = {AnchorName="Q03FairCraft;Q03BedroomDisplay", Footprint="14x10 proposed; measured anchors required", ApproachClearance="3 front; 2 side proposed", Owner="Task04", SourceBuilder="roblox/mvp/builders/Q03Station.luau"}
    local function factory()
        local folder = Instance.new("Folder"); folder.Name = "Q03"; folder:SetAttribute("VerificationTicket", "PCW-09"); folder:SetAttribute("MVPBuilder", "Q03Station"); folder:SetAttribute("Owner", "Task04")
        local function part(name,size,cf,token,parent,collide)
            local p=Instance.new("Part"); p.Name=name; p.Size=size; p.CFrame=cf; p.Color=palette[token]; p.Anchored=true; p.CanCollide=collide==true
            for key,value in pairs({VerificationTicket="PCW-09",PaletteToken=token,MVPBuilder="Q03Station",AnchorName=manifest.AnchorName,Footprint=manifest.Footprint,ApproachClearance=manifest.ApproachClearance,Owner=manifest.Owner,SourceBuilder=manifest.SourceBuilder}) do p:SetAttribute(key,value) end
            p.Parent=parent; return p
        end
        local function piece(name,size,cf,token) local m=Instance.new("Model"); m.Name=name; m.Parent=folder; part("Body",size,cf,token,m,false); return m end
        local b,h=boothAnchor.CFrame,homeAnchor.CFrame
        part("CraftTable",Vector3.new(8,2,4),b*CFrame.new(0,1,0),"wood",folder,true)
        for i=1,6 do local x=((i-1)%3-1)*2.2; local z=(math.floor((i-1)/3)-.5)*1.5; part("Socket_"..i,Vector3.new(1.4,.08,1.1),b*CFrame.new(x,2.05,z),"golden",folder,false) end
        piece("Rug",Vector3.new(2.4,.08,1.8),b*CFrame.new(-2.2,2.12,-.75),"sage"); piece("Chair",Vector3.new(1.2,1.4,1.2),b*CFrame.new(0,2.8,-.75),"sage"); piece("Bookcase",Vector3.new(1.1,1.8,.45),b*CFrame.new(2.2,2.9,-.75),"wood"); piece("SideTable",Vector3.new(1,.8,1),b*CFrame.new(-2.2,2.55,.75),"wood"); piece("Plant",Vector3.new(.7,1.2,.7),b*CFrame.new(0,2.7,.75),"forest"); piece("Lamp",Vector3.new(.6,1.4,.6),b*CFrame.new(2.2,2.8,.75),"golden")
        local home=Instance.new("Model"); home.Name="HomeDisplay"; home.Parent=folder; part("DisplayBase",Vector3.new(7,.3,5),h*CFrame.new(0,.2,0),"wood",home,false); home:SetAttribute("SharedState","Q03 server miniature; booth and desk are one state"); home:SetAttribute("NoDuplicateReward",true)
        return folder
    end
    local installed=context.SafeReplace("Q03Station",factory)
    return {folder=installed,manifest=manifest}
end
]=],
    ["roblox/mvp/builders/Q04Station.luau"] = [=[return function(context)
    assert(context and context.Root and context.MVP and context.Anchors and context.Palette, "Q04 station context is required")
    assert(context.SafeReplace, "Q04Station requires SafeReplace")
    local function getAnchor(name)
        local anchor = context.Anchors[name]
        if not anchor then
            local markerRoot = context.MVP:FindFirstChild("Anchors")
            anchor = markerRoot and markerRoot:FindFirstChild(name, true) or nil
        end
        return anchor
    end
    local required = { "Q04QuadReading", "Q04BedroomKindle" }
    for _, name in ipairs(required) do
        local anchor = getAnchor(name)
        assert(anchor, "Required Q04 anchor missing: " .. name)
        local status = anchor:GetAttribute("PlacementStatus")
        assert(anchor:IsA("BasePart"), "Q04 anchor must be a BasePart: " .. name)
        assert(type(status) == "string" and status ~= "" and status ~= "UNRESOLVED" and status ~= "UNRESOLVED_LIVE_ANCHOR", "Q04 anchor unresolved: " .. name)
    end
    for _, token in ipairs({ "forest", "sage", "cream", "wood", "blossom", "brick", "golden", "ink" }) do
        assert(context.Palette[token], "Required palette token missing: " .. token)
    end
    local function factory()
        local folder = Instance.new("Folder")
        folder.Name = "Q04"
        folder:SetAttribute("VerificationTicket", "PCW-10")
        folder:SetAttribute("MVPBuilder", "Q04Station")
        local function prop(name, anchorName, token, offset, footprint, clearance)
            local part = Instance.new("Part")
            part.Name = name
            part.Size = Vector3.new(.8, .18, .55)
            part.CFrame = getAnchor(anchorName).CFrame * CFrame.new(offset)
            part.Color = context.Palette[token]
            part.Anchored = true
            part.CanCollide = false
            part.CanTouch = false
            part.CanQuery = false
            for key, value in { VerificationTicket = "PCW-10", PaletteToken = token, MVPBuilder = "Q04Station", AnchorName = anchorName, Footprint = footprint, ApproachClearance = clearance, Owner = "Task05", SourceBuilder = "roblox/mvp/builders/Q04Station.luau" } do
                part:SetAttribute(key, value)
            end
            part.Parent = folder
        end
        prop("QuadReadingBook", "Q04QuadReading", "wood", Vector3.new(0, 1.15, 0), "Existing bench only", "Measured by Task01")
        prop("QuadReadingPrompt", "Q04QuadReading", "golden", Vector3.new(0, 1.45, 0), "Existing bench only", "Measured by Task01")
        prop("BedroomKindlePrompt", "Q04BedroomKindle", "forest", Vector3.new(0, .25, 0), "Existing desk/display only", "Measured by Task01")
        return folder
    end
    local manifest = { VerificationTicket = "PCW-10", MVPBuilder = "Q04Station", Owner = "Task05", SourceBuilder = "roblox/mvp/builders/Q04Station.luau", RequiredAnchors = required, Preserves = { "Existing Quad benches", "QuadPlanting", "Quad paths", "Bedroom desk/Kindle" }, BasePartCount = 3 }
    local installed = context.SafeReplace("Q04Station", factory)
    return {
        folder = installed,
        manifest = manifest,
    }
end
]=],
    ["roblox/mvp/builders/Q05Station.luau"] = [=[-- Native, installable Q05 vending visuals. Task 01 owns Studio installation.
return function(context)
    assert(context and context.Root and context.MVP and context.Anchors and context.Palette and context.SafeReplace, "Q05Station context is incomplete")
    local anchor = context.Anchors.Q05UDistrictVending
    assert(anchor and anchor:IsA("BasePart"), "Q05Station requires Q05UDistrictVending BasePart")
    assert(anchor:GetAttribute("PlacementStatus") ~= "UNRESOLVED_LIVE_ANCHOR", "Q05 vending anchor is unresolved")
    local anchorCFrame = anchor.CFrame
    local manifest = {AnchorName = "Q05UDistrictVending", Footprint = "6.4 x 2.4 cabinet footprint", ApproachClearance = "Measured by integrator outside crossing and pedestrian route", Owner = "Task06", SourceBuilder = "roblox/mvp/builders/Q05Station.luau"}
    local installed = context.SafeReplace("Q05Station", function()
        local folder = Instance.new("Model"); folder.Name = "Q05LabubuVending"
        folder:SetAttribute("ActivityId", "Q05"); folder:SetAttribute("VerificationTicket", "PCW-11"); folder:SetAttribute("MVPBuilder", "Q05Station")
        for key, value in pairs(manifest) do folder:SetAttribute(key, value) end
        folder:SetAttribute("Interaction", "Inspect; select wanted; authorized shared-fund roll; skippable reveal")
        local function part(name, size, cf, token, material, collide)
            assert(context.Palette[token], "unknown palette token: " .. token)
            local item = Instance.new("Part"); item.Name = name; item.Size = size; item.CFrame = cf; item.Color = context.Palette[token]; item.Material = material or Enum.Material.SmoothPlastic; item.Anchored = true; item.CanCollide = collide == true; item.CanTouch = false; item.CanQuery = true
            item:SetAttribute("VerificationTicket", "PCW-11"); item:SetAttribute("PaletteToken", token); item:SetAttribute("MVPBuilder", "Q05Station"); item:SetAttribute("AnchorName", manifest.AnchorName); item:SetAttribute("Footprint", manifest.Footprint); item:SetAttribute("ApproachClearance", manifest.ApproachClearance); item:SetAttribute("Owner", manifest.Owner); item:SetAttribute("SourceBuilder", manifest.SourceBuilder); item.Parent = folder; return item
        end
        part("CabinetBody", Vector3.new(6, 7, 2), anchorCFrame * CFrame.new(0, 3.5, 0), "forest", Enum.Material.Wood, true)
        part("DisplayPanel", Vector3.new(5.2, 3.2, .18), anchorCFrame * CFrame.new(0, 5.05, -1.08), "cream", Enum.Material.Glass, false)
        part("GoldHeader", Vector3.new(5.4, .45, 2.15), anchorCFrame * CFrame.new(0, 7.2, 0), "golden", Enum.Material.Metal, false)
        part("Counter", Vector3.new(6.4, .35, 2.4), anchorCFrame * CFrame.new(0, 1.4, -.2), "wood", Enum.Material.Wood, true)
        for index = 1, 7 do part("FigureSlot" .. index, Vector3.new(.48, .72, .18), anchorCFrame * CFrame.new((index - 4) * .62, 5.05, -1.22), index == 7 and "blossom" or "sage", nil, false) end
        part("PromptPlate", Vector3.new(2.8, .5, .12), anchorCFrame * CFrame.new(0, 2.05, -1.22), "golden", Enum.Material.Neon, false)
        return folder
    end)
    return {folder = installed, manifest = manifest}
end
]=],
    ["roblox/mvp/builders/Q06Station.luau"] = [=[-- Q06 station builder. Geometry is derived from measured UDistrict anchors only.
return function(context)
    assert(context and context.Root and context.MVP and context.Anchors and context.Palette and context.SafeReplace, "Q06Station context is incomplete")
    local required = { "Q06FOBCounter", "Q06AladdinsCounter", "Q06Serving" }
    for _, name in ipairs(required) do
        local anchor = context.Anchors[name]
        assert(anchor and anchor:IsA("BasePart"), "Q06Station requires anchor BasePart: " .. name)
        assert(anchor:GetAttribute("Status") ~= "UNRESOLVED" and anchor:GetAttribute("PlacementStatus") ~= "UNRESOLVED_LIVE_ANCHOR", "Q06 anchor unresolved: " .. name)
    end
    for _, token in ipairs({ "forest", "sage", "cream", "wood", "blossom", "brick", "golden", "ink" }) do assert(context.Palette[token], "Required palette token missing: " .. token) end
    local manifests = {}
    for _, name in ipairs(required) do manifests[name] = { AnchorName=name, Footprint="10 x 4 station footprint", ApproachClearance="Measured UDistrict route clearance", Owner="Task07", SourceBuilder="roblox/mvp/builders/Q06Station.luau" } end
    local function factory()
        local folder = Instance.new("Folder"); folder.Name = "Q06"; folder:SetAttribute("ActivityId", "Q06"); folder:SetAttribute("VerificationTicket", "PCW-12"); folder:SetAttribute("MVPBuilder", "Q06Station")
        local function part(parent, name, size, cf, token, manifest, collide)
            local item = Instance.new("Part"); item.Name, item.Size, item.CFrame, item.Color = name, size, cf, context.Palette[token]; item.Anchored, item.CanCollide, item.CanTouch, item.CanQuery = true, collide == true, false, true
            for key, value in pairs({ VerificationTicket="PCW-12", PaletteToken=token, MVPBuilder="Q06Station", AnchorName=manifest.AnchorName, Footprint=manifest.Footprint, ApproachClearance=manifest.ApproachClearance, Owner=manifest.Owner, SourceBuilder=manifest.SourceBuilder }) do item:SetAttribute(key, value) end
            item.Parent = parent
        end
        for _, name in ipairs(required) do
            local station = Instance.new("Model"); station.Name = name; station.Parent = folder
            local anchor, manifest = context.Anchors[name], manifests[name]
            part(station, "Counter", Vector3.new(10,2,4), anchor.CFrame * CFrame.new(0,1,0), "wood", manifest, true)
            part(station, "ActionSurface", Vector3.new(8,.15,3), anchor.CFrame * CFrame.new(0,2.1,0), "cream", manifest, false)
            part(station, "StationLabel", Vector3.new(4,1,.15), anchor.CFrame * CFrame.new(0,3,-1.8), "forest", manifest, false)
        end
        return folder
    end
    local installedFolder = context.SafeReplace("Q06Station", factory)
    assert(installedFolder and installedFolder.IsA and (installedFolder:IsA("Folder") or installedFolder:IsA("Model")), "Q06 SafeReplace must return installed Folder or Model")
    return { folder=installedFolder, manifest={ VerificationTicket="PCW-12", MVPBuilder="Q06Station", Owner="Task07", SourceBuilder="roblox/mvp/builders/Q06Station.luau", RequiredAnchors=required, PatioPlacement="forbidden", Measurements="pending" } }
end
]=],
    ["roblox/mvp/builders/SeattleBoundary.luau"] = [=[-- Task 10 Seattle perimeter builder.
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
]=],
    ["roblox/mvp/client/activities/Q01.luau"] = [=[-- View descriptor consumed by the common activity renderer.
return {
	activityId = "Q01",
	title = "Everything Tucked In",
	state = "Open",
	instructions = "Help with an available bed step",
	progress = { done = 0, total = 7 },
	availableActions = {},
	acceptedStepIds = {},
	contributors = {},
	busyReason = nil,
	errorText = nil,
	canReplay = false,
	steps = {
		{ id = "blanket_left", label = "Smooth the left blanket", verb = "Smooth", socket = "Socket_blanket_left" },
		{ id = "blanket_right", label = "Smooth the right blanket", verb = "Smooth", socket = "Socket_blanket_right" },
		{ id = "blanket_foot", label = "Fold the foot blanket", verb = "Fold", socket = "Socket_blanket_foot" },
		{ id = "pillow_left", label = "Place the left pillow", verb = "Place", socket = "Socket_pillow_left" },
		{ id = "pillow_right", label = "Place the right pillow", verb = "Place", socket = "Socket_pillow_right" },
		{ id = "plush_dog", label = "Tuck in the round-bellied dog", verb = "Tuck", socket = "Socket_plush_dog" },
		{ id = "plush_dinosaur", label = "Tuck in the dinosaur plush", verb = "Tuck", socket = "Socket_plush_dinosaur" },
	},
	finish = {
		permission = "PhuongOnly",
		label = "Choose how to finish the bed",
		choices = { { id = "soft_snug", label = "Soft and snug" }, { id = "neat_layered", label = "Neatly layered" } },
	},
	controls = { touch = { select = "Tap highlighted step", confirm = "Tap Place or Tuck", cancel = "Tap Cancel" }, desktop = { select = "Click highlighted step", confirm = "Click Place or Tuck", cancel = "Press Escape or click Cancel" } },
	messages = { alreadyDone = "That spot is already handled—choose another bed task", inUse = "Someone else is handling that spot; choose another bed task", needsPhuong = "Ready for Phuong to finish" },
}
]=],
    ["roblox/mvp/client/activities/Q02.luau"] = [=[-- UI-safe descriptor for Q02. Main client owns rendering and input routing.
return {
    activityId = "Q02",
    title = "Jasper's Favorite Things",
    prompts = {
        greet = {desktop = "Interact", touch = "Say hi to Jasper"},
        rabbitFound = {desktop = "Interact", touch = "Inspect basket"},
        rabbitReturned = {desktop = "Interact", touch = "Return rabbit"},
        fetch = {desktop = "Click / Throw", touch = "Throw"},
        greenie = {desktop = "Interact", touch = "Give Greenie"},
        pet = {desktop = "Interact", touch = "Pet Jasper"},
    },
    note = "Throw uses a forgiving lane target; no camera lock or repeated-pet reward.",
}
]=],
    ["roblox/mvp/client/activities/Q03.luau"] = [=[return {
    ActivityId = "Q03",
    Controls = {"Select piece", "Select socket", "Rotate left", "Rotate right", "Place", "Cancel", "Preview at home"},
    Keyboard = {RotateLeft="Q", RotateRight="E"},
    TouchTargetMinimum = 48,
    States = {"Available", "Reserved", "Placed", "Invalid", "Busy", "Expired", "Completed"},
}
]=],
    ["roblox/mvp/client/activities/Q04.luau"] = [=[return {
    activityId = "Q04",
    title = "One More Chapter",
    entryActions = { "Read" },
    panel = { name = "ReadingPanel", scroll = true, close = true, save = true, retry = true, keyboardOptional = true },
    highlightChoices = { "small-detail", "comforting-moment", "shared-spark" },
    reactions = { "moved", "cozy", "curious", "smile" },
    bookmarks = { "ribbon", "pressed-flower", "star-tab" },
    anchors = { "Q04QuadReading", "Q04BedroomKindle" },
}
]=],
    ["roblox/mvp/client/activities/Q06.luau"] = [=[-- UI-safe Q06 descriptor. Client code renders this; it never grants progress.
return {
	activityId = "Q06",
	title = "Something Delicious",
	menuStatus = "Proposed venue-inspired bowl and plate assembly",
	anchors = { "Q06FOBCounter", "Q06AladdinsCounter", "Q06Serving" },
	roles = {
		{ id = "base", label = "Choose a base", items = { "rice" } },
		{ id = "toppings", label = "Add fresh toppings", items = { "greens", "cucumber", "carrot" } },
		{ id = "protein", label = "Add a warm topping", items = { "tofu", "chicken", "mushroom" } },
		{ id = "sauce", label = "Finish the plate", items = { "sauce", "sesame" } },
		{ id = "settingA", label = "Set a plate", items = { "plate", "napkin" } },
		{ id = "settingB", label = "Set a cup", items = { "cup", "napkin" } },
	},
	input = { sequence = { "tap-item", "tap-slot", "tap-confirm" }, cancel = "tap-cancel", desktopEquivalent = true, minTargetScreenUnits = 48 },
	feedback = { accepted = "Added to the shared birthday spread", busy = "Someone else is using that spot", complete = "Spread ready" },
}
]=],
    ["roblox/mvp/client/Main.client.luau"] = [=[local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
local action = ReplicatedStorage:WaitForChild("PhuongMVP"):WaitForChild("Action")

local P = {forest=Color3.fromRGB(54,87,68), sage=Color3.fromRGB(168,185,149), cream=Color3.fromRGB(245,240,228), wood=Color3.fromRGB(149,103,75), blossom=Color3.fromRGB(232,183,198), brick=Color3.fromRGB(182,108,104), golden=Color3.fromRGB(232,199,121), ink=Color3.fromRGB(38,56,46)}
local gui=Instance.new("ScreenGui"); gui.Name="PhuongMVPHud"; gui.ResetOnSpawn=false; gui.Parent=player:WaitForChild("PlayerGui")
local function corner(x,r) local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(0,r or 12); c.Parent=x end
local function text(parent,name,value,size,color) local x=Instance.new("TextLabel"); x.Name=name; x.Text=value or ""; x.TextColor3=color or P.ink; x.BackgroundTransparency=1; x.Font=Enum.Font.GothamSemibold; x.TextSize=size or 16; x.TextWrapped=true; x.TextXAlignment=Enum.TextXAlignment.Left; x.Parent=parent; return x end
local function button(parent,name,value,callback) local x=Instance.new("TextButton"); x.Name=name; x.Text=value or ""; x.AutoButtonColor=true; x.Font=Enum.Font.GothamBold; x.TextSize=16; x.TextColor3=P.cream; x.BackgroundColor3=P.forest; x.Size=UDim2.new(1,0,0,52); x.Parent=parent; corner(x,10); x.Activated:Connect(callback); return x end

local hud=Instance.new("Frame"); hud.Name="ExploreHud"; hud.Position=UDim2.fromOffset(16,16); hud.Size=UDim2.fromOffset(310,132); hud.BackgroundColor3=P.cream; hud.BackgroundTransparency=.08; hud.Parent=gui; corner(hud,14)
local status=text(hud,"SessionStatus","Birthday session loading",16); status.Position=UDim2.fromOffset(14,10); status.Size=UDim2.new(1,-28,0,25)
local flower=text(hud,"FlowerProgress","✿ 0 / 6 petals",18,P.forest); flower.Position=UDim2.fromOffset(14,40); flower.Size=UDim2.new(1,-28,0,28)
local fund=text(hud,"FundBalance","Shared fund  •  0",14); fund.Position=UDim2.fromOffset(14,72); fund.Size=UDim2.new(1,-28,0,24)
local queueState=text(hud,"QueueState","Queue: not joined",13); queueState.Position=UDim2.fromOffset(14,98); queueState.Size=UDim2.new(1,-28,0,22)
local journal=button(gui,"JournalButton","Journal",function() end); journal.AnchorPoint=Vector2.new(1,0); journal.Position=UDim2.new(1,-20,0,20); journal.Size=UDim2.fromOffset(132,52)
local cakeButton=button(gui,"CakeButton","Cake finale",function() end); cakeButton.AnchorPoint=Vector2.new(1,0); cakeButton.Position=UDim2.new(1,-20,0,80); cakeButton.Size=UDim2.fromOffset(132,44); cakeButton.Visible=false

local panel=Instance.new("Frame"); panel.Name="ActivityPanel"; panel.AnchorPoint=Vector2.new(.5,.5); panel.Position=UDim2.fromScale(.5,.5); panel.Size=UDim2.new(.86,0,.78,0); panel.BackgroundColor3=P.cream; panel.Visible=false; panel.Parent=gui; corner(panel,16)
local title=text(panel,"Title","",24,P.forest); title.Position=UDim2.fromOffset(22,18); title.Size=UDim2.new(1,-260,0,36)
local close=button(panel,"Close","Close",function() panel.Visible=false end); close.AnchorPoint=Vector2.new(1,0); close.Position=UDim2.new(1,-18,0,16); close.Size=UDim2.fromOffset(104,48); close.BackgroundColor3=P.brick
local back=button(panel,"Back","Back",function() panel.Visible=false end); back.AnchorPoint=Vector2.new(1,0); back.Position=UDim2.new(1,-132,0,16); back.Size=UDim2.fromOffset(104,48)
local instructions=text(panel,"Instructions","",16); instructions.Position=UDim2.fromOffset(22,62); instructions.Size=UDim2.new(1,-44,0,48)
local progress=text(panel,"Progress","",15,P.forest); progress.Position=UDim2.fromOffset(22,112); progress.Size=UDim2.new(1,-44,0,28)
local scroll=Instance.new("ScrollingFrame"); scroll.Name="ActionList"; scroll.Position=UDim2.fromOffset(22,148); scroll.Size=UDim2.new(1,-44,1,-170); scroll.BackgroundColor3=P.sage; scroll.BackgroundTransparency=.35; scroll.BorderSizePixel=0; scroll.ScrollBarThickness=10; scroll.AutomaticCanvasSize=Enum.AutomaticSize.Y; scroll.Parent=panel; corner(scroll,10)
local list=Instance.new("UIListLayout"); list.Padding=UDim.new(0,10); list.Parent=scroll
local pad=Instance.new("UIPadding"); pad.PaddingTop=UDim.new(0,12); pad.PaddingBottom=UDim.new(0,12); pad.PaddingLeft=UDim.new(0,12); pad.PaddingRight=UDim.new(0,12); pad.Parent=scroll

local currentView; local sequence=0; local sessionId=nil; local lastSnapshot={}; local cakeState={finaleState="LOCKED"}; local panelMode="closed"
local function freshId() sequence+=1; return string.format("client-%d-%d-%d",player.UserId,math.floor(os.clock()*1000),sequence) end
cakeButton.Activated:Connect(function() renderCake(cakeState) end)
local function sendActivity(activityId,roundId,stepId,payload) if not sessionId then status.Text="Waiting for birthday session"; return end; action:FireServer({kind="ActivityAction",sessionId=sessionId,activityId=activityId,roundId=roundId or "",stepId=stepId or "",actionId=freshId(),payload=payload or {}}) end
local function clear() for _,x in ipairs(scroll:GetChildren()) do if x:IsA("TextButton") or x:IsA("TextLabel") then x:Destroy() end end end
local function petalCount(p) if type(p)=="number" then return p end; local n=0; if type(p)=="table" then for _,v in pairs(p) do if v then n+=1 end end end; return n end
local function closeActivity() if currentView and sessionId then action:FireServer({kind="CloseActivity",sessionId=sessionId,activityId=currentView.activityId,roundId=currentView.roundId,actionId=freshId()}) end; currentView=nil; panelMode="closed"; panel.Visible=false end
close.Activated:Connect(closeActivity); back.Activated:Connect(closeActivity)
local function render(view)
	if type(view)~="table" then return end
	if not view.activityId then
		renderJournal(view); return
	end
	currentView=view; panelMode="activity"; panel.Visible=true; title.Text=view.title or view.activityId; instructions.Text=view.instructions or "Choose an available action."
	local p=view.progress or {}; progress.Text=string.format("Progress  •  %s / %s   [%s]",tostring(p.done or 0),tostring(p.total or 0),tostring(view.state or "")); clear()
	local order=1
	local reading=view.reading
	if type(reading)=="table" and (type(reading.title)=="string" or type(reading.text)=="string") then
		local readingTitle=text(scroll,"ReadingTitle",reading.title or "Reading",18,P.forest); readingTitle.LayoutOrder=order; readingTitle.AutomaticSize=Enum.AutomaticSize.Y; readingTitle.Size=UDim2.new(1,0,0,0); order+=1
		local readingText=text(scroll,"ReadingText",reading.text or "",16,P.ink); readingText.LayoutOrder=order; readingText.AutomaticSize=Enum.AutomaticSize.Y; readingText.Size=UDim2.new(1,0,0,0); order+=1
	end
	for _,d in ipairs(view.availableActions or {}) do local b=button(scroll,"Action_"..tostring(d.id),d.label or d.id,function() if d.enabled~=false then sendActivity(view.activityId,view.roundId,d.stepId,d.payload) end end); b.LayoutOrder=order; order+=1; if d.enabled==false then b.Active=false; b.AutoButtonColor=false; b.BackgroundColor3=P.wood; b.Text=(d.label or d.id).." — "..(d.reason or "Unavailable") end end
	if view.canReplay then local b=button(scroll,"Replay","Replay this activity",function() requestView(view.activityId,true) end); b.LayoutOrder=order end
	if view.errorText then local e=text(scroll,"Error",view.errorText,14,P.brick); e.Size=UDim2.new(1,0,0,40) end
end
function renderJournal(s)
 currentView=nil; panelMode="journal"; clear(); panel.Visible=true; title.Text="Birthday journal"; instructions.Text="Explore together and help complete each petal."; local petals=s.petals or {}; local rounds=s.rounds or {}; local names={Q01="Everything Tucked In • Bedroom",Q02="Jasper's Favorite Things • Bedroom / Jasper yard",Q03="A Tiny World of Her Own • U District booth / bedroom display",Q04="One More Chapter • Quad / bedroom",Q05="A Labubu Wish • U District",Q06="Something Delicious • Three food counters"}; local order=1
 for _,id in ipairs({"Q01","Q02","Q03","Q04","Q05","Q06"}) do local r=rounds[id] or {}; local done=petals[id] or r.completed or false; local e=text(scroll,"Journal_"..id,string.format("%s • %s",names[id],done and "Petal complete" or "Explore"),16,done and P.forest or P.ink); e.LayoutOrder=order; e.Size=UDim2.new(1,0,0,34); order+=1 end
 local f=text(scroll,"JournalFund",string.format("Shared fund • %s",tostring(s.fundBalance or 0)),17,P.golden); f.LayoutOrder=order; f.Size=UDim2.new(1,0,0,34)
end
function renderCake(state)
 currentView=nil; panelMode="cake"; cakeState=state or cakeState; clear(); panel.Visible=true; title.Text="Birthday cake"; instructions.Text="Gather voluntarily, then choose a celebration action."; progress.Text="Finale • "..tostring(cakeState.finaleState or "LOCKED"); local order=1; local phase=cakeState.finaleState
 local methods={}; local host=player.UserId==lastSnapshot.phuongUserId or player.UserId==lastSnapshot.hostUserId; if phase=="INVITED" then if host then methods={"CancelInvite","Cut"} end elseif phase=="CUT" or phase=="EATING" then methods={"Eat"} elseif host and petalCount(lastSnapshot.petals)>=6 then methods={"Invite"} end
 for _,method in ipairs(methods) do local b=button(scroll,"Cake_"..method,method,function() if sessionId then action:FireServer({kind="Cake",action=method,sessionId=sessionId,actionId=freshId()}) end end); b.LayoutOrder=order; order+=1 end
end
local function snapshot(s)
	if type(s)~="table" then return end
	for k,v in pairs(s) do lastSnapshot[k]=v end; s=lastSnapshot; if s.cake then cakeState=s.cake; if panelMode=="cake" and panel.Visible then renderCake(cakeState) end end
	if type(s.sessionId)=="string" and s.sessionId~="" then sessionId=s.sessionId end
	local petals=s.petals; local petalCountValue=petalCount(petals); flower.Text=string.format("✿ %d / 6 petals%s",petalCountValue,petalCountValue==6 and "  •  Cake ready" or ""); fund.Text=string.format("Shared fund  •  %s",tostring(s.fundBalance or s.fund or 0))
	local q=s.queue or {}; local members=q.members or {}; local queueCount=q.count or #members; local joined=table.find(members,player.UserId)~=nil; local remaining=q.remaining and math.ceil(q.remaining) or 0; queueState.Text=string.format("Queue: %s • %d/%d • %ds • %s",joined and "joined" or "waiting",queueCount,q.capacity or 10,remaining,q.state or "Empty")
	cakeButton.Visible=(petalCountValue>=6)
end
function requestView(id,replay) if not sessionId then status.Text="Waiting for birthday session"; return end; action:FireServer({kind="RequestView",sessionId=sessionId,activityId=id,actionId=freshId(),replay=replay==true}) end
journal.Activated:Connect(function() if sessionId then action:FireServer({kind="RequestJournal",sessionId=sessionId,actionId=freshId()}) else status.Text="Waiting for birthday session" end end)
action.OnClientEvent:Connect(function(payload)
	if type(payload)~="table" then return end
	if type(payload.sessionId)=="string" and payload.sessionId~="" then sessionId=payload.sessionId end
	if payload.snapshot then snapshot(payload.snapshot) end; if payload.queue then snapshot({queue=payload.queue}) end
	if payload.view then render(payload.view) end; if payload.journal then renderJournal(payload.journal) end; if payload.cake then cakeState=payload.cake; renderCake(payload.cake) end
	if payload.kind=="Result" then status.Text=payload.ok and "A cozy action was accepted" or (payload.errorText or payload.code or "Action unavailable") end
end)
local function bind(p)
	if not p:IsA("ProximityPrompt") or p:GetAttribute("MVPBound") then return end
	local id=p:GetAttribute("ActivityId") or p.Parent:GetAttribute("ActivityId"); if not id then return end
	p:SetAttribute("MVPBound",true); p.Triggered:Connect(function() if id=="Cake" then renderCake(cakeState) else requestView(id) end end)
end
for _,x in ipairs(workspace:GetDescendants()) do bind(x) end; workspace.DescendantAdded:Connect(bind)
UserInputService.InputBegan:Connect(function(input,processed)
	if processed or not panel.Visible or not currentView then return end
	local step=input.KeyCode==Enum.KeyCode.Q and "rotate-left" or input.KeyCode==Enum.KeyCode.E and "rotate-right"
	if step then for _,d in ipairs(currentView.availableActions or {}) do local rotates=d.payload and d.payload.action=="rotate" and ((step=="rotate-left" and d.payload.direction==-1) or (step=="rotate-right" and d.payload.direction==1)); if d.enabled~=false and (d.stepId==step or d.id==step or rotates) then sendActivity(currentView.activityId,currentView.roundId,d.stepId,d.payload); break end end end
end)
local function refresh() status.Text=string.format("Birthday session  •  arrival %s",player:GetAttribute("MVPArrivalStatus") or "Loading") end
player.AttributeChanged:Connect(refresh); refresh(); action:FireServer({kind="RequestSnapshot",actionId=freshId()})
]=],
    ["roblox/mvp/install.luau"] = [=[-- Edit-mode integrator. Require this module and invoke the returned function with measured inputs.
local REQUIRED_ANCHORS = { "GameplayBedroomArrival", "Q01Bed", "JasperBedroomStart", "JasperFetchYard", "Q03FairCraft", "Q03BedroomDisplay", "Q04QuadReading", "Q05UDistrictVending", "Q06FOBCounter", "Q06AladdinsCounter", "Q06Serving", "FinalePatio", "BirthdayLobbyQueue" }
local STATIONS = { "Q01Station", "Q02Station", "Q03Station", "Q04Station", "Q05Station", "Q06Station", "CakeFinale", "LobbyQueue" }
local ENVIRONMENT = { "SeattleBoundary", "NightLighting", "GrassDecoration" }
local PALETTE = { forest=Color3.fromHex("365744"), sage=Color3.fromHex("A8B995"), cream=Color3.fromHex("F5F0E4"), wood=Color3.fromHex("95674B"), blossom=Color3.fromHex("E8B7C6"), brick=Color3.fromHex("B66C68"), golden=Color3.fromHex("E8C779"), ink=Color3.fromHex("26382E") }

return function(context)
    assert(context and context.Root, "installer requires measured context.Root")
    local root = context.Root
    local mvp = assert(context.MVP or root:FindFirstChild("MVP"), "MVP folder required")
    local anchors = assert(context.Anchors or mvp:FindFirstChild("Anchors"), "resolved measured Anchors required")
    local options = assert(context.Options, "measured Options are required")
    assert(options.OuterQuadBounds and options.Keepouts and options.WorldBounds, "Options require OuterQuadBounds, Keepouts, and WorldBounds provenance")
    local resolvedAnchors, missing = {}, {}
    for _, name in ipairs(REQUIRED_ANCHORS) do
        local anchor = anchors[name] or anchors:FindFirstChild(name, true)
        local status = anchor and anchor:GetAttribute("PlacementStatus")
        if not anchor or not anchor:IsA("BasePart") or type(status) ~= "string" or status == "" or status == "UNRESOLVED_LIVE_ANCHOR" or status == "UNRESOLVED" then table.insert(missing, "Anchor:" .. name) else resolvedAnchors[name] = anchor end
    end
    local builders = assert(context.Builders or script.Parent:FindFirstChild("builders"), "builders folder required")
    local function builder(name) return builders.FindFirstChild and builders:FindFirstChild(name) or builders[name] end
    for _, name in ipairs(STATIONS) do if not builder(name) then table.insert(missing, "Builder:" .. name) end end
    for _, name in ipairs(ENVIRONMENT) do if not builder(name) then table.insert(missing, "Builder:" .. name) end end
    if #missing > 0 then error("MVP preflight failed before scene change: " .. table.concat(missing, ", ")) end
    local stations = mvp:FindFirstChild("Stations") or Instance.new("Folder"); stations.Name = "Stations"
    local environment = mvp:FindFirstChild("Environment") or Instance.new("Folder"); environment.Name = "Environment"
    local selected = {}
    if context.OnlyFeature ~= nil then
        assert(type(context.OnlyFeature) == "string" and context.OnlyFeature ~= "", "OnlyFeature must be a known nonempty string")
        for _, name in ipairs(STATIONS) do if name == context.OnlyFeature then table.insert(selected, {name=name, parent=stations}) end end
        for _, name in ipairs(ENVIRONMENT) do if name == context.OnlyFeature then table.insert(selected, {name=name, parent=environment}) end end
        assert(#selected == 1, "OnlyFeature must select exactly one canonical builder")
    else
        for _, name in ipairs(STATIONS) do table.insert(selected, {name=name, parent=stations}) end
        for _, name in ipairs(ENVIRONMENT) do table.insert(selected, {name=name, parent=environment}) end
    end
    local original, staged, restores = {}, {}, {}
    local function safeReplace(ownedName, ownedParent, name, factory)
        assert(name == ownedName, "SafeReplace name outside caller ownership"); assert(ownedParent == stations or ownedParent == environment, "SafeReplace parent outside MVP ownership")
        local parent = ownedParent
        local made = factory(); assert(made and (made:IsA("Folder") or made:IsA("Model")) and not made.Parent, "factory must return detached Folder/Model")
        local old = parent:FindFirstChild(name); original[name] = { old=old, parent=parent }; if old then old.Parent = nil end
        made.Name = name; made.Parent = parent; staged[name] = made; return made
    end
    local shared = { Root=root, MVP=mvp, Anchors=resolvedAnchors, Palette=PALETTE, RequiredPalette=PALETTE, Options=options, Lighting=context.Lighting or game:GetService("Lighting") }
    function shared:ValidateAnchors(names) for _, name in ipairs(names) do local a = self.Anchors[name]; local s = a and a:GetAttribute("PlacementStatus"); assert(a and a:IsA("BasePart") and type(s)=="string" and s~="" and s~="UNRESOLVED_LIVE_ANCHOR" and s~="UNRESOLVED", "unresolved anchor: " .. name) end return true end
    local ok, result = pcall(function()
        stations.Parent = mvp; environment.Parent = mvp
        local out = {}
        for _, entry in ipairs(selected) do local name, parent = entry.name, entry.parent; local c = table.clone(shared); c.SafeReplace=function(n,f) return safeReplace(name,parent,n,f) end; out[name] = require(builder(name))(c); if out[name].Restore then table.insert(restores,out[name].Restore) end end
        return out
    end)
    if not ok then for i=#restores,1,-1 do pcall(restores[i]) end; for _, item in pairs(staged) do if item then item:Destroy() end end; for _, backup in pairs(original) do if backup.old then backup.old.Parent = backup.parent end end; error("MVP install rolled back owned outputs: " .. tostring(result)) end
    return { folders = result, manifest = { RequiredAnchors=REQUIRED_ANCHORS, Stations=STATIONS, Environment=ENVIRONMENT, Measurements="provided by Task01", PaletteTokens=PALETTE } }
end
]=],
    ["roblox/mvp/server/activities/Q01.luau"] = [=[-- Q01 Everything Tucked In. Server-owned activity rules; no currency or petal ownership here.
local Q01 = {}
Q01.__index = Q01

Q01.ActivityId = "Q01"
Q01.StepIds = { "blanket_left", "blanket_right", "blanket_foot", "pillow_left", "pillow_right", "plush_dog", "plush_dinosaur" }
Q01.StepLabels = {
	blanket_left = "Smooth the left blanket",
	blanket_right = "Smooth the right blanket",
	blanket_foot = "Fold the foot blanket",
	pillow_left = "Place the left pillow",
	pillow_right = "Place the right pillow",
	plush_dog = "Tuck in the round-bellied dog",
	plush_dinosaur = "Tuck in the dinosaur plush",
}
Q01.ReservationSeconds = 15

local function now(context)
	return context.clock and context.clock() or os.clock()
end

function Q01.new(context)
	assert(context and context.session, "Q01 requires a shared session")
	local self = setmetatable({
		session = context.session,
		clock = context.clock,
		reserved = {},
		reservationByActor = {},
		finalChoices = { soft_snug = "Soft and snug", neat_layered = "Neatly layered" },
		visibleState = {},
		currentRoundId = nil,
		finishedPreview = nil,
	}, Q01)
	return self
end

Q01.New = Q01.new

function Q01:_round()
	return self.currentRoundId and self.session.rounds[self.currentRoundId] or nil
end

function Q01:_requireRound(roundId)
	assert(roundId == self.currentRoundId, "stale Q01 round")
	local round = self.session.rounds[roundId]
	assert(round and round.activityId == self.ActivityId and round.state == "IN_PROGRESS", "Q01 round is not active")
	return round
end

function Q01:CreateRound(request)
	local actorUserId = request.actorUserId
	local roundId = request.roundId
	local isReplay = request.isReplay
	assert(not self.currentRoundId or not self:_round() or self:_round().state ~= "IN_PROGRESS", "Q01 round already active")
	local round = self.session:CreateRound(self.ActivityId, roundId, actorUserId, isReplay == true)
	self.currentRoundId = roundId
	self.reserved = {}
	self.reservationByActor = {}
	self.visibleState = {}
	return self:GetView(request.actorUserId)
end

Q01.Start = Q01.CreateRound

function Q01:Reserve(request)
	local round = self:_requireRound(request.roundId)
	if not self.StepLabels[request.stepId] then
		return { ok = false, code = "INVALID_STEP", message = "That is not a bed task—choose a highlighted step" }
	end
	local existing = round.steps[request.stepId]
	if existing then return { ok = false, code = "ALREADY_DONE", message = "That spot is already handled—choose another bed task", accepted = existing } end
	local prior = self.reserved[request.stepId]
	local timestamp = now(self)
	if prior and prior.expiresAt > timestamp and prior.actorUserId ~= request.actorUserId then
		return { ok = false, code = "IN_USE", message = "Someone else is handling that spot; choose another bed task" }
	end
	if prior then self.reservationByActor[prior.actorUserId] = nil end
	local reservation = { actorUserId = request.actorUserId, stepId = request.stepId, expiresAt = timestamp + self.ReservationSeconds }
	self.reserved[request.stepId] = reservation
	self.reservationByActor[request.actorUserId] = reservation
	return { ok = true, code = "RESERVED", reservation = reservation, label = self.StepLabels[request.stepId] }
end

function Q01:Cancel(request)
	local reservation = self.reserved[request.stepId]
	if reservation and reservation.actorUserId == request.actorUserId then
		self.reserved[request.stepId] = nil
		self.reservationByActor[request.actorUserId] = nil
	end
	return self:GetView()
end

function Q01:ReleaseActor(actorUserId)
	local reservation = self.reservationByActor[actorUserId]
	if reservation then
		self.reserved[reservation.stepId] = nil
		self.reservationByActor[actorUserId] = nil
	end
	return self:GetView(actorUserId)
end

function Q01:ExpireReservations(at)
	local timestamp = at or now(self)
	for stepId, reservation in pairs(self.reserved) do
		if reservation.expiresAt <= timestamp then
			self.reserved[stepId] = nil
			if self.reservationByActor[reservation.actorUserId] == reservation then self.reservationByActor[reservation.actorUserId] = nil end
		end
	end
end

function Q01:Apply(request)
	local action = request.payload and request.payload.action
	if not request.stepId and request.payload then request.stepId = request.payload.stepId end
	if action == "reserve" and self.reserved[request.stepId] and self.reserved[request.stepId].actorUserId == request.actorUserId then action = "place" end
	if action == "reserve" then
		local result = self:Reserve(request)
		result.view = self:GetView(request.actorUserId)
		return result
	elseif action == "cancel" then
		return { ok = true, code = "CANCELLED", view = self:Cancel(request) }
	elseif action == "finish" then
		return self:Finish(request)
	end
	local round = self:_requireRound(request.roundId)
	assert(request.actionId and request.actorUserId, "Q01 action identity is required")
	self:ExpireReservations()
	local existing = round.steps[request.stepId]
	if existing then return { ok = false, code = "ALREADY_DONE", message = "That spot is already handled—choose another bed task", accepted = existing } end
	local reservation = self.reserved[request.stepId]
	assert(reservation and reservation.actorUserId == request.actorUserId, "reserve this bed spot first")
	local accepted = self.session:ApplyStep({ sessionId = self.session.sessionId, activityId = self.ActivityId, roundId = request.roundId, stepId = request.stepId, actionId = request.actionId, actorUserId = request.actorUserId })
	self.reserved[request.stepId] = nil
	self.reservationByActor[request.actorUserId] = nil
	self.visibleState[request.stepId] = true
	return { ok = true, code = "ACCEPTED", accepted = accepted, view = self:GetView(request.actorUserId) }
end

function Q01:Finish(request)
	local prior = request.actionId and self.session.receipts[request.actionId]
	if prior then return { ok = true, code = "DUPLICATE", receipt = prior, preview = self.finishedPreview, view = self:GetView(request.actorUserId) } end
	local round = self:_requireRound(request.roundId)
	local choiceId = request.choiceId or (request.payload and request.payload.choiceId)
	local presence = self.session.presence or {}
	local authorized = self.session:IsPresent(request.actorUserId) and self.session:CanSpend(request.actorUserId, presence)
	assert(authorized, "only present Phuong or fallback host can finish Q01")
	assert(self.finalChoices[choiceId], "unknown Q01 finishing choice")
	for _, stepId in ipairs(self.StepIds) do assert(round.steps[stepId], "all seven Q01 steps are required") end
	local receipt = self.session:CompleteRound({ sessionId = self.session.sessionId, activityId = self.ActivityId, roundId = request.roundId, actionId = request.actionId, actorUserId = request.actorUserId })
	self.finishedPreview = { choiceId = choiceId, choiceLabel = self.finalChoices[choiceId], receipt = receipt }
	self.currentRoundId = request.roundId
	return { ok = true, code = "FINISHED", receipt = receipt, preview = self.finishedPreview, view = self:GetView(request.actorUserId) }
end

function Q01:GetView(actorUserId)
	self:ExpireReservations()
	local round = self:_round()
	local accepted = {}
	if round then for stepId in pairs(round.steps) do accepted[stepId] = true end end
	local phase = "INACTIVE"
	if round then phase = round.state == "COMPLETED" and "FINISHED" or (next(accepted) and "IN_PROGRESS" or "OPEN") end
	if round and #Q01.StepIds == 7 then
		local complete = true
		for _, stepId in ipairs(Q01.StepIds) do if not accepted[stepId] then complete = false break end end
		if complete and round.state == "IN_PROGRESS" then phase = "READY_FOR_PHUONG" end
	end
	local completed = 0
	for _ in pairs(accepted) do completed += 1 end
	local actions = {}
	for _, stepId in ipairs(self.StepIds) do
		local done = accepted[stepId] ~= nil
		local reservation = self.reserved[stepId]
		local held = reservation ~= nil
		local owned = held and reservation.actorUserId == actorUserId
		local action = owned and "place" or "reserve"
		table.insert(actions, { id = action .. ":" .. stepId, label = self.StepLabels[stepId], stepId = stepId, payload = { action = action, stepId = stepId }, enabled = not done and (not held or owned), reason = done and "Already handled" or (held and not owned and "In use" or nil) })
		if owned then table.insert(actions, { id = "cancel:" .. stepId, label = "Cancel " .. self.StepLabels[stepId], stepId = stepId, payload = { action = "cancel", stepId = stepId }, enabled = true }) end
	end
	if phase == "READY_FOR_PHUONG" then
		local presence = self.session.presence or {}
		local canFinish = actorUserId and self.session:IsPresent(actorUserId) and self.session:CanSpend(actorUserId, presence)
		for choiceId, choiceLabel in pairs(self.finalChoices) do
			table.insert(actions, { id = "finish:" .. choiceId, label = choiceLabel, stepId = "finish", payload = { action = "finish", choiceId = choiceId }, enabled = canFinish == true, reason = canFinish and nil or "Phuong chooses the finishing style" })
		end
	end
	return { activityId = self.ActivityId, roundId = self.currentRoundId, state = phase, title = "Everything Tucked In", instructions = phase == "READY_FOR_PHUONG" and "Choose how Phuong finishes the bed" or "Help with an available bed step", progress = { done = completed, total = 7 }, availableActions = actions, acceptedStepIds = accepted, contributors = round and round.contributors or {}, busyReason = nil, errorText = nil, canReplay = phase == "FINISHED", visibleState = self.visibleState, finishedPreview = self.finishedPreview, reservationSeconds = self.ReservationSeconds }
end

return Q01
]=],
    ["roblox/mvp/server/activities/Q02.luau"] = [=[-- Q02 Jasper's Favorite Things. Server-owned activity adapter.
-- Does not own fund/petal logic; SessionService is the only reward authority.

local Activity = {}
Activity.__index = Activity

local STEPS = {"greet", "rabbitFound", "rabbitReturned", "fetch1", "fetch2", "fetch3", "greenie"}
local FETCH_STEPS = {fetch1 = true, fetch2 = true, fetch3 = true}
local function clone(value)
    if type(value) ~= "table" then return value end
    local result = {}
    for key, item in pairs(value) do result[key] = clone(item) end
    return result
end

function Activity.new(ctx)
    assert(ctx and ctx.session and ctx.world, "Q02 requires session and world context")
    local self = setmetatable({
        session = ctx.session,
        context = ctx.world,
        clock = ctx.clock or os.clock,
        round = nil,
        state = "IDLE",
        rabbitBasket = nil,
        accepted = {},
        actionReceipts = {},
        contributors = {},
        busyThrowAction = nil,
        busyThrowActor = nil,
        targetIndex = 0,
        reservations = {},
        replayCount = 0,
        jasperMode = "BEDROOM",
        lastError = nil,
    }, Activity)
    return self
end

function Activity:_actorId(request)
    assert(request and type(request.actorUserId) == "number" and request.actorUserId > 0 and request.actorUserId % 1 == 0, "authenticated actorUserId is required")
    return request.actorUserId
end

function Activity:_present(actorUserId)
    if self.context.isPresent then return self.context.isPresent(actorUserId) end
    return self.session:IsPresent(actorUserId)
end

function Activity:_action(request)
    assert(request and request.actionId and request.roundId and request.stepId, "Q02 action fields are required")
    assert(self.round and request.roundId == self.round.roundId, "Q02 round is not active")
    local prior = self.actionReceipts[request.actionId]
    if prior then return prior end
    assert(self:_present(self:_actorId(request)), "actor is not present")
end

function Activity:CreateRound(request)
    assert(request and request.activityId == "Q02" and request.roundId, "Q02 round request is invalid")
    assert(not self.round or self.state == "COMPLETED", "Q02 already has an active round")
    assert(self:_present(self:_actorId(request)), "actor is not present")
    local created = self.session:CreateRound("Q02", request.roundId, self:_actorId(request))
    self.round = { activityId = "Q02", roundId = request.roundId, startedBy = created.startedBy, isReplay = created.isReplay }
    self.replayCount = request.replay == true and self.replayCount + 1 or self.replayCount
    self.state, self.jasperMode = "GREETING", "BEDROOM"
    self.rabbitBasket, self.targetIndex = nil, 0
    self.accepted, self.actionReceipts, self.contributors, self.reservations = {}, {}, {}, {}
    self.busyThrowAction, self.busyThrowActor = nil, nil
    self.lastError = nil
    return clone(self.round)
end

function Activity:_accept(request)
    local actorUserId = self:_actorId(request)
    local prior = self.actionReceipts[request.actionId]
    if prior then return prior end
    assert(not self.accepted[request.stepId], "step already accepted")
    local accepted = self.session:ApplyStep({sessionId = self.session.sessionId, activityId = "Q02", roundId = request.roundId, stepId = request.stepId, actionId = request.actionId, actorUserId = actorUserId})
    if accepted.receipt then accepted = accepted.receipt end
    self.accepted[request.stepId] = accepted
    self.actionReceipts[request.actionId] = accepted
    self.contributors[actorUserId] = true
    return accepted
end

function Activity:_requirePrevious(stepId)
    local index
    for position, step in ipairs(STEPS) do if step == stepId then index = position end end
    assert(index, "unknown Q02 step")
    for position = 1, index - 1 do assert(self.accepted[STEPS[position]], "previous Q02 step is incomplete") end
end

function Activity:_basketForRound()
    local chooser = self.context.chooseRabbitBasket
    local value = chooser and chooser(self.round.roundId) or 1
    return math.clamp(tonumber(value) or 1, 1, 3)
end

function Activity:Apply(request)
    local prior = request and request.actionId and self.actionReceipts[request.actionId]
    if prior then return {ok = true, code = "duplicate", receipt = prior, view = self:GetView(self:_actorId(request))} end
    self:_action(request)
    local actorUserId = self:_actorId(request)
    local stepId = request.stepId
    if stepId == "greet" then
        assert(self.state == "GREETING", "greeting is closed")
        local receipt = self:_accept(request)
        self.state, self.jasperMode = "LEADING", "LEADING_TO_YARD"
        if self.context.moveJasperToYard then self.context.moveJasperToYard() end
        return {ok = true, code = "accepted", receipt = receipt, view = self:GetView(actorUserId)}
    elseif stepId == "rabbitFound" then
        self:_requirePrevious(stepId)
        assert(self.state == "LEADING" or self.state == "RABBIT", "rabbit search is not available")
        if not self.rabbitBasket then self.rabbitBasket = self:_basketForRound() end
        if tonumber(request.payload and request.payload.basketIndex) ~= self.rabbitBasket then
            return {ok = false, code = "empty_basket", receipt = {activityId = "Q02", roundId = self.round.roundId, stepId = "rabbitFound", actionId = request.actionId, accepted = false}, view = self:GetView(actorUserId)}
        end
        local receipt = self:_accept(request)
        self.state = "RABBIT"
        return {ok = true, code = "accepted", receipt = receipt, view = self:GetView(actorUserId)}
    elseif stepId == "rabbitReturned" then
        self:_requirePrevious(stepId)
        assert(self.state == "RABBIT", "rabbit is not ready for return")
        local reservation = self.reservations.rabbit
        if reservation and reservation ~= actorUserId then error("rabbit is being carried by another player") end
        self.reservations.rabbit = nil
        local receipt = self:_accept(request)
        self.state, self.jasperMode = "FETCH", "FETCH_READY"
        if self.context.presentFetchTarget then self.context.presentFetchTarget(1) end
        return {ok = true, code = "accepted", receipt = receipt, view = self:GetView(actorUserId)}
    elseif FETCH_STEPS[stepId] then
        self:_requirePrevious(stepId)
        assert(self.state == "FETCH", "fetch is not available")
        local expected = self.targetIndex + 1
        assert(tonumber(request.payload and request.payload.targetIndex) == expected, "wrong fetch target")
        assert(not self.busyThrowAction, "fetch target is occupied")
        self.busyThrowAction, self.busyThrowActor = request.actionId, actorUserId
        local accepted = self:_accept(request)
        self.busyThrowAction, self.busyThrowActor = nil, nil
        self.targetIndex = expected
        if expected < 3 and self.context.presentFetchTarget then self.context.presentFetchTarget(expected + 1) end
        if expected == 3 then self.state = "GREENIE" end
        return {ok = true, code = "accepted", receipt = accepted, view = self:GetView(actorUserId)}
    elseif stepId == "greenie" then
        self:_requirePrevious(stepId)
        assert(self.state == "GREENIE", "Greenie is not available")
        local receipt = self:_accept(request)
        self.state, self.jasperMode = "COMPLETED", "CELEBRATING"
        return {ok = true, code = "completed", receipt = self.session:CompleteRound({sessionId = self.session.sessionId, activityId = "Q02", roundId = self.round.roundId, actionId = request.actionId .. ":complete", actorUserId = actorUserId}), view = self:GetView(actorUserId)}
    elseif stepId == "pet" then
        assert(self.state == "COMPLETED", "petting is available after Greenie")
        if self.context.petJasper then self.context.petJasper(actorUserId) end
        return {ok = true, code = "petted", receipt = {activityId = "Q02", roundId = self.round.roundId, stepId = "pet", actionId = request.actionId, reward = 0, petalGranted = false}, view = self:GetView(actorUserId)}
    end
    error("unknown Q02 action: " .. tostring(stepId))
end

function Activity:ReleaseActor(actorUserId)
    for key, value in pairs(self.reservations) do if value == actorUserId then self.reservations[key] = nil end end
    if self.busyThrowActor == actorUserId then self.busyThrowAction, self.busyThrowActor = nil, nil end
end

function Activity:GetView(actorUserId)
    local actions = {}
    if self.state == "GREETING" then actions = {{id="greet", label="Say hi to Jasper", stepId="greet", payload={}, enabled=true}}
    elseif self.state == "LEADING" then actions = {
        {id="rabbitFound-1", label="Inspect basket 1", stepId="rabbitFound", payload={basketIndex=1}, enabled=true},
        {id="rabbitFound-2", label="Inspect basket 2", stepId="rabbitFound", payload={basketIndex=2}, enabled=true},
        {id="rabbitFound-3", label="Inspect basket 3", stepId="rabbitFound", payload={basketIndex=3}, enabled=true},
    }
    elseif self.state == "RABBIT" then actions = {{id="rabbitReturned", label="Return rabbit", stepId="rabbitReturned", payload={}, enabled=true}}
    elseif self.state == "FETCH" then actions = {{id="fetch" .. tostring(self.targetIndex + 1), label="Throw", stepId="fetch" .. tostring(self.targetIndex + 1), payload={targetIndex=self.targetIndex + 1}, enabled=self.busyThrowAction == nil, reason=self.busyThrowAction and "Target occupied" or nil}}
    elseif self.state == "GREENIE" then actions = {{id="greenie", label="Give Greenie", stepId="greenie", payload={}, enabled=true}}
    elseif self.state == "COMPLETED" then actions = {{id="pet", label="Pet Jasper", stepId="pet", payload={}, enabled=true}} end
    return {activityId = "Q02", roundId = self.round and self.round.roundId, state = self.state, title = "Jasper's Favorite Things", instructions = "Help Jasper find his rabbit and fetch three toys.", progress = {done = self.targetIndex, total = 3}, availableActions = actions, acceptedStepIds = clone(self.accepted), contributors = clone(self.contributors), busyReason = self.busyThrowAction and "fetch_target_occupied" or nil, errorText = self.lastError, canReplay = self.state == "COMPLETED"}
end

return Activity
]=],
    ["roblox/mvp/server/activities/Q03.luau"] = [=[local Q03 = {}
Q03.__index = Q03

local PARTS = {"rug", "chair", "bookcase", "side_table", "plant", "lamp"}
local SOCKETS = {rug="rugSocket", chair="chairSocket", bookcase="bookcaseSocket", side_table="sideTableSocket", plant="plantSocket", lamp="lampSocket"}
local function copy(t) local r = {}; for k,v in pairs(t) do if type(v) == "table" then r[k] = copy(v) else r[k] = v end end; return r end
local function now(self) return self.clock() end
local function validId(value) return type(value) == "string" and value ~= "" end
local function validActorId(value) return type(value) == "number" and value > 0 and value % 1 == 0 end

function Q03.new(options)
    assert(options and options.session and options.clock and options.context, "Q03 context dependencies are required")
    return setmetatable({session=options.session, actorResolver=options.actorResolver, clock=options.clock, context=options.context, rounds={}, actions={}, stateByRound={}, currentRoundId=nil}, Q03)
end

function Q03:_actor(request)
    local actorUserId = self.actorResolver and self.actorResolver(request) or request.actorUserId
    return actorUserId and actorUserId == request.actorUserId
end
function Q03:_canFinalize(actorUserId)
    if not self.session:IsPresent(actorUserId) then return false end
    if actorUserId == self.session.phuongUserId then return true end
    return not self.session:IsPresent(self.session.phuongUserId) and self.session.hostUserId ~= 0 and actorUserId == self.session.hostUserId
end
function Q03:_round(request) return self.stateByRound[request.roundId] end
function Q03:_view(roundId, actorUserId, errorText)
    local state = self.stateByRound[roundId]
    local accepted, contributors = {}, {}
    if state then for id in pairs(state.accepted) do table.insert(accepted, id) end; for id in pairs(state.contributors) do table.insert(contributors, id) end end
    local done = state and #self:_committedParts(state) or 0
    local actions = {}
    if state and state.status == "IN_PROGRESS" then
        for part, socket in pairs(SOCKETS) do
            local entry = state.sockets[socket]
            local enabled = entry.status == "AVAILABLE"
            table.insert(actions, {id="reserve:"..part, label="Place "..part, stepId="reserve:"..part, payload={action="reserve",socketId=socket,partId=part}, enabled=enabled, reason=enabled and nil or "Socket is reserved or placed"})
            if entry.status == "RESERVED" and entry.ownerUserId == actorUserId then
                table.insert(actions, {id="rotate-left:"..part,label="Rotate left",stepId="rotate-left:"..part,payload={action="rotate",socketId=socket,direction=-1},enabled=true})
                table.insert(actions, {id="rotate-right:"..part,label="Rotate right",stepId="rotate-right:"..part,payload={action="rotate",socketId=socket,direction=1},enabled=true})
                table.insert(actions, {id="place:"..part,label="Place",stepId="place:"..part,payload={action="place",socketId=socket,partId=part},enabled=true})
                table.insert(actions, {id="cancel:"..part,label="Cancel",stepId="cancel:"..part,payload={action="cancel",socketId=socket},enabled=true})
            end
        end
    elseif state and state.status == "COMPLETED" then
        local allowed = self:_canFinalize(actorUserId)
        for _, presentation in ipairs({"lamp_on", "lamp_off"}) do table.insert(actions, {id="finalize:"..presentation,label="Choose "..presentation,stepId="finalize:"..presentation,payload={action="finalize",presentation=presentation},enabled=allowed and state.finalizationReceipt == nil,reason=allowed and nil or "Phuong or configured host only"}) end
    end
    return {activityId="Q03", roundId=roundId, state=state and state.status or "NONE", title="A Tiny World of Her Own", instructions="Place each tiny piece in its matching socket.", progress={done=done,total=#PARTS}, availableActions=actions, acceptedStepIds=accepted, contributors=contributors, busyReason=state and state.busyReason or nil, errorText=errorText, canReplay=state and state.status == "COMPLETED" or false}
end

function Q03:CreateRound(request)
    assert(request and validId(request.sessionId) and request.activityId == "Q03" and validId(request.roundId) and validActorId(request.actorUserId) and self:_actor(request), "invalid Q03 round")
    assert(not self.rounds[request.roundId], "round already exists")
    self.session:CreateRound("Q03", request.roundId, request.actorUserId, request.replay == true)
    local sockets = {}; for _, socket in pairs(SOCKETS) do sockets[socket] = {status="AVAILABLE"} end
    self.rounds[request.roundId] = true
    self.currentRoundId = request.roundId
    self.stateByRound[request.roundId] = {status="IN_PROGRESS", sockets=sockets, committed={}, accepted={}, contributors={}, reservations={}, presentation=nil}
    return self:GetView(request.actorUserId, request.roundId)
end

function Q03:Apply(request)
    assert(request and validId(request.sessionId) and request.activityId == "Q03" and validId(request.roundId) and validId(request.actionId) and validActorId(request.actorUserId), "invalid Q03 request")
    assert(self:_actor(request), "unauthenticated actor")
    if self.actions[request.actionId] then return self.actions[request.actionId] end
    local state = assert(self:_round(request), "unknown Q03 round")
    local p = request.payload or {}; local action = p.action
    local result
    if action == "finalize" then
        if state.finalizationReceipt then
            self.actions[request.actionId] = state.finalizationReceipt
            return state.finalizationReceipt
        end
        assert(state.status == "COMPLETED", "all parts required")
        assert(self:_canFinalize(request.actorUserId), "not authorized or not present")
        assert(p.presentation == "lamp_on" or p.presentation == "lamp_off", "invalid presentation")
        state.finalPresentation=p.presentation
        state.finalizationReceipt={ok=true,code="FINALIZED",receipt={receiptId="q03-final:" .. request.roundId,roundId=request.roundId,presentation=p.presentation,actorUserId=request.actorUserId},view=self:_view(request.roundId,request.actorUserId)}
        result=state.finalizationReceipt
    else
    assert(state.status == "IN_PROGRESS", "Q03 round is not active")
    if action == "reserve" then
        local socket = assert(p.socketId, "socketId required"); local part = assert(p.partId, "partId required")
        assert(SOCKETS[part] == socket, "part does not fit socket")
        local entry = assert(state.sockets[socket], "unknown socket")
        assert(entry.status == "AVAILABLE", "socket is busy or placed")
        entry.status = "RESERVED"; entry.ownerUserId = request.actorUserId; entry.partId = part; entry.orientation = 0; entry.lastActivity = now(self)
        state.reservations[socket] = entry; result = {ok=true, socketId=socket, partId=part, orientation=0}
    elseif action == "rotate" then
        local entry = assert(state.reservations[p.socketId], "reservation required"); assert(entry.ownerUserId == request.actorUserId, "not reservation owner")
        assert(p.direction == 1 or p.direction == -1, "quarter-turn direction required")
        entry.orientation = (entry.orientation + p.direction) % 4; entry.lastActivity = now(self); result = {ok=true, orientation=entry.orientation}
    elseif action == "place" then
        local socket = assert(p.socketId, "socketId required"); local entry = assert(state.reservations[socket], "reservation required")
        assert(entry.ownerUserId == request.actorUserId, "not reservation owner"); assert(entry.partId == p.partId, "piece mismatch")
        state.committed[entry.partId] = {socketId=socket, orientation=entry.orientation, ownerUserId=request.actorUserId}; entry.status = "PLACED"; state.reservations[socket] = nil
        state.accepted[entry.partId] = true; state.contributors[request.actorUserId] = true; result = self.session:ApplyStep({sessionId=request.sessionId, activityId="Q03", roundId=request.roundId, stepId=entry.partId, actionId=request.actionId, actorUserId=request.actorUserId})
        if #self:_committedParts(state) == #PARTS then state.status = "COMPLETED"; result = {step=result, completion=self.session:CompleteRound({sessionId=request.sessionId, activityId="Q03", roundId=request.roundId, actionId="complete:" .. request.actionId, actorUserId=request.actorUserId})} end
    elseif action == "cancel" then
        local entry = assert(state.reservations[p.socketId], "reservation required"); assert(entry.ownerUserId == request.actorUserId, "not reservation owner")
        entry.status = "AVAILABLE"; entry.ownerUserId=nil; entry.partId=nil; entry.orientation=nil; entry.lastActivity=nil; state.reservations[p.socketId]=nil; result={ok=true, released=true}
    else error("unknown Q03 action") end
    end
    self.actions[request.actionId] = result; return result
end

function Q03:_committedParts(state) local r={}; for id in pairs(state.committed) do table.insert(r,id) end; return r end
function Q03:ExpireReservations(roundId)
    local state = assert(self:_round({roundId=roundId})); local current=now(self)
    for socket, entry in pairs(state.reservations) do if current - entry.lastActivity >= 15 then entry.status="AVAILABLE"; entry.ownerUserId=nil; entry.partId=nil; entry.orientation=nil; entry.lastActivity=nil; state.reservations[socket]=nil end end
end
function Q03:ReleaseActor(actorUserId, roundId)
    local rounds = roundId and {[roundId]=self:_round({roundId=roundId})} or self.stateByRound
    for _, state in pairs(rounds) do if state and state.status == "IN_PROGRESS" then for socket, entry in pairs(state.reservations) do if entry.ownerUserId == actorUserId then entry.status="AVAILABLE"; entry.ownerUserId=nil; entry.partId=nil; entry.orientation=nil; state.reservations[socket]=nil end end end end
end
function Q03:GetView(actorUserId)
    for roundId, state in pairs(self.stateByRound) do if state.status == "IN_PROGRESS" then self:ExpireReservations(roundId) end end
    return self:_view(self.currentRoundId, actorUserId)
end
Q03.PARTS = PARTS; Q03.SOCKETS = SOCKETS
return Q03
]=],
    ["roblox/mvp/server/activities/Q04.luau"] = [=[local Q04 = {}
Q04.__index = Q04

Q04.ActivityId = "Q04"
Q04.PassageIds = { "small-worlds", "night-pages", "next-chapter" }
Q04.Highlights = { "small-detail", "comforting-moment", "shared-spark" }
Q04.Reactions = { "moved", "cozy", "curious", "smile" }
Q04.Bookmarks = { "ribbon", "pressed-flower", "star-tab" }

Q04.Passages = {
    ["small-worlds"] = "A tiny place can hold more than its walls suggest. A folded corner, a favorite cup, or a little handmade scene may keep a whole afternoon safe inside it. Reading gives those small worlds room to open. You can linger over one detail, carry its feeling with you, or close the page knowing it will still be there later.",
    ["night-pages"] = "At night, one quiet page can make the room feel kinder. The light may be low, the day may be finished, and still a sentence can offer somewhere gentle to rest your attention. You do not have to reach the ending. Mark the place, notice what comforted you, and return whenever the next page feels right.",
    ["next-chapter"] = "Friends can share a chapter without turning every page together. One person notices a bright line, another pauses at a quiet thought, and someone else simply enjoys being nearby. The story keeps its welcome for all of them. A good next chapter leaves space for different rhythms, small discoveries, and the choice to come back tomorrow."
}

local function contains(list, value)
    for _, item in ipairs(list) do if item == value then return true end end
    return false
end

local function copyDraft(draft)
    local result = { highlights = {}, reaction = draft.reaction, bookmark = draft.bookmark, note = draft.note or "", passageId = draft.passageId, revision = draft.revision }
    for key, value in pairs(draft.highlights) do result.highlights[key] = value end
    return result
end

function Q04.new(options)
    assert(options and options.session and options.clock, "session and clock are required")
    return setmetatable({ session = options.session, clock = options.clock, context = options.context or {}, drafts = {}, activeRoundId = nil, roundComplete = false, usedActions = {}, contributors = {} }, Q04)
end

Q04.new = Q04.new
Q04.Module = Q04

function Q04:_draft(actorUserId, passageId)
    local key = tostring(actorUserId) .. ":" .. passageId
    self.drafts[key] = self.drafts[key] or { passageId = passageId, revision = 0, highlights = {}, reaction = nil, bookmark = nil, note = "" }
    return self.drafts[key], key
end

function Q04:CreateRound(request)
    assert(request.activityId == self.ActivityId and request.roundId and request.actorUserId, "invalid Q04 round")
    assert(self.activeRoundId == nil or self.roundComplete, "Q04 round is active")
    self.session:CreateRound(self.ActivityId, request.roundId, request.actorUserId, request.replay == true)
    self.activeRoundId, self.roundComplete = request.roundId, false
    return { activityId = self.ActivityId, roundId = request.roundId, state = "IN_PROGRESS" }
end

function Q04:Apply(request)
    assert(request and request.roundId == self.activeRoundId and request.actionId and request.actorUserId, "invalid Q04 action")
    if self.usedActions[request.actionId] then return self.usedActions[request.actionId] end
    local payload = request.payload or {}
    local passageId = payload.passageId
    assert(contains(self.PassageIds, passageId), "unknown passage")
    local draft = self:_draft(request.actorUserId, passageId)
    if payload.revision ~= nil then assert(payload.revision == draft.revision, "stale draft revision") end
    if payload.highlights then
        assert(#payload.highlights <= 3, "too many highlights")
        for _, value in ipairs(payload.highlights) do assert(contains(self.Highlights, value), "unknown highlight") end
        draft.highlights = {}
        for _, value in ipairs(payload.highlights) do draft.highlights[value] = true end
    end
    if payload.reaction ~= nil then assert(contains(self.Reactions, payload.reaction), "unknown reaction"); draft.reaction = payload.reaction end
    if payload.bookmark ~= nil then assert(contains(self.Bookmarks, payload.bookmark), "unknown bookmark"); draft.bookmark = payload.bookmark end
    if payload.note ~= nil then assert(type(payload.note) == "string" and #payload.note <= 500, "invalid note"); draft.note = payload.note end
    draft.revision += 1
    local accepted
    if not self.roundComplete then
        accepted = self.session:ApplyStep({ sessionId = self.session.sessionId, activityId = self.ActivityId, roundId = request.roundId, stepId = request.stepId or ("draft:" .. tostring(request.actorUserId) .. ":" .. passageId), actionId = request.actionId, actorUserId = request.actorUserId })
    else
        accepted = { activityId = self.ActivityId, roundId = request.roundId, stepId = "post-close-draft", actorUserId = request.actorUserId, acknowledgementOnly = true }
    end
    self.contributors[request.actorUserId] = true
    local receipt
    if payload.complete == true and not self.roundComplete then
        assert(next(draft.highlights) ~= nil and draft.reaction and draft.bookmark, "reading selections incomplete")
        receipt = self.session:CompleteRound({ sessionId = self.session.sessionId, activityId = self.ActivityId, roundId = request.roundId, actionId = request.actionId .. ":complete", actorUserId = request.actorUserId })
        self.roundComplete = true
    end
    local result = { ok = true, code = receipt and "COMPLETED" or (self.roundComplete and "ACKNOWLEDGED" or "SAVED"), receipt = receipt, draft = copyDraft(draft), view = self:GetView(request.actorUserId) }
    self.usedActions[request.actionId] = result
    return result
end

function Q04:GetView(actorUserId)
    local roundId = self.activeRoundId
    local passageId = "small-worlds"
    for key, draft in pairs(self.drafts) do
        if string.find(key, tostring(actorUserId) .. ":", 1, true) then passageId = draft.passageId; break end
    end
    local function choices(ids, labels, stepId, field)
        local result = {}
        for index, id in ipairs(ids) do
            local payload = { passageId = passageId, [field] = id }
            if field == "highlight" then payload.highlights = { id }; payload.highlight = nil end
            table.insert(result, { id = id, label = labels[index], stepId = stepId, payload = payload, enabled = not self.roundComplete })
        end
        return result
    end
    local actions = {}
    for _, action in ipairs(choices(self.Highlights, { "Small detail", "Comforting moment", "Shared spark" }, "highlight", "highlight")) do table.insert(actions, action) end
    for _, action in ipairs(choices(self.Reactions, { "Moved", "Cozy", "Curious", "Made me smile" }, "reaction", "reaction")) do table.insert(actions, action) end
    for _, action in ipairs(choices(self.Bookmarks, { "Ribbon", "Pressed flower", "Star tab" }, "bookmark", "bookmark")) do table.insert(actions, action) end
    local currentDraft = self:_draft(actorUserId, passageId)
    local ready = next(currentDraft.highlights) ~= nil and currentDraft.reaction ~= nil and currentDraft.bookmark ~= nil
    table.insert(actions, { id = "save", label = ready and "Save reading" or "Choose a highlight, reaction, and bookmark", stepId = "reading", payload = { passageId = passageId, complete = ready }, enabled = ready and not self.roundComplete, reason = ready and nil or "Reading choices are incomplete" })
    return { activityId = self.ActivityId, roundId = roundId, state = self.roundComplete and "ROUND_COMPLETE" or "IN_PROGRESS", title = "One More Chapter", instructions = "Choose a highlight, reaction, and bookmark; a note is optional.", reading = { title = "A quiet page", text = self.Passages[passageId], passageId = passageId }, progress = { done = self.roundComplete and 1 or 0, total = 1 }, availableActions = actions, acceptedStepIds = {}, contributors = self.contributors, busyReason = nil, errorText = nil, canReplay = self.roundComplete }
end

return Q04
]=],
    ["roblox/mvp/server/activities/Q05.luau"] = [=[local Config = require(script.Parent.Parent.Parent.shared.Config)
local Q05 = {}; Q05.__index = Q05
local Figures = {}; for _, id in ipairs(Config.RegularFigureIds) do table.insert(Figures, id) end; table.insert(Figures, Config.SecretFigureId)
local function valid(id) for _, value in ipairs(Figures) do if value == id then return true end end return false end
local function clone(map) local out = {}; for k, v in pairs(map) do out[k] = v end return out end
local function label(id)
    if id == Config.SecretFigureId then return "Secret figure" end
    local index = 0; for _, figureId in ipairs(Config.RegularFigureIds) do index += 1; if figureId == id then return "Big Into Energy figure " .. tostring(index) end end
    return "Unknown figure"
end

function Q05.new(ctx)
    assert(ctx and ctx.session, "Q05 requires session")
    local random = ctx.random or math.random
    local weighted = function()
        local roll = random()
        local cursor = 0
        for _, figureId in ipairs(Figures) do
            local weight = figureId == Config.SecretFigureId and Config.SecretProbability or Config.RegularProbability
            cursor += weight
            if roll <= cursor then return figureId end
        end
        return Config.SecretFigureId
    end
    return setmetatable({ctx = ctx, session = ctx.session, clock = ctx.clock or os.clock, outcome = ctx.outcome or weighted, roundId = nil, wanted = nil, misses = 0, fulfilled = false, petalAwarded = false, collection = {}, receipts = {}, pendingReveal = nil}, Q05)
end
function Q05:_present(userId) return self.session:IsPresent(userId) end
function Q05:_canSpend(userId) return self:_present(userId) and self.session:CanSpend(userId, self.session.presence) end
function Q05:CreateRound(request)
    assert(request and request.activityId == "Q05" and request.roundId and not self.roundId, "invalid Q05 round")
    self.session:CreateRound("Q05", request.roundId, request.actorUserId, request.replay == true); self.roundId = request.roundId
    return {activityId = "Q05", roundId = self.roundId, state = "READY"}
end
function Q05:_select(request)
    if self.receipts[request.actionId] then return {ok = true, code = "DUPLICATE", receipt = self.receipts[request.actionId], view = self:GetView(request.actorUserId)} end
    assert(self:_canSpend(request.actorUserId), "not authorized to select wanted figure"); assert(valid(request.payload.figureId), "unknown figure")
    assert(not self.wanted or self.fulfilled, "wanted figure is locked"); self.wanted = request.payload.figureId; self.misses = 0; self.fulfilled = false
    local owned = (self.collection[self.wanted] or 0) > 0
    local newPetal = false
    if owned then self.fulfilled = true; newPetal = self:_completeWanted(request.actorUserId, request.actionId) end
    local receipt = {actionId = request.actionId, wantedFigureId = self.wanted, ownedFulfillment = owned, petalGranted = newPetal}
    self.receipts[request.actionId] = receipt
    return {ok = true, code = owned and "WANTED_ALREADY_OWNED" or "WANTED_LOCKED", receipt = receipt, view = self:GetView(request.actorUserId)}
end
function Q05:_draw()
    local result = self.outcome({figures = Figures, wantedFigureId = self.wanted, misses = self.misses})
    assert(valid(result), "outcome provider returned unknown figure")
    return self.misses >= Config.WantedGuaranteeRoll - 1 and self.wanted or result
end
function Q05:_completeWanted(actorUserId, actionId)
    if self.petalAwarded then return false end
    self.session:ApplyStep({sessionId = self.session.sessionId, activityId = "Q05", roundId = self.roundId, stepId = "wanted-fulfilled", actionId = "q05-step:" .. actionId, actorUserId = actorUserId})
    self.session:CompleteRound({sessionId = self.session.sessionId, activityId = "Q05", roundId = self.roundId, actionId = "q05-complete:" .. actionId, actorUserId = actorUserId})
    self.petalAwarded = true
    return true
end
function Q05:Apply(request)
    assert(request and request.roundId == self.roundId and request.actionId and request.actorUserId, "invalid Q05 request")
    if self.receipts[request.actionId] then return {ok = true, code = "DUPLICATE", receipt = self.receipts[request.actionId], view = self:GetView(request.actorUserId)} end
    if request.stepId == "inspect" then return {ok = true, code = "INSPECTED", view = self:GetView(request.actorUserId)} end
    if request.stepId == "select-wanted" then return self:_select(request) end
    assert(request.stepId == "roll" and self.wanted, "wanted figure required"); assert(self:_canSpend(request.actorUserId), "not authorized to spend shared fund")
    local figure = self:_draw()
    local purchase = self.session:CommitPurchase({actionId = request.actionId, actorUserId = request.actorUserId, cost = Config.RollCost, awardFigureId = figure})
    self.collection[figure] = (self.collection[figure] or 0) + 1
    local wanted = figure == self.wanted; local newPetal = false; if wanted then self.fulfilled = true; newPetal = self:_completeWanted(request.actorUserId, request.actionId) else self.misses += 1 end
    local receipt = {sessionId = purchase.sessionId, activityId = "Q05", roundId = self.roundId, actionId = request.actionId, receiptId = purchase.receiptId, debitApplied = true, awardFigureId = figure, wantedFulfilled = wanted, petalGranted = newPetal, revealSkippable = true}
    self.receipts[request.actionId] = receipt; self.pendingReveal = receipt
    return {ok = true, code = "AWARDED", receipt = receipt, view = self:GetView(request.actorUserId)}
end
function Q05:GetView(actorUserId)
    local snapshot = self.session:GetSnapshot()
    local actions = {{id = "inspect", label = "Inspect figures", stepId = "inspect", enabled = true}}
    for _, figureId in ipairs(Figures) do table.insert(actions, {id = "select-" .. figureId, label = "Want " .. label(figureId), stepId = "select-wanted", payload = {figureId = figureId}, enabled = self:_canSpend(actorUserId) and (not self.wanted or self.fulfilled), reason = self.wanted and not self.fulfilled and "Wanted figure is locked" or nil}) end
    table.insert(actions, {id = "roll", label = "Roll shared fund (20)", stepId = "roll", enabled = self:_canSpend(actorUserId) and self.wanted ~= nil and not self.fulfilled and snapshot.fundBalance >= Config.RollCost, reason = self.fulfilled and "Choose a new wanted figure to replay" or snapshot.fundBalance < Config.RollCost and "Need 20 shared-fund units" or nil})
    local last = self.pendingReveal and label(self.pendingReveal.awardFigureId) or "none"; local collectionCount = 0; for _, count in pairs(self.collection) do collectionCount += count end
    return {activityId = "Q05", roundId = self.roundId, state = self.fulfilled and "FULFILLED" or "READY", title = "A Labubu Wish", instructions = "Choose Phuong's wanted figure, then spend 20 from the shared birthday fund. Last awarded: " .. last .. ". Collection copies: " .. tostring(collectionCount), progress = {done = self.fulfilled and 1 or 0, total = 1}, availableActions = actions, acceptedStepIds = {}, contributors = {}, busyReason = nil, errorText = nil, canReplay = false, sharedFundBalance = snapshot.fundBalance, wantedFigureId = self.wanted, unsuccessfulRollCount = self.misses, q05Petal = snapshot.petals.Q05 == true, collection = clone(self.collection)}
end
Q05.Figures = Figures; return Q05
]=],
    ["roblox/mvp/server/activities/Q06.luau"] = [=[-- Q06 server activity: venue-inspired bowl/plate assembly near FOB and Aladdins.
-- Owns activity validation and visible round state; SessionService owns petals/fund.
local Q06 = {}
Q06.__index = Q06

local ACTIVITY_ID = "Q06"
local REQUIRED_STEPS = {
	base = "rice",
	toppings = "greens",
	protein = "tofu",
	sauce = "sauce",
	settingA = "plate",
	settingB = "cup",
}
local VALID_ITEMS = {
	base = { rice = true },
	toppings = { greens = true, cucumber = true, carrot = true },
	protein = { tofu = true, chicken = true, mushroom = true },
	sauce = { sauce = true, sesame = true },
	settingA = { plate = true, napkin = true },
	settingB = { cup = true, napkin = true },
}
local ROLE_FOR_SLOT = {
	base = "FOB",
	toppings = "FOB",
	protein = "FOB",
	sauce = "Aladdins",
	settingA = "Serving",
	settingB = "Serving",
}

local function clone(source)
	local result = {}
	for key, value in pairs(source) do
		if type(value) == "table" then result[key] = clone(value) else result[key] = value end
	end
	return result
end

local function requireRequest(request)
	assert(request and request.sessionId and type(request.sessionId) == "string", "Q06 sessionId is required")
	assert(request.activityId == ACTIVITY_ID and type(request.activityId) == "string", "Q06 activityId is required")
	assert(type(request.roundId) == "string" and type(request.actionId) == "string" and type(request.stepId) == "string", "Q06 round/action/step IDs are required")
	assert(type(request.actorUserId) == "number", "Q06 actorUserId must be numeric")
end

function Q06.new(options)
	assert(options and options.session and options.actor and options.clock and options.context, "Q06 dependencies are required")
	return setmetatable({
		session = options.session,
		actor = options.actor,
		clock = options.clock,
		context = options.context,
		rounds = {},
		currentRoundId = nil,
	}, Q06)
end

function Q06:CreateRound(request)
	requireRequest(request)
	assert(not self.rounds[request.roundId], "Q06 round already exists")
	local prior = self.session.rounds[request.roundId]
	assert(not prior, "Q06 round already exists")
	if request.replay then
		self.session:StartNextRound(ACTIVITY_ID, request.roundId, request.actorUserId)
	else
		self.session:CreateRound(ACTIVITY_ID, request.roundId, request.actorUserId, false)
	end
	self.rounds[request.roundId] = {
		roundId = request.roundId,
		state = "IN_PROGRESS",
		isReplay = request.replay == true,
		accepted = {},
		reservations = {},
		contributors = {},
	}
	self.currentRoundId = request.roundId
	return { activityId = ACTIVITY_ID, roundId = request.roundId, actorUserId = request.actorUserId, replay = request.replay == true }
end

function Q06:_round(roundId)
	local round = self.rounds[roundId]
	assert(round, "unknown Q06 round")
	assert(round.state == "IN_PROGRESS", "Q06 round is not active")
	return round
end

function Q06:_expireReservations(round)
	local now = self.clock()
	for slotId, reservation in pairs(round.reservations) do
		if reservation.expiresAt <= now then round.reservations[slotId] = nil end
	end
end

function Q06:Apply(request)
	requireRequest(request)
	local round = self:_round(request.roundId)
	self:_expireReservations(round)
	local payload = request.payload or {}
	assert(payload.slotId and payload.itemId, "Q06 slot and item are required")
	local slotId = payload.slotId
	local itemId = payload.itemId
	assert(REQUIRED_STEPS[slotId], "unknown Q06 slot")
	assert(VALID_ITEMS[slotId][itemId], "invalid item for Q06 slot")
	if round.accepted[slotId] then return { ok = true, code = "ALREADY_ACCEPTED", receipt = clone(round.accepted[slotId]), view = self:GetView(request.actorUserId) } end
	local reservation = round.reservations[slotId]
	if reservation and reservation.actorUserId ~= request.actorUserId then
		return { ok = false, code = "SLOT_BUSY", receipt = nil, view = self:GetView(request.actorUserId) }
	end
	local accepted = self.session:ApplyStep({
		sessionId = self.session.sessionId,
		activityId = ACTIVITY_ID,
		roundId = request.roundId,
		stepId = slotId,
		actionId = request.actionId,
		actorUserId = request.actorUserId,
	})
	local result = {
		roundId = request.roundId,
		stepId = slotId,
		actionId = request.actionId,
		actorUserId = request.actorUserId,
		itemId = itemId,
		roleId = ROLE_FOR_SLOT[slotId],
		accepted = true,
		acceptedStep = accepted,
	}
	round.accepted[slotId] = result
	round.reservations[slotId] = nil
	round.contributors[request.actorUserId] = true
	if self:_isComplete(round) then
		local completion = self.session:CompleteRound({ sessionId = self.session.sessionId, activityId = ACTIVITY_ID, roundId = request.roundId, actionId = "complete:" .. request.roundId, actorUserId = request.actorUserId })
		round.state = "COMPLETED"
		result.completion = completion
	end
	return { ok = true, code = result.completion and "ROUND_COMPLETED" or "STEP_ACCEPTED", receipt = clone(result), view = self:GetView(request.actorUserId) }
end

function Q06:Reserve(request)
	requireRequest(request)
	local round = self:_round(request.roundId)
	self:_expireReservations(round)
	local slotId = request.payload and request.payload.slotId
	assert(REQUIRED_STEPS[slotId], "unknown Q06 slot")
	assert(not round.accepted[slotId], "Q06 slot already accepted")
	local current = round.reservations[slotId]
	if current and current.actorUserId ~= request.actorUserId then return { accepted = false, busyReason = "slot-in-use" } end
	local reservation = { slotId = slotId, actorUserId = request.actorUserId, expiresAt = self.clock() + 15 }
	round.reservations[slotId] = reservation
	return clone(reservation)
end

function Q06:Cancel(request)
	requireRequest(request)
	local round = self:_round(request.roundId)
	local slotId = request.payload and request.payload.slotId
	local reservation = round.reservations[slotId]
	if reservation and reservation.actorUserId == request.actorUserId then round.reservations[slotId] = nil end
	return { roundId = request.roundId, slotId = slotId, cancelled = true }
end

function Q06:_isComplete(round)
	for slotId in pairs(REQUIRED_STEPS) do
		if not round.accepted[slotId] then return false end
	end
	return true
end

function Q06:GetView(actorUserId)
	local round = self.currentRoundId and self.rounds[self.currentRoundId] or nil
	if not round then
		return { activityId = ACTIVITY_ID, roundId = nil, state = "NOT_STARTED", title = "Something Delicious", instructions = "Choose an ingredient, choose a slot, and confirm.", progress = { done = 0, total = 6 }, availableActions = {}, acceptedStepIds = {}, contributors = {}, busyReason = nil, errorText = nil, canReplay = false }
	end
	self:_expireReservations(round)
	local accepted, available = {}, {}
	for slotId in pairs(REQUIRED_STEPS) do
		if round.accepted[slotId] then
			table.insert(accepted, slotId)
		else
			local busy = round.reservations[slotId]
			for itemId in pairs(VALID_ITEMS[slotId]) do
				table.insert(available, { id = "choose-" .. slotId .. "-" .. itemId, label = "" .. slotId .. ": " .. itemId, stepId = slotId, payload = { slotId = slotId, itemId = itemId }, enabled = busy == nil, reason = busy and "Slot is being used" or "Tap to add, then confirm" })
			end
		end
	end
	return {
		activityId = ACTIVITY_ID,
		roundId = round.roundId,
		state = round.state,
		title = "Something Delicious",
		instructions = "Choose an ingredient, choose a slot, and confirm.",
		progress = { done = #accepted, total = 6 },
		availableActions = available,
		acceptedStepIds = accepted,
		contributors = clone(round.contributors),
		busyReason = nil,
		errorText = nil,
		canReplay = round.state == "COMPLETED",
		actorUserId = actorUserId,
		foodDisplay = clone(round.accepted),
	}
end

return Q06
]=],
    ["roblox/mvp/server/CakeService.luau"] = [=[local Config = require(script.Parent.Parent.shared.Config)

local CakeService = {}
CakeService.__index = CakeService

function CakeService.new(session)
    return setmetatable({ session = session, finaleState = "LOCKED" }, CakeService)
end

function CakeService:_authorized(actorUserId)
    local present = self.session:IsPresent(actorUserId)
    return present and (actorUserId == self.session.phuongUserId or actorUserId == self.session.hostUserId)
end

function CakeService:Invite(actorUserId)
    assert(self:_authorized(actorUserId), "not authorized")
    assert(self.session:AllPetalsComplete(), "all petals are required")
    self.finaleState = "INVITED"
    return self:GetState()
end

function CakeService:CancelInvite(actorUserId)
    assert(self:_authorized(actorUserId), "not authorized")
    assert(self.finaleState == "INVITED", "invite is not open")
    self.finaleState = "READY"
    return self:GetState()
end

function CakeService:Cut(actorUserId)
    assert(self:_authorized(actorUserId), "not authorized")
    assert(self.finaleState == "INVITED", "cake is not invited")
    self.finaleState = "CUT"
    return self:GetState()
end

function CakeService:Eat(actorUserId)
    assert(self.finaleState == "CUT" or self.finaleState == "EATING", "cake is not cut")
    self.finaleState = "EATING"
    return { actorUserId = actorUserId, state = self.finaleState }
end

function CakeService:GetState()
    return { finaleState = self.finaleState }
end

return CakeService
]=],
    ["roblox/mvp/server/LocalPartyTransferAdapter.luau"] = [=[-- STUDIO-ONLY LOCAL PLAYTEST ADAPTER.
-- This deliberately does not simulate production teleport or reserve a server.
local LocalPartyTransferAdapter = {}
LocalPartyTransferAdapter.__index = LocalPartyTransferAdapter

function LocalPartyTransferAdapter.new(onPartyReady)
	return setmetatable({ onPartyReady = onPartyReady }, LocalPartyTransferAdapter)
end

function LocalPartyTransferAdapter:Transfer(players, roster)
	assert(type(self.onPartyReady) == "function", "local playtest callback is required")
	self.onPartyReady(players, roster)
	return true, "LocalPartyReady"
end

return LocalPartyTransferAdapter
]=],
    ["roblox/mvp/server/Main.server.luau"] = [=[local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local root = workspace:WaitForChild("CozyWorld_Draft01")
local mvp = root:WaitForChild("MVP")
local action = ReplicatedStorage:WaitForChild("PhuongMVP"):WaitForChild("Action")
local Anchors = require(script.Parent.Parent.shared.Anchors)
local Config = require(script.Parent.Parent.shared.Config)
local SessionService = require(script.Parent.SessionService)
local QueueService = require(script.Parent.QueueService)
local CakeService = require(script.Parent.CakeService)
local TeleportAdapter = require(script.Parent.TeleportAdapter)
local LocalPartyTransferAdapter = require(script.Parent.LocalPartyTransferAdapter)

local now = os.clock
local sessionId = "MVP-" .. tostring(math.floor(workspace:GetServerTimeNow()))
local session = SessionService.new({sessionId = sessionId})
local queue = QueueService.new({clock = now, capacity = 10})
local cake = CakeService.new(session)
local anchors, missingAnchors = Anchors.Resolve(mvp)
local arrivalFolder = mvp:WaitForChild("Anchors"):WaitForChild("BedroomArrivalSlots")
local activities, activityErrors = {}, {}
local arrivalSlots, arrivalByUser, currentRounds = {}, {}, {}
local arrivalCount = 0
local roundSerial = 0
local queueBroadcastKey = ""
local queueScanAt = 0
local function uid(p) return p and p.UserId end
local function anchor(name)
 local v = anchors[name]; return v and (v:IsA("BasePart") and v or v:FindFirstChildWhichIsA("BasePart", true))
end
local function character(p)
 local c = p and p.Character; local h = c and c:FindFirstChildOfClass("Humanoid"); local r = c and c:FindFirstChild("HumanoidRootPart")
 if not c or not h or h.Health <= 0 or not r then return nil end; return c, r
end
local function near(p, name, radius)
 local _, r = character(p); local a = anchor(name); return r and a and (r.Position-a.Position).Magnitude <= radius
end
local function place(p, name)
 local c, a = character(p), anchor(name); if not c or not a then return false end; c:PivotTo(a.CFrame+Vector3.new(0,3,0)); return true
end
local function snapshot()
 local s = session:GetSnapshot(); s.queue = queue:Snapshot(); s.cake = cake:GetState()
 s.arrival = {capacity=10, occupied=0, ready={}}
 for player, entry in pairs(arrivalByUser) do s.arrival.occupied += 1; s.arrival.ready[player] = entry.ready == true end
 return s
end
local function send(p, request, ok, code, extra)
 request=type(request)=="table" and request or {}
 local r = {kind="Result", ok=ok, code=code, sessionId=sessionId, activityId=request and request.activityId, roundId=request and request.roundId, actionId=request and request.actionId, stepId=request and request.stepId, actorUserId=uid(p), snapshot=snapshot()}
 if extra then for k,v in pairs(extra) do r[k]=v end end; action:FireClient(p,r); return r
end
local function broadcast()
 for _, p in ipairs(Players:GetPlayers()) do send(p,{kind="RequestSnapshot"},true,"Snapshot") end
end
local function view(a,p)
 if not a then return {state="UNAVAILABLE",errorText="ActivityUnavailable"} end
 local ok, result = pcall(a.GetView,a,uid(p)); return ok and result or {state="UNAVAILABLE",errorText=tostring(result)}
end
local function construct(name,module,context)
 local ctor=module.new or module.New; if not ctor then activityErrors[name]="missing constructor"; return end
 local ok,value=pcall(ctor,context); if ok then activities[name]=value else activityErrors[name]=tostring(value) end
end
-- Prompts are owned by this runtime so a saved place cannot retain stale handlers.
local promptLabels={Q01="Make the bed",Q02="Visit Jasper",Q03="Craft a keepsake",Q04="Read together",Q05="Make a Labubu wish",Q06="Share a food memory",Cake="Birthday cake"}
local promptObjects={Q01="Everything Tucked In",Q02="Jasper's Favorite Things",Q03="A Tiny World of Her Own",Q04="One More Chapter",Q05="A Labubu Wish",Q06="Something Delicious",Cake="Birthday cake"}
local function installPrompt(id, instance)
 if not instance then return end
 local host=instance:IsA("BasePart") and instance or instance:FindFirstChildWhichIsA("BasePart",true); if not host then return end
 local prompt=host:FindFirstChild("MVPProximityPrompt") or Instance.new("ProximityPrompt")
 prompt.Name="MVPProximityPrompt"; prompt.ActionText=promptLabels[id] or id; prompt.ObjectText=promptObjects[id] or id; prompt.KeyboardKeyCode=Enum.KeyCode.E
 prompt.HoldDuration=0; prompt.MaxActivationDistance=12; prompt.RequiresLineOfSight=false; prompt:SetAttribute("ActivityId",id); prompt.Parent=host
end
local world={isPresent=function(id) return session:IsPresent(id) end,presentUserIds=session.presence,anchors=anchors}
construct("Q01",require(script.Parent.activities.Q01),{session=session,clock=now,world=world})
construct("Q02",require(script.Parent.activities.Q02),{session=session,clock=now,world=world})
construct("Q03",require(script.Parent.activities.Q03),{session=session,clock=now,context=world})
construct("Q04",require(script.Parent.activities.Q04),{session=session,clock=now,context=world})
construct("Q05",require(script.Parent.activities.Q05),{session=session,clock=now,context=world,presentUserIds=session.presence})
construct("Q06",require(script.Parent.activities.Q06),{session=session,clock=now,actor=world.isPresent,context=world})
local transfer
if RunService:IsStudio() then
 transfer=LocalPartyTransferAdapter.new(function(players)
  local checked={}; for _,p in ipairs(players) do local e=arrivalByUser[p.UserId]; local c=character(p); if not e or not e.part or not c then error("arrival slot or character not ready") end; table.insert(checked,{player=p,entry=e,character=c}) end
  for _,item in ipairs(checked) do item.character:PivotTo(item.entry.part.CFrame+Vector3.new(0,3,0)); item.entry.transferred=true; item.player:SetAttribute("MVPArrivalStatus","Transferred") end
  broadcast(); return true
 end)
else
 local placeId=game:GetAttribute("GameplayPlaceId") or Config.GameplayPlaceId
 if placeId and placeId ~= 0 then transfer=TeleportAdapter.new({GameplayPlaceId=placeId},{}) else warn("GameplayPlaceId is unconfigured; production transfer is disabled") end
end
local function transferQueue(roster)
 if not roster then return end
 local players={}; for _,id in ipairs(roster.members) do local p=Players:GetPlayerByUserId(id); local e=arrivalByUser[id]; if not p or not e or not e.part or not e.ready or not character(p) then queue:FailTransfer(); return end; table.insert(players,p) end
 if not queue:BeginTransfer() then return end
 if not transfer then queue:FailTransfer(); return end
 local ok,result=pcall(transfer.Transfer,transfer,players,roster); if ok and result then queue:CompleteTransfer() else queue:FailTransfer() end
end
local station={Q01="Q01Bed",Q02="JasperBedroomStart",Q03="Q03FairCraft",Q04="Q04QuadReading",Q05="Q05UDistrictVending",Q06="Q06FOBCounter"}
local function nearActivity(p,r)
 if r.activityId=="Q02" then if r.stepId=="greet" then return near(p,"JasperBedroomStart",24) end; if r.stepId then return near(p,"JasperFetchYard",24) end; return near(p,"JasperBedroomStart",24) or near(p,"JasperFetchYard",24) end
 if r.activityId=="Q04" then return near(p,"Q04QuadReading",24) or near(p,"Q04BedroomKindle",24) end
 if r.activityId=="Q03" then return near(p,"Q03FairCraft",24) or near(p,"Q03BedroomDisplay",24) end
 if r.activityId=="Q06" then
  local slot=r.payload and r.payload.slotId
  if slot=="sauce" then return near(p,"Q06AladdinsCounter",24) end
  if slot=="settingA" or slot=="settingB" then return near(p,"Q06Serving",24) end
  if not slot then return near(p,"Q06FOBCounter",24) or near(p,"Q06AladdinsCounter",24) or near(p,"Q06Serving",24) end
 end
 return near(p,station[r.activityId],24)
end
local function queueInside(p)
 local _,hrp=character(p); local floor=mvp:FindFirstChild("QueueFloor",true) or mvp:FindFirstChild("QueueFloor")
 if not hrp or not floor or not floor:IsA("BasePart") then return false end
 local localPos=floor.CFrame:PointToObjectSpace(hrp.Position); local half=floor.Size*.5
 return math.abs(localPos.X)<=half.X and math.abs(localPos.Z)<=half.Z and localPos.Y>=-4 and localPos.Y<=8
end
local function updateQueueSign(q)
 local sign=mvp:FindFirstChild("QueueSign",true); if not sign then return end
 local gui=sign:FindFirstChildWhichIsA("SurfaceGui",true) or Instance.new("SurfaceGui"); gui.Name="QueueSignSurface"; gui.Parent=sign
 local label=gui:FindFirstChild("QueueText") or Instance.new("TextLabel"); label.Name="QueueText"; label.Size=UDim2.fromScale(1,1); label.BackgroundTransparency=1; label.TextColor3=Color3.fromRGB(38,56,46); label.TextScaled=true; label.Parent=gui
 label.Text=string.format("Birthday group  %d/10\n%s",q.count,q.remaining and ("Shared wait: "..math.ceil(q.remaining).."s") or "Step inside to join")
end
local function canonical(p,r)
 if type(r.sessionId)~="string" or r.sessionId~=sessionId then return nil,"BadSessionId" end
 if type(r.activityId)~="string" or not activities[r.activityId] then return nil,"ActivityUnavailable" end
 if type(r.actionId)~="string" or r.actionId=="" then return nil,"BadActionId" end; r.actorUserId=uid(p); return r
end
local function release(p, activityId, roundId)
 local a=activityId and activities[activityId]; if a and a.ReleaseActor then pcall(a.ReleaseActor,a,uid(p),roundId) end
end
local function openRound(p,r)
 if not nearActivity(p,r) then return false,"TooFar" end
 local a=activities[r.activityId]; if currentRounds[r.activityId] and not r.replay then r.roundId=currentRounds[r.activityId]; return true,"RoundExisting",{view=view(a,p)} end
 roundSerial+=1; r.roundId="round:"..r.activityId..":"..roundSerial
 if r.activityId=="Q06" then r.stepId="base" end
 local ok,result=pcall(a.CreateRound,a,r); if not ok then return false,"RoundRejected",{errorText=tostring(result)} end
 currentRounds[r.activityId]=r.roundId; return true,"RoundCreated",{round=result,view=view(a,p)}
end
local function apply(p,r)
 local req,err=canonical(p,r); if not req then return false,err end
 if type(r.roundId)~="string" or type(r.stepId)~="string" then return false,"BadAction" end
 if not nearActivity(p,r) then return false,"TooFar" end
 local ok,result=pcall(activities[r.activityId].Apply,activities[r.activityId],req)
 if not ok then return false,"ActionRejected",{errorText=tostring(result),view=view(activities[r.activityId],p),failedResult=result} end
 if type(result)~="table" then return false,"ActionRejected",{errorText="Invalid activity result"} end
 return result.ok~=false,result.code or "Accepted",{receipt=result.receipt,view=result.view or view(activities[r.activityId],p),result=result}
end
action.OnServerEvent:Connect(function(p,r)
 if type(r)~="table" or type(r.kind)~="string" then return send(p,r,false,"BadPayload") end
 if r.actorUserId~=nil or r.player~=nil then return send(p,r,false,"ClientAuthorityRejected") end
 if r.kind=="ActivityAction" then local ok,c,e=apply(p,r); send(p,r,ok,c,e); if ok then broadcast() end; return end
 if r.kind=="RequestView" then local req,err=canonical(p,r); if not req then return send(p,r,false,err) end; if req.replay and (not currentRounds[req.activityId] or not view(activities[req.activityId],p).canReplay) then return send(p,req,false,"ReplayUnavailable") end; local ok,c,e=openRound(p,req); return send(p,req,ok,c,e) end
 if r.kind=="CloseActivity" then release(p,r.activityId,r.roundId); return send(p,r,true,"Released") end
 if r.kind=="RequestJournal" then return send(p,r,true,"Journal",{journal=snapshot()}) end
 if r.kind=="RequestSnapshot" then return send(p,r,true,"Snapshot") end
 if r.kind=="QueueJoin" then if not queueInside(p) then return send(p,r,false,"TooFar") end; local ok,c=queue:Join(uid(p),now()); send(p,r,ok,c); broadcast(); return end
 if r.kind=="QueueLeave" then local ok,c=queue:Leave(uid(p)); send(p,r,ok,c); broadcast(); return end
 if r.kind=="Cake" then if type(r.sessionId)~="string" or r.sessionId~=sessionId or type(r.actionId)~="string" or r.actionId=="" then return send(p,r,false,"BadCakeRequest") end; if not session:IsPresent(uid(p)) then return send(p,r,false,"NotPresent") end; if not near(p,"FinalePatio",28) then return send(p,r,false,"TooFar") end; local allowed={Invite=true,CancelInvite=true,Cut=true,Eat=true}; if not allowed[r.action] then return send(p,r,false,"UnsupportedCakeAction") end; local ok,result=pcall(cake[r.action],cake,uid(p)); send(p,r,ok,ok and (r.action.."Accepted") or "CakeRejected",{cake=cake:GetState(),result=result,errorText=ok and nil or tostring(result)}); if ok then broadcast() end; return end
 send(p,r,false,"UnsupportedAction")
end)
local function assign(p)
 if arrivalByUser[p.UserId] then return end; if arrivalCount>=10 then p:SetAttribute("MVPArrivalStatus","Full"); return end
 local folder=arrivalFolder; local target
 if folder then for _,v in ipairs(folder:GetChildren()) do if v:IsA("BasePart") and not arrivalSlots[v] then target=v; break end end end
 if not target then p:SetAttribute("MVPArrivalStatus","NotReady"); return end
 arrivalSlots[target]=p; arrivalByUser[p.UserId]={part=target,ready=false,transferred=false}; arrivalCount += 1; p:SetAttribute("MVPArrivalSlot",target.Name); p:SetAttribute("MVPArrivalStatus","ReadyPendingCharacter")
 local function ready() local e=arrivalByUser[p.UserId]; local c=character(p); if e and c then e.ready=true; if e.transferred then c:PivotTo(e.part.CFrame+Vector3.new(0,3,0)) end; p:SetAttribute("MVPArrivalStatus",e.transferred and "Transferred" or "Ready") end end
 p.CharacterAdded:Connect(function() task.spawn(function() for _=1,20 do if character(p) then ready(); return end; task.wait(.1) end end) end)
 p.CharacterRemoving:Connect(function() local e=arrivalByUser[p.UserId]; if e then e.ready=false end end); ready()
end
Players.PlayerAdded:Connect(function(p) session:SetPresence(p.UserId,true); p:SetAttribute("MVPSessionId",sessionId); assign(p); send(p,{kind="RequestSnapshot"},true,"Snapshot") end)
Players.PlayerRemoving:Connect(function(p) session:SetPresence(p.UserId,false); queue:Leave(p.UserId); local e=arrivalByUser[p.UserId]; if e then arrivalSlots[e.part]=nil; arrivalByUser[p.UserId]=nil; arrivalCount -= 1 end; for _,a in pairs(activities) do if a.ReleaseActor then pcall(a.ReleaseActor,a,p.UserId) end end; broadcast() end)
RunService.Heartbeat:Connect(function()
 if now()>=queueScanAt then queueScanAt=now()+.2; for _,p in ipairs(Players:GetPlayers()) do local e=arrivalByUser[p.UserId]; if not (e and e.transferred) then if queueInside(p) then queue:Join(p.UserId,now()) elseif queue.state=="Open" or queue.state=="Shortened" then queue:Leave(p.UserId) end end end end
 local q=queue:Snapshot(); local key=string.format("%s:%d:%d:%s",q.state,q.count,math.floor(q.remaining or -1),table.concat(q.members,",")); if key~=queueBroadcastKey then queueBroadcastKey=key; updateQueueSign(q); broadcast() end
 local expired,_,roster=queue:Tick(now()); if expired then transferQueue(roster) end
end)
for id,name in pairs(station) do installPrompt(id,anchor(name)) end
installPrompt("Q02",anchor("JasperFetchYard")); installPrompt("Q04",anchor("Q04BedroomKindle")); installPrompt("Q06",anchor("Q06AladdinsCounter")); installPrompt("Q06",anchor("Q06Serving")); installPrompt("Cake",anchor("FinalePatio"))
installPrompt("Q03",anchor("Q03BedroomDisplay"))
local legacyPortal=workspace:FindFirstChild("BirthdayLobby",true)
legacyPortal=legacyPortal and legacyPortal:FindFirstChild("Portal",true)
legacyPortal=legacyPortal and legacyPortal:FindFirstChild("PortalPrompt")
legacyPortal=legacyPortal and legacyPortal:FindFirstChild("EnterWorld")
if legacyPortal and legacyPortal:IsA("ProximityPrompt") then legacyPortal.Enabled=false end
for _,p in ipairs(Players:GetPlayers()) do session:SetPresence(p.UserId,true); p:SetAttribute("MVPSessionId",sessionId); assign(p); send(p,{kind="RequestSnapshot"},true,"Snapshot") end
print("Phuong MVP server integration active",sessionId,"missing anchors:",table.concat(missingAnchors,","))
for name,defect in pairs(activityErrors) do warn("Activity "..name.." unavailable: "..defect) end
]=],
    ["roblox/mvp/server/QueueService.luau"] = [=[-- Server-owned shared birthday queue. Pure state machine; Roblox wiring belongs to LobbyQueue.
local QueueService = {}
QueueService.__index = QueueService

QueueService.Config = {
	Capacity = 10,
	ShortenAt = 8,
	InitialSeconds = 60,
	ShortenedSeconds = 10,
}

local function copyIds(ids)
	local result = {}
	for index, userId in ipairs(ids) do
		result[index] = userId
	end
	return result
end

function QueueService.new(options)
	options = options or {}
	local self = setmetatable({}, QueueService)
	self.clock = options.clock or os.clock
	self.capacity = options.capacity or QueueService.Config.Capacity
	self.shortenAt = options.shortenAt or QueueService.Config.ShortenAt
	self.initialSeconds = options.initialSeconds or QueueService.Config.InitialSeconds
	self.shortenedSeconds = options.shortenedSeconds or QueueService.Config.ShortenedSeconds
	self.generation = 0
	self.state = "Empty"
	self.members = {}
	self.order = {}
	self.startedAt = nil
	self.deadlineAt = nil
	self.shortenedAt = nil
	self.rosterId = nil
	self.destinationReservationId = nil
	self.frozenRoster = nil
	return self
end

function QueueService:_reset()
	self.generation += 1
	self.state = "Empty"
	self.members = {}
	self.order = {}
	self.startedAt = nil
	self.deadlineAt = nil
	self.shortenedAt = nil
	self.rosterId = nil
	self.destinationReservationId = nil
	self.frozenRoster = nil
end

function QueueService:_snapshot(reason)
	return {
		state = self.state,
		generation = self.generation,
		count = #self.order,
		capacity = self.capacity,
		startedAt = self.startedAt,
		deadlineAt = self.deadlineAt,
		remaining = self.deadlineAt and math.max(0, self.deadlineAt - self.clock()) or nil,
		shortened = self.shortenedAt ~= nil,
		members = copyIds(self.order),
		reason = reason,
	}
end

function QueueService:Snapshot()
	return self:_snapshot()
end

function QueueService:Join(userId, now)
	now = now or self.clock()
	if self.state ~= "Empty" and self.state ~= "Open" and self.state ~= "Shortened" then
		return false, "QueueClosed", self:_snapshot()
	end
	if self.members[userId] then
		return true, "AlreadyJoined", self:_snapshot()
	end
	if #self.order >= self.capacity then
		return false, "QueueFull", self:_snapshot()
	end
	if self.state == "Empty" then
		self.generation += 1
		self.state = "Open"
		self.startedAt = now
		self.deadlineAt = now + self.initialSeconds
	end
	self.members[userId] = true
	table.insert(self.order, userId)
	if #self.order >= self.shortenAt and self.shortenedAt == nil then
		self.deadlineAt = math.min(self.deadlineAt, now + self.shortenedSeconds)
		self.shortenedAt = now
		self.state = "Shortened"
	end
	return true, "Joined", self:_snapshot()
end

function QueueService:Leave(userId)
	if self.state ~= "Empty" and self.state ~= "Open" and self.state ~= "Shortened" then
		return false, "QueueClosed", self:_snapshot()
	end
	if not self.members[userId] then
		return true, "AlreadyLeft", self:_snapshot()
	end
	self.members[userId] = nil
	for index, queuedId in ipairs(self.order) do
		if queuedId == userId then
			table.remove(self.order, index)
			break
		end
	end
	if #self.order == 0 then
		self:_reset()
		return true, "Reset", self:_snapshot()
	end
	return true, "Left", self:_snapshot()
end

function QueueService:Tick(now)
	now = now or self.clock()
	if (self.state == "Open" or self.state == "Shortened") and self.deadlineAt and now >= self.deadlineAt then
		return self:Freeze(now)
	end
	return false, "NotExpired", self:_snapshot()
end

function QueueService:Freeze(now)
	if self.state == "Frozen" or self.state == "Transferring" or self.state == "Completed" then
		return false, "AlreadyFrozen", self:_snapshot()
	end
	if #self.order == 0 then
		return false, "Empty", self:_snapshot()
	end
	if self.deadlineAt and now < self.deadlineAt then
		return false, "NotExpired", self:_snapshot()
	end
	self.state = "Frozen"
	self.frozenRoster = copyIds(self.order)
	self.rosterId = string.format("birthday-%d", self.generation)
	self.destinationReservationId = string.format("destination-%d", self.generation)
	return true, "Frozen", {
		generation = self.generation,
		rosterId = self.rosterId,
		destinationReservationId = self.destinationReservationId,
		members = copyIds(self.frozenRoster),
	}
end

function QueueService:BeginTransfer()
	if self.state ~= "Frozen" then
		return false, "NotFrozen"
	end
	self.state = "Transferring"
	return true, "Transferring"
end

function QueueService:CompleteTransfer()
	if self.state ~= "Transferring" then
		return false, "NotTransferring"
	end
	self.state = "Completed"
	return true, "Completed"
end

function QueueService:FailTransfer()
	if self.state ~= "Transferring" and self.state ~= "Frozen" then
		return false, "NotTransferable"
	end
	self.state = "Failed"
	return true, "Failed"
end

return QueueService
]=],
    ["roblox/mvp/server/SessionService.luau"] = [=[local Config = require(script.Parent.Parent.shared.Config)

local SessionService = {}
SessionService.__index = SessionService

local function copyMap(source)
    local result = {}
    for key, value in pairs(source) do result[key] = value end
    return result
end

function SessionService.new(options)
    assert(options and options.sessionId, "sessionId is required")
    local self = setmetatable({
        sessionId = options.sessionId,
        hostUserId = options.hostUserId or Config.HostUserId,
        phuongUserId = options.phuongUserId or Config.PhuongUserId,
        phase = "ACTIVE",
        fundBalance = 0,
        petals = {},
        rounds = {},
        actions = {},
        receipts = {},
        acceptedSteps = {},
        reservations = {},
        presence = {},
    }, SessionService)
    for _, activityId in ipairs(Config.ActivityIds) do self.petals[activityId] = false end
    return self
end

function SessionService:_receipt(actionId)
    return actionId and self.receipts[actionId]
end

function SessionService:CreateRound(activityId, roundId, actorUserId)
    assert(self.petals[activityId] ~= nil, "unknown activity")
    assert(not self.rounds[roundId], "round already exists")
    local hasCompleted = false
    for _, priorRound in pairs(self.rounds) do
        if priorRound.activityId == activityId and priorRound.state == "COMPLETED" then hasCompleted = true break end
    end
    self.rounds[roundId] = { activityId = activityId, roundId = roundId, startedBy = actorUserId, state = "IN_PROGRESS", isReplay = hasCompleted, contributors = {}, steps = {} }
    return self.rounds[roundId]
end

function SessionService:StartNextRound(activityId, roundId, actorUserId)
    return self:CreateRound(activityId, roundId, actorUserId)
end

function SessionService:ApplyStep(request)
    assert(request and request.sessionId == self.sessionId and request.activityId and request.actionId and request.stepId and request.roundId and request.actorUserId, "canonical step identity is required")
    local prior = self:_receipt(request.actionId)
    if prior then
        assert(prior.actorUserId == nil or prior.actorUserId == request.actorUserId, "actor does not match action")
        return { ok = true, code = "DUPLICATE_ACTION", receipt = prior }
    end
    local round = self.rounds[request.roundId]
    assert(round and round.state == "IN_PROGRESS", "round is not active")
    assert(round.activityId == request.activityId, "activity does not match round")
    if round.steps[request.stepId] then return { ok = true, code = "DUPLICATE_STEP", receipt = round.steps[request.stepId] } end
    local accepted = { sessionId = self.sessionId, activityId = round.activityId, roundId = round.roundId, stepId = request.stepId, actionId = request.actionId, actorUserId = request.actorUserId }
    round.steps[request.stepId] = accepted
    round.contributors[request.actorUserId] = true
    self.acceptedSteps[request.actionId] = accepted
    return { ok = true, code = "ACCEPTED", receipt = accepted }
end

function SessionService:CancelRound(roundId)
    local round = self.rounds[roundId]
    assert(round and round.state == "IN_PROGRESS", "round is not active")
    round.state = "CANCELLED"
    self.reservations[roundId] = nil
    return round
end

function SessionService:CompleteRound(request)
    assert(request and request.sessionId == self.sessionId and request.activityId and request.actionId and request.roundId and request.actorUserId, "canonical completion identity is required")
    local prior = self:_receipt(request.actionId)
    if prior then return prior end
    local round = self.rounds[request.roundId]
    assert(round, "round is unknown")
    assert(round.activityId == request.activityId, "activity does not match round")
    if round.completionReceipt then
        self.receipts[request.actionId] = round.completionReceipt
        return round.completionReceipt
    end
    assert(round.state == "IN_PROGRESS", "round is not active")
    assert(self:CanFinish(request.roundId), "round has no accepted steps")
    round.state = "COMPLETED"
    local firstPetal = not self.petals[round.activityId]
    self.petals[round.activityId] = true
    local reward = 0
    if Config.EarningActivityIds[round.activityId] then reward = round.isReplay and Config.ReplayReward or Config.FirstRoundReward end
    self.fundBalance += reward
    local receipt = { sessionId = self.sessionId, receiptId = "completion:" .. round.roundId, activityId = round.activityId, roundId = round.roundId, petalGranted = firstPetal, fundRewardGranted = reward, contributors = copyMap(round.contributors) }
    round.completionReceipt = receipt
    self.receipts[request.actionId] = receipt
    self.receipts[receipt.receiptId] = receipt
    self.reservations[round.roundId] = nil
    return receipt
end

function SessionService:CanFinish(roundId)
    local round = self.rounds[roundId]
    if not round or round.state ~= "IN_PROGRESS" then return false end
    for _ in pairs(round.steps) do return true end
    return false
end

function SessionService:AddFund(amount)
    assert(amount >= 0, "amount must be positive")
    self.fundBalance += amount
end

function SessionService:SpendFund(amount)
    assert(amount >= 0 and self.fundBalance >= amount, "insufficient fund")
    self.fundBalance -= amount
end

function SessionService:CanSpend(actorUserId, presentUserIds)
    local present = presentUserIds and presentUserIds[actorUserId] == true
    return present and (actorUserId == self.phuongUserId or (self.hostUserId ~= 0 and actorUserId == self.hostUserId and not presentUserIds[self.phuongUserId]))
end

function SessionService:SetPresence(userId, isPresent)
    self.presence[userId] = isPresent == true
end

function SessionService:IsPresent(userId)
    return self.presence[userId] == true
end

function SessionService:CommitPurchase(request)
    assert(request and request.actionId and request.actorUserId and request.cost and request.awardFigureId, "purchase fields are required")
    local prior = self:_receipt(request.actionId)
    if prior then return prior end
    assert(self:IsPresent(request.actorUserId), "actor is not present")
    assert(self:CanSpend(request.actorUserId, self.presence), "not authorized")
    self:SpendFund(request.cost)
    local receipt = { sessionId = self.sessionId, receiptId = "purchase:" .. request.actionId, actionId = request.actionId, cost = request.cost, awardFigureId = request.awardFigureId, debitApplied = true }
    self.receipts[request.actionId] = receipt
    self.receipts[receipt.receiptId] = receipt
    return receipt
end

function SessionService:AllPetalsComplete()
    for _, activityId in ipairs(Config.ActivityIds) do if not self.petals[activityId] then return false end end
    return true
end

function SessionService:GetSnapshot()
    local petals = copyMap(self.petals)
    return { sessionId = self.sessionId, phase = self.phase, fundBalance = self.fundBalance, petals = petals, allPetalsComplete = self:AllPetalsComplete(), phuongUserId = self.phuongUserId, hostUserId = self.hostUserId }
end

return SessionService
]=],
    ["roblox/mvp/server/TeleportAdapter.luau"] = [=[-- Production adapter for one reserved destination. Studio must inject a local adapter.
local TeleportService = game:GetService("TeleportService")

local TeleportAdapter = {}
TeleportAdapter.__index = TeleportAdapter

function TeleportAdapter.new(config, services)
	config = config or {}
	services = services or {}
	local self = setmetatable({}, TeleportAdapter)
	self.gameplayPlaceId = config.GameplayPlaceId
	self.maxRetries = config.MaxRetries or 2
	self.retryDelay = config.RetryDelay or 3
	self.teleportService = services.teleportService or TeleportService
	self.reserveServer = services.reserveServer or function(placeId)
		return self.teleportService:ReserveServerAsync(placeId)
	end
	self.wait = services.wait or task.wait
	self.isStudio = services.isStudio
	if self.isStudio == nil then
		self.isStudio = game:GetService("RunService"):IsStudio()
	end
	return self
end

function TeleportAdapter:Reserve(roster)
	assert(self.gameplayPlaceId, "GameplayPlaceId is required for production teleport")
	if self.isStudio then
		return false, "StudioTeleportUnsupported"
	end
	if roster.reservedServerAccessCode then
		return true, "AlreadyReserved", roster
	end
	local ok, accessCode, privateServerId = pcall(self.reserveServer, self.gameplayPlaceId)
	if not ok then
		return false, "ReserveFailed"
	end
	roster.reservedServerAccessCode = accessCode
	roster.privateServerId = privateServerId
	return true, "Reserved", roster
end

function TeleportAdapter:Transfer(players, roster)
	assert(self.gameplayPlaceId, "GameplayPlaceId is required for production teleport")
	if self.isStudio then
		return false, "StudioTeleportUnsupported"
	end
	if #players ~= #roster.members then
		return false, "RosterPlayerMismatch"
	end
	local reserved, reserveReason = self:Reserve(roster)
	if not reserved then
		return false, reserveReason
	end
	local teleportOptions = Instance.new("TeleportOptions")
	teleportOptions.ReservedServerAccessCode = roster.reservedServerAccessCode
	teleportOptions:SetTeleportData({
		rosterId = roster.rosterId,
		destinationReservationId = roster.destinationReservationId,
		members = roster.members,
	})
	local ok, result = pcall(function()
		return self.teleportService:TeleportAsync(self.gameplayPlaceId, players, teleportOptions)
	end)
	if ok then
		return true, "Dispatched", result, 1
	end
	return false, "DispatchFailed", nil, 1
end

function TeleportAdapter:RetryMember(player, roster, attempt)
	if self.isStudio then
		return false, "StudioTeleportUnsupported"
	end
	if not roster.reservedServerAccessCode then
		return false, "ReservationMissing"
	end
	if attempt > self.maxRetries then
		return false, "RetryLimit"
	end
	local teleportOptions = Instance.new("TeleportOptions")
	teleportOptions.ReservedServerAccessCode = roster.reservedServerAccessCode
	teleportOptions:SetTeleportData({
		rosterId = roster.rosterId,
		destinationReservationId = roster.destinationReservationId,
		members = roster.members,
		retry = true,
	})
	local ok = pcall(function()
		self.teleportService:TeleportAsync(self.gameplayPlaceId, { player }, teleportOptions)
	end)
	if ok then
		return true, "RetryDispatched"
	end
	return false, "RetryFailed"
end

return TeleportAdapter
]=],
    ["roblox/mvp/shared/Anchors.luau"] = [=[local Anchors = {}

Anchors.Names = {
    GameplayBedroomArrival = "GameplayBedroomArrival",
    Q01Bed = "Q01Bed",
    JasperBedroomStart = "JasperBedroomStart",
    JasperFetchYard = "JasperFetchYard",
    Q03FairCraft = "Q03FairCraft",
    Q03BedroomDisplay = "Q03BedroomDisplay",
    Q04QuadReading = "Q04QuadReading",
    Q04BedroomKindle = "Q04BedroomKindle",
    Q05UDistrictVending = "Q05UDistrictVending",
    Q06FOBCounter = "Q06FOBCounter",
    Q06AladdinsCounter = "Q06AladdinsCounter",
    Q06Serving = "Q06Serving",
    FinalePatio = "FinalePatio",
    BirthdayLobbyQueue = "BirthdayLobbyQueue",
}

local function find(root, name)
    local value = root and root:FindFirstChild(name, true) or nil
    if value and value:GetAttribute("PlacementStatus") == "UNRESOLVED_LIVE_ANCHOR" then return nil end
    return value
end

function Anchors.Resolve(root)
    local result = {}
    local missing = {}
    for key, name in Anchors.Names do
        local instance = find(root, name)
        result[key] = instance
        if not instance then table.insert(missing, name) end
    end
    return result, missing
end

function Anchors.ResolveSource(root)
    local home = root:FindFirstChild("Home")
    local arrival = root:FindFirstChild("Arrival")
    local party = root:FindFirstChild("BirthdayCourtyard") or root:FindFirstChild("Party")
    local bedroom = home and home:FindFirstChild("Bedroom")
    local source = {
        HomeFloor = home and home:FindFirstChild("Floor"),
        FrontDoor = home and home:FindFirstChild("FrontDoor"),
        ArrivalSpawn = arrival and arrival:FindFirstChild("ArrivalSpawn"),
        Bedroom = bedroom,
        Bed = bedroom and bedroom:FindFirstChild("Bed", true),
        QuadBenchWest = root:FindFirstChild("QuadBenchWest", true),
        QuadBenchEast = root:FindFirstChild("QuadBenchEast", true),
        Party = party,
    }
    return source
end

return Anchors
]=],
    ["roblox/mvp/shared/Config.luau"] = [=[local Config = {
    FirstRoundReward = 20,
    ReplayReward = 10,
    RollCost = 20,
    ActivityIds = { "Q01", "Q02", "Q03", "Q04", "Q05", "Q06" },
    EarningActivityIds = { Q01 = true, Q02 = true, Q03 = true, Q04 = true, Q06 = true },
    RegularFigureIds = { "BigIntoEnergy01", "BigIntoEnergy02", "BigIntoEnergy03", "BigIntoEnergy04", "BigIntoEnergy05", "BigIntoEnergy06" },
    SecretFigureId = "BigIntoEnergySecret",
    RegularProbability = 0.165,
    SecretProbability = 0.01,
    WantedGuaranteeRoll = 5,
    PhuongUsername = "Phamlet707",
    PhuongUserId = 3971290001,
    HostUsername = "IamBannedrew",
    HostUserId = 1078077474,
}

return Config
]=],
    ["roblox/mvp/shared/MeasuredInstallOptions.luau"] = [=[-- Task 01 measured Edit-mode inputs. Returns Roblox-native values for world builders.
local Options = {}

function Options.FromWorld(root, anchors)
    local landscape = assert(root:FindFirstChild("Landscape"), "Landscape is required")
    local quad = assert(landscape:FindFirstChild("QuadGround"), "Landscape.QuadGround is required")
    assert(quad:IsA("BasePart"), "QuadGround must be a BasePart")
    local paths = assert(root:FindFirstChild("Paths"), "Paths is required")
    local routeDefinitions = assert(paths:FindFirstChild("RouteDefinitions"), "Paths.RouteDefinitions is required")
    local keepouts = {Provenance = "Workspace.CozyWorld_Draft01.Paths.RouteDefinitions plus measured Task01 station/facade approach buffers"}
    for _, item in routeDefinitions:GetChildren() do
        keepouts["RouteDefinition:" .. item.Name] = true
    end
    local stationNames = {"GameplayBedroomArrival","Q03FairCraft","Q04QuadReading","Q05UDistrictVending","Q06FOBCounter","Q06AladdinsCounter","FinalePatio","JasperFetchYard"}
    local stationPoints = {}
    for _, name in stationNames do
        local anchor = anchors and anchors[name]
        if anchor and anchor:IsA("BasePart") and anchor:GetAttribute("PlacementStatus") ~= "UNRESOLVED_LIVE_ANCHOR" then table.insert(stationPoints, {name = name, position = anchor.Position}) end
    end
    local function stationKeepout(position, radius)
        for _, item in stationPoints do if (item.position - position).Magnitude <= radius then return item.name end end
        return nil
    end
    local worldParts = {}
    for _, item in root:GetDescendants() do
        if item:IsA("BasePart") and not item:IsDescendantOf(root:FindFirstChild("MVP")) and item.Position.X > -500 and item.Position.X < 500 and item.Position.Z > -260 and item.Position.Z < 200 then
            table.insert(worldParts, item)
        end
    end
    assert(#worldParts > 0, "Measured gameplay world bounds have no source parts")
    local minX, maxX, minZ, maxZ, centerY = math.huge, -math.huge, math.huge, -math.huge, 0
    for _, item in worldParts do
        local p, h = item.Position, item.Size / 2
        minX, maxX = math.min(minX, p.X - h.X), math.max(maxX, p.X + h.X)
        minZ, maxZ = math.min(minZ, p.Z - h.Z), math.max(maxZ, p.Z + h.Z)
        centerY = math.max(centerY, p.Y + h.Y)
    end
    local candidatePositions = {
        NorthWest = quad.Position + Vector3.new(-quad.Size.X/2, 0, -quad.Size.Z/2),
        NorthEast = quad.Position + Vector3.new(quad.Size.X/2, 0, -quad.Size.Z/2),
        SouthWest = quad.Position + Vector3.new(-quad.Size.X/2, 0, quad.Size.Z/2),
        SouthEast = quad.Position + Vector3.new(quad.Size.X/2, 0, quad.Size.Z/2),
        Grass_1 = quad.Position + Vector3.new(-.30 * quad.Size.X/2, quad.Size.Y/2, -.22 * quad.Size.Z/2),
        Grass_2 = quad.Position + Vector3.new(0, quad.Size.Y/2, .16 * quad.Size.Z/2),
        Grass_3 = quad.Position + Vector3.new(.28 * quad.Size.X/2, quad.Size.Y/2, -.06 * quad.Size.Z/2),
        Grass_4 = quad.Position + Vector3.new(-.12 * quad.Size.X/2, quad.Size.Y/2, .31 * quad.Size.Z/2),
    }
    for name, position in candidatePositions do
        local blocker = stationKeepout(position, name:sub(1,5) == "Grass" and 8 or 16)
        if blocker then keepouts[name] = "Measured station/approach buffer: " .. blocker end
    end
    return {
        OuterQuadBounds = quad,
        Keepouts = keepouts,
        WorldBounds = {minX = minX, maxX = maxX, minZ = minZ, maxZ = maxZ, centerY = centerY},
        Provenance = {QuadGround = quad:GetFullName(), RouteDefinitions = routeDefinitions:GetFullName(), GameplayBoundsFilter = "-500<X<500,-260<Z<200, excluding MVP"},
    }
end

return Options
]=],
    ["roblox/mvp/tests/cake_service.spec.luau"] = [=[local SessionService = require(script.Parent.Parent.server.SessionService)
local CakeService = require(script.Parent.Parent.server.CakeService)

local session = SessionService.new({ sessionId = "cake-test", phuongUserId = 3971290001, hostUserId = 1078077474 })
session:SetPresence(3971290001, true)
session:SetPresence(1078077474, true)
for _, activityId in ipairs({ "Q01", "Q02", "Q03", "Q04", "Q06" }) do
    local roundId = activityId .. "-r1"
    session:CreateRound(activityId, roundId, 3971290001)
    session:ApplyStep({ sessionId = "cake-test", activityId = activityId, roundId = roundId, stepId = roundId .. "-step", actionId = roundId .. "-step-action", actorUserId = 3971290001 })
    session:CompleteRound({ sessionId = "cake-test", activityId = activityId, roundId = roundId, actionId = roundId .. "-complete", actorUserId = 3971290001 })
end
session.petals.Q05 = true
local cake = CakeService.new(session)
for index = 1, 5 do
    local receipt = session:CommitPurchase({actorUserId = 3971290001, actionId = "roll-" .. index, cost = 20, awardFigureId = "BigIntoEnergy0" .. index})
    assert(receipt.debitApplied, "purchase should atomically debit and award")
end
assert(session.fundBalance == 0, "five rolls must consume the 100-unit first-clear fund")
assert(cake:Invite(1078077474).finaleState == "INVITED", "present birthday host can invite")
assert(cake:CancelInvite(3971290001).finaleState == "READY", "present Phuong can cancel")
assert(cake:Invite(3971290001).finaleState == "INVITED", "present Phuong can invite")
assert(cake:Cut(1078077474).finaleState == "CUT", "present birthday host can cut")
assert(cake:Eat(11).state == "EATING", "any present guest may eat")

local rejected = pcall(function() CakeService.new(session):Invite(12345) end)
assert(not rejected, "stranger cannot invite")
session:SetPresence(1078077474, false)
local disconnectedHost = pcall(function() CakeService.new(session):Invite(1078077474) end)
assert(not disconnectedHost, "disconnected host cannot invite")
session:SetPresence(1078077474, true)
session:SetPresence(3971290001, false)
assert(CakeService.new(session):Invite(1078077474).finaleState == "INVITED", "host alone can invite")
return true
]=],
    ["roblox/mvp/tests/Q01_activity.spec.luau"] = [=[local SessionService = require(script.Parent.Parent.server.SessionService)
local Q01 = require(script.Parent.Parent.server.activities.Q01)

return function()
	local clock = 100
	local session = SessionService.new({ sessionId = "test-session", phuongUserId = 7, hostUserId = 9 })
	session:SetPresence(7, true)
	local activity = Q01.new({ session = session, clock = function() return clock end })
	activity:CreateRound({ actorUserId = 7, roundId = "q01-r1", isReplay = false })
	local invalid = activity:Reserve({ roundId = "q01-r1", stepId = "not-a-step", actorUserId = 8 })
	assert(not invalid.ok)
	for index, stepId in ipairs(Q01.StepIds) do
		local actor = index == 1 and 7 or 8
		local offered = activity:GetView(actor)
		local reserveAction
		for _, candidate in ipairs(offered.availableActions) do if candidate.stepId == stepId and candidate.payload.action == "reserve" then reserveAction = candidate break end end
		assert(reserveAction and activity:Apply({ sessionId = session.sessionId, activityId = "Q01", roundId = "q01-r1", actionId = "reserve-a" .. index, actorUserId = actor, payload = reserveAction.payload }).ok)
		local placed = activity:GetView(actor)
		local placeAction
		for _, candidate in ipairs(placed.availableActions) do if candidate.stepId == stepId and candidate.payload.action == "place" then placeAction = candidate break end end
		assert(placeAction and activity:Apply({ sessionId = session.sessionId, activityId = "Q01", roundId = "q01-r1", actionId = "a" .. index, actorUserId = actor, payload = placeAction.payload }).ok)
	end
	local readyView = activity:GetView(7)
	local choices = {}
	for _, action in ipairs(readyView.availableActions) do if action.stepId == "finish" then choices[action.payload.choiceId] = action.enabled end end
	assert(choices.soft_snug == true and choices.neat_layered == true)
	local result = activity:Finish({ roundId = "q01-r1", actionId = "finish-1", actorUserId = 7, payload = { choiceId = "soft_snug" } })
	assert(result.ok and result.receipt.petalGranted and result.receipt.fundRewardGranted == 20)
	assert(activity:Finish({ roundId = "q01-r1", actionId = "finish-1", actorUserId = 7, payload = { choiceId = "soft_snug" } }).ok)
	assert(session.fundBalance == 20)

	-- Host cannot finish while Phuong is present; after Phuong leaves, present host may finish.
	activity:CreateRound({ actorUserId = 8, roundId = "q01-r2", isReplay = true })
	for index, stepId in ipairs(Q01.StepIds) do
		assert(activity:Reserve({ roundId = "q01-r2", stepId = stepId, actorUserId = 8 }).ok)
		assert(activity:Apply({ roundId = "q01-r2", stepId = stepId, actionId = "b" .. index, actorUserId = 8 }).ok)
	end
	session:SetPresence(9, true)
	local hostRejectedOk = pcall(function()
		activity:Finish({ roundId = "q01-r2", actionId = "finish-host-rejected", actorUserId = 9, payload = { choiceId = "neat_layered" } })
	end)
	assert(not hostRejectedOk)
	session:SetPresence(7, false)
	local hostView = activity:GetView(9)
	local hostChoices = {}
	for _, action in ipairs(hostView.availableActions) do if action.stepId == "finish" then hostChoices[action.payload.choiceId] = action.enabled end end
	assert(hostChoices.soft_snug == true and hostChoices.neat_layered == true)
	local hostFinished = activity:Finish({ roundId = "q01-r2", actionId = "finish-host-accepted", actorUserId = 9, payload = { choiceId = "neat_layered" } })
	assert(hostFinished.ok and hostFinished.preview.choiceId == "neat_layered")

	activity:CreateRound({ actorUserId = 8, roundId = "q01-r3", isReplay = true })
	assert(activity:Reserve({ roundId = "q01-r3", stepId = "pillow_left", actorUserId = 8 }).ok)
	local race = activity:Reserve({ roundId = "q01-r3", stepId = "pillow_left", actorUserId = 9 })
	assert(not race.ok and race.code == "IN_USE")
	clock += 16
	assert(activity:Reserve({ roundId = "q01-r3", stepId = "pillow_left", actorUserId = 9 }).ok)
	assert(activity:Cancel({ roundId = "q01-r3", stepId = "pillow_left", actorUserId = 9 }))
	return true
end
]=],
    ["roblox/mvp/tests/Q02_activity.spec.luau"] = [=[local Q02 = require(script.Parent.Parent.server.activities.Q02)
local SessionService = require(script.Parent.Parent.server.SessionService)
local function expect(value, message) assert(value, message) end
local function request(step, action, payload)
    return {sessionId = "q02-test", activityId = "Q02", roundId = "q02-r1", stepId = step, actionId = action, actorUserId = 101, payload = payload or {}}
end
local session = SessionService.new({sessionId = "q02-test", phuongUserId = 101, hostUserId = 0})
session:SetPresence(101, true)
session:SetPresence(202, true)
local moved, presented, pets = false, {}, 0
local activity = Q02.new({session = session, world = {
    chooseRabbitBasket = function() return 2 end,
    moveJasperToYard = function() moved = true end,
    presentFetchTarget = function(index) table.insert(presented, index) end,
    petJasper = function() pets += 1 end,
}})
activity:CreateRound({activityId = "Q02", roundId = "q02-r1", actorUserId = 101})
local function apply(step, action, payload, userId)
    local item = request(step, action, payload); item.actorUserId = userId or 101
    return activity:Apply(item)
end
apply("greet", "a-greet"); expect(moved, "greeting must request Jasper movement")
local basketActions = activity:GetView(101).availableActions
expect(#basketActions == 3 and basketActions[1].payload.basketIndex == 1, "view must offer three explicit basket actions")
local wrong = apply(basketActions[1].stepId, basketActions[1].id, basketActions[1].payload)
expect(not wrong.ok and wrong.code == "empty_basket", "wrong basket must be normal empty feedback")
local acceptedBasket = basketActions[2]
apply(acceptedBasket.stepId, acceptedBasket.id, acceptedBasket.payload)
local returnAction = activity:GetView(101).availableActions[1]
apply(returnAction.stepId, "a-return", returnAction.payload)
local fetchAction = activity:GetView(101).availableActions[1]
apply(fetchAction.stepId, "a-fetch1", fetchAction.payload)
local duplicate = apply(fetchAction.stepId, "a-fetch1", fetchAction.payload)
expect(duplicate.ok, "duplicate action returns its receipt")
local fetch2 = activity:GetView(202).availableActions[1]
apply(fetch2.stepId, "a-fetch2", fetch2.payload, 202)
local fetch3 = activity:GetView(101).availableActions[1]
apply(fetch3.stepId, "a-fetch3", fetch3.payload)
local greenie = activity:GetView(101).availableActions[1]
local completion = apply(greenie.stepId, "a-greenie", greenie.payload)
expect(completion.receipt.petalGranted and completion.receipt.fundRewardGranted == 20, "first completion must award one petal and 20 fund")
local pet = apply("pet", "a-pet")
expect(pet.receipt.reward == 0 and pets == 1, "pet is social only")
expect(#presented == 3, "each fetch target must be presented")
activity:ReleaseActor(101)

local malformed = pcall(function() apply("fetch3", "bad-after-complete", {targetIndex = 3}) end)
expect(not malformed, "completed activity must reject malformed or stale actions")
local replay = Q02.new({session = session, world = {chooseRabbitBasket = function() return 1 end}})
replay:CreateRound({activityId = "Q02", roundId = "q02-r2", actorUserId = 202, replay = true})
expect(replay:GetView(202).canReplay == false, "new replay begins incomplete")
return true
]=],
    ["roblox/mvp/tests/Q03.spec.luau"] = [=[local Q03 = require(script.Parent.Parent.server.activities.Q03)
local SessionService = require(script.Parent.Parent.server.SessionService)
local function expect(value, message) assert(value, message) end
local function setup()
    local session = SessionService.new({sessionId="s",phuongUserId=7,hostUserId=8})
    session:SetPresence(7, true); session:SetPresence(8, true)
    local t=0; local trustedUserId=7; local activity=Q03.new({session=session,actorResolver=function() return trustedUserId end,clock=function() return t end,context={}})
    activity:CreateRound({sessionId="s",activityId="Q03",roundId="r1",actorUserId=trustedUserId})
    return activity, function(v) t += v end, session
end
local activity, advance, session = setup()
local initialView = activity:GetView(7)
expect(#initialView.availableActions == 6, "view offers one concrete reserve action per piece")
expect(initialView.availableActions[1].payload.action == "reserve" and initialView.availableActions[1].stepId ~= "", "offered action is executable")
activity:Apply({sessionId="s",activityId="Q03",roundId="r1",actionId="a1",actorUserId=7,payload={action="reserve",socketId="rugSocket",partId="rug"}})
activity:Apply({sessionId="s",activityId="Q03",roundId="r1",actionId="a2",actorUserId=7,payload={action="rotate",socketId="rugSocket",direction=1}})
activity:Apply({sessionId="s",activityId="Q03",roundId="r1",actionId="a3",actorUserId=7,payload={action="place",socketId="rugSocket",partId="rug"}})
    expect(activity:GetView(7).progress.done == 1, "accepted progress is visible")
local ok=false; pcall(function() activity:Apply({sessionId="s",activityId="Q03",roundId="r1",actionId="a4",actorUserId=7,payload={action="reserve",socketId="rugSocket",partId="rug"}}) end); ok=true; expect(ok, "test harness continues after rejected conflict")
local invalidOk=pcall(function() activity:Apply({sessionId="s",activityId="Q03",roundId="r1",actionId=99,actorUserId=7,payload={action="reserve",socketId="chairSocket",partId="chair"}}) end); expect(not invalidOk, "invalid opaque action ID is rejected")
local before=session:GetSnapshot().fundBalance; local duplicate=activity:Apply({sessionId="s",activityId="Q03",roundId="r1",actionId="a3",actorUserId=7,payload={action="place",socketId="rugSocket",partId="rug"}}); expect(session:GetSnapshot().fundBalance==before and duplicate ~= nil, "duplicate action is idempotent")
local activity2, advance2 = setup(); activity2:Apply({sessionId="s",activityId="Q03",roundId="r1",actionId="b1",actorUserId=7,payload={action="reserve",socketId="chairSocket",partId="chair"}}); advance2(15); activity2:ExpireReservations("r1"); expect(activity2:GetView(7).progress.done==0, "inactive reservation expires")
for i,part in ipairs(Q03.PARTS) do local socket=Q03.SOCKETS[part]; activity2:Apply({sessionId="s",activityId="Q03",roundId="r1",actionId="c"..i,actorUserId=7,payload={action="reserve",socketId=socket,partId=part}}); activity2:Apply({sessionId="s",activityId="Q03",roundId="r1",actionId="d"..i,actorUserId=7,payload={action="place",socketId=socket,partId=part}}) end
expect(session:GetSnapshot().fundBalance == before and activity2:GetView(7).state == "COMPLETED", "completion is local to second session")
local finalized = activity2:Apply({sessionId="s",activityId="Q03",roundId="r1",actionId="f1",actorUserId=7,payload={action="finalize",presentation="lamp_on"}})
local retried = activity2:Apply({sessionId="s",activityId="Q03",roundId="r1",actionId="f2",actorUserId=7,payload={action="finalize",presentation="lamp_off"}})
expect(finalized.receipt.presentation == "lamp_on" and retried.receipt.presentation == "lamp_on", "final presentation is immutable and idempotent")
local SessionService = require(script.Parent.Parent.server.SessionService)
local realSession = SessionService.new({sessionId="q03-real", phuongUserId=7, hostUserId=9})
realSession:SetPresence(7, true)
local realActivity = Q03.new({session=realSession, clock=function() return 15 end, context={}})
realActivity:CreateRound({sessionId="q03-real", activityId="Q03", roundId="real-r1", actorUserId=7})
for index, part in ipairs(Q03.PARTS) do
    local socket = Q03.SOCKETS[part]
    realActivity:Apply({sessionId="q03-real", activityId="Q03", roundId="real-r1", actionId="real-reserve-"..index, actorUserId=7, payload={action="reserve", socketId=socket, partId=part}})
    realActivity:Apply({sessionId="q03-real", activityId="Q03", roundId="real-r1", actionId="real-place-"..index, actorUserId=7, payload={action="place", socketId=socket, partId=part}})
end
expect(realSession:GetSnapshot().petals.Q03 == true and realSession:GetSnapshot().fundBalance == 20, "real session awards exactly one Q03 petal and 20 fund")
local realFund = realSession:GetSnapshot().fundBalance
realActivity:Apply({sessionId="q03-real", activityId="Q03", roundId="real-r1", actionId="real-place-6", actorUserId=7, payload={action="place", socketId="lampSocket", partId="lamp"}})
expect(realSession:GetSnapshot().fundBalance == realFund, "real session duplicate placement adds no reward")
realActivity:ReleaseActor(7)
return true
]=],
    ["roblox/mvp/tests/Q04.spec.luau"] = [=[local Q04 = require(script.Parent.Parent.server.activities.Q04)

local function expectError(fn)
    local ok = pcall(fn)
    assert(not ok, "expected error")
end

local function newFixture()
    local service = {
        rounds = {},
        fundBalance = 0,
        petals = {},
        CreateRound = function(self, activityId, roundId, actorUserId, replay) self.rounds[roundId] = { activityId = activityId, replay = replay } end,
        ApplyStep = function(_, request) return { stepId = request.stepId, actionId = request.actionId } end,
        CompleteRound = function(self, request) self.fundBalance += 20; self.petals[request.activityId] = true; return { activityId = request.activityId, roundId = request.roundId, fundRewardGranted = 20, petalGranted = true } end,
    }
    return Q04.new({ session = service, clock = function() return 1 end }), service
end

do
    local activity = newFixture()
    activity:CreateRound({ activityId = "Q04", roundId = "r1", actorUserId = 7 })
    local saved = activity:Apply({ roundId = "r1", actionId = "a1", stepId = "s1", actorUserId = 7, payload = { passageId = "small-worlds", highlights = { "small-detail" }, reaction = "cozy", bookmark = "ribbon", note = "later" } })
    assert(saved.ok and saved.code == "SAVED" and saved.draft.bookmark == "ribbon")
    local view = activity:GetView(7)
    assert(view.reading and view.reading.text and #view.availableActions == 11)
    assert(activity:Apply({ roundId = "r1", actionId = "a1", stepId = "s1", actorUserId = 7, payload = { passageId = "small-worlds", revision = 0 } }) == saved)
    local receipt = activity:Apply({ roundId = "r1", actionId = "complete-1", actorUserId = 7, payload = { passageId = "small-worlds", complete = true } }).receipt
    assert(receipt.fundRewardGranted == 20 and receipt.petalGranted == true)
    local late = activity:Apply({ roundId = "r1", actionId = "complete-2", actorUserId = 7, payload = { passageId = "small-worlds", bookmark = "star-tab", complete = true } })
    assert(late.ok and late.code == "ACKNOWLEDGED" and late.receipt == nil and late.draft.bookmark == "star-tab")
end

do
    local activity, service = newFixture()
    activity:CreateRound({ activityId = "Q04", roundId = "r1", actorUserId = 7 })
    activity:Apply({ roundId = "r1", actionId = "a1", actorUserId = 7, payload = { passageId = "small-worlds", highlights = { "small-detail" }, reaction = "cozy", bookmark = "ribbon" } })
    local first = activity:Apply({ roundId = "r1", actionId = "complete-a", actorUserId = 7, payload = { passageId = "small-worlds", complete = true } })
    assert(first.receipt.fundRewardGranted == 20 and first.receipt.petalGranted == true and service.fundBalance == 20 and service.petals.Q04 == true)
    local second = activity:Apply({ roundId = "r1", actionId = "b1", actorUserId = 8, payload = { passageId = "night-pages", highlights = { "comforting-moment" }, reaction = "moved", bookmark = "star-tab" } })
    assert(second.code == "ACKNOWLEDGED" and second.draft.bookmark == "star-tab")
    local resave = activity:Apply({ roundId = "r1", actionId = "a2", actorUserId = 7, payload = { passageId = "small-worlds", highlights = { "shared-spark" }, reaction = "smile", bookmark = "pressed-flower" } })
    assert(resave.code == "ACKNOWLEDGED" and resave.receipt == nil and service.fundBalance == 20 and service.petals.Q04 == true)
    assert(service.rounds.r1 ~= nil)
end

do
    local activity = newFixture()
    activity:CreateRound({ activityId = "Q04", roundId = "r1", actorUserId = 7 })
    expectError(function() activity:Apply({ roundId = "r1", actionId = "a1", actorUserId = 7, payload = { passageId = "small-worlds", highlights = { "small-detail", "comforting-moment", "shared-spark", "extra" } } }) end)
    expectError(function() activity:Apply({ roundId = "r1", actionId = "a2", actorUserId = 7, payload = { passageId = "small-worlds", highlights = { "small-detail" }, reaction = "cozy", bookmark = "ribbon", revision = 4 } }) end)
end

return true
]=],
    ["roblox/mvp/tests/q05.spec.luau"] = [=[local SessionService = require(script.Parent.Parent.server.SessionService)
local Q05 = require(script.Parent.Parent.server.activities.Q05)
local function expect(value, message) assert(value, message) end
local phuong = 3971290001; local outcomes = {"BigIntoEnergy02", "BigIntoEnergy03", "BigIntoEnergy04", "BigIntoEnergy05", "BigIntoEnergy06", "BigIntoEnergy02"}; local index = 0
local session = SessionService.new({sessionId = "q05-test", phuongUserId = phuong, hostUserId = 0}); session:AddFund(120)
session:SetPresence(phuong, true)
local activity = Q05.new({session = session, outcome = function() index += 1; return outcomes[index] end})
activity:CreateRound({activityId = "Q05", roundId = "q05-r1", actorUserId = phuong}); activity:Apply({roundId = "q05-r1", stepId = "select-wanted", actionId = "wanted", actorUserId = phuong, payload = {figureId = "BigIntoEnergy01"}})
local initialView = activity:GetView(phuong); local foundSelection = false; expect(string.find(initialView.instructions, "Collection copies: 0") ~= nil, "initial collection display must be zero"); for _, action in ipairs(initialView.availableActions) do if action.payload and action.payload.figureId == "BigIntoEnergySecret" and action.label == "Want Secret figure" then foundSelection = true end end; expect(foundSelection, "view must expose readable figure-specific wanted payload")
for i = 1, 4 do activity:Apply({roundId = "q05-r1", stepId = "roll", actionId = "miss" .. i, actorUserId = phuong}) end
local guaranteed = activity:Apply({roundId = "q05-r1", stepId = "roll", actionId = "guaranteed", actorUserId = phuong}); expect(guaranteed.receipt.awardFigureId == "BigIntoEnergy01", "fifth roll must guarantee target"); expect(guaranteed.receipt.petalGranted, "target grants petal"); expect(session.fundBalance == 20, "five rolls cost 100"); expect(string.find(activity:GetView(phuong).instructions, "Collection copies: 5") ~= nil, "collection display must show awarded copies")
expect(activity:Apply({roundId = "q05-r1", stepId = "roll", actionId = "guaranteed", actorUserId = phuong}).code == "DUPLICATE", "duplicate is idempotent")
activity:Apply({roundId = "q05-r1", stepId = "select-wanted", actionId = "new-wish", actorUserId = phuong, payload = {figureId = "BigIntoEnergy02"}})
activity:Apply({roundId = "q05-r1", stepId = "roll", actionId = "new-wish-roll", actorUserId = phuong})
local owned = activity:Apply({roundId = "q05-r1", stepId = "select-wanted", actionId = "owned-wish", actorUserId = phuong, payload = {figureId = "BigIntoEnergy01"}})
expect(owned.code == "WANTED_ALREADY_OWNED" and owned.receipt.petalGranted == false, "owned figure fulfills new wish without a second petal")
local idSession = SessionService.new({sessionId = "q05-id-test", phuongUserId = phuong, hostUserId = 0}); idSession:AddFund(100)
idSession:SetPresence(phuong, true)
local idIndex = 0; local idActivity = Q05.new({session = idSession, outcome = function() idIndex += 1; return "BigIntoEnergy01" end})
idActivity:CreateRound({activityId = "Q05", roundId = "q05-id", actorUserId = phuong}); idActivity:Apply({roundId = "q05-id", stepId = "select-wanted", actionId = "id-wanted", actorUserId = phuong, payload = {figureId = "BigIntoEnergySecret"}})
for i = 1, 4 do idActivity:Apply({roundId = "q05-id", stepId = "roll", actionId = "id-miss" .. i, actorUserId = phuong}) end
local idGuaranteed = idActivity:Apply({roundId = "q05-id", stepId = "roll", actionId = "id-guaranteed", actorUserId = phuong})
expect(idGuaranteed.receipt.awardFigureId == "BigIntoEnergySecret", "fifth roll must guarantee selected secret ID")
local weightedSession = SessionService.new({sessionId = "q05-weighted", phuongUserId = phuong, hostUserId = 0}); weightedSession:SetPresence(phuong, true)
local weighted = Q05.new({session = weightedSession, random = function() return 0.999 end}); weighted:CreateRound({activityId = "Q05", roundId = "q05-weighted", actorUserId = phuong}); expect(weighted:_draw() == "BigIntoEnergySecret", "weighted default must reach secret boundary")
return true
]=],
    ["roblox/mvp/tests/Q06.spec.luau"] = [=[local Q06 = require(script.Parent.Parent.server.activities.Q06)

local function expect(condition, message) assert(condition, message) end
local now = 100
local clock = function() return now end
local Session = require(script.Parent.Parent.server.SessionService)
local session = Session.new({ sessionId = "q06-test", phuongUserId = 7, hostUserId = 0 })
session:SetPresence(7, true)
session:SetPresence(8, true)
session:SetPresence(9, true)
session:SetPresence(10, true)
session:SetPresence(11, true)
session:SetPresence(12, true)
local activity = Q06.new({ session = session, actor = { userId = 7 }, clock = clock, context = { anchors = {} } })
activity:CreateRound({ sessionId = "q06-test", activityId = "Q06", roundId = "q06-r1", actionId = "create-q06-r1", stepId = "round-start", actorUserId = 7 })

local accepted = activity:Apply({ sessionId = "q06-test", activityId = "Q06", roundId = "q06-r1", stepId = "base", actionId = "a-base", actorUserId = 7, payload = { slotId = "base", itemId = "rice" } })
expect(accepted.ok and accepted.receipt.itemId == "rice", "base action should be accepted")
expect(activity:Apply({ sessionId = "q06-test", activityId = "Q06", roundId = "q06-r1", stepId = "base", actionId = "a-base-duplicate", actorUserId = 7, payload = { slotId = "base", itemId = "rice" } }).receipt.stepId == "base", "filled slot should be idempotent")

local blocked = activity:Reserve({ sessionId = "q06-test", activityId = "Q06", roundId = "q06-r1", stepId = "toppings", actionId = "reserve-t", actorUserId = 7, payload = { slotId = "toppings" } })
expect(blocked.accepted == nil and blocked.slotId == "toppings", "reservation should be created")
local other = activity:Reserve({ sessionId = "q06-test", activityId = "Q06", roundId = "q06-r1", stepId = "toppings", actionId = "reserve-t2", actorUserId = 8, payload = { slotId = "toppings" } })
expect(other.accepted == false and other.busyReason == "slot-in-use", "concurrent reservation should be rejected")
activity:Cancel({ sessionId = "q06-test", activityId = "Q06", roundId = "q06-r1", stepId = "toppings", actionId = "cancel-t", actorUserId = 7, payload = { slotId = "toppings" } })
expect(activity:Reserve({ sessionId = "q06-test", activityId = "Q06", roundId = "q06-r1", stepId = "toppings", actionId = "reserve-t3", actorUserId = 8, payload = { slotId = "toppings" } }).actorUserId == 8, "cancel releases only the slot")

local slots = { { "toppings", "greens" }, { "protein", "tofu" }, { "sauce", "sauce" }, { "settingA", "plate" }, { "settingB", "cup" } }
for index, pair in ipairs(slots) do
	local actor = index + 8
	local slot = pair[1]
	if slot == "toppings" then activity:Cancel({ sessionId = "q06-test", activityId = "Q06", roundId = "q06-r1", stepId = slot, actionId = "cancel-t2", actorUserId = 8, payload = { slotId = slot } }) end
	local result = activity:Apply({ sessionId = "q06-test", activityId = "Q06", roundId = "q06-r1", stepId = slot, actionId = "a-" .. slot, actorUserId = actor, payload = { slotId = slot, itemId = pair[2] } })
	expect(result.ok, "parallel step should be accepted: " .. slot)
end
local view = activity:GetView(7)
expect(view.state == "COMPLETED" and view.canReplay == true, "all six steps should complete Q06")
expect(session.fundBalance == 20 and session.petals.Q06 == true, "completion should use one shared reward and petal")
local lateOk = pcall(function() activity:Apply({ sessionId = "q06-test", activityId = "Q06", roundId = "q06-r1", stepId = "base", actionId = "late", actorUserId = 9, payload = { slotId = "base", itemId = "rice" } }) end)
expect(not lateOk, "completed rounds must reject new work")

activity:CreateRound({ sessionId = "q06-test", activityId = "Q06", roundId = "q06-r2", actionId = "create-q06-r2", stepId = "round-start", actorUserId = 7 })
local replayView = activity:GetView(7)
expect(replayView.roundId == "q06-r2" and replayView.progress.done == 0 and replayView.progress.total == 6, "replay view must use the new round")
local replayItems = { { "base", "rice" }, { "toppings", "carrot" }, { "protein", "tofu" }, { "sauce", "sauce" }, { "settingA", "plate" }, { "settingB", "cup" } }
for index, pair in ipairs(replayItems) do
	local result = activity:Apply({ sessionId = "q06-test", activityId = "Q06", roundId = "q06-r2", stepId = pair[1], actionId = "replay-" .. pair[1], actorUserId = 7, payload = { slotId = pair[1], itemId = pair[2] } })
	expect(result.ok, "replay step should be accepted: " .. pair[1])
end
expect(session.fundBalance == 30 and session.petals.Q06 == true, "replay grants 10 and no second petal")
local oldDuplicate = pcall(function() activity:Apply({ sessionId = "q06-test", activityId = "Q06", roundId = "q06-r1", stepId = "base", actionId = "old-round-new-action", actorUserId = 7, payload = { slotId = "base", itemId = "rice" } }) end)
expect(not oldDuplicate, "old completed round cannot reward again")
return true
]=],
    ["roblox/mvp/tests/queue_service.spec.luau"] = [=[local QueueService = require(script.Parent.Parent.server.QueueService)

local now = 0
local queue = QueueService.new({ clock = function() return now end })
local function expect(condition, message)
	assert(condition, message)
end

local ok, reason, snapshot = queue:Join(1, now)
expect(ok and reason == "Joined" and snapshot.deadlineAt == 60, "first join starts 60 seconds")
for userId = 2, 7 do
		queue:Join(userId, now)
end
now = 5
ok, reason, snapshot = queue:Join(8, now)
expect(ok and snapshot.deadlineAt == 15, "eight at five shortens to t15")
queue:Join(9, now)
queue:Join(10, now)
expect(queue:Join(11, now) == false, "eleventh is rejected")
queue:Leave(1)
expect(queue:Snapshot().deadlineAt == 15, "falling below eight does not extend")
now = 15
ok, reason, localRoster = queue:Tick(now)
expect(ok and reason == "Frozen" and #localRoster.members == 9, "expiry freezes exact roster")
expect(queue:Tick(now) == false, "freeze is exactly once")

local empty = QueueService.new({ clock = function() return now end })
empty:Join(1, now)
local generation = empty:Snapshot().generation
empty:Leave(1)
expect(empty:Snapshot().state == "Empty" and empty:Snapshot().generation == generation + 1, "empty queue resets generation")

return true
]=],
    ["roblox/mvp/tests/session_service.spec.luau"] = [=[local SessionService = require(script.Parent.Parent.server.SessionService)

local function expect(condition, message)
    assert(condition, message)
end

local session = SessionService.new({ sessionId = "test-session", phuongUserId = 3971290001, hostUserId = 0 })
session:SetPresence(3971290001, true)
session:CreateRound("Q01", "q01-r1", 3971290001)
session:ApplyStep({ sessionId = "test-session", activityId = "Q01", roundId = "q01-r1", stepId = "tuck", actionId = "a1", actorUserId = 3971290001 })
session:ApplyStep({ sessionId = "test-session", activityId = "Q01", roundId = "q01-r1", stepId = "tuck", actionId = "a1-repeat", actorUserId = 3971290001 })
local first = session:CompleteRound({ sessionId = "test-session", activityId = "Q01", roundId = "q01-r1", actionId = "complete-1", actorUserId = 3971290001 })
expect(first.petalGranted and first.fundRewardGranted == 20, "first clear should grant one petal and 20")
expect(session.fundBalance == 20, "fund must not multiply by taps")
expect(session:CompleteRound({ sessionId = "test-session", activityId = "Q01", roundId = "q01-r1", actionId = "complete-2", actorUserId = 3971290001 }).receiptId == first.receiptId, "duplicate completion must return receipt")

session:CreateRound("Q01", "q01-r2", 3971290001, true)
session:ApplyStep({ sessionId = "test-session", activityId = "Q01", roundId = "q01-r2", stepId = "replay-step", actionId = "replay-a1", actorUserId = 3971290001 })
local replay = session:CompleteRound({ sessionId = "test-session", activityId = "Q01", roundId = "q01-r2", actionId = "complete-3", actorUserId = 3971290001 })
expect(not replay.petalGranted and replay.fundRewardGranted == 10, "replay grants 10 and no second petal")
expect(session.fundBalance == 30, "replay fund should be exactly 10")

session:CreateRound("Q05", "q05-r1", 3971290001)
session:ApplyStep({ sessionId = "test-session", activityId = "Q05", roundId = "q05-r1", stepId = "q05-step", actionId = "q05-a1", actorUserId = 3971290001 })
local q05 = session:CompleteRound({ sessionId = "test-session", activityId = "Q05", roundId = "q05-r1", actionId = "complete-q05", actorUserId = 3971290001 })
expect(q05.fundRewardGranted == 0, "Q05 must never earn fund currency")

local auth = SessionService.new({ sessionId = "auth-test", phuongUserId = 7, hostUserId = 1078077474 })
auth:AddFund(20)
auth:SetPresence(7, true)
auth:SetPresence(1078077474, true)
local function rejected(callback)
    local ok = pcall(callback)
    expect(not ok, "request should be rejected")
end
rejected(function() auth:CommitPurchase({ actorUserId = 99, actionId = "guest", cost = 20, awardFigureId = "x" }) end)
rejected(function() auth:CommitPurchase({ actorUserId = 1078077474, actionId = "host-while-phuong-present", cost = 20, awardFigureId = "x" }) end)
auth:SetPresence(7, false)
local hostPurchase = auth:CommitPurchase({ actorUserId = 1078077474, actionId = "host-while-phuong-away", cost = 20, awardFigureId = "x" })
expect(hostPurchase.debitApplied, "host may act only while Phuong is absent")
auth:AddFund(20)
auth:SetPresence(1078077474, false)
rejected(function() auth:CommitPurchase({ actorUserId = 1078077474, actionId = "disconnected-host", cost = 20, awardFigureId = "x" }) end)
return true
]=],
    ["roblox/mvp/tests/teleport_adapter.spec.luau"] = [=[local TeleportAdapter = require(script.Parent.Parent.server.TeleportAdapter)

local calls = 0
local reserves = 0
local fakeTeleport = {
	TeleportAsync = function(_, placeId, players, options)
		calls += 1
		assert(placeId == 123, "configured destination is used")
		assert(#players == 2, "whole party is submitted")
		assert(options.ReservedServerAccessCode == "reserved-test", "same reserved destination is reused")
		return { ReservedServerAccessCode = "test-only" }
	end,
}

local adapter = TeleportAdapter.new({ GameplayPlaceId = 123, MaxRetries = 1 }, {
	teleportService = fakeTeleport,
	reserveServer = function(placeId)
		reserves += 1
		assert(placeId == 123, "reservation uses configured destination")
		return "reserved-test", "private-test"
	end,
	isStudio = false,
	wait = function() end,
})
local ok, reason = adapter:Transfer({ "p1", "p2" }, {
	rosterId = "birthday-1",
	destinationReservationId = "destination-1",
	members = { 1, 2 },
})
assert(ok and reason == "Dispatched" and calls == 1 and reserves == 1, "production adapter reserves and submits once")
local retryOk, retryReason = adapter:RetryMember("p1", {
	rosterId = "birthday-1",
	destinationReservationId = "destination-1",
	members = { 1, 2 },
	reservedServerAccessCode = "reserved-test",
}, 1)
assert(retryOk and retryReason == "RetryDispatched" and reserves == 1, "retry reuses reservation")

local studioAdapter = TeleportAdapter.new({ GameplayPlaceId = 123 }, {
	isStudio = true,
	teleportService = fakeTeleport,
})
ok, reason = studioAdapter:Transfer({}, { members = {} })
assert(not ok and reason == "StudioTeleportUnsupported", "Studio never pretends teleport succeeded")

return true
]=],
    ["roblox/mvp/tests/view_actions_check.spec.luau"] = [=[local SessionService = require(script.Parent.Parent.server.SessionService)
local Q01 = require(script.Parent.Parent.server.activities.Q01)

-- Verifier-side check: consume one actual Q01 view action, not a hand-written step ID.
local session = SessionService.new({sessionId = "view-action-check", phuongUserId = 7, hostUserId = 0})
local activity = Q01.new({session = session, clock = function() return 100 end})
activity:CreateRound({actorUserId = 7, roundId = "view-r1", isReplay = false})
local view = activity:GetView(7)
local offered
for _, action in ipairs(view.availableActions) do
    if action.enabled and action.stepId ~= "finish" then offered = action; break end
end
assert(offered and offered.payload and offered.payload.stepId == offered.stepId, "Q01 view action must carry its real step payload")
assert(activity:Reserve({roundId = view.roundId, stepId = offered.stepId, actorUserId = 7}).ok, "offered Q01 action must reserve")
local result = activity:Apply({roundId = view.roundId, stepId = offered.stepId, actionId = "view-action-1", actorUserId = 7, payload = offered.payload})
assert(result.ok, "offered Q01 action rejected: " .. tostring(result.code))
assert(result.accepted and result.accepted.receipt and result.accepted.receipt.stepId == offered.stepId, "offered Q01 action must return its accepted step")
return true
]=]
}
local hashes = {
    ["roblox/mvp/build-world.luau"] = [=[3D3C86BEF7FBE4D6519E7AC7A8471D9E8CE91B657CCAC253A69A392967CEC250]=],
    ["roblox/mvp/builders/CakeFinale.luau"] = [=[946E2F2CB5F61A4F81C79C619D3EB40A144739C60A182B4BDAF7701CC01E1A7C]=],
    ["roblox/mvp/builders/GrassDecoration.luau"] = [=[ACE88714C084E1661B120AC448575831F24CCC633AB9C8CBA9C5C38CB32182F9]=],
    ["roblox/mvp/builders/LobbyQueue.luau"] = [=[975ADA6AFA10E774D5022705ED83325B1D51F4F468E478CECF5D76416884DB18]=],
    ["roblox/mvp/builders/NightLighting.luau"] = [=[6FEF0BB78720D6F71F9F47BAA8E71738EA5F474685A0216C7B1DBEE21E84C286]=],
    ["roblox/mvp/builders/Q01Station.luau"] = [=[D172A10A3D526B85433DE5FA17BCBB05D9E927CF63BB305CAF61F8F14E96AAE6]=],
    ["roblox/mvp/builders/Q02Station.luau"] = [=[A6242204D72BA38288F0A369466E4EE0F3B8CDE37214A7C0872F58705E4B0807]=],
    ["roblox/mvp/builders/Q03Station.luau"] = [=[731FBE638669BCF4316C40090931A74F43B499FCACAD2D8D8DFBEAE56E4D58C9]=],
    ["roblox/mvp/builders/Q04Station.luau"] = [=[00655CA8B550D50AECD95589E78DFF7AED2B5143172877ED876E01EF6A73F2D5]=],
    ["roblox/mvp/builders/Q05Station.luau"] = [=[D5F2D591DD2CAB2FEB0C812D39D727D4516097C4360C0313FC48F888059C6C50]=],
    ["roblox/mvp/builders/Q06Station.luau"] = [=[79EE132C0E70020683A6EC1F1C8287854A81311C0D8FBA3C4D933937F5656FC3]=],
    ["roblox/mvp/builders/SeattleBoundary.luau"] = [=[76B6827E49000B1C6486EAF519501157FF9BC0C81811A0A12AA188A0D73B4EA3]=],
    ["roblox/mvp/client/activities/Q01.luau"] = [=[296BE5460CB07DB60E29AAD61FD23AAC09C8E5992D7FD9C7B8EDF6C93BFB569B]=],
    ["roblox/mvp/client/activities/Q02.luau"] = [=[40F5666C6CBA1BFD249C421BBBE367E7E1944D1607914DE90875CC961F546F80]=],
    ["roblox/mvp/client/activities/Q03.luau"] = [=[EAFAA784A3090765B3DB7C82BEE86C9278FB78A778BDA82868CB77E7673376E0]=],
    ["roblox/mvp/client/activities/Q04.luau"] = [=[5D4A8B294FFDA0BF59868125E06738A3D52FA413B83B7944A2B2429B63CCC4D3]=],
    ["roblox/mvp/client/activities/Q06.luau"] = [=[C738FC533E351712C98B7046C67D6777E57E7CF42171CC6CB2F92B0573496AA2]=],
    ["roblox/mvp/client/Main.client.luau"] = [=[DD2A27A3BFC04847BFC94A59A1443B4D5FFD3F6D224FFFC687FEAC1E35ABCA8E]=],
    ["roblox/mvp/install.luau"] = [=[3B64EC04EB7F47F3E6031DD6EB13EBA2F1582787DB1A55EAC6E642349C82C339]=],
    ["roblox/mvp/server/activities/Q01.luau"] = [=[3773F06B01026DA2851BFF02C2D9142C406CFD44A51D339E4BEE3A028D78F36A]=],
    ["roblox/mvp/server/activities/Q02.luau"] = [=[98BB044B530BBF4E2D4A6B7E1CB8F45F95BFF61158AD90F5DA655C7F5DAE0D27]=],
    ["roblox/mvp/server/activities/Q03.luau"] = [=[D72B4E25EA406E6E5BA99FDF7F195BD4962DA85EE213BABC8F8E5557EAB8C4D3]=],
    ["roblox/mvp/server/activities/Q04.luau"] = [=[1BEC8E214D3E25924D77A7F9B8CC5C3729032102B86E1BC43E25A33C756FE6A4]=],
    ["roblox/mvp/server/activities/Q05.luau"] = [=[3C9FC62692DFA1A7F16CD88D203BEB1367CBC8EBB6B72596B41FEEB0D3DB6B74]=],
    ["roblox/mvp/server/activities/Q06.luau"] = [=[96B89A12D677459FF8BF4ABE767BA440707EA4ACA212CA43FA4445BAC2776B8E]=],
    ["roblox/mvp/server/CakeService.luau"] = [=[5D7D5D7BA39C11F67B67A466DE1853E34E551206A99EB741A51D5B4822428B39]=],
    ["roblox/mvp/server/LocalPartyTransferAdapter.luau"] = [=[9C28106FAACE5C26AFF5FAA8FF19EDE60939F37BF62D2F6CD7CBB13970B1988D]=],
    ["roblox/mvp/server/Main.server.luau"] = [=[B153B2D300EAB85D35F2EF5A675635175FFE242341F416D036EE6E33E2EA3F9D]=],
    ["roblox/mvp/server/QueueService.luau"] = [=[9C1F7322949395896229FF7EDC9AB0E719F9B5AA642B1EF42A2968724D9B920B]=],
    ["roblox/mvp/server/SessionService.luau"] = [=[1725E383387CB9FE68964E1838900A587E9FDA19371B41EF24953612702A35BF]=],
    ["roblox/mvp/server/TeleportAdapter.luau"] = [=[22082E97B07DD791D41107730700589AC1C8EC5306C5C0B6C92E20F20B09A00D]=],
    ["roblox/mvp/shared/Anchors.luau"] = [=[0D8D42052DB32E17D23ED3EBB6317FD52A985DA0695946DD4C5E70CDD328626C]=],
    ["roblox/mvp/shared/Config.luau"] = [=[3DD7A7557ED9D7C0A3391FAD03D8E67AC175392C0412B4A395C8DECDDAEA6034]=],
    ["roblox/mvp/shared/MeasuredInstallOptions.luau"] = [=[00871AD4417CDFBAC7D55CBCE7B73B0D1D674C52924339C5F27412BB75B661AC]=],
    ["roblox/mvp/tests/cake_service.spec.luau"] = [=[49610DD6D7D51B3AF234A71DA2329484FA8550F3EB3D40EEF446ADEA518DA8D2]=],
    ["roblox/mvp/tests/Q01_activity.spec.luau"] = [=[B2BF05A078A9451B5674143617EBDD131EB071AD98D9EF9D8CB71F65EC2004BD]=],
    ["roblox/mvp/tests/Q02_activity.spec.luau"] = [=[8EA6139A1B59EF2ED15298A842C30E029C038032B53819901DBFD90B1288E619]=],
    ["roblox/mvp/tests/Q03.spec.luau"] = [=[A1A7D1194D3AEE5A94DB0DD554EC9CFB9DBCBE8E3E7930A8862642281A3E7E51]=],
    ["roblox/mvp/tests/Q04.spec.luau"] = [=[96AE5ED7838C09FCF6D313D98048A5B3AB800167D62897CA0DE816C2EE9E56FF]=],
    ["roblox/mvp/tests/q05.spec.luau"] = [=[131F3682F6808AC5F51A178CCC7B6C25214DAD26D9862E47CA810C6C8C3243C1]=],
    ["roblox/mvp/tests/Q06.spec.luau"] = [=[BD7730C76FB513EA75DDAE7E33E7CD7F3DDE1B070C121E1033F02DAA1EAD2D83]=],
    ["roblox/mvp/tests/queue_service.spec.luau"] = [=[E28CBFAAA9406076FDF041146117684F26E3DAD40ABB5BD5AD24E52B5BD7FEC9]=],
    ["roblox/mvp/tests/session_service.spec.luau"] = [=[FB4B5302FF6552ABCE8541E68FAE98501BC6E523ADF4274E151C7088604CF0B5]=],
    ["roblox/mvp/tests/teleport_adapter.spec.luau"] = [=[891A85F630768DFF57A33CD883672B3475C980DAA94B969F985D9C171BBCF74B]=],
    ["roblox/mvp/tests/view_actions_check.spec.luau"] = [=[1DA767B29C285961C98067C8462B98D8627FD171DDC08134C0B873F949A58AF2]=]
}

local function node(name, parent, path)
    local n = {Name = name, Parent = parent, _path = path, _children = {}, _module = nil}
    setmetatable(n, {__index = function(self, key) return self._children[key] end})
    function n:FindFirstChild(child)
        return self._children[child]
    end
    if parent then parent._children[name] = n end
    return n
end

local root = node("root", nil, "")
local nodes = {}
for path in pairs(sources) do
    local parent = root
    local built = ""
    for segment in string.gmatch(path, "[^/]+") do
        built = built == "" and segment or built .. "/" .. segment
        parent = nodes[built] or node(segment, parent, built)
        nodes[built] = parent
        if string.sub(segment, -5) == ".luau" then
            local alias = string.sub(segment, 1, -6)
            parent.Parent._children[alias] = parent
            nodes[string.sub(built, 1, -6)] = parent
        end
    end
end

local function loadModule(target)
    if target._module ~= nil then return target._module end
    local source = sources[target._path]
    assert(source, "not a module source: " .. tostring(target._path))
    local chunk, compileError = loadstring(source, "@" .. target._path)
    assert(chunk, compileError)
    local environment = setmetatable({script = target}, {__index = _G})
    environment.require = function(child)
        assert(type(child) == "table" and child._path, "test adapter require expects a ModuleScript node")
        return loadModule(child)
    end
    setfenv(chunk, environment)
    target._module = assert(chunk())
    return target._module
end

local specs = {
    "roblox/mvp/tests/session_service.spec.luau",
    "roblox/mvp/tests/queue_service.spec.luau",
    "roblox/mvp/tests/cake_service.spec.luau",
    "roblox/mvp/tests/Q01_activity.spec.luau",
    "roblox/mvp/tests/Q02_activity.spec.luau",
    "roblox/mvp/tests/Q03.spec.luau",
    "roblox/mvp/tests/Q04.spec.luau",
    "roblox/mvp/tests/q05.spec.luau",
    "roblox/mvp/tests/Q06.spec.luau",
    "roblox/mvp/tests/view_actions_check.spec.luau",
}

for path, digest in pairs(hashes) do
    if string.find(path, "roblox/mvp/server/") then
        print("SOURCE_HASH " .. path .. " " .. digest)
    end
end

local passed, failed = 0, 0
for _, path in ipairs(specs) do
    print("RUN " .. path)
    local ok, result = xpcall(function() return loadModule(nodes[path]) end, debug.traceback)
    if ok and type(result) == "function" then
        ok, result = pcall(result)
    end
    if ok and result == true then
        passed += 1
        print("PASS " .. path)
    else
        failed += 1
        print("FAIL " .. path .. " " .. tostring(result))
    end
end
print(string.format("SUMMARY passed=%d failed=%d", passed, failed))
if failed > 0 then error("module specs failed") end
