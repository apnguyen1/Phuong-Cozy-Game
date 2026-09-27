# MAP-02 — BLOCKED

Stage: production · Iteration 1 · 20260926T200503Z-1f754b59

## Automatic checks

- **PASS** `ticket-approved`: Approved ticket required; a draft is not an assignment
- **PASS** `palette`: {'forest': '#365744', 'sage': '#A8B995', 'cream': '#F5F0E4', 'wood': '#95674B', 'blossom': '#E8B7C6', 'brick': '#B66C68', 'golden': '#E8C779', 'ink': '#26382E'}
- **PASS** `input:docs/tickets/MAP-02.md`: Required input exists
- **PASS** `input:docs/tickets/PCW-04.md`: Required input exists
- **PASS** `input:docs/tickets/PCW-05.md`: Required input exists
- **PASS** `input:docs/tickets/PCW-06.md`: Required input exists
- **PASS** `input:docs/tickets/PCW-17.md`: Required input exists
- **PASS** `input:docs/bedroom02-notes.md`: Required input exists
- **PASS** `input:docs/neighborhood02-notes.md`: Required input exists
- **PASS** `input:docs/lobby02-notes.md`: Required input exists
- **PASS** `input:roblox/build-draft01.luau`: Required input exists
- **PASS** `input:roblox/prepare-assets.luau`: Required input exists
- **PASS** `input:roblox/build-bedroom02.luau`: Required input exists
- **PASS** `input:roblox/build-lobby02.luau`: Required input exists
- **PASS** `input:roblox/build-neighborhood02.luau`: Required input exists
- **PASS** `input:roblox/build-quad02.luau`: Required input exists
- **PASS** `input:roblox/build-blossom-template02.luau`: Required input exists
- **PASS** `input:roblox/finalize-draft02.luau`: Required input exists
- **PASS** `input:roblox/birthday-lobby.server.luau`: Required input exists
- **PASS** `input:roblox/birthday-lobby.client.luau`: Required input exists
- **PASS** `input:roblox/draft-door.server.luau`: Required input exists
- **PASS** `input:roblox/draft-camera.client.luau`: Required input exists
- **PASS** `input:art/references/map/draft02-reference-quad.png`: Required input exists
- **PASS** `input:art/references/map/draft02-reference-bedroom-a.jpg`: Required input exists
- **PASS** `input:art/references/map/draft02-reference-bedroom-b.jpg`: Required input exists
- **BLOCKED** `artifact:place`: Missing or empty artifact: roblox/Phuong-Cozy-World-Draft02.rbxl
- **BLOCKED** `artifact:studio-colors`: Missing or empty artifact: roblox/evidence/draft02/map-studio-colors.json
- **BLOCKED** `artifact:navigation`: Missing or empty artifact: roblox/evidence/draft02/navigation-results.json
- **BLOCKED** `artifact:console`: Missing or empty artifact: roblox/evidence/draft02/console.txt
- **BLOCKED** `artifact:views`: Missing or empty artifact: roblox/evidence/draft02/visual-evidence.json

## Required review

- `ticket-match` (independent): All ticket requirements and submitted source files are covered; the assigned object/activity was built, with no substituted scope.
- `shared-scope` (independent): Preserve touch/desktop access, independent third-person cameras, real group participation, one detailed bedroom, six quests and the empty user-authored note. No invented rooms, economy, forced cinematic or guest messages. Verify dependency interfaces and that automated tests exercise the actual ticket behavior.
- `visual-identity` (independent): Compare reference and actual result. Required silhouette, proportions, named features and color placement survive simplification; readability is clear at play scale.
- `roblox-import` (independent): Import this exact revision in Roblox Studio. Record place/model identity, scale, pivot, orientation, materials/textures, collision and console results; test it in context.
- `final-acceptance` (human): The user has reviewed this exact revision and explicitly accepted it as finished. Preserve their actual decision and comments.
- `MAP-02-AC01` (independent): The live model replaces the Draft 01 bare store masses, empty bedroom and birthday/park/perimeter reservations with recognizable decorative compositions and surface detail.
- `MAP-02-AC02` (independent): The Quad preserves the reference's main cross and paired diagonal panels over continuous landscape, with usable arrival/cottage/street/park/courtyard links.
- `MAP-02-AC03` (independent): Exactly one cottage room reflects both bedroom photos, including opposed bed/light and desk/shelf walls and recognizable key personal objects.
- `MAP-02-AC04` (independent): The bedroom retains entry/station clearances, a working front door, low-graphics readability and usable circulation for 4–6 visitors.
- `MAP-02-AC05` (independent): Three stores read FOB, HeyTea and Aladdins north to south; FOB is clearly FOB Poke Bar, and Aladdins refers to the UDistrict Ave restaurant.
- `MAP-02-AC06` (independent): All three shops, sidewalks and crossings are traversable; decorated store identities read from player height.
- `MAP-02-AC07` (independent): The birthday courtyard has finished furniture, decorations, eight usable seats, table settings and cake; both dog-park gates remain clear around new furnishings.
- `MAP-02-AC08` (independent): Initial arrivals use an enclosed decorated lobby with the exact greeting Happy 24th Birthday, Phuong and recognizable favorite-things displays; PCW-17 supplies its runtime evidence.
- `MAP-02-AC09` (independent): Planting, materials, furnishings and decorations create a soft warm stylized world, without prominent unfinished temporary masses, floating objects or intersecting decorations.
- `MAP-02-AC10` (independent): Each authored BasePart has the correct exact palette token/color; imported color textures have actual verified source mappings; lighting, GUI and material response receive visual review.
- `MAP-02-AC11` (independent): The user's existing whole-world placement is preserved; sources reproduce the new work and the saved Draft 02 place matches the reviewed live revision.
- `MAP-02-AC12` (independent): Independent review uses current Studio evidence, relevant checks, specific defects and verified revisions; actual user fun/visual/final acceptance is preserved as pending until received.
- `MAP-02-scope` (independent): Deliverable: An editable local Draft 02 Roblox place, matching persisted builder/runtime sources, real Studio screenshots/palette capture, console/navigation evidence and independent review. Scope includes arrival/cottage exterior, one bedroom, continuous blossom Quad, FOB Poke Bar, HeyTea, Aladdins, dog park, birthday courtyard and birthday lobby. PCW-17 separately gates lobby runtime behavior.
Limits/open decisions: This environment and lobby request does not implement the future six quests, shop economy, NPC staff, animated Jasper, cake ceremony or personal birthday note. PCW-04/05/06 explicitly amend historical fair-block/fixed-footprint plans. No external publishing is requested. Exact photographic measurement and branded artwork are unnecessary; recognizable features, coherent finish and playable circulation remain required. An automated check cannot supply human acceptance.
Validation: Use build → check → independent review → user playtest → revise. Bind the three supplied references, relevant builder/runtime sources, independent live Edit-model palette capture, saved place, overview/ground/interior views and console/navigation logs. Review every destination and world continuity, including low settings and inherited visitor-clearance/group-view checks. PCW-17 covers timed entry, early pad, reset/rejoin, touch/desktop and concurrent players. Finalize only when all gates and genuine user acceptance exist.

Fix failed checks, gather missing evidence, then create a new iteration. READY_FOR_REVIEW is not final acceptance.
