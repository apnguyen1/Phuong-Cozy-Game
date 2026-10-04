# Task 08 implementation handoff

## Files

- `roblox/mvp/server/QueueService.luau` — injected-clock, server-owned shared queue state machine.
- `roblox/mvp/server/TeleportAdapter.luau` — production `ReserveServerAsync` plus `TeleportAsync` adapter; member retries reuse the actual access code and Studio is refused.
- `roblox/mvp/server/LocalPartyTransferAdapter.luau` — explicitly labeled Studio-only callback adapter for local party-flow playtests; never a production fallback.
- `roblox/mvp/builders/LobbyQueue.luau` — queue remotes and shared-state UI projection; no scene installation.
- `roblox/mvp/tests/queue_service.spec.luau` — timing, capacity, freeze, reset tests.
- `roblox/mvp/tests/teleport_adapter.spec.luau` — production adapter and Studio guard tests.

## Contract exports

QueueService exports `Join`, `Leave`, `Tick`, `Freeze`, `BeginTransfer`, `CompleteTransfer`, `FailTransfer`, and `Snapshot`. It owns one generation and never extends a shortened deadline. LobbyQueue’s remotes are `BirthdayQueue/Request` and `BirthdayQueue/State`; Task 01 must wire them to the placed queue square and UI.

TeleportAdapter requires a configured `GameplayPlaceId`; production first calls server-only `ReserveServerAsync`, stores the returned access code/private-server identity on the frozen roster, then uses `TeleportOptions.ReservedServerAccessCode` for the whole party and every member retry. It includes `rosterId`, `destinationReservationId`, and member IDs as teleport data. It returns `StudioTeleportUnsupported` in Studio. The destination must use server-side join data and a create-or-get session keyed by the roster contract from Task 09.

## Tests/results

The tests are pure Luau specifications and were not run in this environment because no Luau/Roblox runtime is installed or started. They inject reservation and teleport functions, prove one reservation plus same-code member retry, and prove Studio refusal. Real reserved-server teleport, `TeleportInitFailed` event wiring, destination arrival, and reconnect remain unverified and require published test places. Roblox documentation states that TeleportService does not support Studio playtesting.

## Installation and dependencies

Task 01 exclusively installs these modules into Studio and owns scene/anchor changes. The integrator must bind the actual `BirthdayLobbyQueue` anchor, destination configuration, RemoteEvent handlers, player cleanup, and ten bedroom arrival slots. Do not replace the production adapter with same-place movement.

## Unresolved gates

`GameplayPlaceId`, universe/access configuration, transfer retry window, live destination session implementation, arrival-slot coordinates, and Task 09’s final session contract are unresolved. No publish/upload or live permission claim is made. Independent verification and PCW-16 mixed-device/published-server rehearsal are still required.
