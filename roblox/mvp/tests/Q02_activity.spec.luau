local Q02 = require(script.Parent.Parent.server.activities.Q02)
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
