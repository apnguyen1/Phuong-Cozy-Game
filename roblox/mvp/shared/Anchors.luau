local Anchors = {}

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
