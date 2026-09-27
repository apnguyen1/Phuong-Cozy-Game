# Draft 03 visual-polish builder handoff

Builder: `polish03` agent. Scope: [MAP-03](tickets/MAP-03.md), authorized by the user's September 27 request for more environment detail and visual polish. This handoff is source only. Studio installation, actual visual/route evidence, saved-place binding and independent review remain the coordinator/verifier's work.

## Submission

[build-polish03.luau](../roblox/build-polish03.luau) adds **618 BaseParts** beneath `Workspace.CozyWorld_Draft01.VisualPolish03`:

| Composition | BaseParts | Detail |
|---|---:|---|
| Arrival and porch | 164 | Four low beds, each with shallow soil, six pale edge stones, seven overlapping leaves and three stemmed five-petal flowers |
| Cottage windows | 76 | Two supported painted window boxes with soil, rims, trailing leaves and three flowers each |
| Quad sitting gardens | 164 | Four compact islands beside existing reading areas, outside cross/diagonal paths |
| Shops | 111 | Two compact planted pots and five small facade trim pieces per shop |
| Jasper rest corner | 103 | Two planted beds, a thin pale inset under/alongside the north bench and four five-part paw motifs |
| **Total** | **618** | Below the 750-part ceiling |

All geometry is native. Petals, leaves and soft profiles use untextured `SpecialMesh` spheres with independently sized parent parts, avoiding the uniform-ball silhouette problem. Variation is explicit and deterministic. The flowers alternate blossom/cream accents above forest/sage foliage with small golden centers; masonry pots and trim retain each shop's existing identity. Exact values come from `verification/palette.json`.

## Placement and preservation

The builder derives translation from `Home.Floor.Position - Vector3.new(-28, .12, -108)`; the reviewed map currently yields `(19, -0.1, -40)`. It never moves the world or changes old properties. Arrival sign, porch deck, both front window panes, shop `DoorCenter` attributes and the north park bench's actual seats supply local placement origins. The four Quad sites are fixed offsets in the original floor-anchor coordinate system, checked against the live route definitions before installation.

The complete stage is constructed without a parent. Its palette, instance classes, stable full paths, part budget, noninteractive flags, route gaps and reserved spaces must pass before an existing owned `VisualPolish03` folder is replaced. An ownership marker prevents replacing unrelated content with that name. The builder creates no script instances, meshes from external assets, textures, lights, prompts, seats or particles. Every added part is anchored, with `CanCollide`, `CanTouch` and `CanQuery` false. Existing scene descendants, source, lighting, community trees, furniture, doors and routes are untouched.

Route checks use each part's conservative projected horizontal bounds against all live route definitions, preserving their full reviewed widths plus 0.55 studs on either side. A ten-stud arrival continuation, twelve-stud cottage approach, ten-stud park gates, nine-stud shop approaches and the park's central fetch rectangle are also protected. These checks concern the added decoration; the original shop sources explicitly describe **7.6-stud openings**. This pass leaves those existing openings unchanged while reserving nine studs free of new decor around each approach. It does not claim to widen or certify an eight-stud physical opening.

## Review priorities and limits

- Check flower/leaf silhouettes, both window-box mounts and foliage against the actual window sills from player height; verify no stems, boxes or beds float or visibly intersect existing objects.
- Check the low plantings preserve arrival sign readability, the porch bench, the cottage door's swing/prompt and eight-stud entrance. Check the shops from the clear sidewalk and walk their existing entrances normally.
- Check each Quad island against the original reading benches, book tables and nearby blossom trunks/crowns. The source uses conservative path checks, but visual overlap with original props still needs actual Studio views.
- Check the park inset and paw motifs are visually flush with the terrain and north bench, both gates stay clear and fetch space stays open. The pale inset is decorative and does not change the bench seat/support collision.
- Run the builder a second time and compare the entire original scene against its baseline. Recount/capture the new folder independently and check normal-speed routes and low graphics after installation.

This source handoff supplies no self-approval, human acceptance, hardware-performance claim or fabricated Studio results. Existing unresolved physical touch/device/reconnect checks carry forward. No personal birthday note content was written, and no publishing is requested.

## Integration refinements

The coordinator installed the staged builder successfully and repeated it without duplicating the owned folder. The first independent live comparison found all 7,124 original objects and all eight script sources/disabled flags exactly equal to the pre-install baseline. The brackets in that installed version already reached the wall; closer inspection prompted a visual refinement, not a claim that the live boxes were unsupported. The box bases were moved 0.6 studs toward the wall, and the flower origins were moved 0.48 studs toward the box fronts to clear the original projecting wood sills. Final close views and a lower-graphics park view are recorded in the Draft 03 evidence folder. Current Studio capture and saved artifact binding belong to the independent review packet.
