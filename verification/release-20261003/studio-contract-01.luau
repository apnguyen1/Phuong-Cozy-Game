_G.__PCW25ContractText=""
_G.__PCW25ContractText..=[==[local messages={}
local function print(...)
 local row={}; for i=1,select('#',...) do row[i]=tostring(select(i,...)) end
 table.insert(messages,table.concat(row,'	'))
end
local ok,failure=xpcall(function()
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
    local homeAnchor = assert(anch]==]
return #_G.__PCW25ContractText