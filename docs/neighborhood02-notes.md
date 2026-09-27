# Neighborhood detail pass 02

Authoring source: [build-neighborhood02.luau](../roblox/build-neighborhood02.luau). Run in Studio Edit mode against `Workspace.CozyWorld_Draft01.SurroundingContext`. The file stages geometry in ServerStorage, checks the 1,500-part limit and palette/static contracts, then swaps only its own scope. Original store massing, dog-park/birthday reservations, and distant canopy balls move to `ServerStorage.BeforeNeighborhood02`. Existing street, sidewalk, crossings, central Quad, house, and gameplay scripts are preserved. Rerunning replaces `NeighborhoodDetails02`, not the original backup.

Every authored BasePart uses one of the eight approved palette colors and carries `PaletteToken`. Store roots carry `VerificationTicket=PCW-05`; surrounding decoration carries `MAP-02`. Native Roblox materials provide brick, wood, cloth, stone, glass, and paving detail without external texture dependencies. No runtime scripts or external model imports are added.

All coordinates below are first authored relative to Draft 01's original layout. The builder computes the current translation from `Home.Floor.Position - Vector3.new(-28,.12,-108)` and shifts only its newly constructed geometry and doorway markers. The integrating agent observed the user's offset `(19,-0.1,-40)`; the builder derives it again at run time rather than hardcoding it. Existing street/sidewalk/crossings stay in their current positions. Original park fences are replaced by the shifted rebuilt fences, preserving their two gates.

The west-to-east-facing storefronts retain their existing plots, with north-to-south labels **FOB**, **HeyTea**, and **Aladdins**. Each has a true 7.6-stud open doorway, transparent framed display glass, a transom, visible propped door leaf, striped fabric awning, roof coping, downpipes, projecting sign, warm lamps, interior counter/shelves/products, and functional café seating. Pocket patios sit beside the buildings. The road at X −134..−110 remains clear; fixtures retain the continuous sidewalk strip X −140..−134. The user clarified that FOB is FOB Poke Bar: its counter now has arranged rice/salmon/edamame bowls, chopsticks, ingredient jars, and a glass counter guard; a secondary sign reads `POKE BAR` while its main sign stays exactly `FOB`.

The birthday courtyard receives timber pergola slats, sagging string lights, pennant garlands, a bordered fabric rug, a tablecloth and runner, eight chairs with legs/backrests and working Seats, eight table settings, a tiered cake with 24 topper, a dessert sideboard, wrapped gifts, and potted greenery. This is decoration, not cake/quest gameplay. Jasper’s park keeps both western entrances and an open fetch lawn while adding two usable benches, a toy basket, loose balls, a water bowl, a small open agility hoop, and planted corners. Perimeter trees now have trunks, branches, several rotated overlapping crown lobes, and varied understory shrubs.

## Reference basis

- [Aladdin Gyro-Cery official website](https://www.aladdingyro.com/) identifies its location at 4139 University Way NE and mentions gyros, shawarma, and fries. [Its official menu](https://www.aladdingyro.com/menu) includes falafel. These support the small food props and concise interior board. The architecture is a stylized neighborhood interpretation; no claim of an exact façade recreation. The user-requested outer sign remains exactly `Aladdins`.
- [HEYTEA official website](https://www.heytea.com/) confirms the brand’s tea identity. Its text was not exposed to the research tool, so no specific menu, price, logo artwork, or location is asserted. The build uses the requested `HeyTea` lettering, generic tea cups, jars, and a `TEA` board.
- [FOB Poke Bar’s official site](https://fobpokebar.com/) and [official menu](https://fobpokebar.com/menu/) support rice, salmon, edamame, and the build-your-own-bowl counter identity. The user explicitly clarified this store identity during construction. Store proportions and architecture remain stylized.

## Integration and visual verification

The construction source passed a complete dry run in Luau with mocked Instance/workspace/service tables, without changing any Studio instance. That dry run produced **1,406 authored BaseParts**, passed syntax and construction-flow checks, and accepted all static/palette contracts. `Enum.Material.CeramicTiles` was independently confirmed in the active Studio API. The integrating agent still needs to execute the file with actual Instances, inspect the return count, and verify the rendered result. A dry run or successful build check alone does not prove visual quality.

Suggested viewport captures (camera → target), already adjusted for the observed `(19,-0.1,-40)` translation. If the anchor changes again, add the difference from that observed offset:

| View | Camera | Target |
|---|---|---|
| Three-shop street overview | `(-84, 25.9, 88)` | `(-130, 7.9, -36)` |
| FOB front | `(-101, 7.9, -136)` | `(-138, 6.9, -136)` |
| HeyTea front/interior | `(-106, 6.9, -33)` | `(-150, 5.9, -45)` |
| Aladdins front | `(-101, 8.9, 60)` | `(-141, 6.9, 56)` |
| Birthday table and pergola | `(103, 17.9, 57)` | `(140, 4.9, 21)` |
| Jasper’s park | `(85, 18.9, -102)` | `(149, 2.9, -130)` |
| Perimeter silhouettes | `(131, 20.9, -149)` | `(176, 14.9, -218)` |

Check and record actual outcomes:

- All three exterior names are legible from the street and face east; no reversed lettering or surfaces hidden by awnings.
- Walk through each doorway from the sidewalk, turn inside, and reach the counter. No invisible wall, raised threshold, or decorative prop blocks the route.
- Walk the uninterrupted sidewalk strip and all three crossings after the Quad path changes are integrated.
- Café, park, and celebration Seats orient avatars toward tables/lawn; chair backs and table legs do not trap players.
- Eight distinct Seats surround the birthday table; pergola beams/strings clear standing heads and cameras.
- The cake, tabletop settings, gift ribbons, signage, glazing, and fabric have no visibly flickering coplanar surfaces.
- Both park gates stay clear; dog-park props and perimeter planting do not block the updated Quad connections.
- Low camera shots retain the warm stylized approved direction; tree crowns do not read as one repeated untextured sphere.
- Verify `PartCount <= 1500`, no scripts inserted by this file, all authored parts anchored, and palette tokens present.

Known deliberate limits: no NPC shopkeepers, purchasing, doors that animate, food interactions, cake ceremony, Jasper animation, or faithful real-world shop-façade claim. The geometry is fully editable native Roblox construction. Place saving and multiplayer testing are owned by integration.
