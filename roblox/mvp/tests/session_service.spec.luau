local SessionService = require(script.Parent.Parent.server.SessionService)

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
session:ApplyStep({ sessionId = "test-session", activityId = "Q05", roundId = "q05-r1", stepId = "q05-step", actionId = "q05-a1", actorUserId = 3971290001 })
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
