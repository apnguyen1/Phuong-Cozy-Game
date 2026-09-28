# Task 12 — Grass decoration and outer Quad trees

Status: implementation-ready design draft only. This document does not authorize Studio edits, asset import, publishing, or approval.

## Scope and authority

This pass owns the continuous lawn's restrained material/detail treatment, small noninteractive grass-edge decoration, and additional trees outside the existing Quad interior. It must leave the existing Quad cross, paired diagonal panels, perimeter paths, interior trees, benches, signs, destination links and activity footprints unchanged. Task 10 owns Seattle-inspired perimeter facades; Task 11 owns lighting. The existing `QuadPlanting` community-tree textures remain the only approved texture exception: bark `rbxassetid://740989141` on `TextureID` and foliage `rbxassetid://4668043207` on `ColorMap`, only beneath the existing `Workspace.CozyWorld_Draft01.QuadPlanting` path. This draft does not extend that exception.

Confirmed direction: the Quad remains a connected blossom landscape, readable at night and usable by up to ten participants. The eight-color palette is authoritative: forest `#365744`, sage `#A8B995`, cream `#F5F0E4`, wood `#95674B`, blossom `#E8B7C6`, brick `#B66C68`, golden `#E8C779`, ink `#26382E`.

The following are proposed defaults, not separately user-approved facts: one native sage lawn base; a small number of low grass clumps; six to ten outer trees; a 250-new-BasePart local budget and 500-part shared MAP-03 budget reserve. Final counts and coordinates require a fresh Studio measurement of the reviewed place.

## Current source observations and non-duplication

Measured/source observations (not claims about the currently installed live Studio place):

- `roblox/build-quad02.luau` authors `QuadPlanting`, the route network, 21 cherry trees, four reading benches, seven flower beds and signs. Its tree points include interior and outer-world positions; this task must not re-author or move them.
- `roblox/build-polish03.luau` currently stages `VisualPolish03` with ten low planting beds, two cottage window boxes, six shop planters, three facade accents and Jasper's rest corner, for an asserted 618 anchored parts. It does not own a new grass system or outer Quad tree layer.
- Existing Draft 02 evidence includes `quad-overview-final.png`, `quad-low-graphics-ground.png` and `quad-low-graphics-aerial.png`; these are visual baselines only. They do not prove current coordinates, mobile performance, collision, or the next revision's appearance.

Before implementation, capture the current Edit-model hierarchy and positions of `Landscape.QuadGround`, `Paths`, `QuadPlanting`, route definitions, benches, signs, destination anchors, `VisualPolish03`, all doors/gates and the Q03/Q04/Q05/Q06 proposed anchors. Resolve world offset from `Home.Floor` as the existing scripts do; do not paste historical map coordinates into the live scene.

## Proposed geometry and material treatment

### Grass base

Keep the existing continuous lawn geometry and its sage token. Do not replace the Quad floor, alter path unions, or add a second terrain layer. If the current lawn is visually flat, use one of these bounded implementation options after inspection:

1. Preferred: keep the native sage material/color and add sparse, untextured, anchored low clumps made from native Parts/SpecialMesh spheres, tagged `GrassDecoration`, with no custom material variant.
2. If a native Roblox material is visually superior in Studio, test it on a duplicate preview region first, then retain the exact sage Color3 and record the material as a visual-review decision. It is not palette proof by itself.
3. Do not add a color-map, grass decal, foliage package, or external texture ID. A new texture exception requires a separate explicit user decision and updated verification evidence.

Grass clumps should be 0.15–0.45 studs high, 0.35–0.9 studs wide, in irregular groups of 3–7 blades/leaves. Use forest for the darkest blades and sage for secondary blades; reserve blossom/cream/golden for occasional existing-style flower accents, not a carpet. Place groups only in lawn pockets at least 1.5 studs from route edges and 2 studs from benches, doors, gates, interaction stations and arrival/cake approaches. Avoid repeating a fixed grid pattern.

### Outer-edge trees

Add trees only beyond the existing Quad interior boundary, as a separate replaceable folder such as `QuadOuterTrees12`. A tree is eligible only if its trunk center is outside the measured interior lawn/path envelope and outside every activity/arrival footprint. Preserve open sky above the Quad; trees frame the neighborhood rather than forming a wall.

Proposed starting arrangement, expressed relative to measured anchors rather than hard-coded world coordinates:

| Site | Relative rule | Proposed count/height | Purpose |
|---|---|---:|---|
| North-west outer edge | 10–14 studs outside the north perimeter path, staggered 8–12 studs apart | 2 / 14–17 studs | Frame Quad from cottage approach without hiding porch/sign |
| North-east outer edge | 10–14 studs outside the north perimeter path, stop before the dog-park link | 2 / 13–16 studs | Soft edge toward park; retain gate sightline |
| South-west outer edge | 10–16 studs outside the south perimeter, away from UDistrict crossing | 1–2 / 14–18 studs | Hide unfinished edge while leaving crossing legible |
| South-east outer edge | 10–16 studs outside the south perimeter, outside patio/food route | 1–2 / 14–18 studs | Frame distant view without covering patio seating |
| Far side framing, if needed | Only where a measured facade gap remains; never on a route | 0–2 / 12–16 studs | Optional completion of silhouette |

The proposed total is 6–10 trees, with a later Studio measurement deciding exact count. Use the existing approved community-tree model only if it is cloned without modifying the original and remains within its existing exception scope; otherwise use untextured native geometry in the eight-color palette. New trees must not silently reuse the exception outside `QuadPlanting`. Tree trunks should remain noninteractive decoration unless a measured collision test demonstrates a clear, intentional obstacle outside routes; the preferred new tree collision is disabled, with any visual trunk collider excluded from the decorative budget and reviewed separately.

Every tree record must include a stable name, anchor-relative X/Z offset, height/scale, yaw, nearest protected route, minimum route gap, and reason for placement. No tree may intrude into a route's half-width plus 1.5 studs, an 8-stud door/gate approach, a 10-stud principal entry lane, a bench's approach/usable-space cone, or any Q01–Q06 station footprint. Canopies must be checked at player height and from group-photo views; low branches cannot cover signs, the Quad reading benches, crossing, Q03 booth, Q04 benches, Q05 vending machine, Q06 counters, patio seats, Jasper's fetch lane, or the bedroom arrival view.

## Player sequence and simultaneous roles

This is static decoration, so there is no quest round or reward state. A player sequence is nevertheless required for implementation review:

1. Arrive inside the existing bedroom and walk toward the Quad using the unchanged destination route.
2. Approach the Quad from each available link: cottage/arrival, UDistrict crossing, dog park, and birthday courtyard.
3. Walk the central cross, both diagonal panels, and both perimeter directions at normal speed while looking around with an independent camera.
4. Visit Q04's existing reading benches and then continue toward the patio/cake seating without touching or being blocked by decoration.
5. Repeat with eight, then ten avatars distributed across routes, benches and views; no decoration changes state.

Useful concurrent roles for a ten-player rehearsal: two traverse the central cross, two traverse diagonals, two approach from cottage/arrival, two approach from UDistrict/food, one checks dog-park/fetch clearance, and one checks patio/cake sightline. Rotate roles, including touch players, so no single route is judged from one camera only.

## Controls, state, permissions, cancellation and reconnect

No new input, prompt, GUI, server state, permission, queue, replay or reconnect behavior is introduced. Grass and trees are anchored, noninteractive visual objects: `CanCollide=false`, `CanTouch=false`, `CanQuery=false`, with no scripts, seats, prompts or ClickDetectors. Existing doors, stations, benches and activity permissions remain authoritative. Joining, leaving, canceling, replaying, disconnecting and rejoining must leave this decoration unchanged and must not reset shared session progress. Desktop orbit/movement and Roblox touch movement/camera must expose the same traversable routes; device-specific decorative toggles are not proposed.

## Dependencies and interfaces

- Task 01 supplies measured anchor names/footprints, especially `Q04QuadReading`, `Q03FairCraft`, `Q05UDistrictVending`, `Q06FOBCounter`, `Q06AladdinsCounter`, `FinalePatio`, `GameplayBedroomArrival`, and route clearances. Until delivered, use the source route definitions and flag every coordinate as provisional.
- Task 10 supplies facade extents and open-sky sightline requirements. Outer trees must not become a substitute facade or conceal facade entrances.
- Task 11 supplies nighttime exposure checks; it owns lights and must not be asked to compensate for dense foliage.
- Task 09 and Q01–Q06 owners consume no new gameplay interface. Their station footprints and camera sightlines are regression inputs only.
- MAP-03 owns the shared 750-part `VisualPolish03` budget and replaceable-folder rule. If grass is placed in that folder, the existing 618-part assertion and ownership string must be revised by the integrator; preferred alternative is a separately counted `QuadOuterDecor12` folder with an explicit combined budget.

## Acceptance scenarios and expected outcomes

1. **Hierarchy and ownership:** capture the reviewed Edit model before and after. Expected: original `Paths`, `QuadPlanting`, lawn, benches, signs, doors, gates and activity parts have identical instance paths/transforms; only the assigned replacement folder is new.
2. **Palette/material evidence:** capture every new BasePart's PaletteToken, Color3, Material, texture properties and source path. Expected: native colors use only the eight tokens; no new albedo/color-map IDs; the existing two tree IDs appear only under the already approved `QuadPlanting` scope.
3. **Budget:** count new anchored BaseParts and meshes. Expected: grass/outer-tree pass is at most 250 new BaseParts (proposed), and MAP-03's combined authored budget remains at most 750 after the integrator resolves folder ownership. Any tree asset with extra hidden parts is included in the count.
4. **Route regression:** overhead and player-height captures plus normal-speed traversal cover central cross, four diagonals, perimeter, arrival, UDistrict, dog park and patio. Expected: continuous lawn remains readable; no tree/clump enters route clearance or causes a snag.
5. **Landmark sightlines:** from bedroom arrival, Q03 crossing, Q04 benches, Q05 vending, Q06 counters, Jasper fetch area and patio seats, rotate the independent camera. Expected: required station, sign and destination remain visible/readable; outer trees frame rather than occlude.
6. **Eight/ten-player safety:** place eight and ten avatars at the listed concurrent roles. Expected: no pile-up, blocked approach, canopy camera collision, or forced movement; decoration remains static and noninteractive.
7. **Low graphics and touch:** inspect Roblox low-graphics view and a touch-sized viewport, then traverse with touch and desktop controls. Expected: cross/diagonal composition and grass/tree silhouettes remain recognizable. This does not claim physical-device frame rate until PCW-16 evidence exists.
8. **Regression/recovery:** leave, rejoin, cancel/replay each relevant activity and reconnect during the shared birthday session. Expected: no decoration duplication, disappearance or state mutation; all existing progress behavior remains governed by the shared contracts.

## Required ticket, contract and evidence updates

Before implementation, update PCW-06 to distinguish preserved interior planting from this outer-edge additive layer, replace the historical fixed tree count with measured anchor-relative evidence, and state that new trees cannot inherit the existing texture exception. Update MAP-03/MAP-02 with the separate folder owner, combined part-budget accounting, original-hierarchy transform comparison, and exact no-new-texture rule. Update verification contracts for PCW-06, MAP-02 and MAP-03 to require the new folder path, part count, palette/material/texture capture, route clearance, landmark sightlines and low-graphics evidence. Task 01's anchor/footprint contract must include the outer Quad envelope and tree keepouts; Task 13's review matrix must assign these checks to an independent reviewer. Do not mark screenshots as production-ready art or as proof of Studio import, physical device performance, group play, or final user acceptance.

## Bounded later implementation checklist

1. Re-read the latest coordination packet and obtain a fresh Edit-model checkpoint; hash the prior place and preserve Draft 02 evidence.
2. Measure lawn/path envelope, route widths, station footprints, gates, benches, signs, facade edges and world offset. Record anchor-relative candidate tree sites.
3. Inspect existing `VisualPolish03` and `QuadPlanting` descendants so no bed, planter, tree or exception is duplicated.
4. Prototype two or three grass-clump silhouettes using native untextured geometry and exact palette tokens; visually compare at player height and low graphics.
5. Place the minimum outer-tree set, then add only evidence-supported sites that improve edge framing without closing the sky or sightlines.
6. Run static assertions for folder ownership, stable names, noninteractive flags, palette, no textures, count and route/keepout clearance before parenting the replacement folder.
7. Capture overhead, ground, landmark, group, low-graphics and texture/material evidence; run normal-speed route traversal with desktop and touch controls.
8. Hand the frozen source, place, captures and report to an independent verifier. Rework defects and retest; builder evidence is not approval.

## Unresolved choices and evidence limits

- Exact outer boundary, tree count, coordinates, scale and whether any existing outer trees already satisfy the framing need are unresolved until the current saved place is measured.
- Whether the final grass appearance should remain native sage SmoothPlastic/Ground or use another native Roblox material is unresolved; no external texture is authorized.
- The proposed 250-part local budget and 6–10 tree range are planning defaults, not user approvals. The integrator must reconcile them with MAP-03's 750-part total after inspecting all concurrent drafts.
- Current screenshots and source scripts show prior geometry but cannot establish the installed live Studio state, collision/query behavior, mobile frame rate, touch usability, ten-player performance, or human visual/fun acceptance.

