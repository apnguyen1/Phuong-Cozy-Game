# PCW-17 amendment — shared birthday queue (implementation wave)

This versioned amendment supersedes the personal-countdown and same-place early-entry portions of PCW-17 for the September 27 MVP wave. The original ticket remains historical source text; it is not edited by this side task.

## Replaced requirements

- Replace one 60-second countdown per player with one server-owned 60-second countdown started by the first explicit join to the `BirthdayLobbyQueue` square.
- Replace the personal early-entry pad with explicit Join/Leave membership on that square and a shared `n/10` status.
- At eight queued players, set the deadline to `min(existingDeadline, serverNow + 10)`; do not extend after later arrivals or after the count falls below eight.
- At ten players, remain queued until the deadline; never launch instantly.
- At expiry, freeze one exact unique roster and transfer it to one reserved gameplay destination. Non-members stay in the lobby.
- Replace same-place outdoor relocation with arrival in the existing bedroom through `GameplayBedroomArrival` slots.

## Acceptance additions

The implementation must pass the Task 08 scenarios: eight at t5 departs at t15; eight with six seconds left keeps six; capacity rejects eleven; empty reset increments generation; leave/drop below eight never extends; freeze is exactly once; retries reuse the same roster/destination reservation; Studio/local adapters never claim real teleport; and reconnect does not restart the lobby timer or duplicate session progress.

## Evidence boundary

Pure queue tests may run locally with an injected clock and fake teleporter. Real reserved-server behavior requires published test places and Roblox application clients because TeleportService is not supported in Studio playtesting. A passing local test is not teleport or group-play approval.

## Dependencies

Task 01 owns scene installation and actual anchors. Task 09 owns the common session/action/idempotency contract. PCW-16 must later cover 8–10 real participants, mixed input, late join, disconnect/reconnect, transfer failure, and ten distinct bedroom arrival slots.
