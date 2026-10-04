# Task 10 — Seattle-inspired boundary and skyline draft

Status: implementation-ready design proposal only. This document owns the outer facade/backdrop ring, not the playable zones, roads, doors, Quad interior, trees, lighting, or runtime. It does not claim that the proposal is installed or tested in live Studio.

## Scope and authority

Confirmed direction: surround the existing playable neighborhood with a Seattle-inspired facade ring that hides unfinished edges while retaining an open night sky. The reference is an artistic compression of Seattle, not surveyed geography. Existing bedroom, UDistrict crossing/storefronts, Quad paths and blossom interior, patio, doors, routes, spawn/destination positions, and all gameplay remain authoritative.

The exact palette is Forest `#365744`, Sage `#A8B995`, Cream `#F5F0E4`, Wood `#95674B`, Blossom `#E8B7C6`, Brick `#B66C68`, Golden `#E8C779`, Ink `#26382E`. No new palette value or texture exception is proposed. Facades should use shallow, readable shells and repeatable modules; they are not extra playable interiors.

Measured/current evidence: Draft 03 reports 7,124 original objects preserved, 618 non-colliding polish parts, five walked routes, and the approved two-tree texture exception remains scoped under `Workspace.CozyWorld_Draft01.QuadPlanting`. Those facts describe the existing revision, not a completed Seattle ring. The earlier map dimensions are still proposals and must be derived from the current live anchors before construction.

Coordinator defaults used here (proposed, not separately user-approved): retain the compact map envelope around the current scene; use 8–10 player rehearsal targets; treat all boundary pieces as anchored visual-only geometry; and reserve a broad sky-facing upper band rather than closing the map with a roof or skybox wall.

## Desired player experience

Players read a cozy night neighborhood: low storefront and house edges nearby, compressed brick campus silhouettes farther away, one or two taller Seattle cues at the horizon, and open dark sky above. The ring should remove the feeling of an unfinished rectangular edge without making the world feel enclosed or turning the skyline into a destination.

No boundary segment should imply a door, quest, shop, road continuation, collision challenge, or hidden room. A street should visually terminate at a facade corner, planted wall, gentle dark service alley, or framed skyline gap; it must not end at a bright blank plane or a walkable-looking doorway.

## Proposed segment plan

Use current anchors and world bounds as inputs, not the old diagram coordinates. Each segment has a named visual owner and a 2–4 stud service gap behind the visible face for inspection/replacement where the existing scene permits it.

| Segment | Visual treatment | Sightline/route rule |
|---|---|---|
| West UDistrict outer edge | 1–2 story cream/brick facade rhythm behind the existing storefronts, varied awnings and masonry corners, with a few dark upper windows | Existing crossing remains the foreground landmark. Do not hide Q03 booth, Q05 vending approach, or the central pedestrian lane. No new shop door. |
| North of house/Jasper | Low cottage backs, rooflines, window glow and a distant evergreen/tree silhouette; one restrained taller roof shape | Bedroom exterior and Jasper yard remain readable from arrival. Keep both yard gates, fetch lawn and house approach visually open. No facade behind the bedroom camera at a distance that causes wall clipping. |
| East Quad edge | Simplified brick collegiate wings with spaced arch/window rhythm and a few gaps showing sky | Quad cross, diagonals, blossom rows and Q04 benches remain the composition. Do not alter protected Quad interior geometry or add an interior entrance. |
| Southeast patio edge | Low garden/service wall or warm facade band, with a darker skyline gap above it | Finale Patio remains visible and easy to enter from both approaches; preserve the ten-seat gathering sightline and cake/photo space. No roof or pergola extension owned by this task. |
| South/arrival edge | Low neighborhood frontage and a terminating corner that frames the sign and house view; facade height falls near the arrival | Do not compete with the birthday sign or queue square. Preserve ten arrival positions, the north-facing first view, and the route toward the house. |
| Inner UDistrict/central junction | Only small end-caps where existing streets need a visual conclusion: planter wall, corner facade, or banner support | Never narrow the 16-stud main route or 24-stud fair center. Crossing stripes, craft booth, Q05 machine and Q06 approaches remain unobstructed. |

### Height and setback proposal

These are bounded starting targets for a later blockout, not measured requirements:

- Near facade shells: 12–22 studs high, set back at least 8 studs from an outside door/gate approach and outside the current principal route clearances.
- Midground campus/warehouse masses: 22–36 studs high, visually behind the near shells and never placed in the player’s direct camera collision envelope.
- One or two skyline cues: 40–64 studs high, narrow and low-contrast, placed beyond the playable edge with a minimum 24-stud visual separation from the nearest route where the current scene allows.
- Keep the upper 35–45% of typical third-person views open to sky from arrival, the Quad center, patio, and house approach. This is a camera test target, not a measured current result.
- Setback must be recomputed from the current world bounding boxes and camera positions. Do not apply the map proposal’s `(320, 280)` envelope as if it were live coordinates.

## Player sequence and boundary states

1. On arrival, the player sees the birthday sign, house direction, open sky, and a low south facade terminating the view naturally.
2. Walking west, the player sees existing UDistrict storefronts in front of the facade ring; crossing and pedestrian route remain the obvious path.
3. Walking north, the player reaches the existing bedroom/yard landmarks; the boundary reads as a quiet neighborhood beyond, not a second route.
4. Crossing the Quad, the player sees blossom trees and protected paths first, with brick campus silhouettes behind them and sky above.
5. At the patio, the low edge frames the cake gathering without enclosing the ten-person group.
6. At every outer edge, the player encounters a visual stop: a noninteractive facade, planted edge, or dark service gap. There is no prompt, teleport, climb, or hidden collision puzzle.

Boundary states are static: `Visible`, `Camera-near`, and `Outside-playable-bounds`. `Camera-near` may use local transparency/fade only if needed to preserve the player’s view; it must not change another player’s camera. `Outside-playable-bounds` is a later collision/soft-boundary decision owned by the map/runtime integrator, not a new gameplay state here.

## Concurrent roles and safety

The ring must support ten avatars in the existing world. Facade modules are visual-only (`CanCollide`, `CanTouch`, and `CanQuery` disabled) unless an integrator documents a separate invisible outer boundary. Avoid narrow alcoves, low awnings, projecting signs, hidden steps, and repeated vertical posts that can trap or occlude avatars.

Useful simultaneous roles: one player can read the UDistrict crossing and craft booth, others can use the Quad routes, one can inspect the house/Jasper view, and the rest can gather at the patio. No segment may reserve a player slot or block a station. Preserve at least 16 studs on main garden routes, 12 studs at secondary/door targets, 24 studs in the fair center, and the existing 8-stud outside approach rule from MAP-03; confirm all against live geometry.

Touch, tablet, and desktop must use ordinary movement and camera orbit/zoom. No boundary interaction may require hover, precise clicking, a new UI panel, or camera lock. Near-wall camera tests must preserve independent third-person views and avoid forcing a fade that hides a quest station.

## Materials, assets, and proposed budget

Preferred construction is native Roblox parts or already-approved, source-recorded modules. A candidate asset is acceptable only after inspection for creator/source record, license, scale, pivot, bundled scripts, hidden prompts, textures, collision, palette mapping, and replacement ownership. No downloads/imports are authorized by this draft.

Proposed mobile-conscious starting budget for this task (must be measured after blockout):

- 12–18 reusable facade module families, instanced rather than uniquely modeled.
- 80–140 visible facade modules around the ring; 250 anchored BaseParts maximum for the ring itself, excluding existing world and Task 12 planting.
- 2 skyline cues maximum; 6–10 parts each if native, with no animated windows, particles, traffic, or NPCs.
- 0 new runtime scripts, lights, sound emitters, textures, or playable interiors.
- Treat the 250-part cap as a proposal; MAP-03’s 750-part cap applies to its `VisualPolish03` folder, not automatically to this future ring. The integrator must record the final count and device result before approval.

Use only approved palette roles: cream/brick/wood for facade identity, forest/ink for outlines and depth, sage for restrained trim, golden for sparse window warmth, blossom only as an existing-world echo. Do not use pale text on sage/pink/gold or make a facade readable only through green.

## Camera, jump, zoom, and route QA

For each segment, capture a before/after pair from the same player-height and wide third-person positions: arrival facing house, house facing arrival/yard, both sides of UDistrict crossing, Quad center and each diagonal, patio approaches, and an outer-edge stop. Record the current anchor/position rather than relying on diagram coordinates.

Acceptance tests for each segment:

1. Normal walking from both directions reaches every existing door, crossing, bench, booth, vending machine, food counter, patio approach, and yard gate without new collision or snagging.
2. Ten staggered avatars do not block the route or spawn/destination positions; no facade piece overlaps a protected keepout.
3. Rotate the camera 360 degrees, zoom near and far, and jump beside the segment on desktop and touch. The player, route, and nearest landmark remain readable; no facade fills the camera, clips through the avatar, or creates a forced camera change.
4. Look upward from arrival, Quad, house approach, and patio: the proposed sky band remains open; skyline cues frame rather than cap the view.
5. Walk to the visual stop. It reads as non-playable scenery without a misleading prompt, climbable ledge, visible unfinished backside, or route that appears accidentally blocked.
6. Inspect low graphics and a representative phone/tablet/laptop. The main silhouette survives, repeated modules remain legible, and the ten-player patio view does not claim performance until measured on hardware.

Per-segment before/after checklist: anchor used; facade height/setback; route width; nearest station visibility; camera/jump/zoom result; palette/source mapping; collision/touch/query flags; part/instance count; screenshot/log paths; defect and owner. Any failure returns the segment to revision rather than being hidden by camera fade.

## Completion, cancellation, replay, and reconnect

This is static environment work and has no activity completion or replay state. A later builder may replace the whole owned `SeattleBoundary10` folder before playtesting. Cancelled placement must leave the prior folder/world unchanged. A failed Studio import or partial integration must be removed/reverted by the integrator using the saved checkpoint, not by changing gameplay or teleport behavior.

Reconnect and late join are runtime responsibilities: a rejoining player must see the same boundary revision and current shared session; boundary geometry must not reset a queue, petal, fund, wish, or cake state. The ring must not depend on a player count or on all eight/ten participants being present.

## Interfaces and dependencies

- Task 01 supplies measured world anchors and protected footprint/approach names; this draft depends on it and must not invent replacements.
- Task 11 owns night lighting and any window-glow treatment; this task supplies only facade geometry/material roles.
- Task 12 owns outer Quad trees, grass and planting; coordinate gaps so foliage does not hide the facade’s route stops or expand the collision budget.
- Tasks 02–08 own activity stations, queue, arrival and destination behavior; their prompts, approaches, and camera rules must remain unchanged.
- Task 09 owns session progression and cake; the patio boundary cannot gate or trigger it.
- PCW-03 owns integrated geometry/camera validation; MAP-02 owns recognizable stores, patio, lobby and world continuity; MAP-03 owns static polish limits and preservation evidence.

## Required ticket/contract updates before implementation

- PCW-03: add a boundary/backdrop criterion covering natural street termination, open-sky camera exposure, 16/12-stud route preservation, ten-player obstruction checks, and 360-degree third-person camera tests.
- MAP-02: add Seattle-inspired outer facades/backdrop as shallow non-interior scenery; require existing UDistrict, house, Quad, patio, lobby and route landmarks to remain readable and preserve the scoped texture exception.
- MAP-03: clarify whether `SeattleBoundary10` is outside the 750-part `VisualPolish03` cap or receives a separately recorded cap; require noninteractive flags and no new scripts/lights/textures for this ring.
- PCW-16: add mixed-device ten-player evidence for arrival/UDistrict/Quad/patio skyline views, jump/zoom/camera obstruction, and low-graphics silhouette. Studio simulation alone remains insufficient for hardware performance.
- Verification contracts: add the owned folder/source files, exact palette subset, no-texture/script/light assertions, part-count check, protected landmark comparison, route widths, and per-segment screenshots/logs. Keep status `concept`/handoff until actual Studio and independent review evidence exists.

## Bounded later implementation checklist

1. Task 01 integrator measures current bounds, anchors, station keepouts, and camera sample positions in the live Draft 03 place.
2. Build one representative near facade, one campus wing, and one skyline cue in an isolated review area; verify palette, source, pivot, collision and camera behavior.
3. Place segment end-caps first and walk every route in both directions before filling repetition modules.
4. Add the five outer segments with stable names under `SeattleBoundary10`; keep modules replaceable and noninteractive.
5. Run per-segment before/after, route, ten-avatar, camera/jump/zoom, sky, low-graphics, and source/palette checks.
6. Have an independent verifier review the captured live Studio model; then run PCW-16 mixed-device/group rehearsal. Do not call the ring production-ready from document or automatic checks alone.

## Unresolved choices and evidence limits

The exact current outer bounds, facade count, skyline silhouettes, final height/setback, target low-end device, and whether a soft invisible world boundary is needed remain unresolved. The user has not approved a specific Seattle landmark, storefront wording, or skyline asset. Do not infer geography, add traffic, or choose a branded tower to fill the horizon.

No live Studio installation, mobile/tablet hardware test, ten-person group test, final lighting pass, or human visual/fun acceptance was performed for this draft. Existing Draft 03 route and preservation evidence cannot certify this unbuilt ring. The document is ready for the coordinator’s design integration review, not final approval.
