# Draft 03 independent review

Reviewer: independent verifier, separate from the builder and integration owner. September 27, 2026. **Status: READY_FOR_REVIEW. All 47 automatic checks pass; 13 independent criteria pass and 2 remain pending. The new revision has not been accepted by the user.**

The user authorized a third revision focused on **More environment detail and visual polish** after positive feedback and save/merge authorization for Draft 02. This review covers new static exterior decoration in `VisualPolish03`: arrival/porch/window-box planting, low lawn-edge clusters, storefront finishing and Jasper's rest-corner garden. It does not reopen or silently complete the prior lobby/device/reconnect review.

## Review plan

| Criterion | Required evidence |
|---|---|
| Visible improvement consistent with the warm stylized neighborhood | Actual before/after views from matching arrival, cottage, Quad, shop and park viewpoints; inspect silhouettes, density, color roles, intersections and landmark readability |
| Scoped, modest decoration | Source inspection plus independent live inventory of the owned folder; no more than 750 new native anchored, noncolliding parts; no new textures, scripts, prompts or lights |
| Exact native palette | Independent `VisualPolish03` capture checked against the approved eight colors; no texture exception for new work |
| Existing layout and behavior preserved | Before/after old-scene geometry and runtime-source comparison, preserved landmark locations, unchanged lobby/bedroom/doors/gates and retained blossom trees |
| Routes remain usable | Actual Studio Play walks through arrival-to-house, affected shop entrances/sidewalks, Quad edges and both park gates; no new camera or collision obstruction at decorated edges |
| Saved current artifact | Source/live provenance, production-only Draft 03 checkpoint, current views and console evidence, linked report and independent criterion decisions |
| New-revision acceptance | Actual user feedback on Draft 03; Draft 02 approval does not supply it |

No old runtime engine test will be rerun merely for static decoration. If source or scene evidence reveals a behavioral change, the affected checks must be reconsidered. Existing missing physical-touch completion, same-account reconnect, hardware performance and human gameplay/fun evidence remain documented facts; an unchanged script does not turn them into passes.

## Evidence status

The contract is being prepared while integration owns Studio. No live capture, saved Draft 03, actual route regression or independent visual verdict has yet been claimed. Defects will record criterion, expected/observed result, reproduction, evidence, suggested fix and owner.

This initial preparation status is superseded by the dated observations below as evidence becomes available; it is retained as review history.

## Source preflight

The submitted builder constructs an unparented stage, derives translation from the current cottage floor, and reads existing sign/window/door/bench landmarks. It validates native classes, exact colors, stable names, the 750-part budget, noninteractive flags, conservative route clearance and protected approaches before replacing only a recognized owned `VisualPolish03` folder. Source inventory predicts 618 BaseParts; actual installation and independent capture must confirm that count. No production runtime or original scene mutation was found in the reviewed source.

The first temporary walking helper stopped on horizontal distance alone. The reviewer requested grounded/floor-height observations before accepting actual routes, preserving the earlier three-stud floor-error criterion rather than repeating the prior mid-jump sampling problem. This is a test-evidence concern, not a confirmed map defect.

All four supplied baseline views were inspected. The existing street openings, broad Quad lawn/cross/diagonals, house frontage and open park establish the comparison. The ticket now distinguishes the eight-stud outside approach reserved from new decoration from the unchanged inherited 7.6-stud shop opening; this visual pass does not widen that doorway.

## First independent live review

Read-only Edit capture after installation found **618 BaseParts**, 602 other owned instances and no color textures. Every new part is anchored, with collision/touch/query disabled; native class, sphere-mesh and unique-path checks pass. The original **7,124 objects match their baseline exactly for every captured field**, and all **eight script sources/classes/disabled flags match exactly**. These results come from independently executed captures, not the builder's success message. Their fields include original transforms, sizes, material/color, collision flags, meshes, text and prompts; uncaptured service settings are not implied by this comparison.

Matching arrival, house, street and park before/after images show restrained low beds, cottage boxes, storefront pots/trim and a planted park corner while preserving open lawn and the major paths. Close player-height views and actual walking remain necessary before the visual/access criteria can pass.

**V03-001 — Window-box mounting refinement.** Criteria: MAP-03 AC01/AC08, convincing cottage detail without apparent floating. Expected: clearly supported boxes integrated with the wall below the sill. Observed: the first installed box backs sit approximately 0.69 studs ahead of the wall. Independent live measurements also show 1.75-stud-deep brackets reaching the wall by approximately 0.055 studs, so the suggestion that the actual brackets float is **not confirmed**. Reproduction: view the new east/west boxes from the porch side and inspect bracket/box depth. Evidence: retained `polish-studio-colors-iteration01.json` and the initial house view, later replaced by the final `house-after.png`. Suggested refinement: bring the boxes nearer the wall while retaining support, flower clearance and existing window geometry. Owner: integration. **Visual refinement verified:** `window-detail.png` shows the closer supported box. Flower origins were also moved forward within the box to keep stems in front of the original sill. Final independent geometry capture remains pending.

The new player-height/detail views (`arrival-player.png`, `window-detail.png`, `shop-detail.png`, `park-detail.png`) show readable low flower/leaf silhouettes, clear approach lanes and park paw motifs without a prominent new intersection. The earlier baseline street's interior-board first-frame text rendering issue is not attributed to new decoration; the original text instances are unchanged.

**V03-002 — Effective low-graphics setting needs verification.** Criterion: MAP-03 AC08, lower-graphics silhouette inspection. Expected: capture while Studio uses a documented low quality setting. Observed: the first `low-graphics-park.png` manifest records only `Rendering.QualityLevel=Level01` in Edit, which does not establish that Edit rendering was fixed to Level01. The [official RenderSettings documentation](https://create.roblox.com/docs/reference/engine/classes/RenderSettings) specifies EditQualityLevel with EnableFRM disabled for fixed Studio quality. Reproduction/evidence: inspect the initial visual-evidence manifest's setting and compare that property with the documented Edit control. Suggested fix: capture with EditQualityLevel=Level01 and EnableFRM=false, record both readbacks, then restore prior settings. Owner: integration. **Resolved:** the final image was recaptured with those settings and a one-second settle; manifest readbacks/restoration now identify the correct controls. Independent inspection confirms the nearby garden, bench and paw silhouettes survive while distant objects show culling. This is an evidence-setup correction, not a hardware-performance claim.

## Final scene and walking evidence

After Play stopped, a second full independent Edit capture again matched all 7,124 original objects and eight sources exactly, with no temporary scripts/remotes. The final new folder still contains 618 native parts, 602 other instances and no textures. The closer box back is approximately 0.09 studs from the wall, supported by the retained brackets. The captured source owner, part count and world translation agree with the builder; root DraftVersion is 03.

Independent recomputation from live CFrames, sizes and 20 route definitions plus the ten-stud arrival continuation found a minimum conservative route-border gap of **0.818727 studs**, above the builder's 0.55-stud reserve, with no encroachment. All seven approach/fetch keepouts are clear of new bounding boxes: a twelve-stud cottage approach, two ten-stud park gate approaches, three nine-stud shop approaches and the open fetch rectangle. These checks preserve approaches around existing geometry; they do not claim that inherited 7.6-stud shop openings were widened.

`navigation-results.json` records five actual normal-speed client routes with **46 grounded waypoints**: arrival/Quad/porch, bedroom entry/exit, western Quad and FOB/HeyTea entries, Aladdins and southern Quad, and both park gates/rest-corner approach. The reviewer recomputed every horizontal distance and height error from raw coordinates. All endpoints are within two studs horizontally and 1.5 studs vertically, with non-Air floor material, no seated state and health 100. Maximum observed height error is 0.305542 studs. WalkSpeed stayed 16; no teleport or speed change supplied these paths. The door's settled prompt becomes Close after actual E input; the immediate earlier Open read is recorded as asynchronous timing, not falsely treated as the final response. The actual Play camera remains Custom with the player's humanoid subject, and the post-route console query returned no messages.

The saved working place and numbered Draft 03 checkpoint are byte-identical: **1,648,676 bytes**, SHA256 `3e6d5fdbe8e0026a7c9367ebddbb6bf828b36cbce0770c9a2820e5644a541d66`. The save audit binds builder SHA256 `26d7943b4a44196ad76bd6ce371c5a2d6003cfa5af8e27f5a654a654736edef3`; it matches the reviewed source. The original reviewed Draft 02 checkpoint remains unchanged at SHA256 `c0d95754…`. This source/live/save provenance does not imply binary parsing or final user acceptance.

## Verification result

MAP-03's first report is `verification/runs/MAP-03/20260927T180310Z-799b211b/report.json`: **READY_FOR_REVIEW**, with 47 automatic checks passing. Its `agent-review.json` maps all independent criteria: **13 pass, 2 pending, 0 fail**. This new chain covers the explicitly requested static visual revision; it does not reset or rewrite MAP-02/PCW-17 history.

The pending shared-scope and full-scope review retain the known physical-touch, same-account reconnect, real-device experience and human playtest limitations. All ten specific visual-revision acceptance criteria have current evidence. No old lobby engine test was rerun for unchanged runtime code. No human approval, fun assessment, publication or finalization was fabricated. Draft 03 is saved locally and ready for the user's review.
