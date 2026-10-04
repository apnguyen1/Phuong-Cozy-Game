# Independent review and group rehearsal plan

**Review revision:** MVP verification update, September 27, 2026  
**Scope:** cross-document planning review and later PCW-16 rehearsal design  
**Status:** `CHANGES_REQUIRED` for contract alignment; source-level tests prepared; Studio/device/group gates pending  

## Review boundary and inputs

This document is an independent review plan, not an implementation or approval. The coordination README is the authority for this wave. PCW-16 requires an eventual mixed-device rehearsal after PCW-03–14 are implemented. The historical `mini-game-idea-plan.md` is useful for activity identity, but its personal-wallet and gifting model conflicts with the current shared-fund direction and must not be used as the implementation contract without amendment.

All twelve builder drafts are now present and were read for this checkpoint. They are coherent planning documents, but several contract and wording corrections below are required before implementation contracts are frozen. Their proposed measurements, source observations, and acceptance scenarios remain unverified until the later Studio/device/group gates.

No Studio scene, published session, device run, group playtest, performance capture, or human fun review exists for these new plans. Consequently this document cannot produce `PASS`, `READY_FOR_REVIEW`, or Roblox readiness. The delegated verifier task returned no substantive cross-document findings (it spent its bounded turn waiting on the coordinator rather than producing a review), so the concrete findings below are from this document's direct comparison. The later verifier review must inspect submitted files and evidence; it must not run a production harness over planning prose or convert design consistency into gameplay evidence.

## Requirement traceability checkpoint (initial draft intake)

| Requirement to trace later | Source/authority | Expected draft evidence | Current result / correction request |
|---|---|---|---|
| Lobby remains free waiting; one opt-in square; first entrant starts a shared 60-second queue | Coordination README, PCW-17 | 08 sequence, generation/deadline state, leave/empty reset | **Missing 08.** Owner must specify server-owned deadline and empty-generation reset. |
| At eight queued, remaining time becomes at most 10 seconds; capacity is 10; no instant launch at 10 | README, PCW-17 | 08 timing table and scenarios for 7→8, 8→7, 10→11 | **Missing 08.** Add exact `min(current deadline, now+10s)` behavior and graceful rejection. |
| Only frozen queued roster transfers to one gameplay server; partial failures and late arrivals are safe | README, PCW-17 | 08 transfer/retry/idempotency states | **Missing 08.** Require destination configuration as an implementation prerequisite; no fabricated place ID or live-test claim. |
| Arrival is inside Phuong’s bedroom with Jasper; ten unique safe spots; no pile-up; no forced cinematic | README, PCW-03/04/08 | 01 geometry/anchors and 03 arrival/Jasper handoff | **Missing 01/03.** Require measured local offsets and a ten-avatar occupancy test. |
| Independent third-person cameras on touch, tablet, desktop | AGENTS.md, PCW-02/16 | 02 controls plus every activity’s input notes and rehearsal cases | **Missing 02 and 01–12.** Owners must state camera is local, rotatable, and never shared/locked. |
| Q01 bed activity completes cooperatively and awards one petal once | README, PCW-07 | 02 roles, accepted steps, replay/cancel/rejoin, dedupe receipt | **Missing 02.** Add server ownership, once-only petal and host fallback when Phuong leaves. |
| Q02 starts with Jasper indoors, then supports outdoor fetch; solo fallback exists | README, PCW-08 | 03 navigation/fallback and yard footprint | **Missing 03.** Require indoor greeting, yard route, stall recovery, and no bedroom fetch-lane squeeze. |
| Q03 booth beside UDistrict crossing and bedroom desk share one miniature | README, PCW-09 | 04 shared-round identity, reservations, both station anchors | **Missing 04.** Prove route clearance and no duplicate reward from booth/home simultaneous saves. |
| Q04 uses existing Quad blossom benches; interior Quad paths/trees unchanged | README, PCW-10, PCW-06 | 05 bench positions and preservation checks | **Missing 05/12.** Require before/after geometry comparison and independent bookmark contribution dedupe. |
| Q05 vending machine is outside UDistrict crossing route; five-roll guarantee includes selected ID | README, PCW-11 | 06 fund debit/award order, wanted ID, five-roll scenarios | **Missing 06.** Replace personal wallets/gifts as core behavior with shared fund and Phuong-controlled purchase; retain session-only state. |
| Q06 is near FOB Poke Bar and Aladdins; patio is cake/seating | README, PCW-12 | 07 counter anchors, route/clearance and contribution rules | **Missing 07.** Do not assert real menus; mark proposed adaptations and reserve patio for finale. |
| Six petals, five earning activities plus Q05 wanted-Labubu; no eight/ten-person completion gate | README, PCW-13/14 | 09 progression graph and cake unlock rules | **Missing 09.** Require petal identity, one receipt per quest, absent-player behavior, and no money-only unlock. |
| Shared fund replaces personal wallets; proposed earning amounts are defaults, not user-approved facts | README, PCW-13 | 09 explicit label and adjustable configuration | **Missing 09.** Mark 20/10 rates as coordinator defaults pending confirmation; do not present them as settled user decisions. |
| Cake is voluntary, host/Phuong-controlled, no absent-player gate or forced warp/camera | README, PCW-14 | 09 invite/start/cut/eat/exit/replay states | **Missing 09.** Require walk-in cake flow and forgiving seated eating. |
| Seattle-inspired perimeter conceals unfinished edges while preserving open night sky | README, MAP-02/03 | 10 geometry, sightline and mobile budget checks | **Missing 10.** Require route exits, skyline readability and concealed-boundary review. |
| Cozy nighttime lighting remains readable and palette-safe | README, PCW-01/02 | 11 light ownership, low-setting checks, palette review | **Missing 11.** Separate authored colors from lighting appearance; no exact-color claim from screenshots alone. |
| Grass/decor and outer Quad trees are separate, preserve routes and Quad interior | README, MAP-03, PCW-06 | 12 footprint/budget and before/after route checks | **Missing 12.** Require tree count, collision, route width and protected interior geometry. |
| Eight real friends target, ten capacity; late join/reconnect restore live session; no timer resurrection | PCW-16, README | 08/09 and rehearsal cases | **Missing all drafts.** Add reconnect state ownership, session identity, activity/action IDs, and stale timer rejection. |
| Personal note stays entirely user-authored and unchanged | AGENTS.md, PCW-14/16 | Content diff and rehearsal checklist | **Not testable from missing drafts.** No draft may generate, paraphrase, or invent note text. |

## Cross-document contradiction audit to run when drafts arrive

The reviewer should mark each item `consistent`, `contradictory`, `omitted`, or `unverifiable`, with an owner and smallest correction.

1. Compare every anchor and footprint against task 01. Proposed anchor names are interfaces, not proof that Instances exist. A draft must not reuse old map coordinates as measured facts.
2. Compare every activity reward against task 09. A shared fund, shared petals, server receipts, contributor acknowledgements, and session-only state must replace independent wallets. The coordinator’s 20-first/10-later amounts remain proposed defaults.
3. Check Q05 against the current direction: Phuong’s selected figure and shared-fund spending, Big into Energy outcomes, selected-ID fifth-roll guarantee, award-before-animation, and exactly-once debit/award. Personal gifting and personal wallets from the older plan are not silently retained as core behavior.
4. Check all drafts for one common action identity, activity/round identity, contributor identity, accepted-step receipt, completion receipt, and once-only petal/fund reward. Local names that cannot be mapped to this contract are blockers.
5. Check all cancellation/replay/rejoin descriptions for the same rule: accepted work survives, only unfinished reservations release, completed rewards do not repeat, and a new explicit replay creates a new eligible round.
6. Check all UI drafts for touch and desktop parity, readable controls, movement/camera safe areas, back/cancel paths, and no forced camera or cinematic. A screenshot or concept is not a working UI.
7. Check route and environment drafts for the protected Quad interior, crossing clearance, bedroom circulation, ten-player patio seating, concealed perimeter, open sky, night readability, and the exact eight-color world palette.
8. Check every “tested,” “ready,” or “pass” statement against evidence type. Planning measurements, diagrams, simulated device views, Studio edit captures, actual device play, group play, and human fun review are separate claims.

## Completed cross-document findings

The initial traceability table above was written before the drafts arrived. Its “missing” entries are historical intake notes, superseded by the completed findings and current ledger below; they are retained only to show the review sequence.

| ID / severity | Exact location | Expected | Observed | Smallest fix |
|---|---|---|---|---|
| B1 — blocking contract correction | `09-progression-cake.md`, **Figure set / probability contract** and **Evidence limits and unresolved choices** | The README and Q05 draft treat Big into Energy custom probabilities as an approved baseline: six regular outcomes at 16.5% each, secret ID at 1%, and the fifth unsuccessful-sequence roll guarantees the selected figure, including ID. | Task 09 says the probabilities “need explicit alignment” and lists the final probability reference as unresolved. This incorrectly reopens an already-settled baseline, even though `06-q05-labubu.md` correctly uses it. | Remove probability/reference from Task 09’s unresolved choices; retain only final asset/reference provenance and implementation test evidence as open. Do not change the weights or guarantee. |
| B2 — blocking contract correction | `04-q03-craft.md`, **Player sequence** / **Phuong/host final choice**; `09-progression-cake.md`, **Permissions and collection choices** | One canonical rule must decide who may make a temporary final presentation choice when Phuong is absent, with explicit host availability/consent and a visible audit result. | Q03 repeatedly defers to “the shared progression contract,” while Task 09 defines spending and cake authority but does not explicitly define Q03’s final presentation permission. This can produce divergent implementations. | Add `Q03FinalizePresentation` to Task 09’s permission matrix, or state that Q03 presentation is non-gating and any participant may choose from an allow-list. Record the selected rule in Q03 and its verifier contract. |
| B3 — blocking schema correction | `04-q03-craft.md` **Concurrent reservations and lifecycle**; `05-q04-reading.md` **Interfaces and dependencies / Suggested Q04 contract calls**; `07-q06-food.md` **State and interface dependencies**; `09-progression-cake.md` **Common server contract** | All activities must consume one canonical round state, accepted-step receipt, completion receipt, once-only petal receipt, and once-only fund receipt, with the same cancellation/replay semantics. | The drafts are conceptually compatible but expose local names and APIs (`CompleteRound`, `CompleteRead`, `StartNextRound`, `FundReceipt`) without a normative field mapping or transaction boundary. Q04 additionally has player-local draft completion feeding a shared activity round, unlike the other activities. | Task 09 must publish the canonical field/state mapping and adapter rules: Q04 personal `completionReceipt` becomes an eligible contribution, while the shared Q04 `roundId` owns exactly one fund/petal transaction. Add one example receipt sequence to each dependent contract; remove competing field definitions. |
| B4 — medium lifecycle clarification | `05-q04-reading.md`, **Completion and replay** and **Cancellation, error, reconnect, and replay rules** | An asynchronous Q04 round should have an unambiguous open/close/reopen rule that cannot strand a late reader or erase another reader’s draft. | Q04 says later readers see “Round complete,” but also says replay is available after the round is “explicitly reopened”; no owner/action is defined for reopening, and Task 09 only generally says explicit replay creates a new round. | Define `StartNextRound` as the sole transition, authorized for any participant after a paid round (or explicitly host-only), and state whether a personal completion submitted after payment belongs to the old round for acknowledgement only or must target the next round. Preserve old drafts. |
| B5 — medium wording correction | `09-progression-cake.md`, **Evidence limits and unresolved choices** | Approved baseline facts must be distinguished from genuinely open implementation choices. | The same section lists the “final Big into Energy asset/probability reference” as open, conflating asset provenance (open) with approved custom odds/guarantee (settled). | Split the item: asset/reference/provenance remains open; custom outcome weights and fifth-roll guarantee remain approved baseline and require only implementation/evidence verification. |
| B6 — medium source-contract correction | `07-q06-food.md`, **Coherent proposed activity** and **Acceptance scenarios** | Q06 should preserve the confirmed location and patio separation while clearly labeling menu/role details as proposals. | Q06 does label the food assembly as proposed and explicitly supersedes historical patio cooking, but its “five roles” and “at least two place settings” are new concrete defaults not yet reflected in PCW-12’s amendment list as an explicit open choice. | Mark exact role count/place-setting minimum as a proposed content choice in PCW-12/PCW-15 and keep it out of immutable verifier criteria until approved. The location and patio exclusion are not open. |
| B7 — non-blocking evidence correction | `01-placement.md`, `08-lobby-queue.md`, `10-seattle-boundary.md`, `11-night-lighting.md`, `12-grass-decoration.md` | Source observations and proposed anchors must not be mistaken for installed live Studio state. | All five drafts generally disclose this limit and request measured captures; none claims live readiness. The remaining risk is that source-derived coordinates and existing screenshots are copied into implementation without the required current-scene capture. | Keep the explicit capture gate and require one revision-bound anchor manifest before implementation. This is a future evidence blocker, not a design contradiction. |
| B8 — non-blocking evidence correction | `08-lobby-queue.md`, **Transfer and exactly-once interface** | Published multi-server transfer, partial failure, duplicate/late callbacks, and arrival receipts require published-session evidence. | The draft correctly specifies retry against the same destination reservation and says Studio-only simulation cannot certify it; no contradiction found. | Retain as a required PCW-16 published test, not a Studio acceptance claim. |

### Confirmed consistency findings

- `06-q05-labubu.md` explicitly says Q05 never adds fund units, never grants personal coins, and uses the approved custom odds/ID guarantee. This is consistent with the README and is not a defect.
- `08-lobby-queue.md` explicitly supersedes PCW-17’s personal timer, per-player pad, and same-place relocation. It has the required eight-player acceleration, cap-10 rejection, frozen roster, same-reservation retry, duplicate/late callback handling, and no timer resurrection. Published transfer remains unverified.
- `03-q02-jasper.md` preserves the required indoor start and outdoor fetch lane/fallback. `01-placement.md` likewise keeps Jasper out of the arrival/door path.
- `07-q06-food.md` places food near FOB/Aladdins and explicitly keeps the patio for cake; its historical PCW-12 patio cooking text is labeled superseded.
- `05-q04-reading.md` and `12-grass-decoration.md` protect the existing Quad interior paths/trees while allowing only outside-edge additions. This requires later transform evidence but is not a planning contradiction.
- The drafts consistently preserve independent cameras, session-only state, touch/desktop parity, no absent-player gate, and the empty user-authored note.

### Bounded verifier cross-check

A dedicated GPT-5.6 Luna / Low verifier read the complete draft set plus the now-present `roblox/mvp/CONTRACT.md` and `roblox/mvp/INTEGRATION.md`. It returned substantive findings, independently confirming the following:

| Severity | Exact location | Expected vs observed | Smallest fix |
|---|---|---|---|
| High | `roblox/mvp/CONTRACT.md` Activity adapter/API; `05-q04-reading.md` suggested Q04 calls | One canonical adapter boundary must own state mutations and receipts. The shared contract defines `CreateRound`, `Apply`, `CompleteRound`, and `CommitPurchase`, while Q04 exposes `OpenDraft`, `PatchDraft`, `SaveDraft`, and `CompleteRead` without an explicit adapter mapping. | Add a canonical API mapping table to `CONTRACT.md`; classify Q04 calls as adapter operations and keep receipt ownership in the shared session service. |
| High | `05-q04-reading.md` completion/replay and `roblox/mvp/CONTRACT.md` Q04 rules | Q04 must preserve independent drafts, prevent resave payment, and create a new round only through explicit replay. The behavior is split across two documents, creating competing authority. | Make `CONTRACT.md` authoritative for draft revision, contribution eligibility, and `StartNextRound`; reduce Q04 to its activity-specific adapter behavior. |
| Medium | `04-q03-craft.md` final presentation and `roblox/mvp/CONTRACT.md` permissions | Q03 permits Phuong or host fallback, but the shared contract has no `SetFinalPresentation` API or complete absence rule. | Define idempotent `SetFinalPresentation`, authorized actor, temporary absence condition, and visible receipt/audit result centrally. |
| Medium | `06-q05-labubu.md` figure IDs and `roblox/mvp/CONTRACT.md` purchase primitive | Approved probabilities and fifth-roll guarantee are correct, but logical-to-approved seven-figure IDs remain open. | Add an explicit seven-ID mapping/configuration requirement and deterministic tests; do not change the approved weights or guarantee. |
| Low | `06-q05-labubu.md` Q05 fund rule and `roblox/mvp/CONTRACT.md` activity config | Both correctly state Q05 never earns fund currency, but this is not centrally encoded. | Add canonical `fundRewardEligible = false` for Q05 so adapters cannot drift. |

The verifier found Q06 patio separation, queue acceleration/capacity/frozen roster/retry, Q02 indoor-to-outdoor Jasper flow, and protected Quad geometry consistent at planning/source level. It separately confirmed that published teleport, failure-window behavior, ten-player arrival, Studio state, device performance, group play, and human fun remain evidence gates—not documentation facts.

### MVP source review correction

The actual MVP source and Luau specs are now present under `roblox/mvp`. The Python file previously added under `verification/mvp` is explicitly illustrative and is excluded from MVP pass evidence. The actual Luau specs are the authoritative source-level test target.

The bounded verifier also identified these implementation blockers:

- `roblox/mvp/CONTRACT.md` owns `CreateRound`, `Apply`, `CompleteRound`, and `CommitPurchase`, while Q04’s draft-level calls (`OpenDraft`, `PatchDraft`, `SaveDraft`, `CompleteRead`) are not mapped as adapters. Owner 09 must publish that mapping and receipt ownership before implementation tests can be interpreted.
- Q04 replay semantics are split between the draft and shared contract. `StartNextRound`, draft revision, contribution eligibility, and old-save behavior need one authoritative state machine.
- Q03 needs a shared `SetFinalPresentation` permission/receipt path for Phuong, temporary host fallback, and idempotent retries.
- Q05’s approved custom weights and fifth-roll guarantee are preserved, but the seven logical figure IDs need an explicit mapping/configuration requirement. This is an implementation identity blocker, not approval to alter the probabilities.
- Encode Q05 as `fundRewardEligible = false` in the central activity configuration; the source currently states this behavior but central encoding prevents drift.

`verification/mvp/run_luau_specs.ps1` is the actual-spec runner. It was run and exited `2` because no compatible local Luau runtime was available; no Luau MVP module was executed. The required next step is the exclusive Studio test window described in the handoff, after integrator installation. This remains `CHANGES_REQUIRED`, not gameplay `PASS`.

### Actual Luau source defects (independent review)

These findings come from read-only inspection of the current MVP source, not from executed gameplay. Owners must fix and then run the actual Luau specs in the exclusive window.

| Severity | File/section | Expected | Observed | Owner / smallest fix |
|---|---|---|---|---|
| High | `server/activities/Q04.luau:Apply`, `server/SessionService.luau:CompleteRound` | The first eligible bookmark may intentionally pay/close the shared reward round, but other readers must still finish their own personal bookmark for acknowledgement without being blocked. | Q04 calls `SessionService:CompleteRound` on the first personal `complete=true`, setting the shared round `COMPLETED`; later readers cannot `ApplyStep`, so their own acknowledgements are blocked. | Owner 09/Q04: preserve first-eligible shared reward timing, but decouple personal draft completion/acknowledgement from the closed reward round. |
| High | `server/SessionService.luau:CommitPurchase` | Spend requires a present authorized Phuong or configured fallback host, and the purchase must be exactly-once. | Direct `CommitPurchase` checks identity but not `presentUserIds`; an absent Phuong/host can spend if a caller reaches the service. | Owner 09: require presence in the canonical purchase request/service context, or make only Q05’s validated adapter able to call an internal commit primitive. Add a race test. |
| High | `server/activities/Q05.luau:CreateRound`, `Apply` | Q05 remains replayable after fulfillment, while wanted selection/counter rules remain session-scoped and Q05 never earns fund currency. | `CreateRound` rejects any second round while `self.roundId` is set; no reset/replay path exists after fulfillment. | Owner 06/09: use canonical `StartNextRound`/replay state without resetting the fulfilled petal; preserve the selected-figure/session collection policy. |
| Medium — fixed, execution pending | `server/TeleportAdapter.luau:Reserve/Transfer/RetryMember` | Retry must target the same reserved destination/session and duplicate/late callbacks must be idempotent. | Current source now caches `reservedServerAccessCode` and reuses it for `RetryMember`; the earlier `ShouldReserveServer` retry defect is fixed. Per-member arrival receipts/callback dedupe and published behavior remain unexecuted. | Owner 08: add/verify arrival receipts and published tests. Do not retain the old retry defect against current source. |
| Medium | `server/activities/Q03.luau:Apply` finalize branch | Final presentation needs a canonical permission path and idempotent presentation receipt. | It checks Phuong/host locally and stores `state.finalPresentation`, but has no shared `SetFinalPresentation` receipt/API and does not expose the result through the common completion contract. | Owner 09/Q03: centralize permission/fallback and return a deduplicated presentation receipt. |
| Medium | `server/SessionService.luau:ApplyStep`, activity adapters | Arbitrary client steps must be rejected before shared state mutation; duplicate accepted steps should return the original receipt consistently. | SessionService accepts any nonempty `stepId`; per-activity validation varies, and a repeated step with a new action returns the old accepted step without a consistent duplicate code/receipt contract. | Owner 09 plus activity owners: make the adapter own allow-lists and define the canonical duplicate-step response; add negative tests for each activity. |
| Medium | `server/SessionService.luau:CompleteRound` and activity completion calls | Replay reward classification must come from explicit canonical replay state, and completion must be immutable across retries. | The service does classify `isReplay`, but several activities synthesize completion action IDs (`complete:` prefixes) and local global flags; there is no common completion receipt lookup by round before adapter-side state changes. | Owner 09: make round completion idempotent by `roundId` and return the original receipt for duplicate completion attempts, regardless of action ID. |

The source review also confirms the current Config values preserve the approved six regular IDs, secret ID, 16.5%/1% baseline, and fifth-roll constant. Those values were not treated as newly undecided; the unresolved item is the required mapping/asset provenance and deterministic test coverage.

**Reviewed source fingerprint:** `SessionService.luau` `C6822378CEE62FE79DD8278F55E6E6F7EF6976521B8BF8E3775D142E21B0C96D`; `TeleportAdapter.luau` `22082E97B07DD791D41107730700589AC1C8EC5306C5C0B6C92E20F20B09A00D`; `QueueService.luau` `9C1F7322949395896229FF7EDC9AB0E719F9B5AA642B1EF42A2968724D9B920B`; `Q04.luau` `56A6B69A8B106AC47653273A1981819050D43644227165E8E1FFE8110BFF0E71`; `Q05.luau` `0E8B44D2198FDA4F1724B8F5856F9517F6BD5C54B4A1381E9E7829EADC8BAC07`. These are read-only source fingerprints, not Studio/runtime evidence.

### Current installer and placement audit

Read-only inspection of the current source foundation found additional integration blockers:

- `roblox/mvp/install.luau` creates only `ReplicatedStorage.PhuangMVP.Action` and a manifest attribute. It does not mount `server/Main.server.luau`, `client/Main.client.luau`, shared services, or Q01–Q06 modules. Therefore the current installer cannot produce a playable MVP and must not be described as installed gameplay.
- `roblox/mvp/client/Main.client.luau` is a source file only; no current installer path mounts it under `StarterPlayer.StarterPlayerScripts`. A Workspace folder would not execute it as a LocalScript. Owner 01/integrator must mount the reviewed LocalScript in the correct service during the exclusive Studio window.
- `roblox/mvp/anchors-live-draft03.json` records `Q04QuadReading` as `UNRESOLVED_NAME_OR_INSTANCE` and `Q06Serving` as `UNRESOLVED_ACTIVITY_OWNED_SURFACE`. This confirms no live source proof for the Q04 bench anchor or Q06 serving location. The historical Quad bench coordinates must not be treated as current placement evidence.
- `Q06Station.luau` places `Q06Serving` relative to whichever anchor is supplied; it does not itself guarantee UDistrict placement. The anchor manifest must reject a patio/FinalePatio binding and require measured UDistrict clearance before installation.
- `Main.server.luau` assigns ten numeric arrival slots but does not position characters, validate collision/door/bed/Jasper clearance, or restore a session on reconnect. Ten-slot capacity is source intent only, not arrival evidence.
- No generic `ActivityKernel` replaces the six activity modules in the inspected source; the six server activity files exist. However, the installer currently does not register or mount those modules, so six-activity play is not established.

These findings are source/integration blockers, not live Studio observations. The exact current place geometry remains unverified until the integrator’s exclusive window permits read-only inspection after installation.

### Current bundle and entrypoint audit

The regenerated source bundle is **hash/XML-valid and ready for a reviewed local insertion step**, but it is not installed gameplay and is not ready for playtest approval. `verification/mvp/BUNDLE-INSTALL.md` records generation `2026-09-27T14:36:37.7427825-07:00`, 30 source entries, XML parse success, and manifest/source hash agreement. The bundle’s documented mounts include runtime modules/entrypoints, `MeasuredInstallOptions`, plus `ServerStorage/PhuongMVPTools` installer, anchor builder, and world builders.

Current concrete blockers and mismatches remain:

- `roblox/mvp/install.luau` currently validates measured anchors/options and invokes station/environment builders; mounting the runtime hierarchy and creating `ReplicatedStorage/PhuongMVP/Action` remain explicit integrator actions. The reviewed insertion artifact is `verification/mvp/bundle-out/Phuong-Cozy-MVP-source.rbxmx`; no Studio insertion or playtest was performed by Task 13.
- The current client/server request mapping is aligned for the reviewed session envelope: the client carries the server-issued session ID for activity/view/journal requests, while snapshot uses its dedicated branch. Runtime behavior remains unverified.
- The previously observed `INTEGRATION.md` round-object versus module-level API mismatch is resolved in the current integrator revision; recheck the frozen bundle hashes if that contract changes again.
- `anchors-live-draft03.json` leaves `Q04QuadReading` unresolved and `Q06Serving` unresolved. The bundle document explicitly records the actual Quad seats and rejects the prior patio Q06 coordinate; these are still placement-validation requirements, not source-only passes.
- `Main.server.luau:80-84` provides ten slot attributes and `:40-44` provides a pivot helper, but the source does not prove collision/bed/Jasper/door clearance or reconnect restoration. Local transfer placement remains a source path, not gameplay evidence.

**Entrypoint/source fingerprints:** `install.luau` `06DBAA5A93064D765FA4C9F1F340F71BA8B0ABF6B90177C413DD99A963CF4EA0`; `server/Main.server.luau` `02A4B009911C92FDD8735395E4F9C2F78259017FF95B8662A7B4720FBC3D9EE3`; `client/Main.client.luau` `FBE81C17C7B8A859192B6FA3B72471F0751D2A1643AF6C3230D9B00C4B52AC82`; `shared/Anchors.luau` `44DD13F4963ADD33C59D2F6DFEA4424BFC87B6C1BCB62318945B00C4EFB77FD8`; `shared/Config.luau` `45947095247B646BF3B80931AEEA124EF0DB9D81846B5F421D30F3EAD762E0C1`.

### Historical module-tree adapter execution results (superseded by current reruns below)

A test-only adapter was generated from the untouched Luau source strings, preserving `script.Parent`/child navigation and printing source hashes. It is not installable Roblox code. With the official Luau 0.740 runtime, the actual specs produced **2 passes and 7 failures**: `queue_service.spec.luau` and `cake_service.spec.luau` passed; `session_service.spec.luau`, Q01, Q02, Q03, Q04, Q05, and Q06 failed with concrete issues below. The teleport spec was omitted from the adapter because it requires Roblox `game`, `Instance`, and TeleportService globals; it remains Studio/fake-service boundary testing only.

| Severity | Actual result | Owner correction |
|---|---|---|
| High | `session_service.spec.luau` fails at `SessionService.luau:79` when a duplicate completion uses a new action ID after the round is completed. The current state check occurs before `round.completionReceipt` lookup. | Owner 09: return the stored completion receipt by round before rejecting a completed round. |
| High | Q02 fails at `Q02.luau:19`: constructor stores `session = options.session` even though the parameter is `ctx`; the actual session is nil. | Owner 03: use `ctx.session`; rerun Q02 spec. |
| High | Q05 fails at `SessionService.luau:134`: Q05’s context presence map is not reflected in SessionService presence, so a present Phuong is rejected by the atomic purchase boundary. | Owner 06/09: pass canonical presence into the service or use one authoritative presence source; retain host-while-Phuong-present rejection. |
| Medium | Q01 fails at `SessionService.luau:52` because its activity adapter omits canonical `sessionId`/`activityId` in `ApplyStep`. | Owner 02/09: include the full canonical request shape. |
| Medium | Q03 fails at its `validId` guard because the source requires string IDs while the current spec supplies numeric actor IDs; the shared contract describes opaque IDs but current tests/config use numeric Roblox UserIds. | Owner 04/09: normalize actor identity at the adapter boundary and make the contract/tests consistent; do not silently weaken authentication. |
| Medium | Q04 reaches the adapter but its current spec expects `saved.saved`; the implementation returns `ok=true, code="SAVED"`. This is a test/contract shape mismatch, not evidence of a pass. | Owner 05/09: standardize the view/receipt field name and update the spec or implementation through the canonical contract. |
| Medium | Q06 fails at its request-ID guard in the actual adapter run; the request-shape expectation and test invocation need reconciliation before behavior can be assessed. | Owner 07/09: capture the exact failing request payload in the next run and standardize required `activityId`, `roundId`, `actionId`, and actor fields. |

The generated adapter and source hashes are test artifacts only; no production source was rewritten and no Studio behavior is implied. These results supersede earlier “not executable” wording for the pure modules while engine-only teleport/device/scene gates remain pending.

### Prior rerun after owner repairs (superseded by latest run below)

The adapter was regenerated from current files. Current compilation is **42/42 successful** and actual supported spec execution is **6 passed, 3 failed**: SessionService, QueueService, CakeService, Q01, Q02, and Q03 pass; Q04, Q05, and Q06 fail. Q04’s failure is a stale fixture expecting a second completion to throw, contrary to the intended late-bookmark acknowledgement behavior. Q05 has a real source defect: its completion call omits canonical `sessionId` and `activityId`. Q06’s failure is a stale fixture missing the newly required `sessionId`. Full details and hashes are in `verification/runs/mvp-20260927-source-adapter-rerun2.md`.

This rerun supersedes the prior 2-pass/7-failure status for current source behavior. No bundle-manifest consistency or Studio gameplay approval is implied.

### Prior current-source rerun 3 (superseded by rerun 4)

The adapter was regenerated again from current files. Compilation remains **42/42 successful**; supported specs remain **6 passed, 3 failed**. The current failures are:

- **Q04:** fixture still expects the second late bookmark completion to throw; current behavior intentionally acknowledges it. Owner 05 should update the fixture, not require all readers before the first shared reward.
- **Q05:** the canonical completion envelope is now present, but the completion call reaches `SessionService:CompleteRound` with no accepted Q05 step and fails `round has no accepted steps`. Owner 06 must record an accepted Q05 step or use the canonical Q05 completion path without weakening the once-only petal rule.
- **Q06:** the fixture now supplies session IDs in the visible calls but still fails the source request-ID guard during the run. Owner 07 must capture the exact failing call/stack and align every CreateRound/Reserve/Cancel/Apply request with the canonical envelope.

Latest source hashes are saved in `verification/runs/mvp-20260927-source-adapter-rerun2.md` only for the earlier run; this latest run must receive a new versioned log before any further status claim. Bundle manifest/hash consistency remains unreviewed while Owner 01 refreshes packaging.

### Current targeted rerun 4 (superseded by rerun 5)

The adapter was regenerated from the current source/spec files and the official Luau compiler again compiled **42/42** source files successfully. The supported module/spec run produced **7 passes and 2 failures**: SessionService, QueueService, CakeService, Q01, Q02, Q03, and Q04 pass; Q05 was intentionally not dispositioned in this run at the coordinator's request; Q06 fails before behavior assessment because `Q06.spec.luau:15` sends `CreateRound` without the required `actionId`. The exact stack and current source/spec hashes are recorded in `verification/runs/mvp-20260927-source-adapter-rerun4.md`.

Q04 is now green with the refreshed fixture and its late-reader acknowledgement behavior is therefore covered by the current adapter run. Q05's prior source issue remains open: its completion path reaches `SessionService:CompleteRound` without an accepted Q05 step and raises `round has no accepted steps`; this was deliberately left out of the latest disposition rather than converted into a false pass. Q06 requires a fixture-envelope correction before its activity behavior can be assessed. No bundle consistency, Studio, device, group, published-transfer, or human-fun gate is implied.

### Prior source rerun 5 (superseded by rerun 6)

After the Owner 06 repair, the adapter was regenerated from current files and executed again. The prior result was **8 passed, 1 failed**, with Q06 blocked by its fixture envelope. It is retained in `verification/runs/mvp-20260927-source-adapter-rerun5.md` for traceability.

### Current source rerun 6

After the Q06 fixture/builder repair, the adapter was regenerated from the current source tree. Compilation is **42/42 successful** and supported module/spec execution is **9 passed, 0 failed** across SessionService, QueueService, CakeService, Q01–Q06. The exact current hashes and result are recorded in `verification/runs/mvp-20260927-source-adapter-rerun6.md`. This is source/spec evidence only; no Studio, device, group, published-transfer, or human-fun gate is passed. The current `Main.server.luau` hash differs from the frozen bundle, so the bundle requires regeneration before it can represent this revision.

### Historical standalone-runtime result (superseded by ModuleScript adapter)

The official Luau 0.740 Windows release was downloaded into the scoped `verification/mvp/tools` directory after verifying the upstream `luau-lang/luau` release. `luau-compile.exe` compiled all 42 current `roblox/mvp/**/*.luau` files with zero compiler failures. Running all 10 actual specs with `luau.exe` reached each file but failed immediately at line 1 with `attempt to index nil with 'Parent'`: the standalone runtime does not provide Roblox’s ModuleScript `script.Parent` hierarchy. This is a real harness/environment failure, not an implementation pass. The specs require Studio execution or a documented module-tree adapter; no Python reimplementation is being used as evidence.

## Targeted future rehearsal matrix

The following is the minimum later matrix. Each row needs participant roster, device/model and OS, build/session identifier, exact steps, expected result, observed result, evidence path, and defect owner. Run it on the same revision used for the integrated review.

| ID | Setup and trigger | Expected outcome |
|---|---|---|
| R1 Queue baseline | Empty lobby; P1 enters square, P1 leaves, P2 enters | First queue generation starts at 60 seconds; empty square resets generation; no personal arrival countdown. |
| R2 Queue acceleration | Seven queued, then P8 enters; separately test P8 leaves before expiry | At eight, deadline becomes no later than now+10s; joining never extends it; dropping below eight does not extend it. |
| R3 Capacity | Ten queued, P11 attempts entry; include unrelated lobby player | P11 receives readable rejection; no roster mutation; no unrelated player transfers; no launch before deadline. |
| R4 Frozen transfer | Queue expires with eight-to-ten roster; one member disconnects during reservation/transfer | Frozen roster and one destination are retained; retry/partial-failure behavior is deterministic; duplicate teleport does not create a second party. |
| R5 Bedroom arrival | Ten players arrive together | Ten unique safe spots; no avatar overlaps bed, Jasper, door, or each other; exits and interaction positions remain usable. |
| R6 Camera/input | One phone, one tablet, one desktop participant concurrently rotates/zooms and opens UI | Each camera remains independent; no forced cinematic/shared camera; controls do not cover movement, jump, inset, or camera-drag areas. |
| R7 Jasper handoff | Players greet Jasper indoors, then follow to yard; induce navigation obstruction | Indoor greeting remains available; fetch moves to yard; solo-friendly fallback completes or recovers without deadlock. |
| R8 Q01/Q03 concurrency | Different players perform bed steps; others use booth/desk miniature simultaneously | Accepted steps are server-validated and visible; reservations are local; one round completion and one petal/fund receipt only. |
| R9 Q04 shared reading | Several readers save bookmarks at once; reopen/resave an old bookmark | Independent bookmarks coexist; simultaneous saves cannot double-pay; reopening/resaving pays nothing; explicit replay is required. |
| R10 Q05 guarantee | Set a selected regular figure, then selected secret ID; perform four misses and fifth roll; disconnect during reveal | Fifth unsuccessful-sequence roll awards selected ID or figure; award/debit is exactly once before animation; reconnect restores live session state; reveal can be skipped. |
| R11 Q06 contribution | Players perform parallel food roles near FOB/Aladdins; late joiner helps replay | Counters and roles remain accessible; no patio/cake collision; accepted contributors receive the configured shared-fund receipt once. |
| R12 Six-petal unlock | Complete five earning activities and Q05 wanted-Labubu in mixed order; attempt cake with money only | Exactly six petals; Q05 petal requires wanted completion; cake remains locked until all six required petals, not merely fund balance. |
| R13 Disconnect/rejoin | Disconnect during each activity, during reward, and during cake invitation; rejoin same session | Accepted state and live session identity restore; unfinished reservations release; rewards/petals do not repeat; lobby timer is not resurrected or restarted. |
| R14 Voluntary cake | Phuong present and absent in separate runs; fewer than eight guests; guests arrive late and leave | Host/Phuong can invite/start when permitted; no absent-player or minimum-count gate; no forced warp/camera; seated guests can eat through forgiving actions; activities remain available. |
| R15 Environment readability | Ten avatars at patio, crossing and Quad at low settings/night; walk every main route | Perimeter hides unfinished edges without blocking sky; routes remain readable; protected Quad interior geometry is unchanged; no harmful collision or camera obstruction. |
| R16 Full rehearsal | Eight real participants across named phone/tablet/desktop targets for approximately 30 minutes | All quests completable by touch and desktop; camera/UI usable; relaxed pacing assessed with actual notes; defects and retests recorded rather than inferred. |

## Required corrections by owner

When the drafts are available, return exact line-level requests. At this checkpoint the actionable requests are:

- **Owners 01–12:** bind implementation to the shared contracts and resolve the findings above; the twelve drafts are present and no longer missing inputs.
- **Owner 01:** publish the single anchor/footprint vocabulary and measured-source requirements used by all other drafts.
- **Owner 08:** make queue generation, deadline acceleration, cap-10 rejection, frozen roster, retry, late-arrival, and duplicate-transfer semantics explicit.
- **Owner 09:** reconcile the shared fund, six-petal graph, Phuong spending permissions, five-roll guarantee including selected ID, session-only restoration, and voluntary cake flow. Clearly label numeric reward rates and menu choices as proposed defaults.
- **Owners 02–07:** reference the common receipt/action contract instead of inventing wallets or independent petal semantics; state how a late/reconnected participant contributes without repeating rewards.
- **Owners 10–12:** provide geometry, route/sightline, protected-Quad, material/light, collision, and mobile-budget checks; do not claim visual or Roblox readiness from a plan.
- **PCW-16 integrator:** name lowest intended phone, tablet and desktop targets before performance sign-off; preserve actual user feedback and the personal note boundary.

## Bounded later implementation and review sequence

1. Receive drafts 01–12 and run this consistency audit; return only targeted corrections.
2. Freeze anchor and progression interfaces, then update affected tickets/contracts before implementation.
3. Build queue/arrival foundation and verify server/session identity before activity work.
4. Implement activities against the shared receipt contract, then add bounded environment passes.
5. Obtain independent verifier review of submitted artifacts and actual Studio evidence; keep device, group, and human-fun gates pending until observed.
6. Run R1–R16 on named devices, fix defects, and rerun failed plus regression rows.
7. Report unresolved scope choices to the user. Never label a design-document review as gameplay `PASS`.

## Honest evidence status

This MVP update records the twelve available drafts, the current contract findings, and the independent pure-test plan. It does not establish that any queue, spawn, camera, activity, economy, environment, cake flow, device layout, performance target, or reconnect behavior exists in Roblox. No Studio import/playtest, published-session teleport, mixed-device rehearsal, or human fun review has been performed for this wave.
