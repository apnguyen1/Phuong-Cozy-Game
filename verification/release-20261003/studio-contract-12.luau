_G.__PCW25ContractText..=[==[k~=false then pcall(function() CozyAudio.Accepted(r,result) end) end
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
		if frame then self.readingFram]==]
return #_G.__PCW25ContractText