-- Q02 Jasper's Favorite Things. Server-owned activity adapter.
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
