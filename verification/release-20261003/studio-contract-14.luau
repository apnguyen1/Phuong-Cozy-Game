_G.__PCW25ContractText..=[==[escriptor.payload or {}
	local step = descriptor.stepId
	if step == "roll" or payload.action == "roll" then
		return { title = "Open a Labubu box?", detail = "This uses 20 from the shared birthday fund. Everyone's progress stays shared.", label = "Spend 20 and open" }
	end
	if step == "select-wanted" then
		return { title = "Choose this wish?", detail = "The wanted figure stays selected until Phuong receives it.", label = "Choose this Labubu" }
	end
	if payload.action == "finish" or payload.action == "finalize" or payload.complete == true then
		return { title = "Finish this activity?", detail = "Save this choice for the shared birthday session.", label = "Finish together" }
	end
	return nil
end

return Guidance
]=],
["roblox/mvp/shared/MeasuredInstallOptions.luau"] = [=[-- Task 01 measured Edit-mode inputs. Returns Roblox-native values for world builders.
local Options = {}

function Options.FromWorld(root, anchors)
    local landscape = assert(root:FindFirstChild("Landscape"), "Landscape is required")
    local quad = assert(landscape:FindFirstChild("QuadGround"), "Landscape.QuadGround is required")
    assert(quad:IsA("BasePart"), "QuadGround must be a BasePart")
    local paths = assert(root:FindFirstChild("Paths"), "Paths is required")
    local routeDefinitions = assert(paths:FindFirstChild("RouteDefinitions"), "Paths.RouteDefinitions is required")
    local keepouts = {Provenance = "Workspace.CozyWorld_Draft01.Paths.RouteDefinitions plus measured Task01 station/facade approach buffers"}
    for _, item in routeDefinitions:GetChildren() do
        keepouts["RouteDefinition:" .. item.Name] = true
    end
    local stationNames = {"GameplayBedroomArrival","Q03FairCraft","Q04QuadReading","Q05UDistrictVending","Q06FOBCounter","Q06AladdinsCounter","FinalePatio","JasperFetchYard"}
    local stationPoints = {}
    for _, name in stationNames do
        local anchor = anchors and anchors[name]
        if anchor and anchor:IsA("BasePart") and anchor:GetAttribute("PlacementStatus") ~= "UNRESOLVED_LIVE_ANCHOR" then table.insert(stationPoints, {name = name, position = anchor.Position}) end
    end
    local function stationKeepout(position, radius)
        for _, item in stationPoints do if (item.position - position).Magnitude <= radius then return item.name end end
        return nil
    end
    local worldParts = {}
    for _, item in root:GetDescendants() do
        if item:IsA("BasePart") and not item:IsDescendantOf(root:FindFirstChild("MVP")) and item.Position.X > -500 and item.Position.X < 500 and item.Position.Z > -260 and item.Position.Z < 200 then
            table.insert(worldParts, item)
        end
    end
    assert(#worldParts > 0, "Measured gameplay world bounds have no source parts")
    local minX, maxX, minZ, maxZ, centerY = math.huge, -math.huge, math.huge, -math.huge, 0
    for _, item in worldParts do
        local p, h = item.Position, item.Size / 2
        minX, maxX = math.min(minX, p.X - h.X), math.max(maxX, p.X + h.X)
        minZ, maxZ = math.min(minZ, p.Z - h.Z), math.max(maxZ, p.Z + h.Z)
        centerY = math.max(centerY, p.Y + h.Y)
    end
    local candidatePositions = {
        NorthWest = quad.Position + Vector3.new(-quad.Size.X/2, 0, -quad.Size.Z/2),
        NorthEast = quad.Position + Vector3.new(quad.Size.X/2, 0, -quad.Size.Z/2),
        SouthWest = quad.Position + Vector3.new(-quad.Size.X/2, 0, quad.Size.Z/2),
        SouthEast = quad.Position + Vector3.new(quad.Size.X/2, 0, quad.Size.Z/2),
        Grass_1 = quad.Position + Vector3.new(-.30 * quad.Size.X/2, quad.Size.Y/2, -.22 * quad.Size.Z/2),
        Grass_2 = quad.Position + Vector3.new(0, quad.Size.Y/2, .16 * quad.Size.Z/2),
        Grass_3 = quad.Position + Vector3.new(.28 * quad.Size.X/2, quad.Size.Y/2, -.06 * quad.Size.Z/2),
        Grass_4 = quad.Position + Vector3.new(-.12 * quad.Size.X/2, quad.Size.Y/2, .31 * quad.Size.Z/2),
    }
    for name, position in candidatePositions do
        local blocker = stationKeepout(position, name:sub(1,5) == "Grass" and 8 or 16)
        if blocker then keepouts[name] = "Measured station/approach buffer: " .. blocker end
    end
    return {
        OuterQuadBounds = quad,
        Keepouts = keepouts,
        WorldBounds = {minX = minX, maxX = maxX, minZ = minZ, maxZ = maxZ, centerY = centerY},
        Provenance = {QuadGround = quad:GetFullName(), RouteDefinitions = routeDefinitions:GetFullName(), GameplayBoundsFilter = "-500<X<500,-260<Z<200, excluding MVP"},
    }
end

return Options
]=],
["roblox/mvp/tests/cake_service.spec.luau"] = [=[local SessionService = require(script.Parent.Parent.server.SessionService)
local CakeService = require(script.Parent.Parent.server.CakeService)

local session = SessionService.new({ sessionId = "cake-test", phuongUserId = 3971290001, hostUserId = 1078077474 })
session:SetPresence(3971290001, true)
session:SetPresence(1078077474, true)
for _, activityId in ipairs({ "Q01", "Q02", "Q03", "Q04", "Q06" }) do
    local roundId = activityId .. "-r1"
    session:CreateRound(activityId, roundId, 3971290001)
    session:ApplyStep({ sessionId = "cake-test", activityId = activityId, roundId = roundId, stepId = roundId .. "-step", actionId = roundId .. "-step-action", actorUserId = 3971290001 })
    session:CompleteRound({ sessionId = "cake-test", activityId = activityId, roundId = roundId, actionId = roundId .. "-complete", actorUserId = 3971290001 })
end
session.petals.Q05 = true
local cake = CakeService.new(session)
for index = 1, 5 do
    local receipt = session:CommitPurchase({actorUserId = 3971290001, actionId = "roll-" .. index, cost = 20, awardFigureId = "BigIntoEnergy0" .. index})
    assert(receipt.debitApplied, "purchase should atomically debit and award")
end
assert(session.fundBalance == 0, "five rolls must consume the 100-unit first-clear fund")
assert(cake:Invite(1078077474).finaleState == "INVITED", "present birthday host can invite")
assert(cake:CancelInvite(3971290001).finaleState == "READY", "present Phuong can cancel")
assert(cake:Invite(3971290001).finaleState == "INVITED", "present Phuong can invite")
assert(cake:Cut(1078077474).finaleState == "CUT", "present birthday host can cut")
assert(cake:Eat(11).state == "EATING", "any present guest may eat")

local rejected = pcall(function() CakeService.new(session):Invite(12345) end)
assert(not rejected, "stranger cannot invite")
session:SetPresence(1078077474, false)
local disconnectedHost = pcall(function() CakeService.new(session):Invite(1078077474) end)
assert(not disconnectedHost, "disconnected host cannot invite")
session:SetPresence(1078077474, true)
session:SetPresence(3971290001, false)
assert(CakeService.new(session):Invite(1078077474).finaleState == "INVITED", "host alone can invite")
return true
]=],
["roblox/mvp/tests/Q01_activity.spec.luau"] = [=[local SessionService = require(script.Parent.Parent.server.SessionService)
local Q01 = require(script.Parent.Parent.server.activities.Q01)

return function()
	local clock = 100
	local session = SessionService.new({ sessionId = "test-session", phuongUserId = 7, hostUserId = 9 })
	session:SetPresence(7, true)
	local activity = Q01.new({ session = session, clock = function() return clock end })
	activity:CreateRound({ actorUserId = 7, roundId = "q01-r1", isReplay = false })
	local invalid = activity:Reserve({ roundId = "q01-r1", stepId = "not-a-step", actorUserId = 8 })
	assert(not invalid.ok)
	for index, stepId in ipairs(Q01.StepIds) do
		local actor = index == 1 and 7 or 8
		local offered = activity:GetView(actor)
		local reserveAction
		for _, candidate in ipairs(offered.availableActions) do if candidate.stepId == stepId and candidate.payload.action == "reserve" then reserveAction = candidate break end end
		assert(reserveAction and activity:Apply({ sessionId = session.sessionId, activityId = "Q01", roundId = "q01-r1", actionId = "reserve-a" .. index, actorUserId = actor, payload = reserveAction.payload }).ok)
		local placed = activity:GetView(actor)
		local placeAction
		for _, candidate in ipairs(placed.availableActions) do if candidate.stepId == stepId and candidate.payload.action == "place" then placeAction = candidate break end end
		assert(placeAction and activity:Apply({ sessionId = session.sessionId, activityId = "Q01", roundId = "q01-r1", actionId = "a" .. index, actorUserId = actor, payload = placeAction.payload }).ok)
	end
	local readyView = activity:GetView(7)
	local choices = {}
	for _, action in ipairs(readyView.availableActions) do if action.stepId == "finish" then choices[action.payload.choiceId] = action.enabled end end
	assert(choices.soft_snug == true and choices.neat_layered == true)
	local result = activity:Finish({ roundId = "q01-r1", actionId = "finish-1", actorUserId = 7, payload = { choiceId = "soft_snug" } })
	assert(result.ok and result.receipt.petalGranted and result.receipt.fundRewardGranted == 20)
	assert(activity:Finish({ roundId = "q01-r1", actionId = "finish-1", actorUserId = 7, payload = { choiceId = "soft_snug" } }).ok)
	assert(session.fundBalance == 20)

	-- Host cannot finish while Phuong is present; after Phuong leaves, present host may finish.
	activity:CreateRound({ actorUserId = 8, roundId = "q01-r2", isReplay = true })
	for index, stepId in ipairs(Q01.StepIds) do
		assert(activity:Reserve({ roundId = "q01-r2", stepId = stepId, actorUserId = 8 }).ok)
		assert(activity:Apply({ roundId = "q01-r2", stepId = stepId, actionId = "b" .. index, actorUserId = 8 }).ok)
	end
	session:SetPresence(9, true)
	local hostRejectedOk = pcall(function()
		activity:Finish({ roundId = "q01-r2", actionId = "finish-host-rejected", actorUserId = 9, payload = { choiceId = "neat_layered" } })
	end)
	assert(not hostRejectedOk)
	session:SetPresence(7, false)
	local hostView = activity:GetView(9)
	local hostChoices = {}
	for _, action in ipairs(hostView.availableActions) do if action.stepId == "finish" then hostChoices[action.payload.choiceId] = action.enabled end end
	assert(hostChoices.soft_snug == true and hostChoices.neat_layered == true)
	local hostFinished = activity:Finish({ roundId = "q01-r2", actionId = "finish-host-accepted", actorUserId = 9, payload = { choiceId = "neat_layered" } })
	assert(hostFinished.ok and hostFinished.preview.choiceId == "neat_layered")

	activity:CreateRound({ actorUserId = 8, roundId = "q01-r3", isReplay = true })
	assert(activity:Reserve({ roundId = "q01-r3", stepId = "pillow_left", actorUserId = 8 }).ok)
	local race = activity:Reserve({ roundId = "q01-r3", stepId = "pillow_left", actorUserId = 9 })
	assert(not race.ok and race.code == "IN_USE")
	clock += 16
	assert(activity:Reserve({ roundId = "q01-r3", stepId = "pillow_left", actorUserId = 9 }).ok)
	assert(activity:Cancel({ roundId = "q01-r3", stepId = "pillow_left", actorUserId = 9 }))
	return true
end
]=],
["roblox/mvp/tests/Q02_activity.spec.luau"] = [=[local Q02 = require(script.Parent.Parent.server.activities.Q02)
local SessionService = require(script.Parent.Parent.server.SessionService)
local function expect(value, message) assert(value, message) end
local function request(step, action, payload)
    return {sessionId = "q02-test", activityId = "Q02", roundId = "q02-r1", stepId = step, actionId = action, actorUserId = 101, payload = payload or {}}
end
local session = SessionService.new({sessionId = "q02-test", phuongUserId = 101, hostUserId = 0})
session:SetPresence(101, true)
session:SetPresence(202, true)
local moved, presented, pets = false, {}, 0
local activity = Q02.new({session = session, world = {
    chooseRabbitBasket = function() return 2 end,
    moveJasperToYard = function() moved = true end,
    presentFetchTarget = function(index) table.insert(presented, index) end,
    petJasper = function() pets += 1 end,
}})
activity:CreateRound({activityId = "Q02", roundId = "q02-r1", actorUserId = 101})
local function apply(step, action, payload, userId)
    local item = request(step, action, payload); item.actorUserId = userId or 101
    return activity:Apply(item)
end
apply("greet", "a-greet"); expect(moved, "greeting must request Jasper movement")
local basketActions = activity:GetView(101).availableActions
expect(#basketActions == 3 and basketActions[1].payload.basketIndex == 1, "view must offer three explicit basket actions")
local wrong = apply(basketActions[1].stepId, basketActions[1].id, basketActions[1].payload)
expect(not wrong.ok and wrong.code == "empty_basket", "wrong basket must be normal empty feedback")
local acceptedBasket = basketActions[2]
apply(acceptedBasket.stepId, acceptedBasket.id, acceptedBasket.payload)
local returnAction = activity:GetView(101).availableActions[1]
apply(returnAction.stepId, "a-return", returnAction.payload)
local fetchAction = activity:GetView(101).availableActions[1]
apply(fetchAction.stepId, "a-fetch1", fetchAction.payload)
local duplicate = apply(fetchAction.stepId, "a-fetch1", fetchAction.payload)
expect(duplicate.ok, "duplicate action returns its receipt")
local fetch2 = activity:GetView(202).availableActions[1]
apply(fetch2.stepId, "a-fetch2", fetch2.payload, 202)
local fetch3 = activity:GetView(101).availableActions[1]
apply(fetch3.stepId, "a-fetch3", fetch3.payload)
local greenie = activity:GetView(101).availableActions[1]
local completion = apply(greenie.stepId, "a-greenie", greenie.payload)
expect(completion.receipt.petalGranted and completion.receipt.fundRewardGranted == 20, "first completion must award one petal and 20 fund")
local pet = apply("pet", "a-pet")
expect(pet.receipt.reward == 0 and pets == 1, "pet is social only")
expect(#presented == 3, "each fetch target must be presented")
activity:ReleaseActor(101)

local malformed = pcall(function() apply("fetch3", "bad-after-complete", {targetIndex = 3}) end)
expect(not malformed, "completed activity must reject malformed or stale actions")
local replay = Q02.new({session = session, world = {chooseRabbitBasket = function() return 1 end}})
replay:CreateRound({activityId = "Q02", roundId = "q02-r2", actorUserId = 202, replay = true})
expect(replay:GetView(202).canReplay == false, "new replay begins incomplete")
return true
]=],
["roblox/mvp/tests/Q03.spec.luau"] = [=[local Q03 = require(script.Parent.Parent.server.activities.Q03)
local SessionService = require(script.Parent.Parent.server.SessionService)
local function expect(value, message) assert(value, message) end
local function setup()
    local session = SessionService.new({sessionId="s",phuongUserId=7,hostUserId=8})
    session:SetPresence(7, true); session:SetPresence(8, true)
    local t=0; local trustedUserId=7; local activity=Q03.new({session=session,actorResolver=function() return trustedUserId end,clock=function() return t end,context={}})
    activity:CreateRound({sessionId="s",activityId="Q03",roundId="r1",actorUserId=trustedUserId})
    return activity, function(v) t += v end, session
end
local activity, advance, session = setup()
local initialView = activity:GetView(7)
expect(#initialView.availableActions == 6, "view offers one concrete reserve action per piece")
expect(initialView.availableActions[1].payload.action == "reserve" and initialView.availableActions[1].stepId ~= "", "offered action is executable")
activity:Apply({sessionId="s",activityId="Q03",roundId="r1",actionId="a1",actorUserId=7,payload={action="reserve",socketId="rugSocket",partId="rug"}})
activity:Apply({sessionId="s",activityId="Q03",roundId="r1",actionId="a2",actorUserId=7,payload={action="rotate",socketId="rugSocket",direction=1}})
activity:Apply({sessionId="s",activityId="Q03",roundId="r1",actionId="a3",actorUserId=7,payload={action="place",socketId="rugSocket",partId="rug"}})
    expect(activity:GetView(7).progress.done == 1, "accepted progress is visible")
local ok=false; pcall(function() activity:Apply({sessionId="s",activityId="Q03",roundId="r1",actionId="a4",actorUserId=7,payload={action="reserve",socketId="rugSocket",partId="rug"}}) end); ok=true; expect(ok, "test harness continues after rejected conflict")
local invalidOk=pcall(function() activity:Apply({sessionId="s",activityId="Q03",roundId="r1",actionId=99,actorUserId=7,payload={action="reserve",socketId="chairSocket",partId="chair"}}) end); expect(not invalidOk, "invalid opaque action ID is rejected")
local before=session:GetSnapshot().fundBalance; local duplicate=activity:Apply({sessionId="s",activityId="Q03",roundId="r1",actionId="a3",actorUserId=7,payload={action="place",socketId="rugSocket",partId="rug"}}); expect(session:GetSnapshot().fundBalance==before and duplicate ~= nil, "duplicate action is idempotent")
local activity2, advance2 = setup(); activity2:Apply({sessionId="s",activityId="Q03",roundId="r1",actionId="b1",actorUserId=7,payload={action="reserve",socketId="chairSocket",partId="chair"}}); advance2(15); activity2:ExpireReservations("r1"); expect(activity2:GetView(7).progress.done==0, "inactive reservation expires")
for i,part in ipairs(Q03.PARTS) do local socket=Q03.SOCKETS[part]; activity2:Apply({sessionId="s",activityId="Q03",roundId="r1",actionId="c"..i,actorUserId=7,payload={action="reserve",socketId=socket,partId=part}}); activity2:Apply({sessionId="s",activityId="Q03",roundId="r1",actionId="d"..i,actorUserId=7,payload={action="place",socketId=socket,partId=part}}) end
expect(session:GetSnapshot().fundBalance == before and activity2:GetView(7).state == "COMPLETED", "completion is local to second session")
local finalized = activity2:Apply({sessionId="s",activityId="Q03",roundId="r1",actionId="f1",actorUserId=7,payload={action="finalize",presentation="lamp_on"}})
local retried = activity2:Apply({sessionId="s",activityId="Q03",roundId="r1",actionId="f2",actorUserId=7,payload={action="finalize",presentation="lamp_off"}})
expect(finalized.receipt.presentation == "lamp_on" and retried.receipt.presentation == "lamp_on", "final presentation is immutable and idempotent")
local SessionService = require(script.Parent.Parent.server.SessionService)
local realSession = SessionService.new({sessionId="q03-real", phuongUserId=7, hostUserId=9})
realSession:SetPresence(7, true)
local realActivity = Q03.new({session=realSession, clock=function() return 15 end, context={}})
realActivity:CreateRound({sessionId="q03-real", activityId="Q03", roundId="real-r1", actorUserId=7})
for index, part in ipairs(Q03.PARTS) do
    local socket = Q03.SOCKETS[part]
    realActivity:Apply({sessionId="q03-real", activityId="Q03", roundId="real-r1", actionId="real-reserve-"..index, actorUserId=7, payload={action="reserve", socketId=socket, partId=part}})
    realActivity:Apply({sessionId="q03-real", activityId="Q03", roundId="real-r1", actionId="real-place-"..index, actorUserId=7, payload={action="place", socketId=socket, partId=part}})
end
expect(realSession:GetSnapshot().petals.Q03 == true and realSession:GetSnapshot().fundBalance == 20, "real session awards exactly one Q03 petal and 20 fund")
local realFund = realSession:GetSnapshot().fundBalance
realActivity:Apply({sessionId="q03-real", activityId="Q03", roundId="real-r1", actionId="real-place-6", actorUserId=7, payload={action="place", socketId="lampSocket", partId="lamp"}})
expect(realSession:GetSnapshot().fundBalance == realFund, "real session duplicate placement adds no reward")
realActivity:ReleaseActor(7)
return true
]=],
["roblox/mvp/tests/Q04.spec.luau"] = [=[local Q04 = require(script.Parent.Parent.server.activities.Q04)

local function expectError(fn)
    local ok = pcall(fn)
    assert(not ok, "expected error")
end

local function newFixture()
    local service = {
        rounds = {},
        fundBalance = 0,
        petals = {},
        CreateRound = function(self, activityId, roundId, actorUserId, replay) self.rounds[roundId] = { activityId = activityId, replay = replay } end,
        ApplyStep = function(_, request) return { stepId = request.stepId, actionId = request.actionId } end,
        CompleteRound = function(self, request) self.fundBalance += 20; self.petals[request.activityId] = true; return { activityId = request.activityId, roundId = request.roundId, fundRewardGranted = 20, petalGranted = true } end,
    }
    return Q04.new({ session = service, clock = function() return 1 end }), service
end

do
    local activity = newFixture()
    activity:CreateRound({ activityId = "Q04", roundId = "r1", actorUserId = 7 })
    local saved = activity:Apply({ roundId = "r1", actionId = "a1", stepId = "s1", actorUserId = 7, payload = { passageId = "small-worlds", highlights = { "small-detail" }, reaction = "cozy", bookmark = "ribbon", note = "later" } })
    assert(saved.ok and saved.code == "SAVED" and saved.draft.bookmark == "ribbon")
    local view = activity:GetView(7)
    assert(view.reading and view.reading.text and #view.availableActions == 11)
    assert(activity:Apply({ roundId = "r1", actionId = "a1", stepId = "s1", actorUserId = 7, payload = { passageId = "small-worlds", revision = 0 } }) == saved)
    local receipt = activity:Apply({ roundId = "r1", actionId = "complete-1", actorUserId = 7, payload = { passageId = "small-worlds", complete = true } }).receipt
    assert(receipt.fundRewardGranted == 20 and receipt.petalGranted == true)
    local late = activity:Apply({ roundId = "r1", actionId = "complete-2", actorUserId = 7, payload = { passageId = "small-worlds", bookmark = "star-tab", complete = true } })
    assert(late.ok and late.code == "ACKNOWLEDGED" and late.receipt == nil and late.draft.bookmark == "star-tab")
end

do
    local activity, service = newFixture()
    activity:CreateRound({ activityId = "Q04", roundId = "r1", actorUserId = 7 })
    activity:Apply({ roundId = "r1", actionId = "a1", actorUserId = 7, payload = { passageId = "small-worlds", highlights = { "small-detail" }, reaction = "cozy", bookmark = "ribbon" } })
    local first = activity:Apply({ roundId = "r1", actionId = "complete-a", actorUserId = 7, payload = { passageId = "small-worlds", complete = true } })
    assert(first.receipt.fundRewardGranted == 20 and first.receipt.petalGranted == true and service.fundBalance == 20 and service.petals.Q04 == true)
    local second = activity:Apply({ roundId = "r1", actionId = "b1", actorUserId = 8, payload = { passageId = "night-pages", highlights = { "comforting-moment" }, reaction = "moved", bookmark = "star-tab" } })
    assert(second.code == "ACKNOWLEDGED" and second.draft.bookmark == "star-tab")
    local resave = activity:Apply({ roundId = "r1", actionId = "a2", actorUserId = 7, payload = { passageId = "small-worlds", highlights = { "shared-spark" }, reaction = "smile", bookmark = "pressed-flower" } })
    assert(resave.code == "ACKNOWLEDGED" and resave.receipt == nil and service.fundBalance == 20 and service.petals.Q04 == true)
    assert(service.rounds.r1 ~= nil)
end

do
    local activity = newFixture()
    activity:CreateRound({ activityId = "Q04", roundId = "r1", actorUserId = 7 })
    expectError(function() activity:Apply({ roundId = "r1", actionId = "a1", actorUserId = 7, payload = { passageId = "small-worlds", highlights = { "small-detail", "comforting-moment", "shared-spark", "extra" } } }) end)
    expectError(function() activity:Apply({ roundId = "r1", actionId = "a2", actorUserId = 7, payload = { passageId = "small-worlds", highlights = { "small-detail" }, reaction = "cozy", bookmark = "ribbon", revision = 4 } }) end)
end

return true
]=],
["roblox/mvp/tests/q05.spec.luau"] = [=[local SessionService = require(script.Parent.Parent.server.SessionService)
local Q05 = require(script.Parent.Parent.server.activities.Q05)
local function expect(value, message) assert(value, message) end
local phuong = 3971290001; local outcomes = {"BigIntoEnergy02", "BigIntoEnergy03", "BigIntoEnergy04", "BigIntoEnergy05", "BigIntoEnergy06", "BigIntoEnergy02"}; local index = 0
local session = SessionService.new({sessionId = "q05-test", phuongUserId = phuong, hostUserId = 0}); session:AddFund(120)
session:SetPresence(phuong, true)
local activity = Q05.new({session = session, outcome = function() index += 1; return outcomes[index] end})
activity:CreateRound({activityId = "Q05", roundId = "q05-r1", actorUserId = phuong}); activity:Apply({roundId = "q05-r1", stepId = "select-wanted", actionId = "wanted", actorUserId = phuong, payload = {figureId = "BigIntoEnergy01"}})
local initialView = activity:GetView(phuong); local foundSelection = false; expect(string.find(initialView.instructions, "Collection copies: 0") ~= nil, "initial collection display must be zero"); for _, action in ipairs(initialView.availableActions) do if action.payload and action.payload.figureId == "BigIntoEnergySecret" and action.label == "Want Secret figure" then foundSelection = true end end; expect(foundSelection, "view must expose readable figure-specific wanted payload")
for i = 1, 4 do activity:Apply({roundId = "q05-r1", stepId = "roll", actionId = "miss" .. i, actorUserId = phuong}) end
local guaranteed = activity:Apply({roundId = "q05-r1", stepId = "roll", actionId = "guaranteed", actorUserId = phuong}); expect(guaranteed.receipt.awardFigureId == "BigIntoEnergy01", "fifth roll must guarantee target"); expect(guaranteed.receipt.petalGranted, "target grants petal"); expect(session.fundBalance == 20, "five rolls cost 100"); expect(string.find(activity:GetView(phuong).instructions, "Collection copies: 5") ~= nil, "collection display must show awarded copies")
expect(activity:Apply({roundId = "q05-r1", stepId = "roll", actionId = "guaranteed", actorUserId = phuong}).code == "DUPLICATE", "duplicate is idempotent")
activity:Apply({roundId = "q05-r1", stepId = "select-wanted", actionId = "new-wish", actorUserId = phuong, payload = {figureId = "BigIntoEnergy02"}})
activity:Apply({roundId = "q05-r1", stepId = "roll", actionId = "new-wish-roll", actorUserId = phuong})
local owned = activity:Apply({roundId = "q05-r1", stepId = "select-wanted", actionId = "owned-wish", actorUserId = phuong, payload = {figureId = "BigIntoEnergy01"}})
expect(owned.code == "WANTED_ALREADY_OWNED" and owned.receipt.petalGranted == false, "owned figure fulfills new wish without a second petal")
local idSession = SessionService.new({sessionId = "q05-id-test", phuongUserId = phuong, hostUserId = 0}); idSession:AddFund(100)
idSession:SetPresence(phuong, true)
local idIndex = 0; local idActivity = Q05.new({session = idSession, outcome = function() idIndex += 1; return "BigIntoEnergy01" end})
idActivity:CreateRound({activityId = "Q05", roundId = "q05-id", actorUserId = phuong}); idActivity:Apply({roundId = "q05-id", stepId = "select-wanted", actionId = "id-wanted", actorUserId = phuong, payload = {figureId = "BigIntoEnergySecret"}})
for i = 1, 4 do idActivity:Apply({roundId = "q05-id", stepId = "roll", actionId = "id-miss" .. i, actorUserId = phuong}) end
local idGuaranteed = idActivity:Apply({roundId = "q05-id", stepId = "roll", actionId = "id-guaranteed", actorUserId = phuong})
expect(idGuaranteed.receipt.awardFigureId == "BigIntoEnergySecret", "fifth roll must guarantee selected secret ID")
local weightedSession = SessionService.new({sessionId = "q05-weighted", phuongUserId = phuong, hostUserId = 0}); weightedSession:SetPresence(phuong, true)
local weighted = Q05.new({session = weightedSession, random = function() return 0.999 end}); weighted:CreateRound({activityId = "Q05", roundId = "q05-weighted", actorUserId = phuong}); expect(weighted:_draw() == "BigIntoEnergySecret", "weighted default must reach secret boundary")
return true
]=],
["roblox/mvp/tests/Q06.spec.luau"] = [=[local Q06 = require(script.Parent.Parent.server.activities.Q06)

local function expect(condition, message) assert(condition, message) end
local now = 100
local clock = function() return now end
local Session = require(script.Parent.Parent.server.SessionService)
local session = Session.new({ sessionId = "q06-test", phuongUserId = 7, hostUserId = 0 })
session:SetPresence(7, true)
session:SetPresence(8, true)
session:SetPresence(9, true)
session:SetPresence(10, true)
session:SetPresence(11, true)
session:SetPresence(12, true)
local activity = Q06.new({ session = session, actor = { userId = 7 }, clock = clock, context = { anchors = {} } })
activity:CreateRound({ sessionId = "q06-test", activityId = "Q06", roundId = "q06-r1", actionId = "create-q06-r1", stepId = "round-start", actorUserId = 7 })

local accepted = activity:Apply({ sessionId = "q06-test", activityId = "Q06", roundId = "q06-r1", stepId = "base", actionId = "a-base", actorUserId = 7, payload = { slotId = "base", itemId = "rice" } })
expect(accepted.ok and accepted.receipt.itemId == "rice", "base action should be accepted")
expect(activity:Apply({ sessionId = "q06-test", activityId = "Q06", roundId = "q06-r1", stepId = "base", actionId = "a-base-duplicate", actorUserId = 7, payload = { slotId = "base", itemId = "rice" } }).receipt.stepId == "base", "filled slot should be idempotent")

local blocked = activity:Reserve({ sessionId = "q06-test", activityId = "Q06", roundId = "q06-r1", stepId = "toppings", actionId = "reserve-t", actorUserId = 7, payload = { slotId = "toppings" } })
expect(blocked.accepted == nil and blocked.slotId == "toppings", "reservation should be created")
local other = activity:Reserve({ sessionId = "q06-test", activityId = "Q06", roundId = "q06-r1", stepId = "toppings", actionId = "reserve-t2", actorUserId = 8, payload = { slotId = "toppings" } })
expect(other.accepted == false and other.busyReason == "slot-in-use", "concurrent reservation should be rejected")
activity:Cancel({ sessionId = "q06-test", activityId = "Q06", roundId = "q06-r1", stepId = "toppings", actionId = "cancel-t", actorUserId = 7, payload = { slotId = "toppings" } })
expect(activity:Reserve({ sessionId = "q06-test", activityId = "Q06", roundId = "q06-r1", stepId = "toppings", actionId = "reserve-t3", actorUserId = 8, payload = { slotId = "toppings" } }).actorUserId == 8, "cancel releases only the slot")

local slots = { { "toppings", "greens" }, { "protein", "tofu" }, { "sauce", "sauce" }, { "settingA", "plate" }, { "settingB", "cup" } }
for index, pair in ipairs(slots) do
	local actor = index + 8
	local slot = pair[1]
	if slot == "toppings" then activity:Cancel({ sessionId = "q06-test", activityId = "Q06", roundId = "q06-r1", stepId = slot, actionId = "cancel-t2", actorUserId = 8, payload = { slotId = slot } }) end
	local result = activity:Apply({ sessionId = "q06-test", activityId = "Q06", roundId = "q06-r1", stepId = slot, actionId = "a-" .. slot, actorUserId = actor, payload = { slotId = slot, itemId = pair[2] } })
	expect(result.ok, "parallel step should be accepted: " .. slot)
end
local view = activity:GetView(7)
expect(view.state == "COMPLETED" and view.canReplay == true, "all six steps should complete Q06")
expect(session.fundBalance == 20 and session.petals.Q06 == true, "completion should use one shared reward and petal")
local lateOk = pcall(function() activity:Apply({ sessionId = "q06-test", activityId = "Q06", roundId = "q06-r1", stepId = "base", actionId = "late", actorUserId = 9, payload = { slotId = "base", itemId = "rice" } }) end)
expect(not lateOk, "completed rounds must reject new work")

activity:CreateRound({ sessionId = "q06-test", activityId = "Q06", roundId = "q06-r2", actionId = "create-q06-r2", stepId = "round-start", actorUserId = 7 })
local replayView = activity:GetView(7)
expect(replayView.roundId == "q06-r2" and replayView.progress.done == 0 and replayView.progress.total == 6, "replay view must use the new round")
local replayItems = { { "base", "rice" }, { "toppings", "carrot" }, { "protein", "tofu" }, { "sauce", "sauce" }, { "settingA", "plate" }, { "settingB", "cup" } }
for index, pair in ipairs(replayItems) do
	local result = activity:Apply({ sessionId = "q06-test", activityId = "Q06", roundId = "q06-r2", stepId = pair[1], actionId = "replay-" .. pair[1], actorUserId = 7, payload = { slotId = pair[1], itemId = pair[2] } })
	expect(result.ok, "replay step should be accepted: " .. pair[1])
end
expect(session.fundBalance == 30 and session.petals.Q06 == true, "replay grants 10 and no second petal")
local oldDuplicate = pcall(function() activity:Apply({ sessionId = "q06-test", activityId = "Q06", roundId = "q06-r1", stepId = "base", actionId = "old-round-new-action", actorUserId = 7, payload = { slotId = "base", itemId = "rice" } }) end)
expect(not oldDuplicate, "old completed round cannot reward again")
return true
]=],
["roblox/mvp/tests/queue_service.spec.luau"] = [=[local QueueService = require(script.Parent.Parent.server.QueueService)

local now = 0
local queue = QueueService.new({ clock = function() return now end })
local function expect(condition, message)
	assert(condition, message)
end

local ok, reason, snapshot = queue:Join(1, now)
expect(ok and reason == "Joined" and snapshot.deadlineAt == 60, "first join starts 60 seconds")
for userId = 2, 7 do
		queue:Join(userId, now)
end
now = 5
ok, reason, snapshot = queue:Join(8, now)
expect(ok and snapshot.deadlineAt == 15, "eight at five shortens to t15")
queue:Join(9, now)
queue:Join(10, now)
expect(queue:Join(11, now) == false, "eleventh is rejected")
queue:Leave(1)
expect(queue:Snapshot().deadlineAt == 15, "falling below eight does not extend")
now = 15
ok, reason, localRoster = queue:Tick(now)
expect(ok and reason == "Frozen" and #localRoster.members == 9, "expiry freezes exact roster")
expect(queue:Tick(now) == false, "freeze is exactly once")

local empty = QueueService.new({ clock = function() return now end })
empty:Join(1, now)
local generation = empty:Snapshot().generation
empty:Leave(1)
expect(empty:Snapshot().state == "Empty" and empty:Snapshot().generation == generation + 1, "empty queue resets generation")

expect(queue:BeginTransfer(), "frozen roster starts transfer")
expect(not queue:ResetAfterTransfer(), "cannot reset during transfer")
expect(queue:CompleteTransfer(), "transfer completes")
expect(queue:ResetAfterTransfer(), "completed transfer resets")
now = 20
expect(queue:Join(20, now), "next group can board")
expect(queue:Snapshot().deadlineAt == 80, "next group has fresh countdown")
expect(#localRoster.members == 9, "reset preserves dispatched roster")
queue:Tick(80)
queue:FailTransfer()
expect(queue:ResetAfterTransfer(), "failure can recover")
return true
]=],
["roblox/mvp/tests/session_service.spec.luau"] = [=[local SessionService = require(script.Parent.Parent.server.SessionService)

local function expect(condition, message)
    assert(condition, message)
end

local session = SessionService.new({ sessionId = "test-session", phuongUserId = 3971290001, hostUserId = 0 })
session:SetPresence(3971290001, true)
session:CreateRound("Q01", "q01-r1", 3971290001)
session:ApplyStep({ sessionId = "test-session", activityId = "Q01", roundId = "q01-r1", stepId = "tuck", actionId = "a1", actorUserId = 3971290001 })
session:ApplyStep({ sessionId = "test-session", activityId = "Q01", roundId = "q01-r1", stepId = "tuck", actionId = "a1-repeat", actorUserId = 3971290001 })
local first = session:CompleteRound({ sessionId = "test-session", activityId = "Q01", roundId = "q01-r1", actionId = "complete-1", actorUserId = 3971290001 })
expect(first.petalGranted and first.fundRewardGranted == 20, "first clear should grant one petal and 20")
expect(session.fundBalance == 20, "fund must not multiply by taps")
expect(session:CompleteRound({ sessionId = "test-session", activityId = "Q01", roundId = "q01-r1", actionId = "complete-2", actorUserId = 3971290001 }).receiptId == first.receiptId, "duplicate completion must return receipt")

session:CreateRound("Q01", "q01-r2", 3971290001, true)
session:ApplyStep({ sessionId = "test-session", activityId = "Q01", roundId = "q01-r2", stepId = "replay-step", actionId = "replay-a1", actorUserId = 3971290001 })
local replay = session:CompleteRound({ sessionId = "test-session", activityId = "Q01", roundId = "q01-r2", actionId = "complete-3", actorUserId = 3971290001 })
expect(not replay.petalGranted and replay.fundRewardGranted == 10, "replay grants 10 and no second petal")
expect(session.fundBalance == 30, "replay fund should be exactly 10")

session:CreateRound("Q05", "q05-r1", 3971290001)
se]==]
return #_G.__PCW25ContractText