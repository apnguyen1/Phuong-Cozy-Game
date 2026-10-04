local HttpService=game:GetService("HttpService")
local ServerScriptService=game:GetService("ServerScriptService")
local parent=assert(ServerScriptService.PhuongMVP.server.activities,"activities missing")
local old=assert(parent:FindFirstChild("Q05"),"owned target missing")
assert(old:IsA("ModuleScript") and old:GetAttribute("PhuongMVPImportOwned"),"owned ModuleScript required")
local expectedSource=HttpService:JSONDecode(HttpService:JSONEncode([=[local Config = require(script.Parent.Parent.Parent.shared.Config)
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
]=]))
assert(type(expectedSource)=="string" and #expectedSource>0,"source payload missing")
local replacement=Instance.new("ModuleScript")
replacement.Name="Q05"
replacement:SetAttribute("PhuongMVPImportOwned",true)
replacement:SetAttribute("PhuongMVPSourceSHA256","3C9FC62692DFA1A7F16CD88D203BEB1367CBC8EBB6B72596B41FEEB0D3DB6B74")
replacement.Source=expectedSource
assert(replacement.Source==expectedSource,"source readback mismatch")
replacement.Parent=parent
old:Destroy()
return true
