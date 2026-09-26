# Art and map production plan

Working plan, September 20, 2026. AGENT.md remains the source of confirmed game direction. The user selected hybrid production (generated references, finished in Aseprite) and **A — Compact** from the visual comparison. Exact production dimensions, Phuong's outfit, and missing personal references remain unresolved.

Selected reference: the **left panel** of [the proportion comparison](../art/references/character-proportion-comparison.png). This generated board establishes visual direction, not an exact pixel grid or production-ready sprite sheet. The right panel is retained only for comparison.

## 1. What we are making

The [Phuong, Lisa, and Jasper sprite sheets](../art/references/sprite-sheets/README.md) and [native Phuong animation draft](../art/characters/README.md) are retained as references. The Aseprite MCP workflow has been demonstrated for editable sprite creation, animation tags, and exports. Final art and in-game integration remain future work; the native draft's dimensions are not a new confirmed art constraint.

This game needs 2D characters, scenery, props, activity close-ups, and interface art. It does not currently need 3D models, rigging, or a 3D rendering pipeline.

Use a consistent slightly elevated top-down view: visible floor, object tops, and front faces. All assets share the same perspective, lighting direction, outline treatment, and palette. A 16 x 16 tile is a placement unit, not a limit on object size; beds and trees span several tiles.

Suggested starting art direction: warm cream interiors, wood browns, several distinguishable greens, golden-orange Jasper, and pink cherry blossom accents. Keep interaction objects distinct from their surroundings. Choose actual palette swatches after a room sample is reviewed.

## 2. Production method options

| Method | Strength | Work to account for |
|---|---|---|
| Original Aseprite art | Full control over pixel placement and consistent animation | Most drawing time; begin with a small reusable kit |
| Generated references plus Aseprite finishing | Fast exploration of character and room appearance | Generated images still need grid, palette, transparency, proportions, and animation cleanup |
| Existing pack plus custom personal assets | Fast environment foundation | Match pack perspective/pixel density and record its license; Phuong and personal props still need customization |

**Selected workflow:** generate visual references, then finish and maintain precise runtime sprites in Aseprite. Do not treat a generated contact sheet as verified animation data. Existing packs and fully hand-drawn production are alternatives, not the selected workflow.

## 3. Scale test before production

**A — Compact is selected.** Begin the production scale test with a proposed 16 x 32 character canvas and 16 x 16 tiles in the proposed 640 x 360 logical viewport. Preserve the compact reference's silhouette and proportions; the generated sample does not prove these exact dimensions. Adjust the canvas if needed for readable glasses/hair and a stable animation silhouette. Review at intended display scale, not only zoomed in inside the art editor.

The test scene contains Phuong, Jasper, a bed, a doorway, one shelf, and one plant. Use placeholders for unresolved appearance details. Check legibility of glasses/hair, Jasper's size, foot alignment, doorway clearance, and room density. Lock exact pixel dimensions after this test.

Frame canvas size includes transparent margins. Record the actual body height, foot anchor, and collision footprint separately. Give every frame of one character the same canvas and anchor to prevent animation jitter.

## 4. Asset inventory

| Family | Minimum required set | States / motion | Priority |
|---|---|---|---|
| Phuong | One outfit, four facing directions | One idle pose and four walk frames per direction: 20 initial frames; extra gestures later | Bedroom slice |
| Jasper | One coherent four-direction character | Idle and walk first; sniff, happy reaction, rabbit play, and treat reaction later | Bedroom slice, then Q02 |
| Bedroom tiles | Floor, wall fronts/tops, corners, door surround | Static; small variants only after readability works | Bedroom slice |
| Bed | Green sheets, pillows, dog plush, dinosaur plush | Messy and finished world views; separate manipulable pieces in the activity | Bedroom slice / Q01 |
| Home props | Kindle chair, desk/computer, craft table, shelf, rug, plants | Most static; shelf and miniature change with progress | Q03–Q05 |
| Jasper props | Rabbit, fetch item, Greenie, portrait | Rabbit location/carried or play states as required by Q02 | Q02 |
| Miniature | Reading-nook shell, a small defined set of furniture/decor pieces | Loose pieces, placed pieces, completed lit display | Q03 |
| Reading | Kindle casing, bookmark, reading spot cue | Screen content and highlight selection rendered by UI | Q04 |
| Collectibles | Three required figures; three more provisional | Tiny world pickup/shelf view plus readable close-up per figure | Q05; extras later |
| Cooking | Grill, raw/cooked serving, seafood components, platter, utensils | Simple cooking states and completed dishes | Q06 |
| Outdoor tiles | Grass, paths, path edges/corners, courtyard surface | Start with only the terrain combinations actually used | Complete world |
| Outdoor props | House facade, storefront facades, cherry trees, benches, fences, planters | Mostly static; separate objects when actors must walk behind them | Complete world |
| Lisa | Personal sprite using shared human proportions | Idle first; walk only if staging needs it | Quad encounter |
| Party friends | One recognizable sprite per supplied guest | Idle first; movement frames only if arrival is animated | Celebration |
| Party props | Table, cake, gifts, simple bunting | Lit/unlit cake; confetti can be an engine effect | Celebration |
| Interface | Six quest icons, flower center/petal, scrapbook frame, interaction prompt | Render six reusable petals from progress; do not draw seven complete HUD screens | Slice, then all quests |

Use runtime text for dialogue, journal entries, annotations, and the exact user-authored birthday note. The note remains empty until supplied. Do not bake text into decorative images.

Activity close-ups are separate compositions, not stretched copies of tiny world sprites. Share colors and design, but give plush placement, miniature pieces, Kindle controls, and cooking targets enough screen space to read and manipulate. Avoid creating large close-ups for props that never need them.

## 5. First art batch

1. A native-pixel scale test of the selected compact direction using placeholder character appearances.
2. Once dimensions and character appearance are settled: Phuong's four idle poses and directional walk loop; Jasper idle/walk.
3. A small bedroom tile atlas with floor, wall, corner, and door tiles.
4. The green bed, two plushies, pillows, shelf, and one foreground prop.
5. Bed activity background and independent placement pieces, including completed-state visuals.
6. One flower petal, one quest icon, and an interaction prompt treatment.

Finish and test this batch before making the street, Quad, every collectible, or all guests. Keep a simple asset checklist with ID, source file, export file, dimensions, tags/states, and status when production begins.

## 6. Map layout

Build one outdoor map and one house interior. The bedroom test can grow into the house map; it need not become a third permanent scene. Storefronts can be facades, and activities can open overlays without additional interiors.

Proposed outdoor arrangement:

```text
                 NORTH
       House / porch       UW Quad
             |                |
       Front garden --------- +
             |                |
       UDistrict street --- Courtyard
                 SOUTH
```

The house sits above and left of center. Paths form a loop, with a short home-to-courtyard route for the party. The exact layout remains adjustable. Place the cooking table and party table in the same courtyard to preserve the visible result of Q06.

House zones: bedroom, reading nook, computer/craft area, collection shelf, and exit. Keep a clear route between the door and every activity. Choose dimensions after blocking out furniture at the selected character scale; do not fill an arbitrary large map with walking space.

Place three required collectible opportunities along naturally visited routes and optional finds on small detours. Specific figure variants and hiding places remain content decisions. Jasper hints must not be necessary to locate a mandatory quest.

## 7. Building the maps in Tiled

1. Make a finite orthogonal map on the proposed 16 x 16 grid. Start with colored placeholder tiles and mark every quest location.
2. Import the exported environment atlas. Paint ground and detail layers; use explicit edge/corner artwork rather than flipped tiles under the initial project validation contract.
3. Use `entities` point markers for runtime props/characters and their foot origins. These markers reference stable entity IDs; the game supplies the sprite. Do not assume Tiled tile-object alignment equals the game's anchor.
4. Add rectangular `collisions`, named `spawns`, rectangular `interactions`, and `transitions` with destination IDs. Phaser loads the tilemap; the project adapter creates physics bodies and gameplay objects from this metadata. Tiled alone does not determine runtime behavior.
5. Reserve `overhead` for elements genuinely above actors. Objects requiring front/behind ordering become runtime entities; do not bake them into a single ground image.
6. Export the supported JSON format described in AGENT.md: embedded atlas tilesets and numeric tile arrays, no infinite maps, compression, nested groups, or flipped GIDs initially.
7. Walk the map in the game before decorating. Verify every destination, collision, door return, interaction reach, and route back home.
8. Replace placeholders with finished tiles and props, then repeat the walk test. Decorative changes can accidentally obscure prompts or narrow paths.

Tiled stores placement and metadata. Quest logic, petal awards, dynamic bed/shelf/dish states, and scene transitions are implemented in TypeScript.

## 8. Aseprite handoff

Maintain editable art in `art/` and runtime exports in `public/assets/`, using the layout established in AGENT.md. Keep export sizes at native pixel resolution; enlarge only for review images.

For animated sprites, export PNG sheets and JSON array metadata with animation tags. Use equal untrimmed frames and no rotated packing. For terrain, export an atlas with a fixed 16 x 16 grid and documented margin/spacing. Once maps refer to tile IDs, avoid reordering atlas tiles; append or deliberately migrate maps.

For Phaser's Aseprite animation importer, export numeric frame names using `{frame}` and production tags prefixed by character, such as `phuong:walk-down`. Load PNG/JSON through `load.aseprite` and create the animations after loading. Explicitly enable walk looping. Existing reference exports stay untouched; re-export them with these conventions only when preparing a Phaser prototype or final art.

Before accepting an export, check transparency edges, missing frames, tag names, anchor stability, consistent lighting/palette, and visibility at game scale. Test a single animated sprite through the pinned Phaser version before producing the remaining sheets.

## 9. References still needed

- Phuong's final outfit and a usable appearance reference; AGENT.md mentions an earlier attachment, but no reference image is present in the repository.
- Jasper, the weighted dog/dinosaur, and the rabbit's colors and shapes.
- Specific collectible variants and confirmation of how many optional ones to include.
- Guest roster/appearance references and cake design before party art.

Placeholder shapes can support map planning while these are unresolved; do not invent personal details and mark them as approved.

## Sources

- [Aseprite sprite sheet workflow](https://www.aseprite.org/docs/sprite-sheet/): importing/exporting sheets and selecting tagged frames.
- [Tiled object workflow](https://doc.mapeditor.org/en/stable/manual/objects/): point/rectangle placement, custom properties, and object alignment.

The inventory, frame budget, layout, and restricted export workflow above are project proposals, not requirements imposed by these tools.
