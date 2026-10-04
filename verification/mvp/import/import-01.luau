local HttpService=game:GetService("HttpService")
assert(not game:GetService("RunService"):IsRunning(),"Edit mode required")
local entries={
{target=[=[ReplicatedStorage/PhuongMVP/shared/Anchors]=],kind=[=[ModuleScript]=],sha=[=[0d8d42052db32e17d23ed3ebb6317fd52a985da0695946dd4c5e70cdd328626c]=],source=[=[local Anchors = {}

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
]=]},
{target=[=[ReplicatedStorage/PhuongMVP/shared/Config]=],kind=[=[ModuleScript]=],sha=[=[3dd7a7557ed9d7c0a3391fad03d8e67ac175392c0412b4a395c8decddaea6034]=],source=[=[local Config = {
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
]=]},
{target=[=[ServerScriptService/PhuongMVP/shared/Anchors]=],kind=[=[ModuleScript]=],sha=[=[0d8d42052db32e17d23ed3ebb6317fd52a985da0695946dd4c5e70cdd328626c]=],source=[=[local Anchors = {}

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
]=]},
{target=[=[ServerScriptService/PhuongMVP/shared/Config]=],kind=[=[ModuleScript]=],sha=[=[3dd7a7557ed9d7c0a3391fad03d8e67ac175392c0412b4a395c8decddaea6034]=],source=[=[local Config = {
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
]=]},
{target=[=[ServerScriptService/PhuongMVP/shared/MeasuredInstallOptions]=],kind=[=[ModuleScript]=],sha=[=[00871ad4417cdfbac7d55cbce7b73b0d1d674c52924339c5f27412bb75b661ac]=],source=[=[-- Task 01 measured Edit-mode inputs. Returns Roblox-native values for world builders.
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
]=]},
{target=[=[ServerScriptService/PhuongMVP/server/SessionService]=],kind=[=[ModuleScript]=],sha=[=[1725e383387cb9fe68964e1838900a587e9fda19371b41ef24953612702a35bf]=],source=[=[local Config = require(script.Parent.Parent.shared.Config)

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
]=]},
{target=[=[ServerScriptService/PhuongMVP/server/CakeService]=],kind=[=[ModuleScript]=],sha=[=[5d7d5d7ba39c11f67b67a466de1853e34e551206a99eb741a51d5b4822428b39]=],source=[=[local Config = require(script.Parent.Parent.shared.Config)

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
]=]},
{target=[=[ServerScriptService/PhuongMVP/server/QueueService]=],kind=[=[ModuleScript]=],sha=[=[9c1f7322949395896229ff7edc9ab0e719f9b5aa642b1ef42a2968724d9b920b]=],source=[=[-- Server-owned shared birthday queue. Pure state machine; Roblox wiring belongs to LobbyQueue.
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
]=]},
{target=[=[ServerScriptService/PhuongMVP/server/TeleportAdapter]=],kind=[=[ModuleScript]=],sha=[=[22082e97b07dd791d41107730700589ac1c8ec5306c5c0b6c92e20f20b09a00d]=],source=[=[-- Production adapter for one reserved destination. Studio must inject a local adapter.
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
]=]},
{target=[=[ServerScriptService/PhuongMVP/server/LocalPartyTransferAdapter]=],kind=[=[ModuleScript]=],sha=[=[9c28106faace5c26aff5faa8ff19ede60939f37bf62d2f6cd7cbb13970b1988d]=],source=[=[-- STUDIO-ONLY LOCAL PLAYTEST ADAPTER.
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
]=]},
{target=[=[ServerScriptService/PhuongMVP/server/activities/Q01]=],kind=[=[ModuleScript]=],sha=[=[07905a40c976c6b7fb748c26467abef2af7eb7f30f8c027a97c8dd2dc4fb1d43]=],source=[=[-- Q01 Everything Tucked In. Server-owned activity rules; no currency or petal ownership here.
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
	return self:GetView()
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
	return { ok = true, code = "ACCEPTED", accepted = accepted, view = self:GetView() }
end

function Q01:Finish(request)
	local prior = request.actionId and self.session.receipts[request.actionId]
	if prior then return { ok = true, code = "DUPLICATE", receipt = prior, preview = self.finishedPreview, view = self:GetView() } end
	local round = self:_requireRound(request.roundId)
	assert(request.actorUserId == self.session.phuongUserId, "only Phuong can finish Q01")
	assert(self.finalChoices[request.choiceId], "unknown Q01 finishing choice")
	for _, stepId in ipairs(self.StepIds) do assert(round.steps[stepId], "all seven Q01 steps are required") end
	local receipt = self.session:CompleteRound({ sessionId = self.session.sessionId, activityId = self.ActivityId, roundId = request.roundId, actionId = request.actionId, actorUserId = request.actorUserId })
	self.finishedPreview = { choiceId = request.choiceId, choiceLabel = self.finalChoices[request.choiceId], receipt = receipt }
	self.currentRoundId = request.roundId
	return { ok = true, code = "FINISHED", receipt = receipt, preview = self.finishedPreview, view = self:GetView() }
end

function Q01:GetView()
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
		local held = self.reserved[stepId] ~= nil
		table.insert(actions, { id = "reserve:" .. stepId, label = self.StepLabels[stepId], stepId = stepId, payload = { stepId = stepId }, enabled = not done and not held, reason = done and "Already handled" or (held and "In use" or nil) })
	end
	return { activityId = self.ActivityId, roundId = self.currentRoundId, state = phase, title = "Everything Tucked In", instructions = phase == "READY_FOR_PHUONG" and "Choose how Phuong finishes the bed" or "Help with an available bed step", progress = { done = completed, total = 7 }, availableActions = actions, acceptedStepIds = accepted, contributors = round and round.contributors or {}, busyReason = nil, errorText = nil, canReplay = phase == "FINISHED", visibleState = self.visibleState, finishedPreview = self.finishedPreview, reservationSeconds = self.ReservationSeconds }
end

return Q01
]=]},
{target=[=[ServerScriptService/PhuongMVP/server/activities/Q02]=],kind=[=[ModuleScript]=],sha=[=[46d534ceba9319c6f2954a8abc0670373bf021f8e04e55366c551b263bf1deae]=],source=[=[-- Q02 Jasper's Favorite Things. Server-owned activity adapter.
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
    assert(request and request.actor and request.actor.UserId, "authenticated actor is required")
    return request.actor.UserId
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
        assert(tonumber(request.payload and request.payload.basketIndex) == self.rabbitBasket, "that basket is empty")
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
    elseif self.state == "LEADING" then actions = {{id="rabbitFound", label="Inspect basket", stepId="rabbitFound", payload={}, enabled=true}}
    elseif self.state == "RABBIT" then actions = {{id="rabbitReturned", label="Return rabbit", stepId="rabbitReturned", payload={}, enabled=true}}
    elseif self.state == "FETCH" then actions = {{id="fetch" .. tostring(self.targetIndex + 1), label="Throw", stepId="fetch" .. tostring(self.targetIndex + 1), payload={targetIndex=self.targetIndex + 1}, enabled=self.busyThrowAction == nil, reason=self.busyThrowAction and "Target occupied" or nil}}
    elseif self.state == "GREENIE" then actions = {{id="greenie", label="Give Greenie", stepId="greenie", payload={}, enabled=true}}
    elseif self.state == "COMPLETED" then actions = {{id="pet", label="Pet Jasper", stepId="pet", payload={}, enabled=true}} end
    return {activityId = "Q02", roundId = self.round and self.round.roundId, state = self.state, title = "Jasper's Favorite Things", instructions = "Help Jasper find his rabbit and fetch three toys.", progress = {done = self.targetIndex, total = 3}, availableActions = actions, acceptedStepIds = clone(self.accepted), contributors = clone(self.contributors), busyReason = self.busyThrowAction and "fetch_target_occupied" or nil, errorText = self.lastError, canReplay = self.state == "COMPLETED"}
end

return Activity
]=]},
{target=[=[ServerScriptService/PhuongMVP/server/activities/Q03]=],kind=[=[ModuleScript]=],sha=[=[0380d348ef150f11feace487b70ae5c34825ec8ce7393593aee33931941b0b95]=],source=[=[local Q03 = {}
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
function Q03:_round(request) return self.stateByRound[request.roundId] end
function Q03:_view(roundId, actorUserId, errorText)
    local state = self.stateByRound[roundId]
    local accepted, contributors = {}, {}
    if state then for id in pairs(state.accepted) do table.insert(accepted, id) end; for id in pairs(state.contributors) do table.insert(contributors, id) end end
    local done = state and #self:_committedParts(state) or 0
    return {activityId="Q03", roundId=roundId, state=state and state.status or "NONE", title="A Tiny World of Her Own", instructions="Place each tiny piece in its matching socket.", progress={done=done,total=#PARTS}, availableActions={{id="reserve",label="Select piece and socket",stepId="piece",payload={},enabled=true},{id="rotate",label="Rotate 90°",stepId="rotate",payload={},enabled=true},{id="place",label="Place",stepId="place",payload={},enabled=true},{id="cancel",label="Cancel",stepId="cancel",payload={},enabled=true},{id="preview_home",label="Preview at home",stepId="preview",payload={},enabled=true}}, acceptedStepIds=accepted, contributors=contributors, busyReason=state and state.busyReason or nil, errorText=errorText, canReplay=state and state.status == "COMPLETED" or false}
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
        local canFinish = self.session.CanFinish and self.session:CanFinish("Q03", request.actorUserId) or (request.actorUserId == self.session.phuongUserId or (self.session.hostUserId ~= 0 and request.actorUserId == self.session.hostUserId))
        assert(canFinish, "not authorized")
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
    local state = assert(self:_round({roundId=roundId})); for socket, entry in pairs(state.reservations) do if entry.ownerUserId == actorUserId then entry.status="AVAILABLE"; state.reservations[socket]=nil end end
end
function Q03:GetView(actorUserId)
    return self:_view(self.currentRoundId, actorUserId)
end
Q03.PARTS = PARTS; Q03.SOCKETS = SOCKETS
return Q03
]=]},
{target=[=[ServerScriptService/PhuongMVP/server/activities/Q04]=],kind=[=[ModuleScript]=],sha=[=[56a6b69a8b106ac47653273a1981819050d43644227165e8e1ffe8110bff0e71]=],source=[=[local Q04 = {}
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
        accepted = self.session:ApplyStep({ activityId = self.ActivityId, roundId = request.roundId, stepId = request.stepId or ("draft:" .. tostring(request.actorUserId) .. ":" .. passageId), actionId = request.actionId, actorUserId = request.actorUserId })
    else
        accepted = { activityId = self.ActivityId, roundId = request.roundId, stepId = "post-close-draft", actorUserId = request.actorUserId, acknowledgementOnly = true }
    end
    self.contributors[request.actorUserId] = true
    local receipt
    if payload.complete == true and not self.roundComplete then
        assert(next(draft.highlights) ~= nil and draft.reaction and draft.bookmark, "reading selections incomplete")
        receipt = self.session:CompleteRound({ activityId = self.ActivityId, roundId = request.roundId, actionId = request.actionId .. ":complete", actorUserId = request.actorUserId })
        self.roundComplete = true
    end
    local result = { ok = true, code = receipt and "COMPLETED" or (self.roundComplete and "ACKNOWLEDGED" or "SAVED"), receipt = receipt, draft = copyDraft(draft), view = self:GetView(request.actorUserId) }
    self.usedActions[request.actionId] = result
    return result
end

function Q04:GetView(actorUserId)
    local roundId = self.activeRoundId
    return { activityId = self.ActivityId, roundId = roundId, state = self.roundComplete and "ROUND_COMPLETE" or "IN_PROGRESS", title = "One More Chapter", instructions = "Choose a highlight, reaction, and bookmark; a note is optional.", progress = { done = self.roundComplete and 1 or 0, total = 1 }, availableActions = { { id = "save", label = "Save", stepId = "reading", enabled = not self.roundComplete }, { id = "close", label = "Close", stepId = "close", enabled = true }, { id = "replay", label = "Start next round", stepId = "replay", enabled = self.roundComplete } }, acceptedStepIds = {}, contributors = self.contributors, busyReason = nil, errorText = nil, canReplay = self.roundComplete }
end

return Q04
]=]},
{target=[=[ServerScriptService/PhuongMVP/server/activities/Q05]=],kind=[=[ModuleScript]=],sha=[=[2fd4d5713dae9f03cd85e1fdb976de293fe8c57390d64d3bc339fbab54043733]=],source=[=[local Config = require(script.Parent.Parent.Parent.shared.Config)
local Q05 = {}; Q05.__index = Q05
local Figures = {}; for _, id in ipairs(Config.RegularFigureIds) do table.insert(Figures, id) end; table.insert(Figures, Config.SecretFigureId)
local function valid(id) for _, value in ipairs(Figures) do if value == id then return true end end return false end
local function clone(map) local out = {}; for k, v in pairs(map) do out[k] = v end return out end

function Q05.new(ctx)
    assert(ctx and ctx.session, "Q05 requires session")
    return setmetatable({ctx = ctx, session = ctx.session, clock = ctx.clock or os.clock, outcome = ctx.outcome or function() return Figures[1] end, roundId = nil, wanted = nil, misses = 0, fulfilled = false, petalAwarded = false, collection = {}, receipts = {}, pendingReveal = nil}, Q05)
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
    return {activityId = "Q05", roundId = self.roundId, state = self.fulfilled and "FULFILLED" or "READY", title = "A Labubu Wish", instructions = "Inspect the figures, lock Phuong's wanted figure, then spend 20 from the shared birthday fund.", progress = {done = self.fulfilled and 1 or 0, total = 1}, availableActions = {{id = "inspect", label = "Inspect", stepId = "inspect", enabled = true}, {id = "select-wanted", label = "Lock wanted figure", stepId = "select-wanted", enabled = self:_canSpend(actorUserId)}, {id = "roll", label = "Roll (20)", stepId = "roll", enabled = self:_canSpend(actorUserId) and self.wanted ~= nil and snapshot.fundBalance >= Config.RollCost}}, acceptedStepIds = {}, contributors = {}, busyReason = nil, errorText = nil, canReplay = self.fulfilled, sharedFundBalance = snapshot.fundBalance, wantedFigureId = self.wanted, unsuccessfulRollCount = self.misses, q05Petal = snapshot.petals.Q05 == true, collection = clone(self.collection)}
end
Q05.Figures = Figures; return Q05
]=]},
}
local ALLOWED={ServerScriptService="PhuongMVP",ReplicatedStorage="PhuongMVP",ServerStorage="PhuongMVPTools",StarterPlayer="StarterPlayerScripts/PhuongMVPClient"}
local function mount(e)
 local p={};for x in string.gmatch(e.target,"[^/]+") do table.insert(p,x) end;local service=ALLOWED[p[1]];assert(service,"disallowed root service");assert(string.sub(e.target,1,#p[1]+1+#service)==p[1].."/"..service,"disallowed mount prefix")
 local par=game:GetService(p[1]);table.remove(p,1);local first=p[1];if p[1]=="StarterPlayerScripts" then par=par:FindFirstChild("StarterPlayerScripts");assert(par,"StarterPlayerScripts missing");table.remove(p,1);assert(p[1]=="PhuongMVPClient","disallowed client mount") end
 for i=1,#p-1 do local n=par:FindFirstChild(p[i]);if n then assert(n:IsA("Folder") and n:GetAttribute("PhuongMVPImportOwned"),"unowned intermediate folder") else n=Instance.new("Folder");n.Name=p[i];n:SetAttribute("PhuongMVPImportOwned",true);n.Parent=par end;par=n end
 local o=par:FindFirstChild(p[#p]);if o then assert(o:IsA(e.kind) and o:GetAttribute("PhuongMVPImportOwned"),"unowned source collision") else o=Instance.new(e.kind);o.Name=p[#p];o:SetAttribute("PhuongMVPImportOwned",true);o.Parent=par end;o.Source=HttpService:JSONDecode(HttpService:JSONEncode(e.source));assert(o.Source==e.source,"Source readback mismatch");o:SetAttribute("PhuongMVPSourceSHA256",e.sha);if o:IsA("Script") or o:IsA("LocalScript") then o.Enabled=false end
end
for _,e in ipairs(entries) do mount(e) end
print("mounted exact import chunk")
