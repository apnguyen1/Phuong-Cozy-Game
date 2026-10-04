_G.__PCW25ContractText..=[==[ssion:ApplyStep({ sessionId = "test-session", activityId = "Q05", roundId = "q05-r1", stepId = "q05-step", actionId = "q05-a1", actorUserId = 3971290001 })
local q05 = session:CompleteRound({ sessionId = "test-session", activityId = "Q05", roundId = "q05-r1", actionId = "complete-q05", actorUserId = 3971290001 })
expect(q05.fundRewardGranted == 0, "Q05 must never earn fund currency")

local auth = SessionService.new({ sessionId = "auth-test", phuongUserId = 7, hostUserId = 1078077474 })
auth:AddFund(20)
auth:SetPresence(7, true)
auth:SetPresence(1078077474, true)
local function rejected(callback)
    local ok = pcall(callback)
    expect(not ok, "request should be rejected")
end
rejected(function() auth:CommitPurchase({ actorUserId = 99, actionId = "guest", cost = 20, awardFigureId = "x" }) end)
rejected(function() auth:CommitPurchase({ actorUserId = 1078077474, actionId = "host-while-phuong-present", cost = 20, awardFigureId = "x" }) end)
auth:SetPresence(7, false)
local hostPurchase = auth:CommitPurchase({ actorUserId = 1078077474, actionId = "host-while-phuong-away", cost = 20, awardFigureId = "x" })
expect(hostPurchase.debitApplied, "host may act only while Phuong is absent")
auth:AddFund(20)
auth:SetPresence(1078077474, false)
rejected(function() auth:CommitPurchase({ actorUserId = 1078077474, actionId = "disconnected-host", cost = 20, awardFigureId = "x" }) end)
return true
]=],
["roblox/mvp/tests/teleport_adapter.spec.luau"] = [=[local TeleportAdapter = require(script.Parent.Parent.server.TeleportAdapter)

local calls = 0
local reserves = 0
local fakeTeleport = {
	TeleportAsync = function(_, placeId, players, options)
		calls += 1
		assert(placeId == 123, "configured destination is used")
		assert(#players == 2, "whole party is submitted")
		assert(options.ReservedServerAccessCode == "reserved-test", "same reserved destination is reused")
		return { ReservedServerAccessCode = "test-only" }
	end,
}

local adapter = TeleportAdapter.new({ GameplayPlaceId = 123, MaxRetries = 1 }, {
	teleportService = fakeTeleport,
	reserveServer = function(placeId)
		reserves += 1
		assert(placeId == 123, "reservation uses configured destination")
		return "reserved-test", "private-test"
	end,
	isStudio = false,
	wait = function() end,
})
local ok, reason = adapter:Transfer({ "p1", "p2" }, {
	rosterId = "birthday-1",
	destinationReservationId = "destination-1",
	members = { 1, 2 },
})
assert(ok and reason == "Dispatched" and calls == 1 and reserves == 1, "production adapter reserves and submits once")
local retryOk, retryReason = adapter:RetryMember("p1", {
	rosterId = "birthday-1",
	destinationReservationId = "destination-1",
	members = { 1, 2 },
	reservedServerAccessCode = "reserved-test",
}, 1)
assert(retryOk and retryReason == "RetryDispatched" and reserves == 1, "retry reuses reservation")

local studioAdapter = TeleportAdapter.new({ GameplayPlaceId = 123 }, {
	isStudio = true,
	teleportService = fakeTeleport,
})
ok, reason = studioAdapter:Transfer({}, { members = {} })
assert(not ok and reason == "StudioTeleportUnsupported", "Studio never pretends teleport succeeded")

return true
]=],
["roblox/mvp/update-lobby-circle.luau"] = [=[-- Apply in Studio Edit mode after updating the Main and QueueService sources.

local root=workspace.CozyWorld_Draft01

local portal=root.BirthdayLobby.Portal

local old=root.MVP.Stations:FindFirstChild("LobbyQueue")

if old then old:ClearAllChildren() end

local pad=portal.TeleportPad

local anchor=root.MVP.Anchors:FindFirstChild("BirthdayLobbyQueue",true)

if anchor then anchor.CFrame=CFrame.new(pad.Position) end

local oldGui=pad:FindFirstChild("BoardingCountdown")

if oldGui then oldGui:Destroy() end

for _,v in portal.PortalInstructions:GetDescendants() do if v:IsA("TextLabel") then v.Text="Enter Phuong’s home whenever you’re ready\nPress E at the circle • tap on mobile" end end

local prompt=portal.PortalPrompt.EnterWorld

prompt.Enabled=true; prompt.ActionText="Enter Phuong’s home"; prompt.ObjectText="Birthday world"; prompt.HoldDuration=0; prompt.KeyboardKeyCode=Enum.KeyCode.E

return "Boarding circle installed; obsolete square removed"

]=],
["roblox/mvp/tests/release_activity_contracts.spec.luau"] = [=[-- Pure server contracts using actual GetView descriptors, not retired shortcuts.
-- Does not establish Roblox UI, replication, devices, geometry or performance.
local Session = require(script.Parent.Parent.server.SessionService)
local Q01 = require(script.Parent.Parent.server.activities.Q01)
local Q05 = require(script.Parent.Parent.server.activities.Q05)
local Q06 = require(script.Parent.Parent.server.activities.Q06)
local P, A, G, H = 3971290001, 1078077474, 101, 102
local serial = 0
local function expect(value, message) assert(value, message) end
local function copy(value)
    if type(value) ~= "table" then return value end
    local result = {}; for k, v in pairs(value) do result[k] = copy(v) end; return result
end
local function fresh(label)
    local session = Session.new({sessionId=label, phuongUserId=P, hostUserId=A})
    for _, actor in ipairs({P,A,G,H}) do session:SetPresence(actor, true) end
    return session
end
local function descriptor(activity, actor, predicate, allowDisabled)
    for _, action in ipairs(activity:GetView(actor).availableActions or {}) do
        if predicate(action) and (allowDisabled or action.enabled ~= false) then return copy(action) end
    end
    error("Required current view action missing for actor " .. tostring(actor))
end
local function envelope(session, activity, actor, action, id)
    serial += 1
    local view = activity:GetView(actor)
    return {sessionId=session.sessionId, activityId=view.activityId, roundId=view.roundId,
        actorUserId=actor, actionId=id or (session.sessionId .. ":" .. serial),
        stepId=action.stepId, payload=copy(action.payload or {})}
end
local function apply(session, activity, actor, predicate)
    local request = envelope(session, activity, actor, descriptor(activity, actor, predicate))
    local result = activity:Apply(request)
    expect(result.ok, "Current descriptor rejected: " .. tostring(result.code) .. " " .. tostring(result.message))
    return result, request
end
local function actionIs(operation, step)
    return function(action) return action.payload.action == operation and (not step or action.stepId == step) end
end

-- Bed: holds are exclusive and expire, previews have no reward, each accepted
-- task is shared, only Phuong normally finishes, optional shelf earns nothing.
do
    local session, tick = fresh("bed-contract"), 0
    local feedback = {shelfReady=true, BeginRound=function() end, ApplyStep=function() end,
        Finish=function() end, RenderShelf=function() end}
    local activity = Q01.new({session=session, clock=function() return tick end, feedback=feedback})
    activity:CreateRound({activityId="Q01", roundId="bed:1", actorUserId=P})
    local reserve = descriptor(activity, G, actionIs("reserve", "blanket_left"))
    local request = envelope(session, activity, G, reserve)
    expect(activity:Apply(request).ok, "Guest can pick up bed task")
    expect(session.fundBalance == 0 and not session.petals.Q01, "Preview grants nothing")
    local clash = envelope(session, activity, H, reserve)
    expect(not activity:Apply(clash).ok, "Two guests cannot hold same bed spot")
    tick = 31; activity:ExpireReservations(tick)
    expect(activity:GetView(G).held == nil, "Expired bed selection disappears")
    apply(session, activity, H, actionIs("reserve", "blanket_left"))
    apply(session, activity, H, actionIs("cancel", "blanket_left"))
    for _, step in ipairs(Q01.StepIds) do
        apply(session, activity, G, actionIs("reserve", step))
        local result, placed = apply(session, activity, G, actionIs("place", step))
        expect(activity:Apply(placed).ok, "Exact bed duplicate returns prior result")
    end
    local finishing = descriptor(activity, P, actionIs("finish"))
    expect(not activity:Apply(envelope(session, activity, G, finishing)).ok, "Guest cannot finish Phuong's bed")
    expect(not activity:Apply(envelope(session, activity, A, finishing)).ok, "Andrew normal finish waits while Phuong present")
    local _, completed = apply(session, activity, P, actionIs("finish"))
    activity:Apply(completed)
    expect(session.fundBalance == 20 and session.petals.Q01, "Bed initial reward once")
    apply(session, activity, G, function(a) return a.payload.action == "shelf_select" and a.payload.itemId == "book_sage" end)
    apply(session, activity, G, function(a) return a.payload.action == "shelf_slot" and a.payload.slotId == "left" end)
    apply(session, activity, G, actionIs("shelf_place"))
    expect(session.fundBalance == 20 and activity.shelfSlots.left == "book_sage", "Shelf arrangement has no reward")
    local occupied = {stepId="shelf", payload={action="shelf_select", itemId="book_sage"}}
    expect(not activity:Apply(envelope(session, activity, H, occupied)).ok, "Guest cannot rearrange occupied shelf")
    apply(session, activity, P, function(a) return a.payload.action == "shelf_select" and a.payload.itemId == "book_sage" end)
    activity:ReleaseActor(P)
    activity:CreateRound({activityId="Q01", roundId="bed:2", actorUserId=P, replay=true})
    expect(activity.shelfSlots.left == "book_sage", "Bed replay preserves shelf layout")
    for _, step in ipairs(Q01.StepIds) do
        apply(session, activity, G, actionIs("reserve", step)); apply(session, activity, G, actionIs("place", step))
    end
    apply(session, activity, P, actionIs("finish"))
    expect(session.fundBalance == 30, "Explicit bed replay adds only 10")
    print("CONTRACT bed: shared holds, expiry, cancellation, role, reward, shelf, replay")
end

-- Food: exact card variants, honest counter boundaries, reservations, replay.
do
    local session, tick, places = fresh("food-contract"), 0, {[P]="FOB",[G]="FOB",[H]="FOB"}
    local activity = Q06.new({session=session, clock=function() return tick end,
        context={foodVenue=function(actor) return places[actor] end}})
    local function round(id, replay)
        activity:CreateRound({sessionId=session.sessionId, activityId="Q06", roundId=id, actorUserId=P, replay=replay})
    end
    local function select(slot, item)
        return function(a) return a.payload.action == "select" and a.payload.slotId == slot and a.payload.itemId == item end
    end
    round("food:1", false)
    local base = descriptor(activity, G, select("base", "rice"))
    local _, reserved = apply(session, activity, G, select("base", "rice"))
    expect(session.fundBalance == 0 and activity:GetView(G).progress.done == 0, "Food preview adds no ingredient or reward")
    expect(not activity:Apply(envelope(session, activity, H, base)).ok, "Food slot has one owner")
    local staleAdd = descriptor(activity, G, actionIs("add", "base"))
    tick = 31; activity:ExpireReservations(tick)
    expect(not activity:Apply(envelope(session, activity, G, staleAdd)).ok, "Expired food hold cannot commit")
    local recipe = {{"base","rice","FOB"},{"protein","mushroom","FOB"},{"toppings","carrot","FOB"},
        {"sauce","sesame","Aladdins"},{"settingA","napkin","Serving"},{"settingB","cup","Serving"}}
    for _, part in ipairs(recipe) do
        places[G] = part[3]
        apply(session, activity, G, select(part[1],part[2]))
        local add = descriptor(activity, G, actionIs("add",part[1]))
        places[G] = "Away"
        expect(not activity:Apply(envelope(session, activity, G, add)).ok, "Cannot add food from another venue")
        places[G] = part[3]
        local _, accepted = apply(session, activity, G, actionIs("add",part[1]))
        activity:Apply(accepted)
        expect(activity:GetView(G).foodDisplay[part[1]].itemId == part[2], "Exact selected food preserved")
    end
    expect(session.fundBalance == 20 and session.petals.Q06, "Shared food completes once")
    round("food:2", true)
    for _, part in ipairs(recipe) do
        places[G] = part[3]; apply(session, activity, G, select(part[1],part[2])); apply(session, activity, G, actionIs("add",part[1]))
    end
    expect(session.fundBalance == 30, "Food explicit replay adds 10")
    print("CONTRACT food: held previews, venue, expiry, variant, first/replay reward")
end

-- Labubu: all tests start from real descriptors, then mutate one boundary.
local function labubu(label, desired, outcome, amount, feedback)
    local session = fresh(label); session:AddFund(amount or 100)
    local activity = Q05.new({session=session, outcome=outcome or function() return "BigIntoEnergy02" end,
        clock=function() return 1234 end, feedback=feedback})
    activity:CreateRound({activityId="Q05", roundId=label .. ":round", actorUserId=P})
    local choice = function(a) return a.stepId == "select-wanted" and a.payload.figureId == desired end
    return session, activity, choice
end
do
    local session, activity, choice = labubu("guarantee", "BigIntoEnergySecret")
    local wish = descriptor(activity,P,choice)
    expect(not activity:Apply(envelope(session,activity,G,wish)).ok, "Guest cannot choose wish")
    expect(not activity:Apply(envelope(session,activity,A,wish)).ok, "Andrew normal controls defer to Phuong")
    local _, chosen = apply(session,activity,P,choice)
    expect(activity:Apply(chosen).ok, "Exact confirmed wish retry is harmless")
    expect(not activity:Apply(envelope(session,activity,P,wish)).ok, "Stale wish confirmation rejects")
    for roll=1,5 do
        local rollChoice = function(a) return a.stepId == "roll" end
        local displayed = descriptor(activity,P,rollChoice)
        local result, request = apply(session,activity,P,rollChoice)
        expect(result.receipt.debitApplied and result.receipt.cost == 20, "Successful box spends exactly 20")
        expect(session.fundBalance == 100-roll*20, "Box fund balance exact")
        expect(activity:GetView(P).collectionCount == roll, "One copy per box")
        local saved = activity:GetView(P).latestResult
        expect(saved and saved.awardedAt == 1234 and saved.receiptId == result.receipt.receiptId, "Result is saved before reveal")
        activity:ReleaseActor(P); expect(activity:Apply(request).ok, "Close/retry keeps receipt")
        expect(not activity:Apply(envelope(session,activity,P,displayed)).ok, "Distinct stale ID cannot buy same displayed roll")
        local changedActor = copy(request); changedActor.actorUserId=G
        expect(not activity:Apply(changedActor).ok, "Changed actor cannot reuse purchase ID")
        if roll < 5 then expect(not session.petals.Q05, "Miss does not grant petal") end
    end
    expect(session.petals.Q05 and activity:GetView(P).wishFulfilled and session.fundBalance == 0, "Fifth selected secret is guaranteed within 100")
    apply(session,activity,P,function(a) return a.stepId == "select-wanted" and a.payload.figureId == "BigIntoEnergy02" end)
    expect(activity:GetView(P).wishFulfilled and session.fundBalance == 0 and session.petals.Q05, "Owned optional wish costs nothing and keeps story completion")
    print("CONTRACT Labubu: permissions, secret guarantee, stale/duplicate receipt, optional owned wish")
end
do
    local session, activity, choice = labubu("early", "BigIntoEnergy01", function() return "BigIntoEnergy01" end)
    session:SetPresence(P,false)
    apply(session,activity,A,choice)
    apply(session,activity,A,function(a) return a.stepId=="roll" end)
    expect(session.fundBalance == 80 and session.petals.Q05 and activity:GetView(A).collectionCount == 1, "Andrew fallback early success only costs 20, Q05 earns zero")
    local poor, box, choose = labubu("poor", "BigIntoEnergy01", nil, 0)
    apply(poor,box,P,choose)
    local unavailable = descriptor(box,P,function(a) return a.stepId=="roll" end,true)
    expect(not box:Apply(envelope(poor,box,P,unavailable)).ok and poor.fundBalance == 0, "Insufficient funds reject without award")
    local broken, awarded, selectWish = labubu("display-failure", "BigIntoEnergy01", function() return "BigIntoEnergy01" end,100,
        {Render=function() error("Intentional presentation failure") end})
    apply(broken,awarded,P,selectWish)
    local _, saved = apply(broken,awarded,P,function(a) return a.stepId=="roll" end)
    awarded:Apply(saved)
    expect(broken.fundBalance == 80 and broken.petals.Q05 and awarded:GetView(P).collectionCount == 1, "Rendering failure cannot duplicate debit or lose award")
    print("CONTRACT Labubu: early win, Andrew fallback, no-fund, presentation failure")
end
do
    local values = {{0,"BigIntoEnergy01"},{0.164999,"BigIntoEnergy01"},{0.165,"BigIntoEnergy02"},
        {0.329999,"BigIntoEnergy02"},{0.989999,"BigIntoEnergy06"},{0.990001,"BigIntoEnergySecret"},{0.999999,"BigIntoEnergySecret"}}
    for index, item in ipairs(values) do
        local session = fresh("odds" .. index)
        local activity = Q05.new({session=session, random=function() return item[1] end})
        expect(activity:_draw() == item[2], "16.5% regular / 1% secret boundary")
    end
    print("CONTRACT Labubu: regular and secret probability boundaries")
end
return true
]=],
["roblox/mvp/tests/release_cake_contracts.spec.luau"] = [=[-- Cake authority contracts. Fixtures model authenticated IDs; actual seats,
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
]=],
["roblox/mvp/tests/release_host_contracts.spec.luau"] = [=[-- Final-stage host contracts. These positive IDs are fixtures, not shipped
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
    assert(not f.host:GetView(A).override,"Old mode receipt cannot reenable cleared auth]==]
return #_G.__PCW25ContractText