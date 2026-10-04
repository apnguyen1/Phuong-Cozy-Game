-- Cake authority contracts. Fixtures model authenticated IDs; actual seats,
-- camera, sound, avatar slices and mobile controls require live Studio evidence.
local Session = require(script.Parent.Parent.server.SessionService)
local Cake = require(script.Parent.Parent.server.CakeService)
local P,A,G,H = 3971290001,1078077474,301,302
local serial=0
local function fixture(name)
    local session=Session.new({sessionId=name,phuongUserId=P,hostUserId=A})
    local state={time=0,occupant=nil,world={[P]=true,[A]=true,[G]=true,[H]=true},patio={[P]=true,[A]=true,[G]=true,[H]=true}}
    for _,actor in ipairs({P,A,G,H}) do session:SetPresence(actor,true) end
    local cake=Cake.new(session,{clock=function() return state.time end})
    cake:SetRuntime({isWorld=function(actor) return state.world[actor]==true end,
        isAtPatio=function(actor) return state.patio[actor]==true end,
        occupant=function() return state.occupant end})
    return session,cake,state
end
local function allPetals(session)
    for id in pairs(session.petals) do session.petals[id]=true end
end
local function envelope(session,cake,state,actor,action,generation,id)
    serial+=1;state.time+=1
    return {sessionId=session.sessionId,actorUserId=actor,actionId=id or (session.sessionId..":"..serial),
        action=action,generation=generation or cake:GetState(actor).generation}
end
local function descriptor(cake,actor,operation)
    for _,item in ipairs(cake:GetState(actor).availableActions) do
        if item.action==operation and item.enabled then return item end
    end
    error("Required cake action is not offered: "..operation)
end
local function apply(session,cake,state,actor,operation)
    local item=descriptor(cake,actor,operation)
    local request=envelope(session,cake,state,actor,item.action,item.generation)
    local result=cake:Apply(request)
    assert(result.ok,tostring(result.code).." "..tostring(result.message))
    return result,request
end
local function reject(result,why) assert(result.ok==false,why) end
do
    local session,cake,state=fixture("cake-normal")
    state.occupant=P;cake:Tick()
    assert(cake:GetState(P).phase=="LOCKED","Phuong cannot start before six petals")
    state.occupant=G;allPetals(session);cake:Tick()
    assert(cake:GetState(P).phase=="GATHERING","Unlock auto-arms without a separate Start")
    assert(cake:GetState(P).generation==0,"Guest occupancy cannot start birthday")
    state.occupant=P;state.time=5;cake:Tick()
    local beginning=cake:GetState(P)
    assert(beginning.phase=="CELEBRATING" and beginning.generation==1 and beginning.startedAt==5,"Phuong seat begins once")
    state.occupant=nil;state.time=8;cake:Tick();state.occupant=P;cake:Tick()
    assert(cake:GetState(P).startedAt==5 and cake:GetState(P).generation==1,"Unseat/reseat cannot restart")
    assert(cake:GetState(H).startedAt==5 and cake:GetState(H).endsAt==beginning.endsAt,"Late participant receives same timeline")
    state.time=beginning.endsAt;cake:Tick()
    assert(cake:GetState(P).phase=="CAKE_READY","Server time advances with no client acknowledgement")
    reject(cake:Apply(envelope(session,cake,state,G,"Cut")),"Guest cannot cut")
    reject(cake:Apply(envelope(session,cake,state,A,"Cut")),"Andrew normal flow cannot replace Phuong cut")
    reject(cake:Apply(envelope(session,cake,state,P,"Cut",0)),"Old generation cannot mutate new celebration")
    local _,cut=apply(session,cake,state,P,"Cut")
    assert(cake:Apply(cut).ok,"Exact cut retry is idempotent")
    local _,taken=apply(session,cake,state,G,"TakeSlice")
    assert(cake:Apply(taken).ok,"Exact take-slice retry returns receipt")
    reject(cake:Apply(envelope(session,cake,state,G,"TakeSlice")),"A second slice cannot be granted with a new ID")
    local changed={};for k,v in pairs(taken) do changed[k]=v end;changed.actorUserId=H
    reject(cake:Apply(changed),"Another actor cannot reuse slice receipt")
    apply(session,cake,state,G,"Eat")
    local firstBite=cake:GetState(G).biteCount
    reject(cake:Apply(envelope(session,cake,state,G,"Bite")),"Bites are rate-limited")
    apply(session,cake,state,G,"Bite")
    assert(cake:GetState(G).biteCount==firstBite+1 and session.fundBalance==0,"Cosmetic repeat bite grants no reward")
    assert(cake:GetState(H).sliceTaken==false,"Each participant owns only their slice state")
    state.patio[H]=false
    reject(cake:Apply(envelope(session,cake,state,H,"TakeSlice")),"Taking cake requires actual patio presence")
    state.patio[H]=true;apply(session,cake,state,H,"TakeSlice")
    state.world[G]=false
    reject(cake:Apply(envelope(session,cake,state,G,"Bite")),"Lobby participant cannot eat remotely")
    state.world[G]=true
    assert(cake:GetState(G).hasEaten,"Return/reset retains individual cake moment")
    reject(cake:Apply(envelope(session,cake,state,P,"Arm")),"Invite cannot reset a completed celebration")
    assert(cake:GetState(P).generation==1 and cake:GetState(P).phase=="EATING","Finale advances monotonically")
    print("CONTRACT cake normal: lock, auto-arm, seat identity, one generation, late state, cut, slices, bites, no repeat reward")
end
do
    local session,cake,state=fixture("cake-delay")
    state.occupant=P
    apply(session,cake,state,A,"Delay")
    allPetals(session);cake:Tick()
    assert(cake:GetState(P).phase=="READY" and cake:GetState(P).generation==0,"Explicit delay survives unlock while Phuong seated")
    reject(cake:Apply(envelope(session,cake,state,G,"Arm")),"Guest cannot arm")
    apply(session,cake,state,A,"Arm")
    assert(cake:GetState(P).phase=="CELEBRATING" and cake:GetState(P).generation==1,"Arming evaluates already-seated Phuong")
    reject(cake:Apply(envelope(session,cake,state,A,"Delay")),"No cancellation after start")
    print("CONTRACT cake delay: pre-unlock pause, guest rejection, already-seated arming, no restart")
end
do
    local session,cake,state=fixture("cake-recovery")
    session:SetPresence(P,false);state.world[P]=false;state.occupant=A
    reject(cake:Recover(envelope(session,cake,state,A,"RecoverStart")),"Recovery cannot bypass petals")
    allPetals(session);cake:Tick()
    assert(cake:GetState(A).phase=="GATHERING","Andrew seating does not silently replace Phuong trigger")
    reject(cake:Apply(envelope(session,cake,state,A,"RecoverStart")),"Normal public route cannot call recovery")
    reject(cake:Recover(envelope(session,cake,state,G,"RecoverStart")),"Guest cannot call recovery method")
    local request=envelope(session,cake,state,A,"RecoverStart")
    assert(cake:Recover(request).ok and cake:Recover(request).ok,"Authorized recovery starts once and dedupes")
    local generation=cake:GetState(A).generation
    local advance=envelope(session,cake,state,A,"RecoverCut")
    assert(cake:Recover(advance).ok,"Explicit recovery may advance and cut while celebrating")
    assert(cake:GetState(A).phase=="CAKE_READY" and cake:GetState(A).cutAt~=nil,"Recovery produces coherent ready slices")
    assert(cake:GetState(A).endsAt==state.time and cake:GetState(A).generation==generation,"Recovery ends same timeline rather than starting another")
    reject(cake:Recover(envelope(session,cake,state,A,"RecoverStart")),"Recovery cannot restart")
    apply(session,cake,state,A,"TakeSlice");apply(session,cake,state,A,"Eat")
    assert(cake:GetState(A).hasEaten and session.fundBalance==0,"Recovered party still supports real cake flow")
    print("CONTRACT cake recovery: explicit method, host identity, petals, monotonic advance, slices")
end
return true
