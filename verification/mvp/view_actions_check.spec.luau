local SessionService = require(script.Parent.Parent.server.SessionService)
local Q01 = require(script.Parent.Parent.server.activities.Q01)

-- Verifier-side check: consume one actual Q01 view action, not a hand-written step ID.
local session = SessionService.new({sessionId = "view-action-check", phuongUserId = 7, hostUserId = 0})
local activity = Q01.new({session = session, clock = function() return 100 end})
activity:CreateRound({actorUserId = 7, roundId = "view-r1", isReplay = false})
local view = activity:GetView(7)
local offered
for _, action in ipairs(view.availableActions) do
    if action.enabled and action.stepId ~= "finish" then offered = action; break end
end
assert(offered and offered.payload and offered.payload.stepId == offered.stepId, "Q01 view action must carry its real step payload")
assert(activity:Reserve({roundId = view.roundId, stepId = offered.stepId, actorUserId = 7}).ok, "offered Q01 action must reserve")
local result = activity:Apply({roundId = view.roundId, stepId = offered.stepId, actionId = "view-action-1", actorUserId = 7, payload = offered.payload})
assert(result.ok, "offered Q01 action rejected: " .. tostring(result.code))
assert(result.accepted and result.accepted.receipt and result.accepted.receipt.stepId == offered.stepId, "offered Q01 action must return its accepted step")
return true
