local SessionService = require(script.Parent.Parent.server.SessionService)
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
