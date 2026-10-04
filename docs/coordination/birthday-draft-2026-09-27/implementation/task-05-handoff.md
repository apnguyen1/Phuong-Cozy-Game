# Task 05 Q04 implementation handoff

Status: source implementation complete; owned-source compile check passed; Q04BedroomKindle optional-marker boundary repaired; Studio/integration and evidence gates pending.

Latest Q04 server hash: `1BEC8E214D3E25924D77A7F9B8CC5C3729032102B86E1BC43E25A33C756FE6A4`. The generated actual-source Luau adapter run completed with `passed=10 failed=0`, including `roblox/mvp/tests/Q04.spec.luau`.

## Owned files

- `roblox/mvp/server/activities/Q04.luau` — server-side Q04 adapter with provisional passages, draft validation, idempotent action handling, completion, and UI-safe view.
- `roblox/mvp/builders/Q04Station.luau` — station anchors and UI descriptor.
- `roblox/mvp/client/activities/Q04.luau` — renderer-facing panel and choice descriptor.
- `roblox/mvp/tests/Q04.spec.luau` — pure state tests for save deduplication, completion, invalid choices, and stale revisions.
- `docs/tickets/PCW-10.md` — versioned MVP amendment; historical planning text retained.
- `docs/coordination/birthday-draft-2026-09-27/05-q04-reading.md` — design contract and acceptance scenarios.

## Exports and binding

`Q04.new({session, clock, context})` returns an activity adapter. It exports the canonical `CreateRound(request)`, `Apply(request)`, and `GetView(actorUserId)`. Actor identity is supplied on each authenticated request, never bound permanently to the instance. A validated `payload.complete=true` submitted through `Apply` calls `session:CompleteRound` exactly once for the active round.

`Q04Station(context)` preflights both required anchors and all eight palette tokens, then calls only `context.SafeReplace("Q04Station", factory)` with a detached folder containing three minimal book/prompt props. Because the installer’s required-anchor map intentionally omits the optional `Q04BedroomKindle`, the builder falls back only to the existing `MVP.Anchors` marker subtree; it does not invent coordinates or create markers. Every BasePart carries the PCW-10, palette, builder, anchor, footprint, clearance, owner, and source attributes. It returns `{folder, manifest}` and preserves existing benches, QuadPlanting, paths, and the bedroom desk/Kindle. Builder SHA-256: `9239BE85ACA1B5F71A36F2089D73225FBE78E8AAFE10B8EB30847690F873C4B7`.

## Installation and testing

No Studio installation, scene mutation, camera/lighting change, publish, or upload was performed. The owned source/spec compile check passed with `verification/mvp/tools/luau-0.740/luau-compile.exe`; the full actual-source adapter rerun remains owned by task 13. The spec now asserts the canonical `{ok, code, receipt, view}` envelope, bookmark preservation, and fund/petal effects. Passage word counts were authored within the required 50–80-word range but still need content review.

## Integration dependencies

1. Task 09 must confirm the corrected `SessionService`/contract binding for `CompleteRound`, replay creation, shared reward, once-only petal, receipts, and session persistence.
2. After the first eligible bookmark completes and pays a round, later readers in that same round remain able to save personal drafts/bookmarks through acknowledgement-only responses; these saves never call shared completion or award another fund/petal receipt. Task 01 must measure and install `Q04QuadReading` and `Q04BedroomKindle`; this task does not guess live positions or alter Quad geometry.
3. The common client renderer must bind the Q04 descriptor to a scrollable, movement-safe panel with keyboard avoidance and independent camera behavior.
4. The main router must explicitly route `CreateRound`, `Apply`, completion, and replay; no activity module should own wallets or fund mutation.

## Unresolved gates

Final passage/title approval, live anchor clearance, Studio import, mobile/tablet/desktop readability, keyboard behavior, concurrent readers, 8–10-player route safety, reconnect during save/reward, low-graphics behavior, and independent verification remain unresolved. This handoff is not a Roblox playtest result or final approval.
