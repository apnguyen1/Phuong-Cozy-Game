local Q04 = require(script.Parent.Parent.server.activities.Q04)

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
