local TeleportAdapter = require(script.Parent.Parent.server.TeleportAdapter)

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
