# Phuong's Cozy World — Roblox map design

Version 0.6 · September 26, 2026 · First arrival-to-house draft built

## Confirmed direction

- Carry Phuong's Cozy World into Roblox: house, Jasper's dog park, blossom Quad with outdoor minigame spaces, U District street, birthday celebration area, and arrival plaza with a 24th birthday sign.
- Follow the user's supplied sketch: house north-center; dog park northeast; birthday area southeast; arrival south-center; Quad center-left; U District along the west.
- Extend the blossom Quad into continuous landscaped grounds across the center, with the roads and paths overlaid on it. The center-left lawn retains the main minigame clearings; blossoms continue on both sides of the central route and between its eastern branches.
- Soft, stylized 3D with warm colors.
- Up to eight players, with real friends exploring together and independently rotatable third-person cameras.
- Outdoor Quad activities mix cozy activities and playful group games.
- Design each component separately, then blend the components into one coherent neighborhood.
- Start with free community assets. Decide on external 3D imports or custom modeling only after identifying a specific gap.
- Continue developing the design over multiple sessions, recording decisions and asset choices here.

Roblox is the current map target. Earlier Phaser/Tiled documents preserve the previous 2D concept; their pixel dimensions, scene architecture, and export contracts do not govern this map. Existing character art remains reference material. The personal birthday note stays user-authored, with no generated placeholder text.

The overall layout and first-draft construction are approved. The [detailed component studies](roblox-component-designs.md) develop all ten components, their furniture and activity layouts, entrance markers, asset strategy, and review criteria. An arrival-to-house draft is now built and saved locally using five inspected community assets and native geometry. See [Draft 01](roblox-draft01.md) for actual screenshots, implemented dimensions, the successful single-client walk/door test, and saved place files. Unbuilt component details remain proposals.

The first [arrival-to-house visual study](roblox-arrival-visual-study.md) illustrates the sign, open plaza, blossom approach, and cottage porch. The user accepted this visual direction on September 26. The [asset register](roblox-asset-register.md) now distinguishes preview-reviewed free candidates from the simple elements to build directly; individual models and measurements remain untested.

## Overall composition

A small, warm neighborhood organized around a pedestrian route from the arrival plaza in the south to Phuong's house in the north. The blossom Quad is the continuous green landscape beneath the central road/path network, extending from U District's inner promenade to the eastern destinations and around the arrival and home approaches. Its minigame clearings remain in the western lawn. Jasper's dog park sits to the right of the house, and the birthday celebration area sits directly below the park. U District forms the western edge.

The user's hand-drawn sketch is the current layout reference and supersedes the earlier northwest-house / northeast-Quad / southern-storefront arrangement. Interpretation for this draft: gray lines are pedestrian paths; the western boundary is the U District street/promenade; black outlines reserve component footprints rather than requiring solid walls. Exact curves, distances, planting, and the form of U District remain design proposals.

```text
 U DISTRICT       PHUONG'S HOUSE        DOG PARK
 street /              │                + JASPER
 promenade ────────────┼───────────────────┘
     │                 │
     │   BLOSSOM       ├────────── BIRTHDAY
     │   QUAD +        │           CELEBRATION
     ├── MINIGAMES ────┤               │
     │                 ├───────────────┘
     └─────────────────┤
                   ARRIVAL
               24TH BIRTHDAY SIGN
```

This is a fictional arrangement inspired by the user's sketch, not a geographical reconstruction of UW or the UDistrict. Main destinations connect in both directions. The central path supports easy orientation toward the house; western cross-paths and eastern branches create shorter loops. Optional discoveries occupy pockets beside these routes.

**Quad extension:** In the diagram above, the Quad now includes the green spaces around the central route and eastern branches, not only the labeled western lawn. Treat the landscape as the base layer and lay the paved routes across it at ground level. Roads divide the lawn into connected planting and activity pockets without becoming the outer boundary of the Quad. Keep the house, dog park, birthday area, and arrival plaza as distinct plots cut out of this shared landscape.

### Arrival and route sequence

1. **Arrival:** enter at the south-center plaza beside the 24th birthday sign, with a clear view north toward the house. A welcome sign is distinct from the personal birthday note, which remains user-authored.
2. **Choice of activity:** travel north through the blossom Quad, branch left into its minigame clearings, or right into the dog park or celebration area. U District can be reached by upper, middle, and lower western cross-paths. The connecting routes sit within the Quad landscape.
3. **Home:** the front door faces the arrival route. Keep the approach open enough to see the porch from the main junctions.
4. **Celebration:** the right-hand area is visible and visitable during exploration. Real friends play together throughout; cake and celebratory dressing can appear when the proposed finale becomes ready. A group gathering action is proposed before starting the cake moment. No new gate or forced activity order is implied.

The arrival plaza replaces the bedroom as the proposed first spawn. The earlier snooze/bed vignette can remain an optional home interaction. Exact opening storytelling is still a proposal; the arrival location and birthday sign come from the sketch.

## Shared rules before individual design

These rules let separately designed components fit together later without locking the final composition too early.

| Element | Initial proposal | What the blockout must establish |
|---|---|---|
| Outdoor study area | 360 × 336 studs; X -180 to 180, Z -160 to 176 | Fit the sketch's north/south composition with comfortable connections |
| Construction grid | 4 studs; smaller increments for props | Compatible building edges and paving modules |
| Ground | Walking surface Y = 0; X east, negative Z north | Every connecting entrance lands at the same height |
| Main paths | 12 studs clear along the arrival-to-house promenade; 8 for connecting paths | Comfortable passing, Jasper following, and camera clearance |
| Shop promenade | 12 studs clear | Space to browse displays without blocking travel |
| Local road | 24 studs wide along the western U District edge | Believable street frontage without cutting through the activity areas |
| Door opening | Proposed 8 wide × 12 high | Actual chosen avatar, passing friends, and camera fit comfortably |
| Avatar reference | One consistent Roblox avatar during blockout | Furniture, stairs, doorways, and companion scale agree |
| Camera | Independently rotatable third-person view; lightly elevated default proposed | Indoor visibility, canopy clearance, and landmarks work |
| Art language | Broad shapes, matte surfaces, restrained textures | Matching silhouettes and detail density between asset packs |
| Palette | Warm cream, sage/forest green, warm wood, dusty pink, muted brick | One shared material sample strip applied across all areas |
| Lighting | Warm afternoon, soft blue sky, mild haze | Light interiors, readable faces, visible paths, gentle shadows |

Stud sizes are design estimates, not Roblox requirements. Validate them using the selected avatar before detailed decoration. Test the chosen kit at its original scale before resizing pieces individually. Repeated road sections must meet with the same width, top surface height, and endpoint alignment.

### Working placement envelopes

Centers and sizes use the X/Z ground plane. These envelopes reserve space; they are not final walls or exact model placements. The Quad is a continuous ground layer with the other destination plots cut out; shared paths overlay this ground layer.

| Component | Center (X, Z) | Width × depth | Connections |
|---|---|---|---|
| House plot and porch | (-28, -100) | 112 × 88 | Front door south toward arrival; branching paths west to U District and east to dog park |
| Extended blossom Quad | (27, 13) | 274 × 322 outer envelope, excluding destination plots | X -110 to 164, Z -148 to 174; roads/path branches laid across the green ground, with western minigame clearings |
| Jasper's dog park | (118, -86) | 84 × 112 | Two southwest-facing path connections toward the house and main promenade |
| U District frontage, street, and promenade | (-140, 8) | 72 × 312 | Along the western edge; cross-paths at the Quad's north, middle, and south |
| Birthday celebration | (120, 64) | 80 × 120 | Two west-facing entrances from the central and lower paths |
| Arrival and birthday sign | (-20, 148) | 104 × 52 | North onto the main path; clear first view toward the house |

Reserve planting and view space between envelopes. The house envelope includes its yard and porch; it does not require a 112-stud-wide building. Keep the home itself intimate. Model pivots and doorway/route markers will be defined after these placements are reviewed; avoid sculpting permanent terrain around an untested layout.

## Component briefs

### 01 — Sky, light, and distant backdrop

**Feeling:** A warm afternoon after light rain, with enough blue sky to keep the neighborhood cheerful. Seasonal colors are an artistic blend; no seasonal simulation is implied.

**Design:** Soft clouds, mild horizon haze, warm window glow, distant tree masses. Buildings and trees provide the horizon near the player; the sky should support their colors without drawing attention away from the world.

**Asset approach:** Compare the free sky candidates in the asset register on the same small material sample scene. Use Roblox Sky, Atmosphere, and optional Clouds for the final treatment. Avoid adopting a community model's entire lighting setup by accident.

**Decision to make:** Clear blue with light clouds versus a more overcast cozy afternoon. Proposed first candidate: Sunless Blue Sky Skybox, with Roblox lighting supplying the sun direction; visual review still required.

**Ready when:** The house facade, green clothing, pink blossoms, and shaded path remain readable together. One global lighting treatment applies to all outdoor components.

### 02 — Ground, roads, and pedestrian connections

**Feeling:** A walkable neighborhood with short, inviting routes.

**Design:** A north/south main promenade connects arrival to the house. Three western branches cross the Quad toward U District; two eastern branches reach the dog park, and two reach the birthday area. All these internal routes overlay the extended Quad landscape. Use gentle bends matching the sketch, shared path edging, curb heights, and repeated lamps/planters. Continue grass and cherry-tree groups between routes and on both sides of the main promenade. Keep junctions open and the house visible along the main approach. The western U District street remains the outer street surface.

**Asset approach:** First compare roads/sidewalks from the Synty City Pack with the independent Modular Road Kit candidate. Prefer the same kit as the buildings if its scale works. Simple custom paths can use native Roblox parts and materials.

**Ready when:** Every entrance joins the route at the correct level, corners have no snagging collisions, and the full loop is pleasant to walk. No detailed terrain or traffic system is required for this check.

### 03 — Home exterior and porch

**Feeling:** The most welcoming and recognizable building in the world.

**Design:** North-center placement, facing the arrival route. One-story cottage, cream walls, sage trim, warm wood porch, broad windows, a simple pitched roof, planters, and a readable front door facing south. Use the wider plot for a small front garden and approach. Keep the building compact and the doorway visible from the central path; the dog park is the neighboring destination to the east.

**Asset approach:** Start with a free shell if its proportions fit an enterable interior. Otherwise assemble the simple shell with Roblox parts and reuse compatible community windows, doors, and furniture. A decorative building mesh does not establish a usable interior. Kenney's suburban kit is an external fallback, not a selected import.

**Ready when:** Exterior proportions match the interior, the camera crosses the doorway comfortably, and Phuong plus Jasper can pause on the porch without blocking the exit.

### 04 — Home interior

**Feeling:** Personal, calm, organized, and full of recognizable interests.

**Design:** Start with an open interior roughly 56 × 40 studs inside the proposed shell. Bed and plushies northwest; reading nook northeast; craft desk west; computer east; collection shelves southwest; clear central circulation; front door south. Use rugs and furniture to separate activities before adding partitions that might obstruct the camera.

**Asset approach:** Community furniture for generic tables, shelves, seats, and lamps. Use placeholders for the weighted dog and dinosaur, miniature reading nook, and personal collectibles until references and scale are settled. Retain space for the user-authored note without writing its content.

**Ready when:** All stations are visible or easily discoverable, the character reaches each one without climbing over props, and the camera gives a comfortable view of the bed and desks. Whether the interior stays physically inside the shell or uses a separate interior space is an early prototype decision; prefer the simpler in-shell option if it works.

### 05 — Jasper's dog park

**Feeling:** A playful neighborhood park with room for Jasper to run.

**Design:** A larger lawn northeast of the main path, immediately right of the house. Include one unobstructed fetch lane, shade trees along the perimeter, a water-bowl point, a sniffing corner, rabbit-toy hiding pocket, and a bench. Use low planting or fences with two generous southwest openings onto the branching paths. Avoid adding obstacles before Jasper's following and fetch space are tested.

**Asset approach:** Shared community trees, shrubs, rocks, fence segments, and bench. Jasper and his specific rabbit belong to the personal-asset decision list rather than the generic environment kit.

**Ready when:** The fetch lane is usable, planting does not hide the character, the companion can follow through the gates, and both exits read clearly.

### 06 — Blossom Quad and outdoor minigame clearings

**Feeling:** The neighborhood's memorable, open landmark.

**Design:** One extended ground-level landscape across the central map. It reaches from the U District promenade through the arrival-to-house corridor, into the spaces between the dog-park and birthday branches, and around the edges of the home and arrival approaches. The roads and paths are paved routes laid over that landscape. Groups of cherry trees frame the resulting lawn pockets, benches, a reading spot, and Lisa's meeting point; leave intersections and the house sightline clear. Keep two or three small clearings near the western cross-paths for outdoor minigames; the illustration shows space reservations, not new confirmed quest mechanics. Preserve the open sightline through each clearing. Existing home activities remain at home unless their location is explicitly changed later.

**Asset approach:** Evaluate a shared free tree family first; use a restrained recolor only if editable materials support it. If no candidate gives the right cherry-tree silhouette, make one simple reusable custom tree, then vary scale/rotation. Do not assume recoloring a generic tree produces a convincing blossom tree.

**Ready when:** Grass and blossom planting visually continue across both sides of the main route and between the eastern branches. The paved routes read clearly on top of the Quad surface, with smooth ground-level joins rather than raised crossings. The blossom canopy and activity clearings are recognizable from arrival, trunks leave clear movement lanes, the reading seat is easy to find, and the camera stays below or outside foliage comfortably. Minigame interaction space must not block any cross-path.

### 07 — UDistrict-inspired storefront street

**Feeling:** A tiny, lively neighborhood frontage with personal discoveries.

**Design:** A north/south strip along the far western edge. Proposed treatment: three shallow storefronts facing a small street, with a planted pedestrian promenade on the Quad side. Possible bays are a food/cafe window, collectibles display, and optional salon reference. Use coordinated awnings, warm windows, planters, and a consistent sign height. The sketch fixes U District's western placement; these shop types and street details remain proposals.

**Asset approach:** Synty City storefronts, low-rise building pieces, roads, and park props are the first coherent kit to evaluate. Adapt color and signage after visual review. Any specific store names or personal references remain to be supplied or selected.

**Ready when:** Displays are readable from the promenade, entrances and decorative doors are distinguishable, the street feels compact, and all three connections back into the Quad are obvious.

### 08 — Birthday celebration area

**Feeling:** A sheltered outdoor room that becomes festive through small changes.

**Design:** A distinct rectangular garden/patio directly below the dog park in the southeast, with two west-facing entries from the path network. Pergola or string lights overhead; cooking counter against the outer eastern boundary; table as the center of attention; open guest standing positions; clear route around the table. Retain the cooking activity here as a provisional carryover. For the finale, dishes, cake, friends, and restrained decorations transform it. Low hedges or planting define the boundary without concealing the area from the arrival route.

**Asset approach:** Free tables, chairs, planters, counters, and simple structural pieces. Reserve custom work for a distinctive cake or recognizable food only if the selected kit cannot cover it. Keep party props separable from the permanent courtyard structure.

**Ready when:** Cooking and cake interactions have clear standing space, eight player positions do not block the route, and the home-to-party transition is short and understandable. The component study proposes an eight-seat table and a separate group photo space; dimensions still need playtesting.

### 09 — Arrival plaza and 24th birthday sign

**Feeling:** An immediate personal welcome and a clear view into the world.

**Design:** South-center placement as drawn. A small paved arrival pad, a 24th birthday sign offset from the walking line, two planters, and space for Phuong and Jasper. Face the initial view north toward the house with blossom trees to the left and the birthday area to the right. Keep the sign readable without letting it block the first view or path.

**Asset approach:** Reuse the common paving and planter kit. A simple sign can use native Roblox parts and text. Final wording beyond the user's "24th birthday" label remains to be chosen. This does not substitute for the personal birthday note.

**Ready when:** The player has a safe, uncluttered arrival position, immediately understands how to enter the main promenade, and can read the sign with the selected camera.

### 10 — Final blending pass

Combine the reviewed component designs into a unified map only after their basic connections work. Use the same foliage family, path edge, wood tone, trim color, lamp style, and sign proportions across the world. Blend edges with small planting beds and continued paving. Use gentle terrain only where it improves a view or boundary.

Walk north from arrival to the house, then test each western cross-path and each eastern destination branch in both directions. Check the lower return loop into arrival and the indoor/outdoor transition. Remove visual clutter at junctions. Ensure key landmarks are visible from the places where the player chooses a direction. Consolidate duplicate materials and unused pack pieces; test performance on the intended device before adding dense decoration.

## Roblox authoring and import plan

The design translates into editable Roblox Models and native terrain/parts. Each location stays independently movable; the completed map is not one giant mesh. Plan proposed groups for `Arrival`, `Home`, `DogPark`, `Quad`, `UDistrict`, `Birthday`, and shared `Paths`/`Backdrop`, with lighting managed globally. Keep outdoor minigame clearings as separately identifiable spaces inside `Quad`.

1. Evaluate free Creator Store candidates first. Record exact creator and asset ID in the [asset register](roblox-asset-register.md).
2. Inspect candidate pieces in a separate asset review area before adopting them: appearance, size, materials, collision shape, bundled scripts, and dependencies. Copy only useful approved pieces into the map.
3. Save reusable component Models in Roblox's model format during the building phase, and save versioned place snapshots. Define consistent ground-level pivots and named entrance/connection markers so components can be repositioned together.
4. Use external 3D files only for identified gaps. Roblox's [Importer](https://create.roblox.com/docs/studio/importer) supports FBX, glTF, and OBJ; choose FBX or glTF for multi-part assets and confirm scale, materials, hierarchy, and collision after importing.
5. Keep external source files, source URL, creator, and supplied license together. The existing 2D references can inform the 3D work but are not direct Roblox map imports.

Free price and an open license are different properties. Creator Store assets are candidates for use in Roblox; the Synty listing specifically describes licensing for Roblox games. Kenney alternatives explicitly list CC0. Record the applicable source terms instead of treating every free model as unrestricted source material.

## Asset gaps to revisit after kit review

| Gap | First approach | Custom work only if needed |
|---|---|---|
| Enterable cottage | Free shell or simple native construction | Unique roof/window/porch pieces |
| Cherry blossoms | Compatible free tree with editable materials | One reusable stylized blossom tree |
| Personal bedroom props | Generic furniture plus placeholders | Weighted plushies, miniature nook, selected figures |
| Jasper and rabbit | Existing appearance references; placeholder scale | Distinctive mesh and rig as a separate character task |
| Food and cake | Free generic props in the chosen style | A few recognizable centerpiece props |
| Shop/campus details | Reused facade modules | Small bespoke signs and trim |

No external 3D asset is required to begin the map blockout.

## Continuous workflow and next session

Use the same cycle for each component: brief → two small design alternatives where useful → preferred layout → asset shortlist → simple walkable blockout → detail pass → integration review. Record a decision when the user chooses; keep unchosen ideas marked as proposals.

| Stage | Current state | Next useful result |
|---|---|---|
| Setting and visual style | Confirmed | Phuong's world; soft, warm stylized 3D |
| Overall layout | User approved; dimensions proposed | Arrival south, house north, shared Quad landscape under the internal routes, dog park and party east, U District west |
| Shared scale and materials | Proposed | One avatar, door, path, wall, tree, and sky sample |
| Community assets | Candidates researched; untested | Review only the relevant pieces from a small number of packs |
| Arrival and main route | Brief drafted | Entry camera, sign placement, house sightline, and branches |
| House and porch | Brief revised | Exterior and floor plan together within the north-center plot |
| Other components | Detailed studies drafted for all ten components | Review proposed spatial layouts, activities, materials, props, and handoff markers |
| Assembly and blending | Later | Walkable joined map with consistent art direction |

**Recommended first detailed design:** the arrival plaza and central approach, followed by the house and porch. A small study containing the sign, a short path, and the house silhouette establishes the first view and avatar scale. Then refine each destination without changing the sketch's agreed relationships.

**Open decisions:** exact dimensions and path curves; specific outdoor minigames within the confirmed cozy/playful mix; final sign wording; opening storytelling; camera behavior indoors; avatar proportions; exact house facade; clear versus overcast afternoon; target devices and performance expectations. Capacity is confirmed at up to eight players. These open details do not prevent the current design exploration.

## Decision log

| Date | Decision | Status |
|---|---|---|
| 2026-09-25 | Target Roblox and plan before construction | User-confirmed |
| 2026-09-25 | Carry over Phuong's Cozy World and its main destinations | User-confirmed |
| 2026-09-25 | Soft, stylized 3D with warm colors | User-confirmed |
| 2026-09-25 | Prioritize free community assets; investigate custom imports for gaps | User-confirmed |
| 2026-09-25 | Design components individually and blend them at the end | User-confirmed |
| 2026-09-25 | Compact loop, southern road, northwest house, northeast Quad | Superseded by user's sketch |
| 2026-09-25 | Adopt sketch: house north-center; dog park northeast; party southeast; arrival and 24th birthday sign south-center; blossom Quad/minigames center-left; U District west | User-directed layout |
| 2026-09-25 | Translate sketch into a proposed 360 × 336 stud study, central promenade, cross-paths, and component envelopes | Draft dimensions and path treatment |
| 2026-09-25 | Extend the blossom Quad across the central grounds and overlay the roads/path network on it | User-confirmed direction; exact landscape envelope proposed |
| 2026-09-25 | Approve the expanded-Quad map layout and begin detailed component planning | User-confirmed |
| 2026-09-25 | Design for up to eight players and a mix of cozy and playful group activities | User-confirmed |
| 2026-09-26 | Refine the arrival-to-house view; create a concept board with arrival and porch details | Visual direction accepted by user |
| 2026-09-26 | Find assets for the accepted visual and verify autonomous Studio controls | Research completed; free candidates previewed; intended build place still needs confirmation |
