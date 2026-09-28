# Task 10 implementation handoff — Seattle perimeter

## Delivered files

- `roblox/mvp/builders/SeattleBoundary.luau`
- Design source: `docs/coordination/birthday-draft-2026-09-27/10-seattle-boundary.md`

## What the builder does

`SeattleBoundary.luau` returns the standard Edit-mode builder function `function(context)`. The integrator supplies `Root`, `MVP`, resolved `Anchors`, exact `Palette`, and `SafeReplace`. It is idempotent native geometry and:

- Requires the injected `MVP` and resolves the Task 01 marker vocabulary from the injected anchor map, with a direct-marker fallback for the current foundation.
- Refuses to proceed while required live anchors are marked `UNRESOLVED_LIVE_ANCHOR`; it does not guess old map coordinates.
- Derives the perimeter from the current `CozyWorld_Draft01:GetBoundingBox()` at install time.
- Calls injected `SafeReplace("SeattleBoundary", factory)` so replacement is limited to its own folder and follows the shared integrator lifecycle.
- Creates west, north, east and south shallow facade rows, four natural street terminators, and two compressed skyline cues under the exact owned folder `SeattleBoundary`.
- Uses only the eight approved palette values, native parts, and no external asset IDs, textures, scripts, lights, particles, NPCs, doors, or playable interiors.
- Sets all owned parts anchored with `CanCollide`, `CanTouch`, and `CanQuery` disabled. Any physical invisible world boundary remains the integrator’s responsibility.
- Writes source, ticket, policy, world-bounds, part-count and per-token metadata for later capture.
- Enforces the proposed 250 BasePart cap before parenting the staged folder.

## Installation ownership

Task 01/designated integrator must require/import this module and invoke it in Studio Edit mode on a copied local Draft 03 place after resolving the required live anchors. This worker did not start Studio, alter a place, change camera/lighting, save a checkpoint, publish, or upload assets.

## Checks implemented in source

- Edit-mode assertion.
- Required-anchor existence and unresolved-anchor rejection.
- Recognized-folder replacement guard.
- Exact palette and `PaletteToken` equality.
- Anchored/noncolliding/non-touch/non-query requirements.
- No Lua source containers beneath the owned folder.
- Proposed 250-part bound.

## Actual tests/results in this handoff

- Read-only source inspection: PASS for file scope and required ownership paths.
- PowerShell file/status inspection: PASS; the builder and handoff are present as new files.
- Contract inspection: PASS; returns `function(context)`, uses only `SafeReplace("SeattleBoundary", factory)`, returns `{folder, manifest}`, excludes `MVP` descendants from fallback bounds, and tags every authored BasePart with required provenance.
- Source hash (current builder): `76B6827E49000B1C6486EAF519501157FF9BC0C81811A0A12AA188A0D73B4EA3`.
- Luau compiler check: PASS with `verification/mvp/tools/luau-0.740/luau-compile.exe`; exit code `0`. This is source compilation only and does not replace Studio installation or play validation.
- Budget correction: the integrator observed 254 generated BaseParts in the prior install attempt. Removed one nonessential marker cube from each of four natural terminators, reducing the deterministic source count to 250 while preserving all facade rows, terminator walls/caps, skyline cues, palette, and open-sky geometry.
- Studio installation: NOT RUN; live anchors are not resolved in this chat and Studio mutation belongs to Task 01/integrator.
- Route, sightline, 360-degree camera, jump/zoom, ten-avatar, low-graphics, touch/device and night-lighting checks: NOT RUN.
- Independent verification and human acceptance: NOT RUN.

## Integration dependencies

- Bind to `roblox/mvp/shared/Anchors.luau` and the eventual live marker placement from Task 01. Do not replace marker positions from this builder.
- Preserve `roblox/mvp/CONTRACT.md`; this environment module has no session or activity API.
- Coordinate with Task 11 for lighting/window-glow treatment and Task 12 for outer planting. Neither should add geometry inside this owned folder.
- Task 13 should inspect existing route, station visibility, camera and 8–10-player behavior after installation.

## Known unresolved gates

The final facade geometry, current live world bounds, safe setback from every route/station, sky exposure, and skyline readability are unverified until Studio installation. The proposed 250-part budget is enforced by source but is not a hardware-performance claim. No production-ready or final-approved status is asserted.

## Changes made outside Task 10 ownership

None. No original tickets, contracts, Studio place, lighting, camera scripts, or shared runtime files were edited.
