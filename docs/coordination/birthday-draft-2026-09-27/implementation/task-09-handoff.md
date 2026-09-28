# Task 09 implementation handoff

## Files

- `roblox/mvp/CONTRACT.md` — authoritative activity/session/CakeService boundary.
- `roblox/mvp/shared/Config.luau` — MVP rates, Q05 constants, and verified Phuong/host IDs.
- `roblox/mvp/server/SessionService.luau` — session fund, petals, rounds, accepted steps, receipts, replay, atomic purchase boundary.
- `roblox/mvp/server/CakeService.luau` — six-petal gate and invitation/cut/eat state only.
- `roblox/mvp/builders/CakeFinale.luau` — optional edit-mode builder adding exactly two table-end seats while preserving the existing cake, table, and eight seats.
- `roblox/mvp/tests/session_service.spec.luau`, `cake_service.spec.luau` — pure kernel scenarios.
- `roblox/mvp/PHUONG-LOOKUP.md` — official Roblox username lookup evidence.
- `docs/tickets/PCW-13.md`, `PCW-14.md` and `verification/contracts/PCW-13.json`, `PCW-14.json` — amendments.

## Binding behavior

Q05 owns wanted selection, probabilities, inventory, and guarantee logic. It should call `SessionService:CommitPurchase` with its server-selected outcome. CakeService owns only invitation, voluntary finale progression, cutting, and eating. Activity modules must use the exact `CreateRound`, `Apply`, `GetView`, `StartNextRound`, `CanFinish`, and `CanSpend` contract described in `CONTRACT.md`; they must not expose raw kernel mutators to clients.

## Installation

No Studio installation was performed. The designated integrator must place the ModuleScripts under the corresponding `ServerScriptService`/shared locations and bind activity adapters and remotes. No scene, camera, Lighting, or live place was changed.

## Tests and results

Pure Luau test sources cover: one reward despite repeated steps/completions; first-clear 20; replay 10 without another petal; Q05 zero fund earnings; five purchase debits against 100; six-petal finale gate; authorized cut; and guest eating. They were not run because this checkout has no configured Luau/Roblox test runner. Studio playtest, multi-device, reconnect, late join, and 8–10-player evidence remain required.

The kernel now requires canonical session/activity/round identity, uses round-scoped completion receipts before active-state rejection, derives replay status centrally, retains accepted work after disconnect, and gates purchases on trusted presence plus role. Tests cover same-action and new-action completion retries, guest, disconnected authorized player, host while Phuong is present, and host while Phuong is absent.

The regenerated actual-source Luau adapter ran all 9 MVP specs: `passed=9 failed=0`. Relevant SHA-256 hashes: Config `3DD7A7557ED9D7C0A3391FAD03D8E67AC175392C0412B4A395C8DECDDAEA6034`; SessionService `1725E383387CB9FE68964E1838900A587E9FDA19371B41EF24953612702A35BF`; CakeService `5D7D5D7BA39C11F67B67A466DE1853E34E551206A99EB741A51D5B4822428B39`; session spec `FB4B5302FF6552ABCE8541E68FAE98501BC6E523ADF4274E151C7088604CF0B5`; cake spec `49610DD6D7D51B3AF234A71DA2329484FA8550F3EB3D40EEF446ADEA518DA8D2`.

`CakeFinale.luau` compiles with Luau 0.740; revised SHA-256 `C74B21F080C99FB2C7CEA1B1B3985B70C3687732553B0671124327F3FA8303D3`. Both authored Seat and Back BaseParts now carry `MVPBuilder="CakeFinale"` for shared capture.

## Dependencies and unresolved gates

Activity owners must bind their validated completion conditions and Q04 private bookmark mapping using the frozen `Module.new(ctx)`, `CreateRound`, `Apply`, and `GetView` interface and exact UI descriptor in `CONTRACT.md`. Owner01 must bind remote dispatch/UI/bootstrap and measured anchors. Q05 must provide atomic outcome/inventory integration and the approved figure assets/probabilities. The official lookup resolved Phamlet707 to user ID `3971290001` and IamBannedrew to host ID `1078077474`; no guessed live permissions were used. Phuong remains authorized directly for spending/finalization, both verified hosts may use celebration controls when present, and stranger/disconnected actors remain rejected. The new CakeFinale builder requires the existing `FinalePatio` marker, `BirthdayCourtyard.BirthdayCake`, `GatheringTable`, and exactly eight existing Seat instances; it derives two end seats from the live table CFrame/size and fails before SafeReplace on overlap conflicts. RuntimeHooks metadata identifies expected Main/CakeService proximity and native Seat paths but is not binding. Integration still must validate route clearance, native seat behavior, ten-player use, and post-cut free play in Studio.
