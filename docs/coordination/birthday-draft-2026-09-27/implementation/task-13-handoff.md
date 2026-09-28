# Task 13 implementation handoff

**Owner:** independent verification  
**Status:** source-level verification prepared; Studio/device/group gates pending  
**Scope:** MVP contract ledger, independent Luau test execution plan, and first-user-playtest checklist

## Files delivered

- `docs/coordination/birthday-draft-2026-09-27/13-independent-review.md` — updated review, current findings, requirement ledger, rehearsal matrix, and evidence limits.
- `verification/mvp/run_luau_specs.ps1` — runner for the actual Luau specs under `roblox/mvp/tests`; exits `2` when no compatible local Luau runtime exists rather than fabricating a pass.
- `verification/mvp/STUDIO_TEST_WINDOW.md` — bounded Studio execution order, required observations, lease prerequisite, and evidence packet.
- `verification/mvp/tools/luau-0.740/` — scoped official Luau 0.740 Windows runtime and compiler; SHA-256 of downloaded archive: `BE676D9A1092B3D5EE36BE5F5F11E2AF1976911C32F5644A052548DC7C66BB9C`.
- `verification/mvp/generate_luau_adapter.py` and generated `verification/mvp/run_module_specs.luau` — test-only ModuleScript-tree adapter loading original source strings; never install in Roblox.
- `verification/mvp/test_mvp_contracts.py` — illustrative Python contract model only. It is **not** implementation evidence and must not be used for MVP pass/readiness.

## How to run

```powershell
.\verification\mvp\run_luau_specs.ps1
```

The runner targets the actual Luau modules/specs. It must be run with a compatible local Luau runtime or during the designated Studio test window. The Python model is explanatory only.

## Test results

- `python -m unittest verification.mvp.test_mvp_contracts -v`: **8/8 passed as illustrative/spec-only examples; not implementation evidence**.
- `verification/mvp/run_luau_specs.ps1`: **blocked (exit 2)** because no local `luau` command was available. No actual Luau MVP module was executed in this environment.
- Updated actual-runtime result: `luau-compile.exe` compiled all **42** `roblox/mvp/**/*.luau` files with zero syntax/compiler failures.
- Latest test-only adapter rerun after the Owner 06 repair executed the original source/specs: **8 passed, 1 failed**. SessionService, QueueService, CakeService, Q01, Q02, Q03, Q04, and Q05 pass. Q06 fails at `Q06.spec.luau:15` because its `CreateRound` fixture omits required `actionId`; the source guard is `Q06.luau:43`. Exact output, disposition, and relevant hashes are in `verification/runs/mvp-20260927-source-adapter-rerun5.md`. These are actual source/spec results, not Python-model evidence.
- A combined run including legacy `verification.test_party_runtime` and `verification.test_verify` did not complete: the former could not resolve its existing `check_party_runtime` import from the repository-root invocation, and the latter lacks the optional Pillow dependency in the active interpreter. These are environment/source-test setup blockers, not MVP gameplay results.
- No Studio start/stop, script injection, camera mutation, lighting mutation, place import, upload, publish, or production harness run was performed by Task 13.

## Binding requirements

Before interpreting any MVP result, bind the implementation to the designated integrator’s `roblox/mvp/CONTRACT.md` and `roblox/mvp/INTEGRATION.md`. Task 13 must not invent a competing global session/reward API. If either file is absent, the implementation review is blocked on that missing contract.

## Remaining gates and owners

- Owner 01/integrator: current anchor manifest, ten safe bedroom spots, protected Quad transforms, and exclusive Studio installation window.
- Owner 09: canonical session/action/round/receipt schema, Q03 final-presentation permission, Q04 next-round transition, Q05 approved odds/guarantee, shared-fund authorization.
- Owner 08: published-compatible transfer, same-reservation retry, player-facing failure recovery, duplicate/late callback handling.
- Owners 02–07: activity adapters and once-only receipts against the canonical contract.
- Owners 10–12: perimeter/night/decoration implementation and route/sightline evidence.
- Task 13: independent source/Studio/device/group review only after the integrator grants the exclusive test window; no self-approval.

## Historical source findings and current open item

- Resolved and covered by the current adapter run: Q04 late-reader fixture/behavior, SessionService duplicate completion, Q01 canonical request, Q02 construction, Q03 ID handling, and Q05 completion path. These remain in older run logs for traceability and are not current defects.
- Resolved in rerun 6: Q06’s `CreateRound` fixture now uses the canonical action envelope and the Q06 spec passes.
- SessionService `CommitPurchase` checks actor identity but not current presence; enforce presence in the canonical purchase boundary.
- Q05 replay-after-fulfillment remains a source-review item, separate from the passing current Q05 spec.
- The earlier teleport retry defect is fixed in the current source: `Reserve` caches `reservedServerAccessCode` and `RetryMember` reuses it. Per-member arrival receipt/callback dedupe and published behavior remain unverified.
- Q03 final presentation is locally permission-checked but lacks a shared idempotent presentation receipt/API.
- SessionService accepts arbitrary nonempty step IDs and duplicate-step responses are not normalized; activity adapters need canonical allow-list and duplicate semantics.
- Completion idempotency is currently action-ID-centric; make round completion immutable and return the original receipt even if a duplicate completion uses another action ID.

These remaining items are source-review findings only. They are not claimed as Studio/runtime observations.

The reviewed source fingerprint is recorded in `13-independent-review.md`; rehash before execution and treat any change as a new review revision.

## First-user-playtest checklist

After the independent evidence gates pass, ask the user to play one complete session with real friends and record actual observations:

1. Join/leave the shared lobby square; confirm the shared timer is understandable and does not feel like a personal countdown.
2. Arrive in the bedroom with 8–10 players; check the room feels cozy, navigable, and not crowded around bed/Jasper/door.
3. Rotate each player’s third-person camera independently on phone, tablet, and desktop.
4. Complete each of Q01–Q06 through touch and desktop equivalents; record unclear prompts, contention, waiting, or repetitive steps.
5. Confirm Q02 feels natural from Jasper’s indoor greeting to the outdoor fetch area.
6. Confirm the shared fund, six petals, Q05 wanted figure, fifth-roll guarantee, and cake invitation are understandable without explanation.
7. Disconnect/rejoin one player during an activity and during a reward/reveal; verify no progress or reward duplication.
8. Walk voluntarily to the patio with fewer than eight present; cut/eat cake without forced camera or absent-player gate.
9. Ask whether the pacing, route discovery, contribution credit, and replay behavior felt satisfying; preserve the user’s actual words without inventing feedback.
10. Leave the personal birthday note empty unless the user supplies its exact text.

## Exclusive Studio test window requested

Task 13 needs one exclusive window after the designated integrator installs the MVP into a copied local place and confirms the shared `CONTRACT.md`/`INTEGRATION.md` bindings. During that window, Task 13 should run the Luau specs from `roblox/mvp/tests` against the actual installed modules, then perform read-only Studio play checks for queue/arrival/camera/activity/reconnect/cake behavior. Required artifacts are the exact revision ID, Luau output, Studio console output, screenshots/logs, participant roster, and defect reproduction records. Task 13 must not install, mutate, publish, or self-approve.

## Evidence status

No gameplay `PASS` is claimed. Studio import/play, published multi-server transfer, real 8–10-player behavior, mobile/tablet/desktop performance, and human fun acceptance remain pending.

## Bundle readiness result

The source/spec suite remains **9/9 passing** after the official host-policy delta; the focused SessionService/CakeService/Q05 retest is recorded in `verification/runs/mvp-20260927-host-policy-focused.md`. The targeted client session-ID retest remains resolved. The prior 30-entry bundle is stale relative to this 43-source revision and must not be treated as the current package. Actual server requires resolve under `ServerScriptService/PhuongMVP/server/Main` to sibling services and `ServerScriptService/PhuongMVP/shared`, matching `script.Parent.Parent.shared.*`; the ReplicatedStorage shared copy is client-safe. `install.luau` runs measured builder staging/rollback, while runtime mounting and `ReplicatedStorage/PhuongMVP/Action` creation remain explicit integrator actions. Treat the source as source-review evidence only until the integrator supplies a matching package and approved local-place handoff. No Studio insertion, playtest, publish, or gameplay PASS is claimed.

## Bounded integration verification plan

After an approved insertion into a copied place, Task 13 will use the frozen bundle revision and read-only observation only: verify the exact service hierarchy, remotes, entrypoint loading, and source hashes; invoke the real `Main.server.luau` handlers through minimal test-double services or the approved Studio bridge; exercise queue, transfer, `CreateRound`, `Apply`, `GetView`, and cake through the actual router; assert receipts, presence, proximity rejection, duplicate actions, and six-petal/cake state; then run bounded Studio checks for camera independence, ten-player arrival spacing, Q01–Q06 interaction, reconnect, and cake flow. Capture the exact revision, console output, request/response payloads, screenshots, and defect traces. If executable insertion is rejected or a required service is absent, stop and record the gate as blocked.

Entrypoint fingerprints are recorded in the independent review. Q04 and Q06 placement remain unresolved in `anchors-live-draft03.json`; ten arrival slots remain source intent without collision/reconnect evidence.
