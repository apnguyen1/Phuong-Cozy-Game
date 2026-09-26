# Phuong's Cozy World — component design studies

Version 0.2 · September 26, 2026 · Detailed design, before construction

The overall layout is approved: arrival south, house north-center, Jasper's park northeast, birthday courtyard southeast, U District west, and an extended blossom Quad underneath the internal road/path network. This document develops those components without changing their relationships. The [master map](roblox-map-design.md) owns the overall placement envelopes; the [asset register](roblox-asset-register.md) owns source links and inspection status.

**Confirmed for this pass:** up to eight players total; real friends can explore together; independently rotatable third-person cameras; warm, soft stylized 3D; a mix of cozy activities and playful group games in the Quad; free community assets first. The eight-player capacity includes Phuong.

**Proposed below:** measurements, furniture layouts, specific minigames, colors, prop counts, and celebration staging. These are design studies to refine before a playable blockout, not finished or tested Roblox assets. No asset has been inserted into Studio during this planning pass.

**Visual refinement:** [Arrival-to-house study 01](roblox-arrival-visual-study.md) adds the first concept board and material/placement treatment for the arrival, blossom approach, and cottage facade. It is proposed for review; the image does not replace the dimensions below.

## Shared design rules

The neighborhood should feel like several parts of the same place. Repeat cream walls, sage and forest-green trim, dusty pink blossoms, warm wood, pale warm-gray paving, and muted brick. Use broad silhouettes, matte surfaces, simple trim, and restrained texture detail. Personal objects carry the strongest detail; background objects stay quieter.

| Rule | Proposed design target | Reason |
|---|---|---|
| Main promenade | 12 studs clear | Friends can pass and walk together |
| Branch paths and park gates | 8 studs clear | Two-way access without a single-file bottleneck |
| House doorway | 8 wide × 12 high | More generous entrance for the group and camera |
| Indoor central aisle | 12 studs clear | Reach each station without crossing another activity |
| Main gathering spaces | Room for eight avatars plus circulation | Cake, arrival, and photo positions remain usable together |
| Small activity station | 2–4 active positions, nearby spectator space | Participation can be shared without eight overlapping prompts |
| Ground connections | Walking surface Y = 0 | Paths, plots, and thresholds meet smoothly |
| Camera | Free third-person rotation per player | One player's activity never takes over the group's view |
| Personalization | Curated placement spots initially | Decorating is satisfying without blocking doors or paths |

These are spatial targets, not Roblox minimums. Test with the chosen avatar, Jasper placeholder, and eight players before freezing dimensions. Start with one physically connected house interior; camera clipping or crowding is the reason to reconsider it, rather than adding separate spaces preemptively.

**Activity scope:** retain the six existing favorite-things quests as the main progression proposal. Quad games are optional and replayable. A proposed shared flower receives each quest reward once for the group, including late arrivals in the visible completed state. It does not require every guest to repeat every activity. Participation rules, persistence, and decoration ownership still need a gameplay decision.

## C01 — Sky, lighting, and distant backdrop

**Design:** a warm midafternoon following light rain, with soft blue sky, a few clouds, warm faces, and readable green clothing. The initial study uses a fixed afternoon; weather and a day/night cycle are outside this first environment pass.

- Use one global light treatment across all outdoor components. Warm interior lamps are a local accent.
- Make the house roof and blossom canopy the important skyline shapes. Low tree masses and a few muted building silhouettes conceal the map edge.
- Leave the northward view from arrival open. Place the brightest party lights low enough that they do not overpower the house during exploration.
- Keep mild haze at the distant boundary. Close objects need clear color separation and readable faces.
- Localize drifting petals to a few blossom groups. Use a small amount of wind motion and soft birds/wind ambience; party and street audio should become quieter with distance.

**Asset approach:** compare the two free sky candidates under the same material samples. Adopt only the selected sky treatment and deliberate lighting settings. The skyline can reuse simplified pieces from the building and foliage kits.

**First sample:** one wall, roof, paving tile, tree, bench, green-clothed avatar, and a warm interior window. Check them in sun and shade before changing every area's materials.

**Ready for assembly when:** faces, paving edges, pink blossoms, and cream walls stay distinguishable; the horizon has no visible seam; the interior is comfortable without excessive glow. Final clear-versus-overcast mood remains open.

## C02 — Ground, roads, and connections

**Design:** the Quad is the continuous landscaped base. Internal roads and paths sit over it at ground level, with green lawn and blossoms continuing on both sides. The western U District road remains a distinct street surface.

Use pale paving for the central promenade and branches, a single restrained edging detail, and muted asphalt or brick for the western street. The paved routes can read as small neighborhood lanes, but vehicle traffic is not part of the current activity design. Slight visual elevation is acceptable only if walking and Jasper's movement remain smooth.

The main path runs from arrival at `(8, 122)` north to the house plot at `(8, -56)`. Preserve the three western links, two dog-park branches, and two courtyard branches from the approved sketch. Put lamps, signs, benches, and activity prompts in side pockets rather than in the clear path width.

**Junction treatment:** widen the visible paving slightly where routes meet; use one planter or landmark beyond the fork; leave the inside of each bend free of tall shrubs. Continue matching grass and paving materials across component seams. Keep crossings between the U District sidewalk and promenade aligned with the three western links.

**Asset approach:** compare road and curb pieces in the Synty kit with the separate modular road kit. For the winding internal paths, simple native Roblox parts may require less adaptation than a vehicle-road pack. Reuse the chosen edging, not necessarily every road module.

**Ready for assembly when:** the entire loop can be walked in both directions; no curb catches an avatar; two players can pass at every gate; Jasper follows through each transition; the destination is visible from each choice point. Exact bends may change during blockout while endpoints remain consistent.

## C03 — House exterior, porch, and front garden

**Identity:** the most personal and welcoming building, with a simple cottage silhouette and a recognizable green roof. Use cream walls, sage trim, warm wood, broad windows, and a south-facing front door.

**Proposed envelope:** plot `112 × 88` at `(-28, -100)`. Place a `64 × 48` shell at `(-28, -108)`, leaving room for the porch and garden. Start with eaves around 14 studs and a ridge around 26; interior ceiling clearance and roof proportions must be tested together.

| Part | Proposed arrangement |
|---|---|
| Roof | One simple pitched form; forest-green main surface, minimal trim |
| Porch | 56 × 16, centered at `(-16, -76)`; warm wood; broad step-free approach |
| Front door | South wall at `(-12, -84)`; 8 × 12 opening |
| Approach | Door to `(8, -76)`, then south to `(8, -56)` on the main route |
| Windows | One broad window either side of the entrance where interior furniture permits |
| Garden | Two small planting beds, a mailbox, and a pair of planters; keep the approach open |
| Porch seating | A small bench on the west side, outside the doorway and turn space |

**Activity support:** two people can wait on the porch while others enter. A personal discovery can sit beside a planter, but the exit should never become a collectible station. The porch is also a quiet photo spot with the Quad behind the camera.

**Asset approach:** inspect the free Cottage House candidate for proportions, usable interior, separable roof, and actual door openings. If adapting it becomes awkward, build the simple shell from native parts and reuse compatible windows, doors, planters, and furniture. A pretty facade alone is insufficient.

**Ready for assembly when:** the floor plan fits the shell; a friend can pass someone at the entrance; the camera moves through the doorway without trapping behind the roof; the front door remains visible from the main approach. Roof cutaway/fading is a possible local camera treatment, not yet a selected system.

## C04 — House interior and personal activity stations

**Identity:** one calm, open room whose corners reflect Phuong's interests. Rugs, furniture heights, and lighting separate the zones. Keep tall partitions out of the first study.

**Proposed clear floor:** `56 × 40` studs, centered inside the shell. In this table, coordinates are local to the interior center; negative Z is north. The south entrance is at approximately `(16, 20)`.

| Station | Center / reserved floor | Layout and group behavior |
|---|---|---|
| Bed and plushies | `(-18, -11)`, 16 × 14 | Green sheets; weighted dog and dinosaur at the pillows; approach from the south and east. Friends can help with bedding; Phuong's finishing interaction is a proposed role. |
| Reading nook | `(18, -11)`, 16 × 14 | Chair, small side table, warm lamp, books, and Kindle. Adjacent shared bookmark/book display lets friends contribute without forcing synchronized reading. |
| Miniature craft station | `(-20, 6)`, 12 × 12 | Table against west wall, trays beneath, finished miniature display above. Two contributors can stand beside each other. |
| Computer corner | `(20, 6)`, 12 × 10 | Compact desk and chair against east wall; optional cozy gaming detail. Keep its interaction independent of main quest progression. |
| Collection display | `(-18, 17)`, 16 × 4 | Low shelving on southwest wall, with clear standing space to its north. Display a small curated collection rather than many cluttered objects. |
| Central floor | At least 12 studs clear | Entry circulation and room for friends waiting or looking at finished work. Keep the south entry-to-center turn open. |

**Furniture language:** rounded or softened corners, warm wood, green textiles, cream storage, and one or two pink accents. Use low shelving where the camera must see across the room. Scale personal objects for recognizability, then confirm them at actual player viewing distance.

**Persistent visual results:** a made bed with tucked-in plushies; a lit miniature; selected figures on the shelf; a bookmark or annotation keepsake. Each result has a named display spot. Do not stack all rewards at the entry door.

**Initial prop set:** bed, two specific plushies, one reading chair, side table, floor lamp, book shelf, craft table, a few supply trays, miniature placeholder, computer desk/chair, collection shelf, and Jasper's toy basket. Use a small repeated book family rather than separate detailed meshes for every book.

**Asset approach:** inspect the free low-poly furniture candidate for shared scale and style. Kenney Furniture Kit is an external CC0 fallback. Generic furniture can be reused; plushies, Jasper, his rabbit, the miniature, and chosen collectibles are the main personal-asset gaps. Keep the user's birthday note content empty until supplied.

**Ready for assembly when:** all eight players can enter and leave; two people can use different stations without overlapping prompts; a spectator can see the miniature; the camera sees the bed and shelf comfortably; any optional close-up affects only its requesting player.

## C05 — Jasper's dog park

**Identity:** an open, friendly neighborhood lawn framed by low fencing and shade. Jasper is the focus; the park does not need a full obstacle course.

**Plot:** `84 × 112` at `(118, -86)`. The following positions are local to the plot center.

| Area | Position / size | Design |
|---|---|---|
| Upper west gate | `(-42, -6)` | 8-stud opening connecting toward the house |
| Lower west gate | `(-42, 34)` | 8-stud opening connecting toward the central Quad |
| Fetch lane | `(6, -2)`, 24 × 56 | Flat, empty lawn; no trunks, benches, or water props in the run |
| Shaded seating | `(-22, -38)`, 24 × 8 | Two benches facing the fetch area; spectator space beside them |
| Sniffing garden | `(26, -36)`, 16 × 20 | Low shrubs and a few rocks; readable hiding pockets |
| Water and treat point | `(24, 40)`, 12 × 12 | Bowl, small mat, low storage; away from the throwing line |
| Rabbit hiding pocket | Near `(30, 22)` | One playful location behind low planting, visible on approach |

**Activity proposal:** find the rabbit together, take turns throwing it, then give Jasper a treat. Keep one shared Jasper and one current fetch toy per session. Players watching can pet him between throws; avoid multiple competing targets or duplicated pets. The main quest remains forgiving and can complete once for the group.

**Props and materials:** low wood fence, two benches, bowl, toy/treat props, three or four perimeter shade trees, repeated shrubs, and a small park sign. Park grass matches the Quad; slightly denser border planting makes the space feel distinct.

**Asset approach:** reuse the common fence, bench, and foliage families. Jasper's actual appearance and rabbit shape need references before final modeling; placeholders are sufficient to test the lane.

**Ready for assembly when:** Jasper can navigate both gates and the throwing lane; a spectator never blocks the toy destination; the toy is visible in grass; gates remain recognizable from both sides; a lost toy can reset without trapping progress.

## C06 — Extended blossom Quad and outdoor minigames

**Identity:** a continuous blossom landscape connecting every destination. The western lawn is its social center, while smaller green pockets extend between the paths east of the main promenade.

**Planting composition:** use larger groups at the map edge and two or three trees around each activity clearing. Keep junctions and the northward house view open. Trunks sit outside walking lanes; canopies should read overhead without filling the third-person camera. Reuse a small tree family with modest variations in rotation and scale.

**First art-pass allowance:** approximately 24 blossom-tree instances across the shared landscape, using two compatible silhouettes if available; four Quad benches; two reading/picnic settings. This is a starting composition, not a performance guarantee or a target to fill regardless of visibility.

Reserve two `32 × 32` activity clearings in the western lawn, centered roughly at `(-72, 76)` and `(-28, 78)`. They fit between the middle and lower western routes. Keep entrances toward those routes and a clear strip between the games. The spaces remain reservations until the mechanics have been tried.

| Proposed activity | Experience | Group use | Visible result |
|---|---|---|---|
| Blossom picnic decorating | Cozy: choose a blanket, arrange snacks, flowers, and small decorations in curated spots | 2–4 people place pieces; others sit nearby. Changes appear to everyone. | A shared picnic stays on the lawn until deliberately reset |
| Petal basket toss | Playful: toss soft blossom bundles into wide baskets at forgiving distances | Two throwing positions plus room for spectators/turn-taking; a short shared target rather than elimination | A basket display fills during the round; replay is optional |

The user confirmed a mix of cozy and playful activities; these two specific games are proposals. No optional score, timer, or minigame reward blocks the birthday. Begin with these two spaces rather than adding a third system immediately.

**Quiet pocket:** one reading bench and small book/flower arrangement near a path, separated from the throwing direction. A Lisa meeting/photo spot can be present; if Lisa joins as a real player, the environment should support her presence without requiring a duplicate NPC.

**Asset approach:** inspect the free Cherry Blossom Tree candidate first. Check its silhouette from ground level, opacity, materials, and collision. If none of the free candidates fits, one reusable custom blossom tree would have more value than many unrelated imported trees.

**Ready for assembly when:** the green landscape visibly continues on both sides of the main route; players can recognize both clearings while passing; throws stay within the game space; spectators do not occupy a through-path; the house and east-side destinations remain easy to find.

## C07 — U District storefront street

**Identity:** a short neighborhood street that feels inhabited without requiring a whole city. Three storefronts provide places to browse and personal references.

**Reserved strip:** `72 × 312` at `(-140, 8)`. Use three shallow buildings approximately `28 × 54`, centered near X `-160`, Z `-96`, `0`, and `96`, facing east. The western sidewalk sits around X `-144` to `-134`, the street around `-134` to `-110`, and the Quad promenade around `-110` to `-98`. This intentional overlap with the Quad edge forms the transition.

**Facade rhythm:** one shared roof/eave family, consistent sign band and door height, warm display windows, and different restrained awning colors. Start with low-rise facades; only open an interior when an activity actually uses it.

| Proposed shop | Window / frontage detail | Interaction scope |
|---|---|---|
| Cafe or food window | Small menu, pastry/drink display, two stools tucked aside | Browsing, sitting, photo spot; optional food prop |
| Collectibles display | A few recognizable display silhouettes, small shelf, warm light | A possible discovery for the existing collection activity |
| Salon reference | Simple sign, plant, nail-color display | Personal visual nod; no work-simulation requirement |

Specific names and branding remain open. A decorative door should not look like an unexplained locked objective. Clearly distinguish enterable doors from window-only fronts.

Align three crossings with the western Quad branches near Z `-100`, `28`, and `108`. Continue their paving cues across the street. Put benches and browse positions beyond the 12-stud promenade width. Decorative street props can suggest a neighborhood without adding moving traffic.

**Asset approach:** review a small subset of the Synty City Pack as the first coherent facade/road/prop family. Choose pieces by scale and silhouette before recoloring. The independent road kit is a fallback if the paired kit cannot meet the route widths.

**Ready for assembly when:** every crossing points back into the Quad; display labels are readable at normal camera distance; the street does not look much more detailed than the cottage; browsing friends do not block the promenade.

## C08 — Birthday courtyard and live celebration

**Identity:** a garden room available throughout exploration, with cooking and a central table. Cake, lighting accents, and decorations make it festive when the group is ready.

**Plot:** `80 × 120` at `(120, 64)`. Positions below are local. Keep both western entrances: `(-40, -44)` and `(-40, 22)`.

| Feature | Position / reserved size | Purpose |
|---|---|---|
| Shared table | `(-8, 0)`, 28 × 12 | Eight chairs, four along each long side; cake at center |
| Table gathering zone | Around table, approximately 48 × 44 | Seated and standing friends plus a route around them |
| Cooking counter | `(28, -4)`, 8 × 48 | Grill, seafood preparation, serving space against the east edge |
| Cooking approach | West of counter, X 14–24 | Parallel working spots for cooking and plating |
| Backdrop | `(0, -48)`, 48 × 8 | Low greenery and a restrained birthday decoration band |
| Group photo space | `(-2, 40)`, 44 × 14 | Eight loosely spaced positions; camera can look north toward the table |
| Note / gift presentation | Small side stand near the photo space | Empty content slot until the user supplies his exact words |

Use cream paving, warm wood furniture, sage planting, and dusty-pink accents. A light pergola frame or two string-light runs can define the ceiling; avoid a dense overhead structure that traps the camera. Low hedges leave the courtyard visible from the Quad.

**Cooking proposal:** separate simple grill, platter, and table-setting contributions so several friends can help. Completed dishes stay on the shared table. One player leaving should not strand the activity.

**Celebration states:**

1. **Exploration:** courtyard open; table and cooking stations usable; friends already participate in the world.
2. **Ready:** the proposed shared flower completes and the game invites the group to gather. The celebration does not automatically start while friends are elsewhere.
3. **Gathered:** a proposed host-ready action starts the cake moment once everyone is present. Exact host permissions and Phuong's candle interaction remain to be chosen.
4. **Afterward:** decorations and cake result remain; guests can sit, take photos, and return to activities.

Birthday wishes come from real people, not invented scripted guest dialogue. A group-photo viewpoint may be optional for each player; it should not force all cameras into a shot. The personal note remains fully user-authored.

**Asset approach:** reuse generic table, chair, counter, planter, and light pieces. Inspect generic food and cake props after the environment kit is chosen. Custom cake or food meshes are justified only for specific recognizable details the selected assets cannot supply.

**Ready for assembly when:** eight players can gather around the table and still leave through either entrance; cooking users do not block the cake; the photo framing includes the whole group; late arrivals see the current celebration state; starting and replaying the moment cannot duplicate main quest rewards.

## C09 — Arrival plaza and 24th birthday sign

**Identity:** a small personal welcome with an immediate view into the blossom landscape. The first frame should contain the sign, a clear route, and the house silhouette.

**Plot:** `104 × 52` at `(-20, 148)`. Local north exit is `(28, -26)`, joining the world main path at `(8, 122)`.

- Reserve a `56 × 32` paved group pad centered near local `(12, 6)`.
- Put a roughly 24-stud-wide birthday sign on the west side near `(-30, 0)`, with two planters. Keep its shape below the main distant sightline.
- Reserve eight arrival positions toward the east half: two rows of four, approximately 8 studs apart. Face the initial view north; players can rotate immediately.
- Place one bench off the west edge of the pad. Leave the northeast line from the spawn area to the main path open.
- Use the same paving and plants as the Quad. Make the sign base and curved planting edge the arrival's distinct detail.

The only committed sign content is the user's 24th-birthday idea; final wording and typography remain to choose. It is separate from the personal birthday note.

**Asset approach:** native parts and text for the sign, common paving, repeated planters/bench, and shared trees. This component needs no external custom mesh to block out.

**Ready for assembly when:** eight arrivals do not overlap or spawn inside decoration; everyone can step toward the route; the birthday sign is legible with the normal camera; the sign and plants do not hide the house or right-hand destination branches.

## C10 — Joining the components

Keep one consistent ground level, shared material samples, and the same tree/bench/lamp families. Each destination should be recognizable from its main approach before it receives small decorative props.

### Connection handoff

All coordinates below are proposed world X/Z endpoints at walking height Y = 0. Store these as named markers when the building phase begins. Path endpoints may be refined together, never independently on each side of a seam.

| Marker | Position | Clear width |
|---|---|---|
| Arrival → main path | `(8, 122)` | 12 |
| Main path → house plot | `(8, -56)` | 12 |
| House front door | `(-12, -84)` | 8 |
| Dog park upper gate | `(76, -92)` | 8 |
| Dog park lower gate | `(76, -52)` | 8 |
| Courtyard upper entrance | `(80, 20)` | 8 |
| Courtyard lower entrance | `(80, 86)` | 8 |
| U District upper link | `(-104, -100)` | 8 |
| U District middle link | `(-104, 28)` | 8 |
| U District lower link | `(-104, 108)` | 8 |

### Roblox handoff and import strategy

Plan separate editable models for `Arrival`, `Home`, `DogPark`, `Quad`, `UDistrict`, and `Birthday`, with shared `Paths` and `Backdrop`. Put component pivots at their plot centers at ground level. The landscape stays continuous beneath the routes; component boundaries organize editing, not visible seams or fenced-off rectangular islands.

Review community assets in an isolated review area during construction, recording selected sub-models, source, scale changes, materials, collisions, scripts/dependencies, and inspection results. Keep only the pieces used by the design. Save reusable Roblox models and versioned place snapshots when actual assembly begins.

External source meshes are optional. If a gap needs one, keep its source and license with the file, then review scale, hierarchy, materials, and collision in Roblox's [3D Importer](https://create.roblox.com/docs/studio/importer). The importer supports FBX, glTF, and OBJ. This design study itself is not an importable finished map.

### Review and building order

1. **Agree on the component studies:** adjust layouts and personal references while changes are cheap. Keep measurements provisional.
2. **Establish the shared sample:** avatar, door, paving, cottage wall/roof, tree, bench, and lighting. Choose compatible free assets.
3. **Block out arrival, main path, and home together:** prove the first view, doorway, interior scale, and one shared activity with at least two players before expanding asset work; then check eight-player occupancy.
4. **Add the Quad and its two reserved activity clearings:** prove paths and open views before dense planting; prototype one cozy activity and one playful game.
5. **Add the park and western frontage:** check Jasper's lane, both gates, storefront proportions, and crossings.
6. **Stage the courtyard with eight players:** verify cooking positions, table access, gathering behavior, and photos.
7. **Blend:** repeat materials and props, soften seams with planting, remove clutter at junctions, test full loops, and check the intended device before increasing decorative density.

**Next decisions, in order:** house facade/furniture feel; the two specific Quad games; sky mood; shop references and sign wording; final personal-asset references. Target device, avatar style, save ownership, and host controls are open before implementation. None changes the approved map relationships.

## Decision record

| Date | Decision | Status |
|---|---|---|
| 2026-09-25 | Expanded Quad with roads overlaid; sketch relationships retained | User approved |
| 2026-09-25 | Map comfortably fits up to eight players | User confirmed |
| 2026-09-25 | Outdoor games mix cozy activities and playful group games | User confirmed |
| 2026-09-25 | Specific picnic and basket-toss games; furniture plans and measurements | Proposed in this study |
