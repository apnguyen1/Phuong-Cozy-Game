# Task 07 Q06 implementation handoff

Status: implementation delivered; independent verification and Studio/device/group evidence remain open.

## Owned files

- `roblox/mvp/server/activities/Q06.luau` — server-owned Q06 round adapter. Validates six accepted food/setting slots, per-slot reservations, 15-second inactivity expiry, duplicate/final-step behavior, visible food state, and SessionService completion.
- `roblox/mvp/builders/Q06Station.luau` — station builder for measured FOB, Aladdins, and serving anchors. Returns the frozen builder result shape `{Root, MVP, Anchors, Palette, ReplaceFolder, SafeReplace}`.
- `roblox/mvp/client/activities/Q06.luau` — UI-safe proposed menu/role/input descriptor.
- `roblox/mvp/tests/Q06.spec.luau` — pure injected-clock tests for accepted steps, reservation contention/release, completion, shared reward, and no post-completion work.
- `docs/tickets/PCW-12.md` — current MVP amendment while preserving historical criteria.
- `docs/coordination/birthday-draft-2026-09-27/07-q06-food.md` — design source and evidence limits.

## Exports and binding

`Q06.new({session, actor, clock, context})` returns an activity instance with `CreateRound(request)`, `Apply(request)`, `GetView(actorUserId)`, plus activity-local `Reserve` and `Cancel` helpers for the router. `Apply` returns `{ok, code, receipt, view}`. The module never owns petals, currency, teleport, cake, or client authority. Authenticated actor identity must be supplied by the server router, not accepted from client authority.

The builder's returned function requires `context.MVP`, `context.Anchors`, and `context.Palette`; it does not resolve or move anchors. The exact food menu is marked proposed in the model attribute and client descriptor.

## Installation

Task 01/integrator must install the station builder in Edit mode using measured live anchors. Do not run this builder against guessed coordinates or modify the saved Draft 02/03 place. The integrator must ensure the three stations are outside doors and crossing lanes, and must keep the FinalePatio free of Q06 geometry.

## Tests and results

The bundled Luau 0.740 compiler passed all four owned source/spec files: Q06 server activity, station builder, client descriptor, and Q06 spec. The Q06 spec now uses canonical string session/activity/round/action IDs, numeric authenticated actor IDs, trusted `SetPresence` setup, and full `SessionService` request envelopes. It covers accepted base selection, filled-slot idempotence, concurrent reservation rejection, cancellation releasing one slot, six-step completion, one shared 20 first-clear reward, one Q06 petal, and rejection after completion.

The generated exact-source adapter previously embedded stale Q06/test text; Task 13 must regenerate it before the independent rerun. No Studio, mobile, 8–10-player, collision, route, or human-fun result is claimed.

Rerun2 fixture repair: every Q06 CreateRound, Reserve, Cancel, Apply, and negative/replay invocation now includes canonical string `sessionId`, `activityId`, `roundId`, `actionId`, and `stepId` fields, with numeric actor IDs and trusted presence setup. Production request guards remain strict. Q06 source and spec compile successfully with Luau 0.740 after this repair.

UI gap repair: `GetView().availableActions` now emits one valid `{slotId,itemId}` payload per available ingredient/setting choice, with role/slot labels, busy-state reasons, and confirmation-oriented instructions. Existing `Main.client.luau` action buttons can therefore submit valid Q06 payloads instead of the former item-less slot payload. Q06 server SHA256 after this change: `C14F5FE00A2E64AA8C46916BE7E7EA9147FD1AF2C7016DEABC931024762C46AF`.

Replay repair: Q06 now stores `currentRoundId` on every explicit `CreateRound` and `GetView` resolves only that round, never an arbitrary `pairs(self.rounds)` entry. The spec covers new-round progress 0/6, replay completion adding 10 without a second petal, and rejection of old completed-round work. Luau 0.740 compile passed. Current SHA256: Q06 `96B89A12D677459FF8BF4ABE767BA440707EA4ACA212CA43FA4445BAC2776B8E`; Q06 spec `BD7730C76FB513EA75DDAE7E33E7CD7F3DDE1B070C121E1033F02DAA1EAD2D83`.

## Dependencies and unresolved gates

- `roblox/mvp/CONTRACT.md` is canonical; router wiring must create one Q06 instance per session and pass authenticated actors per request.
- `roblox/mvp/INTEGRATION.md` and Task 01 must expose measured Q06 anchors and install the builder result.
- The exact menu remains a user-playtest proposal, not approved real restaurant research.
- Independent verification must inspect source, run meaningful tests, verify palette/scale/collision in Studio, and test touch/desktop, reconnect, late join, ten-player crowding, and route clearance.
- Final reward behavior depends on SessionService and the shared progression integration; Q06 does not self-approve or duplicate it.
