# MVP actual Luau test window

This is a bounded execution plan for Task 13. It is not Studio/gameplay evidence until the installed MVP module tree executes in the verified local place. Task 13 must not install or mutate production source/scene content.

## Lease prerequisite

Run only after the coordinator explicitly transfers the exclusive Studio test lease from the integrator. The integrator must identify the exact place revision and confirm that `roblox/mvp/CONTRACT.md`, `INTEGRATION.md`, shared modules, server modules, and test modules are the installed revision. Do not start/stop play or inject scripts before that transfer.

## Execution order

Run the nine current pure/service/activity specs first, then the separate engine/fake-Teleport boundary:

1. `roblox/mvp/tests/session_service.spec.luau`
2. `roblox/mvp/tests/queue_service.spec.luau`
3. `roblox/mvp/tests/cake_service.spec.luau`
4. `roblox/mvp/tests/Q01_activity.spec.luau`
5. `roblox/mvp/tests/Q02_activity.spec.luau`
6. `roblox/mvp/tests/Q03.spec.luau`
7. `roblox/mvp/tests/Q04.spec.luau`
8. `roblox/mvp/tests/q05.spec.luau`
9. `roblox/mvp/tests/Q06.spec.luau`

Separate boundary: `roblox/mvp/tests/teleport_adapter.spec.luau`.

The nine module specs already have independent CLI adapter evidence: **9/9 passed** on the recorded source revision, with **42/42 files compiling in that recorded CLI run**. That is source/module evidence only, not installed Studio evidence. During the exclusive window, rerun them against the installed ModuleScript tree with no scene mutation. The teleport spec must use a fake injected TeleportService and must not call Roblox production teleport. A real published transfer remains a separate PCW-16 evidence gate.

## Required actual observations

- Session: duplicate completion, replay 20/10 classification, Q05 zero fund reward, purchase debit/award idempotency, presence/host permissions, all-six-petal cake gate.
- Queue: 60-second start, shortening at eight, cap ten, drop below eight without extension, frozen roster, empty-generation reset, failure state, and same-reservation retry behavior.
- Activities: unknown step rejection, duplicate action/step receipts, completion only after required steps, replay behavior, Q04 concurrent drafts, Q05 four misses/fifth selected-ID guarantee, and Q06 route-independent state.
- Cake: absent-player/host permissions, voluntary invite/cut/eat, no full-roster gate, and post-cut free play.
- Teleport boundary: Studio returns explicit unsupported status; fake service proves payload identity and retry behavior without asserting published server reuse.

## First user playtest after engine smoke

Only after installation, module-load smoke, and engine checks pass, ask the user to run this short sequence with the approved test identity. Do not invent a host identity: privileged Phuong actions require actual `Phamlet707` or an explicitly isolated existing Studio test identity named by the coordinator.

1. Join the lobby queue, wait/leave once, and report whether the shared timer, leave result, and roster feedback are understandable.
2. Enter the bedroom with the available participants, rotate each camera independently, and report spacing around beds, Jasper, door, and other avatars.
3. Have one player make one valid shared Q01 contribution and report the prompt, receipt, shared step/progress update, and whether another player can see the authoritative state. A single accepted step must **not** award fund or petal; completion of the first full Q01 round awards 20 fund and one Q01 petal, while duplicate completion adds nothing.

Record device/input type, exact wording or reproduction steps, screenshots, and whether the issue is source/router (Owners 02–09), queue/transfer (Owner 08), anchors/installer/world geometry (Owner 01), activity station/builders (Owners 02–07/10–12), or UX/device performance (PCW-16 integrator).

## Evidence packet

Capture the exact source revision, installed place identifier/revision, test order, output/console log, failures with reproduction steps, and any Studio screenshots needed to establish context. Mark each result `executed-pass`, `executed-fail`, or `not-executed`; never convert a source inspection or Python model result into an executed Luau result.

## Current status

No lease has been transferred to Task 13. No Studio insertion, play session, device/group test, or published transfer has been performed. The recorded CLI adapter run executed the nine module specs with **9/9 passed**; the teleport test remains an engine/fake-service boundary, not a gameplay result. This window remains preparation only until the coordinator grants the exclusive lease after approved local installation.
