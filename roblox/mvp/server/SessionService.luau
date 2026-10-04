local Config = require(script.Parent.Parent.shared.Config)

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
