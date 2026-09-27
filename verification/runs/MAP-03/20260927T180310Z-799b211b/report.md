# MAP-03 — READY_FOR_REVIEW

Stage: production · Iteration 1 · 20260927T180310Z-799b211b

## Automatic checks

- **PASS** `ticket-approved`: Approved ticket required; a draft is not an assignment
- **PASS** `palette`: {'forest': '#365744', 'sage': '#A8B995', 'cream': '#F5F0E4', 'wood': '#95674B', 'blossom': '#E8B7C6', 'brick': '#B66C68', 'golden': '#E8C779', 'ink': '#26382E'}
- **PASS** `input:docs/tickets/MAP-03.md`: Required input exists
- **PASS** `input:docs/draft02-user-handoff.md`: Required input exists
- **PASS** `input:roblox/build-polish03.luau`: Required input exists
- **PASS** `input:roblox/build-draft01.luau`: Required input exists
- **PASS** `input:roblox/build-bedroom02.luau`: Required input exists
- **PASS** `input:roblox/build-quad02.luau`: Required input exists
- **PASS** `input:roblox/build-neighborhood02.luau`: Required input exists
- **PASS** `input:roblox/build-lobby02.luau`: Required input exists
- **PASS** `input:roblox/finalize-draft02.luau`: Required input exists
- **PASS** `input:roblox/birthday-lobby.server.luau`: Required input exists
- **PASS** `input:roblox/birthday-lobby.client.luau`: Required input exists
- **PASS** `input:roblox/draft-door.server.luau`: Required input exists
- **PASS** `input:roblox/evidence/draft03/save-audit.json`: Required input exists
- **PASS** `input:roblox/evidence/draft03/scene-invariants.json`: Required input exists
- **PASS** `input:verification/check_polish03.py`: Required input exists
- **PASS** `input:roblox/Phuong-Cozy-World-Draft02.rbxl`: Required input exists
- **PASS** `input:roblox/phuong-cozy-game.rbxl`: Required input exists
- **PASS** `input:verification/roblox/capture-polish03.luau`: Required input exists
- **PASS** `input:verification/roblox/capture-preserved03.luau`: Required input exists
- **PASS** `input:roblox/evidence/draft03/scene-baseline.json`: Required input exists
- **PASS** `input:roblox/evidence/draft03/runtime-baseline.json`: Required input exists
- **PASS** `input:roblox/evidence/draft03/scene-current-independent.json`: Required input exists
- **PASS** `input:roblox/evidence/draft03/runtime-current-independent.json`: Required input exists
- **PASS** `input:roblox/tests/polish03-walk-client.luau`: Required input exists
- **PASS** `input:roblox/capture-invariants03.luau`: Required input exists
- **PASS** `input:roblox/evidence/draft03/arrival-before.png`: Required input exists
- **PASS** `input:roblox/evidence/draft03/arrival-after.png`: Required input exists
- **PASS** `input:roblox/evidence/draft03/house-before.png`: Required input exists
- **PASS** `input:roblox/evidence/draft03/house-after.png`: Required input exists
- **PASS** `input:roblox/evidence/draft03/park-before.png`: Required input exists
- **PASS** `input:roblox/evidence/draft03/park-after.png`: Required input exists
- **PASS** `input:roblox/evidence/draft03/street-before.png`: Required input exists
- **PASS** `input:roblox/evidence/draft03/street-after.png`: Required input exists
- **PASS** `input:roblox/evidence/draft03/window-detail.png`: Required input exists
- **PASS** `input:roblox/evidence/draft03/park-detail.png`: Required input exists
- **PASS** `input:roblox/evidence/draft03/shop-detail.png`: Required input exists
- **PASS** `input:roblox/evidence/draft03/arrival-player.png`: Required input exists
- **PASS** `input:roblox/evidence/draft03/low-graphics-park.png`: Required input exists
- **PASS** `input:roblox/evidence/draft03/runtime-porch.png`: Required input exists
- **PASS** `artifact:place`: File present; format/import correctness is an independent review gate
- **PASS** `artifact:polish-colors`: {'parts': 618, 'tokens': ['blossom', 'brick', 'cream', 'forest', 'golden', 'sage', 'wood'], 'approved_texture_exceptions': [], 'note': 'All authored BasePart colors checked. Explicit approved texture exceptions are reported separately; other color textures still require verified sources. Capture provenance, GUI, materials and actual import require independent review.'}
- **PASS** `artifact:navigation`: File present; format/import correctness is an independent review gate
- **PASS** `artifact:views`: File present; format/import correctness is an independent review gate
- **PASS** `artifact:console`: File present; format/import correctness is an independent review gate
- **PASS** `test:captured-static-decor`: {'exit_code': 0, 'log': 'verification/runs/MAP-03/20260927T180310Z-799b211b/captured-static-decor.log', 'sha256': '230eca743df8098af6c47885c4d18be764c669cb9ee7e47e1397d88c6872bf63'}

## Required review

- `ticket-match` (independent): All ticket requirements and submitted source files are covered; the assigned object/activity was built, with no substituted scope.
- `shared-scope` (independent): Preserve touch/desktop access, independent third-person cameras, real group participation, one detailed bedroom, six quests and the empty user-authored note. No invented rooms, economy, forced cinematic or guest messages. Verify dependency interfaces and that automated tests exercise the actual ticket behavior.
- `visual-identity` (independent): Compare reference and actual result. Required silhouette, proportions, named features and color placement survive simplification; readability is clear at play scale.
- `roblox-import` (independent): Import this exact revision in Roblox Studio. Record place/model identity, scale, pivot, orientation, materials/textures, collision and console results; test it in context.
- `final-acceptance` (human): The user has reviewed this exact revision and explicitly accepted it as finished. Preserve their actual decision and comments.
- `MAP-03-AC01` (independent): Arrival-to-house views gain deliberate, layered low planting and cottage window-box detail; flowers and foliage have readable silhouettes and palette roles rather than unfinished generic masses.
- `MAP-03-AC02` (independent): Lawn-edge and sitting-area planting blends the broad Quad into adjacent destinations while preserving the continuous lawn, reference-based cross/diagonal paths and detailed community trees.
- `MAP-03-AC03` (independent): FOB Poke Bar, HeyTea and Aladdins retain their order and readable identities while receiving modest doorstep/planter/trim finishing details.
- `MAP-03-AC04` (independent): Jasper's park gains a finished planted rest corner and small paw motifs, with both gates, benches and the central fetch area visibly clear.
- `MAP-03-AC05` (independent): Existing authored geometry, materials, textures, collisions, seats, doors, spawn/destination positions, room layout and runtime source remain unchanged. The user's world offset is derived from the current home anchor.
- `MAP-03-AC06` (independent): New decor lives in one replaceable VisualPolish03 folder, has unique stable names, exact palette tags/colors, and at most 750 anchored BaseParts. New decorative parts have CanCollide, CanTouch and CanQuery disabled. No runtime scripts, external textures, extra lights or particles are added.
- `MAP-03-AC07` (independent): New decor reserves at least eight studs of clear width on outside door/gate approaches and the principal entry lane remains at least ten studs clear. Existing 7.6-stud shop door openings are preserved; this criterion does not claim they are widened. Actual normal-speed movement and camera views verify that planting does not hide access, wayfinding or required interactions.
- `MAP-03-AC08` (independent): Actual Studio views at player height and a wider view show a coherent improvement without floating/clipping decorations, intrusive repetition, obstructed signs or crowded walking space. Lower-graphics inspection preserves the principal new silhouettes; it does not claim hardware performance.
- `MAP-03-AC09` (independent): The working place and numbered Draft 03 checkpoint are saved locally, source and evidence are bound to this revision, and the original reviewed Draft 02 checkpoint remains intact.
- `MAP-03-AC10` (independent): An independent reviewer checks this scope and records specific defects/corrections. The user's previous Draft 02 feedback is not treated as acceptance of Draft 03.
- `MAP-03-scope` (independent): Deliverable: An editable Draft 03 place and repeatable static-detail builder, with actual Studio before/after views, palette and preservation evidence, relevant route checks and independent review. Improve the approved warm stylized neighborhood without changing its layout or gameplay.
Limits/open decisions: No new activities, economy, rooms, brands, guest messages or personal birthday note. Keep the approved community-tree texture exception scoped to the original two IDs under QuadPlanting. Physical device performance, touch completion and same-account reconnect are carried forward as unverified; this static visual pass does not silently certify them. No Roblox publishing is requested.
Validation: Follow verification/README.md: build, inspect actual Studio output, check, independent review, user playtest. Use a new MAP-03 review chain for this explicitly requested new visual scope, not a reset of MAP-02's exhausted iteration chain. Compare all original BaseParts with the prior captured baseline, verify runtime source and landmarks, capture the new folder's palette, verify its native-detail budget and noncolliding flags, and test relevant walking routes. Reuse prior evidence only for unchanged facts and identify that provenance clearly; do not rebind old runtime packets to a new place hash.

Fix failed checks, gather missing evidence, then create a new iteration. READY_FOR_REVIEW is not final acceptance.
