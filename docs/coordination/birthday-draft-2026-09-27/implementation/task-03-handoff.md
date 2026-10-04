# Task 03 handoff — Q02 Jasper

Status: source implementation complete for handoff; actual-source compile checks pass; Studio install and acceptance are not claimed.

## Owned files

- `roblox/mvp/server/activities/Q02.luau` — one server-owned Q02 adapter using `Module.new(ctx)`, `CreateRound`, `Apply`, and `GetView`.
- `roblox/mvp/builders/Q02Station.luau` — context-based edit-mode builder for greeting, yard, baskets, fetch lane, rabbit handoff, and Greenie markers.
- `roblox/mvp/client/activities/Q02.luau` — UI-safe desktop/touch labels and interaction guidance.
- `roblox/mvp/tests/Q02_activity.spec.luau` — injected state tests for ordered completion, wrong basket rejection, duplicate action handling, concurrent contributors, fund/petal completion, and non-reward petting.
- `docs/tickets/PCW-08.md` — versioned MVP amendment preserving the historical ticket text.
- `docs/coordination/birthday-draft-2026-09-27/03-q02-jasper.md` — design source and unresolved choices.

## Exports and behavior

The activity exports `new(ctx)`. The context must provide `session`, `clock` (optional), and `world`. Requests must carry the authenticated server `actor` with `UserId`; the module does not trust a client actor ID. `Apply` returns `{ok, code, receipt, view}`. The view uses the canonical fields and never grants authority.

The server sequence is greeting → rabbit found in the round-selected basket → rabbit returned → fetch1 → fetch2 → fetch3 → Greenie. Only the current fetch target is occupied. `ReleaseActor` releases unfinished reservations. Petting is available after completion and returns zero reward. Completion delegates petal/fund authority to `SessionService:CompleteRound`.

## Installation

Task 01/integrator must invoke `Q02Station` with the frozen builder context `{Root, MVP, Anchors, Palette, ReplaceFolder, SafeReplace}` after resolving measured `JasperBedroomStart` and `JasperFetchYard`. This task did not run Studio, mutate the live place, move anchors, install scripts, change camera/Lighting, publish, or upload assets.

## Tests and evidence

The official Luau compiler (`verification/mvp/tools/luau-0.740/luau-compile.exe`) compiled the Q02 activity, test, and client descriptor sources successfully after the constructor and canonical-envelope repair. The spec was not run as a live Roblox test and compilation is not evidence of visual movement or Studio behavior. The spec now uses trusted `SessionService:SetPresence`, numeric UserIds, indoor greeting through three fetch targets and Greenie, malformed/stale action rejection, and replay creation. Required later evidence: Studio edit capture of the staged model, server play test, touch and desktop input, 8–10 players, simultaneous throw, navigation stall fallback, bedroom/door clearance, disconnect/rejoin, late join, replay, Jasper figure identity/palette review, and independent verifier review.

## Dependencies and open gates

- `SessionService` must remain the shared reward/petal authority.
- Task 01 must provide measured bedroom, yard, route, and arrival-clearance anchors.
- Owner 01/Main must route authenticated Player actors and render canonical Q02 views.
- Owner 09 must keep the published contract fields and reward semantics stable.
- Jasper’s final fluffy golden-orange Pomeranian reference/model palette is still an evidence-gated fidelity decision; the builder deliberately uses exact world palette markers until an approved figure profile exists.
- The design choices for basket placement, target meshes, navigation timeout, and rabbit carry versus proximity handoff remain unresolved as recorded in the Q02 draft.

## Builder protocol repair

`Q02Station.luau` now uses only `SafeReplace("Q02", factory)`, rejects anchors marked `PlacementStatus="UNRESOLVED_LIVE_ANCHOR"`, validates required palette tokens before factory execution, builds a detached folder, tags every authored BasePart, records prompt bindings/footprints/clearances, and returns `{folder, manifest}` using the direct installed Instance. Exact source SHA256: `AB96D920805A6DC1B3F8C4A587FC31DD3F74F65179EFBA9D924A7130DCCA21E8`.

## Actual-source retest

Q02 now consumes the canonical server-stamped numeric `request.actorUserId` and retains `SessionService:IsPresent` checks; it does not trust client actor tables. `GetView` offers three explicit basket actions with payloads, and wrong baskets return normal `empty_basket` feedback without progress. The test traverses offered actions through greeting, basket discovery, rabbit return, three fetches, Greenie, petting, malformed/stale action, and replay. The generated actual-source adapter run passed all 10 module specs, including `Q02_activity.spec.luau`. Q02 source SHA256: `98BB044B530BBF4E2D4A6B7E1CB8F45F95BFF61158AD90F5DA655C7F5DAE0D27`. This is source/runtime evidence only; Studio movement, visual identity, device play, and group play remain independent gates.
