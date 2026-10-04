local QueueService = require(script.Parent.Parent.server.QueueService)

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
