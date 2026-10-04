-- Bounded, session-only recovery. Only Main supplies the authenticated actor.
local Config = require(script.Parent.Parent.shared.Config)
local Catalog = require(script.Parent.Parent.shared.FigureCatalog)
local HostService = {}; HostService.__index = HostService
local RESETTABLE = { Q01=true, Q03=true, Q06=true }
local QUEST_ACTIONS = { ReleaseReservations=true, RestartRound=true, CompleteQuest=true }
local OPERATIONS = { ReleaseReservations=true, RestartRound=true, CompleteQuest=true, TopUp=true, FulfillWish=true,
    InviteCake=true, StartCake=true, AdvanceCake=true, ReturnBedroom=true, ReturnPatio=true }
local TITLES = { Q01="Bed",Q02="Jasper",Q03="Craft",Q04="Reading",Q05="Labubu wish",Q06="Food" }
local LABELS = { ReleaseReservations="Release held choices",RestartRound="Restart incomplete round",CompleteQuest="Complete quest",
    TopUp="Add 20 to shared fund",FulfillWish="Fulfill selected Labubu wish",InviteCake="Invite everyone to cake",
    StartCake="Start birthday celebration",AdvanceCake="Advance to cut cake",ReturnBedroom="Return me to bedroom",ReturnPatio="Return me to patio" }
local function copy(value)
    if type(value)~="table" then return value end
    local out={}; for k,v in pairs(value) do out[k]=copy(v) end; return out
end
local function equal(a,b)
    if type(a)~=type(b) then return false end
    if type(a)~="table" then return a==b end
    for k,v in pairs(a) do if not equal(v,b[k]) then return false end end
    for k in pairs(b) do if a[k]==nil then return false end end
    return true
end
local function count(map) local n=0; for _ in pairs(map or {}) do n+=1 end; return n end
local function reject(code,message) return {ok=false,code=code,message=message} end
local function hostName(actor) return actor==Config.PhuongUserId and "Phuong" or "Andrew" end

function HostService.new(session,options)
    assert(session and options and options.activities and options.cake,"host dependencies required")
    return setmetatable({session=session,activities=options.activities,cake=options.cake,clock=options.clock or os.clock,
        runtime=options.runtime or {},overrides={},quotes={},results={},audit={},lastRequest={},serial=0,revision=0,
        requestCount=0,topUps=0,lastTopUp=nil},HostService)
end
function HostService:IsHost(actor)
    return actor==Config.PhuongUserId or actor==Config.HostUserId
end
function HostService:_present(actor)
    return self:IsHost(actor) and self.session:IsPresent(actor) and self.runtime.isWorld and self.runtime.isWorld(actor)==true
end
function HostService:_record(actor,operation,activityId,prior,new)
    self.revision+=1
    table.insert(self.audit,1,{actorUserId=actor,actor=hostName(actor),action=operation,activityId=activityId,
        prior=prior,new=new,timestamp=self.clock()})
    while #self.audit>32 do table.remove(self.audit) end
end
function HostService:ReleaseActor(actor)
    self.quotes[actor]=nil
    if self.overrides[actor] then
        self.overrides[actor]=nil
        self:_record(actor,"Override ended",nil,"Override active","Normal choices")
    end
end
function HostService:_state(activityId,operation)
    local activity=activityId and self.activities[activityId]
    local localState=activity and activity:RecoveryState() or nil
    local round=localState and localState.roundId and self.session.rounds[localState.roundId]
    local state={revision=self.revision,fund=self.session.fundBalance,petals=copy(self.session.petals),localState=copy(localState),
        round=round and {roundId=round.roundId,state=round.state,steps=copy(round.steps),isReplay=round.isReplay},
        missingReward=activityId and self.session:MissingInitialReward(activityId) or 0,topUps=self.topUps}
    if operation=="InviteCake" or operation=="StartCake" or operation=="AdvanceCake" then
        state.cake={phase=self.cake.phase,generation=self.cake.generation,revision=self.cake.revision,cutAt=self.cake.cutAt,startedAt=self.cake.startedAt}
    end
    return state
end
function HostService:_summary(state,activityId)
    local petals=0; for _,done in pairs(state.petals) do if done then petals+=1 end end
    local text="Shared fund "..state.fund.." · "..petals.."/6 petals"
    if activityId then
        text..=" · "..TITLES[activityId]..": "..(state.petals[activityId] and "petal saved" or "petal missing")
        if state.round then text..=" · "..count(state.round.steps).." saved steps ("..state.round.state..")" else text..=" · not started" end
        local localState=state.localState
        if localState and RESETTABLE[activityId] then
            local held=activityId=="Q01" and count(localState.reserved)+count(localState.shelfHolds)
                or activityId=="Q03" and count(localState.state and localState.state.reservations) or count(localState.reservations)
            text..=" · "..held.." held choices"
        end
    end
    if state.localState and state.localState.wanted then
        text..=" · wish: "..Catalog.Label(state.localState.wanted).." · "..(state.localState.collection[state.localState.wanted] or 0).." copies owned"
    end
    if state.cake then text..=" · cake "..state.cake.phase end
    return text
end
function HostService:_plan(operation,activityId)
    if not OPERATIONS[operation] then return nil,"Choose a listed recovery action." end
    if QUEST_ACTIONS[operation] then
        if not TITLES[activityId] or not self.activities[activityId] then return nil,"Choose one of the six available quests." end
    elseif activityId~=nil and not (operation=="FulfillWish" and activityId=="Q05") then return nil,"This action has no activity target." end
    if operation=="FulfillWish" then activityId="Q05" end
    local state=self:_state(activityId,operation)
    local effect
    if operation=="ReleaseReservations" or operation=="RestartRound" then
        if not RESETTABLE[activityId] then return nil,"Only the bed, craft and food have recoverable holds/rounds." end
        if not state.round or state.round.state~="IN_PROGRESS" then return nil,"Open an incomplete round first. Completed work is preserved." end
        effect=operation=="ReleaseReservations" and "Release every held choice for this activity. Keep all placed work, petals and funds."
            or "Discard only this incomplete round's placed work and holds, then open a fresh round. Keep all earned petals, shared funds and bedroom shelf placements. No reward is granted."
    elseif operation=="CompleteQuest" or operation=="FulfillWish" then
        if activityId=="Q05" then
            local wish=state.localState
            if not wish or not Catalog.ById[wish.wanted] then return nil,"Phuong must first confirm a wish at the Labubu booth; Andrew can choose normally while she is away." end
            if wish.recovered then return nil,"The one Labubu recovery for this server session was already used." end
            if wish.fulfilled or wish.purchasing then return nil,"The current wish is already fulfilled or a box is being saved." end
            effect="Add exactly one "..Catalog.Label(wish.wanted).." to the collection; fulfill the selected wish. "
                ..(state.petals.Q05 and "Keep the existing Q05 petal." or "Grant the missing Q05 petal once.")
                .." Spend 0 and grant 0 funds. Preserve paid rolls and misses. One wish recovery per server session."
        else
            if state.petals[activityId] and state.missingReward==0 then return nil,"This quest's initial petal and reward are already saved." end
            effect="Complete "..TITLES[activityId].." and its visible activity state. "..(state.petals[activityId] and "Keep its saved petal. " or "Grant its missing petal once. ")
                .."Add only the missing initial reward: "..state.missingReward..". No replay reward."
            if activityId=="Q01" then effect..=" Fill all bed tasks and use Soft and snug if no final style is saved. Keep the optional shelf." end
            if activityId=="Q02" then effect..=" Jasper finishes happy in the yard." end
            if activityId=="Q03" then effect..=" Keep placed orientations; fill missing pieces at zero turns. Phuong can still choose the finishing lamp." end
            if activityId=="Q04" then effect..=" Preserve every person's choices and private notes; no reading response is invented." end
            if activityId=="Q06" then effect..=" Keep accepted choices; fill only missing slots with Rice, Tofu, Greens, Sauce, Plate and Cup respectively." end
        end
    elseif operation=="TopUp" then
        if self.topUps>=5 then return nil,"All five +20 emergency top-ups have been used in this session." end
        local remaining=self.lastTopUp and math.ceil(30-(self.clock()-self.lastTopUp)) or 0
        if remaining>0 then return nil,"Wait "..remaining.." seconds before another top-up." end
        effect="Add exactly 20 to the shared fund: "..state.fund.." → "..(state.fund+20)..". Top-up "..(self.topUps+1).." of 5 this session; wait 30 seconds between top-ups. No petal changes."
    elseif operation=="InviteCake" or operation=="StartCake" then
        if not self.session:AllPetalsComplete() then return nil,"All six petals are required before cake recovery." end
        if self.cake.startedAt then return nil,"The celebration has already started and cannot restart." end
        effect=operation=="InviteCake" and "Arm the normal invitation and Phuong's seat. If Phuong is already seated, the celebration begins now. Nobody is moved."
            or "Start the single birthday celebration now, bypassing the normal Phuong seat trigger. Keep seats and optional personal camera/Skip controls. No rewards."
    elseif operation=="AdvanceCake" then
        if self.cake.cutAt or (self.cake.phase~="CELEBRATING" and self.cake.phase~="CAKE_READY") then return nil,"Start the celebration first; an already-cut cake cannot be cut twice." end
        effect="End any remaining birthday presentation and make the first cut once. Everyone can take a slice; optional cameras return and saved slice/eating state remains. No rewards."
    else
        effect="Release only your activity holds, leave your seat safely and move only you to the "..(operation=="ReturnBedroom" and "bedroom arrival." or "patio arrival.").." No progress or funds change."
    end
    return {operation=operation,activityId=activityId,label=LABELS[operation],state=state,current=self:_summary(state,activityId),effect=effect}
end
function HostService:GetView(actor)
    if not self:IsHost(actor) then return nil end
    local actions={}
    local function add(operation,id)
        local plan,reason=self:_plan(operation,id)
        table.insert(actions,{operation=operation,activityId=id,label=LABELS[operation],enabled=plan~=nil,reason=reason})
    end
    for _,id in ipairs(Config.ActivityIds) do
        if RESETTABLE[id] then add("ReleaseReservations",id); add("RestartRound",id) end
        add("CompleteQuest",id)
    end
    for _,op in ipairs({"TopUp","FulfillWish","InviteCake","StartCake","AdvanceCake","ReturnBedroom","ReturnPatio"}) do add(op) end
    local active={}; for _,id in ipairs({Config.PhuongUserId,Config.HostUserId}) do if self.overrides[id] then table.insert(active,hostName(id)) end end
    local quote=self.quotes[actor]
    if quote and quote.expiresAt<=self.clock() then self.quotes[actor]=nil; quote=nil end
    return {authorized=true,actor=hostName(actor),override=self.overrides[actor]==true,activeOverrides=active,revision=self.revision,
        fundBalance=self.session.fundBalance,petals=copy(self.session.petals),actions=actions,audit=copy(self.audit),
        topUpsUsed=self.topUps,topUpLimit=5,topUpAmount=20,topUpCooldown=30,requestCount=self.requestCount,requestLimit=512,
        confirmation=quote and {token=quote.token,label=quote.label,current=quote.current,effect=quote.effect,expiresAt=quote.expiresAt},
        inWorld=self:_present(actor),hint="Normal choices stay Phuong-first. Override is for deliberate recovery by Phuong or Andrew."}
end
function HostService:_execute(plan,request)
    local operation,id=plan.operation,plan.activityId
    if operation=="TopUp" then
        self.session:AddFund(20); self.topUps+=1; self.lastTopUp=self.clock()
    elseif QUEST_ACTIONS[operation] or operation=="FulfillWish" then
        local activity=self.activities[id]
        local roundId=activity:RecoveryState().roundId
        if not roundId then
            roundId=self.runtime.newRoundId(id)
            activity:CreateRound({sessionId=request.sessionId,actionId=request.actionId,activityId=id,roundId=roundId,actorUserId=request.actorUserId})
            self.runtime.setRoundId(id,roundId)
        end
        local recovery={sessionId=request.sessionId,actionId=request.actionId,actorUserId=request.actorUserId,activityId=id,roundId=roundId}
        if operation=="ReleaseReservations" then activity:RecoverRelease(recovery)
        elseif operation=="RestartRound" then
            roundId=activity:RecoverRestart(recovery,self.runtime.newRoundId(id)); self.runtime.setRoundId(id,roundId)
        else
            local receipt=activity:RecoverComplete(recovery); self.runtime.setRoundId(id,roundId)
            return {ok=true,receipt=receipt}
        end
    elseif operation=="InviteCake" or operation=="StartCake" or operation=="AdvanceCake" then
        local cakeRequest={sessionId=request.sessionId,actionId="host-cake:"..request.actionId,actorUserId=request.actorUserId,
            generation=self.cake.generation,action=operation=="InviteCake" and "Arm" or operation=="StartCake" and "RecoverStart" or "RecoverCut"}
        if operation=="InviteCake" then return self.cake:Apply(cakeRequest) end
        return self.cake:Recover(cakeRequest)
    else
        local destination=operation=="ReturnBedroom" and "Bedroom" or "Patio"
        if not self.runtime.travel(request.actorUserId,destination) then return reject("HostTravelUnavailable","Your character or destination is unavailable. Try again after respawning.") end
        return {ok=true,destination=destination}
    end
    return {ok=true}
end

local FIELDS={kind=true,sessionId=true,actionId=true,actorUserId=true,action=true,enabled=true,operation=true,activityId=true,token=true}
function HostService:Apply(request)
    if type(request)~="table" or not self:_present(request.actorUserId) then return reject("HostPermission","Only Phuong and Andrew in the birthday world can use host controls.") end
    if request.sessionId~=self.session.sessionId or type(request.actionId)~="string" or #request.actionId<1 or #request.actionId>96 then return reject("HostIdentity","Reopen host controls for this session.") end
    for field in pairs(request) do if not FIELDS[field] then return reject("HostMalformed","Use one of the listed host controls.") end end
    local command=request.action
    if command~="Prepare" and command~="Confirm" and command~="Cancel" and command~="SetOverride" then return reject("HostMalformed","Use one of the listed host controls.") end
    if command=="SetOverride" then
        if type(request.enabled)~="boolean" or request.operation~=nil or request.activityId~=nil or request.token~=nil then return reject("HostMalformed","Choose whether Override is enabled.") end
    elseif command=="Prepare" then
        if type(request.operation)~="string" or request.token~=nil or request.enabled~=nil or (request.activityId~=nil and type(request.activityId)~="string") then return reject("HostMalformed","Choose a listed recovery action.") end
    elseif type(request.token)~="string" or #request.token>128 or request.operation~=nil or request.activityId~=nil or request.enabled~=nil then return reject("HostMalformed","Review the confirmation before continuing.") end
    local identity={actor=request.actorUserId,action=command,enabled=request.enabled,operation=request.operation,activityId=request.activityId,token=request.token}
    local previous=self.results[request.actionId]
    if previous then
        if not equal(previous.identity,identity) then return reject("HostIdentityChanged","That request already represents another choice.") end
        return copy(previous.result)
    end
    if self.session.receipts[request.actionId] or self.session.acceptedSteps[request.actionId] or self.session.receipts["host-cake:"..request.actionId] then return reject("HostActionUsed","That request was already used. Choose again.") end
    if self.requestCount>=512 then return reject("HostLimit","This session reached its host request limit. Ordinary play remains available.") end
    local actor,at=request.actorUserId,self.clock()
    if self.lastRequest[actor] and at-self.lastRequest[actor]<.5 then return reject("HostTooQuick","Wait a moment for your last host choice to settle.") end
    self.lastRequest[actor]=at
    local result
    if command=="SetOverride" then
        local before=self.overrides[actor]==true
        self.overrides[actor]=request.enabled; self.quotes[actor]=nil
        if before~=request.enabled then self:_record(actor,"Override "..(request.enabled and "enabled" or "ended"),nil,before and "Override active" or "Normal choices",request.enabled and "Override active" or "Normal choices") end
        result={ok=true,code="HostOverride",message=request.enabled and "Override active. Every recovery still needs a current-state confirmation." or "Override ended. Normal choices remain active."}
    elseif command=="Cancel" then
        if self.quotes[actor] and self.quotes[actor].token==request.token then self.quotes[actor]=nil end
        result={ok=true,code="HostCancelled",message="Recovery cancelled. Nothing changed."}
    elseif not self.overrides[actor] then return reject("HostOverrideRequired","Enable Override explicitly before preparing a recovery.")
    elseif command=="Prepare" then
        local plan,reason=self:_plan(request.operation,request.activityId)
        if not plan then return reject("HostUnavailable",reason) end
        self.serial+=1; plan.token="host:"..self.serial..":"..actor; plan.expiresAt=at+30
        self.quotes[actor]=copy(plan)
        result={ok=true,code="HostPrepared",message="Review the current state and exact effect, then Confirm or Cancel.",confirmation={token=plan.token,label=plan.label,current=plan.current,effect=plan.effect,expiresAt=plan.expiresAt}}
    else
        local plan=self.quotes[actor]
        if not plan or plan.token~=request.token or plan.expiresAt<=at then self.quotes[actor]=nil; return reject("HostQuoteExpired","That confirmation expired or belongs to another host. Review a fresh preview.") end
        local fresh,reason=self:_plan(plan.operation,plan.activityId)
        if not fresh or not equal(plan.state,fresh.state) then self.quotes[actor]=nil; return reject("HostStateChanged",reason or "The shared state changed. Review a fresh preview before confirming.") end
        self.quotes[actor]=nil
        local called,outcome=pcall(self._execute,self,plan,request)
        if not called then
            local activity=plan.activityId and self.activities[plan.activityId]
            local current=activity and activity:RecoveryState().roundId
            if current then self.runtime.setRoundId(plan.activityId,current) end
            warn("PCW-24 recovery needs attention",outcome)
            self:_record(actor,plan.operation.." needs review",plan.activityId,plan.current,self:_summary(self:_state(plan.activityId,plan.operation),plan.activityId))
            result=reject("HostRecoveryFailed","Recovery could not fully finish. Current state is refreshed; review it before trying again.")
        elseif not outcome.ok then result=outcome
        else
            self:_record(actor,plan.operation,plan.activityId,plan.current,self:_summary(self:_state(plan.activityId,plan.operation),plan.activityId))
            result={ok=true,code="HostRecovered",message=plan.label.." saved.",operation=plan.operation,activityId=plan.activityId,receipt=outcome.receipt,destination=outcome.destination}
        end
    end
    self.requestCount+=1
    self.results[request.actionId]={identity=identity,result=copy(result)}
    self.session.receipts[request.actionId]={actorUserId=actor,actionId=request.actionId,hostRecovery=true}
    return result
end
return HostService
