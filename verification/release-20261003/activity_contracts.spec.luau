-- Pure server contracts using actual GetView descriptors, not retired shortcuts.
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
