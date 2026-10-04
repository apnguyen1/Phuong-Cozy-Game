local sources = {
["roblox/mvp/afternoon-quad.luau"] = [=[-- Repeatable Edit-mode afternoon lighting and six extra Quad lamps.
local lighting=game:GetService("Lighting")
lighting.ClockTime=15.5; lighting.Brightness=1.6; lighting.ExposureCompensation=-.15
lighting.GlobalShadows=true; lighting.Ambient=Color3.fromRGB(168,185,149); lighting.OutdoorAmbient=Color3.fromRGB(168,185,149)
lighting.EnvironmentDiffuseScale=.65; lighting.EnvironmentSpecularScale=.15; lighting.ShadowSoftness=.85
local root=workspace.CozyWorld_Draft01
local quad=root.QuadPlanting
local old=quad:FindFirstChild("AfternoonLamps")
if old then old:Destroy() end
local folder=Instance.new("Folder"); folder.Name="AfternoonLamps"; folder:SetAttribute("VerificationTicket","MAP-03"); folder.Parent=quad
local reference=quad:WaitForChild("PathLantern1"):GetPivot().Position
local colors={ink=Color3.fromRGB(38,56,46),golden=Color3.fromRGB(232,199,121)}
local function part(model,name,size,position,token)
 local p=Instance.new("Part"); p.Name=name; p.Size=size; p.Position=position; p.Anchored=true
 p.CanCollide=false; p.CanTouch=false; p.CanQuery=false; p.Color=colors[token]; p.Material=Enum.Material.SmoothPlastic
 p:SetAttribute("PaletteToken",token); p:SetAttribute("VerificationTicket","MAP-03"); p.Parent=model; return p
end
for i,offset in ipairs({Vector3.new(0,0,50),Vector3.new(0,0,100),Vector3.new(0,0,145),Vector3.new(177,0,25),Vector3.new(177,0,65),Vector3.new(177,0,155)}) do
 local model=Instance.new("Model"); model.Name=string.format("QuadLamp%02d",i); model.Parent=folder
 local base=reference+offset+Vector3.new(0,.06,0)
 local ray=RaycastParams.new(); ray.FilterType=Enum.RaycastFilterType.Include; ray.FilterDescendantsInstances={root.Landscape,root.Paths}
 local hit=workspace:Raycast(base+Vector3.new(0,20,0),Vector3.new(0,-40,0),ray)
 if hit then base=Vector3.new(base.X,hit.Position.Y,base.Z) end
 part(model,"Foot",Vector3.new(1.2,.25,1.2),base+Vector3.new(0,.125,0),"ink")
 part(model,"Post",Vector3.new(.3,10,.3),base+Vector3.new(0,5,0),"ink")
 part(model,"LanternBase",Vector3.new(1.2,.2,1.2),base+Vector3.new(0,10,0),"ink")
 local glow=part(model,"WarmGlass",Vector3.new(.85,1.2,.85),base+Vector3.new(0,10.7,0),"golden")
 part(model,"LanternCap",Vector3.new(1.4,.25,1.4),base+Vector3.new(0,11.45,0),"ink")
 local light=Instance.new("PointLight"); light.Name="WarmLampLight"; light.Color=colors.golden; light.Brightness=.45; light.Range=14; light.Shadows=false; light.Parent=glow
end
return {clock=lighting.ClockTime,extraLamps=#folder:GetChildren()}
]=],
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
	-- The existing BirthdayLobby.Portal.TeleportPad owns the visible boarding circle.
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
		manifest = { Ticket = TICKET, Builder = BUILDER, Owner = "Task08", AnchorName = "BirthdayLobbyQueue", Footprint = "existing 12-stud boarding circle", ApproachClearance = "16 studs / 12 studs", QueueRule = "one opt-in queue, max 10, shared deadline" },
	}
end
]=],
["roblox/mvp/builders/NightLighting.luau"] = [=[-- Edit-mode builder. Requiring this module has no live-world side effects.
-- Canonical integration shape: return function(context).
local COLORS={sage=Color3.fromRGB(168,185,149),golden=Color3.fromRGB(232,199,121),cream=Color3.fromRGB(245,240,228),forest=Color3.fromRGB(54,87,68),ink=Color3.fromRGB(38,56,46)}
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
  local light=Instance.new("PointLight"); light.Name="WarmFixture"; light.Color=COLORS.golden; light.Brightness=options.lowGraphics and math.min(definition.brightness,1) or definition.brightness; light.Range=definition.range; light.Shadows=not options.lowGraphics and definition.shadows; light.Parent=part
  table.insert(created,name); if light.Shadows then shadowCount+=1 end
 end
 folder:SetAttribute("CreatedFixtureCount",#created); folder:SetAttribute("ShadowFixtureCount",shadowCount); return folder,created,shadowCount
end
local function applyGlobals(lighting)
 lighting.ClockTime=15.5; lighting.Brightness=1.6; lighting.ExposureCompensation=-.15; lighting.GlobalShadows=true; lighting.Ambient=COLORS.sage; lighting.OutdoorAmbient=COLORS.sage; lighting.EnvironmentDiffuseScale=.65; lighting.EnvironmentSpecularScale=.15; lighting.ShadowSoftness=.85
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
["roblox/mvp/builders/Q01Station.luau"] = [=[-- Compatibility station builder. PCW-19 uses the detailed Home.Bedroom.SageBed.
-- Runtime BedroomFeedback supplies task cues; never create another bed here.
return function(context)
	assert(context and context.Root and context.MVP and context.Anchors and context.SafeReplace, "Q01Station context is incomplete")
	local home = context.Root:FindFirstChild("Home")
	local room = home and home:FindFirstChild("Bedroom")
	assert(room and room:FindFirstChild("SageBed"), "Q01 requires the existing detailed SageBed")
	local manifest = {
		AnchorName = "Q01Bed", Footprint = "Existing Home.Bedroom.SageBed; no duplicate geometry",
		Owner = "PCW-19", SourceBuilder = "roblox/mvp/builders/Q01Station.luau",
		ApproachClearance = "Existing bedroom circulation; final integration review required",
	}
	local installed = context.SafeReplace("Q01Station", function()
		local model = Instance.new("Model"); model.Name = "Q01Station"
		model:SetAttribute("ActivityId", "Q01"); model:SetAttribute("VerificationTicket", "PCW-19")
		model:SetAttribute("MVPBuilder", "Q01Station"); model:SetAttribute("UsesDetailedBed", true)
		return model
	end)
	return { folder = installed, manifest = manifest }
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
["roblox/mvp/builders/SeattleBoundary.luau"] = [=[-- Edit-only Seattle enclosure. Decorative buildings are solid, shallow shells.
return function(context)
    assert(context and context.Root and context.MVP and context.SafeReplace,"Measured builder context required")
    assert(not game:GetService("RunService"):IsRunning(),"Build in Edit mode")
    local root=context.Root
    local palette=context.Palette or {
        forest=Color3.fromHex("365744"),sage=Color3.fromHex("A8B995"),cream=Color3.fromHex("F5F0E4"),wood=Color3.fromHex("95674B"),
        blossom=Color3.fromHex("E8B7C6"),brick=Color3.fromHex("B66C68"),golden=Color3.fromHex("E8C779"),ink=Color3.fromHex("26382E"),
    }
    local V,CF=Vector3.new,CFrame.new
    local existing=root.MVP.Environment:FindFirstChild("SeattleBoundary")
    local minX,maxX,minZ,maxZ
    -- Frozen world-space measurements make reruns independent of world translations.
    if existing and existing:GetAttribute("EnclosureMinX") then
        minX,maxX=existing:GetAttribute("EnclosureMinX"),existing:GetAttribute("EnclosureMaxX")
        minZ,maxZ=existing:GetAttribute("EnclosureMinZ"),existing:GetAttribute("EnclosureMaxZ")
    elseif existing and existing:FindFirstChild("WestUDistrictBackdrop") then
        minX=existing.WestUDistrictBackdrop:FindFirstChild("Shell1",true).Position.X
        maxX=existing.EastQuadBackdrop:FindFirstChild("Shell1",true).Position.X
        minZ=existing.NorthHouseJasperBackdrop:FindFirstChild("Shell1",true).Position.Z
        maxZ=existing.SouthArrivalPatioBackdrop:FindFirstChild("Shell1",true).Position.Z
    else
        local b=assert(context.Options and context.Options.WorldBounds,"Measured world bounds required")
        minX,maxX,minZ,maxZ=b.minX-12,b.maxX+12,b.minZ-12,b.maxZ+12
    end
    assert(minX<maxX and minZ<maxZ,"Invalid enclosure bounds")
    local field=root.Landscape.QuadGround
    local y=field.Position.Y+field.Size.Y/2
    local stage=Instance.new("Folder");stage.Name="SeattleBoundary"
    stage:SetAttribute("BuilderSource","roblox/mvp/builders/SeattleBoundary.luau")
    stage:SetAttribute("VerificationTicket","MAP-03")
    stage:SetAttribute("EnclosureMinX",minX);stage:SetAttribute("EnclosureMaxX",maxX)
    stage:SetAttribute("EnclosureMinZ",minZ);stage:SetAttribute("EnclosureMaxZ",maxZ)
    stage:SetAttribute("GroundedFieldY",y)
    stage:SetAttribute("CollisionPolicy","Solid closed shells; four overlapping 96-stud boundary colliders")
    stage:SetAttribute("SkylinePolicy","Open sky; roofed shallow perimeter buildings")
    stage:SetAttribute("TexturePolicy","Native Roblox materials; approved Color3 palette")
    local count=0
    local function group(name,parent)
        local m=Instance.new("Model");m.Name=name;m.Parent=parent;return m
    end
    local function part(name,size,cf,token,parent,material,collide,query)
        local p=Instance.new("Part");p.Name=name;p.Size=size;p.CFrame=cf;p.Color=assert(palette[token])
        p:SetAttribute("PaletteToken",token);p:SetAttribute("MVPBuilder","SeattleBoundary")
        p.Material=material or Enum.Material.SmoothPlastic;p.Anchored=true
        p.CanCollide=collide==true;p.CanTouch=false;p.CanQuery=query==true
        p.CastShadow=collide==true;p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth
        p.Parent=parent;count+=1;return p
    end
    local function window(name,base,x,h,z,parent)
        part(name.."Frame",V(4.1,4.9,.20),base*CF(x,h,z),"cream",parent,Enum.Material.Concrete)
        part(name.."Pane",V(3.5,4.25,.12),base*CF(x,h,z-.15),"ink",parent,Enum.Material.Glass)
        part(name.."Mullion",V(.13,4.25,.13),base*CF(x,h,z-.24),"cream",parent,Enum.Material.Metal)
        part(name.."Sill",V(4.5,.25,.65),base*CF(x,h-2.55,z-.15),"cream",parent,Enum.Material.Concrete)
    end
    local function building(name,base,width,index,parent)
        local m=group(name,parent)
        local variant=index%5;local height=26+variant*3;local depth=10
        local masonry=variant==1 or variant==4
        m:SetAttribute("DetailType","ClosedSeattleBuilding");m:SetAttribute("FacadeHeight",height)
        part("ClosedShell",V(width+.04,height,depth),base*CF(0,height/2,depth/2),masonry and "brick" or "cream",m,
            masonry and Enum.Material.Brick or Enum.Material.Concrete,true,true)
        part("Roof",V(width+.55,.65,depth+.7),base*CF(0,height+.30,depth/2),"ink",m,Enum.Material.Slate,true,true)
        part("Cornice",V(width+.55,.55,1.1),base*CF(0,height-.30,-.30),"cream",m,Enum.Material.Concrete)
        part("WaterTable",V(width,.65,.28),base*CF(0,.75,-.18),"wood",m,Enum.Material.Concrete)
        part("StoryBand",V(width,.30,.32),base*CF(0,10.4,-.20),"cream",m,Enum.Material.Concrete)
        local bay=variant==2 and -.55 or -.16
        for row=1,2 do for column=1,2 do
            window("Upper"..row.."_"..column,base,(column==1 and -1 or 1)*width*.27,14+(row-1)*8,bay,m)
        end end
        -- Decorative doors are closed; playable storefront entrances are preserved.
        part("DoorFrame",V(4.5,8.9,.22),base*CF(0,4.65,-.16),"wood",m,Enum.Material.Wood)
        part("ClosedDoor",V(3.8,8.2,.17),base*CF(0,4.35,-.32),variant%2==0 and "forest" or "wood",m,Enum.Material.Wood)
        part("DoorGlass",V(2.65,3.8,.10),base*CF(0,5.8,-.46),"ink",m,Enum.Material.Glass)
        part("DoorRail",V(3.5,.16,.12),base*CF(0,3.9,-.49),"wood",m,Enum.Material.Wood)
        part("DoorHandle",V(.12,1.0,.18),base*CF(1.3,3.7,-.54),"golden",m,Enum.Material.Metal)
        for column=1,2 do
            local x=(column==1 and -1 or 1)*width*.29
            part("ShopFrame"..column,V(width*.32,6.7,.16),base*CF(x,4.5,-.14),"wood",m,Enum.Material.Wood)
            part("ShopGlass"..column,V(width*.32-.45,6.12,.12),base*CF(x,4.5,-.26),"ink",m,Enum.Material.Glass)
        end
        local awningToken=variant%2==0 and "forest" or "wood"
        part("Awning",V(width*.80,.26,2.6),base*CF(0,9.1,-1.35)*CFrame.Angles(math.rad(9),0,0),awningToken,m,Enum.Material.Fabric)
        part("AwningValance",V(width*.80,.60,.15),base*CF(0,8.65,-2.62),awningToken,m,Enum.Material.Fabric)
        part("RainDownpipe",V(.22,height-.7,.24),base*CF(width/2-.6,height/2,-.30),"ink",m,Enum.Material.Metal)
        if variant==3 then
            part("RoofVent",V(3,1.6,3),base*CF(width*.15,height+1.2,6),"sage",m,Enum.Material.Metal)
        end
    end
    local depth=10
    local function row(name,base,length,variant)
        local m=group(name,stage);local pieces=math.ceil(length/30);local width=length/pieces
        for i=1,pieces do building(string.format("Building%02d",i),base*CF((i-(pieces+1)/2)*width,0,0),width,i+variant,m) end
    end
    row("NorthHouseJasperBackdrop",CF((minX+maxX)/2,y,minZ)*CFrame.Angles(0,math.pi,0),maxX-minX+depth*2,1)
    row("SouthArrivalPatioBackdrop",CF((minX+maxX)/2,y,maxZ),maxX-minX+depth*2,3)
    row("WestUDistrictBackdrop",CF(minX,y,(minZ+maxZ)/2)*CFrame.Angles(0,-math.pi/2,0),maxZ-minZ,2)
    row("EastQuadBackdrop",CF(maxX,y,(minZ+maxZ)/2)*CFrame.Angles(0,math.pi/2,0),maxZ-minZ,4)
    local floor=part("PerimeterGround",V(maxX-minX+1,.32,maxZ-minZ+1),CF((minX+maxX)/2,y-.20,(minZ+maxZ)/2),"sage",stage,Enum.Material.Grass,true,true)
    floor:SetAttribute("DetailType","GroundClosure")
    local barrier=group("ContinuousEnclosure",stage)
    local wallY=y-4+96/2
    local walls={
        {"North",V(maxX-minX+24,96,2),CF((minX+maxX)/2,wallY,minZ+1)},
        {"South",V(maxX-minX+24,96,2),CF((minX+maxX)/2,wallY,maxZ-1)},
        {"West",V(2,96,maxZ-minZ+4),CF(minX+1,wallY,(minZ+maxZ)/2)},
        {"East",V(2,96,maxZ-minZ+4),CF(maxX-1,wallY,(minZ+maxZ)/2)},
    }
    for _,spec in walls do
        local p=part(spec[1],spec[2],spec[3],"ink",barrier,Enum.Material.SmoothPlastic,true,false)
        p.Transparency=1;p.CastShadow=false;p:SetAttribute("DetailType","WorldBoundary")
    end
    assert(count<=2300,"Seattle enclosure exceeds 2300 parts: "..count)
    for _,p in stage:GetDescendants()do if p:IsA("BasePart")then
        assert(p.Color==palette[p:GetAttribute("PaletteToken")] and p.Anchored,"Invalid palette/static part")
    end end
    stage:SetAttribute("PartCount",count)
    stage:SetAttribute("BuildingCount",math.ceil((maxX-minX+20)/30)*2+math.ceil((maxZ-minZ)/30)*2)
    stage:SetAttribute("Status","Built; independent review and human playtest pending")
    local installed=context.SafeReplace("SeattleBoundary",function()return stage end)
    game:GetService("ChangeHistoryService"):SetWaypoint("Seattle enclosed and detailed buildings 04")
    return {folder=installed or stage,manifest={PartCount=count,Bounds={minX,maxX,minZ,maxZ},GroundY=y}}
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
	menuStatus = "Build a bowl at FOB, add sauce at Aladdins, then set the serving table",
	anchors = { "Q06FOBCounter", "Q06AladdinsCounter", "Q06Serving" },
	roles = {
		{ id = "base", label = "Choose a base", items = { "rice" } },
		{ id = "protein", label = "Choose a protein", items = { "tofu", "chicken", "mushroom" } },
		{ id = "toppings", label = "Choose a fresh topping", items = { "greens", "cucumber", "carrot" } },
		{ id = "sauce", label = "Choose a finish", items = { "sauce", "sesame" } },
		{ id = "settingA", label = "Left table setting", items = { "plate", "napkin" } },
		{ id = "settingB", label = "Right table setting", items = { "cup", "napkin" } },
	},
	input = { sequence = { "choose-card", "preview-selection", "add-or-place" }, cancel = "tap-cancel", desktopEquivalent = true, minTargetScreenUnits = 48 },
	feedback = { accepted = "Added to the shared meal", busy = "A friend is choosing for this spot", complete = "Done! Your shared meal is ready" },
}
]=],
["roblox/mvp/client/CozySoundEffectsClient.client.luau"] = [=[-- Permanent export of live SFX client. Replace the old LocalScript, do not add a second copy.
local Players = game:GetService("Players")
local SoundService = game:GetService("SoundService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContentProvider = game:GetService("ContentProvider")
local player = Players.LocalPlayer
if SoundService:FindFirstChild("CozySoundEffectsLocal") then return end
local specs = {
    SoftClick={id="88442833509532",volume=.18}, SuccessChime={id="103516326607012",volume=.22},
    JasperBark={id="135016436724006",volume=.25}, JasperPant={id="6463651038",volume=.10},
}
local root = ReplicatedStorage:FindFirstChild("PhuongMVP")
local shared = root and root:FindFirstChild("shared")
local configModule = shared and shared:FindFirstChild("AudioConfig")
if configModule and configModule:IsA("ModuleScript") then
    local ok, config = pcall(require,configModule)
    if ok and type(config)=="table" and type(config.Effects)=="table" then specs=config.Effects end
end
if type(player:GetAttribute("CozyEffectsEnabled")) ~= "boolean" then player:SetAttribute("CozyEffectsEnabled",true) end
local folder = Instance.new("Folder")
folder.Name, folder.Parent = "CozySoundEffectsLocal", SoundService
local group = Instance.new("SoundGroup")
group.Name, group.Parent = "EffectsVolume", folder
local destroyed, cooldown, lastChime, seenCount = false, -math.huge, -math.huge, 0
local connections, buttons, seen, loads, previousGroups, pendingSpatial = {}, {}, {}, {}, {}, {}
local trySpatial
local function enabled() return player:GetAttribute("CozyEffectsEnabled") ~= false end
local function setVolume() group.Volume = enabled() and 1 or 0 end
setVolume()
table.insert(connections, player:GetAttributeChangedSignal("CozyEffectsEnabled"):Connect(setVolume))
local function cancelThread(thread)
    if thread and coroutine.status(thread) ~= "dead" then pcall(task.cancel,thread) end
end
local function makeSound(name)
    local spec = specs[name]
    local templates = SoundService:FindFirstChild("CozySoundEffects")
    local original = templates and templates:FindFirstChild(name)
    local sound = original and original:IsA("Sound") and original:Clone() or Instance.new("Sound")
    sound.Name, sound.SoundId, sound.Volume = name, "rbxassetid://"..spec.id, spec.volume
    sound.Looped, sound.SoundGroup, sound.Parent = false, group, folder
    sound.PlayOnRemove = false
    local entry = {sound=sound,status="Loading"}
    loads[name] = entry
    folder:SetAttribute(name.."Status",entry.status)
    local function finish(status)
        if destroyed or entry.status ~= "Loading" then return end
        entry.status = status; folder:SetAttribute(name.."Status",status)
        if entry.loaded then entry.loaded:Disconnect(); entry.loaded=nil end
        if trySpatial then
            for pending in pairs(pendingSpatial) do if pending.Name==name then trySpatial(pending) end end
        end
    end
    entry.loaded = sound.Loaded:Connect(function() if sound.IsLoaded then finish("Loaded") end end)
    entry.worker = task.defer(function()
        local ok = pcall(function()
            ContentProvider:PreloadAsync({sound},function(_,status)
                if status ~= Enum.AssetFetchStatus.Success then finish("Unavailable") end
            end)
        end)
        if destroyed then return end
        if sound.IsLoaded then finish("Loaded") elseif not ok then finish("Unavailable") end
    end)
    entry.timeout = task.delay(8,function()
        if destroyed or entry.status ~= "Loading" then return end
        finish(sound.IsLoaded and "Loaded" or "Timed out")
        cancelThread(entry.worker)
    end)
    return entry
end
local click, chime = makeSound("SoftClick"), makeSound("SuccessChime")
makeSound("JasperBark"); makeSound("JasperPant")
local function play(entry)
    if destroyed or not enabled() or entry.status ~= "Loaded" then return end
    pcall(function() entry.sound.TimePosition=0; entry.sound:Play() end)
end
local function bindButton(button)
    if not button:IsA("GuiButton") or buttons[button] then return end
    local record = {}
    buttons[button] = record
    record.activated = button.Activated:Connect(function()
        if not button.Active or not button.Interactable or os.clock()-cooldown < .08 then return end
        cooldown = os.clock(); play(click)
    end)
    record.destroying = button.Destroying:Connect(function()
        record.activated:Disconnect(); record.destroying:Disconnect(); buttons[button]=nil
    end)
end
local boundGui, boundRoots, boundRemotes = {}, {}, {}
local function bindGui(gui)
    if not gui:IsA("PlayerGui") or boundGui[gui] then return end
    boundGui[gui]=true
    table.insert(connections,gui.DescendantAdded:Connect(bindButton))
    for _,child in ipairs(gui:GetDescendants()) do bindButton(child) end
end
local function bindRemote(remote)
    if remote.Name~="Action" or not remote:IsA("RemoteEvent") or boundRemotes[remote] then return end
    boundRemotes[remote]=true
    table.insert(connections,remote.OnClientEvent:Connect(function(payload)
        if type(payload)~="table" or payload.kind~="Result" or payload.ok~=true then return end
        if string.lower(tostring(payload.code))=="duplicate" or type(payload.result)=="table" and string.lower(tostring(payload.result.code))=="duplicate" then return end
        local receipt=payload.receipt
        local completion=type(receipt)=="table" and (type(receipt.completion)=="table" and receipt.completion or receipt) or nil
        local code=string.lower(tostring(payload.code))
        local complete=code=="completed" or code=="round_completed" or completion and completion.petalGranted==true
        local identity=completion and (completion.receiptId or completion.actionId) or payload.actionId
        if not complete or type(identity)~="string" then return end
        local key=tostring(payload.sessionId)..":"..identity
        if seen[key] or seenCount>=4096 then return end
        seen[key],seenCount=true,seenCount+1
        if os.clock()-lastChime<1 then return end
        lastChime=os.clock(); play(chime)
    end))
end
local function bindRoot(candidate)
    if candidate.Name~="PhuongMVP" or boundRoots[candidate] then return end
    boundRoots[candidate]=true
    table.insert(connections,candidate.ChildAdded:Connect(bindRemote))
    for _,child in ipairs(candidate:GetChildren()) do bindRemote(child) end
end
trySpatial=function(sound)
    if destroyed or not sound.Parent then pendingSpatial[sound]=nil; return end
    local entry=loads[sound.Name]
    if not entry or entry.status=="Loading" then return end
    pendingSpatial[sound]=nil
    if entry.status~="Loaded" or not enabled() then return end
    local emitted=sound:GetAttribute("CozyEmittedAt")
    local lifetime=sound:GetAttribute("CozyLifetime")
    if type(emitted)~="number" or type(lifetime)~="number" then return end
    local elapsed=math.max(0,workspace:GetServerTimeNow()-emitted)
    if elapsed>=lifetime or entry.sound.TimeLength>0 and elapsed>=entry.sound.TimeLength then return end
    pcall(function() sound.TimePosition=elapsed; sound:Play() end)
end
-- A local SoundGroup also silences replicated Jasper sounds for this listener.
local function bindSpatial(sound)
    if not sound:IsA("Sound") or sound:IsDescendantOf(folder) or previousGroups[sound] then return end
    local spec=specs[sound.Name]
    if not spec or sound.SoundId~="rbxassetid://"..spec.id then return end
    if sound:GetAttribute("CozySoundEffect")~=true and not (sound.Parent and sound.Parent.Name=="JasperAudioEmitter") then return end
    previousGroups[sound]={group=sound.SoundGroup}
    sound.SoundGroup=group
    local connection
    connection=sound.Destroying:Connect(function()
        previousGroups[sound]=nil
        pendingSpatial[sound]=nil
        connection:Disconnect()
    end)
    previousGroups[sound].connection=connection
    if sound:GetAttribute("CozyAutoPlay")==true then pendingSpatial[sound]=true; trySpatial(sound) end
end
table.insert(connections,workspace.DescendantAdded:Connect(bindSpatial))
for _,child in ipairs(workspace:GetDescendants()) do bindSpatial(child) end
table.insert(connections,player.ChildAdded:Connect(bindGui))
for _,child in ipairs(player:GetChildren()) do bindGui(child) end
table.insert(connections,ReplicatedStorage.ChildAdded:Connect(bindRoot))
for _,child in ipairs(ReplicatedStorage:GetChildren()) do bindRoot(child) end
local function destroy()
    if destroyed then return end
    destroyed=true
    for _,connection in ipairs(connections) do connection:Disconnect() end
    for _,record in pairs(buttons) do record.activated:Disconnect(); record.destroying:Disconnect() end
    for sound,record in pairs(previousGroups) do
        record.connection:Disconnect()
        if sound.Parent and sound:GetAttribute("CozyAutoPlay")==true then sound:Stop() end
        if sound.Parent and sound.SoundGroup==group then sound.SoundGroup=record.group end
    end
    for _,entry in pairs(loads) do
        if entry.loaded then entry.loaded:Disconnect() end
        cancelThread(entry.worker); cancelThread(entry.timeout)
    end
    folder:Destroy()
    table.clear(buttons); table.clear(previousGroups); table.clear(seen); table.clear(pendingSpatial)
end
table.insert(connections,script.Destroying:Connect(destroy))
table.insert(connections,folder.Destroying:Connect(destroy))
]=],
["roblox/mvp/client/extensions/FinalePresentation.luau"] = [=[-- One optional local camera. Music belongs exclusively to PCW-26.
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Module = {}

function Module.Init(getContext, registry)
    local initial = getContext()
    local player, UI = initial.player, initial.UI
    local latest, active, confirmation, destroyed
    local skipped, connections = {}, {}
    local offeredKey, invitationKey
    local P = UI.Palette
    local overlay = Instance.new("ScreenGui")
    overlay.Name, overlay.ResetOnSpawn, overlay.IgnoreGuiInset = "BirthdayMoment", false, false
    overlay.DisplayOrder, overlay.ZIndexBehavior = 18, Enum.ZIndexBehavior.Sibling
    overlay.ScreenInsets = Enum.ScreenInsets.CoreUISafeInsets
    overlay.Parent = player:WaitForChild("PlayerGui")
    local banner = Instance.new("Frame")
    banner.Name, banner.AnchorPoint, banner.Position = "BirthdayChoice", Vector2.new(.5,0), UDim2.new(.5,0,0,8)
    banner.BackgroundColor3, banner.BorderSizePixel, banner.Visible = P.cream, 0, false
    banner.Parent = overlay; UI.Corner(banner)
    local headline = UI.Label(banner, "HappyBirthday", "Happy Birthday, Phuong!", 21, P.forest)
    headline.Font, headline.AutomaticSize = Enum.Font.GothamBold, Enum.AutomaticSize.None
    headline.Position, headline.Size = UDim2.fromOffset(12,9), UDim2.new(1,-24,0,32)
    local subtitle = UI.Label(banner, "CameraHint", "An optional birthday view · keep exploring freely", 14)
    subtitle.AutomaticSize, subtitle.Position, subtitle.Size = Enum.AutomaticSize.None, UDim2.fromOffset(12,43), UDim2.new(1,-24,0,38)
    local watch, skip
    local function key(state)
        return tostring(getContext().sessionId) .. ":" .. tostring(state and state.generation or 0)
    end
    local function inWorld() return player:GetAttribute("BirthdayLocation") == "World" end
    local function human()
        local character = player.Character
        return character and character:FindFirstChildOfClass("Humanoid")
    end
    local function isLive(state)
        return state and state.phase == "CELEBRATING" and type(state.startedAt) == "number"
            and type(state.endsAt) == "number" and workspace:GetServerTimeNow() < state.endsAt
    end
    local function notify(kind, reason, state)
        local context = getContext()
        registry.Notify({ kind = kind, reason = reason, generation = state and state.generation,
            sessionId = context.sessionId, startedAt = state and state.startedAt, endsAt = state and state.endsAt }, context)
    end
    local function restore(reason, markSkipped)
        local state = active and active.state or latest
        if markSkipped and state then
            skipped[key(state)] = true
            -- Stable late-subscriber hook for MusicController. Client-only.
            initial.gui:SetAttribute("FinaleSkippedSessionId", getContext().sessionId)
            initial.gui:SetAttribute("FinaleSkippedGeneration", state.generation)
        end
        local saved = active
        active = nil
        if saved then
            if saved.render then saved.render:Disconnect() end
            if saved.death then saved.death:Disconnect() end
            local humanoid = human()
            local sameSubject = saved.subject and saved.subject.Parent and humanoid == saved.humanoid and humanoid.Health > 0
            if saved.camera.Parent then
                pcall(function()
                    saved.camera.CameraType = sameSubject and saved.cameraType or Enum.CameraType.Custom
                    saved.camera.CameraSubject = sameSubject and saved.subject or humanoid
                    saved.camera.FieldOfView = saved.fov
                    saved.camera.CFrame = saved.frame
                end)
            end
            local current = workspace.CurrentCamera
            if current and current ~= saved.camera and inWorld() then
                current.CameraType = Enum.CameraType.Custom
                current.CameraSubject = humanoid
            end
            if initial.gui.Parent then initial.gui.Enabled = saved.guiEnabled end
            notify("FinaleCameraReturned", reason, saved.state)
        end
        if markSkipped then notify("FinaleCameraSkipped", reason, state) end
        banner.Visible = false
    end
    local function showOffer()
        if destroyed then return end
        local allowed = inWorld() and isLive(latest) and not skipped[key(latest)]
        banner.Visible = allowed == true
        if not allowed then return end
        offeredKey = key(latest)
        watch.Visible = active == nil
        skip.Position = active and UDim2.fromOffset(12,84) or UDim2.new(.5,4,0,84)
        skip.Size = active and UDim2.new(1,-24,0,52) or UDim2.new(.5,-16,0,52)
        subtitle.Text = active and "Your camera only · Skip / Return at any time" or "An optional birthday view · keep exploring freely"
    end
    local function startCamera()
        if active or not inWorld() or not isLive(latest) then return end
        local center = latest.scene and latest.scene.center
        local camera, humanoid = workspace.CurrentCamera, human()
        if not center or not camera or not humanoid or humanoid.Health <= 0 then
            getContext().toast("The birthday view is unavailable. Enjoy the celebration with your usual camera.")
            return
        end
        local focus = Vector3.new(center.x, center.y+3, center.z)
        local body = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if not body or (body.Position-focus).Magnitude > 65 then
            getContext().toast("Walk closer to the birthday table to watch the optional view.")
            return
        end
        local context = getContext()
        context.close()
        local saved = { camera = camera, cameraType = camera.CameraType, subject = camera.CameraSubject,
            frame = camera.CFrame, fov = camera.FieldOfView, humanoid = humanoid, seat = humanoid.SeatPart,
            state = latest, focus = focus, guiEnabled = initial.gui.Enabled }
        active = saved
        initial.gui.Enabled = false
        camera.CameraType = Enum.CameraType.Scriptable
        camera.FieldOfView = 60
        saved.death = humanoid.Died:Connect(function() restore("death", true) end)
        saved.render = RunService.RenderStepped:Connect(function()
            if active ~= saved then return end
            if not inWorld() or player.Character ~= humanoid.Parent or humanoid.Health <= 0 or camera ~= workspace.CurrentCamera then
                restore("camera-or-character-changed", true); return
            end
            if humanoid.MoveDirection.Magnitude > .1 or (saved.seat and humanoid.SeatPart ~= saved.seat) then
                restore("returned-to-exploring", true); return
            end
            if not isLive(latest) or key(latest) ~= key(saved.state) then restore("complete", false); return end
            local progress = math.clamp((workspace:GetServerTimeNow()-saved.state.startedAt)/saved.state.duration,0,1)
            local angle = -.6 + progress*1.2
            local eye = focus + Vector3.new(math.sin(angle)*31,10+math.sin(progress*math.pi)*2,math.cos(angle)*28)
            camera.CFrame = CFrame.lookAt(eye,focus)
        end)
        showOffer()
        notify("FinaleCameraStarted", "opted-in", latest)
    end
    watch = UI.Button(banner, "WatchBirthday", "Watch birthday view", startCamera)
    watch.Position, watch.Size = UDim2.fromOffset(12,84), UDim2.new(.5,-16,0,52)
    skip = UI.Button(banner, "SkipBirthday", "Skip / Return", function() restore("skip", true) end, true)
    local function layout()
        banner.Size = UDim2.fromOffset(math.min(432,math.max(256,overlay.AbsoluteSize.X-24)),148)
        banner.Position = UDim2.new(.5,0,0,8+(initial.gui:GetAttribute("AudioControlsInset") or 0))
    end
    table.insert(connections, overlay:GetPropertyChangedSignal("AbsoluteSize"):Connect(layout))
    table.insert(connections, initial.gui:GetAttributeChangedSignal("AudioControlsInset"):Connect(layout))
    table.insert(connections, UserInputService.InputBegan:Connect(function(input, processed)
        if not processed and input.KeyCode == Enum.KeyCode.Escape and (active or banner.Visible) then restore("skip", true) end
    end))
    table.insert(connections, workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
        if active then restore("camera-replaced", true) end
    end))
    table.insert(connections, player.CharacterAdded:Connect(function(character)
        confirmation = nil
        task.spawn(function()
            local humanoid = character:WaitForChild("Humanoid",10)
            if destroyed or player.Character ~= character then return end
            -- Default camera scripts choose the new live character; repair only
            -- an orphaned subject from our own prior optional view.
            local camera = workspace.CurrentCamera
            if humanoid and camera and inWorld() and (not camera.CameraSubject or not camera.CameraSubject.Parent) then
                camera.CameraType, camera.CameraSubject = Enum.CameraType.Custom, humanoid
            end
        end)
    end))
    local elapsed = 0
    table.insert(connections, RunService.Heartbeat:Connect(function(dt)
        elapsed += dt; if elapsed < .2 then return end; elapsed = 0
        if active and not isLive(latest) then restore("complete",false) end
        if banner.Visible and not isLive(latest) then banner.Visible = false end
    end))

    registry.RegisterActivity("Cake", function(container, state, context)
        local card = UI.Card(container, "CakeChoices", "blossom"); card.LayoutOrder = 3
        UI.Label(card, "SeatHelp", "Ten real seats · Phuong's marked seat is at the west end. Guests can use the other nine.",16).LayoutOrder = 1
        if state.hasEaten then UI.Label(card,"SavedCake","✓ Your cake moment is saved. Another bite is cosmetic.",16,P.forest).LayoutOrder=2
        elseif state.sliceTaken then UI.Label(card,"SavedSlice","✓ Your slice is ready to enjoy.",16,P.forest).LayoutOrder=2 end
        local fresh
        for _, descriptor in ipairs(state.availableActions or {}) do
            if confirmation and descriptor.id == confirmation.id and descriptor.generation == confirmation.generation and descriptor.enabled ~= false then fresh=descriptor end
        end
        if not fresh then confirmation=nil end
        local function sendChoice(descriptor)
            local current=getContext()
            if current.pending then return end
            confirmation=nil
            if current.send({kind="Cake",action=descriptor.action,generation=descriptor.generation}) then current.refresh() end
        end
        if fresh then
            UI.Label(card,"ConfirmTitle",fresh.confirm.title,18,P.forest).LayoutOrder=3
            UI.Label(card,"ConfirmDetail",fresh.confirm.detail,16).LayoutOrder=4
            local confirm=UI.Button(card,"ConfirmCake",fresh.confirm.label,function() sendChoice(fresh) end)
            confirm.LayoutOrder=5; UI.SetEnabled(confirm,not context.pending)
            UI.Button(card,"CancelCake","Keep gathering",function() confirmation=nil; getContext().refresh() end,true).LayoutOrder=6
        else
            for index,descriptor in ipairs(state.availableActions or {}) do
                local button=UI.Button(card,"CakeAction"..index,context.pending and "Saving..." or descriptor.label,function()
                    if descriptor.confirm then confirmation={id=descriptor.id,generation=descriptor.generation}; getContext().refresh()
                    else sendChoice(descriptor) end
                end)
                button.LayoutOrder=index*2+2; UI.SetEnabled(button,not context.pending and descriptor.enabled~=false)
                if descriptor.enabled==false then UI.Label(card,"Unavailable"..index,descriptor.reason,14).LayoutOrder=index*2+3 end
            end
        end
        UI.Label(card,"FreePlay","Close to explore or sit with your friends. Leaving the view does not undo the celebration or your slice.",14).LayoutOrder=80
    end)

    registry.RegisterObserver("FinalePresentation", function(payload, context)
        if destroyed then return end
        if payload.kind == "FinaleCameraSkipped" or payload.kind == "FinaleCameraReturned" or payload.kind == "FinaleCameraStarted" then return end
        if payload.kind == "HostTravel" or payload.kind == "CharacterRemoving" or payload.kind == "LocationChanged" and not payload.inWorld then
            confirmation=nil; restore(payload.kind,true); return
        end
        if payload.kind == "PanelClosed" then confirmation=nil end
        local state=payload.cake or payload.snapshot and payload.snapshot.cake or context.snapshot.cake
        if state then latest=state end
        if inWorld() and latest and latest.invitation then
            local invitation=tostring(context.sessionId)..":"..tostring(latest.unlockedAt)
            if invitationKey~=invitation then
                invitationKey=invitation
                context.track("Cake","FinalePatio")
                context.toast(latest.cutAt and "Birthday cake is ready! Come to the patio for your slice and photos."
                    or latest.phase=="CELEBRATING" and "Happy Birthday, Phuong! Join the celebration at the patio."
                    or latest.phase=="CAKE_READY" and "The birthday table is ready for Phuong's first cut."
                    or "All six petals! Gather at the birthday table. Guests sit first, then Phuong's marked seat.")
            end
        end
        if active and not isLive(latest) then restore("complete",false) end
        if isLive(latest) and (offeredKey~=key(latest) or payload.kind=="LocationChanged") then showOffer() end
        if payload.kind=="Result" and payload.result and payload.result.message and payload.result.receipt and payload.result.receipt.activityId=="Cake" then
            confirmation=nil; context.toast(payload.result.message,payload.ok==false)
        end
    end)
    local function destroy()
        if destroyed then return end
        restore("destroyed",true); destroyed=true
        for _,connection in ipairs(connections) do connection:Disconnect() end
        registry.activities.Cake=nil; registry.observers.FinalePresentation=nil
        overlay:Destroy()
    end
    table.insert(connections, initial.gui.Destroying:Connect(destroy))
    table.insert(connections, script.Destroying:Connect(destroy))
    table.insert(connections, overlay.Destroying:Connect(function() if not destroyed then destroy() end end))
    layout()
end

return Module
]=],
["roblox/mvp/client/extensions/HostControls.luau"] = [=[-- Presentation only. Every recovery is prepared and confirmed on the server.
local Module = {}
local QUESTS = { {"Q01","Bed"},{"Q02","Jasper"},{"Q03","Craft"},{"Q04","Reading"},{"Q05","Labubu wish"},{"Q06","Food"} }
function Module.Init(getContext, registry)
    local selectedQuest, expanded, dismissedToken = "Q01", "quest", nil
    local lastSession, lastResult
    local showAllAudit = false
    local function request(value)
        local context=getContext()
        if context.pending then context.toast("Wait for your last choice to finish."); return end
        value.kind="Host"
        if context.send(value) then context.refresh() end
    end
    local function isHost(context)
        return context.snapshot.host and context.snapshot.host.authorized==true and context.player:GetAttribute("BirthdayLocation")=="World"
    end
    registry.RegisterPanel("HostControls",{
        label="Host controls",title="Host controls",visible=isHost,
        render=function(container,context)
            local host=context.snapshot.host
            if not isHost(context) then context.UI.Label(container,"HostUnavailable","Host controls are available to Phuong and Andrew in the world.",16); return end
            if lastSession~=context.sessionId then lastSession=context.sessionId; dismissedToken=nil end
            local UI=context.UI
            local banner=UI.Card(container,"HostState",#host.activeOverrides>0 and "golden" or "sage"); banner.LayoutOrder=1
            UI.Label(banner,"Mode",#host.activeOverrides>0 and "HOST OVERRIDE · "..table.concat(host.activeOverrides,", ") or "Normal choices",18).LayoutOrder=1
            UI.Label(banner,"Authority",host.hint,14).LayoutOrder=2
            local petals=0; for _,done in pairs(host.petals) do if done then petals+=1 end end
            UI.Label(banner,"CurrentSharedState","Shared fund "..host.fundBalance.." · "..petals.."/6 petals",16).LayoutOrder=3
            local toggle=UI.Button(banner,"ToggleHostOverride",host.override and "End my Override" or "Enable my Override",function()
                dismissedToken=nil; request({action="SetOverride",enabled=not getContext().snapshot.host.override})
            end,host.override)
            toggle.LayoutOrder=4; UI.SetEnabled(toggle,not context.pending,host.override)
            if not host.override then
                UI.Label(container,"OverrideHelp","Enable Override to preview a recovery. Every change shows its current state and exact effect before Confirm. Either host may recover while Phuong is present.",16).LayoutOrder=2
            end
            local quote=host.confirmation
            if quote and quote.token~=dismissedToken and host.override then
                local card=UI.Card(container,"HostConfirmation","cream"); card.LayoutOrder=2
                UI.Label(card,"ConfirmTitle",quote.label.."?",18,UI.Palette.forest).LayoutOrder=1
                UI.Label(card,"Before",quote.current,15).LayoutOrder=2
                UI.Label(card,"ExactEffect",quote.effect,16).LayoutOrder=3
                UI.Label(card,"Freshness","If anything relevant changes or 30 seconds pass, review a fresh preview. Cancel leaves everything as it is.",13).LayoutOrder=4
                local confirm=UI.Button(card,"ConfirmHostRecovery",context.pending and "Saving…" or "Confirm recovery",function()
                    request({action="Confirm",token=quote.token})
                end)
                confirm.LayoutOrder=5; UI.SetEnabled(confirm,not context.pending and workspace:GetServerTimeNow()<quote.expiresAt)
                local cancel=UI.Button(card,"CancelHostRecovery","Cancel",function()
                    if getContext().pending then return end
                    dismissedToken=quote.token; request({action="Cancel",token=quote.token})
                end,true)
                cancel.LayoutOrder=6; UI.SetEnabled(cancel,not context.pending,true)
                UI.Button(card,"FreshPreview","Review current state again",function()
                    dismissedToken=quote.token; request({action="Cancel",token=quote.token})
                end,true).LayoutOrder=7
            elseif host.override then
                local function operation(parent,descriptor,order)
                    local button=UI.Button(parent,"Host"..descriptor.operation,descriptor.label,function()
                        dismissedToken=nil
                        request({action="Prepare",operation=descriptor.operation,activityId=descriptor.activityId})
                    end,true)
                    button.LayoutOrder=order; UI.SetEnabled(button,descriptor.enabled and not context.pending,true)
                    if not descriptor.enabled then UI.Label(parent,"Reason"..descriptor.operation,descriptor.reason,14).LayoutOrder=order+1 end
                end
                local quests=UI.Card(container,"HostQuestRecovery","cream"); quests.LayoutOrder=3
                UI.Button(quests,"ShowQuestRecovery",(expanded=="quest" and "▾ " or "▸ ").."Quest recovery",function() expanded=expanded=="quest" and nil or "quest"; getContext().refresh() end,true).LayoutOrder=1
                if expanded=="quest" then
                    UI.Label(quests,"ChooseQuest","Choose one activity. Held work and completed progress are listed in the confirmation.",14).LayoutOrder=2
                    for index,entry in ipairs(QUESTS) do
                        local button=UI.Button(quests,"Choose"..entry[1],(selectedQuest==entry[1] and "✓ " or "")..entry[2]..(host.petals[entry[1]] and " · petal saved" or " · incomplete"),function() selectedQuest=entry[1]; getContext().refresh() end,selectedQuest~=entry[1])
                        button.LayoutOrder=index+20; UI.SetEnabled(button,not context.pending,selectedQuest~=entry[1])
                    end
                    UI.Label(quests,"SelectedQuest","Selected activity · "..selectedQuest,16,UI.Palette.forest).LayoutOrder=3
                    local order=4
                    for _,descriptor in ipairs(host.actions) do if descriptor.activityId==selectedQuest then operation(quests,descriptor,order); order+=2 end end
                end
                local other=UI.Card(container,"HostOtherRecovery","cream"); other.LayoutOrder=4
                UI.Button(other,"ShowOtherRecovery",(expanded=="other" and "▾ " or "▸ ").."Fund, wish, cake and return",function() expanded=expanded=="other" and nil or "other"; getContext().refresh() end,true).LayoutOrder=1
                UI.Label(other,"TopUpBounds","Emergency fund: +20, up to 5 times this session, 30 seconds apart. Used "..host.topUpsUsed.."/5. Wish fulfillment: once, for the normally selected wish.",14).LayoutOrder=2
                if expanded=="other" then
                    local order=3
                    for _,descriptor in ipairs(host.actions) do if not descriptor.activityId then operation(other,descriptor,order); order+=2 end end
                end
            end
            local audit=UI.Card(container,"HostAudit","sage"); audit.LayoutOrder=8
            UI.Label(audit,"AuditTitle","Recent host recoveries · visible only to hosts",16).LayoutOrder=1
            if #host.audit==0 then UI.Label(audit,"NoRecovery","No recovery changes in this session.",14).LayoutOrder=2 end
            for index,entry in ipairs(host.audit) do
                if index>6 and not showAllAudit then break end
                UI.Label(audit,"HostAudit"..index,entry.actor.." · "..entry.action..(entry.activityId and " · "..entry.activityId or "").." · "..os.date("%H:%M:%S",math.floor(entry.timestamp)).."\n"..entry.prior.." → "..entry.new,13).LayoutOrder=index+1
            end
            if #host.audit>6 then UI.Button(audit,"ShowHostAudit",showAllAudit and "Show latest six" or "Show all recent audit entries",function() showAllAudit=not showAllAudit; getContext().refresh() end,true).LayoutOrder=40 end
            UI.Label(audit,"AuditLimit","The server keeps the latest 32 audit entries and at most 512 host requests this session ("..host.requestCount.." used). Close or Back leaves ordinary play available.",12).LayoutOrder=41
        end,
    })
    registry.RegisterObserver("HostControls",function(payload,context)
        if payload.kind=="PanelClosed" or payload.kind=="CharacterRemoving" or payload.kind=="LocationChanged" and not payload.inWorld then
            local quote=context.snapshot.host and context.snapshot.host.confirmation
            dismissedToken=quote and quote.token or dismissedToken
            return
        end
        if payload.hostResult then
            local result=payload.hostResult
            if payload.actionId~=lastResult then
                lastResult=payload.actionId
                context.toast(result.message,payload.ok==false)
                if result.ok and result.destination then
                    registry.Notify({kind="HostTravel",destination=result.destination},getContext())
                    context.close()
                end
            end
        end
        if context.activePanel=="HostControls" and (payload.snapshot or payload.hostResult) then getContext().refresh() end
    end)
end
return Module
]=],
["roblox/mvp/client/extensions/MusicController.luau"] = [=[-- PCW-26: one local controller, independent of activity panels and actions.
local SoundService = game:GetService("SoundService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContentProvider = game:GetService("ContentProvider")
local RunService = game:GetService("RunService")
local Module = {}
local instance

function Module.Init(getContext, registry)
    if instance then return instance end
    local initial = getContext()
    local player, UI = initial.player, initial.UI
    local playerGui = player:FindFirstChildOfClass("PlayerGui")
    if not playerGui or SoundService:FindFirstChild("CozyMusicLocal") then return end
    local config = {
        Music={Birthday={id="87992648461099",title="Birthday song",volume=.22},World={id="139568344220252",title="Slow Mornings · gentle acoustic guitar",volume=.18}},
        DefaultMusicVolume=.5,VolumeStep=.25,CrossfadeSeconds=.65,LoadTimeoutSeconds=8,
    }
    local configuration = "Exact-ID fallback"
    local root=ReplicatedStorage:FindFirstChild("PhuongMVP")
    local shared=root and root:FindFirstChild("shared")
    local source=shared and shared:FindFirstChild("AudioConfig")
    if source and source:IsA("ModuleScript") then
        local ok,value=pcall(require,source)
        if ok and type(value)=="table" and type(value.Music)=="table" then config=value; configuration="AudioConfig" end
    end
    if type(player:GetAttribute("CozyMusicMuted"))~="boolean" then player:SetAttribute("CozyMusicMuted",false) end
    if type(player:GetAttribute("CozyMusicVolume"))~="number" then player:SetAttribute("CozyMusicVolume",config.DefaultMusicVolume) end
    if type(player:GetAttribute("CozyEffectsEnabled"))~="boolean" then player:SetAttribute("CozyEffectsEnabled",true) end
    local folder=Instance.new("Folder")
    folder.Name,folder.Parent="CozyMusicLocal",SoundService
    folder:SetAttribute("Configuration",configuration)
    local overlay=Instance.new("ScreenGui")
    overlay.Name,overlay.ResetOnSpawn,overlay.IgnoreGuiInset="CozyAudioControls",false,false
    overlay.DisplayOrder,overlay.ZIndexBehavior=24,Enum.ZIndexBehavior.Sibling
    overlay.ScreenInsets=Enum.ScreenInsets.CoreUISafeInsets
    overlay.Parent=playerGui
    local bar=Instance.new("Frame")
    bar.Name,bar.AnchorPoint,bar.Position="AudioBar",Vector2.new(.5,0),UDim2.new(.5,0,0,8)
    bar.BackgroundColor3,bar.BorderSizePixel=UI.Palette.cream,0
    bar.Parent=overlay; UI.Corner(bar)
    -- Main and the optional camera reserve this band, including on phones.
    initial.gui:SetAttribute("AudioControlsInset",64)
    local destroyed,latest,currentSession,mode,modeKey=false,initial.snapshot.cake,nil,"Quiet",nil
    local tracks,connections,runs={}, {}, {}
    local mute,lower,raise,sfx,launcher
    local expanded=false
    local refresh,chooseMode
    local function volume() return math.clamp(player:GetAttribute("CozyMusicVolume") or config.DefaultMusicVolume,0,1) end
    local function muted() return player:GetAttribute("CozyMusicMuted")==true end
    local function cancelThread(thread)
        if thread and coroutine.status(thread)~="dead" then pcall(task.cancel,thread) end
    end
    local function status(track,value)
        track.status=value
        track.sound:SetAttribute("LoadStatus",value)
        folder:SetAttribute(track.name.."Status",value)
    end
    local function setTarget(track,target)
        if track.target==target then return end
        track.from,track.target,track.fadeAt=track.sound.Volume,target,os.clock()
    end
    local function pause(track)
        if track.sound.IsPlaying then pcall(function() track.sound:Pause() end) end
    end
    local function createTrack(name,spec)
        local sound=Instance.new("Sound")
        sound.Name,sound.SoundId,sound.Volume=name,"rbxassetid://"..spec.id,0
        sound.Looped=name=="World"
        sound.Parent=folder
        local track={name=name,spec=spec,sound=sound,status="Loading",target=0,from=0,fadeAt=os.clock(),wanted=false}
        tracks[name]=track; status(track,"Loading")
        local function finish(value)
            if destroyed or track.status~="Loading" then return end
            status(track,value)
            if track.loaded then track.loaded:Disconnect(); track.loaded=nil end
            if refresh then refresh() end
        end
        track.loaded=sound.Loaded:Connect(function() if sound.IsLoaded then finish("Loaded") end end)
        track.worker=task.defer(function()
            local ok=pcall(function()
                ContentProvider:PreloadAsync({sound},function(_,fetchStatus)
                    if fetchStatus~=Enum.AssetFetchStatus.Success then finish("Unavailable") end
                end)
            end)
            if destroyed then return end
            if sound.IsLoaded then finish("Loaded") elseif not ok then finish("Unavailable") end
        end)
        track.timeout=task.delay(config.LoadTimeoutSeconds,function()
            if destroyed or track.status~="Loading" then return end
            finish(sound.IsLoaded and "Loaded" or "Timed out")
            cancelThread(track.worker)
        end)
        table.insert(connections,sound.Ended:Connect(function()
            if destroyed or name~="Birthday" or mode~="Finale" then return end
            local run=runs[modeKey]
            if run then run.finished=true end
            if refresh then refresh() end
        end))
    end
    createTrack("Birthday",config.Music.Birthday)
    createTrack("World",config.Music.World)
    local function finaleKey(state,session)
        return tostring(session)..":"..tostring(state.generation)
    end
    local function skipMatches(state,session)
        return initial.gui:GetAttribute("FinaleSkippedSessionId")==session
            and initial.gui:GetAttribute("FinaleSkippedGeneration")==state.generation
    end
    chooseMode=function()
        local context=getContext()
        local session=context.sessionId
        if session~=currentSession then
            currentSession=session; table.clear(runs)
        end
        local location=player:GetAttribute("BirthdayLocation")
        if location=="Lobby" then return "Lobby","Lobby" end
        if location~="World" then return "Quiet","Quiet" end
        local state=latest
        if type(session)=="string" and type(state)=="table" and (state.phase or state.finaleState)=="CELEBRATING"
            and type(state.generation)=="number" and state.generation>0
            and type(state.startedAt)=="number" and type(state.endsAt)=="number"
            and workspace:GetServerTimeNow()>=state.startedAt and workspace:GetServerTimeNow()<state.endsAt then
            local key=finaleKey(state,session)
            local run=runs[key]
            if not run then run={started=false}; runs[key]=run end
            if skipMatches(state,session) then run.skipped=true end
            if not run.skipped and not run.finished then return "Finale",key end
        end
        return "World","World"
    end
    local function start(track)
        if track.status~="Loaded" or not track.wanted then return end
        if track.sound.IsPlaying then return end
        local ok=pcall(function()
            if track.name=="Birthday" and mode=="Finale" then
                local run=runs[modeKey]
                if not run or run.started or run.skipped or run.finished then return end
                -- Seek only after loading, including when that finishes late.
                local elapsed=math.max(0,workspace:GetServerTimeNow()-latest.startedAt)
                if workspace:GetServerTimeNow()>=latest.endsAt or track.sound.TimeLength>0 and elapsed>=track.sound.TimeLength then
                    run.finished=true; return
                end
                track.sound.Looped=false
                track.sound.TimePosition=elapsed
                run.started=true
                folder:SetAttribute("FinaleStartedKey",modeKey)
                track.sound:Play()
            else
                track.sound.Looped=true
                -- Resume paused ambient tracks instead of restarting on snapshots.
                if track.ambientStarted then track.sound:Resume()
                else track.ambientStarted=true; track.sound:Play() end
            end
        end)
        if not ok then status(track,"Playback unavailable") end
    end
    local function drawControls()
        local level=math.floor(volume()*100+.5)
        local selected=mode=="World" and tracks.World or (mode=="Lobby" or mode=="Finale") and tracks.Birthday or nil
        local state=selected and selected.status
        if muted() or level==0 then mute.Text="Music off\nUnmute"
        elseif state and state~="Loaded" then mute.Text=state=="Loading" and "Music loading\nMute" or "Music unavailable\nMute"
        else mute.Text="Music "..level.."%\nMute" end
        sfx.Text=player:GetAttribute("CozyEffectsEnabled")==false and "SFX off" or "SFX on"
        if launcher then
            local label=(muted() or level==0) and "Music off" or state and state~="Loaded" and (state=="Loading" and "Loading" or "Unavailable") or "Music on"
            launcher.Text=expanded and "Close audio" or "Audio\n"..label
        end
        UI.SetEnabled(lower,level>0,true); UI.SetEnabled(raise,level<100,true)
        folder:SetAttribute("MusicMuted",muted()); folder:SetAttribute("MusicVolume",volume())
        folder:SetAttribute("EffectsEnabled",player:GetAttribute("CozyEffectsEnabled")~=false)
    end
    refresh=function()
        if destroyed then return end
        local nextMode,nextKey=chooseMode()
        if nextMode~=mode or nextKey~=modeKey then
            local previous=mode
            mode,modeKey=nextMode,nextKey
            folder:SetAttribute("Mode",mode); folder:SetAttribute("TimelineKey",modeKey)
            -- Only one Birthday sound is used for lobby and finale, never two players.
            if mode=="Finale" or previous=="Finale" and mode=="Lobby" then
                tracks.Birthday.sound:Stop(); tracks.Birthday.sound.Volume=0
                tracks.Birthday.target,tracks.Birthday.from=0,0
                tracks.Birthday.ambientStarted=false
            end
        end
        tracks.World.wanted=mode=="World"
        tracks.Birthday.wanted=mode=="Lobby" or mode=="Finale"
        for _,track in pairs(tracks) do
            start(track)
            local target=track.wanted and track.status=="Loaded" and not muted() and volume()*track.spec.volume or 0
            setTarget(track,target)
        end
        drawControls()
    end
    mute=UI.Button(bar,"MusicMute","Music",function()
        local turnOn=muted() or volume()==0
        player:SetAttribute("CozyMusicMuted",not turnOn)
        if turnOn and volume()==0 then player:SetAttribute("CozyMusicVolume",config.DefaultMusicVolume) end
    end)
    lower=UI.Button(bar,"VolumeDown","Vol −",function() player:SetAttribute("CozyMusicVolume",math.max(0,volume()-config.VolumeStep)) end,true)
    raise=UI.Button(bar,"VolumeUp","Vol +",function()
        player:SetAttribute("CozyMusicVolume",math.min(1,volume()+config.VolumeStep)); player:SetAttribute("CozyMusicMuted",false)
    end,true)
    sfx=UI.Button(bar,"EffectsToggle","SFX on",function() player:SetAttribute("CozyEffectsEnabled",player:GetAttribute("CozyEffectsEnabled")==false) end,true)
    for _,button in ipairs({mute,lower,raise,sfx}) do button.TextSize=14 end
    local layout
    launcher=UI.Button(overlay,"AudioOptions","Audio",function() expanded=not expanded; layout(); drawControls() end,true)
    launcher.Position,launcher.Size=UDim2.fromOffset(8,8),UDim2.fromOffset(84,48)
    launcher.TextSize=14
    local activityPanel=initial.gui:FindFirstChild("ActivityPanel")
    layout=function()
        local size=overlay.AbsoluteSize
        -- Landscape uses the clear left gutter beside the centered panel. The
        -- collapsed control keeps activity content height; expand only on demand.
        local compact=size.X>=650 or size.X>size.Y and activityPanel and activityPanel.Visible
        launcher.Visible=compact==true
        bar.Visible=not compact or expanded
        local inset=bar.Visible and 64 or 0
        if initial.gui:GetAttribute("AudioControlsInset")~=inset then initial.gui:SetAttribute("AudioControlsInset",inset) end
        local width=math.min(390,math.max(274,overlay.AbsoluteSize.X-24))
        bar.Size=UDim2.fromOffset(width,56)
        local musicWidth=width-186
        mute.Position,mute.Size=UDim2.fromOffset(4,4),UDim2.fromOffset(musicWidth,48)
        lower.Position,lower.Size=UDim2.fromOffset(musicWidth+10,4),UDim2.fromOffset(48,48)
        raise.Position,raise.Size=UDim2.fromOffset(musicWidth+64,4),UDim2.fromOffset(48,48)
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
		UI.Label(card,"SaveHelp","Each choice stays saved when you close. Save reading completes the shared activity when all three are chosen. Your reading note is private to you for this session.",13).LayoutOrder=3
		local key=tostring(context.sessionId)..":"..tostring(view.roundId)..":"..tostring(draft.passageId)
		if not noteBuffer or noteBuffer.key~=key then noteBuffer={key=key,text=draft.note or "",dirty=false,open=false} end
		if not noteBuffer.dirty or noteBuffer.text==draft.note then noteBuffer.text=draft.note or ""; noteBuffer.dirty=false end
		local buffer=noteBuffer
		local note=UI.Card(container,"OptionalReadingNote","sage"); note.LayoutOrder=2
		local content=Instance.new("Frame"); content.Name="NoteEditor"; content.BackgroundTransparency=1
		content.Size=UDim2.new(1,0,0,0); content.AutomaticSize=Enum.AutomaticSize.Y; content.Visible=buffer.open; content.LayoutOrder=2; content.Parent=note; UI.List(content,8)
		local toggle=UI.Button(note,"ToggleNote","Optional · my private reading note",function() buffer.open=not buffer.open; content.Visible=buffer.open end,true); toggle.LayoutOrder=1
		local box=Instance.new("TextBox"); box.Name="ReadingNote"; box.Size=UDim2.new(1,0,0,105); box.LayoutOrder=1
		box.Text=buffer.text; box.PlaceholderText="An optional thought about this reading"; box.ClearTextOnFocus=false; box.MultiLine=true
		box.TextWrapped=true; box.TextXAlignment=Enum.TextXAlignment.Left; box.TextYAlignment=Enum.TextYAlignment.Top
		box.Font=Enum.Font.GothamMedium; box.TextSize=17; box.TextColor3=UI.Palette.ink; box.PlaceholderColor3=UI.Palette.forest
		box.BackgroundColor3=UI.Palette.cream; box.BorderSizePixel=0; box.Parent=content; UI.Padding(box,8); UI.Corner(box,8)
		local save
		local function validNote() return #box.Text<=500 end
		local function update()
			buffer.text=box.Text; buffer.dirty=box.Text~=(draft.note or "")
			if save then UI.SetEnabled(save,buffer.dirty and validNote() and not getContext().pending) end
		end
		save=UI.Button(content,"SaveNote","Save my reading note",function()
			if not validNote() then getContext().toast("Please shorten this reading note a little.",true); return end
			local descriptor=view.noteAction; if not descriptor then return end
			local payload={}; for k,v in pairs(descriptor.payload) do payload[k]=v end; payload.note=box.Text
			getContext().runAction({id=descriptor.id,label=descriptor.label,stepId=descriptor.stepId,payload=payload,enabled=true,confirm=false},false)
		end); save.LayoutOrder=2
		local hint=UI.Label(content,"PrivateNoteHelp","Save note keeps your words. Unsaved text is cleared on Close. This never appears in a shared world label.",13); hint.LayoutOrder=3
		box:GetPropertyChangedSignal("Text"):Connect(function() update(); hint.Text=validNote() and "Save note keeps your words. Unsaved text is cleared on Close. This never appears in a shared world label." or "Please shorten this reading note a little before saving." end)
		update()
	end)
	registry.RegisterObserver("WorldActivities",function(payload,context)
		if payload.kind=="LocationChanged" or payload.kind=="CharacterRemoving" then clearCue(); noteBuffer=nil; return end
		if not panel or not panel.Visible or context.player:GetAttribute("BirthdayLocation")~="World" then return end
		if payload.activityId=="Q04" and payload.ok and payload.result and payload.result.draft and panel:FindFirstChild("ReadingSavedChoices",true) then
			local draft=payload.result.draft
			if noteBuffer and noteBuffer.text==draft.note then noteBuffer.dirty=false end
			getContext().toast(payload.stepId=="note" and "Your private reading note is saved." or "Your reading choice is saved.")
		end
	end)
end
return Module
]=],
["roblox/mvp/client/Extensions.luau"] = [=[-- Optional extension surface, shared by Main and activity/finale/host modules.
-- Registration functions only change client presentation. All mutations still
-- travel through context.send() and are validated by the existing server.
local Extensions = { activities = {}, panels = {}, observers = {} }

function Extensions.RegisterActivity(activityId, renderer)
	assert(type(activityId) == "string" and type(renderer) == "function", "activity renderer required")
	Extensions.activities[activityId] = renderer
end

function Extensions.RegisterPanel(id, descriptor)
	assert(type(id) == "string" and type(descriptor) == "table" and type(descriptor.render) == "function", "panel renderer required")
	Extensions.panels[id] = descriptor
end

function Extensions.RegisterObserver(id, callback)
	assert(type(id) == "string" and type(callback) == "function", "observer required")
	Extensions.observers[id] = callback
end

function Extensions.Notify(payload, context)
	local ids = {}
	for id in pairs(Extensions.observers) do table.insert(ids, id) end
	table.sort(ids)
	for _, id in ipairs(ids) do
		local callback = Extensions.observers[id]
		local ok, err = pcall(callback, payload, context)
		if not ok then warn("Birthday client observer failed", id, err) end
	end
end

return Extensions
]=],
["roblox/mvp/client/Main.client.luau"] = [=[-- PCW-18: presentation only. The server owns every quest, purchase and permission.
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
local hostButton = UI.Button(hud, "HostControlsButton", "Host controls", function() end, true)
hostButton.Visible = false
local hostBanner = UI.Label(hud, "HostOverrideBanner", "", 14, P.ink)
hostBanner.BackgroundTransparency, hostBanner.BackgroundColor3 = 0, P.golden
hostBanner.Position, hostBanner.Size = UDim2.fromOffset(12, 166), UDim2.new(1, -24, 0, 30)
hostBanner.AutomaticSize, hostBanner.Visible = Enum.AutomaticSize.None, false
UI.Corner(hostBanner, 6)

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
	local audioInset = gui:GetAttribute("AudioControlsInset") or 0
	hud.Position, panel.Position = UDim2.new(.5, 0, 0, 8 + audioInset), UDim2.new(.5, 0, 0, 8 + audioInset)
	local compact = height < 500
	local host = lastSnapshot.host
	local isHost = host and host.authorized == true
	local overrideNames = isHost and host.activeOverrides or {}
	hostButton.Visible = isHost == true
	hostBanner.Visible = #overrideNames > 0
	hostBanner.Text = "HOST OVERRIDE · " .. table.concat(overrideNames, ", ")
	hud.Size = UDim2.fromOffset(math.min(432, width - 24), hostBanner.Visible and 208 or 171)
	if isHost then
		journalButton.Size = UDim2.new(1/3, -13, 0, 48)
		trackButton.Position, trackButton.Size = UDim2.new(1/3, 6, 0, 111), UDim2.new(1/3, -13, 0, 48)
		hostButton.Position, hostButton.Size = UDim2.new(2/3, 0, 0, 111), UDim2.new(1/3, -12, 0, 48)
	else
		journalButton.Size = UDim2.new(.5, -16, 0, 48)
		trackButton.Position, trackButton.Size = UDim2.new(.5, 4, 0, 111), UDim2.new(.5, -16, 0, 48)
	end
	goal.Text = width < 460 and "Phuong's Labubu → birthday cake" or "Together for Phuong's Labubu + birthday cake"
	goal.TextSize = width < 460 and 14 or 16
	-- Leave the lower control band uncovered. No full-screen input backdrop,
	-- camera replacement, player warp or movement disable is installed here.
	local panelWidth = math.min(580, width - 24)
	if width > height and compact then panelWidth = math.min(510, width - 204) end
	panel.Size = UDim2.fromOffset(math.max(280, panelWidth), math.max(192, math.min(740, height - (compact and 92 or 120) - audioInset)))
	toast.Size = UDim2.fromOffset(math.min(460, width - 36), 0)
	toast.Position = UDim2.new(.5, 0, 0, audioInset + (panel.Visible and panel.Size.Y.Offset + 14 or hud.Size.Y.Offset + 10))
end
gui:GetPropertyChangedSignal("AbsoluteSize"):Connect(layout)
gui:GetAttributeChangedSignal("AudioControlsInset"):Connect(layout)

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
	if extensionContext then Extensions.Notify({ kind = "PanelClosed" }, extensionContext()) end
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
		READY = "The gathering is paused while friends find their seats.",
		GATHERING = "Guests sit first, then Phuong sits in her marked seat to begin.",
		CELEBRATING = "Happy Birthday, Phuong! The optional birthday view has its own Skip / Return.",
		CAKE_READY = "Phuong, make the first cut whenever you are ready.",
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
		-- The extension supplies actor-specific actions and confirmations. Do not
		-- fall back to historical guest/host authority if that module is missing.
		addLabel("CakeControlsUnavailable", "Birthday controls are loading. Reopen the table in a moment.", 3)
	end
	scroll.CanvasPosition = preserveScroll and previous or Vector2.zero
end

extensionContext = function()
	return {
		UI = UI, gui = gui, player = player, snapshot = lastSnapshot, sessionId = sessionId,
		pending = pending ~= nil, toast = showToast, track = track, close = closeActivity,
		activePanel = panelMode == "extension" and activeExtension or nil,
		send = send, requestView = requestView,
		openPanel = function(id)
			local descriptor = Extensions.panels[id]
			if not descriptor or not inWorld() or descriptor.visible and not descriptor.visible(extensionContext()) then return end
			closeActivity(); setMode("extension"); activeExtension = id; clearContent()
			title.Text = Guidance.Text(descriptor.title or descriptor.label, "Birthday options")
			descriptor.render(scroll, extensionContext())
		end,
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
	layout()
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
hostButton.Activated:Connect(function()
	extensionContext().openPanel("HostControls")
	send({ kind = "RequestSnapshot" })
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
		if id == "Cake" then closeActivity(); renderCake(cakeState); send({ kind = "RequestSnapshot" })
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
]=],
["roblox/mvp/client/Navigator.luau"] = [=[local UI = require(script.Parent.UI)
local Guidance = require(script.Parent.Parent.shared.Guidance)
local Navigator = {}
Navigator.__index = Navigator

function Navigator.new(player, gui)
	local self = setmetatable({ player = player, gui = gui, cache = {} }, Navigator)
	return self
end

function Navigator:Resolve(name)
	local cached = self.cache[name]
	if cached and cached:IsDescendantOf(workspace) then return cached end
	local world = workspace:FindFirstChild("CozyWorld_Draft01")
	local mvp = world and world:FindFirstChild("MVP")
	local found = mvp and mvp:FindFirstChild(name, true)
	if found and found:GetAttribute("PlacementStatus") ~= "UNRESOLVED_LIVE_ANCHOR" then
		local part = found:IsA("BasePart") and found or found:FindFirstChildWhichIsA("BasePart", true)
		self.cache[name] = part
		return part
	end
	return nil
end

function Navigator:Root()
	local character = self.player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if not humanoid or humanoid.Health <= 0 then return nil end
	return character:FindFirstChild("HumanoidRootPart")
end

function Navigator:Nearest(id, view)
	local root = self:Root()
	local best, distance = nil, math.huge
	for _, name in ipairs(Guidance.AnchorNames(id, view)) do
		local anchor = self:Resolve(name)
		if anchor then
			local d = root and (anchor.Position - root.Position).Magnitude or 0
			if d < distance then best, distance = anchor, d end
		end
	end
	return best, distance
end

function Navigator:Distances(views)
	local distances = {}
	for _, id in ipairs(Guidance.Order) do
		local _, distance = self:Nearest(id, views[id])
		distances[id] = distance
	end
	return distances
end

function Navigator:Clear()
	if self.billboard then self.billboard:Destroy(); self.billboard = nil end
	if self.highlight then self.highlight:Destroy(); self.highlight = nil end
	self.anchor, self.activityId = nil, nil
end

function Navigator:SetTarget(id, view)
	if self.suspended or self.player:GetAttribute("BirthdayLocation") ~= "World" or not self:Root() then self:Clear(); return end
	local anchor = self:Nearest(id, view)
	if not anchor then self:Clear(); return end
	if self.anchor == anchor and self.activityId == id then return end
	self:Clear()
	self.anchor, self.activityId = anchor, id
	local billboard = Instance.new("BillboardGui")
	billboard.Name = "BirthdayDestinationMarker"
	billboard.Adornee = anchor
	billboard.AlwaysOnTop = true
	billboard.Size = UDim2.fromOffset(218, 68)
	billboard.StudsOffsetWorldSpace = Vector3.new(0, 5, 0)
	billboard.MaxDistance = 900
	billboard.Active = false
	billboard.Parent = self.gui
	local background = Instance.new("Frame")
	background.Size = UDim2.fromScale(1, 1)
	background.BackgroundColor3 = UI.Palette.cream
	background.BorderSizePixel = 0
	background.Parent = billboard
	UI.Corner(background)
	UI.Padding(background, 8)
	local label = UI.Label(background, "Destination", "", 15, UI.Palette.forest)
	label.Size = UDim2.fromScale(1, 1)
	label.AutomaticSize = Enum.AutomaticSize.None
	label.TextXAlignment = Enum.TextXAlignment.Center
	label.TextYAlignment = Enum.TextYAlignment.Center
	self.billboard, self.label = billboard, label
	local highlight = Instance.new("Highlight")
	highlight.Name = "BirthdayDestinationOutline"
	highlight.Adornee = anchor
	highlight.FillTransparency = 1
	highlight.OutlineColor = UI.Palette.golden
	highlight.OutlineTransparency = 0
	highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	highlight.Parent = self.gui
	self.highlight = highlight
end

function Navigator:Update()
	local root, anchor = self:Root(), self.anchor
	if self.suspended or not root or not anchor or not anchor:IsDescendantOf(workspace) or self.player:GetAttribute("BirthdayLocation") ~= "World" then
		self:Clear()
		return ""
	end
	local info = Guidance.Activities[self.activityId]
	local distance = math.floor((root.Position - anchor.Position).Magnitude + .5)
	local camera = workspace.CurrentCamera
	local hint = "Walk toward the marker"
	if distance <= 12 then
		hint = "You're here · use the nearby prompt"
	elseif camera then
		local _, onScreen = camera:WorldToViewportPoint(anchor.Position + Vector3.new(0, 5, 0))
		local relative = camera.CFrame:PointToObjectSpace(anchor.Position)
		if relative.Z > 0 then hint = "↶ Turn around"
		elseif not onScreen then hint = relative.X > 0 and "→ Turn right" or "← Turn left"
		else hint = "↑ Follow the marker" end
	end
	self.label.Text = "◆ " .. info.short .. "\n" .. tostring(distance) .. " studs"
	return hint .. " · " .. tostring(distance) .. " studs"
end

return Navigator
]=],
["roblox/mvp/client/UI.luau"] = [=[-- Shared primitives. All authored colors are exact approved palette tokens.
local UI = {}
UI.Palette = {
	forest = Color3.fromRGB(54, 87, 68), sage = Color3.fromRGB(168, 185, 149),
	cream = Color3.fromRGB(245, 240, 228), wood = Color3.fromRGB(149, 103, 75),
	blossom = Color3.fromRGB(232, 183, 198), brick = Color3.fromRGB(182, 108, 104),
	golden = Color3.fromRGB(232, 199, 121), ink = Color3.fromRGB(38, 56, 46),
}

function UI.Corner(instance, radius)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius or 12)
	corner.Parent = instance
	return corner
end

function UI.Padding(instance, amount)
	local padding = Instance.new("UIPadding")
	padding.PaddingTop = UDim.new(0, amount)
	padding.PaddingBottom = UDim.new(0, amount)
	padding.PaddingLeft = UDim.new(0, amount)
	padding.PaddingRight = UDim.new(0, amount)
	padding.Parent = instance
	return padding
end

function UI.List(instance, padding)
	local layout = Instance.new("UIListLayout")
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Padding = UDim.new(0, padding or 8)
	layout.Parent = instance
	return layout
end

function UI.Label(parent, name, value, size, color)
	local label = Instance.new("TextLabel")
	label.Name = name
	label.Text = value or ""
	label.TextColor3 = color or UI.Palette.ink
	label.BackgroundTransparency = 1
	label.BorderSizePixel = 0
	label.Font = Enum.Font.GothamMedium
	label.TextSize = size or 16
	label.TextWrapped = true
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextYAlignment = Enum.TextYAlignment.Top
	label.Size = UDim2.new(1, 0, 0, 0)
	label.AutomaticSize = Enum.AutomaticSize.Y
	label.Parent = parent
	return label
end

function UI.Button(parent, name, value, callback, secondary)
	local button = Instance.new("TextButton")
	button.Name = name
	button.Text = value or ""
	button.TextSize = 16
	button.Font = Enum.Font.GothamBold
	button.TextWrapped = true
	button.TextColor3 = secondary and UI.Palette.ink or UI.Palette.cream
	button.BackgroundColor3 = secondary and UI.Palette.sage or UI.Palette.forest
	button.BorderSizePixel = 0
	button.Size = UDim2.new(1, 0, 0, 52)
	button.AutoButtonColor = true
	button.Selectable = true
	button.Parent = parent
	UI.Corner(button, 10)
	local padding = UI.Padding(button, 8)
	padding.PaddingTop = UDim.new(0, 6)
	padding.PaddingBottom = UDim.new(0, 6)
	button.Activated:Connect(function() if button.Active then callback() end end)
	return button
end

function UI.SetEnabled(button, enabled, secondary)
	button.Active = enabled
	button.Interactable = enabled
	button.AutoButtonColor = enabled
	button.BackgroundColor3 = enabled and not secondary and UI.Palette.forest or UI.Palette.sage
	button.TextColor3 = enabled and not secondary and UI.Palette.cream or UI.Palette.ink
end

function UI.Card(parent, name, token)
	local frame = Instance.new("Frame")
	frame.Name = name
	frame.Size = UDim2.new(1, 0, 0, 0)
	frame.AutomaticSize = Enum.AutomaticSize.Y
	frame.BackgroundColor3 = UI.Palette[token or "sage"]
	frame.BorderSizePixel = 0
	frame.Parent = parent
	UI.Corner(frame)
	UI.Padding(frame, 12)
	UI.List(frame, 7)
	return frame
end

function UI.Clear(container)
	for _, child in ipairs(container:GetChildren()) do
		if child:IsA("GuiObject") then child:Destroy() end
	end
end

return UI
]=],
["roblox/mvp/environment-detail04.luau"] = [=[-- Edit-only ground and green-tree detail pass. Cherry assets and gameplay are preserved.
local RunService = game:GetService("RunService")
assert(not RunService:IsRunning(), "Environment details require Edit mode")
local root = assert(workspace:FindFirstChild("CozyWorld_Draft01"))
local V, CF = Vector3.new, CFrame.new
local palette = {
    forest=Color3.fromHex("365744"), sage=Color3.fromHex("A8B995"),
    cream=Color3.fromHex("F5F0E4"), wood=Color3.fromHex("95674B"),
    blossom=Color3.fromHex("E8B7C6"), brick=Color3.fromHex("B66C68"),
    golden=Color3.fromHex("E8C779"), ink=Color3.fromHex("26382E"),
}
local stage = Instance.new("Folder")
stage.Name = "EnvironmentDetail04"
stage:SetAttribute("SourceBuilder", "roblox/mvp/environment-detail04.luau")
stage:SetAttribute("VerificationTicket", "MAP-03")
stage:SetAttribute("TexturePolicy", "Native materials only; original cherry textures untouched")
local count = 0
local function part(name, size, cf, token, parent, material)
    local p=Instance.new("Part");p.Name=name;p.Size=size;p.CFrame=cf
    p.Color=palette[token];p:SetAttribute("PaletteToken",token)
    p.Material=material or Enum.Material.SmoothPlastic;p.Anchored=true
    p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.CastShadow=false
    p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth
    p.Parent=parent;count+=1;return p
end
local function ball(name,size,cf,token,parent,material)
    local p=part(name,size,cf,token,parent,material)
    local mesh=Instance.new("SpecialMesh");mesh.MeshType=Enum.MeshType.Sphere;mesh.Parent=p
    return p
end
local ground=Instance.new("Folder");ground.Name="GroundDetails";ground.Parent=stage
local foliage=Instance.new("Folder");foliage.Name="GreenTreeDetails";foliage.Parent=stage
local n=root.SurroundingContext.NeighborhoodDetails02
local field=root.Landscape.QuadGround
local fieldY=field.Position.Y+field.Size.Y/2
local road=root.SurroundingContext.UDistrictStreet
local sidewalk=root.SurroundingContext.ShopSidewalk
local sidewalkTop=sidewalk.Position.Y+sidewalk.Size.Y/2
-- Flush sidewalk seams, a curb edge, and small recessed drain grilles.
for i=0,24 do
    local z=sidewalk.Position.Z-sidewalk.Size.Z/2+6+i*12
    part("SidewalkJoint_"..i,V(sidewalk.Size.X,.025,.055),CF(sidewalk.Position.X,sidewalkTop+.015,z),"sage",ground,Enum.Material.Concrete)
end
part("StreetCurb",V(.35,.20,sidewalk.Size.Z),CF(sidewalk.Position.X+sidewalk.Size.X/2,sidewalkTop+.025,sidewalk.Position.Z),"cream",ground,Enum.Material.Concrete)
for i=1,6 do
    local z=road.Position.Z-road.Size.Z/2+20+i*40
    local x=road.Position.X-road.Size.X/2+1.6
    local y=road.Position.Y+road.Size.Y/2+.015
    part("DrainFrame_"..i,V(1.4,.04,2.5),CF(x,y,z),"ink",ground,Enum.Material.Metal)
    for j=1,5 do part("DrainSlat_"..i.."_"..j,V(1.18,.035,.12),CF(x,y+.025,z-1+j*.34),"sage",ground,Enum.Material.Metal) end
end
-- The world has moved since these route attributes were authored. Resolve their
-- translation from the current home anchor instead of moving existing geometry.
local authoredOffset=root.Paths:GetAttribute("WorldOffset")
assert(typeof(authoredOffset)=="Vector3","Route offset provenance required")
local routeDelta=(root.Home.Floor.Position-V(-28,.12,-108))-authoredOffset
local routes={}
for _,definition in root.Paths.RouteDefinitions:GetChildren() do
    local a,b=definition:GetAttribute("From"),definition:GetAttribute("To")
    assert(typeof(a)=="Vector3" and typeof(b)=="Vector3","Measured route required")
    table.insert(routes,{name=definition.Name,a=a+routeDelta,b=b+routeDelta,width=definition:GetAttribute("Width")})
end
local function nearOtherRoute(point,current)
    local p=Vector2.new(point.X,point.Z)
    for _,route in routes do if route~=current then
        local a,b=Vector2.new(route.a.X,route.a.Z),Vector2.new(route.b.X,route.b.Z)
        local d=b-a;local t=math.clamp((p-a):Dot(d)/d:Dot(d),0,1)
        if (p-a-d*t).Magnitude<route.width/2+1 then return true end
    end end
    return false
end
local walk=root.Paths.BrickWalkNetwork
local pavingY=walk.Position.Y+walk.Size.Y/2+.014
for _,route in routes do
    local length=(route.b-route.a).Magnitude
    local direction=(route.b-route.a).Unit
    for distance=4,length-3,6 do
        local position=route.a+direction*distance
        if not nearOtherRoute(position,route) then
            local cf=CFrame.lookAt(V(position.X,pavingY,position.Z),V(route.b.X,pavingY,route.b.Z))
            part("PavingCourse_"..route.name.."_"..math.floor(distance),V(route.width-.50,.025,.06),cf,"wood",ground,Enum.Material.Concrete)
        end
    end
end
-- Native grass and bark supply real surface texture, with explicit leaf silhouettes.
local changedMaterials={}
for _,tree in n.PerimeterGardens:GetChildren() do
    if tree:IsA("Model") and tree.Name:match("^LayeredTree%d+$") then
        local index=tonumber(tree.Name:match("%d+"))
        local details=Instance.new("Model");details.Name=tree.Name;details.Parent=foliage
        local trunk=assert(tree:FindFirstChild("TreeTrunk"))
        local center=V(trunk.Position.X,fieldY,trunk.Position.Z)
        local mulch=part("MulchBed",V(.07,6.6,6.6),CF(center+V(0,.045,0))*CFrame.Angles(0,0,math.pi/2),"wood",details,Enum.Material.Ground)
        mulch.Shape=Enum.PartType.Cylinder
        -- No change to existing trunk/crown footprint, placement, or collision.
        for _,p in tree:GetChildren() do
            if p:IsA("BasePart") and (p.Name:match("LeafCrown") or p.Name=="TopCrown" or p.Name:match("UnderstoryShrub")) then
                table.insert(changedMaterials,{part=p,material=p.Material})
                p.Material=Enum.Material.Grass
                for j=1,(p.Name:match("Understory") and 2 or 3) do
                    local angle=j*2.09+index*.43
                    local offset=V(math.cos(angle)*p.Size.X*.33,p.Size.Y*.23,math.sin(angle)*p.Size.Z*.32)
                    ball(p.Name.."_LeafCluster"..j,V(3.2,2.0,2.6),CF(p.Position+offset)*CFrame.Angles(.12*j,angle,.15),
                        (j+index)%3==0 and "sage" or "forest",details,Enum.Material.Grass)
                end
            end
        end
        -- Six narrow bark ridges provide trunk relief visible near the tree.
        local height=trunk.Size.X
        for j=1,6 do
            local angle=j*math.pi/3+index*.2
            part("BarkRidge_"..j,V(.10,height*.68,.16),CF(center+V(math.cos(angle)*.84,height*.40,math.sin(angle)*.84))*CFrame.Angles(0,-angle,0),
                j%3==0 and "ink" or "wood",details,Enum.Material.Wood)
        end
        -- Low native leaf litter stays within existing tree beds.
        for j=1,4 do
            local angle=j*1.73+index
            ball("FallenLeaf_"..j,V(.48,.045,.24),CF(center+V(math.cos(angle)*2.8,.09,math.sin(angle)*2.8))*CFrame.Angles(0,angle,0),
                j%2==0 and "sage" or "golden",ground,Enum.Material.Grass)
        end
    end
end
-- Grass tufts on the outer verges, clear of shops, park gates, arrival and paths.
local bounds=root.MVP.Environment.SeattleBoundary
local minX,maxX=bounds:GetAttribute("EnclosureMinX"),bounds:GetAttribute("EnclosureMaxX")
local minZ,maxZ=bounds:GetAttribute("EnclosureMinZ"),bounds:GetAttribute("EnclosureMaxZ")
assert(minX and maxX and minZ and maxZ,"Install the enclosed boundary first")
for side=1,2 do for i=1,20 do
    local x=side==1 and minX+7 or maxX-7
    local z=minZ+18+i*(maxZ-minZ-40)/21
    for j=1,3 do
        ball("VergeTuft_"..side.."_"..i.."_"..j,V(.20,.38+j*.12,.60),CF(x+(j-2)*.28,fieldY+.22,z)*CFrame.Angles(0,j*.9+i,.22),j==2 and "sage" or "forest",ground,Enum.Material.Grass)
    end
end end
assert(count<=1100,"Environment detail exceeds its 1100-part budget")
stage:SetAttribute("PartCount",count);stage:SetAttribute("ChangedNativeMaterials",#changedMaterials)
local old=root:FindFirstChild(stage.Name)
if old then old:Destroy() end
stage.Parent=root
game:GetService("ChangeHistoryService"):SetWaypoint("Ground and green-tree surface detail 04")
return {parts=count,greenTrees=#foliage:GetChildren(),changedNativeMaterials=#changedMaterials}
]=],
["roblox/mvp/ground-city-boundary.luau"] = [=[-- Edit-mode repair: extend city facades downward, preserving their roof height.
local root=workspace.CozyWorld_Draft01
local field=root.Landscape:WaitForChild("QuadGround")
local groundY=field.Position.Y+field.Size.Y/2
local boundary=root.MVP.Environment:WaitForChild("SeattleBoundary")
local count=0
for _,p in boundary:GetDescendants() do
 if p:IsA("BasePart") and (p.Name:match("^Shell%d+$") or (p.Name=="Body" and p.Parent.Parent.Name=="CompressedSeattleSkyline")) then
  local top=p.Position.Y+p.Size.Y/2
  if p.Position.Y-p.Size.Y/2>groundY then
   local height=top-groundY
   p.Size=Vector3.new(p.Size.X,height,p.Size.Z)
   p.CFrame=p.CFrame+Vector3.new(0,groundY+height/2-p.Position.Y,0)
   count+=1
  end
 end
end
boundary:SetAttribute("GroundedFieldY",groundY)
return {extended=count,fieldY=groundY}
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
["roblox/mvp/server/activities/Q01.luau"] = [=[-- Server-owned room activity. Only the seven bed steps earn Q01.
local Q01 = {}
Q01.__index = Q01
Q01.ActivityId = "Q01"
Q01.StepIds = { "blanket_left", "blanket_right", "blanket_foot", "pillow_left", "pillow_right", "plush_dog", "plush_dinosaur" }
Q01.StepLabels = {
	blanket_left = "Smooth the left blanket edge", blanket_right = "Smooth the right blanket edge",
	blanket_foot = "Fold the cream quilt", pillow_left = "Place the left pillow", pillow_right = "Place the right pillow",
	plush_dog = "Tuck in the round-bellied dog", plush_dinosaur = "Tuck in the dinosaur plush",
}
local ITEMS = {
	blanket_left = { label = "Left blanket edge", destination = "Left side of the sage bed", verb = "Tuck" },
	blanket_right = { label = "Right blanket edge", destination = "Right side of the sage bed", verb = "Tuck" },
	blanket_foot = { label = "Cream quilt", destination = "Foot of the sage bed", verb = "Fold" },
	pillow_left = { label = "Left cream pillow", destination = "Left pillow spot", verb = "Place" },
	pillow_right = { label = "Right cream pillow", destination = "Right pillow spot", verb = "Place" },
	plush_dog = { label = "Round-bellied dog plush", destination = "Dog's spot beside the pillows", verb = "Tuck" },
	plush_dinosaur = { label = "Dinosaur plush", destination = "Dinosaur's spot beside the pillows", verb = "Tuck" },
}
local SHELF_ITEMS = { { id = "book_sage", label = "Sage book" }, { id = "book_cream", label = "Cream book" }, { id = "small_figure", label = "Small shelf figure" } }
local SHELF_SLOTS = { { id = "left", label = "Top shelf · left" }, { id = "middle", label = "Top shelf · middle" }, { id = "right", label = "Top shelf · right" } }
Q01.ReservationSeconds = 30
local function now(self) return self.clock and self.clock() or os.clock() end
local function find(list, id) for _, item in ipairs(list) do if item.id == id then return item end end end
local function copyMap(source) local result = {}; for k, v in pairs(source) do result[k] = v end; return result end

function Q01.new(context)
	assert(context and context.session, "Q01 requires a shared session")
	return setmetatable({ session = context.session, clock = context.clock, feedback = context.feedback,
		reserved = {}, reservationByActor = {}, visibleState = {}, currentRoundId = nil, finishedPreview = nil,
		finalChoices = { soft_snug = "Soft and snug", neat_layered = "Neatly layered" },
		shelfSlots = {}, shelfHolds = {}, shelfItemHolds = {}, shelfSlotHolds = {}, actions = {}, expiryRevision = 0,
	}, Q01)
end
Q01.New = Q01.new
function Q01:_round() return self.currentRoundId and self.session.rounds[self.currentRoundId] or nil end
function Q01:_active(roundId)
	local round = self:_round()
	return roundId == self.currentRoundId and round and round.state == "IN_PROGRESS" and round or nil
end
function Q01:_host(actor)
	return actor == self.session.phuongUserId or (self.session.hostUserId ~= 0 and actor == self.session.hostUserId)
end
function Q01:_releaseBed(actor)
	local hold = self.reservationByActor[actor]
	if hold then self.reserved[hold.stepId] = nil; self.reservationByActor[actor] = nil end
end
function Q01:_releaseShelf(actor)
	local hold = self.shelfHolds[actor]
	if hold then
		self.shelfItemHolds[hold.itemId] = nil
		if hold.slotId then self.shelfSlotHolds[hold.slotId] = nil end
		self.shelfHolds[actor] = nil
	end
end
function Q01:ReleaseActor(actor, roundId)
	-- A delayed close from an older round must not release a new-round choice.
	if roundId and roundId ~= self.currentRoundId then return end
	self:_releaseBed(actor); self:_releaseShelf(actor)
end
function Q01:ExpireReservations(at)
	local timestamp, changed = at or now(self), false
	for actor, hold in pairs(self.reservationByActor) do
		if hold.expiresAt <= timestamp then self:_releaseBed(actor); changed = true end
	end
	for actor, hold in pairs(self.shelfHolds) do
		if hold.expiresAt <= timestamp then self:_releaseShelf(actor); changed = true end
	end
	if changed then self.expiryRevision += 1 end
	return changed
end
function Q01:CreateRound(request)
	assert(not self:_round() or self:_round().state ~= "IN_PROGRESS", "Q01 round already active")
	assert(not self:_round() or request.replay == true or request.isReplay == true, "explicit replay required")
	self.session:CreateRound(self.ActivityId, request.roundId, request.actorUserId)
	self.currentRoundId = request.roundId
	self.reserved, self.reservationByActor, self.visibleState = {}, {}, {}
	self.shelfHolds, self.shelfItemHolds, self.shelfSlotHolds = {}, {}, {}
	self.finishedPreview = nil
	-- Committed shelf layout intentionally persists across bed replays.
	if self.feedback then
		local ok,err=pcall(self.feedback.BeginRound,self.feedback,request.roundId)
		if not ok then warn("Bedroom round presentation needs attention",err) end
	end
	return self:GetView(request.actorUserId)
end
Q01.Start = Q01.CreateRound

function Q01:_bed(request, action)
	local actor, stepId = request.actorUserId, request.stepId
	local round = self:_active(request.roundId)
	if not round then return false, "ROUND_CHANGED", "This bed round changed. Reopen it to see the current tasks." end
	if not ITEMS[stepId] then return false, "INVALID_STEP", "Choose one of the bed task cards." end
	if action == "cancel" then self:_releaseBed(actor); return true, "CANCELLED" end
	if round.steps[stepId] then return false, "ALREADY_DONE", "That spot is already tidy. Choose another bed task." end
	local held = self.reserved[stepId]
	if action == "reserve" then
		if held and held.actorUserId ~= actor then return false, "IN_USE", "A friend is using that spot. Choose another task or try again shortly." end
		self:_releaseBed(actor); self:_releaseShelf(actor)
		local hold = { actorUserId = actor, stepId = stepId, expiresAt = now(self) + self.ReservationSeconds }
		self.reserved[stepId], self.reservationByActor[actor] = hold, hold
		return true, "RESERVED"
	end
	if action ~= "place" then return false, "UNKNOWN_ACTION", "Choose a bed task, then use Place or Tuck." end
	if not held or held.actorUserId ~= actor then return false, "HOLD_EXPIRED", "Your item was put back. Choose its card again, then place it." end
	self.session:ApplyStep(request)
	self:_releaseBed(actor)
	self.visibleState[stepId] = true
	if self.feedback then self.feedback:ApplyStep(stepId) end
	return true, "ACCEPTED"
end

function Q01:_shelf(request, action)
	local actor, payload = request.actorUserId, request.payload
	if not self.feedback or not self.feedback.shelfReady then return false, "SHELF_UNAVAILABLE", "The bedroom shelf is not ready. You can still help with the bed." end
	if action == "shelf_cancel" then self:_releaseShelf(actor); return true, "CANCELLED" end
	local function itemSlot(itemId) for slot, item in pairs(self.shelfSlots) do if item == itemId then return slot end end end
	if action == "shelf_select" then
		local item = find(SHELF_ITEMS, payload.itemId)
		if not item then return false, "INVALID_ITEM", "Choose a book or the small shelf figure." end
		if itemSlot(item.id) and not self:_host(actor) then return false, "HOST_ONLY", "Phuong or Andrew can rearrange displayed items. Choose an item that has not been placed." end
		local owner = self.shelfItemHolds[item.id]
		if owner and owner ~= actor then return false, "IN_USE", "A friend is holding that item. Choose another one." end
		-- A displayed item's current slot may already be reserved by another host.
		local sourceSlot = itemSlot(item.id)
		if sourceSlot and self.shelfSlotHolds[sourceSlot] and self.shelfSlotHolds[sourceSlot] ~= actor then return false, "IN_USE", "A friend is arranging that spot. Choose another item." end
		self:_releaseShelf(actor); self:_releaseBed(actor)
		self.shelfHolds[actor] = { itemId = item.id, expiresAt = now(self) + self.ReservationSeconds }
		self.shelfItemHolds[item.id] = actor
		return true, "SHELF_SELECTED"
	end
	local hold = self.shelfHolds[actor]
	if not hold then return false, "HOLD_EXPIRED", "Your shelf item was put back. Choose it again." end
	if action == "shelf_slot" then
		if not find(SHELF_SLOTS, payload.slotId) then return false, "INVALID_SLOT", "Choose a labeled top shelf spot." end
		local occupied, owner = self.shelfSlots[payload.slotId], self.shelfSlotHolds[payload.slotId]
		if owner and owner ~= actor or occupied and self.shelfItemHolds[occupied] and self.shelfItemHolds[occupied] ~= actor then
			return false, "IN_USE", "A friend is arranging that spot. Choose another or try again shortly."
		end
		if occupied and occupied ~= hold.itemId and not self:_host(actor) then return false, "SLOT_FULL", "That spot already has an item. Choose an empty spot." end
		if hold.slotId then self.shelfSlotHolds[hold.slotId] = nil end
		hold.slotId, hold.expiresAt = payload.slotId, now(self) + self.ReservationSeconds
		self.shelfSlotHolds[hold.slotId] = actor
		return true, "SHELF_SLOT_SELECTED"
	end
	if action ~= "shelf_place" or not hold.slotId or self.shelfSlotHolds[hold.slotId] ~= actor then
		return false, "CHOOSE_SLOT", "Choose a labeled shelf spot before placing your item."
	end
	local oldSlot, occupant = itemSlot(hold.itemId), self.shelfSlots[hold.slotId]
	if (oldSlot or occupant and occupant ~= hold.itemId) and not self:_host(actor) then return false, "HOST_ONLY", "Phuong or Andrew can change the shared display. Guests can fill empty spots." end
	if occupant and self.shelfItemHolds[occupant] and self.shelfItemHolds[occupant] ~= actor then return false, "IN_USE", "A friend is holding the item in that spot. Try another spot." end
	if oldSlot then self.shelfSlots[oldSlot] = nil end
	self.shelfSlots[hold.slotId] = hold.itemId
	self:_releaseShelf(actor)
	self.feedback:RenderShelf(self.shelfSlots)
	return true, "SHELF_PLACED"
end

function Q01:_finish(request)
	local round = self:_active(request.roundId)
	if not round then return false, "ROUND_CHANGED", "The bed is already finished. Choose Play again to begin a new round." end
	if not self.session:CanSpend(request.actorUserId, self.session.presence) then return false, "PHUONG_FINISH", "Phuong chooses the final style. Andrew can help when she is away." end
	local choice = request.payload.choiceId
	if not self.finalChoices[choice] then return false, "INVALID_STYLE", "Choose one of the two finishing styles." end
	for _, step in ipairs(self.StepIds) do if not round.steps[step] then return false, "STEPS_REMAIN", "Finish all seven bed tasks before choosing the final style." end end
	local receipt = self.session:CompleteRound(request)
	self.finishedPreview = { choiceId = choice, choiceLabel = self.finalChoices[choice] }
	if self.feedback then self.feedback:Finish(choice) end
	return true, "FINISHED", nil, receipt
end
function Q01:Apply(request)
	if request.sessionId ~= self.session.sessionId or request.activityId ~= self.ActivityId or not self.session:IsPresent(request.actorUserId)
		or type(request.actionId) ~= "string" or request.actionId == "" or type(request.payload) ~= "table" then
		return { ok = false, code = "BadAction", message = "Reopen the bed activity to get fresh choices." }
	end
	local prior = self.actions[request.actionId]
	if prior then
		if prior.actor ~= request.actorUserId or prior.roundId ~= request.roundId then return { ok = false, code = "BadAction" } end
		return { ok = prior.ok, code = "DUPLICATE", message = prior.message, receipt = prior.receipt, view = self:GetView(request.actorUserId) }
	end
	if request.roundId ~= self.currentRoundId then return { ok = false, code = "ROUND_CHANGED", message = "This round changed. Reopen the bed activity." } end
	self:ExpireReservations()
	local action = request.payload.action
	local ok, code, message, receipt
	if action == "finish" and request.stepId == "finish" then ok, code, message, receipt = self:_finish(request)
	elseif type(action) == "string" and string.sub(action, 1, 6) == "shelf_" and request.stepId == "shelf" then ok, code, message = self:_shelf(request, action)
	elseif action == "reserve" or action == "place" or action == "cancel" then ok, code, message = self:_bed(request, action)
	else ok, code, message = false, "UNKNOWN_ACTION", "Choose an available bed or shelf action." end
	self.actions[request.actionId] = { actor = request.actorUserId, roundId = request.roundId, ok = ok, message = message, receipt = receipt }
	return { ok = ok, code = code, message = message, receipt = receipt, view = self:GetView(request.actorUserId) }
end

function Q01:RecoveryState()
	return { roundId = self.currentRoundId, reserved = self.reserved, shelfHolds = self.shelfHolds, visible = self.visibleState, finished = self.finishedPreview }
end
function Q01:RecoverRelease(request)
	self.session:AssertRecovery(request)
	self.reserved, self.reservationByActor = {}, {}
	self.shelfHolds, self.shelfItemHolds, self.shelfSlotHolds = {}, {}, {}
	self.expiryRevision += 1
end
function Q01:RecoverRestart(request, newRoundId)
	self.session:RecoverCancel(request); self:RecoverRelease(request)
	self.currentRoundId = nil
	self:CreateRound({ sessionId = request.sessionId, activityId = "Q01", roundId = newRoundId, actorUserId = request.actorUserId })
	return newRoundId
end
function Q01:RecoverComplete(request)
	self.session:AssertRecovery(request); self:RecoverRelease(request)
	for _, step in ipairs(self.StepIds) do self.session:RecoverStep(request, step); self.visibleState[step] = true end
	local receipt = self.session:RecoverCompleteRound(request)
	self.finishedPreview = self.finishedPreview or { choiceId = "soft_snug", choiceLabel = self.finalChoices.soft_snug }
	if self.feedback then
		local ok, err = pcall(function()
			for _, step in ipairs(self.StepIds) do self.feedback:ApplyStep(step) end
			self.feedback:Finish(self.finishedPreview.choiceId)
		end)
		if not ok then warn("PCW-24 bedroom recovery presentation", err) end
	end
	return receipt
end

function Q01:GetView(actor)
	self:ExpireReservations()
	local round, accepted, completed = self:_round(), {}, 0
	if round then for step in pairs(round.steps) do accepted[step] = true; completed += 1 end end
	local phase = not round and "INACTIVE" or round.state == "COMPLETED" and "FINISHED" or completed == 7 and "READY_FOR_PHUONG" or "IN_PROGRESS"
	local actions, doneLabels = {}, {}
	local held = actor and self.reservationByActor[actor]
	local shelfHold = actor and self.shelfHolds[actor]
	local function add(id, label, step, payload, group, enabled, reason, description, primary)
		local descriptor = { id = id, label = label, stepId = step, payload = payload, groupId = group,
			enabled = enabled ~= false, reason = reason, description = description, primary = primary == true }
		table.insert(actions, descriptor); return descriptor
	end
	for _, step in ipairs(self.StepIds) do
		local item, reservation = ITEMS[step], self.reserved[step]
		if accepted[step] then table.insert(doneLabels, self.StepLabels[step])
		elseif round and phase ~= "FINISHED" then
			if held and held.stepId == step then
				add("place:" .. step, item.verb .. " " .. string.lower(item.label), step, { action = "place" }, "placement", true, nil, "Highlighted destination: " .. item.destination, true)
				add("cancel:" .. step, "Put item back", step, { action = "cancel" }, "placement", true, nil, "Release this item so someone else can help.")
			else
				add("reserve:" .. step, "Pick up " .. string.lower(item.label), step, { action = "reserve" }, "bed", reservation == nil, reservation and "In use · choose another task", item.destination)
			end
		end
	end
	if phase == "READY_FOR_PHUONG" then
		local canFinish = actor and self.session:CanSpend(actor, self.session.presence)
		for _, choice in ipairs({ "soft_snug", "neat_layered" }) do
			local descriptor = add("finish:" .. choice, self.finalChoices[choice], "finish", { action = "finish", choiceId = choice }, "finish", canFinish == true, "Phuong chooses; Andrew can help when she is away.", "Save this style and complete the bed petal.")
			descriptor.confirm = { title = "Finish the bed?", detail = "Save this style for everyone and add the bed's shared reward once.", label = "Finish " .. string.lower(self.finalChoices[choice]) }
		end
	end
	local shelfView = { ready = self.feedback ~= nil and self.feedback.shelfReady == true, slots = {}, items = {}, optional = true }
	if shelfView.ready then
		for _, item in ipairs(SHELF_ITEMS) do
			local placed = false; for _, itemId in pairs(self.shelfSlots) do if itemId == item.id then placed = true end end
			local owner = self.shelfItemHolds[item.id]
			local enabled = (not owner or owner == actor) and (not placed or self:_host(actor))
			table.insert(shelfView.items, { id = item.id, label = item.label, placed = placed })
			if not shelfHold then add("shelf_select:" .. item.id, "Choose " .. string.lower(item.label), "shelf", { action = "shelf_select", itemId = item.id }, "shelf", enabled, owner and "In use" or "Displayed · Phuong or Andrew can rearrange", "Optional top shelf tidying · no fund or petal reward.") end
		end
		for _, slot in ipairs(SHELF_SLOTS) do
			local item = find(SHELF_ITEMS, self.shelfSlots[slot.id])
			local owner = self.shelfSlotHolds[slot.id]
			table.insert(shelfView.slots, { id = slot.id, label = slot.label, itemLabel = item and item.label, busy = owner ~= nil and owner ~= actor })
			if shelfHold then
				local itemHeldBy = item and self.shelfItemHolds[item.id]
				local busy = owner and owner ~= actor or itemHeldBy and itemHeldBy ~= actor
				local enabled = not busy and (not item or item.id == shelfHold.itemId or self:_host(actor))
				local descriptor = add("shelf_slot:" .. slot.id, slot.label, "shelf", { action = "shelf_slot", slotId = slot.id }, "shelf", enabled, busy and "In use" or "Occupied · choose an empty spot", item and "Currently: " .. item.label or "Empty spot")
				descriptor.selected = shelfHold.slotId == slot.id
			end
		end
		if shelfHold then
			local item = find(SHELF_ITEMS, shelfHold.itemId)
			shelfView.held = { itemId = item.id, label = item.label, slotId = shelfHold.slotId, expiresAt = shelfHold.expiresAt, targetName = shelfHold.slotId and "ShelfTarget_" .. shelfHold.slotId }
			if shelfHold.slotId then
				local slot = find(SHELF_SLOTS, shelfHold.slotId)
				local descriptor = add("shelf_place", "Place " .. string.lower(item.label), "shelf", { action = "shelf_place" }, "placement", true, nil, slot.label .. " · everyone will see it here", true)
				descriptor.confirm = { title = "Place this shelf item?", detail = item.label .. " → " .. slot.label .. ". Any replaced item returns to the tidy tray. No funds or petals change.", label = "Place item" }
			end
			add("shelf_cancel", "Put shelf item back", "shelf", { action = "shelf_cancel" }, "shelf", true)
		end
	end
	local heldView = held and { stepId = held.stepId, label = ITEMS[held.stepId].label, destination = ITEMS[held.stepId].destination, targetName = "BedTarget_" .. held.stepId, expiresAt = held.expiresAt }
	local detail = heldView and "Holding " .. heldView.label .. ". Follow the highlighted spot, then choose Place or Tuck."
		or shelfHold and "Choose a labeled shelf spot, then confirm placement. The shelf is optional."
		or phase == "READY_FOR_PHUONG" and "All seven tasks are done. Phuong can choose the finishing style."
		or phase == "FINISHED" and "The bed petal is saved. You can tidy the shelf or choose Play again together."
		or "Choose a blanket, pillow or plush card. Pick it up, see its highlighted spot, then Place or Tuck."
	return { activityId = self.ActivityId, roundId = self.currentRoundId, state = phase, title = "Everything Tucked In", instructions = detail,
		progress = { done = completed, total = 7 }, availableActions = actions, acceptedStepIds = accepted,
		contributors = round and copyMap(round.contributors) or {}, canReplay = phase == "FINISHED", visibleState = copyMap(self.visibleState),
		finishedPreview = self.finishedPreview, held = heldView, doneLabels = doneLabels, shelf = shelfView, reservationSeconds = self.ReservationSeconds,
		guide = { headline = phase == "FINISHED" and "The room feels cozier together" or "A cozy bed, one small task at a time", detail = detail,
			stepLabel = string.format("%d of 7 bed tasks done · %d remaining", completed, 7 - completed), nextAnchor = shelfHold and "Q01Shelf" or "Q01Bed",
			groups = { { id = "placement", title = "Place your held item" }, { id = "bed", title = "Choose a bed task" },
				{ id = "finish", title = "Phuong's finishing style" }, { id = "shelf", title = "Optional · tidy the bedroom shelf", detail = "Choose an item, choose a top shelf spot, then confirm. Phuong and Andrew can rearrange; guests fill empty spots." } },
		},
	}
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
        actionIdentities = {},
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

function Activity:_feedback(name, ...)
    local hook = self.context[name]
    if hook then local ok, err = pcall(hook, ...); if not ok then warn("PCW-22 Jasper feedback", name, err) end end
end

local function identity(request)
    local p = request.payload or {}
    return table.concat({tostring(request.actorUserId), tostring(request.roundId), tostring(request.stepId), tostring(p.basketIndex), tostring(p.targetIndex)}, ":")
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
    assert(request and request.sessionId == self.session.sessionId and request.activityId == "Q02" and request.roundId, "Q02 round request is invalid")
    assert(not self.round or self.state == "COMPLETED", "Q02 already has an active round")
    assert(not self.round or request.replay == true, "replay must be explicit")
    assert(self:_present(self:_actorId(request)), "actor is not present")
    local created = self.session:CreateRound("Q02", request.roundId, self:_actorId(request))
    self.round = { activityId = "Q02", roundId = request.roundId, startedBy = created.startedBy, isReplay = created.isReplay }
    self.replayCount = request.replay == true and self.replayCount + 1 or self.replayCount
    self.state, self.jasperMode = "GREETING", "BEDROOM"
    self.rabbitBasket, self.targetIndex = nil, 0
    self.accepted, self.actionReceipts, self.actionIdentities, self.contributors, self.reservations = {}, {}, {}, {}, {}
    self.busyThrowAction, self.busyThrowActor = nil, nil
    self.lastError = nil
    self:_feedback("resetJasper", request.roundId)
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
    self.actionIdentities[request.actionId] = identity(request)
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
    assert(request and request.sessionId == self.session.sessionId and request.activityId == "Q02", "invalid Q02 session")
    assert(self.round and request.roundId == self.round.roundId, "Q02 round is not active")
    local prior = request and request.actionId and self.actionReceipts[request.actionId]
    if prior then
        assert(self.actionIdentities[request.actionId] == identity(request), "action identity changed")
        return {ok = true, code = "duplicate", receipt = prior, view = self:GetView(self:_actorId(request))}
    end
    assert(not (self.session.receipts and self.session.receipts[request.actionId]) and not (self.session.acceptedSteps and self.session.acceptedSteps[request.actionId]), "action belongs to another receipt")
    self:_action(request)
    local actorUserId = self:_actorId(request)
    local stepId = request.stepId
    if stepId == "greet" then
        assert(self.state == "GREETING", "greeting is closed")
        local receipt = self:_accept(request)
        self.state, self.jasperMode = "LEADING", "LEADING_TO_YARD"
        self:_feedback("moveJasperToYard")
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
        self:_feedback("showRabbitPickup", self.rabbitBasket)
        return {ok = true, code = "accepted", receipt = receipt, view = self:GetView(actorUserId)}
    elseif stepId == "rabbitReturned" then
        self:_requirePrevious(stepId)
        assert(self.state == "RABBIT", "rabbit is not ready for return")
        local reservation = self.reservations.rabbit
        if reservation and reservation ~= actorUserId then error("rabbit is being carried by another player") end
        self.reservations.rabbit = nil
        local receipt = self:_accept(request)
        self.state, self.jasperMode = "FETCH", "FETCH_READY"
        self:_feedback("returnRabbit")
        self:_feedback("presentFetchTarget", 1)
        return {ok = true, code = "accepted", receipt = receipt, view = self:GetView(actorUserId)}
    elseif FETCH_STEPS[stepId] then
        self:_requirePrevious(stepId)
        assert(self.state == "FETCH", "fetch is not available")
        local expected = self.targetIndex + 1
        assert(stepId == "fetch" .. expected and expected <= 3, "wrong fetch step")
        assert(tonumber(request.payload and request.payload.targetIndex) == expected, "wrong fetch target")
        assert(not self.busyThrowAction, "fetch target is occupied")
        self.busyThrowAction, self.busyThrowActor = request.actionId, actorUserId
        local accepted = self:_accept(request)
        self.busyThrowAction, self.busyThrowActor = nil, nil
        self.targetIndex = expected
        self:_feedback("fetchJasper", expected)
        self:_feedback("presentFetchTarget", expected < 3 and expected + 1 or nil)
        if expected == 3 then self.state = "GREENIE" end
        return {ok = true, code = "accepted", receipt = accepted, view = self:GetView(actorUserId)}
    elseif stepId == "greenie" then
        self:_requirePrevious(stepId)
        assert(self.state == "GREENIE", "Greenie is not available")
        local receipt = self:_accept(request)
        self.state, self.jasperMode = "COMPLETED", "CELEBRATING"
        local completed = self.session:CompleteRound({sessionId = self.session.sessionId, activityId = "Q02", roundId = self.round.roundId, actionId = request.actionId .. ":complete", actorUserId = actorUserId})
        self:_feedback("giveJasperTreat")
        return {ok = true, code = "completed", receipt = completed, view = self:GetView(actorUserId)}
    elseif stepId == "pet" then
        assert(self.state == "COMPLETED", "petting is available after Greenie")
        local receipt = {activityId = "Q02", roundId = self.round.roundId, stepId = "pet", actionId = request.actionId, reward = 0, petalGranted = false}
        self.actionReceipts[request.actionId], self.actionIdentities[request.actionId] = receipt, identity(request)
        self:_feedback("petJasper", actorUserId)
        return {ok = true, code = "petted", receipt = receipt, view = self:GetView(actorUserId)}
    end
    error("unknown Q02 action: " .. tostring(stepId))
end

function Activity:ReleaseActor(actorUserId)
    for key, value in pairs(self.reservations) do if value == actorUserId then self.reservations[key] = nil end end
    if self.busyThrowActor == actorUserId then self.busyThrowAction, self.busyThrowActor = nil, nil end
end

function Activity:RecoveryState()
    return { roundId = self.round and self.round.roundId, state = self.state, accepted = self.accepted, reservations = self.reservations }
end
function Activity:RecoverComplete(request)
    self.session:AssertRecovery(request)
    for _, step in ipairs(STEPS) do self.accepted[step] = self.session:RecoverStep(request, step) end
    local receipt = self.session:RecoverCompleteRound(request)
    self.state, self.jasperMode, self.targetIndex = "COMPLETED", "CELEBRATING", 3
    self.contributors[request.actorUserId] = true
    self.reservations, self.busyThrowAction, self.busyThrowActor = {}, nil, nil
    self:_feedback("resetJasper", request.roundId)
    self:_feedback("moveJasperToYard")
    self:_feedback("returnRabbit")
    self:_feedback("presentFetchTarget", nil)
    self:_feedback("giveJasperTreat")
    return receipt
end

function Activity:GetView(actorUserId)
    local actions = {}
    if self.state == "GREETING" then actions = {{id="greet", label="Say hi to Jasper", stepId="greet", payload={}, enabled=true}}
    elseif self.state == "LEADING" then actions = {
        {id="rabbitFound-1", label="Inspect basket 1", stepId="rabbitFound", payload={basketIndex=1}, enabled=true},
        {id="rabbitFound-2", label="Inspect basket 2", stepId="rabbitFound", payload={basketIndex=2}, enabled=true},
        {id="rabbitFound-3", label="Inspect basket 3", stepId="rabbitFound", payload={basketIndex=3}, enabled=true},
    }
    elseif self.state == "RABBIT" then actions = {{id="rabbitReturned", label="Return rabbit to Jasper", stepId="rabbitReturned", payload={}, enabled=true}}
    elseif self.state == "FETCH" then actions = {{id="fetch" .. tostring(self.targetIndex + 1), label="Pick up toy + gentle throw " .. tostring(self.targetIndex + 1), stepId="fetch" .. tostring(self.targetIndex + 1), payload={targetIndex=self.targetIndex + 1}, enabled=self.busyThrowAction == nil, reason=self.busyThrowAction and "Target occupied" or nil}}
    elseif self.state == "GREENIE" then actions = {{id="greenie", label="Give Greenie", stepId="greenie", payload={}, enabled=true}}
    elseif self.state == "COMPLETED" then actions = {{id="pet", label="Pet Jasper", stepId="pet", payload={}, enabled=true}} end
    local indoor = self.state == "GREETING" or self.state == "IDLE"
    local required = indoor and "Bedroom" or "Yard"
    local atStation = not self.context.jasperVenue or self.context.jasperVenue(actorUserId) == required
    local detail = ({GREETING="Say hello, then follow Jasper's marker to the yard.", LEADING="Meet Jasper in the yard. Inspect the numbered baskets to find his rabbit.", RABBIT="The rabbit is found. Anyone nearby can return it to Jasper.", FETCH="Choose a gentle throw. Jasper fetches and brings the toy back; there is no aiming or timing test.", GREENIE="Three toys returned! Give Jasper his Greenie.", COMPLETED="Jasper is happy. Your shared petal and reward are saved. Petting and replay are optional."})[self.state] or "Say hello to Jasper in the bedroom."
    if not atStation then detail = "Next · " .. (indoor and "Phuong's bedroom" or "Jasper's yard") .. ". Track the marker, then open Jasper's prompt. Shared progress stays saved." end
    for _, action in ipairs(actions) do action.primary=#actions==1; action.confirm=false; if not atStation then action.enabled=false; action.reason="Walk to " .. (indoor and "the bedroom" or "Jasper's yard") .. " first." end end
    local done=0; for _ in pairs(self.accepted) do done+=1 end
    return {activityId = "Q02", roundId = self.round and self.round.roundId, state = self.state, title = "Jasper's Favorite Things", instructions = detail, progress = {done = done, total = #STEPS}, fetchCount=self.targetIndex, atStation=atStation,
        guide={headline=self.state=="COMPLETED" and "Jasper's favorite things · done!" or "Visit Jasper · "..(indoor and "bedroom" or "yard"), detail=detail, nextAnchor=indoor and "JasperBedroomStart" or "JasperFetchYard"},
        availableActions = actions, acceptedStepIds = clone(self.accepted), contributors = clone(self.contributors), busyReason = self.busyThrowAction and "fetch_target_occupied" or nil, errorText = self.lastError, canReplay = self.state == "COMPLETED"}
end

return Activity
]=],
["roblox/mvp/server/activities/Q03.luau"] = [=[-- One shared miniature. SessionService retains the original six-part reward timing.
local Q03 = {}; Q03.__index = Q03
local PARTS = {"rug", "chair", "bookcase", "side_table", "plant", "lamp"}
local SOCKETS = {rug="rugSocket", chair="chairSocket", bookcase="bookcaseSocket", side_table="sideTableSocket", plant="plantSocket", lamp="lampSocket"}
local LABELS = {rug="Rug", chair="Chair", bookcase="Bookcase", side_table="Side table", plant="Plant", lamp="Lamp"}
local function copy(t) local r={}; for k,v in pairs(t) do r[k]=type(v)=="table" and copy(v) or v end; return r end
local function validId(value) return type(value)=="string" and value~="" end
local function validActorId(value) return type(value)=="number" and value>0 and value%1==0 end
local function identity(r)
    local p=r.payload or {}
    return table.concat({tostring(r.actorUserId),tostring(r.roundId),tostring(r.stepId),tostring(p.action),tostring(p.partId),tostring(p.socketId),tostring(p.direction),tostring(p.presentation)},":")
end
local function free(entry)
    entry.status="AVAILABLE"; entry.ownerUserId=nil; entry.partId=nil; entry.orientation=nil; entry.lastActivity=nil
end
function Q03.new(options)
    assert(options and options.session and options.clock and options.context,"Q03 context dependencies are required")
    return setmetatable({session=options.session,actorResolver=options.actorResolver,clock=options.clock,context=options.context,rounds={},actions={},actionIdentities={},stateByRound={},currentRoundId=nil,expiryRevision=0},Q03)
end
function Q03:_actor(request)
    local actor=self.actorResolver and self.actorResolver(request) or request.actorUserId
    return actor and actor==request.actorUserId and self.session:IsPresent(actor)
end
function Q03:_canFinalize(actor)
    if not self.session:IsPresent(actor) then return false end
    return actor==self.session.phuongUserId or (not self.session:IsPresent(self.session.phuongUserId) and self.session.hostUserId~=0 and actor==self.session.hostUserId)
end
function Q03:_round(request) return self.stateByRound[request.roundId] end
function Q03:_committedParts(state) local r={}; for _,id in ipairs(PARTS) do if state.committed[id] then table.insert(r,id) end end; return r end
function Q03:_render(state)
    if not self.context.renderCraft then return end
    local ok,err=pcall(self.context.renderCraft,self.currentRoundId,state.committed,state.reservations,state.finalPresentation)
    if not ok then warn("PCW-22 craft presentation",err) end
end
function Q03:_view(roundId,actor,errorText)
    local state=self.stateByRound[roundId]; local actions,accepted,contributors,pieces={},{},{},{}
    local done=state and #self:_committedParts(state) or 0
    local held
    for _,id in ipairs(PARTS) do
        local socket=SOCKETS[id]; local entry=state and state.sockets[socket]
        local committed=state and state.committed[id]
        if committed then table.insert(accepted,id) end
        table.insert(pieces,{id=id,label=LABELS[id],socketId=socket,complete=committed~=nil,orientation=committed and committed.orientation or 0,busy=entry and entry.status=="RESERVED" or false})
        if entry and entry.status=="RESERVED" and entry.ownerUserId==actor then held={partId=id,label=LABELS[id],socketId=socket,orientation=entry.orientation,expiresAt=entry.lastActivity+15} end
        if state and state.status=="IN_PROGRESS" and not committed then
            local available=entry.status=="AVAILABLE"
            table.insert(actions,{id="reserve:"..id,label="Pick up "..LABELS[id],stepId="reserve:"..id,payload={action="reserve",socketId=socket,partId=id},enabled=available,
                reason=available and nil or entry.ownerUserId==actor and "Already selected. Turn it or place it below." or "A friend is using this socket.",groupId="parts",description="Fits the labeled "..LABELS[id].." socket. Preview before placing.",confirm=false})
        end
    end
    if state then for id in pairs(state.contributors) do table.insert(contributors,id) end end
    if held then
        for _,direction in ipairs({-1,1}) do
            local side=direction<0 and "left" or "right"
            table.insert(actions,{id="rotate-"..side..":"..held.partId,label="Turn "..held.label.." "..side.." · 90°",stepId="rotate-"..side..":"..held.partId,payload={action="rotate",socketId=held.socketId,direction=direction},enabled=true,groupId="placement",confirm=false})
        end
        table.insert(actions,{id="place:"..held.partId,label="Place "..held.label,stepId="place:"..held.partId,payload={action="place",socketId=held.socketId,partId=held.partId},enabled=true,groupId="placement",primary=true,description="Save this orientation in the shared miniature at both locations.",confirm=false})
        table.insert(actions,{id="cancel:"..held.partId,label="Put "..held.label.." back",stepId="cancel:"..held.partId,payload={action="cancel",socketId=held.socketId},enabled=true,groupId="placement",confirm=false})
    end
    if state and state.status=="COMPLETED" and not state.finalizationReceipt then
        local allowed=self:_canFinalize(actor)
        for _,option in ipairs({{id="lamp_on",label="A warm golden lamp"},{id="lamp_off",label="A quiet cream lamp"}}) do
            table.insert(actions,{id="finalize:"..option.id,label=option.label,stepId="finalize:"..option.id,payload={action="finalize",presentation=option.id},enabled=allowed,reason=allowed and nil or "Phuong adds the finishing touch. Andrew can help when Phuong is away.",groupId="finish",description="Choose how the completed keepsake is displayed. Your petal is already saved.",confirm={title="Finish the shared keepsake?",detail=option.label.." will appear at the booth and in the bedroom.",label="Save finishing touch"}})
        end
    end
    local finishing=state and state.status=="COMPLETED" and not state.finalizationReceipt
    local detail=finishing and "All six parts are placed. Find the bedroom keepsake for Phuong's finishing touch; Andrew can help when Phuong is away. The shared reward is already saved."
        or state and state.finalizationReceipt and "The shared keepsake is finished at the booth and in the bedroom. Your petal is saved; another round is optional."
        or held and (held.label.." selected · turn left or right, then Place. The golden socket and translucent piece are a preview.")
        or "Pick a labeled piece. Match its socket, turn it if you like, then Place. Friends can work on different pieces together."
    return {activityId="Q03",roundId=roundId,state=state and state.status or "NONE",title="A Tiny World of Her Own",instructions=detail,progress={done=done,total=#PARTS},availableActions=actions,
        acceptedStepIds=accepted,contributors=contributors,errorText=errorText,canReplay=state and state.status=="COMPLETED" or false,
        craft={pieces=pieces,held=held,finalPresentation=state and state.finalPresentation,needsFinishing=finishing==true},
        guide={headline=finishing and "Ready for Phuong's finishing touch" or state and state.finalizationReceipt and "Keepsake finished!" or "Build one tiny world together",detail=detail,nextAnchor=done==6 and "Q03BedroomDisplay" or "Q03FairCraft",
            groups={{id="placement",title="Turn and place your piece",detail="Each turn is a quarter turn. Any orientation fits its matching socket."},{id="parts",title="Choose a tiny part",detail="Accepted parts stay saved at both locations."},{id="finish",title="Phuong's finishing touch"}}}}
end
function Q03:CreateRound(request)
    assert(request and request.sessionId==self.session.sessionId and request.activityId=="Q03" and validId(request.roundId) and validActorId(request.actorUserId) and self:_actor(request),"invalid Q03 round")
    local previous=self.currentRoundId and self.stateByRound[self.currentRoundId]
    assert(not previous or (previous.status=="COMPLETED" and request.replay==true),"finish the shared round before an explicit replay")
    assert(not self.rounds[request.roundId],"round already exists")
    self.session:CreateRound("Q03",request.roundId,request.actorUserId,request.replay==true)
    local sockets={}; for _,socket in pairs(SOCKETS) do sockets[socket]={status="AVAILABLE"} end
    self.rounds[request.roundId]=true; self.currentRoundId=request.roundId
    local state={status="IN_PROGRESS",sockets=sockets,committed={},accepted={},contributors={},reservations={}}
    self.stateByRound[request.roundId]=state; self:_render(state)
    return self:GetView(request.actorUserId)
end
function Q03:Apply(request)
    assert(request and request.sessionId==self.session.sessionId and request.activityId=="Q03" and request.roundId==self.currentRoundId and validId(request.actionId) and validId(request.stepId) and validActorId(request.actorUserId),"invalid Q03 request")
    assert(self:_actor(request),"unauthenticated actor")
    if self.actions[request.actionId] then
        assert(self.actionIdentities[request.actionId]==identity(request),"action identity changed")
        local result=copy(self.actions[request.actionId]); result.view=self:GetView(request.actorUserId); return result
    end
    assert(not (self.session.receipts and self.session.receipts[request.actionId]) and not (self.session.acceptedSteps and self.session.acceptedSteps[request.actionId]),"action belongs to another receipt")
    local state=assert(self:_round(request),"unknown Q03 round")
    self:ExpireReservations(request.roundId)
    local p=request.payload or {}; local action=p.action; local result
    if action=="finalize" then
        assert(request.stepId=="finalize:"..tostring(p.presentation),"step does not match finishing choice")
        assert(state.status=="COMPLETED" and self:_canFinalize(request.actorUserId),"Phuong or available host must finalize the completed keepsake")
        assert(p.presentation=="lamp_on" or p.presentation=="lamp_off","invalid presentation")
        if state.finalizationReceipt then result=state.finalizationReceipt
        else
            state.finalPresentation=p.presentation
            result={ok=true,code="FINALIZED",receipt={receiptId="q03-final:"..request.roundId,roundId=request.roundId,presentation=p.presentation,actorUserId=request.actorUserId}}
            state.finalizationReceipt=result
        end
    else
        assert(state.status=="IN_PROGRESS","Q03 round is not active")
        if action=="reserve" then
            assert(SOCKETS[p.partId]==p.socketId and request.stepId=="reserve:"..tostring(p.partId),"part does not fit socket")
            local entry=assert(state.sockets[p.socketId],"unknown socket"); assert(entry.status=="AVAILABLE","socket is busy or placed")
            -- One selected piece per helper; changing cards releases the old preview.
            for socket,old in pairs(state.reservations) do if old.ownerUserId==request.actorUserId then free(old); state.reservations[socket]=nil end end
            entry.status="RESERVED"; entry.ownerUserId=request.actorUserId; entry.partId=p.partId; entry.orientation=0; entry.lastActivity=self.clock()
            state.reservations[p.socketId]=entry; result={ok=true,code="SELECTED",socketId=p.socketId,partId=p.partId,orientation=0}
        elseif action=="rotate" or action=="place" or action=="cancel" then
            local entry=assert(state.reservations[p.socketId],"choose that piece again; the selection was released")
            assert(entry.ownerUserId==request.actorUserId,"not reservation owner")
            if action=="rotate" then
                assert(p.direction==1 or p.direction==-1,"quarter-turn direction required")
                assert(request.stepId=="rotate-"..(p.direction<0 and "left" or "right")..":"..entry.partId,"step does not match rotation")
                entry.orientation=(entry.orientation+p.direction)%4; entry.lastActivity=self.clock(); result={ok=true,code="ROTATED",orientation=entry.orientation}
            elseif action=="place" then
                assert(entry.partId==p.partId and request.stepId=="place:"..entry.partId,"piece mismatch")
                local accepted=self.session:ApplyStep({sessionId=request.sessionId,activityId="Q03",roundId=request.roundId,stepId=entry.partId,actionId=request.actionId,actorUserId=request.actorUserId})
                state.committed[entry.partId]={socketId=p.socketId,orientation=entry.orientation,ownerUserId=request.actorUserId}
                state.accepted[entry.partId]=true; state.contributors[request.actorUserId]=true; entry.status="PLACED"; state.reservations[p.socketId]=nil
                result={ok=true,code="PLACED",step=accepted}
                if #self:_committedParts(state)==#PARTS then
                    result.completion=self.session:CompleteRound({sessionId=request.sessionId,activityId="Q03",roundId=request.roundId,actionId="complete:"..request.actionId,actorUserId=request.actorUserId})
                    result.receipt=result.completion; state.status="COMPLETED"
                end
            else
                assert(request.stepId=="cancel:"..entry.partId,"step does not match selection")
                free(entry); state.reservations[p.socketId]=nil; result={ok=true,code="RELEASED",released=true}
            end
        else error("unknown Q03 action") end
    end
    self.actions[request.actionId]=result; self.actionIdentities[request.actionId]=identity(request)
    self:_render(state)
    local reply=copy(result); reply.view=self:GetView(request.actorUserId); return reply
end
function Q03:ExpireReservations(roundId)
    local state=self.stateByRound[roundId or self.currentRoundId]
    if not state or state.status~="IN_PROGRESS" then return false end
    local changed=false; local current=self.clock()
    for socket,entry in pairs(state.reservations) do
        if current-entry.lastActivity>=15 then free(entry); state.reservations[socket]=nil; changed=true end
    end
    if changed then self.expiryRevision+=1; self:_render(state) end
    return changed
end
function Q03:ReleaseActor(actor,roundId)
    if roundId and roundId~=self.currentRoundId then return false end
    local state=self.stateByRound[self.currentRoundId]; if not state then return false end
    local changed=false
    for socket,entry in pairs(state.reservations) do if entry.ownerUserId==actor then free(entry); state.reservations[socket]=nil; changed=true end end
    if changed then self:_render(state) end
    return changed
end
function Q03:RecoveryState()
    return { roundId=self.currentRoundId, state=self.stateByRound[self.currentRoundId] }
end
function Q03:RecoverRelease(request)
    self.session:AssertRecovery(request)
    local state=self.stateByRound[self.currentRoundId]
    if state then
        for socket,entry in pairs(state.reservations) do free(entry); state.reservations[socket]=nil end
        self.expiryRevision+=1; self:_render(state)
    end
end
function Q03:RecoverRestart(request,newRoundId)
    self.session:RecoverCancel(request); self:RecoverRelease(request)
    self.currentRoundId=nil
    self:CreateRound({sessionId=request.sessionId,activityId="Q03",roundId=newRoundId,actorUserId=request.actorUserId})
    return newRoundId
end
function Q03:RecoverComplete(request)
    self.session:AssertRecovery(request); self:RecoverRelease(request)
    local state=assert(self.stateByRound[self.currentRoundId],"missing craft round")
    for _,part in ipairs(PARTS) do
        self.session:RecoverStep(request,part)
        state.committed[part]=state.committed[part] or {socketId=SOCKETS[part],orientation=0,ownerUserId=request.actorUserId}
        state.accepted[part]=true; state.sockets[SOCKETS[part]].status="PLACED"
    end
    state.contributors[request.actorUserId]=true
    local receipt=self.session:RecoverCompleteRound(request)
    state.status="COMPLETED"; self:_render(state)
    return receipt
end
function Q03:GetView(actor)
    self:ExpireReservations(self.currentRoundId)
    return self:_view(self.currentRoundId,actor)
end
Q03.PARTS=PARTS; Q03.SOCKETS=SOCKETS
return Q03
]=],
["roblox/mvp/server/activities/Q04.luau"] = [=[local Q04 = {}
Q04.__index = Q04

Q04.ActivityId = "Q04"
Q04.PassageIds = { "small-worlds", "night-pages", "next-chapter" }
Q04.Highlights = { "small-detail", "comforting-moment", "shared-spark" }
Q04.Reactions = { "moved", "cozy", "curious", "smile" }
Q04.Bookmarks = { "ribbon", "pressed-flower", "star-tab" }
local HIGHLIGHT_LABELS = { ["small-detail"]="Small detail", ["comforting-moment"]="Comforting moment", ["shared-spark"]="Shared spark" }
local REACTION_LABELS = {moved="Moved",cozy="Cozy",curious="Curious",smile="Made me smile"}
local BOOKMARK_LABELS = {ribbon="Ribbon",["pressed-flower"]="Pressed flower",["star-tab"]="Star tab"}

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
    local result = { highlights = {}, reaction = draft.reaction, bookmark = draft.bookmark, note = draft.note or "", passageId = draft.passageId, revision = draft.revision, savedAt = draft.savedAt }
    for key, value in pairs(draft.highlights) do result.highlights[key] = value end
    return result
end

function Q04.new(options)
    assert(options and options.session and options.clock, "session and clock are required")
    return setmetatable({ session = options.session, clock = options.clock, context = options.context or {}, drafts = {}, lastPassage = {}, activeRoundId = nil, roundComplete = false, usedActions = {}, actionIdentities = {}, contributors = {} }, Q04)
end

Q04.new = Q04.new
Q04.Module = Q04

function Q04:_draft(actorUserId, passageId)
    local key = tostring(actorUserId) .. ":" .. passageId
    self.drafts[key] = self.drafts[key] or { passageId = passageId, revision = 0, highlights = {}, reaction = nil, bookmark = nil, note = "" }
    return self.drafts[key], key
end

function Q04:CreateRound(request)
    assert(request.sessionId == self.session.sessionId and request.activityId == self.ActivityId and request.roundId and request.actorUserId and self.session:IsPresent(request.actorUserId), "invalid Q04 round")
    assert(self.activeRoundId == nil or self.roundComplete, "Q04 round is active")
    assert(self.activeRoundId == nil or request.replay == true, "replay must be explicit")
    self.session:CreateRound(self.ActivityId, request.roundId, request.actorUserId, request.replay == true)
    self.activeRoundId, self.roundComplete = request.roundId, false
    return { activityId = self.ActivityId, roundId = request.roundId, state = "IN_PROGRESS" }
end

local function identity(request)
    local p=request.payload or {}
    -- Compare field values directly, including private text, with no delimiter ambiguity.
    return {actor=request.actorUserId,round=request.roundId,step=request.stepId,passage=p.passageId,revision=p.revision,
        reaction=p.reaction,bookmark=p.bookmark,note=p.note,complete=p.complete,highlights=p.highlights and table.concat(p.highlights,"|")}
end
local function same(a,b)
    for k,v in pairs(a) do if b[k]~=v then return false end end
    for k,v in pairs(b) do if a[k]~=v then return false end end
    return true
end
function Q04:_render(draft)
    local hook=self.context.renderReading
    if not hook then return end
    local highlight
    for _,id in ipairs(self.Highlights) do if draft.highlights[id] then highlight=HIGHLIGHT_LABELS[id]; break end end
    local summary={bookmark=draft.bookmark,bookmarkLabel=BOOKMARK_LABELS[draft.bookmark],reactionLabel=REACTION_LABELS[draft.reaction] or "A quiet page",highlightLabel=highlight,
        acknowledgement=draft.reaction and "Reaction saved · "..REACTION_LABELS[draft.reaction] or highlight and "Highlight saved · "..highlight or "Reading choice saved"}
    -- Deliberately omit actor ID, private note and all user-authored text.
    local ok,err=pcall(hook,summary); if not ok then warn("PCW-22 reading presentation",err) end
end

function Q04:Apply(request)
    assert(request and request.sessionId == self.session.sessionId and request.activityId == self.ActivityId and request.roundId == self.activeRoundId and type(request.actionId)=="string" and request.actionId~="" and self.session:IsPresent(request.actorUserId), "invalid Q04 action")
    if self.usedActions[request.actionId] then
        assert(same(self.actionIdentities[request.actionId],identity(request)),"action identity changed")
        local old=self.usedActions[request.actionId]
        return {ok=true,code=old.code,receipt=old.receipt,draft=copyDraft(self:_draft(request.actorUserId,request.payload.passageId)),view=self:GetView(request.actorUserId)}
    end
    assert(not (self.session.receipts and self.session.receipts[request.actionId]) and not (self.session.acceptedSteps and self.session.acceptedSteps[request.actionId]), "action belongs to another receipt")
    local payload = request.payload or {}
    local passageId = payload.passageId
    assert(contains(self.PassageIds, passageId), "unknown passage")
    local previous,key = self:_draft(request.actorUserId, passageId)
    local draft = copyDraft(previous)
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
    assert(payload.highlights or payload.reaction or payload.bookmark or payload.note~=nil or payload.complete==true,"reading choice required")
    if payload.complete == true then assert(next(draft.highlights) ~= nil and draft.reaction and draft.bookmark, "reading selections incomplete") end
    draft.revision += 1
    local accepted
    if not self.roundComplete then
        accepted = self.session:ApplyStep({ sessionId = self.session.sessionId, activityId = self.ActivityId, roundId = request.roundId, stepId = (request.stepId or "draft") .. ":" .. tostring(request.actorUserId) .. ":" .. passageId, actionId = request.actionId, actorUserId = request.actorUserId })
    else
        accepted = { activityId = self.ActivityId, roundId = request.roundId, stepId = "post-close-draft", actorUserId = request.actorUserId, acknowledgementOnly = true }
    end
    self.contributors[request.actorUserId] = true
    local receipt
    if payload.complete == true and not self.roundComplete then
        receipt = self.session:CompleteRound({ sessionId = self.session.sessionId, activityId = self.ActivityId, roundId = request.roundId, actionId = request.actionId .. ":complete", actorUserId = request.actorUserId })
        self.roundComplete = true
    end
    if payload.complete == true then draft.savedAt=self.clock() end
    self.drafts[key]=draft; self.lastPassage[request.actorUserId]=passageId
    self:_render(draft)
    local result = { ok = true, code = receipt and "COMPLETED" or (self.roundComplete and "ACKNOWLEDGED" or "SAVED"), receipt = receipt, draft = copyDraft(draft), view = self:GetView(request.actorUserId) }
    self.usedActions[request.actionId] = result
    self.actionIdentities[request.actionId] = identity(request)
    return result
end

function Q04:RecoveryState()
    return { roundId=self.activeRoundId, complete=self.roundComplete }
end
function Q04:RecoverComplete(request)
    self.session:AssertRecovery(request)
    self.session:RecoverStep(request,"host-recovery")
    local receipt=self.session:RecoverCompleteRound(request)
    self.roundComplete=true
    -- Shared recovery never invents anyone's reading choices or private note.
    local hook=self.context.renderReading
    if hook then
        local ok,err=pcall(hook,{acknowledgement="Shared reading petal restored by a host",reactionLabel="Reading together"})
        if not ok then warn("PCW-24 reading recovery presentation",err) end
    end
    return receipt
end

function Q04:GetView(actorUserId)
    local roundId = self.activeRoundId
    local passageId = self.lastPassage[actorUserId] or "small-worlds"
    local currentDraft = self:_draft(actorUserId, passageId)
    local function choices(ids, labels, stepId, field)
        local result = {}
        for index, id in ipairs(ids) do
            local payload = { passageId = passageId, [field] = id, revision=currentDraft.revision }
            if field == "highlight" then payload.highlights = { id }; payload.highlight = nil end
            local selected=field=="highlight" and currentDraft.highlights[id]==true or currentDraft[field]==id
            table.insert(result, { id = id, label = labels[index], stepId = stepId, payload = payload, enabled = true, selected=selected, groupId=stepId, confirm=false,
                description=selected and "Saved for you in this session" or "Tap this choice, then use the action above to save it." })
        end
        return result
    end
    local actions = {}
    for _, action in ipairs(choices(self.Highlights, { "Small detail", "Comforting moment", "Shared spark" }, "highlight", "highlight")) do table.insert(actions, action) end
    for _, action in ipairs(choices(self.Reactions, { "Moved", "Cozy", "Curious", "Made me smile" }, "reaction", "reaction")) do table.insert(actions, action) end
    for _, action in ipairs(choices(self.Bookmarks, { "Ribbon", "Pressed flower", "Star tab" }, "bookmark", "bookmark")) do table.insert(actions, action) end
    local ready = next(currentDraft.highlights) ~= nil and currentDraft.reaction ~= nil and currentDraft.bookmark ~= nil
    table.insert(actions, { id = "save", label = ready and (self.roundComplete and "Save my reading choices" or "Save reading + shared petal") or "Choose a highlight, reaction, and bookmark", stepId = "reading", payload = { passageId = passageId, complete = true, revision=currentDraft.revision }, enabled = ready, primary=ready and not self.roundComplete, groupId="save", reason = ready and nil or "Reading choices are incomplete" })
    local highlighted={}; for _,id in ipairs(self.Highlights) do if currentDraft.highlights[id] then table.insert(highlighted,HIGHLIGHT_LABELS[id]) end end
    return { activityId = self.ActivityId, roundId = roundId, state = self.roundComplete and "ROUND_COMPLETE" or "IN_PROGRESS", title = "One More Chapter", instructions = "Read at your own pace. Choose a highlight, a reaction, and a bookmark. A private reading note is optional.",
        reading = { title = "A quiet page", text = self.Passages[passageId], passageId = passageId }, draft=copyDraft(currentDraft),
        readingSummary={highlights=highlighted,reaction=REACTION_LABELS[currentDraft.reaction],bookmark=BOOKMARK_LABELS[currentDraft.bookmark]},
        noteAction={id="save-note",label="Save my private reading note",stepId="note",payload={passageId=passageId,revision=currentDraft.revision},enabled=true,confirm=false},
        guide={headline=self.roundComplete and "Shared reading petal saved" or "A quiet page together",detail=self.roundComplete and "Your choices are still yours. Friends can save their own reading without another reward; replay is optional." or "Read the passage, then save one highlight, reaction and bookmark. Choices stay saved when you close.",
            groups={{id="highlight",title="1 · What stood out?"},{id="reaction",title="2 · How did it feel?"},{id="bookmark",title="3 · Choose your bookmark"},{id="save",title="Save the shared reading"}}},
        progress = { done = self.roundComplete and 1 or 0, total = 1 }, availableActions = actions, acceptedStepIds = {}, contributors = self.contributors, busyReason = nil, errorText = nil, canReplay = self.roundComplete }
end

return Q04
]=],
["roblox/mvp/server/activities/Q05.luau"] = [=[local Config = require(script.Parent.Parent.Parent.shared.Config)
local Catalog = require(script.Parent.Parent.Parent.shared.FigureCatalog)
local Q05 = {}; Q05.__index = Q05
local Figures = {}; for _, entry in ipairs(Catalog.Figures) do table.insert(Figures, entry.id) end
local function clone(map) local out = {}; for k, v in pairs(map) do out[k] = v end; return out end
local function identity(request)
	local payload = request.payload
	return { actor = request.actorUserId, round = request.roundId, step = request.stepId,
		figure = payload.figureId, wish = payload.wishVersion, roll = payload.rollNumber }
end
local function same(a, b)
	return a.actor == b.actor and a.round == b.round and a.step == b.step and a.figure == b.figure and a.wish == b.wish and a.roll == b.roll
end
function Q05.new(ctx)
	assert(ctx and ctx.session, "Q05 requires session")
	local random = ctx.random or math.random
	local weighted = function()
		local value, cursor = random(), 0
		for _, entry in ipairs(Catalog.Figures) do cursor += entry.probability; if value < cursor then return entry.id end end
		return Config.SecretFigureId
	end
	return setmetatable({ ctx = ctx, session = ctx.session, clock = ctx.clock or os.clock,
		outcome = ctx.outcome or weighted, roundId = nil, wanted = nil, misses = 0, rolls = 0,
		wishVersion = 0, fulfilled = false, petalAwarded = false, collection = {}, receipts = {},
		latestResult = nil, purchasing = false }, Q05)
end
function Q05:_canSpend(actor)
	return self.session:IsPresent(actor) and self.session:CanSpend(actor, self.session.presence)
end
function Q05:_fail(actor, code, message)
	return { ok = false, code = code, message = message, view = self:GetView(actor) }
end
function Q05:_render()
	-- A display failure cannot roll back or repeat an authoritative purchase.
	if self.ctx.feedback then
		local ok, err = pcall(self.ctx.feedback.Render, self.ctx.feedback, self.wanted, self.fulfilled, self.collection, self.latestResult, self.petalAwarded)
		if not ok then warn("PCW-21 Labubu display needs attention", err) end
	end
end
function Q05:CreateRound(request)
	assert(request and request.activityId == "Q05" and request.roundId and not self.roundId, "invalid Q05 round")
	self.session:CreateRound("Q05", request.roundId, request.actorUserId)
	self.roundId = request.roundId; self:_render()
	return { activityId = "Q05", roundId = self.roundId, state = "READY" }
end
function Q05:_draw()
	-- The selected secret has the same fifth-roll guarantee as a regular.
	if self.misses >= Config.WantedGuaranteeRoll - 1 then return self.wanted end
	local figure = self.outcome({ figures = Figures, wantedFigureId = self.wanted, misses = self.misses })
	assert(Catalog.ById[figure], "Outcome provider returned an unknown figure")
	return figure
end
function Q05:_completeWanted(actor, actionId)
	if self.petalAwarded or self.session.petals.Q05 then self.petalAwarded = true; return false end
	self.session:ApplyStep({ sessionId = self.session.sessionId, activityId = "Q05", roundId = self.roundId,
		stepId = "wanted-fulfilled", actionId = "q05-step:" .. actionId, actorUserId = actor })
	local receipt = self.session:CompleteRound({ sessionId = self.session.sessionId, activityId = "Q05",
		roundId = self.roundId, actionId = "q05-complete:" .. actionId, actorUserId = actor })
	self.petalAwarded = true; return receipt.petalGranted == true
end
function Q05:Apply(request)
	local actor = type(request) == "table" and request.actorUserId or nil
	if type(request) ~= "table" or request.sessionId ~= self.session.sessionId or request.activityId ~= "Q05"
		or not self.roundId or request.roundId ~= self.roundId or type(request.actionId) ~= "string" or request.actionId == ""
		or type(request.payload) ~= "table" or not actor then
		return self:_fail(actor, "STALE_WISH", "Reopen the Labubu booth to see the current wish and balance.")
	end
	local key = identity(request)
	local previous = self.receipts[request.actionId]
	if previous then
		if not same(previous.identity, key) then return self:_fail(actor, "ACTION_CHANGED", "That request already saved a different choice. Reopen the booth.") end
		return { ok = true, code = "DUPLICATE", receipt = clone(previous.receipt), view = self:GetView(actor) }
	end
	if not self:_canSpend(actor) then
		return self:_fail(actor, "PHUONGS_CHOICE", "Phuong chooses her wish and opens the boxes. Andrew can help only while she is away; friends can earn the shared fund together.")
	end
	if self.purchasing then return self:_fail(actor, "ROLL_PENDING", "Your last box is being saved. Wait for its result before opening another.") end
	if request.stepId ~= "select-wanted" and request.stepId ~= "roll" then return self:_fail(actor, "BAD_CHOICE", "Choose a figure card, confirm the wish, then use Get a Labubu.") end
	if request.payload.wishVersion ~= self.wishVersion then return self:_fail(actor, "WISH_CHANGED", "The wish changed. Review the current wish before confirming anything else.") end
	-- SessionService uses a shared action namespace. Never reuse a purchase,
	-- completion or another activity's accepted action as a fresh Q05 mutation.
	for _, actionId in ipairs({ request.actionId, "purchase:" .. request.actionId, "q05-step:" .. request.actionId, "q05-complete:" .. request.actionId }) do
		if self.session.receipts[actionId] or self.session.acceptedSteps[actionId] then
			return self:_fail(actor, "ACTION_USED", "That choice was already saved. Reopen the booth to continue safely.")
		end
	end
	local round = self.session.rounds[self.roundId]
	if not round or round.activityId ~= "Q05" or (round.state ~= "IN_PROGRESS" and not self.petalAwarded) then
		return self:_fail(actor, "ROUND_CHANGED", "The booth is refreshing. Reopen it before using the shared fund.")
	end
	if request.stepId == "select-wanted" then
		if self.wanted and not self.fulfilled then return self:_fail(actor, "WISH_LOCKED", "Your confirmed wish stays selected until you receive it. Every box brings the guarantee closer.") end
		if not Catalog.ById[request.payload.figureId] then return self:_fail(actor, "UNKNOWN_FIGURE", "Choose one of the seven labeled figure cards.") end
		self.wanted = request.payload.figureId; self.wishVersion += 1; self.misses = 0; self.rolls = 0
		self.fulfilled = (self.collection[self.wanted] or 0) > 0
		local petal = self.fulfilled and self:_completeWanted(actor, request.actionId) or false
		local receipt = { actionId = request.actionId, wantedFigureId = self.wanted, wantedLabel = Catalog.Label(self.wanted),
			wishVersion = self.wishVersion, ownedFulfillment = self.fulfilled, petalGranted = petal }
		self.receipts[request.actionId] = { identity = key, receipt = receipt }; self:_render()
		return { ok = true, code = self.fulfilled and "WANTED_ALREADY_OWNED" or "WANTED_LOCKED", receipt = clone(receipt), view = self:GetView(actor) }
	end
	if not self.wanted then return self:_fail(actor, "WISH_REQUIRED", "Choose a figure card and Confirm wish before spending the shared fund.") end
	if self.fulfilled then return self:_fail(actor, "WISH_FULFILLED", "Your wish is already in the collection. The birthday goal is complete; another wish is optional.") end
	if request.payload.rollNumber ~= self.rolls + 1 then return self:_fail(actor, "ROLL_CHANGED", "That box was already handled. Review the saved result before choosing another box.") end
	if self.session.fundBalance < Config.RollCost then return self:_fail(actor, "INSUFFICIENT_FUND", "A box needs 20 from the shared fund. Help with another activity, then come back together.") end
	local drew, figure = pcall(self._draw, self)
	if not drew or not Catalog.ById[figure] then return self:_fail(actor, "BOX_UNAVAILABLE", "This box could not be prepared. Your shared fund has not been spent.") end
	local awardedAt = self.clock()
	-- No yields/external presentation calls within this transaction. Expected
	-- wish/roll guards also reject distinct request IDs from one stale UI state.
	self.purchasing = true
	local purchase = self.session:CommitPurchase({ actionId = request.actionId, actorUserId = actor, cost = Config.RollCost, awardFigureId = figure })
	self.collection[figure] = (self.collection[figure] or 0) + 1; self.rolls += 1
	local wanted = figure == self.wanted
	if wanted then self.fulfilled = true else self.misses += 1 end
	local petal = wanted and self:_completeWanted(actor, request.actionId) or false
	local receipt = { sessionId = purchase.sessionId, activityId = "Q05", roundId = self.roundId, actionId = request.actionId,
		receiptId = purchase.receiptId, debitApplied = true, cost = Config.RollCost,
		awardFigureId = figure, awardLabel = Catalog.Label(figure), wantedFigureId = self.wanted, wantedLabel = Catalog.Label(self.wanted),
		wantedFulfilled = wanted, petalGranted = petal, revealSkippable = true, awardedAt = awardedAt,
		wishVersion = self.wishVersion, rollNumber = self.rolls, copies = self.collection[figure] }
	self.receipts[request.actionId] = { identity = key, receipt = receipt }
	self.latestResult = receipt; self.pendingReveal = receipt -- Compatibility; no reveal acknowledgement changes awards.
	self.purchasing = false; self:_render()
	return { ok = true, code = "AWARDED", receipt = clone(receipt), view = self:GetView(actor) }
end
function Q05:RecoveryState()
	return { roundId=self.roundId,wanted=self.wanted,fulfilled=self.fulfilled,wishVersion=self.wishVersion,
		rolls=self.rolls,misses=self.misses,collection=clone(self.collection),purchasing=self.purchasing,recovered=self.recoveryReceipt~=nil }
end
function Q05:RecoverComplete(request)
	self.session:AssertRecovery(request)
	if self.recoveryReceipt then return clone(self.recoveryReceipt) end
	assert(request.roundId==self.roundId and Catalog.ById[self.wanted] and not self.fulfilled and not self.purchasing,"select an unfulfilled wish normally first")
	if not self.session.petals.Q05 then self.session:RecoverStep(request,"wanted-fulfilled") end
	local completion=self.session:RecoverCompleteRound(request)
	self.collection[self.wanted]=(self.collection[self.wanted] or 0)+1
	self.fulfilled,self.petalAwarded=true,true
	-- Recovery does not consume a paid roll, a miss, or the fifth-box guarantee.
	local receipt={sessionId=self.session.sessionId,activityId="Q05",roundId=self.roundId,actionId=request.actionId,
		receiptId="host-wish:"..self.session.sessionId,recovery=true,debitApplied=false,cost=0,
		awardFigureId=self.wanted,awardLabel=Catalog.Label(self.wanted),wantedFigureId=self.wanted,wantedLabel=Catalog.Label(self.wanted),
		wantedFulfilled=true,petalGranted=completion.petalGranted,fundRewardGranted=0,revealSkippable=true,awardedAt=self.clock(),
		wishVersion=self.wishVersion,rollNumber=self.rolls,copies=self.collection[self.wanted]}
	self.recoveryReceipt=receipt; self.latestResult=receipt; self.pendingReveal=receipt; self:_render()
	return clone(receipt)
end
function Q05:ReleaseActor(_actor, _roundId)
	-- Preview/reveal progress is local only. Committed wishes, collection,
	-- receipts and debits survive Close/reset/lobby/rejoin for this server.
end
function Q05:GetView(actor)
	local snapshot = self.session:GetSnapshot()
	local controller = self:_canSpend(actor)
	local storyComplete = snapshot.petals.Q05 == true
	local selectable = controller and (not self.wanted or self.fulfilled) and not self.purchasing
	local actions, figures, total = {}, {}, 0
	for _, entry in ipairs(Catalog.Figures) do
		local count = self.collection[entry.id] or 0; total += count
		table.insert(figures, { id = entry.id, label = entry.label, secret = entry.secret, odds = entry.odds, copies = count, selected = self.wanted == entry.id })
		if selectable then
			table.insert(actions, { id = "select-" .. entry.id, label = "Confirm wish · " .. entry.label, stepId = "select-wanted",
				payload = { figureId = entry.id, wishVersion = self.wishVersion }, enabled = true, groupId = "wish",
				description = "Previewing is free. Confirming locks this wish until it is in the collection.",
				confirm = { title = "Confirm " .. entry.label .. " as your wish?", detail = storyComplete
					and "This is optional collecting. Your petal and cake progress stay saved. This wish locks until received; each box costs 20."
					or "This wish locks until you receive it. Each box costs 20 from the shared fund; your wish is guaranteed by box five, including the secret.", label = "Confirm wish" } })
		end
	end
	if controller and self.wanted and not self.fulfilled then
		table.insert(actions, { id = "roll", label = "Get a Labubu - 20", stepId = "roll", primary = true, groupId = "open",
			payload = { wishVersion = self.wishVersion, rollNumber = self.rolls + 1 }, enabled = snapshot.fundBalance >= Config.RollCost and not self.purchasing,
			reason = self.purchasing and "Your last box is being saved." or "Help with another activity to reach 20 in the shared fund.",
			description = "Spend 20 together. Your figure is saved before its skippable reveal.",
			confirm = { title = "Open a box for " .. Catalog.Label(self.wanted) .. "?", detail = "Use 20 from the shared fund of " .. tostring(snapshot.fundBalance) .. ". The figure is saved immediately, even if you close or skip.", label = "Spend 20 and open" } })
	end
	local nextActivity
	for _, id in ipairs(Config.ActivityIds) do if id ~= "Q05" and snapshot.petals[id] ~= true then nextActivity = id; break end end
	if not nextActivity then nextActivity = storyComplete and "Cake" or nil end
	local remaining = self.fulfilled and 0 or math.max(0, Config.WantedGuaranteeRoll - self.misses)
	local controlMessage = controller and (actor == self.session.phuongUserId and "Your wish, with help from your friends." or "Andrew can help choose and open while Phuong is away.")
		or "Phuong chooses her wish and opens the boxes. Friends help earn the shared fund; Andrew can help while Phuong is away."
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
    local person = self.participants[actor]
    local message
    if hostAction then
        if self.startedAt then return reject("CakeAlreadyStarted", "The celebration is already underway. It cannot be restarted or cancelled.") end
        self.delayed = operation == "Delay"
        if self.session:AllPetalsComplete() then self.phase = self.delayed and "READY" or "GATHERING" end
        message = self.delayed and "Gathering paused. A host can arm Phuong's seat when everyone is ready." or "Phuong's seat is armed for the birthday celebration."
    elseif operation == "RecoverStart" then
        if not self.session:AllPetalsComplete() then return reject("CakeLocked", "Finish all six petals before recovering the celebration.") end
        if not self:_begin(actor, true) then return reject("CakeAlreadyStarted", "The celebration already started; use Advance cake only if needed.") end
        message = "Host recovery started the birthday celebration."
    elseif operation == "Cut" or operation == "RecoverCut" then
        if operation == "Cut" and actor ~= self.session.phuongUserId then return reject("CakePermission", "Phuong makes the first cut. Andrew can use explicit host recovery if needed.") end
        if self.cutAt then return reject("CakeAlreadyCut", "The cake is already cut. Everyone may take a slice.") end
        if operation == "RecoverCut" and self.phase == "CELEBRATING" then
            self.endsAt = now
            self.phase = "CAKE_READY"
        end
        if self.phase ~= "CAKE_READY" then return reject("CakeNotReady", "The birthday celebration comes before the first cut.") end
        self.cutAt, self.cutBy = now, actor
        self.recoveredCut = operation == "RecoverCut"
        message = "Phuong's birthday cake is cut! Everyone may take a slice."
    elseif operation == "TakeSlice" then
        if not self.cutAt then return reject("CakeNotCut", "Wait for Phuong's first cut, then take a slice.") end
        if person then return reject("CakeSliceSaved", "Your slice is already saved. Enjoy a bite.") end
        self.participants[actor] = { takenAt = now, biteCount = 0 }
        message = "Your slice is ready. Enjoy a bite, then stay for photos or explore."
    elseif operation == "Eat" or operation == "Bite" then
        if not self.cutAt or not person then return reject("CakeNoSlice", "Take your slice before enjoying a bite.") end
        if operation == "Eat" and person.eatenAt then return reject("CakeAlreadyEaten", "Your cake moment is saved. Another bite is just for fun.") end
        if operation == "Bite" and not person.eatenAt then return reject("CakeFirstBite", "Choose Enjoy my cake for your first bite.") end
        if person.lastBiteAt and now - person.lastBiteAt < 1.6 then return reject("CakeBiteBusy", "Enjoy that bite first.") end
        person.eatenAt = person.eatenAt or now
        person.lastBiteAt = now
        person.biteCount += 1
        self.phase = "EATING"
        message = operation == "Bite" and "Another little birthday bite." or "Cake enjoyed! Stay for photos, or keep exploring together."
    end
    self.revision += 1
    local receipt = { sessionId = self.session.sessionId, activityId = "Cake", actionId = request.actionId,
        actorUserId = actor, action = original, generation = request.generation, recovery = recovery,
        acceptedAt = now, message = message }
    self.receipts[request.actionId] = receipt
    self.session.receipts[request.actionId] = receipt
    self:Tick()
    return { ok = true, code = "CakeAccepted", message = message, receipt = receipt }
end

function CakeService:Apply(request)
    return self:_apply(request, false)
end

-- PCW-24 only: after HostService authenticates explicit Override + confirmation.
-- Still authenticates the configured host, current generation and six petals.
-- Both operations advance monotonically; neither can reset this session.
function CakeService:Recover(request)
    return self:_apply(request, true)
end

function CakeService:GetState(actor)
    local person = self.participants[actor]
    local state = {
        phase = self.phase, finaleState = self.phase, generation = self.generation, revision = self.revision,
        unlockedAt = self.unlockedAt, startedAt = self.startedAt, endsAt = self.endsAt,
        duration = DURATION, cutAt = self.cutAt, delayed = self.delayed, armed = self.phase == "GATHERING",
        invitation = self.phase ~= "LOCKED", availableActions = {},
        sliceTaken = person ~= nil, hasEaten = person ~= nil and person.eatenAt ~= nil,
        biteCount = person and person.biteCount or 0,
        scene = self.runtime.scene and self.runtime.scene() or nil,
        guide = { nextAnchor = "FinalePatio" },
    }
    local details = {
        LOCKED = "Complete all six petals to gather for Phuong's birthday cake.",
        READY = "The patio is ready. A host has paused the gathering so friends can find their seats.",
        GATHERING = "Friends, choose a guest seat first. Phuong, sit in the marked west end seat when you are ready; your celebration starts automatically.",
        CELEBRATING = "Happy Birthday, Phuong! Enjoy the moment together. The optional camera view has its own Skip / Return.",
        CAKE_READY = self.cutAt and "The first cut is made! Everyone can take their own slice." or "Phuong, make the first cut whenever you are ready.",
        EATING = "Enjoy your cake together. Another bite is just for fun; photos and exploring stay open.",
    }
    state.guide.detail = details[self.phase]
    local present = actor and self:_present(actor)
    local atPatio = present and self.runtime.isAtPatio and self.runtime.isAtPatio(actor) == true
    state.atPatio = atPatio == true
    local function add(action, label, enabled, confirm)
        table.insert(state.availableActions, { id = action, action = action, label = label, generation = self.generation,
            enabled = enabled == true, reason = not enabled and "Walk to the birthday table first." or nil, confirm = confirm })
    end
    if present and self:_host(actor) and not self.startedAt then
        if self.delayed then add("Arm", "Arm Phuong's seat", true, { title = "Ready to gather?", detail = "If Phuong is already in her seat and six petals are complete, the celebration starts now.", label = "Arm the seat" })
        else add("Delay", "Give friends more time", true, { title = "Pause the gathering?", detail = "This pauses the seat trigger until a host arms it again.", label = "Pause gathering" }) end
    end
    if self.phase == "CAKE_READY" and not self.cutAt and actor == self.session.phuongUserId and present then
        add("Cut", "Make the first cut", atPatio, { title = "Cut your birthday cake?", detail = "Everyone will be able to take a slice.", label = "Cut the cake" })
    end
    if self.cutAt and present then
        if not person then add("TakeSlice", "Take my slice", atPatio)
        elseif not person.eatenAt then add("Eat", "Enjoy my cake", atPatio)
        else add("Bite", "Another little bite", atPatio) end
    end
    return state
end

return CakeService
]=],
["roblox/mvp/server/CozyAudio.luau"] = [=[-- Permanent export of live CozyAudio, with nonblocking dependencies and dedupe.
-- Cosmetic only: Accepted never throws into Main's authoritative action path.
local SoundService = game:GetService("SoundService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")
local Audio = {}
local effects = {
    SoftClick = {id="88442833509532",volume=.18}, SuccessChime = {id="103516326607012",volume=.22},
    JasperBark = {id="135016436724006",volume=.25}, JasperPant = {id="6463651038",volume=.10},
}
local shared = script.Parent.Parent:FindFirstChild("shared")
local configModule = shared and shared:FindFirstChild("AudioConfig")
if configModule and configModule:IsA("ModuleScript") then
    local ok, config = pcall(require, configModule)
    if ok and type(config) == "table" and type(config.Effects) == "table" then effects = config.Effects end
end
local destroyed, lastBark, elapsed, nextPant = false, -math.huge, 0, math.random(25,45)
local seen, seenCount, live, ownedAttachments, connections = {}, 0, {}, {}, {}
local function anchors()
    local world = workspace:FindFirstChild("CozyWorld_Draft01")
    local mvp = world and world:FindFirstChild("MVP")
    return mvp and mvp:FindFirstChild("Anchors")
end
local function template(name)
    local spec = effects[name]
    if not spec then return nil end
    local folder = SoundService:FindFirstChild("CozySoundEffects")
    if not folder then
        folder = Instance.new("Folder"); folder.Name = "CozySoundEffects"; folder.Parent = SoundService
    end
    local sound = folder:FindFirstChild(name)
    if sound and not sound:IsA("Sound") then return nil end
    if not sound then
        sound = Instance.new("Sound"); sound.Name = name; sound.Parent = folder
    end
    sound.SoundId, sound.Volume = "rbxassetid://"..spec.id, spec.volume
    sound.Looped, sound.RollOffMinDistance, sound.RollOffMaxDistance = false, 6, 45
    sound.PlayOnRemove = false
    sound:SetAttribute("CozySoundEffect", true)
    return sound
end
local function emit(name, host, lifetime)
    if destroyed or not host or not host:IsA("BasePart") then return end
    local sound = template(name)
    if not sound then return end
    local attachment = host:FindFirstChild("JasperAudioEmitter")
    if attachment and not attachment:IsA("Attachment") then return end
    if not attachment then
        attachment = Instance.new("Attachment"); attachment.Name = "JasperAudioEmitter"; attachment.Parent = host
        ownedAttachments[attachment] = true
    end
    local copy = sound:Clone()
    copy:SetAttribute("CozySoundEffect", true)
    copy:SetAttribute("CozyAutoPlay", true)
    copy:SetAttribute("CozyEmittedAt", workspace:GetServerTimeNow())
    copy:SetAttribute("CozyLifetime", lifetime)
    copy.Parent = attachment
    live[copy] = true
    -- Each listener plays this one short-lived emission only after its bounded
    -- preload succeeds. Failed asset access never causes repeated server Play.
    Debris:AddItem(copy, lifetime)
end
function Audio.Accepted(request, result)
    if destroyed or type(request) ~= "table" or type(result) ~= "table" then return end
    if request.activityId ~= "Q02" or result.ok == false or string.lower(tostring(result.code)) == "duplicate" then return end
    if type(request.actionId) ~= "string" or request.actionId == "" then return end
    local step = request.stepId
    if type(step) ~= "string" then return end
    if step ~= "greet" and step ~= "pet" and step ~= "greenie" and not string.match(step or "", "^fetch%d$") then return end
    local id = tostring(request.sessionId)..":"..request.actionId
    if seen[id] or seenCount >= 4096 then return end
    seen[id], seenCount = true, seenCount + 1 -- Remember even when cooldown suppresses the sound.
    if os.clock()-lastBark < 4 then return end
    lastBark = os.clock()
    pcall(function()
        local root = anchors()
        emit("JasperBark", root and root:FindFirstChild(step == "greet" and "JasperBedroomStart" or "JasperFetchYard"), 5)
    end)
end
function Audio.Destroy()
    if destroyed then return end
    destroyed = true
    for _, connection in ipairs(connections) do connection:Disconnect() end
    for sound in pairs(live) do if sound.Parent then sound:Destroy() end end
    for attachment in pairs(ownedAttachments) do if attachment.Parent then attachment:Destroy() end end
    table.clear(live); table.clear(ownedAttachments); table.clear(seen)
end
-- Missing containers/anchors are looked up when needed, never waited on.
pcall(function() for name in pairs(effects) do template(name) end end)
table.insert(connections, RunService.Heartbeat:Connect(function(dt)
    if destroyed then return end
    elapsed += dt
    if elapsed < nextPant then return end
    elapsed, nextPant = 0, math.random(25,45)
    for sound in pairs(live) do if not sound.Parent then live[sound] = nil end end
    if os.clock()-lastBark < 8 then return end
    pcall(function()
        local root = anchors()
        if not root then return end
        for _, player in ipairs(Players:GetPlayers()) do
            local body = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            if body and player:GetAttribute("BirthdayLocation") == "World" then
                for _, name in ipairs({"JasperFetchYard", "JasperBedroomStart"}) do
                    local host = root:FindFirstChild(name)
                    if host and host:IsA("BasePart") and (body.Position-host.Position).Magnitude < 30 then
                        emit("JasperPant", host, 4); return
                    end
                end
            end
        end
    end)
end))
table.insert(connections, script.Destroying:Connect(Audio.Destroy))
return Audio
]=],
["roblox/mvp/server/FinalePresentation.luau"] = [=[-- Bounded native presentation around the existing table. Never creates seats,
-- edits the saved cake, plays music, moves avatars or changes avatar joints.
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local FinalePresentation = {}
FinalePresentation.__index = FinalePresentation
local P = {
    forest = Color3.fromRGB(54,87,68), sage = Color3.fromRGB(168,185,149),
    cream = Color3.fromRGB(245,240,228), wood = Color3.fromRGB(149,103,75),
    blossom = Color3.fromRGB(232,183,198), brick = Color3.fromRGB(182,108,104),
    golden = Color3.fromRGB(232,199,121), ink = Color3.fromRGB(38,56,46),
}
local V, CF = Vector3.new, CFrame.new
local function folder(parent, name)
    local value = Instance.new("Folder"); value.Name = name; value.Parent = parent; return value
end
local function part(parent, name, size, frame, token, shape)
    local value = Instance.new("Part")
    value.Name, value.Size, value.CFrame = name, size, frame
    value.Color, value.Material = P[token], Enum.Material.SmoothPlastic
    value.Anchored, value.CanCollide, value.CanTouch, value.CanQuery = true, false, false, false
    value.CastShadow = false
    if shape then value.Shape = shape end
    value:SetAttribute("PaletteToken", token); value:SetAttribute("VerificationTicket", "PCW-23")
    value.Parent = parent
    return value
end
local function label(parent, name, frame, text, width)
    local cue = part(parent, name, V(.1,.1,.1), frame, "cream"); cue.Transparency = 1
    local gui = Instance.new("BillboardGui")
    gui.Name, gui.Size, gui.MaxDistance, gui.AlwaysOnTop = "Caption", UDim2.fromOffset(width or 190, 66), 65, false
    gui.Adornee, gui.Parent = cue, cue
    local caption = Instance.new("TextLabel")
    caption.Name, caption.Size, caption.Text, caption.TextSize = "Text", UDim2.fromScale(1,1), text, 15
    caption.Font, caption.TextWrapped = Enum.Font.GothamMedium, true
    caption.BackgroundColor3, caption.TextColor3, caption.BorderSizePixel = P.cream, P.ink, 0
    caption.Parent = gui
    return gui, caption
end
local function position(value) return { x = value.X, y = value.Y, z = value.Z } end

function FinalePresentation.new(root, mvp)
    local context = root:FindFirstChild("SurroundingContext")
    local details = context and context:FindFirstChild("NeighborhoodDetails02")
    local courtyard = assert(details and details:FindFirstChild("BirthdayCourtyard"), "PCW-23 BirthdayCourtyard missing")
    local tablePart = assert(courtyard:FindFirstChild("GatheringTable"), "PCW-23 GatheringTable missing")
    local cake = assert(courtyard:FindFirstChild("BirthdayCake"), "PCW-23 saved cake missing")
    assert(tablePart:IsA("BasePart"), "PCW-23 table must be a BasePart")
    local stations = mvp:FindFirstChild("Stations")
    local ends = stations and stations:FindFirstChild("CakeFinale")
    local west = ends and ends:FindFirstChild("EndSeatWest")
    local east = ends and ends:FindFirstChild("EndSeatEast")
    west, east = west and west:FindFirstChild("Seat"), east and east:FindFirstChild("Seat")
    assert(west and west:IsA("Seat") and east and east:IsA("Seat"), "PCW-23 saved end seats missing; do not duplicate them")
    local seats = {}
    for _, item in ipairs(courtyard:GetDescendants()) do
        if item:IsA("Seat") then table.insert(seats, item) end
    end
    assert(#seats == 8, "PCW-23 expected eight courtyard side seats")
    table.sort(seats, function(a,b) return a:GetFullName() < b:GetFullName() end)
    table.insert(seats, west); table.insert(seats, east)
    local runtime = mvp:FindFirstChild("RuntimePresentation") or folder(mvp, "RuntimePresentation")
    assert(not runtime:FindFirstChild("FinalePresentation"), "PCW-23 presentation already running")
    local owned = folder(runtime, "FinalePresentation"); owned:SetAttribute("VerificationTicket", "PCW-23")
    local self = setmetatable({ root = owned, seats = seats, phuongSeat = west, tablePart = tablePart,
        seatCues = {}, confetti = {}, sliceModels = {}, participants = {}, elapsed = 0, state = {} }, FinalePresentation)
    self.scene = { center = position(tablePart.Position), tablePath = tablePart:GetFullName(),
        phuongSeatPath = west:GetFullName(), phuongSeatPosition = position(west.Position), seatCount = #seats }
    local cues = folder(owned, "SeatCues")
    for index, seat in ipairs(seats) do
        local designated = seat == west
        local gui = label(cues, "SeatCue" .. index, CF(seat.Position + V(0, 3.7, 0)),
            designated and "Phuong's seat\nSit here when ready" or "Guest seat\nGather here first")
        gui.Enabled = false
        table.insert(self.seatCues, { gui = gui, seat = seat, designated = designated })
    end
    self.banner, self.bannerText = label(owned, "BirthdayCaption", CF(tablePart.Position + V(0, 8.5, 0)), "", 310)
    self.banner.Enabled = false
    local celebration = folder(owned, "Celebration")
    for index = 1, 18 do
        local token = index % 3 == 0 and "golden" or index % 3 == 1 and "blossom" or "cream"
        local piece = part(celebration, "Confetti" .. index, V(.25,.07,.45), tablePart.CFrame, token)
        piece.Transparency = 1
        table.insert(self.confetti, piece)
    end
    -- The existing cake already owns its candles/topper. Add a small halo of
    -- native golden beads rather than duplicate the cake or its light sources.
    self.halo = {}
    local upper = cake:FindFirstChild("CakeUpperTier", true)
    self.cakeFrame = upper and upper.CFrame or tablePart.CFrame * CF(0,2.7,0)
    for index = 1, 6 do
        local angle = index * math.pi / 3
        local bead = part(celebration, "CandleGlow" .. index, V(.15,.15,.15), self.cakeFrame * CF(math.cos(angle)*2.5,1.65,math.sin(angle)*2.5), "golden", Enum.PartType.Ball)
        bead.Transparency = 1; table.insert(self.halo, bead)
    end
    local serving = folder(owned, "Serving")
    self.blade = part(serving, "CakeServerBlade", V(.15,.25,2.4), self.cakeFrame, "golden")
    self.handle = part(serving, "CakeServerHandle", V(.24,.26,1), self.cakeFrame, "wood")
    self.blade.Transparency, self.handle.Transparency = 1, 1
    local tray = tablePart.CFrame * CF(4,tablePart.Size.Y/2+.4,0)
    self.served = {
        part(serving, "SharedSlicePlate", V(.12,2.2,2.2), tray * CFrame.Angles(0,0,math.pi/2), "cream", Enum.PartType.Cylinder),
        part(serving, "SharedSliceCake", V(1.05,.65,1.25), tray * CF(0,.38,0), "golden"),
        part(serving, "SharedSliceIcing", V(1.07,.15,1.27), tray * CF(0,.79,0), "blossom"),
    }
    for _, piece in ipairs(self.served) do piece.Transparency = 1 end
    self.slices = folder(owned, "PersonalSlices")
    self.connection = RunService.Heartbeat:Connect(function(dt)
        self.elapsed += dt
        if self.elapsed < .05 then return end
        self.elapsed = 0
        local ok, err = pcall(self._step, self, workspace:GetServerTimeNow())
        if not ok and not self.warned then self.warned = true; warn("PCW-23 cosmetic presentation failed", err) end
    end)
    return self
end

function FinalePresentation:GetOccupant()
    local seat = self.phuongSeat
    local humanoid = seat and seat.Parent and seat.Occupant
    if not humanoid or humanoid.Health <= 0 or humanoid.SeatPart ~= seat then return nil end
    local actor = Players:GetPlayerFromCharacter(humanoid.Parent)
    if actor and actor.Character == humanoid.Parent and actor:GetAttribute("BirthdayLocation") == "World" then return actor.UserId end
    return nil
end

function FinalePresentation:GetScene() return self.scene end

function FinalePresentation:Render(state, participants)
    self.state, self.participants = state, participants or {}
    self.banner.Enabled = state.phase ~= "LOCKED"
    self.bannerText.Text = state.phase == "CELEBRATING" and "Happy Birthday, Phuong!"
        or state.cutAt and "Cake for everyone!\nTake a slice · stay for photos"
        or state.phase == "CAKE_READY" and "Phuong's first cut\nOpen Birthday cake when ready"
        or state.delayed and "Birthday gathering paused\nFriends, find your seats"
        or "Birthday gathering\nFriends first · then Phuong's seat"
    for _, cue in ipairs(self.seatCues) do
        cue.gui.Enabled = state.phase == "READY" or state.phase == "GATHERING"
    end
    for _, piece in ipairs(self.served) do piece.Transparency = state.cutAt and 0 or 1 end
end

function FinalePresentation:_slice(actor)
    if self.sliceModels[actor] then return self.sliceModels[actor] end
    local model = folder(self.slices, "Participant" .. tostring(actor))
    local result = { root = model }
    result.plate = part(model, "Plate", V(.1,1.5,1.5), CF(), "cream", Enum.PartType.Cylinder)
    result.cake = part(model, "Slice", V(.8,.4,.8), CF(), "golden")
    result.icing = part(model, "Icing", V(.82,.1,.82), CF(), "blossom")
    result.fork = part(model, "UtensilHandle", V(.09,.09,.65), CF(), "wood")
    result.spoon = part(model, "UtensilTip", V(.25,.1,.32), CF(), "golden", Enum.PartType.Ball)
    result.bite = part(model, "LittleBite", V(.19,.16,.2), CF(), "blossom")
    self.sliceModels[actor] = result
    return result
end

function FinalePresentation:_step(now)
    if not self.root.Parent then self:Destroy(); return end
    local state = self.state
    local celebrating = state.phase == "CELEBRATING" and state.startedAt and state.endsAt and now < state.endsAt
    for index, piece in ipairs(self.confetti) do
        piece.Transparency = celebrating and .12 or 1
        if celebrating then
            local t = (now - state.startedAt + index*.21) % 3 / 3
            local angle = index * 2.399 + t*.4
            piece.CFrame = self.tablePart.CFrame * CF(math.cos(angle)*(4+index%5),9-t*6,math.sin(angle)*(3+index%4)) * CFrame.Angles(t*math.pi,index,t*2)
        end
    end
    for _, bead in ipairs(self.halo) do bead.Transparency = celebrating and .15 or 1 end
    local cutting = state.cutAt and now - state.cutAt < 2.4
    self.blade.Transparency, self.handle.Transparency = cutting and 0 or 1, cutting and 0 or 1
    if cutting then
        local t = math.clamp((now-state.cutAt)/2.4,0,1)
        local frame = self.cakeFrame * CF(.6,2-math.sin(t*math.pi)*2.1,0) * CFrame.Angles(0,0,-.25)
        self.blade.CFrame, self.handle.CFrame = frame, frame * CF(0,0,1.7)
    end
    local active = {}
    for _, player in ipairs(Players:GetPlayers()) do
        local person = self.participants[player.UserId]
        local character = player.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        local base = character and character:FindFirstChild("HumanoidRootPart")
        local head = character and character:FindFirstChild("Head")
        if person and player:GetAttribute("BirthdayLocation") == "World" and base and head and humanoid and humanoid.Health > 0 then
            active[player.UserId] = true
            local slice = self:_slice(player.UserId)
            -- R6/R15 fallback: a small plate held beside the body and an animated
            -- utensil from right hand to mouth. No uploaded animation or joints.
            local left = character:FindFirstChild("LeftHand") or character:FindFirstChild("Left Arm")
            local right = character:FindFirstChild("RightHand") or character:FindFirstChild("Right Arm")
            local platePosition = left and left.Position or (base.CFrame * CF(-1.1,0,-.6)).Position
            platePosition += base.CFrame.LookVector * .65 + V(0,.1,0)
            local frame = CF(platePosition) * base.CFrame.Rotation
            local eaten = person.eatenAt ~= nil
            slice.plate.CFrame = frame * CFrame.Angles(0,0,math.pi/2)
            slice.cake.Size = eaten and V(.45,.4,.8) or V(.8,.4,.8)
            slice.icing.Size = eaten and V(.47,.1,.82) or V(.82,.1,.82)
            slice.cake.CFrame, slice.icing.CFrame = frame * CF(0,.25,0), frame * CF(0,.5,0)
            local t = person.lastBiteAt and math.clamp((now-person.lastBiteAt)/1.5,0,1) or 1
            local lift = math.sin(t*math.pi)
            local rest = right and right.Position + base.CFrame.LookVector * .7 or (base.CFrame * CF(1,0,-.8)).Position
            local mouth = head.Position + base.CFrame.LookVector * .65 - V(0,.15,0)
            local tip = rest:Lerp(mouth, lift)
            local forkFrame = CF(tip) * base.CFrame.Rotation
            slice.fork.CFrame, slice.spoon.CFrame = forkFrame * CF(0,0,.25), forkFrame * CF(0,0,-.2)
            slice.bite.CFrame = forkFrame * CF(0,.13,-.2)
            slice.bite.Transparency = t > 0 and t < .55 and 0 or 1
        end
    end
    for actor, slice in pairs(self.sliceModels) do
        if not active[actor] then slice.root:Destroy(); self.sliceModels[actor] = nil end
    end
end

function FinalePresentation:Destroy()
    if self.connection then self.connection:Disconnect(); self.connection = nil end
    if self.root then self.root:Destroy() end
    self.sliceModels = {}
end

return FinalePresentation
]=],
["roblox/mvp/server/FoodFeedback.luau"] = [=[-- One bounded runtime dish, plus route labels on the existing three counters.
local FoodPresentation = require(script.Parent.Parent.shared.FoodPresentation)
local FoodFeedback = {}
FoodFeedback.__index = FoodFeedback
local VENUES = {
	{ id = "FOB", anchor = "Q06FOBCounter", label = "1 · FOB", task = "Rice + protein + fresh topping", next = "Next · Aladdins" },
	{ id = "Aladdins", anchor = "Q06AladdinsCounter", label = "2 · Aladdins", task = "Sauce or sesame", next = "Next · serving table" },
	{ id = "Serving", anchor = "Q06Serving", label = "3 · Serving table", task = "Left + right table settings", next = "Share your meal" },
}
local function folder(parent, name)
	local value = Instance.new("Folder"); value.Name = name; value.Parent = parent; return value
end
local function surface(mvp, anchor)
	local stations = mvp:FindFirstChild("Stations")
	local station = stations and stations:FindFirstChild("Q06Station")
	local counter = station and station:FindFirstChild(anchor.Name, true)
	local top = counter and counter:FindFirstChild("ActionSurface")
	if top and top:IsA("BasePart") then return top.CFrame * CFrame.new(0, top.Size.Y / 2 + .03, 0) end
	-- Matches the existing Q06Station counter contract. No builder is invoked.
	return anchor.CFrame * CFrame.new(0, 2.205, 0)
end
function FoodFeedback.new(mvp, anchors)
	local runtime = mvp:FindFirstChild("RuntimePresentation") or folder(mvp, "RuntimePresentation")
	assert(not runtime:FindFirstChild("FoodFeedback"), "FoodFeedback is already running")
	local root = folder(runtime, "FoodFeedback"); root:SetAttribute("VerificationTicket", "PCW-20")
	local self = setmetatable({ root = root, frames = {}, labels = {} }, FoodFeedback)
	for _, venue in ipairs(VENUES) do
		local anchor = anchors[venue.anchor]
		if anchor and anchor:IsA("BasePart") then
			self.frames[venue.id] = surface(mvp, anchor)
			local cue = Instance.new("Part")
			cue.Name, cue.Size, cue.CFrame = venue.anchor .. "Cue", Vector3.new(.1, .1, .1), self.frames[venue.id] * CFrame.new(0, 1.9, -1)
			cue.Anchored, cue.CanCollide, cue.CanTouch, cue.CanQuery, cue.Transparency = true, false, false, false, 1
			cue.Color = Color3.fromRGB(54, 87, 68); cue:SetAttribute("PaletteToken", "forest"); cue:SetAttribute("VerificationTicket", "PCW-20"); cue.Parent = root
			local gui = Instance.new("BillboardGui")
			gui.Name, gui.Size, gui.AlwaysOnTop, gui.MaxDistance = "FoodRoute", UDim2.fromOffset(250, 92), false, 38
			gui.Adornee, gui.Parent = cue, cue
			local text = Instance.new("TextLabel")
			text.Name, text.Size, text.Font, text.TextSize = "RouteText", UDim2.fromScale(1, 1), Enum.Font.GothamMedium, 14
			text.BackgroundColor3, text.TextColor3, text.BorderSizePixel = Color3.fromRGB(245, 240, 228), Color3.fromRGB(38, 56, 46), 0
			text.TextWrapped, text.Parent = true, gui
			self.labels[venue.id] = text
		else warn("PCW-20 food counter anchor is unavailable", venue.anchor) end
	end
	self:Render(nil, {}, "FOB", false)
	return self
end
function FoodFeedback:Render(roundId, accepted, venueId, complete)
	-- Rebuild only on accepted progress or a new round, never on selections or views.
	-- At most one six-ingredient dish exists, including across repeated replays.
	if self.dish then self.dish:Destroy(); self.dish = nil end
	local frame = self.frames[venueId]
	if frame then
		local model = FoodPresentation.Build(accepted)
		model:SetAttribute("RoundId", roundId); model:SetAttribute("VenueId", venueId); model:SetAttribute("Completed", complete)
		model.Parent = self.root; model:PivotTo(frame); self.dish = model
	end
	self.root:SetAttribute("RoundId", roundId); self.root:SetAttribute("VenueId", venueId)
	for _, venue in ipairs(VENUES) do
		local label = self.labels[venue.id]
		if label then
			local state = complete and "Done · meal ready at serving" or venue.id == venueId and "Build the shared meal here" or "Current step · " .. (venueId == "Serving" and "serving table" or venueId)
			label.Text = venue.label .. "\n" .. venue.task .. "\n" .. state .. "\n" .. venue.next
		end
	end
end
function FoodFeedback:Destroy() self.root:Destroy() end
return FoodFeedback
]=],
["roblox/mvp/server/HostService.luau"] = [=[-- Bounded, session-only recovery. Only Main supplies the authenticated actor.
local Config = require(script.Parent.Parent.shared.Config)
local Catalog = require(script.Parent.Parent.shared.FigureCatalog)
local HostService = {}; HostService.__index = HostService
local RESETTABLE = { Q01=true, Q03=true, Q06=true }
local QUEST_ACTIONS = { ReleaseReservations=true, RestartRound=true, CompleteQuest=true }
local OPERATIONS = { ReleaseReservations=true, RestartRound=true, CompleteQuest=true, TopUp=true, FulfillWish=true,
    InviteCake=true, StartCake=true, AdvanceCake=true, ReturnBedroom=true, ReturnPatio=true }
local TITLES = { Q01="Bed",Q02="Jasper",Q03="Craft",Q04="Reading",Q05="Labubu wish",Q06="Food" }
local LABELS = { ReleaseReservations="Release held choices",RestartRound="Restart incomplete round",CompleteQuest="Complete quest",
    TopUp="Add 20 to shared fund",FulfillWish="Fulfill selected Labubu wish",InviteCake="Invite everyone to cake",
    StartCake="Start birthday celebration",AdvanceCake="Advance to cut cake",ReturnBedroom="Return me to bedroom",ReturnPatio="Return me to patio" }
local function copy(value)
    if type(value)~="table" then return value end
    local out={}; for k,v in pairs(value) do out[k]=copy(v) end; return out
end
local function equal(a,b)
    if type(a)~=type(b) then return false end
    if type(a)~="table" then return a==b end
    for k,v in pairs(a) do if not equal(v,b[k]) then return false end end
    for k in pairs(b) do if a[k]==nil then return false end end
    return true
end
local function count(map) local n=0; for _ in pairs(map or {}) do n+=1 end; return n end
local function reject(code,message) return {ok=false,code=code,message=message} end
local function hostName(actor) return actor==Config.PhuongUserId and "Phuong" or "Andrew" end

function HostService.new(session,options)
    assert(session and options and options.activities and options.cake,"host dependencies required")
    return setmetatable({session=session,activities=options.activities,cake=options.cake,clock=options.clock or os.clock,
        runtime=options.runtime or {},overrides={},quotes={},results={},audit={},lastRequest={},serial=0,revision=0,
        requestCount=0,topUps=0,lastTopUp=nil},HostService)
end
function HostService:IsHost(actor)
    return actor==Config.PhuongUserId or actor==Config.HostUserId
end
function HostService:_present(actor)
    return self:IsHost(actor) and self.session:IsPresent(actor) and self.runtime.isWorld and self.runtime.isWorld(actor)==true
end
function HostService:_record(actor,operation,activityId,prior,new)
    self.revision+=1
    table.insert(self.audit,1,{actorUserId=actor,actor=hostName(actor),action=operation,activityId=activityId,
        prior=prior,new=new,timestamp=self.clock()})
    while #self.audit>32 do table.remove(self.audit) end
end
function HostService:ReleaseActor(actor)
    self.quotes[actor]=nil
    if self.overrides[actor] then
        self.overrides[actor]=nil
        self:_record(actor,"Override ended",nil,"Override active","Normal choices")
    end
end
function HostService:_state(activityId,operation)
    local activity=activityId and self.activities[activityId]
    local localState=activity and activity:RecoveryState() or nil
    local round=localState and localState.roundId and self.session.rounds[localState.roundId]
    local state={revision=self.revision,fund=self.session.fundBalance,petals=copy(self.session.petals),localState=copy(localState),
        round=round and {roundId=round.roundId,state=round.state,steps=copy(round.steps),isReplay=round.isReplay},
        missingReward=activityId and self.session:MissingInitialReward(activityId) or 0,topUps=self.topUps}
    if operation=="InviteCake" or operation=="StartCake" or operation=="AdvanceCake" then
        state.cake={phase=self.cake.phase,generation=self.cake.generation,revision=self.cake.revision,cutAt=self.cake.cutAt,startedAt=self.cake.startedAt}
    end
    return state
end
function HostService:_summary(state,activityId)
    local petals=0; for _,done in pairs(state.petals) do if done then petals+=1 end end
    local text="Shared fund "..state.fund.." · "..petals.."/6 petals"
    if activityId then
        text..=" · "..TITLES[activityId]..": "..(state.petals[activityId] and "petal saved" or "petal missing")
        if state.round then text..=" · "..count(state.round.steps).." saved steps ("..state.round.state..")" else text..=" · not started" end
        local localState=state.localState
        if localState and RESETTABLE[activityId] then
            local held=activityId=="Q01" and count(localState.reserved)+count(localState.shelfHolds)
                or activityId=="Q03" and count(localState.state and localState.state.reservations) or count(localState.reservations)
            text..=" · "..held.." held choices"
        end
    end
    if state.localState and state.localState.wanted then
        text..=" · wish: "..Catalog.Label(state.localState.wanted).." · "..(state.localState.collection[state.localState.wanted] or 0).." copies owned"
    end
    if state.cake then text..=" · cake "..state.cake.phase end
    return text
end
function HostService:_plan(operation,activityId)
    if not OPERATIONS[operation] then return nil,"Choose a listed recovery action." end
    if QUEST_ACTIONS[operation] then
        if not TITLES[activityId] or not self.activities[activityId] then return nil,"Choose one of the six available quests." end
    elseif activityId~=nil and not (operation=="FulfillWish" and activityId=="Q05") then return nil,"This action has no activity target." end
    if operation=="FulfillWish" then activityId="Q05" end
    local state=self:_state(activityId,operation)
    local effect
    if operation=="ReleaseReservations" or operation=="RestartRound" then
        if not RESETTABLE[activityId] then return nil,"Only the bed, craft and food have recoverable holds/rounds." end
        if not state.round or state.round.state~="IN_PROGRESS" then return nil,"Open an incomplete round first. Completed work is preserved." end
        effect=operation=="ReleaseReservations" and "Release every held choice for this activity. Keep all placed work, petals and funds."
            or "Discard only this incomplete round's placed work and holds, then open a fresh round. Keep all earned petals, shared funds and bedroom shelf placements. No reward is granted."
    elseif operation=="CompleteQuest" or operation=="FulfillWish" then
        if activityId=="Q05" then
            local wish=state.localState
            if not wish or not Catalog.ById[wish.wanted] then return nil,"Phuong must first confirm a wish at the Labubu booth; Andrew can choose normally while she is away." end
            if wish.recovered then return nil,"The one Labubu recovery for this server session was already used." end
            if wish.fulfilled or wish.purchasing then return nil,"The current wish is already fulfilled or a box is being saved." end
            effect="Add exactly one "..Catalog.Label(wish.wanted).." to the collection; fulfill the selected wish. "
                ..(state.petals.Q05 and "Keep the existing Q05 petal." or "Grant the missing Q05 petal once.")
                .." Spend 0 and grant 0 funds. Preserve paid rolls and misses. One wish recovery per server session."
        else
            if state.petals[activityId] and state.missingReward==0 then return nil,"This quest's initial petal and reward are already saved." end
            effect="Complete "..TITLES[activityId].." and its visible activity state. "..(state.petals[activityId] and "Keep its saved petal. " or "Grant its missing petal once. ")
                .."Add only the missing initial reward: "..state.missingReward..". No replay reward."
            if activityId=="Q01" then effect..=" Fill all bed tasks and use Soft and snug if no final style is saved. Keep the optional shelf." end
            if activityId=="Q02" then effect..=" Jasper finishes happy in the yard." end
            if activityId=="Q03" then effect..=" Keep placed orientations; fill missing pieces at zero turns. Phuong can still choose the finishing lamp." end
            if activityId=="Q04" then effect..=" Preserve every person's choices and private notes; no reading response is invented." end
            if activityId=="Q06" then effect..=" Keep accepted choices; fill only missing slots with Rice, Tofu, Greens, Sauce, Plate and Cup respectively." end
        end
    elseif operation=="TopUp" then
        if self.topUps>=5 then return nil,"All five +20 emergency top-ups have been used in this session." end
        local remaining=self.lastTopUp and math.ceil(30-(self.clock()-self.lastTopUp)) or 0
        if remaining>0 then return nil,"Wait "..remaining.." seconds before another top-up." end
        effect="Add exactly 20 to the shared fund: "..state.fund.." → "..(state.fund+20)..". Top-up "..(self.topUps+1).." of 5 this session; wait 30 seconds between top-ups. No petal changes."
    elseif operation=="InviteCake" or operation=="StartCake" then
        if not self.session:AllPetalsComplete() then return nil,"All six petals are required before cake recovery." end
        if self.cake.startedAt then return nil,"The celebration has already started and cannot restart." end
        effect=operation=="InviteCake" and "Arm the normal invitation and Phuong's seat. If Phuong is already seated, the celebration begins now. Nobody is moved."
            or "Start the single birthday celebration now, bypassing the normal Phuong seat trigger. Keep seats and optional personal camera/Skip controls. No rewards."
    elseif operation=="AdvanceCake" then
        if self.cake.cutAt or (self.cake.phase~="CELEBRATING" and self.cake.phase~="CAKE_READY") then return nil,"Start the celebration first; an already-cut cake cannot be cut twice." end
        effect="End any remaining birthday presentation and make the first cut once. Everyone can take a slice; optional cameras return and saved slice/eating state remains. No rewards."
    else
        effect="Release only your activity holds, leave your seat safely and move only you to the "..(operation=="ReturnBedroom" and "bedroom arrival." or "patio arrival.").." No progress or funds change."
    end
    return {operation=operation,activityId=activityId,label=LABELS[operation],state=state,current=self:_summary(state,activityId),effect=effect}
end
function HostService:GetView(actor)
    if not self:IsHost(actor) then return nil end
    local actions={}
    local function add(operation,id)
        local plan,reason=self:_plan(operation,id)
        table.insert(actions,{operation=operation,activityId=id,label=LABELS[operation],enabled=plan~=nil,reason=reason})
    end
    for _,id in ipairs(Config.ActivityIds) do
        if RESETTABLE[id] then add("ReleaseReservations",id); add("RestartRound",id) end
        add("CompleteQuest",id)
    end
    for _,op in ipairs({"TopUp","FulfillWish","InviteCake","StartCake","AdvanceCake","ReturnBedroom","ReturnPatio"}) do add(op) end
    local active={}; for _,id in ipairs({Config.PhuongUserId,Config.HostUserId}) do if self.overrides[id] then table.insert(active,hostName(id)) end end
    local quote=self.quotes[actor]
    if quote and quote.expiresAt<=self.clock() then self.quotes[actor]=nil; quote=nil end
    return {authorized=true,actor=hostName(actor),override=self.overrides[actor]==true,activeOverrides=active,revision=self.revision,
        fundBalance=self.session.fundBalance,petals=copy(self.session.petals),actions=actions,audit=copy(self.audit),
        topUpsUsed=self.topUps,topUpLimit=5,topUpAmount=20,topUpCooldown=30,requestCount=self.requestCount,requestLimit=512,
        confirmation=quote and {token=quote.token,label=quote.label,current=quote.current,effect=quote.effect,expiresAt=quote.expiresAt},
        inWorld=self:_present(actor),hint="Normal choices stay Phuong-first. Override is for deliberate recovery by Phuong or Andrew."}
end
function HostService:_execute(plan,request)
    local operation,id=plan.operation,plan.activityId
    if operation=="TopUp" then
        self.session:AddFund(20); self.topUps+=1; self.lastTopUp=self.clock()
    elseif QUEST_ACTIONS[operation] or operation=="FulfillWish" then
        local activity=self.activities[id]
        local roundId=activity:RecoveryState().roundId
        if not roundId then
            roundId=self.runtime.newRoundId(id)
            activity:CreateRound({sessionId=request.sessionId,actionId=request.actionId,activityId=id,roundId=roundId,actorUserId=request.actorUserId})
            self.runtime.setRoundId(id,roundId)
        end
        local recovery={sessionId=request.sessionId,actionId=request.actionId,actorUserId=request.actorUserId,activityId=id,roundId=roundId}
        if operation=="ReleaseReservations" then activity:RecoverRelease(recovery)
        elseif operation=="RestartRound" then
            roundId=activity:RecoverRestart(recovery,self.runtime.newRoundId(id)); self.runtime.setRoundId(id,roundId)
        else
            local receipt=activity:RecoverComplete(recovery); self.runtime.setRoundId(id,roundId)
            return {ok=true,receipt=receipt}
        end
    elseif operation=="InviteCake" or operation=="StartCake" or operation=="AdvanceCake" then
        local cakeRequest={sessionId=request.sessionId,actionId="host-cake:"..request.actionId,actorUserId=request.actorUserId,
            generation=self.cake.generation,action=operation=="InviteCake" and "Arm" or operation=="StartCake" and "RecoverStart" or "RecoverCut"}
        if operation=="InviteCake" then return self.cake:Apply(cakeRequest) end
        return self.cake:Recover(cakeRequest)
    else
        local destination=operation=="ReturnBedroom" and "Bedroom" or "Patio"
        if not self.runtime.travel(request.actorUserId,destination) then return reject("HostTravelUnavailable","Your character or destination is unavailable. Try again after respawning.") end
        return {ok=true,destination=destination}
    end
    return {ok=true}
end

local FIELDS={kind=true,sessionId=true,actionId=true,actorUserId=true,action=true,enabled=true,operation=true,activityId=true,token=true}
function HostService:Apply(request)
    if type(request)~="table" or not self:_present(request.actorUserId) then return reject("HostPermission","Only Phuong and Andrew in the birthday world can use host controls.") end
    if request.sessionId~=self.session.sessionId or type(request.actionId)~="string" or #request.actionId<1 or #request.actionId>96 then return reject("HostIdentity","Reopen host controls for this session.") end
    for field in pairs(request) do if not FIELDS[field] then return reject("HostMalformed","Use one of the listed host controls.") end end
    local command=request.action
    if command~="Prepare" and command~="Confirm" and command~="Cancel" and command~="SetOverride" then return reject("HostMalformed","Use one of the listed host controls.") end
    if command=="SetOverride" then
        if type(request.enabled)~="boolean" or request.operation~=nil or request.activityId~=nil or request.token~=nil then return reject("HostMalformed","Choose whether Override is enabled.") end
    elseif command=="Prepare" then
        if type(request.operation)~="string" or request.token~=nil or request.enabled~=nil or (request.activityId~=nil and type(request.activityId)~="string") then return reject("HostMalformed","Choose a listed recovery action.") end
    elseif type(request.token)~="string" or #request.token>128 or request.operation~=nil or request.activityId~=nil or request.enabled~=nil then return reject("HostMalformed","Review the confirmation before continuing.") end
    local identity={actor=request.actorUserId,action=command,enabled=request.enabled,operation=request.operation,activityId=request.activityId,token=request.token}
    local previous=self.results[request.actionId]
    if previous then
        if not equal(previous.identity,identity) then return reject("HostIdentityChanged","That request already represents another choice.") end
        return copy(previous.result)
    end
    if self.session.receipts[request.actionId] or self.session.acceptedSteps[request.actionId] or self.session.receipts["host-cake:"..request.actionId] then return reject("HostActionUsed","That request was already used. Choose again.") end
    if self.requestCount>=512 then return reject("HostLimit","This session reached its host request limit. Ordinary play remains available.") end
    local actor,at=request.actorUserId,self.clock()
    if self.lastRequest[actor] and at-self.lastRequest[actor]<.5 then return reject("HostTooQuick","Wait a moment for your last host choice to settle.") end
    self.lastRequest[actor]=at
    local result
    if command=="SetOverride" then
        local before=self.overrides[actor]==true
        self.overrides[actor]=request.enabled; self.quotes[actor]=nil
        if before~=request.enabled then self:_record(actor,"Override "..(request.enabled and "enabled" or "ended"),nil,before and "Override active" or "Normal choices",request.enabled and "Override active" or "Normal choices") end
        result={ok=true,code="HostOverride",message=request.enabled and "Override active. Every recovery still needs a current-state confirmation." or "Override ended. Normal choices remain active."}
    elseif command=="Cancel" then
        if self.quotes[actor] and self.quotes[actor].token==request.token then self.quotes[actor]=nil end
        result={ok=true,code="HostCancelled",message="Recovery cancelled. Nothing changed."}
    elseif not self.overrides[actor] then return reject("HostOverrideRequired","Enable Override explicitly before preparing a recovery.")
    elseif command=="Prepare" then
        local plan,reason=self:_plan(request.operation,request.activityId)
        if not plan then return reject("HostUnavailable",reason) end
        self.serial+=1; plan.token="host:"..self.serial..":"..actor; plan.expiresAt=at+30
        self.quotes[actor]=copy(plan)
        result={ok=true,code="HostPrepared",message="Review the current state and exact effect, then Confirm or Cancel.",confirmation={token=plan.token,label=plan.label,current=plan.current,effect=plan.effect,expiresAt=plan.expiresAt}}
    else
        local plan=self.quotes[actor]
        if not plan or plan.token~=request.token or plan.expiresAt<=at then self.quotes[actor]=nil; return reject("HostQuoteExpired","That confirmation expired or belongs to another host. Review a fresh preview.") end
        local fresh,reason=self:_plan(plan.operation,plan.activityId)
        if not fresh or not equal(plan.state,fresh.state) then self.quotes[actor]=nil; return reject("HostStateChanged",reason or "The shared state changed. Review a fresh preview before confirming.") end
        self.quotes[actor]=nil
        local called,outcome=pcall(self._execute,self,plan,request)
        if not called then
            local activity=plan.activityId and self.activities[plan.activityId]
            local current=activity and activity:RecoveryState().roundId
            if current then self.runtime.setRoundId(plan.activityId,current) end
            warn("PCW-24 recovery needs attention",outcome)
            self:_record(actor,plan.operation.." needs review",plan.activityId,plan.current,self:_summary(self:_state(plan.activityId,plan.operation),plan.activityId))
            result=reject("HostRecoveryFailed","Recovery could not fully finish. Current state is refreshed; review it before trying again.")
        elseif not outcome.ok then result=outcome
        else
            self:_record(actor,plan.operation,plan.activityId,plan.current,self:_summary(self:_state(plan.activityId,plan.operation),plan.activityId))
            result={ok=true,code="HostRecovered",message=plan.label.." saved.",operation=plan.operation,activityId=plan.activityId,receipt=outcome.receipt,destination=outcome.destination}
        end
    end
    self.requestCount+=1
    self.results[request.actionId]={identity=identity,result=copy(result)}
    self.session.receipts[request.actionId]={actorUserId=actor,actionId=request.actionId,hostRecovery=true}
    return result
end
return HostService
]=],
["roblox/mvp/server/LabubuFeedback.luau"] = [=[-- Owns only runtime previews/result/collection. It never invokes a world builder.
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
local CakeService = require(script.Parent.CakeService)
-- Preserve the live audio integration when installing this source baseline.
local CozyAudio = require(script.Parent.CozyAudio)
local BedroomFeedback = require(script.Parent.BedroomFeedback)
local FoodFeedback = require(script.Parent.FoodFeedback)
local LabubuFeedback = require(script.Parent.LabubuFeedback)
local WorldFeedback = require(script.Parent.WorldFeedback)
local FinalePresentation = require(script.Parent.FinalePresentation)
local HostService = require(script.Parent.HostService)

local now = function() return workspace:GetServerTimeNow() end
local sessionId = "MVP-" .. tostring(math.floor(workspace:GetServerTimeNow()))
local session = SessionService.new({sessionId = sessionId})
local cake = CakeService.new(session, {clock=now})
local hostService
local finaleFeedback, seenFinaleRevision, broadcastFinaleRevision
local anchors, missingAnchors = Anchors.Resolve(mvp)
local activities, activityErrors = {}, {}
local currentRounds = {}
local openedActivities = {}
local playerConnections = {}
local roundSerial = 0
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

-- Remote views contain presentation data only. Never share one actor's view
-- with another recipient, or replicate Instances/functions from server state.
local function uiCopy(value, seen, depth)
 local kind = type(value)
 if kind == "string" or kind == "number" or kind == "boolean" then return value end
 if kind ~= "table" or (depth or 0) >= 14 then return nil end
 seen = seen or {}; if seen[value] then return nil end; seen[value] = true
 local copy = {}
 for key, child in pairs(value) do
  if type(key) == "string" or type(key) == "number" then copy[key] = uiCopy(child, seen, (depth or 0) + 1) end
 end
 seen[value] = nil; return copy
end
local function view(a,p)
 if not a then return {state="UNAVAILABLE",errorText="ActivityUnavailable"} end
 local ok, result = pcall(a.GetView,a,uid(p))
 return ok and uiCopy(result) or {state="UNAVAILABLE",errorText="ActivityUnavailable"}
end
local function advanceCake()
 local changed=cake:Tick()
 if finaleFeedback and seenFinaleRevision~=cake.revision then
  seenFinaleRevision=cake.revision
  local ok,err=pcall(finaleFeedback.Render,finaleFeedback,cake:GetState(),cake.participants)
  if not ok then warn("PCW-23 finale presentation unavailable",err) end
 end
 return changed
end
local function snapshot(p)
 advanceCake()
 local s = session:GetSnapshot(); s.cake = cake:GetState(uid(p)); s.activityViews = {}
 if p then for id, activity in pairs(activities) do s.activityViews[id] = view(activity, p) end end
 if hostService and p then s.host = hostService:GetView(uid(p)) end
 return uiCopy(s)
end
local function send(p, request, ok, code, extra)
 request=type(request)=="table" and request or {}
 local r = {kind="Result", ok=ok, code=code, sessionId=sessionId, activityId=request and request.activityId, roundId=request and request.roundId, actionId=request and request.actionId, stepId=request and request.stepId, actorUserId=uid(p), snapshot=snapshot(p)}
 if extra then for k,v in pairs(extra) do r[k]=uiCopy(v) end end; action:FireClient(p,r); return r
end
local function broadcast()
 for _, p in ipairs(Players:GetPlayers()) do
  local id = openedActivities[p.UserId]
  local extra = id and p:GetAttribute("BirthdayLocation") == "World" and {view=view(activities[id],p)} or nil
  -- No actionId: clients refresh only this same already-open activity.
  send(p,{kind="RequestSnapshot"},true,"Snapshot",extra)
 end
 broadcastFinaleRevision=cake.revision
end
local function construct(name,module,context)
 local ctor=module.new or module.New; if not ctor then activityErrors[name]="missing constructor"; return end
 local ok,value=pcall(ctor,context); if ok then activities[name]=value else activityErrors[name]=tostring(value) end
end

-- Prompts are owned by this runtime so a saved place cannot retain stale handlers.
local promptLabels={Q01="Make the bed",Q02="Visit Jasper",Q03="Craft a keepsake",Q04="Read together",Q05="Make a Labubu wish",Q06="Build a shared meal",Cake="Birthday cake"}
local promptObjects={Q01="Everything Tucked In",Q02="Jasper's Favorite Things",Q03="A Tiny World of Her Own",Q04="One More Chapter",Q05="A Labubu Wish",Q06="Something Delicious",Cake="Birthday cake"}
local function installPrompt(id, instance)
 if not instance then return end
 local host=instance:IsA("BasePart") and instance or instance:FindFirstChildWhichIsA("BasePart",true); if not host then return end
 local prompt=host:FindFirstChild("MVPProximityPrompt") or Instance.new("ProximityPrompt")
 prompt.Name="MVPProximityPrompt"; prompt.ActionText=promptLabels[id] or id; prompt.ObjectText=promptObjects[id] or id; prompt.KeyboardKeyCode=Enum.KeyCode.E
 prompt.HoldDuration=0; prompt.MaxActivationDistance=12; prompt.RequiresLineOfSight=false; prompt:SetAttribute("ActivityId",id); prompt.Parent=host
end
local world={isPresent=function(id) return session:IsPresent(id) end,presentUserIds=session.presence,anchors=anchors}
-- Nearby FOB and serving radii overlap. Resolve to the closest actual counter,
-- so each recipient sees only their current venue's valid recipe cards.
local foodCounters = { {id="FOB",name="Q06FOBCounter"}, {id="Aladdins",name="Q06AladdinsCounter"}, {id="Serving",name="Q06Serving"} }
world.foodVenue = function(actor)
 local p = Players:GetPlayerByUserId(actor)
 if not p or p:GetAttribute("BirthdayLocation")~="World" then return nil end
 local _, r = character(p); if not r then return nil end
 local closest, distance = nil, 24
 for _, counter in ipairs(foodCounters) do
  local target=anchor(counter.name)
  local d=target and (r.Position-target.Position).Magnitude
  if d and d<=distance then closest,distance=counter.id,d end
 end
 return closest
end
local bedroomFeedback = BedroomFeedback.new(root, mvp)
if bedroomFeedback.shelfAnchor then anchors.Q01Shelf = bedroomFeedback.shelfAnchor end
local foodFeedback = FoodFeedback.new(mvp, anchors)
local labubuFeedback = LabubuFeedback.new(root, mvp, anchors)
local feedbackOk, worldFeedback = pcall(WorldFeedback.new, root, mvp, anchors)
if not feedbackOk then warn("PCW-22 world presentation unavailable", worldFeedback); worldFeedback=nil end
local finaleOk, finaleResult=pcall(FinalePresentation.new,root,mvp)
if finaleOk then finaleFeedback=finaleResult else warn("PCW-23 finale scene unavailable",finaleResult) end
cake:SetRuntime({
 isWorld=function(actor)
  local p=Players:GetPlayerByUserId(actor)
  return p~=nil and p:GetAttribute("BirthdayLocation")=="World"
 end,
 isAtPatio=function(actor) return near(Players:GetPlayerByUserId(actor),"FinalePatio",28)==true end,
 occupant=function() return finaleFeedback and finaleFeedback:GetOccupant() or nil end,
 scene=function() return finaleFeedback and finaleFeedback:GetScene() or nil end,
})
-- Every hook exists in the real context. Activity modules protect accepted state
-- from cosmetic failures; WorldFeedback never yields or owns rewards.
local function worldEffect(method, ...)
 if worldFeedback then return worldFeedback[method](worldFeedback, ...) end
end
world.resetJasper=function(roundId) worldEffect("ResetJasper",roundId) end
world.moveJasperToYard=function() worldEffect("MoveJasperToYard") end
world.showRabbitPickup=function(index) worldEffect("ShowRabbitPickup",index) end
world.returnRabbit=function() worldEffect("ReturnRabbit") end
world.presentFetchTarget=function(index) worldEffect("PresentFetchTarget",index) end
world.fetchJasper=function(index) worldEffect("FetchJasper",index) end
world.giveJasperTreat=function() worldEffect("GiveJasperTreat") end
world.petJasper=function() worldEffect("PetJasper") end
world.renderCraft=function(roundId,committed,reservations,presentation) worldEffect("RenderCraft",roundId,committed,reservations,presentation) end
world.renderReading=function(summary) worldEffect("RenderReading",summary) end
world.jasperVenue=function(actor)
 local p=Players:GetPlayerByUserId(actor)
 if not p or p:GetAttribute("BirthdayLocation")~="World" then return nil end
 if near(p,"JasperBedroomStart",24) then return "Bedroom" end
 if near(p,"JasperFetchYard",24) then return "Yard" end
 return nil
end
construct("Q01",require(script.Parent.activities.Q01),{session=session,clock=now,world=world,feedback=bedroomFeedback})
construct("Q02",require(script.Parent.activities.Q02),{session=session,clock=now,world=world})
construct("Q03",require(script.Parent.activities.Q03),{session=session,clock=now,context=world})
construct("Q04",require(script.Parent.activities.Q04),{session=session,clock=now,context=world})
construct("Q05",require(script.Parent.activities.Q05),{session=session,clock=now,context=world,presentUserIds=session.presence,feedback=labubuFeedback})
construct("Q06",require(script.Parent.activities.Q06),{session=session,clock=now,actor=world.isPresent,context=world,feedback=foodFeedback})
local station={Q01="Q01Bed",Q02="JasperBedroomStart",Q03="Q03FairCraft",Q04="Q04QuadReading",Q05="Q05UDistrictVending",Q06="Q06FOBCounter"}
local function nearActivity(p,r)
 if r.activityId=="Q01" then
  if r.stepId=="shelf" then return near(p,"Q01Shelf",18) end
  if not r.stepId then return near(p,"Q01Bed",24) or near(p,"Q01Shelf",18) end
  return near(p,"Q01Bed",24)
 end
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
local function canonical(p,r)
 if not session:IsPresent(uid(p)) or p:GetAttribute("BirthdayLocation") ~= "World" then return nil,"NotPresent" end
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
 if type(r.roundId)~="string" or type(r.stepId)~="string" or type(r.payload)~="table" then return false,"BadAction" end
 if not nearActivity(p,r) then
  if r.activityId=="Q06" then
   local message="Walk to the next food counter, then open its prompt. Use Track next counter; your shared dish stays saved."
   return false,"NEXT_COUNTER",{view=view(activities.Q06,p),errorText=message,result={ok=false,message=message}}
  end
  return false,"TooFar"
 end
 local ok,result=pcall(activities[r.activityId].Apply,activities[r.activityId],req)
 if not ok then return false,"ActionRejected",{errorText=tostring(result),view=view(activities[r.activityId],p),failedResult=result} end
 if type(result)~="table" then return false,"ActionRejected",{errorText="Invalid activity result"} end
 if result.ok~=false then pcall(function() CozyAudio.Accepted(r,result) end) end
 return result.ok~=false,result.code or "Accepted",{receipt=result.receipt,view=result.view or view(activities[r.activityId],p),result=result,errorText=result.ok==false and result.message or nil}
end

hostService=HostService.new(session,{activities=activities,cake=cake,clock=now,runtime={
 isWorld=function(actor)
  local p=Players:GetPlayerByUserId(actor)
  return p~=nil and p:GetAttribute("BirthdayLocation")=="World"
 end,
 newRoundId=function(id) roundSerial+=1; return "round:"..id..":"..roundSerial end,
 setRoundId=function(id,roundId) currentRounds[id]=roundId end,
 travel=function(actor,destination)
  local p=Players:GetPlayerByUserId(actor)
  local c=character(p)
  local target=destination=="Bedroom" and "GameplayBedroomArrival" or destination=="Patio" and "FinalePatio" or nil
  if not c or not target or not anchor(target) then return false end
  for _,a in pairs(activities) do if a.ReleaseActor then pcall(a.ReleaseActor,a,actor) end end
  openedActivities[actor]=nil
  local humanoid=c:FindFirstChildOfClass("Humanoid")
  if humanoid then humanoid.Sit=false; humanoid:ChangeState(Enum.HumanoidStateType.GettingUp) end
  return place(p,target)
 end,
}})

action.OnServerEvent:Connect(function(p,r)
 if type(r)~="table" or type(r.kind)~="string" then return send(p,r,false,"BadPayload") end
 if r.actorUserId~=nil or r.player~=nil then return send(p,r,false,"ClientAuthorityRejected") end
 if r.kind~="Host" and r.kind~="RequestSnapshot" and r.kind~="RequestJournal" and type(r.actionId)=="string" and hostService.results[r.actionId] then
  return send(p,r,false,"HostActionUsed",{errorText="That request was already used by host controls. Choose a fresh action."})
 end
 if r.kind=="Host" then
  r.actorUserId=uid(p)
  advanceCake()
  local called,result=pcall(hostService.Apply,hostService,r)
  if not called then
   warn("PCW-24 host request failed",result)
   return send(p,r,false,"HostUnavailable",{errorText="Host controls could not refresh. Reopen them to review the current state."})
  end
  advanceCake()
  local extra={hostResult=result}
  if not result.ok then extra.errorText=result.message end
  send(p,r,result.ok==true,result.code,extra)
  -- Failure may include a safely committed partial recovery; refresh all
  -- recipients so their current round, world state and cake remain coherent.
  if result.ok or result.code=="HostRecoveryFailed" or broadcastFinaleRevision~=cake.revision then broadcast() end
  return
 end
 if r.kind=="ActivityAction" then local ok,c,e=apply(p,r); send(p,r,ok,c,e); if ok then broadcast() end; return end
 if r.kind=="RequestView" then
  local req,err=canonical(p,r); if not req then return send(p,r,false,err) end
  if req.replay~=nil and type(req.replay)~="boolean" then return send(p,req,false,"BadAction") end
  if req.replay and (not currentRounds[req.activityId] or not view(activities[req.activityId],p).canReplay) then return send(p,req,false,"ReplayUnavailable") end
  local ok,c,e=openRound(p,req)
  if ok then
   local previous = openedActivities[p.UserId]
   if previous and previous~=req.activityId then release(p,previous) end
   openedActivities[p.UserId]=req.activityId
  end
  send(p,req,ok,c,e); if ok then broadcast() end; return
 end
 if r.kind=="CloseActivity" then
  if r.sessionId~=sessionId or type(r.activityId)~="string" or type(r.actionId)~="string" then return send(p,r,false,"BadAction") end
  release(p,r.activityId,r.roundId)
  if openedActivities[p.UserId]==r.activityId and (r.roundId==nil or r.roundId==currentRounds[r.activityId]) then openedActivities[p.UserId]=nil end
  send(p,r,true,"Released"); broadcast(); return
 end
 if r.kind=="RequestJournal" then return send(p,r,true,"Journal",{journal=snapshot(p)}) end
 if r.kind=="RequestSnapshot" then return send(p,r,true,"Snapshot") end
 if r.kind=="Cake" then
  -- RecoverStart/RecoverCut are deliberately absent: PCW-24 owns explicit
  -- authenticated host override. All normal actions use one canonical path.
  r.actorUserId=uid(p)
  local called,result=pcall(cake.Apply,cake,r)
  if not called then
   warn("PCW-23 cake request failed",result)
   return send(p,r,false,"CakeRejected",{errorText="The cake choice could not be saved. Reopen the table and try again."})
  end
  advanceCake()
  local extra={cake=cake:GetState(uid(p)),result=result,receipt=result.receipt}
  if not result.ok then extra.errorText=result.message end
  send(p,r,result.ok==true,result.code,extra)
  if result.ok then broadcast() end
  return
 end
 send(p,r,false,"UnsupportedAction")
end)

local function releaseAll(p)
 openedActivities[p.UserId]=nil
 if hostService then hostService:ReleaseActor(p.UserId) end
 for _,a in pairs(activities) do if a.ReleaseActor then pcall(a.ReleaseActor,a,p.UserId) end end
end
local function bindPlayer(p)
 session:SetPresence(p.UserId,true); p:SetAttribute("MVPSessionId",sessionId)
 playerConnections[p.UserId]={
  p:GetAttributeChangedSignal("BirthdayLocation"):Connect(function()
   if p:GetAttribute("BirthdayLocation")~="World" then releaseAll(p) end
   broadcast()
  end),
  p.CharacterRemoving:Connect(function() releaseAll(p); broadcast() end),
 }
 send(p,{kind="RequestSnapshot"},true,"Snapshot")
end
Players.PlayerAdded:Connect(bindPlayer)
Players.PlayerRemoving:Connect(function(p)
 session:SetPresence(p.UserId,false); releaseAll(p)
 for _,connection in ipairs(playerConnections[p.UserId] or {}) do connection:Disconnect() end
 playerConnections[p.UserId]=nil; broadcast()
end)

local expiryElapsed=0
local seenQ01Expiry=0
local seenQ03Expiry=0
local seenQ06Expiry=0
local seenFoodVenues={}
local seenJasperVenues={}
RunService.Heartbeat:Connect(function(dt)
 expiryElapsed+=dt; if expiryElapsed<1 then return end; expiryElapsed=0
 local changed=advanceCake()
 -- A private snapshot may have advanced the seat/timer between heartbeats.
 -- Its new phase still has to reach every other participant.
 if broadcastFinaleRevision~=cake.revision then changed=true end
 local q01=activities.Q01
 if q01 then
  q01:ExpireReservations(now())
  -- GetView can expire a hold before this tick; its revision still reaches
  -- every open recipient instead of leaving another helper seeing In use.
  if q01.expiryRevision~=seenQ01Expiry then seenQ01Expiry=q01.expiryRevision; changed=true end
 end
 local q03=activities.Q03
 if q03 then
  q03:ExpireReservations()
  if q03.expiryRevision~=seenQ03Expiry then seenQ03Expiry=q03.expiryRevision; changed=true end
 end
 for _,p in ipairs(Players:GetPlayers()) do
  local venue=openedActivities[p.UserId]=="Q02" and (world.jasperVenue(p.UserId) or "away") or nil
  if venue~=seenJasperVenues[p.UserId] then seenJasperVenues[p.UserId]=venue; changed=true end
 end
 for actor in pairs(seenJasperVenues) do if not Players:GetPlayerByUserId(actor) then seenJasperVenues[actor]=nil end end
 local q06=activities.Q06
 if q06 then
  q06:ExpireReservations(now())
  if q06.expiryRevision~=seenQ06Expiry then seenQ06Expiry=q06.expiryRevision; changed=true end
  for _,p in ipairs(Players:GetPlayers()) do
   local venue=openedActivities[p.UserId]=="Q06" and (q06:GetVenue(p.UserId) or "away") or nil
   if venue~=seenFoodVenues[p.UserId] then seenFoodVenues[p.UserId]=venue; changed=true end
  end
  for actor in pairs(seenFoodVenues) do if not Players:GetPlayerByUserId(actor) then seenFoodVenues[actor]=nil end end
 end
 if changed then broadcast() end
end)
for id,name in pairs(station) do installPrompt(id,anchor(name)) end
installPrompt("Q02",anchor("JasperFetchYard")); installPrompt("Q04",anchor("Q04BedroomKindle")); installPrompt("Q06",anchor("Q06AladdinsCounter")); installPrompt("Q06",anchor("Q06Serving")); installPrompt("Cake",anchor("FinalePatio"))
installPrompt("Q03",anchor("Q03BedroomDisplay"))
for _,p in ipairs(Players:GetPlayers()) do bindPlayer(p) end
print("Phuong MVP server integration active",sessionId,"missing anchors:",table.concat(missingAnchors,","))
for name,defect in pairs(activityErrors) do warn("Activity "..name.." unavailable: "..defect) end
script.Destroying:Connect(function()
 if finaleFeedback then finaleFeedback:Destroy() end
 if CozyAudio.Destroy then pcall(CozyAudio.Destroy) end
end)
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

function QueueService:ResetAfterTransfer()
 if self.state ~= "Completed" and self.state ~= "Failed" then return false, "NotFinished" end
 self:_reset()
 return true, "Reset"
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
        initialRewards = {},
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
    if Config.EarningActivityIds[round.activityId] and not round.isReplay then self.initialRewards[round.activityId] = true end
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

-- Internal host recovery helpers. HostService owns confirmation, limits and
-- request deduplication; these helpers independently require a real host.
function SessionService:AssertRecovery(request)
    assert(request and request.sessionId == self.sessionId and self:IsPresent(request.actorUserId), "invalid recovery session")
    assert(request.actorUserId == Config.PhuongUserId or request.actorUserId == Config.HostUserId, "recovery host required")
    assert(type(request.actionId) == "string" and request.actionId ~= "", "recovery identity required")
    assert(self.petals[request.activityId] ~= nil, "unknown recovery activity")
end

function SessionService:MissingInitialReward(activityId)
    if not Config.EarningActivityIds[activityId] or self.initialRewards[activityId] then return 0 end
    for _, round in pairs(self.rounds) do
        if round.activityId == activityId and not round.isReplay and round.completionReceipt
            and (round.completionReceipt.fundRewardGranted or 0) >= Config.FirstRoundReward then return 0 end
    end
    return Config.FirstRoundReward
end

function SessionService:RecoverCancel(request)
    self:AssertRecovery(request)
    local round = self.rounds[request.roundId]
    assert(round and round.activityId == request.activityId and round.state == "IN_PROGRESS", "only incomplete rounds can restart")
    return self:CancelRound(request.roundId)
end

function SessionService:RecoverStep(request, stepId)
    self:AssertRecovery(request)
    local round = self.rounds[request.roundId]
    assert(round and round.activityId == request.activityId, "recovery round mismatch")
    if round.steps[stepId] then return round.steps[stepId] end
    assert(round.state == "IN_PROGRESS", "recovery round is not active")
    local accepted = { sessionId = self.sessionId, activityId = request.activityId, roundId = request.roundId,
        stepId = stepId, actionId = "host-step:" .. request.actionId .. ":" .. stepId, actorUserId = request.actorUserId, recovery = true }
    round.steps[stepId] = accepted; round.contributors[request.actorUserId] = true
    self.acceptedSteps[accepted.actionId] = accepted
    return accepted
end

function SessionService:RecoverCompleteRound(request)
    self:AssertRecovery(request)
    local round = self.rounds[request.roundId]
    assert(round and round.activityId == request.activityId and (round.state == "IN_PROGRESS" or round.state == "COMPLETED"), "recovery round mismatch")
    local key = "host-complete:" .. request.activityId
    if self.receipts[key] then return self.receipts[key] end
    local reward, petal = self:MissingInitialReward(request.activityId), not self.petals[request.activityId]
    self.petals[request.activityId] = true; self.fundBalance += reward
    if Config.EarningActivityIds[request.activityId] then self.initialRewards[request.activityId] = true end
    round.state = "COMPLETED"
    local receipt = { sessionId = self.sessionId, receiptId = key, activityId = request.activityId, roundId = request.roundId,
        recovery = true, petalGranted = petal, fundRewardGranted = reward, actorUserId = request.actorUserId }
    round.completionReceipt = round.completionReceipt or receipt
    self.receipts[key] = receipt; self.reservations[request.roundId] = nil
    return receipt
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
["roblox/mvp/server/WorldFeedback.luau"] = [=[-- PCW-22: bounded server presentation. No rewards, physics, camera or map rebuild.
local RunService = game:GetService("RunService")
local WorldFeedback = {}; WorldFeedback.__index = WorldFeedback
local V, CF = Vector3.new, CFrame.new
local P = {
	forest=Color3.fromHex("365744"), sage=Color3.fromHex("A8B995"), cream=Color3.fromHex("F5F0E4"),
	wood=Color3.fromHex("95674B"), blossom=Color3.fromHex("E8B7C6"), brick=Color3.fromHex("B66C68"),
	golden=Color3.fromHex("E8C779"), ink=Color3.fromHex("26382E"),
}
local PARTS = {"rug", "chair", "bookcase", "side_table", "plant", "lamp"}
local LABELS = {rug="Rug", chair="Chair", bookcase="Bookcase", side_table="Side table", plant="Plant", lamp="Lamp"}
local SOCKETS = {rug="rugSocket", chair="chairSocket", bookcase="bookcaseSocket", side_table="sideTableSocket", plant="plantSocket", lamp="lampSocket"}
local function folder(parent, name, class)
	local item=Instance.new(class or "Folder"); item.Name=name; item.Parent=parent; return item
end
local function part(parent, name, size, frame, token, soft)
	local unique,index=name,1
	while parent:FindFirstChild(unique) do index+=1; unique=name.."_"..index end
	local item=Instance.new("Part"); item.Name=unique; item.Size=size; item.CFrame=frame; item.Color=P[token]
	item.Anchored, item.CanCollide, item.CanTouch, item.CanQuery = true, false, false, false
	item.Material=Enum.Material.SmoothPlastic; item.TopSurface=Enum.SurfaceType.Smooth; item.BottomSurface=Enum.SurfaceType.Smooth
	item:SetAttribute("PaletteToken",token); item:SetAttribute("VerificationTicket","PCW-22"); item.Parent=parent
	if soft then local mesh=Instance.new("SpecialMesh"); mesh.MeshType=Enum.MeshType.Sphere; mesh.Parent=item end
	return item
end
local function label(target, text, width, offset)
	local gui=Instance.new("BillboardGui"); gui.Name="ActivityCaption"; gui.Adornee=target
	gui.Size=UDim2.fromOffset(width or 210,50); gui.StudsOffsetWorldSpace=offset or V(0,1,0)
	gui.MaxDistance=30; gui.AlwaysOnTop=false; gui.Parent=target
	local value=Instance.new("TextLabel"); value.Name="Caption"; value.Size=UDim2.fromScale(1,1)
	value.BackgroundColor3=P.cream; value.TextColor3=P.ink; value.BorderSizePixel=0; value.TextWrapped=true
	value.Font=Enum.Font.GothamMedium; value.TextSize=14; value.Text=text; value.Parent=gui
	return value
end
local function anchorFrame(anchors, name)
	local item=anchors[name]; return item and item:IsA("BasePart") and item.CFrame or nil
end
local function face(a, b)
	local direction=V(b.X-a.X,0,b.Z-a.Z)
	return direction.Magnitude>.01 and CFrame.lookAt(a,a+direction) or CF(a)
end
function WorldFeedback:_hide(item)
	if not item then return end
	local items=item:IsA("BasePart") and {item} or item:GetDescendants()
	for _, value in ipairs(items) do
		if value:IsA("BasePart") then
			self.hidden[value]={value.Transparency,value.CanCollide,value.CanTouch,value.CanQuery}
			value.Transparency, value.CanCollide, value.CanTouch, value.CanQuery=1,false,false,false
		end
	end
end

local function makeDog(parent)
	local model=folder(parent,"Actor","Model")
	model:SetAttribute("JasperActor",true); model:SetAttribute("SimplifiedGeometry",true)
	model:SetAttribute("ArtStatus","Palette-native simplified Pomeranian; independent visual review pending")
	local function p(name,size,position,token) return part(model,name,size,CF(position),token,true) end
	p("FluffyBody",V(2.25,1.75,2.65),V(0,1.45,.3),"wood")
	p("CreamRuff",V(2.6,2.15,1.7),V(0,1.95,-.6),"cream")
	p("Chest",V(1.6,1.6,1.6),V(0,1.3,-.75),"cream")
	p("Head",V(1.95,1.75,1.8),V(0,2.65,-1.05),"wood")
	p("Muzzle",V(1.1,.7,.75),V(0,2.33,-1.97),"cream")
	p("Nose",V(.29,.25,.2),V(0,2.43,-2.36),"ink")
	for _, side in ipairs({-1,1}) do
		p("Eye",V(.22,.26,.14),V(side*.46,2.78,-1.9),"ink")
		local ear=Instance.new("WedgePart"); ear.Name=side<0 and "PointedEarLeft" or "PointedEarRight"; ear.Size=V(.68,1.05,.6)
		ear.CFrame=CF(side*.7,3.43,-1.01)*CFrame.Angles(0,math.pi,side*-.15)
		ear.Color=P.wood; ear.Anchored=true; ear.CanCollide=false; ear.CanTouch=false; ear.CanQuery=false
		ear:SetAttribute("PaletteToken","wood"); ear:SetAttribute("VerificationTicket","PCW-22"); ear.Parent=model
		for _, z in ipairs({-.55,1.03}) do p("ShortLeg",V(.57,.88,.65),V(side*.72,.45,z),"wood") end
	end
	for index=1,5 do
		local angle=(index-1)*math.pi/4
		p("CurledTail",V(.85,.9,.88),V(0,1.85+math.sin(angle)*.82,1.48+math.cos(angle)*.65),"cream")
	end
	for index=1,6 do
		local angle=index*math.pi/3
		p("RuffTuft",V(.75,.8,.85),V(math.cos(angle)*1.02,1.95+math.sin(angle)*.82,-.6),"cream")
	end
	model.WorldPivot=CF(); return model -- 25 anchored/noncolliding parts; pivot is at feet.
end
local function findDog(root, runtime)
	for _, item in ipairs(root:GetDescendants()) do
		if item:IsA("Model") and not item:IsDescendantOf(runtime) and (item.Name=="Jasper" or item:GetAttribute("JasperActor")==true) then
			local parent, plush=item.Parent,false
			while parent and parent~=root do
				if string.find(string.lower(parent.Name),"plush",1,true) then plush=true end
				parent=parent.Parent
			end
			if not plush and not string.find(string.lower(item.Name),"plush",1,true) and item:FindFirstChildWhichIsA("BasePart",true) then return item end
		end
	end
end
function WorldFeedback.new(root, mvp, anchors)
	local runtime=mvp:FindFirstChild("RuntimePresentation") or folder(mvp,"RuntimePresentation")
	assert(not runtime:FindFirstChild("WorldFeedback") and not runtime:FindFirstChild("Jasper"),"WorldFeedback is already running")
	local self=setmetatable({root=folder(runtime,"WorldFeedback"),jasper=folder(runtime,"Jasper"),hidden={},queue={},elapsed=0,actorParts={}},WorldFeedback)
	self.root:SetAttribute("VerificationTicket","PCW-22"); self.jasper:SetAttribute("VerificationTicket","PCW-22")
	self.bedroom=anchorFrame(anchors,"JasperBedroomStart")
	self.yard=anchorFrame(anchors,"JasperFetchYard")
	if self.bedroom then self.bedroom+=V(0,.1,0) end
	if self.yard then self.yard+=V(0,.1,0) end
	local home=root:FindFirstChild("Home"); local door=home and home:FindFirstChild("DoorInteraction")
	local porch=home and home:FindFirstChild("PorchDeck")
	if door and door:IsA("BasePart") and self.yard then
		self.doorPosition=V(door.Position.X,self.yard.Y,door.Position.Z)
		if porch and porch:IsA("BasePart") then
			local outward=V(porch.Position.X-door.Position.X,0,porch.Position.Z-door.Position.Z)
			if outward.Magnitude>.1 then self.porchPosition=self.doorPosition+outward.Unit*12 end
		end
	end
	if self.bedroom and self.yard then
		self.actor=findDog(root,runtime)
		if self.actor then
			self.originalPivot=self.actor:GetPivot()
			local box,size=self.actor:GetBoundingBox()
			self.footOffset=self.originalPivot:ToObjectSpace(CF(box.Position-V(0,size.Y/2,0)))
			for _, item in ipairs(self.actor:GetDescendants()) do
				if item:IsA("BasePart") then
					self.actorParts[item]={item.Anchored,item.CanCollide,item.CanTouch,item.CanQuery}
					item.Anchored,item.CanCollide,item.CanTouch,item.CanQuery=true,false,false,false
				end
			end
		else self.actor=makeDog(self.jasper); self.footOffset=CF() end
		self.cue=part(self.jasper,"JasperCue",V(.1,.1,.1),self.bedroom,"forest"); self.cue.Transparency=1
		self.jasperText=label(self.cue,"Jasper · say hello in the bedroom",240,V(0,4.4,0))
		self.rabbit=folder(self.jasper,"RabbitToy","Model")
		part(self.rabbit,"Body",V(.65,.65,.9),CF(0,.35,0),"cream",true)
		part(self.rabbit,"Head",V(.55,.55,.5),CF(0,.8,-.2),"cream",true)
		for _, x in ipairs({-.17,.17}) do
			part(self.rabbit,"LongEar",V(.18,.65,.18),CF(x,1.3,-.18),"cream",true)
			part(self.rabbit,"Eye",V(.06,.06,.05),CF(x,.85,-.46),"ink",true)
		end
		self.rabbit.WorldPivot=CF()
		self.ball=part(self.jasper,"FetchToy",V(.6,.6,.6),self.yard,"blossom",true)
		self.target=part(self.jasper,"FetchTarget",V(3,.05,3),self.yard,"golden")
		self.targetText=label(self.target,"Gentle throw · no aiming needed",210,V(0,.7,0))
		self.treat=part(self.jasper,"Greenie",V(.32,.25,1.1),self.yard,"forest")
		local stations=mvp:FindFirstChild("Stations"); local q02=stations and stations:FindFirstChild("Q02Station")
		for _, name in ipairs({"JasperBedroomGreeting","JasperFetchLane","JasperRabbitHandoff","JasperGreenie"}) do self:_hide(q02 and q02:FindFirstChild(name,true)) end
		self.baskets={}
		for index=1,3 do
			local original=q02 and q02:FindFirstChild("JasperRabbitBasket"..string.char(64+index),true)
			local frame=original and original:IsA("BasePart") and original.CFrame or self.yard*CF((index-2)*4,1,5)
			local cue=part(self.jasper,"BasketLabel"..index,V(.1,.1,.1),frame,"wood"); cue.Transparency=1
			self.baskets[index]=frame; label(cue,"Basket "..index,120,V(0,1.7,0))
		end
		self:ResetJasper()
	end
	self:_setupCraft(root,mvp,anchors)
	self.readingFrames={}
	for _, name in ipairs({"Q04QuadReading","Q04BedroomKindle"}) do
		local frame=anchorFrame(anchors,name)
		if frame then self.readingFrames[name]=frame*CF(name=="Q04BedroomKindle" and 1.1 or 1.3,name=="Q04BedroomKindle" and .23 or 1.3,0) end
	end
	self:RenderReading(nil)
	self.connection=RunService.Heartbeat:Connect(function(dt)
		self.elapsed+=dt; if self.elapsed<.05 then return end
		local elapsed=self.elapsed; self.elapsed=0
		local ok,err=pcall(self._tick,self,elapsed)
		if not ok then
			self.queue={}; self.active=nil
			-- Interrupted cosmetics cannot lock gameplay. Return to the authoritative location.
			pcall(function() self:_pose(self.jasperAtYard and self.yard or self.bedroom); self:_settleJasper() end)
			warn("PCW-22 Jasper presentation recovered",err)
		end
	end)
	return self
end
function WorldFeedback:_pose(frame)
	if not self.actor or not self.actor.Parent or not frame then return end
	self.actor:PivotTo(frame*self.footOffset:Inverse()); self.actorFrame=frame; self.cue.CFrame=frame
end
function WorldFeedback:_toyVisible(model,visible)
	if model:IsA("BasePart") then model.Transparency=visible and 0 or 1; return end
	for _, item in ipairs(model:GetDescendants()) do if item:IsA("BasePart") then item.Transparency=visible and 0 or 1 end end
end
function WorldFeedback:ResetJasper(roundId)
	self.queue={}; self.active=nil; self.jasperAtYard=false; self.rabbitState="hidden"; self.targetIndex=nil; self.treated=false
	self.jasper:SetAttribute("RoundId",roundId)
	if not self.actor then return end
	self:_pose(self.bedroom); self:_toyVisible(self.rabbit,false); self.ball.Transparency=1; self.target.Transparency=1; self.treat.Transparency=1
	self.targetText.Parent.Enabled=false; self.jasperText.Text="Jasper · say hello in the bedroom"
end
function WorldFeedback:_enqueue(kind,index)
	if not self.actor then return end
	-- Seven required presentations at most; repeated optional pets coalesce.
	if kind=="pet" then
		if self.active or #self.queue>0 then return end
	end
	if #self.queue<8 then table.insert(self.queue,{kind=kind,index=index,age=0}) end
end
function WorldFeedback:MoveJasperToYard() self.jasperAtYard=true; self:_enqueue("lead") end
function WorldFeedback:ShowRabbitPickup(index) self.rabbitState="found"; self:_enqueue("pickup",index) end
function WorldFeedback:ReturnRabbit() self.rabbitState="returned"; self:_enqueue("return") end
function WorldFeedback:PresentFetchTarget(index) self.targetIndex=index; if not self.active and #self.queue==0 then self:_settleJasper() end end
function WorldFeedback:FetchJasper(index) self:_enqueue("fetch",index) end
function WorldFeedback:GiveJasperTreat() self.treated=true; self.targetIndex=nil; self:_enqueue("treat") end
function WorldFeedback:PetJasper() self:_enqueue("pet") end
function WorldFeedback:_fetchPoint(index)
	return self.yard*CF((index-2)*3.2,.04,-(5+index*2))
end
function WorldFeedback:_settleJasper()
	if not self.actor then return end
	self:_pose(self.jasperAtYard and self.yard or self.bedroom)
	self:_toyVisible(self.rabbit,self.rabbitState~="hidden")
	self.rabbit:PivotTo(self.yard*CF(self.rabbitState=="found" and 2.3 or -2.3,.1,1.4))
	self.ball.Transparency=self.targetIndex and 0 or 1; self.ball.CFrame=self.yard*CF(1.8,.4,0)
	self.target.Transparency=self.targetIndex and .2 or 1; self.targetText.Parent.Enabled=self.targetIndex~=nil
	if self.targetIndex then self.target.CFrame=self:_fetchPoint(self.targetIndex); self.targetText.Text="Throw "..self.targetIndex.." of 3 · no aiming needed" end
	self.treat.Transparency=self.treated and 0 or 1; self.treat.CFrame=self.yard*CF(0,.35,-2.4)
	self.jasperText.Text=self.treated and "Jasper is happy · thank you!" or self.targetIndex and "Jasper · ready to fetch" or self.rabbitState=="found" and "Rabbit found · return it to Jasper" or self.jasperAtYard and "Jasper · find his rabbit in a basket" or "Jasper · say hello in the bedroom"
end
function WorldFeedback:_tick(dt)
	if not self.actor then return end
	if not self.active then self.active=table.remove(self.queue,1); if not self.active then return end end
	local action=self.active; action.age+=dt
	local age=action.age; local duration=1
	if action.kind=="lead" then
		duration=5
		local start,finish=self.bedroom.Position,self.yard.Position
		local route={start,self.doorPosition or start,self.porchPosition or finish,finish}
		local value=math.clamp(age/duration,0,.9999)*3; local index=math.floor(value)+1
		self:_pose(face(route[index]:Lerp(route[index+1],value%1),route[index+1]))
		self.jasperText.Text="Jasper is heading to his yard · follow the marker"
	elseif action.kind=="fetch" then
		duration=2.8
		local target=self:_fetchPoint(action.index); local base=self.yard
		self.target.CFrame=target; self.target.Transparency=.2; self.targetText.Parent.Enabled=true
		self.targetText.Text="Fetch "..action.index.." of 3"
		self.ball.Transparency=0
		if age<.55 then
			local alpha=age/.55
			self.ball.CFrame=base:Lerp(target,alpha)*CF(0,.45+math.sin(alpha*math.pi)*2.4,0)
			self:_pose(base)
		elseif age<1.6 then
			self.ball.CFrame=target*CF(0,.35,0)
			self:_pose(face(base.Position:Lerp(target.Position,(age-.55)/1.05),target.Position))
		else
			self:_pose(face(target.Position:Lerp(base.Position,math.clamp((age-1.6)/1.2,0,1)),base.Position))
			self.ball.CFrame=self.actorFrame*CF(0,1.35,-2.1)
		end
		self.jasperText.Text="Jasper · fetching toy "..action.index
	elseif action.kind=="pickup" then
		self:_pose(self.yard); self:_toyVisible(self.rabbit,true)
		local basket=self.baskets[action.index] or self.yard
		self.rabbit:PivotTo(basket:Lerp(self.yard*CF(2.3,1.2,1.4),math.clamp(age,0,1)))
		self.jasperText.Text="You found Jasper's rabbit!"
	elseif action.kind=="return" then
		self:_pose(self.yard); self:_toyVisible(self.rabbit,true)
		self.rabbit:PivotTo((self.yard*CF(2.3,1.2,1.4)):Lerp(self.yard*CF(0,1.3,-2.1),math.clamp(age,0,1)))
		self.jasperText.Text="Jasper has his rabbit · ready for toys"
	else
		self:_pose(self.yard*CF(0,math.sin(math.clamp(age,0,1)*math.pi)*.2,0)*CFrame.Angles(0,math.sin(age*8)*.08,0))
		self.jasperText.Text=action.kind=="treat" and "A Greenie for Jasper · thank you!" or "Jasper leans in for a gentle pet"
		if action.kind=="treat" then self.treat.Transparency=0; self.treat.CFrame=self.yard*CF(0,1.2,-2.3) end
	end
	if age>=duration then self.active=nil; if #self.queue==0 then self:_settleJasper() end end
end

function WorldFeedback:_setupCraft(root,mvp,anchors)
	self.craft=folder(self.root,"Craft"); self.craftFrames={}
	local stations=mvp:FindFirstChild("Stations"); local station=stations and stations:FindFirstChild("Q03Station")
	local tableTop=station and station:FindFirstChild("CraftTable",true)
	local booth=anchorFrame(anchors,"Q03FairCraft")
	if booth then self.craftFrames.Booth={frame=tableTop and tableTop:IsA("BasePart") and tableTop.CFrame*CF(0,tableTop.Size.Y/2+.05,0) or booth*CF(0,2.05,0),scale=1} end
	-- Replace only obsolete Q03 marker/piece visuals, never the original furniture.
	if station then for _, child in ipairs(station:GetChildren()) do if child.Name~="CraftTable" then self:_hide(child) end end end
	local home=root:FindFirstChild("Home"); local room=home and home:FindFirstChild("Bedroom")
	local bookcase=room and room:FindFirstChild("FilledBookcase")
	local plinth=bookcase and bookcase:FindFirstChild("DisplayPlinth")
	if plinth and plinth:IsA("BasePart") then
		self.craftFrames.Bedroom={frame=plinth.CFrame*CF(0,plinth.Size.Y/2+.015,0),scale=.38}
		for _, child in ipairs(bookcase:GetChildren()) do
			if child.Name=="MiniatureFacade" or child.Name=="MiniatureDoor" or string.match(child.Name,"^MiniatureWindow") then self:_hide(child) end
		end
		self.craft:SetAttribute("OwnedRegion","Existing lower DisplayPlinth; original plinth, desk miniature and all other shelf contents preserved")
	else warn("PCW-22 lower miniature plinth unavailable; booth and authoritative UI remain available") end
	self:RenderCraft(nil,{}, {},nil)
end
local function tinyPiece(parent,id,frame,scale,orientation,ghost,lit)
	local model=folder(parent,"Piece_"..id,"Model"); local base=frame*CFrame.Angles(0,math.rad((orientation or 0)*90),0)
	local function p(name,size,offset,token,soft)
		local item=part(model,name,size*scale,base*CF(offset*scale),token,soft)
		if ghost then item.Transparency=.6 end
		return item
	end
	if id=="rug" then p("WovenRug",V(1.55,.08,1.1),V(0,.07,0),"sage")
	elseif id=="chair" then
		p("Seat",V(.9,.3,.8),V(0,.55,0),"sage",true); p("Back",V(.9,.9,.2),V(0,.9,-.35),"sage",true)
		for _, x in ipairs({-.3,.3}) do for _, z in ipairs({-.24,.24}) do p("Leg",V(.12,.4,.12),V(x,.22,z),"wood") end end
	elseif id=="bookcase" then
		p("Back",V(1,1.5,.16),V(0,.78,-.2),"wood")
		for _, y in ipairs({.13,.77,1.48}) do p("Shelf",V(1,.12,.55),V(0,y,0),"wood") end
		for index,token in ipairs({"forest","cream","blossom"}) do p("Book",V(.18,.45,.32),V((index-2)*.22,1.04,0),token) end
	elseif id=="side_table" then p("Top",V(.95,.13,.8),V(0,.8,0),"wood"); p("Stem",V(.2,.7,.2),V(0,.38,0),"wood"); p("Foot",V(.65,.1,.6),V(0,.05,0),"wood")
	elseif id=="plant" then
		p("Pot",V(.5,.48,.5),V(0,.25,0),"cream"); p("Stem",V(.1,.7,.1),V(0,.7,0),"forest")
		for _, x in ipairs({-.23,0,.23}) do p("Leaf",V(.38,.5,.25),V(x,.94+math.abs(x),0),"sage",true) end
	elseif id=="lamp" then
		p("Base",V(.55,.1,.55),V(0,.08,0),"wood"); p("Stem",V(.1,1,.1),V(0,.6,0),"wood")
		p("Shade",V(.65,.4,.65),V(0,1.23,0),lit and "golden" or "cream",true)
	end
	model:SetAttribute("Orientation",orientation or 0); model:SetAttribute("PreviewOnly",ghost==true)
	return model
end
function WorldFeedback:RenderCraft(roundId,committed,reservations,presentation)
	self.craft:ClearAllChildren(); self.craft:SetAttribute("RoundId",roundId)
	for name,placement in pairs(self.craftFrames) do
		local model=folder(self.craft,name,"Model"); local cf,s=placement.frame,placement.scale
		model:SetAttribute("SharedRoundId",roundId); model:SetAttribute("Presentation",presentation)
		part(model,"Base",V(7.2,.1,3.8)*s,cf,"wood")
		local count=0
		for index,id in ipairs(PARTS) do
			local socket=SOCKETS[id]; local entry=committed[id]; local hold=reservations[socket]
			local frame=cf*CF((((index-1)%3)-1)*2.25*s,.085*s,(math.floor((index-1)/3)-.5)*1.65*s)
			local pad=part(model,socket,V(1.8,.06,1.4)*s,frame,entry and "sage" or hold and "golden" or "cream")
			pad:SetAttribute("SocketId",socket); pad:SetAttribute("PartId",id)
			if name=="Booth" then
				-- Flat, bounded labels; never six large world billboards at a time.
				local gui=Instance.new("SurfaceGui"); gui.Name="SocketLabel"; gui.Face=Enum.NormalId.Top; gui.CanvasSize=Vector2.new(240,130); gui.Parent=pad
				local text=Instance.new("TextLabel"); text.Size=UDim2.fromScale(1,1); text.BackgroundTransparency=1; text.TextColor3=P.ink
				text.Font=Enum.Font.GothamBold; text.TextSize=26; text.TextWrapped=true
				text.Text=(entry and "✓ " or hold and "○ " or "")..LABELS[id]; text.Parent=gui
			end
			if entry or hold then tinyPiece(model,id,frame,s,entry and entry.orientation or hold.orientation,entry==nil,presentation=="lamp_on") end
			if entry then count+=1 end
		end
		local cue=part(model,"ProgressCue",V(.1,.1,.1),cf*CF(0,2.3*s,-1.8*s),"forest"); cue.Transparency=1
		label(cue,(count==6 and (presentation and "Keepsake finished" or "Ready for Phuong's finishing touch") or "Shared miniature · "..count.." of 6").."\nBooth + bedroom share this keepsake",250,V(0,.5,0))
		model.WorldPivot=cf
	end
end
function WorldFeedback:RenderReading(summary)
	if self.reading then self.reading:Destroy() end
	self.reading=folder(self.root,"Reading")
	-- A new helper's first highlight must not erase the last shared bookmark.
	if summary and summary.bookmark then self.lastBookmark=summary end
	local saved=summary and summary.bookmark and summary or self.lastBookmark
	local bookmark=saved and saved.bookmark
	for name,frame in pairs(self.readingFrames) do
		local model=folder(self.reading,name,"Model")
		local base=part(model,"SharedBookmarkCard",V(1.1,.07,.8),frame,"cream")
		if summary then part(model,"SavedChoiceAccent",V(.8,.025,.08),frame*CF(0,.05,.3),"sage") end
		if bookmark=="ribbon" then part(model,"Ribbon",V(.2,.045,1.05),frame*CF(0,.055,.13),"blossom")
		elseif bookmark=="pressed-flower" then
			part(model,"Stem",V(.06,.04,.5),frame*CF(0,.055,.14),"forest")
			for index=1,5 do local a=index*math.pi*2/5; part(model,"Petal",V(.24,.04,.2),frame*CF(math.cos(a)*.16,.07,-.16+math.sin(a)*.16),"blossom",true) end
			part(model,"FlowerCenter",V(.12,.05,.12),frame*CF(0,.08,-.16),"golden",true)
		elseif bookmark=="star-tab" then
			for index=1,3 do part(model,"StarTab",V(.5,.04,.16),frame*CF(0,.06,-.4)*CFrame.Angles(0,index*math.pi/3,0),"golden") end
		end
		local text=summary and (summary.bookmark and "Bookmark saved · "..summary.bookmarkLabel.."\n"..summary.reactionLabel or summary.acknowledgement..(saved and "\nLatest bookmark · "..saved.bookmarkLabel or "")) or "Read a quiet page · save a bookmark"
		label(base,text,225,V(0,.85,0)); model:SetAttribute("Bookmark",bookmark)
	end
end
function WorldFeedback:Destroy()
	if self.connection then self.connection:Disconnect() end
	self.queue={}; self.active=nil
	for item,values in pairs(self.hidden) do if item.Parent then item.Transparency,item.CanCollide,item.CanTouch,item.CanQuery=values[1],values[2],values[3],values[4] end end
	if self.originalPivot and self.actor.Parent then self.actor:PivotTo(self.originalPivot) end
	for item,values in pairs(self.actorParts) do if item.Parent then item.Anchored,item.CanCollide,item.CanTouch,item.CanQuery=values[1],values[2],values[3],values[4] end end
	self.jasper:Destroy(); self.root:Destroy()
end
return WorldFeedback
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
["roblox/mvp/shared/AudioConfig.luau"] = [=[-- PCW-26. Install this same source under both PhuongMVP.shared roots.
-- These are the selected IDs, not an assertion of permission or audition.
return {
    Music = {
        Birthday = { id = "87992648461099", title = "Birthday song", volume = .22 },
        World = { id = "139568344220252", title = "Slow Mornings · gentle acoustic guitar", volume = .18 },
    },
    Effects = {
        SoftClick = { id = "88442833509532", volume = .18 },
        SuccessChime = { id = "103516326607012", volume = .22 },
        JasperBark = { id = "135016436724006", volume = .25 },
        JasperPant = { id = "6463651038", volume = .10 },
    },
    DefaultMusicVolume = .5,
    VolumeStep = .25,
    CrossfadeSeconds = .65,
    LoadTimeoutSeconds = 8,
    ReceiptLimit = 4096,
}
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
["roblox/mvp/shared/FigureCatalog.luau"] = [=[-- Session IDs/probabilities stay in Config. These are palette-constrained toy
-- interpretations, not reference-approved Big into Energy colors or likenesses.
local Config = require(script.Parent.Config)
local Catalog = { Figures = {}, ById = {} }
local styles = {
	{ label = "Love", body = "blossom", accent = "golden", badge = "heart" },
	{ label = "Happiness", body = "golden", accent = "cream", badge = "sun" },
	{ label = "Loyalty", body = "forest", accent = "sage", badge = "pair" },
	{ label = "Serenity", body = "sage", accent = "cream", badge = "moon" },
	{ label = "Hope", body = "cream", accent = "blossom", badge = "bow" },
	{ label = "Luck", body = "wood", accent = "golden", badge = "clover" },
	{ label = "Secret · ID", body = "brick", accent = "ink", badge = "star" },
}
for index, style in ipairs(styles) do
	local entry = {
		id = Config.RegularFigureIds[index] or Config.SecretFigureId,
		label = style.label, body = style.body, accent = style.accent, badge = style.badge,
		secret = index == 7, probability = index == 7 and Config.SecretProbability or Config.RegularProbability,
		odds = index == 7 and "Secret · 1%" or "Regular · 16.5%",
	}
	table.insert(Catalog.Figures, entry); Catalog.ById[entry.id] = entry
end
function Catalog.Label(id) return Catalog.ById[id] and Catalog.ById[id].label or "Choose a figure" end
return Catalog
]=],
["roblox/mvp/shared/FigurePresentation.luau"] = [=[-- Bounded native geometry shared by world displays and client ViewportFrames.
-- All figures retain paired long ears, a cream face, eyes, a toothy smile,
-- rounded body and feet. Labels distinguish the seven simplified toy styles.
local Catalog = require(script.Parent.FigureCatalog)
local Presentation = {}
Presentation.Palette = {
	forest = Color3.fromRGB(54, 87, 68), sage = Color3.fromRGB(168, 185, 149),
	cream = Color3.fromRGB(245, 240, 228), wood = Color3.fromRGB(149, 103, 75),
	blossom = Color3.fromRGB(232, 183, 198), brick = Color3.fromRGB(182, 108, 104),
	golden = Color3.fromRGB(232, 199, 121), ink = Color3.fromRGB(38, 56, 46),
}
function Presentation.Part(parent, name, size, cf, token, shape)
	local value = Instance.new("Part")
	value.Name, value.Size, value.CFrame = name, size, cf
	value.Shape = shape or Enum.PartType.Block
	value.Color, value.Material, value.CastShadow = Presentation.Palette[token], Enum.Material.SmoothPlastic, false
	value.Anchored, value.CanCollide, value.CanTouch, value.CanQuery = true, false, false, false
	value:SetAttribute("PaletteToken", token); value:SetAttribute("VerificationTicket", "PCW-21")
	value.Parent = parent; return value
end
function Presentation.Build(id, scale)
	local entry = assert(Catalog.ById[id], "Unknown figure presentation")
	local model = Instance.new("Model"); model.Name = "Figure"; model.WorldPivot = CFrame.identity
	model:SetAttribute("FigureId", id); model:SetAttribute("FigureLabel", entry.label)
	model:SetAttribute("SimplifiedArt", true); model:SetAttribute("VerificationTicket", "PCW-21")
	scale = scale or 1
	local function shape(name, size, position, token, block, rotation)
		return Presentation.Part(model, name, size * scale, CFrame.new(position * scale) * (rotation or CFrame.identity), token, block and Enum.PartType.Block or Enum.PartType.Ball)
	end
	shape("Body", Vector3.new(1.04, 1.2, .72), Vector3.new(0, .88, 0), entry.body)
	shape("Head", Vector3.new(1.32, 1.08, .84), Vector3.new(0, 1.8, 0), entry.body)
	shape("Face", Vector3.new(1.05, .78, .23), Vector3.new(0, 1.76, -.4), "cream")
	for _, side in ipairs({ -1, 1 }) do
		local tilt = CFrame.Angles(0, 0, -side * .12)
		shape("LongEar", Vector3.new(.37, 1, .35), Vector3.new(side * .38, 2.58, .01), entry.body, false, tilt)
		shape("InnerEar", Vector3.new(.16, .67, .08), Vector3.new(side * .38, 2.58, -.17), entry.accent, false, tilt)
		shape("Eye", Vector3.new(.13, .17, .07), Vector3.new(side * .24, 1.89, -.53), "ink")
		shape("Arm", Vector3.new(.29, .65, .35), Vector3.new(side * .57, .99, -.01), entry.body, false, CFrame.Angles(0, 0, side * .18))
		shape("Foot", Vector3.new(.45, .27, .55), Vector3.new(side * .3, .16, -.12), entry.body)
	end
	shape("ToothySmile", Vector3.new(.55, .2, .06), Vector3.new(0, 1.57, -.53), "ink")
	for index = 1, 5 do shape("Tooth", Vector3.new(.065, .095, .035), Vector3.new((index - 3) * .09, 1.605, -.568), "cream", true) end
	-- Distinct small chest motifs, never a replacement for the paired-ear shape.
	local badge = Vector3.new(0, .98, -.37)
	if entry.badge == "heart" then
		for _, side in ipairs({ -1, 1 }) do shape("Heart", Vector3.new(.24, .34, .07), badge + Vector3.new(side * .085, 0, 0), entry.accent, false, CFrame.Angles(0, 0, side * -.55)) end
	elseif entry.badge == "pair" or entry.badge == "bow" then
		for _, side in ipairs({ -1, 1 }) do shape("PairedBadge", Vector3.new(.23, .22, .08), badge + Vector3.new(side * .13, 0, 0), entry.accent) end
	elseif entry.badge == "clover" then
		for index = 1, 4 do local angle = index * math.pi / 2; shape("Clover", Vector3.new(.2, .2, .07), badge + Vector3.new(math.cos(angle) * .11, math.sin(angle) * .11, 0), entry.accent) end
	elseif entry.badge == "star" then
		shape("SecretBadge", Vector3.new(.3, .3, .07), badge, entry.accent, true, CFrame.Angles(0, 0, math.pi / 4))
	else
		shape("RoundBadge", Vector3.new(.34, .34, .08), badge, entry.accent)
		if entry.badge == "moon" then shape("MoonCutout", Vector3.new(.26, .26, .04), badge + Vector3.new(.1, .05, -.05), entry.body) end
	end
	return model
end
function Presentation.Capsule(scale, opened)
	scale = scale or 1
	local model = Instance.new("Model"); model.Name = "Capsule"; model.WorldPivot = CFrame.identity
	model:SetAttribute("VerificationTicket", "PCW-21")
	Presentation.Part(model, "Lower", Vector3.new(1.5, .9, 1.5) * scale, CFrame.new(0, .45 * scale, 0), "golden", Enum.PartType.Ball)
	Presentation.Part(model, "Upper", Vector3.new(1.5, .9, 1.5) * scale, CFrame.new(0, (opened and 1.8 or 1.02) * scale, 0), "cream", Enum.PartType.Ball)
	Presentation.Part(model, "Seam", Vector3.new(.08, 1.49, 1.49) * scale, CFrame.new(0, .74 * scale, 0) * CFrame.Angles(0, 0, math.pi / 2), "forest", Enum.PartType.Cylinder)
	return model
end
return Presentation
]=],
["roblox/mvp/shared/FoodPresentation.luau"] = [=[-- Deterministic presentation only. Server and local preview use the same shapes.
-- No rewards, permissions, remote requests or user transforms belong here.
local FoodPresentation = {}
local P = {
	forest = Color3.fromRGB(54, 87, 68), sage = Color3.fromRGB(168, 185, 149),
	cream = Color3.fromRGB(245, 240, 228), wood = Color3.fromRGB(149, 103, 75),
	blossom = Color3.fromRGB(232, 183, 198), brick = Color3.fromRGB(182, 108, 104),
	golden = Color3.fromRGB(232, 199, 121), ink = Color3.fromRGB(38, 56, 46),
}
local LABELS = { rice = "Rice", tofu = "Tofu", chicken = "Chicken", mushroom = "Mushroom", greens = "Greens", cucumber = "Cucumber", carrot = "Carrot", sauce = "Sauce", sesame = "Sesame", plate = "Plate", cup = "Cup", napkin = "Napkin" }
local ORDER = { "base", "protein", "toppings", "sauce", "settingA", "settingB" }
local function part(parent, name, size, frame, token, shape)
	local value = Instance.new("Part")
	value.Name, value.Size, value.CFrame = name, size, frame
	value.Shape = shape or Enum.PartType.Block
	value.Anchored, value.CanCollide, value.CanTouch, value.CanQuery = true, false, false, false
	value.Color, value.Material, value.CastShadow = P[token], Enum.Material.SmoothPlastic, false
	value:SetAttribute("PaletteToken", token); value:SetAttribute("VerificationTicket", "PCW-20")
	value.Parent = parent; return value
end
local function disc(parent, name, diameter, height, frame, token)
	return part(parent, name, Vector3.new(height, diameter, diameter), frame * CFrame.Angles(0, 0, math.pi / 2), token, Enum.PartType.Cylinder)
end
local function round(parent, name, size, frame, token)
	return part(parent, name, size, frame, token, Enum.PartType.Ball)
end
local function ingredient(parent, slot, item)
	local model = Instance.new("Model"); model.Name = slot; model.Parent = parent
	model:SetAttribute("SlotId", slot); model:SetAttribute("ItemId", item); model:SetAttribute("ItemLabel", LABELS[item])
	local y = .65
	if item == "rice" then
		disc(model, "RiceBase", 2.05, .16, CFrame.new(0, .49, 0), "cream")
		for index = 1, 8 do
			local angle = index * math.pi / 4
			round(model, "RiceGrain", Vector3.new(.27, .1, .12), CFrame.new(math.cos(angle) * .7, .6, math.sin(angle) * .7) * CFrame.Angles(0, angle, 0), "cream")
		end
	elseif item == "tofu" or item == "chicken" then
		for index = 1, 4 do
			local frame = CFrame.new(-.55 + (index % 2) * .65, y + .08, -.62 + math.floor((index - 1) / 2) * .6) * CFrame.Angles(0, index * .35, 0)
			if item == "tofu" then part(model, "TofuCube", Vector3.new(.45, .34, .45), frame, "cream")
			else round(model, "ChickenPiece", Vector3.new(.58, .34, .42), frame, "golden") end
		end
	elseif item == "mushroom" then
		for index = 1, 3 do
			local frame = CFrame.new(-.72 + index * .38, y, -.45 + (index % 2) * .43)
			part(model, "MushroomStem", Vector3.new(.14, .3, .15), frame, "cream")
			round(model, "MushroomCap", Vector3.new(.52, .23, .43), frame * CFrame.new(0, .17, 0), "wood")
		end
	elseif item == "greens" then
		for index = 1, 5 do round(model, "Leaf", Vector3.new(.38, .12, .55), CFrame.new(-.8 + index * .29, y + .1, .53 + (index % 2) * .15) * CFrame.Angles(0, index * .75, .2), "sage") end
	elseif item == "cucumber" then
		for index = 1, 4 do
			local frame = CFrame.new(-.7 + (index - 1) * .45, y + .07, .5)
			disc(model, "CucumberSkin", .48, .1, frame, "forest")
			disc(model, "CucumberCenter", .36, .11, frame * CFrame.new(0, .01, 0), "sage")
		end
	elseif item == "carrot" then
		for index = 1, 5 do part(model, "CarrotStrip", Vector3.new(.12, .1, .65), CFrame.new(-.65 + index * .22, y + .12, .52) * CFrame.Angles(0, index * .17, 0), "golden") end
	elseif item == "sauce" then
		for index = 1, 3 do part(model, "SauceDrizzle", Vector3.new(1.6, .06, .09), CFrame.new(0, 1, -.5 + index * .32) * CFrame.Angles(0, -.25, 0), "wood") end
	elseif item == "sesame" then
		for index = 1, 9 do
			local angle = index * 2.4
			round(model, "SesameSeed", Vector3.new(.12, .06, .07), CFrame.new(math.cos(angle) * (.25 + index * .045), 1, math.sin(angle) * (.25 + index * .045)) * CFrame.Angles(0, angle, 0), "golden")
		end
	elseif item == "plate" then
		disc(model, "PlateRim", 1.9, .12, CFrame.new(-2.25, .14, 0), "cream")
		disc(model, "PlateWell", 1.5, .04, CFrame.new(-2.25, .21, 0), "sage")
	elseif item == "cup" then
		disc(model, "CupBody", .8, .85, CFrame.new(2.15, .49, 0), "cream")
		disc(model, "CupInside", .62, .04, CFrame.new(2.15, .925, 0), "wood")
		part(model, "CupHandle", Vector3.new(.26, .38, .17), CFrame.new(2.65, .54, 0), "cream")
	elseif item == "napkin" then
		local x = slot == "settingA" and -2.25 or 2.15
		part(model, "FoldedNapkin", Vector3.new(1.25, .09, .95), CFrame.new(x, .16, 0) * CFrame.Angles(0, .13, 0), "sage")
		part(model, "NapkinFold", Vector3.new(.6, .035, .95), CFrame.new(x + .25, .22, 0) * CFrame.Angles(0, .13, 0), "cream")
	end
	return model
end
function FoodPresentation.Build(accepted, held)
	local model = Instance.new("Model"); model.Name = "SharedDish"
	model:SetAttribute("VerificationTicket", "PCW-20"); model.WorldPivot = CFrame.identity
	part(model, "ServingMat", Vector3.new(6.5, .06, 2.8), CFrame.new(0, .03, 0), "wood")
	disc(model, "BowlFoot", 1.5, .12, CFrame.new(0, .13, 0), "cream")
	disc(model, "BowlBody", 2.5, .36, CFrame.new(0, .33, 0), "cream")
	disc(model, "BowlInside", 2.15, .025, CFrame.new(0, .52, 0), "sage")
	for _, slot in ipairs(ORDER) do
		local choice = accepted and accepted[slot]
		local item = type(choice) == "table" and choice.itemId or nil
		if item and LABELS[item] then ingredient(model, slot, item) end
	end
	-- Local-only preview. Server never passes a hold to shared world rendering.
	if held and LABELS[held.itemId] and not (accepted and accepted[held.slotId]) and table.find(ORDER, held.slotId) then
		local selection = ingredient(model, held.slotId, held.itemId)
		selection.Name = "SelectedPreview"; selection:SetAttribute("PreviewOnly", true)
	end
	return model
end
return FoodPresentation
]=],
["roblox/mvp/shared/Guidance.luau"] = [=[-- Presentation data only. Nothing in this module grants a reward or permission.
local Guidance = {}

Guidance.Order = { "Q01", "Q02", "Q03", "Q04", "Q05", "Q06" }
Guidance.Activities = {
	Q01 = { title = "Everything Tucked In", short = "Make her room cozy", destination = "Phuong's bedroom", anchors = { "Q01Bed" }, hint = "Choose a bed or shelf task. Friends help; Phuong adds the finishing touch.", reward = "First completion adds 20 to the shared fund." },
	Q02 = { title = "Jasper's Favorite Things", short = "Play with Jasper", destination = "Bedroom, then Jasper's yard", anchors = { "JasperBedroomStart", "JasperFetchYard" }, hint = "Say hello to Jasper, find his rabbit in the yard, then play fetch.", reward = "First completion adds 20 to the shared fund." },
	Q03 = { title = "A Tiny World of Her Own", short = "Build a tiny keepsake", destination = "UDistrict craft booth", anchors = { "Q03FairCraft", "Q03BedroomDisplay" }, hint = "Choose a tiny piece, turn it if you like, then place it in the miniature.", reward = "First completion adds 20 to the shared fund." },
	Q04 = { title = "One More Chapter", short = "Share a quiet chapter", destination = "Quad blossoms or bedroom Kindle", anchors = { "Q04QuadReading", "Q04BedroomKindle" }, hint = "Read a page. Pick a highlight, a reaction and a bookmark, then save.", reward = "First completion adds 20 to the shared fund." },
	Q05 = { title = "A Labubu Wish", short = "Help Phuong get her Labubu", destination = "UDistrict Labubu booth", anchors = { "Q05UDistrictVending" }, hint = "Phuong chooses her wish. Each box uses 20 from the shared fund; her wish arrives by the fifth box.", reward = "Getting her wanted Labubu adds the sixth activity's petal." },
	Q06 = { title = "Something Delicious", short = "Make a meal together", destination = "FOB, Aladdins, then the serving table", anchors = { "Q06FOBCounter", "Q06AladdinsCounter", "Q06Serving" }, hint = "Build a bowl at FOB, add sauce at Aladdins, then set the serving table.", reward = "First completion adds 20 to the shared fund." },
	Cake = { title = "Happy Birthday, Phuong!", short = "Gather for birthday cake", destination = "Birthday patio", anchors = { "FinalePatio" }, hint = "Follow the marker to the birthday table and gather with your friends.", reward = "Enjoy the birthday moment together." },
}

Guidance.Reasons = {
	TooFar = "Walk closer to the marked activity, then try again.",
	BadSessionId = "The birthday session refreshed. Please reopen this activity.",
	NotPresent = "Enter the birthday world first.",
	ActivityUnavailable = "This activity is not ready yet. Try another petal or ask a host for help.",
	RoundRejected = "This activity changed while you were joining. Please reopen it.",
	ActionRejected = "That step could not be completed. Check the next step and try again.",
	ReplayUnavailable = "Finish this shared round before starting another.",
	CakeRejected = "The birthday table is not ready for that yet. Follow the next step shown here.",
	SLOT_BUSY = "A friend is using this spot. Choose another or try again shortly.",
	empty_basket = "This basket is empty. Try another basket in Jasper's yard.",
	fetch_target_occupied = "Jasper is still fetching. Give him a moment.",
	["not authorized"] = "This choice belongs to Phuong. Andrew can help when the game allows it.",
}

function Guidance.PetalCount(petals)
	if type(petals) == "number" then return math.clamp(petals, 0, 6) end
	local count = 0
	if type(petals) == "table" then
		for _, id in ipairs(Guidance.Order) do if petals[id] == true then count += 1 end end
	end
	return count
end

function Guidance.Complete(snapshot, id)
	return type(snapshot.petals) == "table" and snapshot.petals[id] == true
end

function Guidance.Text(value, fallback)
	if type(value) ~= "string" or value == "" then return fallback or "" end
	-- Error tracebacks, Lua table addresses and machine enum tokens are never UI copy.
	if string.find(value, "table:", 1, true) or string.find(value, "Stack Begin", 1, true)
		or string.find(value, ".luau:", 1, true) or string.match(value, "^[%u%d_]+$") then
		return fallback or ""
	end
	return value
end

function Guidance.FriendlyError(code, detail)
	if type(code) == "string" and Guidance.Reasons[code] then return Guidance.Reasons[code] end
	if type(detail) == "string" and Guidance.Reasons[detail] then return Guidance.Reasons[detail] end
	-- Unstructured server exception strings may contain paths, IDs or object addresses.
	return "That step did not go through. Reopen the activity to see what is available."
end

function Guidance.AnchorNames(id, view)
	local info = Guidance.Activities[id]
	if not info then return {} end
	if view and type(view.guide) == "table" and type(view.guide.nextAnchor) == "string" then
		return { view.guide.nextAnchor }
	end
	if id == "Q02" then
		if view and view.state ~= "GREETING" and view.state ~= "IDLE" then return { "JasperFetchYard" } end
		return { "JasperBedroomStart" }
	end
	if id == "Q03" then
		return view and view.state == "COMPLETED" and { "Q03BedroomDisplay" } or { "Q03FairCraft" }
	end
	if id == "Q06" and view then
		for _, descriptor in ipairs(view.availableActions or {}) do
			if descriptor.enabled ~= false then
				local slot = descriptor.payload and descriptor.payload.slotId
				if slot == "sauce" then return { "Q06AladdinsCounter" } end
				if slot == "settingA" or slot == "settingB" then return { "Q06Serving" } end
				return { "Q06FOBCounter" }
			end
		end
	end
	if id == "Q06" then return { "Q06FOBCounter" } end
	return info.anchors
end

-- distances is supplied by Navigator; this module has no world/service dependency.
function Guidance.Recommend(snapshot, distances, views)
	if Guidance.PetalCount(snapshot.petals) == 6 then return "Cake" end
	local best, score = nil, math.huge
	for _, id in ipairs(Guidance.Order) do
		if not Guidance.Complete(snapshot, id) and id ~= "Q05" then
			local view = views[id]
			local available = not view or view.state ~= "UNAVAILABLE"
			if available then
				local distance = distances[id] or math.huge
				if distance < score then best, score = id, distance end
			end
		end
	end
	local funded = (tonumber(snapshot.fundBalance or snapshot.fund) or 0) >= 20
	if funded and not Guidance.Complete(snapshot, "Q05") and (not best or score > 32 or (distances.Q05 or math.huge) < score) then return "Q05" end
	if best then return best end
	for _, id in ipairs(Guidance.Order) do if not Guidance.Complete(snapshot, id) then return id end end
	return "Cake"
end

function Guidance.Confirmation(descriptor)
	if type(descriptor.confirm) == "table" then return descriptor.confirm end
	if descriptor.confirm == false then return nil end
	local payload = descriptor.payload or {}
	local step = descriptor.stepId
	if step == "roll" or payload.action == "roll" then
		return { title = "Open a Labubu box?", detail = "This uses 20 from the shared birthday fund. Everyone's progress stays shared.", label = "Spend 20 and open" }
	end
	if step == "select-wanted" then
		return { title = "Choose this wish?", detail = "The wanted figure stays selected until Phuong receives it.", label = "Choose this Labubu" }
	end
	if payload.action == "finish" or payload.action == "finalize" or payload.complete == true then
		return { title = "Finish this activity?", detail = "Save this choice for the shared birthday session.", label = "Finish together" }
	end
	return nil
end

return Guidance
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

expect(queue:BeginTransfer(), "frozen roster starts transfer")
expect(not queue:ResetAfterTransfer(), "cannot reset during transfer")
expect(queue:CompleteTransfer(), "transfer completes")
expect(queue:ResetAfterTransfer(), "completed transfer resets")
now = 20
expect(queue:Join(20, now), "next group can board")
expect(queue:Snapshot().deadlineAt == 80, "next group has fresh countdown")
expect(#localRoster.members == 9, "reset preserves dispatched roster")
queue:Tick(80)
queue:FailTransfer()
expect(queue:ResetAfterTransfer(), "failure can recover")
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
["roblox/mvp/update-lobby-circle.luau"] = [=[-- Apply in Studio Edit mode after updating the Main and QueueService sources.

local root=workspace.CozyWorld_Draft01

local portal=root.BirthdayLobby.Portal

local old=root.MVP.Stations:FindFirstChild("LobbyQueue")

if old then old:ClearAllChildren() end

local pad=portal.TeleportPad

local anchor=root.MVP.Anchors:FindFirstChild("BirthdayLobbyQueue",true)

if anchor then anchor.CFrame=CFrame.new(pad.Position) end

local oldGui=pad:FindFirstChild("BoardingCountdown")

if oldGui then oldGui:Destroy() end

for _,v in portal.PortalInstructions:GetDescendants() do if v:IsA("TextLabel") then v.Text="Enter Phuong’s home whenever you’re ready\nPress E at the circle • tap on mobile" end end

local prompt=portal.PortalPrompt.EnterWorld

prompt.Enabled=true; prompt.ActionText="Enter Phuong’s home"; prompt.ObjectText="Birthday world"; prompt.HoldDuration=0; prompt.KeyboardKeyCode=Enum.KeyCode.E

return "Boarding circle installed; obsolete square removed"

]=],
["roblox/mvp/tests/release_activity_contracts.spec.luau"] = [=[-- Pure server contracts using actual GetView descriptors, not retired shortcuts.
-- Does not establish Roblox UI, replication, devices, geometry or performance.
local Session = require(script.Parent.Parent.server.SessionService)
local Q01 = require(script.Parent.Parent.server.activities.Q01)
local Q05 = require(script.Parent.Parent.server.activities.Q05)
local Q06 = require(script.Parent.Parent.server.activities.Q06)
local P, A, G, H = 3971290001, 1078077474, 101, 102
local serial = 0
local function expect(value, message) assert(value, message) end
local function copy(value)
    if type(value) ~= "table" then return value end
    local result = {}; for k, v in pairs(value) do result[k] = copy(v) end; return result
end
local function fresh(label)
    local session = Session.new({sessionId=label, phuongUserId=P, hostUserId=A})
    for _, actor in ipairs({P,A,G,H}) do session:SetPresence(actor, true) end
    return session
end
local function descriptor(activity, actor, predicate, allowDisabled)
    for _, action in ipairs(activity:GetView(actor).availableActions or {}) do
        if predicate(action) and (allowDisabled or action.enabled ~= false) then return copy(action) end
    end
    error("Required current view action missing for actor " .. tostring(actor))
end
local function envelope(session, activity, actor, action, id)
    serial += 1
    local view = activity:GetView(actor)
    return {sessionId=session.sessionId, activityId=view.activityId, roundId=view.roundId,
        actorUserId=actor, actionId=id or (session.sessionId .. ":" .. serial),
        stepId=action.stepId, payload=copy(action.payload or {})}
end
local function apply(session, activity, actor, predicate)
    local request = envelope(session, activity, actor, descriptor(activity, actor, predicate))
    local result = activity:Apply(request)
    expect(result.ok, "Current descriptor rejected: " .. tostring(result.code) .. " " .. tostring(result.message))
    return result, request
end
local function actionIs(operation, step)
    return function(action) return action.payload.action == operation and (not step or action.stepId == step) end
end

-- Bed: holds are exclusive and expire, previews have no reward, each accepted
-- task is shared, only Phuong normally finishes, optional shelf earns nothing.
do
    local session, tick = fresh("bed-contract"), 0
    local feedback = {shelfReady=true, BeginRound=function() end, ApplyStep=function() end,
        Finish=function() end, RenderShelf=function() end}
    local activity = Q01.new({session=session, clock=function() return tick end, feedback=feedback})
    activity:CreateRound({activityId="Q01", roundId="bed:1", actorUserId=P})
    local reserve = descriptor(activity, G, actionIs("reserve", "blanket_left"))
    local request = envelope(session, activity, G, reserve)
    expect(activity:Apply(request).ok, "Guest can pick up bed task")
    expect(session.fundBalance == 0 and not session.petals.Q01, "Preview grants nothing")
    local clash = envelope(session, activity, H, reserve)
    expect(not activity:Apply(clash).ok, "Two guests cannot hold same bed spot")
    tick = 31; activity:ExpireReservations(tick)
    expect(activity:GetView(G).held == nil, "Expired bed selection disappears")
    apply(session, activity, H, actionIs("reserve", "blanket_left"))
    apply(session, activity, H, actionIs("cancel", "blanket_left"))
    for _, step in ipairs(Q01.StepIds) do
        apply(session, activity, G, actionIs("reserve", step))
        local result, placed = apply(session, activity, G, actionIs("place", step))
        expect(activity:Apply(placed).ok, "Exact bed duplicate returns prior result")
    end
    local finishing = descriptor(activity, P, actionIs("finish"))
    expect(not activity:Apply(envelope(session, activity, G, finishing)).ok, "Guest cannot finish Phuong's bed")
    expect(not activity:Apply(envelope(session, activity, A, finishing)).ok, "Andrew normal finish waits while Phuong present")
    local _, completed = apply(session, activity, P, actionIs("finish"))
    activity:Apply(completed)
    expect(session.fundBalance == 20 and session.petals.Q01, "Bed initial reward once")
    apply(session, activity, G, function(a) return a.payload.action == "shelf_select" and a.payload.itemId == "book_sage" end)
    apply(session, activity, G, function(a) return a.payload.action == "shelf_slot" and a.payload.slotId == "left" end)
    apply(session, activity, G, actionIs("shelf_place"))
    expect(session.fundBalance == 20 and activity.shelfSlots.left == "book_sage", "Shelf arrangement has no reward")
    local occupied = {stepId="shelf", payload={action="shelf_select", itemId="book_sage"}}
    expect(not activity:Apply(envelope(session, activity, H, occupied)).ok, "Guest cannot rearrange occupied shelf")
    apply(session, activity, P, function(a) return a.payload.action == "shelf_select" and a.payload.itemId == "book_sage" end)
    activity:ReleaseActor(P)
    activity:CreateRound({activityId="Q01", roundId="bed:2", actorUserId=P, replay=true})
    expect(activity.shelfSlots.left == "book_sage", "Bed replay preserves shelf layout")
    for _, step in ipairs(Q01.StepIds) do
        apply(session, activity, G, actionIs("reserve", step)); apply(session, activity, G, actionIs("place", step))
    end
    apply(session, activity, P, actionIs("finish"))
    expect(session.fundBalance == 30, "Explicit bed replay adds only 10")
    print("CONTRACT bed: shared holds, expiry, cancellation, role, reward, shelf, replay")
end

-- Food: exact card variants, honest counter boundaries, reservations, replay.
do
    local session, tick, places = fresh("food-contract"), 0, {[P]="FOB",[G]="FOB",[H]="FOB"}
    local activity = Q06.new({session=session, clock=function() return tick end,
        context={foodVenue=function(actor) return places[actor] end}})
    local function round(id, replay)
        activity:CreateRound({sessionId=session.sessionId, activityId="Q06", roundId=id, actorUserId=P, replay=replay})
    end
    local function select(slot, item)
        return function(a) return a.payload.action == "select" and a.payload.slotId == slot and a.payload.itemId == item end
    end
    round("food:1", false)
    local base = descriptor(activity, G, select("base", "rice"))
    local _, reserved = apply(session, activity, G, select("base", "rice"))
    expect(session.fundBalance == 0 and activity:GetView(G).progress.done == 0, "Food preview adds no ingredient or reward")
    expect(not activity:Apply(envelope(session, activity, H, base)).ok, "Food slot has one owner")
    local staleAdd = descriptor(activity, G, actionIs("add", "base"))
    tick = 31; activity:ExpireReservations(tick)
    expect(not activity:Apply(envelope(session, activity, G, staleAdd)).ok, "Expired food hold cannot commit")
    local recipe = {{"base","rice","FOB"},{"protein","mushroom","FOB"},{"toppings","carrot","FOB"},
        {"sauce","sesame","Aladdins"},{"settingA","napkin","Serving"},{"settingB","cup","Serving"}}
    for _, part in ipairs(recipe) do
        places[G] = part[3]
        apply(session, activity, G, select(part[1],part[2]))
        local add = descriptor(activity, G, actionIs("add",part[1]))
        places[G] = "Away"
        expect(not activity:Apply(envelope(session, activity, G, add)).ok, "Cannot add food from another venue")
        places[G] = part[3]
        local _, accepted = apply(session, activity, G, actionIs("add",part[1]))
        activity:Apply(accepted)
        expect(activity:GetView(G).foodDisplay[part[1]].itemId == part[2], "Exact selected food preserved")
    end
    expect(session.fundBalance == 20 and session.petals.Q06, "Shared food completes once")
    round("food:2", true)
    for _, part in ipairs(recipe) do
        places[G] = part[3]; apply(session, activity, G, select(part[1],part[2])); apply(session, activity, G, actionIs("add",part[1]))
    end
    expect(session.fundBalance == 30, "Food explicit replay adds 10")
    print("CONTRACT food: held previews, venue, expiry, variant, first/replay reward")
end

-- Labubu: all tests start from real descriptors, then mutate one boundary.
local function labubu(label, desired, outcome, amount, feedback)
    local session = fresh(label); session:AddFund(amount or 100)
    local activity = Q05.new({session=session, outcome=outcome or function() return "BigIntoEnergy02" end,
        clock=function() return 1234 end, feedback=feedback})
    activity:CreateRound({activityId="Q05", roundId=label .. ":round", actorUserId=P})
    local choice = function(a) return a.stepId == "select-wanted" and a.payload.figureId == desired end
    return session, activity, choice
end
do
    local session, activity, choice = labubu("guarantee", "BigIntoEnergySecret")
    local wish = descriptor(activity,P,choice)
    expect(not activity:Apply(envelope(session,activity,G,wish)).ok, "Guest cannot choose wish")
    expect(not activity:Apply(envelope(session,activity,A,wish)).ok, "Andrew normal controls defer to Phuong")
    local _, chosen = apply(session,activity,P,choice)
    expect(activity:Apply(chosen).ok, "Exact confirmed wish retry is harmless")
    expect(not activity:Apply(envelope(session,activity,P,wish)).ok, "Stale wish confirmation rejects")
    for roll=1,5 do
        local rollChoice = function(a) return a.stepId == "roll" end
        local displayed = descriptor(activity,P,rollChoice)
        local result, request = apply(session,activity,P,rollChoice)
        expect(result.receipt.debitApplied and result.receipt.cost == 20, "Successful box spends exactly 20")
        expect(session.fundBalance == 100-roll*20, "Box fund balance exact")
        expect(activity:GetView(P).collectionCount == roll, "One copy per box")
        local saved = activity:GetView(P).latestResult
        expect(saved and saved.awardedAt == 1234 and saved.receiptId == result.receipt.receiptId, "Result is saved before reveal")
        activity:ReleaseActor(P); expect(activity:Apply(request).ok, "Close/retry keeps receipt")
        expect(not activity:Apply(envelope(session,activity,P,displayed)).ok, "Distinct stale ID cannot buy same displayed roll")
        local changedActor = copy(request); changedActor.actorUserId=G
        expect(not activity:Apply(changedActor).ok, "Changed actor cannot reuse purchase ID")
        if roll < 5 then expect(not session.petals.Q05, "Miss does not grant petal") end
    end
    expect(session.petals.Q05 and activity:GetView(P).wishFulfilled and session.fundBalance == 0, "Fifth selected secret is guaranteed within 100")
    apply(session,activity,P,function(a) return a.stepId == "select-wanted" and a.payload.figureId == "BigIntoEnergy02" end)
    expect(activity:GetView(P).wishFulfilled and session.fundBalance == 0 and session.petals.Q05, "Owned optional wish costs nothing and keeps story completion")
    print("CONTRACT Labubu: permissions, secret guarantee, stale/duplicate receipt, optional owned wish")
end
do
    local session, activity, choice = labubu("early", "BigIntoEnergy01", function() return "BigIntoEnergy01" end)
    session:SetPresence(P,false)
    apply(session,activity,A,choice)
    apply(session,activity,A,function(a) return a.stepId=="roll" end)
    expect(session.fundBalance == 80 and session.petals.Q05 and activity:GetView(A).collectionCount == 1, "Andrew fallback early success only costs 20, Q05 earns zero")
    local poor, box, choose = labubu("poor", "BigIntoEnergy01", nil, 0)
    apply(poor,box,P,choose)
    local unavailable = descriptor(box,P,function(a) return a.stepId=="roll" end,true)
    expect(not box:Apply(envelope(poor,box,P,unavailable)).ok and poor.fundBalance == 0, "Insufficient funds reject without award")
    local broken, awarded, selectWish = labubu("display-failure", "BigIntoEnergy01", function() return "BigIntoEnergy01" end,100,
        {Render=function() error("Intentional presentation failure") end})
    apply(broken,awarded,P,selectWish)
    local _, saved = apply(broken,awarded,P,function(a) return a.stepId=="roll" end)
    awarded:Apply(saved)
    expect(broken.fundBalance == 80 and broken.petals.Q05 and awarded:GetView(P).collectionCount == 1, "Rendering failure cannot duplicate debit or lose award")
    print("CONTRACT Labubu: early win, Andrew fallback, no-fund, presentation failure")
end
do
    local values = {{0,"BigIntoEnergy01"},{0.164999,"BigIntoEnergy01"},{0.165,"BigIntoEnergy02"},
        {0.329999,"BigIntoEnergy02"},{0.989999,"BigIntoEnergy06"},{0.990001,"BigIntoEnergySecret"},{0.999999,"BigIntoEnergySecret"}}
    for index, item in ipairs(values) do
        local session = fresh("odds" .. index)
        local activity = Q05.new({session=session, random=function() return item[1] end})
        expect(activity:_draw() == item[2], "16.5% regular / 1% secret boundary")
    end
    print("CONTRACT Labubu: regular and secret probability boundaries")
end
return true
]=],
["roblox/mvp/tests/release_cake_contracts.spec.luau"] = [=[-- Cake authority contracts. Fixtures model authenticated IDs; actual seats,
-- camera, sound, avatar slices and mobile controls require live Studio evidence.
local Session = require(script.Parent.Parent.server.SessionService)
local Cake = require(script.Parent.Parent.server.CakeService)
local P,A,G,H = 3971290001,1078077474,301,302
local serial=0
local function fixture(name)
    local session=Session.new({sessionId=name,phuongUserId=P,hostUserId=A})
    local state={time=0,occupant=nil,world={[P]=true,[A]=true,[G]=true,[H]=true},patio={[P]=true,[A]=true,[G]=true,[H]=true}}
    for _,actor in ipairs({P,A,G,H}) do session:SetPresence(actor,true) end
    local cake=Cake.new(session,{clock=function() return state.time end})
    cake:SetRuntime({isWorld=function(actor) return state.world[actor]==true end,
        isAtPatio=function(actor) return state.patio[actor]==true end,
        occupant=function() return state.occupant end})
    return session,cake,state
end
local function allPetals(session)
    for id in pairs(session.petals) do session.petals[id]=true end
end
local function envelope(session,cake,state,actor,action,generation,id)
    serial+=1;state.time+=1
    return {sessionId=session.sessionId,actorUserId=actor,actionId=id or (session.sessionId..":"..serial),
        action=action,generation=generation or cake:GetState(actor).generation}
end
local function descriptor(cake,actor,operation)
    for _,item in ipairs(cake:GetState(actor).availableActions) do
        if item.action==operation and item.enabled then return item end
    end
    error("Required cake action is not offered: "..operation)
end
local function apply(session,cake,state,actor,operation)
    local item=descriptor(cake,actor,operation)
    local request=envelope(session,cake,state,actor,item.action,item.generation)
    local result=cake:Apply(request)
    assert(result.ok,tostring(result.code).." "..tostring(result.message))
    return result,request
end
local function reject(result,why) assert(result.ok==false,why) end
do
    local session,cake,state=fixture("cake-normal")
    state.occupant=P;cake:Tick()
    assert(cake:GetState(P).phase=="LOCKED","Phuong cannot start before six petals")
    state.occupant=G;allPetals(session);cake:Tick()
    assert(cake:GetState(P).phase=="GATHERING","Unlock auto-arms without a separate Start")
    assert(cake:GetState(P).generation==0,"Guest occupancy cannot start birthday")
    state.occupant=P;state.time=5;cake:Tick()
    local beginning=cake:GetState(P)
    assert(beginning.phase=="CELEBRATING" and beginning.generation==1 and beginning.startedAt==5,"Phuong seat begins once")
    state.occupant=nil;state.time=8;cake:Tick();state.occupant=P;cake:Tick()
    assert(cake:GetState(P).startedAt==5 and cake:GetState(P).generation==1,"Unseat/reseat cannot restart")
    assert(cake:GetState(H).startedAt==5 and cake:GetState(H).endsAt==beginning.endsAt,"Late participant receives same timeline")
    state.time=beginning.endsAt;cake:Tick()
    assert(cake:GetState(P).phase=="CAKE_READY","Server time advances with no client acknowledgement")
    reject(cake:Apply(envelope(session,cake,state,G,"Cut")),"Guest cannot cut")
    reject(cake:Apply(envelope(session,cake,state,A,"Cut")),"Andrew normal flow cannot replace Phuong cut")
    reject(cake:Apply(envelope(session,cake,state,P,"Cut",0)),"Old generation cannot mutate new celebration")
    local _,cut=apply(session,cake,state,P,"Cut")
    assert(cake:Apply(cut).ok,"Exact cut retry is idempotent")
    local _,taken=apply(session,cake,state,G,"TakeSlice")
    assert(cake:Apply(taken).ok,"Exact take-slice retry returns receipt")
    reject(cake:Apply(envelope(session,cake,state,G,"TakeSlice")),"A second slice cannot be granted with a new ID")
    local changed={};for k,v in pairs(taken) do changed[k]=v end;changed.actorUserId=H
    reject(cake:Apply(changed),"Another actor cannot reuse slice receipt")
    apply(session,cake,state,G,"Eat")
    local firstBite=cake:GetState(G).biteCount
    reject(cake:Apply(envelope(session,cake,state,G,"Bite")),"Bites are rate-limited")
    apply(session,cake,state,G,"Bite")
    assert(cake:GetState(G).biteCount==firstBite+1 and session.fundBalance==0,"Cosmetic repeat bite grants no reward")
    assert(cake:GetState(H).sliceTaken==false,"Each participant owns only their slice state")
    state.patio[H]=false
    reject(cake:Apply(envelope(session,cake,state,H,"TakeSlice")),"Taking cake requires actual patio presence")
    state.patio[H]=true;apply(session,cake,state,H,"TakeSlice")
    state.world[G]=false
    reject(cake:Apply(envelope(session,cake,state,G,"Bite")),"Lobby participant cannot eat remotely")
    state.world[G]=true
    assert(cake:GetState(G).hasEaten,"Return/reset retains individual cake moment")
    reject(cake:Apply(envelope(session,cake,state,P,"Arm")),"Invite cannot reset a completed celebration")
    assert(cake:GetState(P).generation==1 and cake:GetState(P).phase=="EATING","Finale advances monotonically")
    print("CONTRACT cake normal: lock, auto-arm, seat identity, one generation, late state, cut, slices, bites, no repeat reward")
end
do
    local session,cake,state=fixture("cake-delay")
    state.occupant=P
    apply(session,cake,state,A,"Delay")
    allPetals(session);cake:Tick()
    assert(cake:GetState(P).phase=="READY" and cake:GetState(P).generation==0,"Explicit delay survives unlock while Phuong seated")
    reject(cake:Apply(envelope(session,cake,state,G,"Arm")),"Guest cannot arm")
    apply(session,cake,state,A,"Arm")
    assert(cake:GetState(P).phase=="CELEBRATING" and cake:GetState(P).generation==1,"Arming evaluates already-seated Phuong")
    reject(cake:Apply(envelope(session,cake,state,A,"Delay")),"No cancellation after start")
    print("CONTRACT cake delay: pre-unlock pause, guest rejection, already-seated arming, no restart")
end
do
    local session,cake,state=fixture("cake-recovery")
    session:SetPresence(P,false);state.world[P]=false;state.occupant=A
    reject(cake:Recover(envelope(session,cake,state,A,"RecoverStart")),"Recovery cannot bypass petals")
    allPetals(session);cake:Tick()
    assert(cake:GetState(A).phase=="GATHERING","Andrew seating does not silently replace Phuong trigger")
    reject(cake:Apply(envelope(session,cake,state,A,"RecoverStart")),"Normal public route cannot call recovery")
    reject(cake:Recover(envelope(session,cake,state,G,"RecoverStart")),"Guest cannot call recovery method")
    local request=envelope(session,cake,state,A,"RecoverStart")
    assert(cake:Recover(request).ok and cake:Recover(request).ok,"Authorized recovery starts once and dedupes")
    local generation=cake:GetState(A).generation
    local advance=envelope(session,cake,state,A,"RecoverCut")
    assert(cake:Recover(advance).ok,"Explicit recovery may advance and cut while celebrating")
    assert(cake:GetState(A).phase=="CAKE_READY" and cake:GetState(A).cutAt~=nil,"Recovery produces coherent ready slices")
    assert(cake:GetState(A).endsAt==state.time and cake:GetState(A).generation==generation,"Recovery ends same timeline rather than starting another")
    reject(cake:Recover(envelope(session,cake,state,A,"RecoverStart")),"Recovery cannot restart")
    apply(session,cake,state,A,"TakeSlice");apply(session,cake,state,A,"Eat")
    assert(cake:GetState(A).hasEaten and session.fundBalance==0,"Recovered party still supports real cake flow")
    print("CONTRACT cake recovery: explicit method, host identity, petals, monotonic advance, slices")
end
return true
]=],
["roblox/mvp/tests/release_host_contracts.spec.luau"] = [=[-- Final-stage host contracts. These positive IDs are fixtures, not shipped
-- permissions or evidence of real users joining. Ordinary UI/travel is separate.
local Session=require(script.Parent.Parent.server.SessionService)
local Cake=require(script.Parent.Parent.server.CakeService)
local Host=require(script.Parent.Parent.server.HostService)
local Q={Q01=require(script.Parent.Parent.server.activities.Q01),Q02=require(script.Parent.Parent.server.activities.Q02),
    Q03=require(script.Parent.Parent.server.activities.Q03),Q04=require(script.Parent.Parent.server.activities.Q04),
    Q05=require(script.Parent.Parent.server.activities.Q05),Q06=require(script.Parent.Parent.server.activities.Q06)}
local P,A,G=3971290001,1078077474,401
local serial=0
local function copy(t) local r={};for k,v in pairs(t) do r[k]=v end;return r end
local function fixture(name)
    local session=Session.new({sessionId=name,phuongUserId=P,hostUserId=A})
    local f={session=session,time=0,world={[P]=true,[A]=true,[G]=true},rounds={},travels={}}
    for _,actor in ipairs({P,A,G}) do session:SetPresence(actor,true) end
    local clock=function() return f.time end
    local world={isPresent=function(actor) return session:IsPresent(actor) end,
        foodVenue=function() return "FOB" end,chooseRabbitBasket=function() return 2 end}
    f.activities={Q01=Q.Q01.new({session=session,clock=clock}),Q02=Q.Q02.new({session=session,clock=clock,world=world}),
        Q03=Q.Q03.new({session=session,clock=clock,context=world}),Q04=Q.Q04.new({session=session,clock=clock,context=world}),
        Q05=Q.Q05.new({session=session,clock=clock,context=world}),Q06=Q.Q06.new({session=session,clock=clock,context=world})}
    for _,id in ipairs({"Q01","Q02","Q03","Q04","Q05","Q06"}) do
        f.rounds[id]=name..":"..id
        f.activities[id]:CreateRound({sessionId=name,activityId=id,roundId=f.rounds[id],actorUserId=P})
    end
    f.cake=Cake.new(session,{clock=clock})
    f.cake:SetRuntime({isWorld=function(actor) return f.world[actor]==true end,isAtPatio=function() return true end,occupant=function() return nil end})
    f.host=Host.new(session,{activities=f.activities,cake=f.cake,clock=clock,runtime={
        isWorld=function(actor) return f.world[actor]==true end,
        newRoundId=function(id) serial+=1;return name..":recovery:"..id..":"..serial end,
        setRoundId=function(id,roundId) f.rounds[id]=roundId end,
        travel=function(actor,destination) table.insert(f.travels,{actor=actor,destination=destination});return true end}})
    return f
end
local function call(f,actor,action,fields)
    f.time+=1;serial+=1
    local request=copy(fields or {})
    request.sessionId=f.session.sessionId;request.actorUserId=actor;request.actionId=f.session.sessionId..":host:"..serial;request.action=action
    return f.host:Apply(request),request
end
local function good(result,why) assert(type(result)=="table" and result.ok==true,(type(why)=="string" and why or "Host action")..": "..tostring(result and result.code).." "..tostring(result and result.message));return result end
local function bad(result,why) assert(type(result)=="table" and result.ok==false,why) end
local function enable(f,actor) good(call(f,actor,"SetOverride",{enabled=true})) end
local function prepare(f,actor,operation,id)
    local result=good(call(f,actor,"Prepare",{operation=operation,activityId=id}),"Prepare "..operation)
    assert(result.confirmation and type(result.confirmation.token)=="string","Server issues confirmation token")
    return result.confirmation
end
local function recover(f,actor,operation,id)
    local quote=prepare(f,actor,operation,id)
    local result,request=call(f,actor,"Confirm",{token=quote.token})
    return good(result,"Confirm "..operation),request
end
local function activityAction(f,id,actor,predicate)
    local activity=f.activities[id];local view=activity:GetView(actor)
    for _,descriptor in ipairs(view.availableActions or {}) do
        if descriptor.enabled~=false and predicate(descriptor) then
            serial+=1
            local request={sessionId=f.session.sessionId,activityId=id,roundId=view.roundId,actorUserId=actor,
                actionId=f.session.sessionId..":normal:"..serial,stepId=descriptor.stepId,payload=descriptor.payload}
            good(activity:Apply(request),"Normal activity action")
            return request
        end
    end
    error("Required ordinary descriptor absent for "..id)
end
do
    local f=fixture("host-auth")
    assert(f.host:GetView(G)==nil,"Guests receive no private host audit/control view")
    assert(f.host:GetView(P) and f.host:GetView(A),"Both exact configured IDs see controls")
    bad(call(f,G,"SetOverride",{enabled=true}),"Guest cannot enable override")
    bad(call(f,A,"Prepare",{operation="TopUp"}),"Host mutation requires explicit override")
    enable(f,A)
    local quote=prepare(f,A,"TopUp")
    bad(call(f,P,"Confirm",{token=quote.token}),"Other host cannot steal an actor-bound quote")
    bad(call(f,G,"Confirm",{token=quote.token}),"Guest cannot use host quote")
    local accepted,request=call(f,A,"Confirm",{token=quote.token});good(accepted)
    assert(f.session.fundBalance==20,"Exactly fixed20 topup")
    good(f.host:Apply(request),"Same request retries original outcome")
    assert(f.session.fundBalance==20,"Duplicate confirmation cannot add money")
    local altered=copy(request);altered.actorUserId=P
    bad(f.host:Apply(altered),"Changed actor cannot reuse request identity")
    bad(call(f,A,"Confirm",{token=quote.token}),"Consumed quote cannot be committed with a fresh ID")
    local forged=copy(request);forged.sessionId="wrong-session";forged.actionId="forged-session"
    bad(f.host:Apply(forged),"Wrong session rejected")
    bad(call(f,A,"Prepare",{operation="ExecuteCode"}),"No arbitrary host commands")
    bad(call(f,A,"Prepare",{operation="CompleteQuest",activityId="Q99"}),"Activity allowlist enforced")
    f.time+=31;quote=prepare(f,A,"TopUp");f.session:AddFund(1)
    bad(call(f,A,"Confirm",{token=quote.token}),"Changed balance invalidates previously quoted effect")
    quote=prepare(f,A,"ReturnBedroom");f.time+=31
    bad(call(f,A,"Confirm",{token=quote.token}),"Expired confirmation rejects")
    quote=prepare(f,A,"ReturnPatio")
    good(call(f,A,"Cancel",{token=quote.token}))
    bad(call(f,A,"Confirm",{token=quote.token}),"Cancel leaves no usable mutation quote")
    f.world[A]=false
    bad(call(f,A,"Prepare",{operation="TopUp"}),"Lobby actor cannot recover world progress")
    print("CONTRACT host auth: real roles, override, quote owner, stale/expiry/cancel, duplicate, session, allowlist")
end
do
    local f=fixture("host-activities");enable(f,A)
    for _,id in ipairs({"Q01","Q03","Q06"}) do
        local held=activityAction(f,id,G,function(d) return d.payload.action=="reserve" or d.payload.action=="select" end)
        recover(f,A,"ReleaseReservations",id)
        assert(f.session.fundBalance==0 and not f.session.petals[id],"Releasing held previews grants no progress")
        activityAction(f,id,P,function(d) return d.payload.action=="reserve" or d.payload.action=="select" end)
        recover(f,A,"RestartRound",id)
        assert(f.activities[id]:GetView(P).roundId==f.rounds[id] and f.rounds[id]~=held.roundId,"Restart synchronizes local and routing round IDs")
        local stale=copy(held);stale.actionId=held.actionId..":stale-round"
        local ok,result=pcall(f.activities[id].Apply,f.activities[id],stale)
        assert(not ok or result.ok==false,"Prior round action cannot mutate replacement")
    end
    for _,id in ipairs({"Q01","Q02","Q03","Q04","Q06"}) do
        local _,request=recover(f,A,"CompleteQuest",id)
        good(f.host:Apply(request))
        assert(f.session.petals[id] and f.activities[id]:GetView(P).canReplay,"Recovery completes local view and petal together")
    end
    assert(f.session.fundBalance==100,"Only five missing initial earning rewards")
    assert(f.activities.Q04:GetView(P).draft.note=="" and f.activities.Q04:GetView(G).draft.note=="","Recovery never fabricates personal reading notes")
    local before=f.session.fundBalance
    local repeatPrepare=call(f,A,"Prepare",{operation="CompleteQuest",activityId="Q01"})
    if repeatPrepare.ok then good(call(f,A,"Confirm",{token=repeatPrepare.confirmation.token})) end
    assert(f.session.fundBalance==before,"Fresh repeated complete cannot repeat initial reward")
    activityAction(f,"Q05",P,function(d) return d.stepId=="select-wanted" and d.payload.figureId=="BigIntoEnergySecret" end)
    local _,wishRequest=recover(f,A,"FulfillWish");good(f.host:Apply(wishRequest))
    local box=f.activities.Q05:GetView(P)
    assert(f.session.petals.Q05 and box.wishFulfilled and box.collectionCount==1,"Wish recovery supplies exactly one wanted copy and sixth petal")
    assert(f.session.fundBalance==100 and box.latestResult.cost==0 and box.latestResult.debitApplied==false,"Recovery is honestly no-cost")
    assert(f.session:AllPetalsComplete(),"Recovered state can reach normal cake unlock")
    -- Andrew can deliberately act while Phuong is present; ordinary controls
    -- are separately checked by the ordinary activity contracts.
    recover(f,A,"StartCake")
    assert(f.cake:GetState(P).generation==1,"Explicit recovery starts one shared generation")
    recover(f,A,"AdvanceCake")
    assert(f.cake:GetState(P).cutAt~=nil and f.cake:GetState(P).phase=="CAKE_READY","Recovery ends camera timeline and makes real slices available")
    recover(f,A,"ReturnBedroom");recover(f,A,"ReturnPatio")
    assert(#f.travels==2 and f.travels[1].actor==A and f.travels[2].actor==A,"Travel moves only requesting host through bounded destinations")
    assert(f.session.fundBalance==100,"Cake/travel never add rewards")
    print("CONTRACT host recovery: holds, coherent restart/completion, missing rewards, no-cost wish, cake and host-only travel")
end
do
    local f=fixture("host-topup-cap");enable(f,P)
    for index=1,5 do
        f.time+=31;recover(f,P,"TopUp")
        assert(f.session.fundBalance==index*20,"Topups have fixed increments")
    end
    f.time+=31
    local result=call(f,P,"Prepare",{operation="TopUp"})
    if result.ok then bad(call(f,P,"Confirm",{token=result.confirmation.token}),"Topup session cap enforced at commit") end
    assert(f.session.fundBalance==100,"Bounded recovery cannot add a sixth topup")
    print("CONTRACT host fixed topup: both hosts, cooldown-spaced confirmation, session cap")
end
do
    local f=fixture("host-bounds");local last
    for index=1,512 do
        local result,request=call(f,A,"SetOverride",{enabled=index%2==0})
        good(result);last=request
    end
    local view=f.host:GetView(A)
    assert(view.requestCount==512 and #view.audit==32,"Request memory and recent audit have explicit bounds")
    bad(call(f,A,"SetOverride",{enabled=false}),"Fresh request after cap rejects")
    good(f.host:Apply(last),"Exact old receipt remains retryable at request cap")
    f.host:ReleaseActor(A)
    assert(not f.host:GetView(A).override and f.host:GetView(A).confirmation==nil,"Reset/departure clears override and quote")
    good(f.host:Apply(last))
    assert(not f.host:GetView(A).override,"Old mode receipt cannot reenable cleared authority")
    activityAction(f,"Q01",G,function(d) return d.payload.action=="reserve" end)
    assert(f.session.fundBalance==0,"Ordinary guest activity remains usable after host request cap")
    print("CONTRACT host bounds: audit32, request512, cached retries, departure reset, ordinary play unaffected")
end
return true
]=],
["roblox/mvp/tests/release_social_activity_contracts.spec.luau"] = [=[-- Pure module behavior only. World movement and two real clients need Studio.
local Session = require(script.Parent.Parent.server.SessionService)
local Q02 = require(script.Parent.Parent.server.activities.Q02)
local Q03 = require(script.Parent.Parent.server.activities.Q03)
local Q04 = require(script.Parent.Parent.server.activities.Q04)
local P,A,G,H = 3971290001,1078077474,201,202
local serial=0
local function fresh(id)
    local session=Session.new({sessionId=id,phuongUserId=P,hostUserId=A})
    for _, actor in ipairs({P,A,G,H}) do session:SetPresence(actor,true) end
    return session
end
local function request(session, activity, actor, filter)
    local view=activity:GetView(actor)
    for _, action in ipairs(view.availableActions or {}) do
        if action.enabled~=false and filter(action) then
            serial+=1
            local payload={}; for k,v in pairs(action.payload or {}) do payload[k]=v end
            return {sessionId=session.sessionId,activityId=view.activityId,roundId=view.roundId,
                actorUserId=actor,actionId=session.sessionId..":"..serial,stepId=action.stepId,payload=payload}
        end
    end
    error("Required current descriptor missing")
end
local function send(session,activity,actor,filter)
    local r=request(session,activity,actor,filter)
    local result=activity:Apply(r)
    assert(type(result)=="table" and result.ok~=false,"Current descriptor rejected")
    return result,r
end
local function rejects(callback)
    local ok,result=pcall(callback)
    assert(not ok or type(result)=="table" and result.ok==false,"Invalid mutation should reject")
end
do
    local session=fresh("jasper"); local calls={}
    local function track(name) return function(...) calls[name]=(calls[name] or 0)+1 end end
    local world={isPresent=function(actor) return session:IsPresent(actor) end,
        chooseRabbitBasket=function() return 2 end,
        resetJasper=track("reset"),moveJasperToYard=track("lead"),showRabbitPickup=track("rabbit"),
        returnRabbit=track("return"),presentFetchTarget=track("target"),fetchJasper=track("fetch"),
        giveJasperTreat=track("treat"),petJasper=track("pet")}
    local activity=Q02.new({session=session,clock=function() return 0 end,world=world})
    activity:CreateRound({sessionId=session.sessionId,activityId="Q02",roundId="jasper:1",actorUserId=P})
    send(session,activity,G,function(a) return a.stepId=="greet" end)
    assert(calls.lead==1,"Accepted greeting reaches world hook")
    local empty=request(session,activity,H,function(a) return a.stepId=="rabbitFound" and a.payload.basketIndex==1 end)
    assert(activity:Apply(empty).ok==false and session.fundBalance==0,"Empty basket is forgiving with no reward")
    send(session,activity,H,function(a) return a.stepId=="rabbitFound" and a.payload.basketIndex==2 end)
    activity:ReleaseActor(H)
    send(session,activity,G,function(a) return a.stepId=="rabbitReturned" end)
    for index=1,3 do
        local _,r=send(session,activity,index%2==0 and G or H,function(a) return a.stepId=="fetch"..index end)
        activity:Apply(r)
    end
    assert(calls.fetch==3,"One world fetch per accepted throw despite duplicates")
    local _,finished=send(session,activity,G,function(a) return a.stepId=="greenie" end)
    activity:Apply(finished)
    assert(calls.rabbit==1 and calls["return"]==1 and calls.treat==1,"Required dog feedback hooks reached once")
    assert(session.petals.Q02 and session.fundBalance==20,"Jasper shared reward once")
    send(session,activity,H,function(a) return a.stepId=="pet" end)
    assert(session.fundBalance==20,"Cosmetic pet grants no money")
    activity:CreateRound({sessionId=session.sessionId,activityId="Q02",roundId="jasper:2",actorUserId=P,replay=true})
    assert(activity:GetView(G).progress.done==0 and calls.reset==2,"Explicit replay resets actor and shared progress")
    print("CONTRACT Jasper: sequence, forgiving basket, helper handoff, world hooks, duplicate reward, replay")
end
do
    local session,tick=fresh("craft"),0
    local activity=Q03.new({session=session,clock=function() return tick end,context={}})
    activity:CreateRound({sessionId=session.sessionId,activityId="Q03",roundId="craft:1",actorUserId=P})
    local function action(operation,part)
        return function(a) return a.payload.action==operation and (not part or a.payload.partId==part or a.payload.socketId==Q03.SOCKETS[part]) end
    end
    local _,held=send(session,activity,G,action("reserve","chair"))
    local conflict={};for k,v in pairs(held) do conflict[k]=v end; conflict.actorUserId=H; conflict.actionId="craft:conflict"
    rejects(function() return activity:Apply(conflict) end)
    send(session,activity,G,action("rotate","chair"))
    send(session,activity,G,action("cancel","chair"))
    send(session,activity,G,action("reserve","chair"))
    local expired=request(session,activity,G,action("place","chair"))
    tick=16;activity:ExpireReservations()
    rejects(function() return activity:Apply(expired) end)
    for _, part in ipairs(Q03.PARTS) do
        send(session,activity,G,action("reserve",part))
        local _,placed=send(session,activity,G,action("place",part));activity:Apply(placed)
    end
    assert(session.petals.Q03 and session.fundBalance==20,"Craft six shared pieces earn once")
    local final=request(session,activity,P,action("finalize"))
    local fake={};for k,v in pairs(final) do fake[k]=v end;fake.actorUserId=G;fake.actionId="craft:guest-finish"
    rejects(function() return activity:Apply(fake) end)
    activity:Apply(final)
    assert(session.fundBalance==20,"Phuong craft presentation does not earn twice")
    print("CONTRACT craft: holds, rotation, cancellation, shared pieces, Phuong finish, no duplicate reward")
end
do
    local session=fresh("reading");local lastWorldSummary
    local activity=Q04.new({session=session,clock=function() return 0 end,
        context={renderReading=function(summary) lastWorldSummary=summary end}})
    activity:CreateRound({sessionId=session.sessionId,activityId="Q04",roundId="reading:1",actorUserId=P})
    send(session,activity,G,function(a) return a.stepId=="highlight" end)
    send(session,activity,G,function(a) return a.stepId=="reaction" end)
    send(session,activity,G,function(a) return a.stepId=="bookmark" end)
    local before=activity:GetView(G)
    assert(before.reading and #before.reading.text>100,"Actual reading passage is available")
    if activity.ReleaseActor then activity:ReleaseActor(G) end
    local after=activity:GetView(G)
    assert(after.reading.text==before.reading.text,"Reopen retains reading passage")
    local _,saved=send(session,activity,G,function(a) return a.payload.complete==true end)
    activity:Apply(saved)
    assert(session.fundBalance==20 and session.petals.Q04,"No typing required and save grants once")
    assert(activity:GetView(H).canReplay,"Other participant sees shared completion")
    -- This is only a private reading-field test marker, never birthday-note copy.
    local note=activity:GetView(G).noteAction
    local noteRequest={sessionId=session.sessionId,activityId="Q04",roundId="reading:1",actorUserId=G,
        actionId="reading:private-fixture",stepId=note.stepId,payload={passageId=note.payload.passageId,
            revision=note.payload.revision,note="PRIVATE_FIELD_TEST_MARKER"}}
    assert(activity:Apply(noteRequest).ok,"Optional private note remains usable after shared completion")
    assert(activity:GetView(G).draft.note=="PRIVATE_FIELD_TEST_MARKER","Owner sees own saved note")
    assert(activity:GetView(H).draft.note=="","Other participant cannot see private note")
    for _,value in pairs(lastWorldSummary) do assert(value~="PRIVATE_FIELD_TEST_MARKER","World feedback excludes private note") end
    assert(session.fundBalance==20,"Post-completion personal choices never add shared money")
    local changed={};for k,v in pairs(noteRequest) do changed[k]=v end;changed.actorUserId=H
    rejects(function() return activity:Apply(changed) end)
    print("CONTRACT reading: passage, close, no required note, single shared reward, private draft isolation")
end
return true
]=]
}
local specs = {"roblox/mvp/tests/release_activity_contracts.spec.luau","roblox/mvp/tests/release_cake_contracts.spec.luau","roblox/mvp/tests/release_host_contracts.spec.luau","roblox/mvp/tests/release_social_activity_contracts.spec.luau"}

local function node(name, parent, path)
    local value = {Name=name, Parent=parent, _path=path, _children={}}
    setmetatable(value, {__index=function(self, key) return self._children[key] end})
    function value:FindFirstChild(child) return self._children[child] end
    if parent then parent._children[name] = value end
    return value
end
local root, nodes = node("root", nil, ""), {}
for path in pairs(sources) do
    local parent, built = root, ""
    for segment in string.gmatch(path, "[^/]+") do
        built = built == "" and segment or built .. "/" .. segment
        parent = nodes[built] or node(segment, parent, built)
        nodes[built] = parent
        if string.sub(segment, -5) == ".luau" then
            parent.Parent._children[string.sub(segment, 1, -6)] = parent
        end
    end
end
local function loadModule(target)
    assert(type(target) == "table" and target._path, "Expected a synthetic ModuleScript node")
    if target._loaded then return target._value end
    local chunk, failure = loadstring(assert(sources[target._path]), "@" .. target._path)
    assert(chunk, failure)
    local env = setmetatable({script=target, warn=function(...) print("EXPECTED_OR_REVIEW_WARNING", ...) end}, {__index=_G})
    env.require = loadModule
    setfenv(chunk, env)
    target._value, target._loaded = chunk(), true
    return target._value
end
local passed, failed = 0, 0
for _, path in ipairs(specs) do
    local ok, result = xpcall(function() return loadModule(nodes[path]) end, debug.traceback)
    if ok and type(result) == "function" then ok, result = pcall(result) end
    if ok and result == true then
        passed += 1; print("PASS", path)
    else
        failed += 1; print("FAIL", path, result)
    end
end
print("RELEASE_CONTRACT_SUMMARY", passed, failed)
assert(failed == 0, "Release contracts failed")
