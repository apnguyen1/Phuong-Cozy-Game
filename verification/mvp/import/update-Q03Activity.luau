local HttpService=game:GetService("HttpService")
local ServerScriptService=game:GetService("ServerScriptService")
local parent=assert(ServerScriptService.PhuongMVP.server.activities,"activities missing")
local old=assert(parent:FindFirstChild("Q03"),"owned target missing")
assert(old:IsA("ModuleScript") and old:GetAttribute("PhuongMVPImportOwned"),"owned target required")
local wasDisabled=(old:IsA("Script") or old:IsA("LocalScript")) and old.Disabled
local expectedSource=HttpService:JSONDecode(HttpService:JSONEncode([=[local Q03 = {}
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
function Q03:_canFinalize(actorUserId)
    if not self.session:IsPresent(actorUserId) then return false end
    if actorUserId == self.session.phuongUserId then return true end
    return not self.session:IsPresent(self.session.phuongUserId) and self.session.hostUserId ~= 0 and actorUserId == self.session.hostUserId
end
function Q03:_round(request) return self.stateByRound[request.roundId] end
function Q03:_view(roundId, actorUserId, errorText)
    local state = self.stateByRound[roundId]
    local accepted, contributors = {}, {}
    if state then for id in pairs(state.accepted) do table.insert(accepted, id) end; for id in pairs(state.contributors) do table.insert(contributors, id) end end
    local done = state and #self:_committedParts(state) or 0
    local actions = {}
    if state and state.status == "IN_PROGRESS" then
        for part, socket in pairs(SOCKETS) do
            local entry = state.sockets[socket]
            local enabled = entry.status == "AVAILABLE"
            table.insert(actions, {id="reserve:"..part, label="Place "..part, stepId="reserve:"..part, payload={action="reserve",socketId=socket,partId=part}, enabled=enabled, reason=enabled and nil or "Socket is reserved or placed"})
            if entry.status == "RESERVED" and entry.ownerUserId == actorUserId then
                table.insert(actions, {id="rotate-left:"..part,label="Rotate left",stepId="rotate-left:"..part,payload={action="rotate",socketId=socket,direction=-1},enabled=true})
                table.insert(actions, {id="rotate-right:"..part,label="Rotate right",stepId="rotate-right:"..part,payload={action="rotate",socketId=socket,direction=1},enabled=true})
                table.insert(actions, {id="place:"..part,label="Place",stepId="place:"..part,payload={action="place",socketId=socket,partId=part},enabled=true})
                table.insert(actions, {id="cancel:"..part,label="Cancel",stepId="cancel:"..part,payload={action="cancel",socketId=socket},enabled=true})
            end
        end
    elseif state and state.status == "COMPLETED" then
        local allowed = self:_canFinalize(actorUserId)
        for _, presentation in ipairs({"lamp_on", "lamp_off"}) do table.insert(actions, {id="finalize:"..presentation,label="Choose "..presentation,stepId="finalize:"..presentation,payload={action="finalize",presentation=presentation},enabled=allowed and state.finalizationReceipt == nil,reason=allowed and nil or "Phuong or configured host only"}) end
    end
    return {activityId="Q03", roundId=roundId, state=state and state.status or "NONE", title="A Tiny World of Her Own", instructions="Place each tiny piece in its matching socket.", progress={done=done,total=#PARTS}, availableActions=actions, acceptedStepIds=accepted, contributors=contributors, busyReason=state and state.busyReason or nil, errorText=errorText, canReplay=state and state.status == "COMPLETED" or false}
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
        assert(self:_canFinalize(request.actorUserId), "not authorized or not present")
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
    local rounds = roundId and {[roundId]=self:_round({roundId=roundId})} or self.stateByRound
    for _, state in pairs(rounds) do if state and state.status == "IN_PROGRESS" then for socket, entry in pairs(state.reservations) do if entry.ownerUserId == actorUserId then entry.status="AVAILABLE"; entry.ownerUserId=nil; entry.partId=nil; entry.orientation=nil; state.reservations[socket]=nil end end end end
end
function Q03:GetView(actorUserId)
    for roundId, state in pairs(self.stateByRound) do if state.status == "IN_PROGRESS" then self:ExpireReservations(roundId) end end
    return self:_view(self.currentRoundId, actorUserId)
end
Q03.PARTS = PARTS; Q03.SOCKETS = SOCKETS
return Q03
]=]))
assert(type(expectedSource)=="string" and #expectedSource>0,"source payload missing")
local replacement=Instance.new("ModuleScript")
replacement.Name="Q03"
replacement:SetAttribute("PhuongMVPImportOwned",true)
replacement:SetAttribute("PhuongMVPSourceSHA256","D72B4E25EA406E6E5BA99FDF7F195BD4962DA85EE213BABC8F8E5557EAB8C4D3")
replacement.Source=expectedSource
assert(replacement.Source==expectedSource,"source readback mismatch")
if replacement:IsA("Script") or replacement:IsA("LocalScript") then replacement.Disabled=wasDisabled end
replacement.Parent=parent
old:Destroy()
return true
