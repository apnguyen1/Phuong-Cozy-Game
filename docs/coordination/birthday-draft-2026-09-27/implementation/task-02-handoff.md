# Task 02 handoff — Q01 Everything Tucked In

## Files and exports

- `roblox/mvp/server/activities/Q01.luau`: `Q01.New(ctx)` / `Q01.new(ctx)`, `CreateRound(request)`, `Reserve`, `Cancel`, `ExpireReservations`, `Apply`, `Finish`, and canonical `GetView`. Uses the shared `SessionService` instance supplied in `ctx.session`.
- `roblox/mvp/builders/Q01Station.luau`: canonical builder function `(context)` using `SafeReplace("Q01", factory)` and returning `{folder, manifest}`. The detached factory creates a native bed arrangement, sage bedding, two pillows, round-bellied dog, dinosaur plush, and seven tagged interaction sockets under the integrator-owned replacement folder.
- `roblox/mvp/client/activities/Q01.luau`: common-renderer descriptor with seven actions, touch/desktop controls, finish choices, and forgiving messages.
- `roblox/mvp/tests/Q01_activity.spec.luau`: injected-clock pure activity test for seven-step completion, duplicate completion, reservation race, expiry, and cancellation.
- `docs/tickets/PCW-07.md`: current MVP authority amendment; historical acceptance remains evidence-gated.

## Installation

Task 01/integrator must invoke the station builder in Studio Edit mode using the shared `INTEGRATION.md` context and resolved live `Q01Bed` anchor. No Studio installation, camera, lighting, or shared scene mutation was performed by this task.

## Actual checks

Source inspection completed against the current `CONTRACT.md`, `INTEGRATION.md`, `SessionService`, PCW-07, and Q01 draft. The Q01 adapter passes the full canonical `sessionId`/`activityId`/`roundId`/`actionId`/`stepId`/numeric authenticated `actorUserId` envelope to shared step and completion calls. The module and spec now use frozen `ctx.clock` for reservation expiry; the spec advances that injected clock to verify a held slot releases. The spec includes genuine invalid-step, reservation race, expiry, cancellation, seven-step completion, duplicate completion, and shared-reward assertions. `luau-compile.exe` from `verification/mvp/tools/luau-0.740` compiled both owned Q01 source/spec files successfully with exit code 0. Studio, device, group, import, collision, palette-capture, and human-fun evidence remain unclaimed.

The station builder now uses the frozen detached-factory `SafeReplace("Q01Station", factory)` contract, requires a non-missing/non-unresolved `PlacementStatus` on the resolved Q01Bed anchor before factory mutation, builds detached from the measured anchor CFrame with no unused parent parameter, tags every authored BasePart with `VerificationTicket`, `PaletteToken`, and `MVPBuilder`, and returns `{folder, manifest}`. Builder compilation returned exit code 0. Exact Q01Station SHA-256: `D172A10A3D526B85433DE5FA17BCBB05D9E927CF63BB305CAF61F8F14E96AAE6`.

Q01 `GetView(actorUserId)` now supplies both explicit `finish:soft_snug` and `finish:neat_layered` actions when all seven preparation steps are accepted. They are enabled only for the authenticated Phuong ID; `Finish` retains the server-side permission check. The focused spec asserts both choices are present and enabled for Phuong. Q01 and spec compilation both returned exit code 0. Q01 SHA-256: `DEDBBF068DDDC3FCF7CCBBBB4CEF7E8E4ACF81B18781862C63E271299EF6E3BC`; spec SHA-256: `0A638B89DB99FF5C9D5CA65B8D32C7875965E9BAFE7582D21C47011CC22028F4`.
Q01 finish requests now consume canonical `request.payload.choiceId` (with top-level compatibility retained), and authorization uses `SessionService:IsPresent` plus `SessionService:CanSpend`: present Phuong is allowed; a present host is rejected while Phuong is present and allowed only after Phuong is absent. The spec prepares separate rounds and exercises both emitted choices through `Finish`, host rejection, host fallback acceptance, invalid step, concurrency, expiry, replay, and shared reward. Q01 and spec compilation both returned exit code 0. Q01 SHA-256: `F87EB97318419D833C2E2AE4DC38248DFEBBB5656D7E3EA19881602ABC98319C`; spec SHA-256: `CCF7C28B017512AD85F6E4F1781A7FB26CF37C577A6FB516A7760DFD287038A4`.
The runtime action path is now complete: `GetView(actorUserId)` emits reserve/place/cancel/finish actions; `Apply` dispatches payload actions, normalizes `payload.stepId`, returns an actor-specific view, and preserves reservation ownership. Legacy manual `Reserve` followed by an offered reserve action is safely treated as place. The actual generated adapter run passed all 10 module specs, including Q01 and `view_actions_check` (`passed=10 failed=0`). Q01/spec compile exit codes were both 0. Q01 SHA-256: `3773F06B01026DA2851BFF02C2D9142C406CFD44A51D339E4BEE3A028D78F36A`; spec SHA-256: `B2BF05A078A9451B5674143617EBDD131EB071AD98D9EF9D8CB71F65EC2004BD`.

## Dependencies and unresolved gates

- Owner 09 must retain the canonical `SessionService` behavior and receipt semantics; Q01 does not duplicate them.
- The integrator must provide the actual `Q01Bed` anchor and verify socket clearances against ten-player bedroom arrival.
- The common client renderer must consume the canonical `availableActions`/`state`/`progress` view fields.
- Independent verification must test actual Studio behavior, touch/desktop parity, two-player races, disconnect/rejoin, late join, replay preview, and exactly-once petal/fund receipts.
