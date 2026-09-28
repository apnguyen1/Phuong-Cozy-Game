-- Task 01 measured Edit-mode inputs. Returns Roblox-native values for world builders.
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
