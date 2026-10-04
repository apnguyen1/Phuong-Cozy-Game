-- Grass and outer-Quad decoration builder.
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
