# MAP-03 — Draft 03 garden detail and environment polish

**Status:** Implementation authorized September 27, 2026. The user approved merging Draft 02 and selected **More environment detail and visual polish** for revision 3. This is a new visual submission; Draft 02's review history and unresolved device checks remain preserved.

## Purpose

Make the approved neighborhood feel more finished through restrained native garden and facade detail while preserving its layout and interactions.

## Deliverable

An editable Draft 03 place and repeatable static-detail builder, with actual Studio before/after views, palette and preservation evidence, relevant route checks and independent review. Improve the approved warm stylized neighborhood without changing its layout or gameplay.

## Acceptance criteria

- Arrival-to-house views gain deliberate, layered low planting and cottage window-box detail; flowers and foliage have readable silhouettes and palette roles rather than unfinished generic masses.
- Lawn-edge and sitting-area planting blends the broad Quad into adjacent destinations while preserving the continuous lawn, reference-based cross/diagonal paths and detailed community trees.
- FOB Poke Bar, HeyTea and Aladdins retain their order and readable identities while receiving modest doorstep/planter/trim finishing details.
- Jasper's park gains a finished planted rest corner and small paw motifs, with both gates, benches and the central fetch area visibly clear.
- Existing authored geometry, materials, textures, collisions, seats, doors, spawn/destination positions, room layout and runtime source remain unchanged. The user's world offset is derived from the current home anchor.
- New decor lives in one replaceable VisualPolish03 folder, has unique stable names, exact palette tags/colors, and at most 750 anchored BaseParts. New decorative parts have CanCollide, CanTouch and CanQuery disabled. No runtime scripts, external textures, extra lights or particles are added.
- New decor reserves at least eight studs of clear width on outside door/gate approaches and the principal entry lane remains at least ten studs clear. Existing 7.6-stud shop door openings are preserved; this criterion does not claim they are widened. Actual normal-speed movement and camera views verify that planting does not hide access, wayfinding or required interactions.
- Actual Studio views at player height and a wider view show a coherent improvement without floating/clipping decorations, intrusive repetition, obstructed signs or crowded walking space. Lower-graphics inspection preserves the principal new silhouettes; it does not claim hardware performance.
- The working place and numbered Draft 03 checkpoint are saved locally, source and evidence are bound to this revision, and the original reviewed Draft 02 checkpoint remains intact.
- An independent reviewer checks this scope and records specific defects/corrections. The user's previous Draft 02 feedback is not treated as acceptance of Draft 03.

## Limits and open decisions

No new activities, economy, rooms, brands, guest messages or personal birthday note. Keep the approved community-tree texture exception scoped to the original two IDs under QuadPlanting. Physical device performance, touch completion and same-account reconnect are carried forward as unverified; this static visual pass does not silently certify them. No Roblox publishing is requested.

## Validation

Follow verification/README.md: build, inspect actual Studio output, check, independent review, user playtest. Use a new MAP-03 review chain for this explicitly requested new visual scope, not a reset of MAP-02's exhausted iteration chain. Compare all original BaseParts with the prior captured baseline, verify runtime source and landmarks, capture the new folder's palette, verify its native-detail budget and noncolliding flags, and test relevant walking routes. Reuse prior evidence only for unchanged facts and identify that provenance clearly; do not rebind old runtime packets to a new place hash.
