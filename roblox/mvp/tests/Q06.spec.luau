local Q06 = require(script.Parent.Parent.server.activities.Q06)

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
