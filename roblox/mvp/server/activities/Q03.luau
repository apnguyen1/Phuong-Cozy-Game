-- One shared miniature. SessionService retains the original six-part reward timing.
local Q03 = {}; Q03.__index = Q03
local PARTS = {"rug", "chair", "bookcase", "side_table", "plant", "lamp"}
local SOCKETS = {rug="rugSocket", chair="chairSocket", bookcase="bookcaseSocket", side_table="sideTableSocket", plant="plantSocket", lamp="lampSocket"}
local LABELS = {rug="Rug", chair="Chair", bookcase="Bookcase", side_table="Side table", plant="Plant", lamp="Lamp"}
local function copy(t) local r={}; for k,v in pairs(t) do r[k]=type(v)=="table" and copy(v) or v end; return r end
local function validId(value) return type(value)=="string" and value~="" end
local function validActorId(value) return type(value)=="number" and value>0 and value%1==0 end
local function identity(r)
    local p=r.payload or {}
    return table.concat({tostring(r.actorUserId),tostring(r.roundId),tostring(r.stepId),tostring(p.action),tostring(p.partId),tostring(p.socketId),tostring(p.direction),tostring(p.presentation)},":")
end
local function free(entry)
    entry.status="AVAILABLE"; entry.ownerUserId=nil; entry.partId=nil; entry.orientation=nil; entry.lastActivity=nil
end
function Q03.new(options)
    assert(options and options.session and options.clock and options.context,"Q03 context dependencies are required")
    return setmetatable({session=options.session,actorResolver=options.actorResolver,clock=options.clock,context=options.context,rounds={},actions={},actionIdentities={},stateByRound={},currentRoundId=nil,expiryRevision=0},Q03)
end
function Q03:_actor(request)
    local actor=self.actorResolver and self.actorResolver(request) or request.actorUserId
    return actor and actor==request.actorUserId and self.session:IsPresent(actor)
end
function Q03:_canFinalize(actor)
    if not self.session:IsPresent(actor) then return false end
    return actor==self.session.phuongUserId or (not self.session:IsPresent(self.session.phuongUserId) and self.session.hostUserId~=0 and actor==self.session.hostUserId)
end
function Q03:_round(request) return self.stateByRound[request.roundId] end
function Q03:_committedParts(state) local r={}; for _,id in ipairs(PARTS) do if state.committed[id] then table.insert(r,id) end end; return r end
function Q03:_render(state)
    if not self.context.renderCraft then return end
    local ok,err=pcall(self.context.renderCraft,self.currentRoundId,state.committed,state.reservations,state.finalPresentation)
    if not ok then warn("PCW-22 craft presentation",err) end
end
function Q03:_view(roundId,actor,errorText)
    local state=self.stateByRound[roundId]; local actions,accepted,contributors,pieces={},{},{},{}
    local done=state and #self:_committedParts(state) or 0
    local held
    for _,id in ipairs(PARTS) do
        local socket=SOCKETS[id]; local entry=state and state.sockets[socket]
        local committed=state and state.committed[id]
        if committed then table.insert(accepted,id) end
        table.insert(pieces,{id=id,label=LABELS[id],socketId=socket,complete=committed~=nil,orientation=committed and committed.orientation or 0,busy=entry and entry.status=="RESERVED" or false})
        if entry and entry.status=="RESERVED" and entry.ownerUserId==actor then held={partId=id,label=LABELS[id],socketId=socket,orientation=entry.orientation,expiresAt=entry.lastActivity+15} end
        if state and state.status=="IN_PROGRESS" and not committed then
            local available=entry.status=="AVAILABLE"
            table.insert(actions,{id="reserve:"..id,label="Pick up "..LABELS[id],stepId="reserve:"..id,payload={action="reserve",socketId=socket,partId=id},enabled=available,
                reason=available and nil or entry.ownerUserId==actor and "Already selected. Turn it or place it below." or "A friend is using this socket.",groupId="parts",description="Fits the labeled "..LABELS[id].." socket. Preview before placing.",confirm=false})
        end
    end
    if state then for id in pairs(state.contributors) do table.insert(contributors,id) end end
    if held then
        for _,direction in ipairs({-1,1}) do
            local side=direction<0 and "left" or "right"
            table.insert(actions,{id="rotate-"..side..":"..held.partId,label="Turn "..held.label.." "..side.." · 90°",stepId="rotate-"..side..":"..held.partId,payload={action="rotate",socketId=held.socketId,direction=direction},enabled=true,groupId="placement",confirm=false})
        end
        table.insert(actions,{id="place:"..held.partId,label="Place "..held.label,stepId="place:"..held.partId,payload={action="place",socketId=held.socketId,partId=held.partId},enabled=true,groupId="placement",primary=true,description="Save this orientation in the shared miniature at both locations.",confirm=false})
        table.insert(actions,{id="cancel:"..held.partId,label="Put "..held.label.." back",stepId="cancel:"..held.partId,payload={action="cancel",socketId=held.socketId},enabled=true,groupId="placement",confirm=false})
    end
    if state and state.status=="COMPLETED" and not state.finalizationReceipt then
        local allowed=self:_canFinalize(actor)
        for _,option in ipairs({{id="lamp_on",label="A warm golden lamp"},{id="lamp_off",label="A quiet cream lamp"}}) do
            table.insert(actions,{id="finalize:"..option.id,label=option.label,stepId="finalize:"..option.id,payload={action="finalize",presentation=option.id},enabled=allowed,reason=allowed and nil or "Phuong adds the finishing touch. Andrew can help when Phuong is away.",groupId="finish",description="Choose how the completed keepsake is displayed. Your petal is already saved.",confirm={title="Finish the shared keepsake?",detail=option.label.." will appear at the booth and in the bedroom.",label="Save finishing touch"}})
        end
    end
    local finishing=state and state.status=="COMPLETED" and not state.finalizationReceipt
    local detail=finishing and "All six parts are placed. Phuong can choose the finishing touch here or at the bedroom keepsake; Andrew can help when she is away. The shared reward is already saved."
        or state and state.finalizationReceipt and "The shared keepsake is finished at the booth and in the bedroom. Your petal is saved; another round is optional."
        or held and (held.label.." selected · turn left or right, then Place. The golden socket and translucent piece are a preview.")
        or "Pick a labeled piece. Match its socket, turn it if you like, then Place. Friends can work on different pieces together."
    return {activityId="Q03",roundId=roundId,state=state and state.status or "NONE",title="A Tiny World of Her Own",instructions=detail,progress={done=done,total=#PARTS},availableActions=actions,
        acceptedStepIds=accepted,contributors=contributors,errorText=errorText,canReplay=state and state.status=="COMPLETED" or false,
        craft={pieces=pieces,held=held,finalPresentation=state and state.finalPresentation,needsFinishing=finishing==true},
        guide={headline=finishing and "Ready for Phuong's finishing touch" or state and state.finalizationReceipt and "Keepsake finished!" or "Build one tiny world together",detail=detail,nextAnchor=done==6 and "Q03BedroomDisplay" or "Q03FairCraft",
            groups={{id="placement",title="Turn and place your piece",detail="Each turn is a quarter turn. Any orientation fits its matching socket."},{id="parts",title="Choose a tiny part",detail="Accepted parts stay saved at both locations."},{id="finish",title="Phuong's finishing touch"}}}}
end
function Q03:CreateRound(request)
    assert(request and request.sessionId==self.session.sessionId and request.activityId=="Q03" and validId(request.roundId) and validActorId(request.actorUserId) and self:_actor(request),"invalid Q03 round")
    local previous=self.currentRoundId and self.stateByRound[self.currentRoundId]
    assert(not previous or (previous.status=="COMPLETED" and request.replay==true),"finish the shared round before an explicit replay")
    assert(not self.rounds[request.roundId],"round already exists")
    self.session:CreateRound("Q03",request.roundId,request.actorUserId,request.replay==true)
    local sockets={}; for _,socket in pairs(SOCKETS) do sockets[socket]={status="AVAILABLE"} end
    self.rounds[request.roundId]=true; self.currentRoundId=request.roundId
    local state={status="IN_PROGRESS",sockets=sockets,committed={},accepted={},contributors={},reservations={}}
    self.stateByRound[request.roundId]=state; self:_render(state)
    return self:GetView(request.actorUserId)
end
function Q03:Apply(request)
    assert(request and request.sessionId==self.session.sessionId and request.activityId=="Q03" and request.roundId==self.currentRoundId and validId(request.actionId) and validId(request.stepId) and validActorId(request.actorUserId),"invalid Q03 request")
    assert(self:_actor(request),"unauthenticated actor")
    if self.actions[request.actionId] then
        assert(self.actionIdentities[request.actionId]==identity(request),"action identity changed")
        local result=copy(self.actions[request.actionId]); result.view=self:GetView(request.actorUserId); return result
    end
    assert(not (self.session.receipts and self.session.receipts[request.actionId]) and not (self.session.acceptedSteps and self.session.acceptedSteps[request.actionId]),"action belongs to another receipt")
    local state=assert(self:_round(request),"unknown Q03 round")
    self:ExpireReservations(request.roundId)
    local p=request.payload or {}; local action=p.action; local result
    if action=="finalize" then
        assert(request.stepId=="finalize:"..tostring(p.presentation),"step does not match finishing choice")
        assert(state.status=="COMPLETED" and self:_canFinalize(request.actorUserId),"Phuong or available host must finalize the completed keepsake")
        assert(p.presentation=="lamp_on" or p.presentation=="lamp_off","invalid presentation")
        if state.finalizationReceipt then result=state.finalizationReceipt
        else
            state.finalPresentation=p.presentation
            result={ok=true,code="FINALIZED",receipt={receiptId="q03-final:"..request.roundId,roundId=request.roundId,presentation=p.presentation,actorUserId=request.actorUserId}}
            state.finalizationReceipt=result
        end
    else
        assert(state.status=="IN_PROGRESS","Q03 round is not active")
        if action=="reserve" then
            assert(SOCKETS[p.partId]==p.socketId and request.stepId=="reserve:"..tostring(p.partId),"part does not fit socket")
            local entry=assert(state.sockets[p.socketId],"unknown socket"); assert(entry.status=="AVAILABLE","socket is busy or placed")
            -- One selected piece per helper; changing cards releases the old preview.
            for socket,old in pairs(state.reservations) do if old.ownerUserId==request.actorUserId then free(old); state.reservations[socket]=nil end end
            entry.status="RESERVED"; entry.ownerUserId=request.actorUserId; entry.partId=p.partId; entry.orientation=0; entry.lastActivity=self.clock()
            state.reservations[p.socketId]=entry; result={ok=true,code="SELECTED",socketId=p.socketId,partId=p.partId,orientation=0}
        elseif action=="rotate" or action=="place" or action=="cancel" then
            local entry=assert(state.reservations[p.socketId],"choose that piece again; the selection was released")
            assert(entry.ownerUserId==request.actorUserId,"not reservation owner")
            if action=="rotate" then
                assert(p.direction==1 or p.direction==-1,"quarter-turn direction required")
                assert(request.stepId=="rotate-"..(p.direction<0 and "left" or "right")..":"..entry.partId,"step does not match rotation")
                entry.orientation=(entry.orientation+p.direction)%4; entry.lastActivity=self.clock(); result={ok=true,code="ROTATED",orientation=entry.orientation}
            elseif action=="place" then
                assert(entry.partId==p.partId and request.stepId=="place:"..entry.partId,"piece mismatch")
                local accepted=self.session:ApplyStep({sessionId=request.sessionId,activityId="Q03",roundId=request.roundId,stepId=entry.partId,actionId=request.actionId,actorUserId=request.actorUserId})
                state.committed[entry.partId]={socketId=p.socketId,orientation=entry.orientation,ownerUserId=request.actorUserId}
                state.accepted[entry.partId]=true; state.contributors[request.actorUserId]=true; entry.status="PLACED"; state.reservations[p.socketId]=nil
                result={ok=true,code="PLACED",step=accepted}
                if #self:_committedParts(state)==#PARTS then
                    result.completion=self.session:CompleteRound({sessionId=request.sessionId,activityId="Q03",roundId=request.roundId,actionId="complete:"..request.actionId,actorUserId=request.actorUserId})
                    result.receipt=result.completion; state.status="COMPLETED"
                end
            else
                assert(request.stepId=="cancel:"..entry.partId,"step does not match selection")
                free(entry); state.reservations[p.socketId]=nil; result={ok=true,code="RELEASED",released=true}
            end
        else error("unknown Q03 action") end
    end
    self.actions[request.actionId]=result; self.actionIdentities[request.actionId]=identity(request)
    self:_render(state)
    local reply=copy(result); reply.view=self:GetView(request.actorUserId); return reply
end
function Q03:ExpireReservations(roundId)
    local state=self.stateByRound[roundId or self.currentRoundId]
    if not state or state.status~="IN_PROGRESS" then return false end
    local changed=false; local current=self.clock()
    for socket,entry in pairs(state.reservations) do
        if current-entry.lastActivity>=15 then free(entry); state.reservations[socket]=nil; changed=true end
    end
    if changed then self.expiryRevision+=1; self:_render(state) end
    return changed
end
function Q03:ReleaseActor(actor,roundId)
    if roundId and roundId~=self.currentRoundId then return false end
    local state=self.stateByRound[self.currentRoundId]; if not state then return false end
    local changed=false
    for socket,entry in pairs(state.reservations) do if entry.ownerUserId==actor then free(entry); state.reservations[socket]=nil; changed=true end end
    if changed then self:_render(state) end
    return changed
end
function Q03:RecoveryState()
    return { roundId=self.currentRoundId, state=self.stateByRound[self.currentRoundId] }
end
function Q03:RecoverRelease(request)
    self.session:AssertRecovery(request)
    local state=self.stateByRound[self.currentRoundId]
    if state then
        for socket,entry in pairs(state.reservations) do free(entry); state.reservations[socket]=nil end
        self.expiryRevision+=1; self:_render(state)
    end
end
function Q03:RecoverRestart(request,newRoundId)
    self.session:RecoverCancel(request); self:RecoverRelease(request)
    self.currentRoundId=nil
    self:CreateRound({sessionId=request.sessionId,activityId="Q03",roundId=newRoundId,actorUserId=request.actorUserId})
    return newRoundId
end
function Q03:RecoverComplete(request)
    self.session:AssertRecovery(request); self:RecoverRelease(request)
    local state=assert(self.stateByRound[self.currentRoundId],"missing craft round")
    for _,part in ipairs(PARTS) do
        self.session:RecoverStep(request,part)
        state.committed[part]=state.committed[part] or {socketId=SOCKETS[part],orientation=0,ownerUserId=request.actorUserId}
        state.accepted[part]=true; state.sockets[SOCKETS[part]].status="PLACED"
    end
    state.contributors[request.actorUserId]=true
    local receipt=self.session:RecoverCompleteRound(request)
    state.status="COMPLETED"; self:_render(state)
    return receipt
end
function Q03:GetView(actor)
    self:ExpireReservations(self.currentRoundId)
    return self:_view(self.currentRoundId,actor)
end
Q03.PARTS=PARTS; Q03.SOCKETS=SOCKETS
return Q03
