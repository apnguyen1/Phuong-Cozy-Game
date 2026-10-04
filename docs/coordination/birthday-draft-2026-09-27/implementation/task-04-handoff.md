# Task 04 handoff — Q03 craft booth

## Files

- `roblox/mvp/server/activities/Q03.luau` — server-owned six-piece puzzle adapter bound to `CONTRACT.md`.
- `roblox/mvp/builders/Q03Station.luau` — edit-mode-only station builder requiring Task 01 anchors.
- `roblox/mvp/client/activities/Q03.luau` — touch/desktop control descriptor.
- `roblox/mvp/tests/Q03.spec.luau` — injected-clock state tests for placement, rotation, idempotence, and expiry.
- `docs/tickets/PCW-09.md` — MVP status and acceptance amendment.
- `docs/coordination/birthday-draft-2026-09-27/04-q03-craft.md` — design source.

## Exports and behavior

`Q03.new({session, actorResolver, clock, context})` returns the common adapter with `CreateRound`, `Apply`, and `GetView(actorUserId)`. Authenticated actor resolution is supplied by the server context; the module is not bound to the first actor. `Apply` supports `reserve`, `rotate`, `place`, `cancel`, and idempotent `finalize`; finalization stores one immutable presentation receipt after completion. `ExpireReservations` and `ReleaseActor` release unfinished work. Six canonical piece/socket IDs are exported as `Q03.PARTS` and `Q03.SOCKETS`.

`Q03Station.luau` uses the frozen builder API and only calls `context.SafeReplace("Q03", factory)`. The factory is detached and returns only its folder; replacement is owned by `MVP.Stations.Q03`. Required anchors and palette are validated before mutation, every authored BasePart receives provenance attributes, and the builder returns `{folder, manifest}` without relying on a second SafeReplace return value.

## Installation

The designated integrator must install the builder in Studio Edit mode only, after confirming Task 01's anchors and crossing clearance. The server/client modules require router binding by the integrator; this task did not edit `Main.server.luau`, `SessionService`, shared Config, or camera/Lighting.

## Tests/results

The Q03 test source uses an injected clock, trusted actor resolver, canonical string envelope IDs, numeric actorUserId, and mocked session boundary. The official Luau 0.740 compiler completed successfully for the Q03 server, client descriptor, and spec source. The spec includes invalid-envelope rejection, duplicate action idempotence, inactivity expiry, six-piece completion, and immutable finalization assertions. No Studio, device, group, route, replication, reconnect, palette-capture, or human-fun evidence is claimed.

The source repair preserves numeric authenticated `actorUserId` values, validates opaque IDs as strings, and passes `sessionId` through delegated step/completion calls.

The view now emits concrete executable actions for each available piece, owned reservation rotation/place/cancel actions, busy reasons for other reservations, and authorized finalization choices. `GetView` expires idle unfinished reservations; `ReleaseActor` accepts either one round or all active rounds. The standalone Luau runner cannot execute the spec because Roblox `script.Parent` module resolution is unavailable outside the test adapter; compilation remains successful.

Actual-source adapter rerun passed all 10 suites, including Q03 and the view-action traversal suite. Q03 server source hash: `D72B4E25EA406E6E5BA99FDF7F195BD4962DA85EE213BABC8F8E5557EAB8C4D3`.

## Dependencies and unresolved gates

- Corrected `roblox/mvp/CONTRACT.md` is required for final router binding and permission semantics.
- Task 01 must provide measured `Q03FairCraft` and `Q03BedroomDisplay` anchors and install the station.
- The integrator must connect player disconnect/session lifecycle to `ReleaseActor` and tick `ExpireReservations`.
- Independent verification must test 8–10 players, touch and desktop controls, live shared desk/booth state, crossing clearance, collision/pivots, and exactly-once progression receipts.
- The Q03 visual pieces are native procedural source geometry, not approved production art until Studio palette and visual review pass.
