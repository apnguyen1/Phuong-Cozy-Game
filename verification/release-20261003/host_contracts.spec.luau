-- Final-stage host contracts. These positive IDs are fixtures, not shipped
-- permissions or evidence of real users joining. Ordinary UI/travel is separate.
local Session=require(script.Parent.Parent.server.SessionService)
local Cake=require(script.Parent.Parent.server.CakeService)
local Host=require(script.Parent.Parent.server.HostService)
local Q={Q01=require(script.Parent.Parent.server.activities.Q01),Q02=require(script.Parent.Parent.server.activities.Q02),
    Q03=require(script.Parent.Parent.server.activities.Q03),Q04=require(script.Parent.Parent.server.activities.Q04),
    Q05=require(script.Parent.Parent.server.activities.Q05),Q06=require(script.Parent.Parent.server.activities.Q06)}
local P,A,G=3971290001,1078077474,401
local serial=0
local function copy(t) local r={};for k,v in pairs(t) do r[k]=v end;return r end
local function fixture(name)
    local session=Session.new({sessionId=name,phuongUserId=P,hostUserId=A})
    local f={session=session,time=0,world={[P]=true,[A]=true,[G]=true},rounds={},travels={}}
    for _,actor in ipairs({P,A,G}) do session:SetPresence(actor,true) end
    local clock=function() return f.time end
    local world={isPresent=function(actor) return session:IsPresent(actor) end,
        foodVenue=function() return "FOB" end,chooseRabbitBasket=function() return 2 end}
    f.activities={Q01=Q.Q01.new({session=session,clock=clock}),Q02=Q.Q02.new({session=session,clock=clock,world=world}),
        Q03=Q.Q03.new({session=session,clock=clock,context=world}),Q04=Q.Q04.new({session=session,clock=clock,context=world}),
        Q05=Q.Q05.new({session=session,clock=clock,context=world}),Q06=Q.Q06.new({session=session,clock=clock,context=world})}
    for _,id in ipairs({"Q01","Q02","Q03","Q04","Q05","Q06"}) do
        f.rounds[id]=name..":"..id
        f.activities[id]:CreateRound({sessionId=name,activityId=id,roundId=f.rounds[id],actorUserId=P})
    end
    f.cake=Cake.new(session,{clock=clock})
    f.cake:SetRuntime({isWorld=function(actor) return f.world[actor]==true end,isAtPatio=function() return true end,occupant=function() return nil end})
    f.host=Host.new(session,{activities=f.activities,cake=f.cake,clock=clock,runtime={
        isWorld=function(actor) return f.world[actor]==true end,
        newRoundId=function(id) serial+=1;return name..":recovery:"..id..":"..serial end,
        setRoundId=function(id,roundId) f.rounds[id]=roundId end,
        travel=function(actor,destination) table.insert(f.travels,{actor=actor,destination=destination});return true end}})
    return f
end
local function call(f,actor,action,fields)
    f.time+=1;serial+=1
    local request=copy(fields or {})
    request.sessionId=f.session.sessionId;request.actorUserId=actor;request.actionId=f.session.sessionId..":host:"..serial;request.action=action
    return f.host:Apply(request),request
end
local function good(result,why) assert(type(result)=="table" and result.ok==true,(type(why)=="string" and why or "Host action")..": "..tostring(result and result.code).." "..tostring(result and result.message));return result end
local function bad(result,why) assert(type(result)=="table" and result.ok==false,why) end
local function enable(f,actor) good(call(f,actor,"SetOverride",{enabled=true})) end
local function prepare(f,actor,operation,id)
    local result=good(call(f,actor,"Prepare",{operation=operation,activityId=id}),"Prepare "..operation)
    assert(result.confirmation and type(result.confirmation.token)=="string","Server issues confirmation token")
    return result.confirmation
end
local function recover(f,actor,operation,id)
    local quote=prepare(f,actor,operation,id)
    local result,request=call(f,actor,"Confirm",{token=quote.token})
    return good(result,"Confirm "..operation),request
end
local function activityAction(f,id,actor,predicate)
    local activity=f.activities[id];local view=activity:GetView(actor)
    for _,descriptor in ipairs(view.availableActions or {}) do
        if descriptor.enabled~=false and predicate(descriptor) then
            serial+=1
            local request={sessionId=f.session.sessionId,activityId=id,roundId=view.roundId,actorUserId=actor,
                actionId=f.session.sessionId..":normal:"..serial,stepId=descriptor.stepId,payload=descriptor.payload}
            good(activity:Apply(request),"Normal activity action")
            return request
        end
    end
    error("Required ordinary descriptor absent for "..id)
end
do
    local f=fixture("host-auth")
    assert(f.host:GetView(G)==nil,"Guests receive no private host audit/control view")
    assert(f.host:GetView(P) and f.host:GetView(A),"Both exact configured IDs see controls")
    bad(call(f,G,"SetOverride",{enabled=true}),"Guest cannot enable override")
    bad(call(f,A,"Prepare",{operation="TopUp"}),"Host mutation requires explicit override")
    enable(f,A)
    local quote=prepare(f,A,"TopUp")
    bad(call(f,P,"Confirm",{token=quote.token}),"Other host cannot steal an actor-bound quote")
    bad(call(f,G,"Confirm",{token=quote.token}),"Guest cannot use host quote")
    local accepted,request=call(f,A,"Confirm",{token=quote.token});good(accepted)
    assert(f.session.fundBalance==20,"Exactly fixed20 topup")
    good(f.host:Apply(request),"Same request retries original outcome")
    assert(f.session.fundBalance==20,"Duplicate confirmation cannot add money")
    local altered=copy(request);altered.actorUserId=P
    bad(f.host:Apply(altered),"Changed actor cannot reuse request identity")
    bad(call(f,A,"Confirm",{token=quote.token}),"Consumed quote cannot be committed with a fresh ID")
    local forged=copy(request);forged.sessionId="wrong-session";forged.actionId="forged-session"
    bad(f.host:Apply(forged),"Wrong session rejected")
    bad(call(f,A,"Prepare",{operation="ExecuteCode"}),"No arbitrary host commands")
    bad(call(f,A,"Prepare",{operation="CompleteQuest",activityId="Q99"}),"Activity allowlist enforced")
    f.time+=31;quote=prepare(f,A,"TopUp");f.session:AddFund(1)
    bad(call(f,A,"Confirm",{token=quote.token}),"Changed balance invalidates previously quoted effect")
    quote=prepare(f,A,"ReturnBedroom");f.time+=31
    bad(call(f,A,"Confirm",{token=quote.token}),"Expired confirmation rejects")
    quote=prepare(f,A,"ReturnPatio")
    good(call(f,A,"Cancel",{token=quote.token}))
    bad(call(f,A,"Confirm",{token=quote.token}),"Cancel leaves no usable mutation quote")
    f.world[A]=false
    bad(call(f,A,"Prepare",{operation="TopUp"}),"Lobby actor cannot recover world progress")
    print("CONTRACT host auth: real roles, override, quote owner, stale/expiry/cancel, duplicate, session, allowlist")
end
do
    local f=fixture("host-activities");enable(f,A)
    for _,id in ipairs({"Q01","Q03","Q06"}) do
        local held=activityAction(f,id,G,function(d) return d.payload.action=="reserve" or d.payload.action=="select" end)
        recover(f,A,"ReleaseReservations",id)
        assert(f.session.fundBalance==0 and not f.session.petals[id],"Releasing held previews grants no progress")
        activityAction(f,id,P,function(d) return d.payload.action=="reserve" or d.payload.action=="select" end)
        recover(f,A,"RestartRound",id)
        assert(f.activities[id]:GetView(P).roundId==f.rounds[id] and f.rounds[id]~=held.roundId,"Restart synchronizes local and routing round IDs")
        local stale=copy(held);stale.actionId=held.actionId..":stale-round"
        local ok,result=pcall(f.activities[id].Apply,f.activities[id],stale)
        assert(not ok or result.ok==false,"Prior round action cannot mutate replacement")
    end
    for _,id in ipairs({"Q01","Q02","Q03","Q04","Q06"}) do
        local _,request=recover(f,A,"CompleteQuest",id)
        good(f.host:Apply(request))
        assert(f.session.petals[id] and f.activities[id]:GetView(P).canReplay,"Recovery completes local view and petal together")
    end
    assert(f.session.fundBalance==100,"Only five missing initial earning rewards")
    assert(f.activities.Q04:GetView(P).draft.note=="" and f.activities.Q04:GetView(G).draft.note=="","Recovery never fabricates personal reading notes")
    local before=f.session.fundBalance
    local repeatPrepare=call(f,A,"Prepare",{operation="CompleteQuest",activityId="Q01"})
    if repeatPrepare.ok then good(call(f,A,"Confirm",{token=repeatPrepare.confirmation.token})) end
    assert(f.session.fundBalance==before,"Fresh repeated complete cannot repeat initial reward")
    activityAction(f,"Q05",P,function(d) return d.stepId=="select-wanted" and d.payload.figureId=="BigIntoEnergySecret" end)
    local _,wishRequest=recover(f,A,"FulfillWish");good(f.host:Apply(wishRequest))
    local box=f.activities.Q05:GetView(P)
    assert(f.session.petals.Q05 and box.wishFulfilled and box.collectionCount==1,"Wish recovery supplies exactly one wanted copy and sixth petal")
    assert(f.session.fundBalance==100 and box.latestResult.cost==0 and box.latestResult.debitApplied==false,"Recovery is honestly no-cost")
    assert(f.session:AllPetalsComplete(),"Recovered state can reach normal cake unlock")
    -- Andrew can deliberately act while Phuong is present; ordinary controls
    -- are separately checked by the ordinary activity contracts.
    recover(f,A,"StartCake")
    assert(f.cake:GetState(P).generation==1,"Explicit recovery starts one shared generation")
    recover(f,A,"AdvanceCake")
    assert(f.cake:GetState(P).cutAt~=nil and f.cake:GetState(P).phase=="CAKE_READY","Recovery ends camera timeline and makes real slices available")
    recover(f,A,"ReturnBedroom");recover(f,A,"ReturnPatio")
    assert(#f.travels==2 and f.travels[1].actor==A and f.travels[2].actor==A,"Travel moves only requesting host through bounded destinations")
    assert(f.session.fundBalance==100,"Cake/travel never add rewards")
    print("CONTRACT host recovery: holds, coherent restart/completion, missing rewards, no-cost wish, cake and host-only travel")
end
do
    local f=fixture("host-topup-cap");enable(f,P)
    for index=1,5 do
        f.time+=31;recover(f,P,"TopUp")
        assert(f.session.fundBalance==index*20,"Topups have fixed increments")
    end
    f.time+=31
    local result=call(f,P,"Prepare",{operation="TopUp"})
    if result.ok then bad(call(f,P,"Confirm",{token=result.confirmation.token}),"Topup session cap enforced at commit") end
    assert(f.session.fundBalance==100,"Bounded recovery cannot add a sixth topup")
    print("CONTRACT host fixed topup: both hosts, cooldown-spaced confirmation, session cap")
end
do
    local f=fixture("host-bounds");local last
    for index=1,512 do
        local result,request=call(f,A,"SetOverride",{enabled=index%2==0})
        good(result);last=request
    end
    local view=f.host:GetView(A)
    assert(view.requestCount==512 and #view.audit==32,"Request memory and recent audit have explicit bounds")
    bad(call(f,A,"SetOverride",{enabled=false}),"Fresh request after cap rejects")
    good(f.host:Apply(last),"Exact old receipt remains retryable at request cap")
    f.host:ReleaseActor(A)
    assert(not f.host:GetView(A).override and f.host:GetView(A).confirmation==nil,"Reset/departure clears override and quote")
    good(f.host:Apply(last))
    assert(not f.host:GetView(A).override,"Old mode receipt cannot reenable cleared authority")
    activityAction(f,"Q01",G,function(d) return d.payload.action=="reserve" end)
    assert(f.session.fundBalance==0,"Ordinary guest activity remains usable after host request cap")
    print("CONTRACT host bounds: audit32, request512, cached retries, departure reset, ordinary play unaffected")
end
return true
