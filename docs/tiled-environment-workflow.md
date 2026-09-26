# Two-area environment plan and Tiled workflow

Proposal, September 20, 2026. This expands the existing art-and-map plan; it does not lock map dimensions, final art, or character scale. AGENT.md remains the source of confirmed direction. No playable maps or environment assets have been created by this planning pass.

## Overall approach

Use generated images to explore the appearance of rooms and individual asset families. Finish a reusable environment kit in Aseprite, assemble two maps in Tiled, and let Phaser render the world and handle gameplay.

Phaser's built-in Tiled loader replaces the previously proposed custom tile importer. Keep a thin project adapter for validating named layers/properties and constructing entities, Arcade collision bodies, and door triggers. Preserve the simple initial export contract in AGENT.md; it describes our starting scope, not all formats Phaser supports.

Tiled is the assembly and placement tool. It cannot turn a room illustration into seamless terrain, separate furniture, or implement quests. A single generated room image is useful as a reference; reusable floor/wall tiles and separate props provide the control needed for walking, collisions, occlusion, and persistent quest changes.

The two maps are `house` and `outside`. The house is an open-plan interior with a bedroom corner; outside contains the yard, street, Quad, and courtyard. Activities open close-ups without requiring more permanent maps.

## Proposed house layout

Start testing at 32 x 20 tiles on a 16 x 16 grid: 512 x 320 native pixels. This can fit in the proposed 640 x 360 viewport, with the remaining space handled by the room backdrop. Test HUD clearance and character readability before approving these dimensions.

| Position | Contents | Play purpose |
|---|---|---|
| Northwest | Green bed, pillows, weighted dog and dinosaur, nightstand | Opening and Q01; stand beside the bed to interact |
| Northeast | Window, Kindle chair, lamp, small book stack | Q04 reading spot |
| West middle | Craft desk, miniature, coloring supplies | Q03; finished miniature remains on display |
| East middle | Computer desk, chair | Personal environmental detail |
| Southwest | Collection shelf | Q05; acquired figures appear here |
| Center | Rug, Jasper, rabbit, open floor | Clear circulation and immediate companion introduction |
| South center | Front door, entry mat | Transition to porch and return from outside |

Keep the initial view roofless with a visible back wall and minimal foreground wall obstruction. Use rugs and furniture to divide zones. Start with at least two clear tiles on main routes and a wider center for Phuong and Jasper; validate using actual collision footprints.

Opening sequence: wake-up presentation at the bed, movement begins on a clear bedside spawn, Jasper is visible, bed interaction is nearby, and the front door is immediately discoverable. She can leave before completing any quest.

## Proposed outside layout

Test 64 x 48 tiles: 1024 x 768 native pixels, with a following camera. This is a blockout budget, not a requirement to decorate every tile.

House/porch northwest -> cherry-blossom Quad northeast -> cooking/birthday courtyard southeast -> UDistrict storefront street southwest -> garden and house. Keep a clear loop, short walking distances, and a direct route home. The house footprint outside need not match the interior's scale exactly.

Jasper's play area sits beside the front garden. Place required figure discoveries near visited destinations, with optional discoveries on small detours. Keep storefronts as facades initially. The cooking and party table share the courtyard, so completed food remains visible. Reserve clear standing space around the table for the guest roster once supplied.

Use vegetation and fences as readable boundaries. Avoid designing water, bridges, cliffs, and multiple elevation levels until there is a gameplay reason for them.

## Make the art in small batches

1. **Scale sample:** existing Phuong draft, placeholder Jasper, a floor patch, doorway, bed, shelf, and one plant. The native draft is 24 x 32; this remains a reference rather than a final dimension decision. Check all objects together at intended display size.
2. **Interior kit:** wood-floor variants, back-wall face/top, wall corners, door opening/trim. Add green bed, chair, desks, shelf, rug, lamp, and plant as separate assets.
3. **Personal states:** messy/made bed with consistent dimensions and origin; shelf empty/filled; miniature unfinished/complete. Draw independent activity pieces for close-ups instead of enlarging tiny world sprites.
4. **Outdoor kit:** grass variants, dirt path center/edges/corners, courtyard paving, porch boards. Add house facade, fence pieces, cherry tree, shrub, bench, planter, grill, table, and simple storefronts.
5. **Polish:** small accents, extra ground variants, animated details, and party props after the two areas work.

Use one environment atlas initially for simplicity. An expandable 256 x 256 sheet gives 16 x 16 slots on the proposed grid; it need not be filled. Keep its width stable once maps use it. Append rows rather than shifting existing tile IDs. Large props get separate transparent sprites and may span many tiles.

All art must share perspective, pixel density, palette, outlines, light direction, and shadow style. Draw object tops and front faces in a slightly elevated top-down view; use an orthogonal map, not an isometric map.

For generated references, request one asset family at a time, neutral presentation, consistent viewpoint, no lettering, and clearly separated objects. A beautiful contact sheet still needs inspection for false transparency, inconsistent scale, antialiased edges, baked shadows, and nonmatching seams. Do not assume downscaling automatically produces usable pixel art.

In Aseprite, redraw or clean up at native resolution. Test floor/grass tiles repeated across a large patch; a single tile can look fine while its repeated edges form an obvious grid. Check paths at turns and junctions, and test both inside and outside corners. For a first manually painted path kit, center plus four edges, four outer corners, and four inner corners is a useful starting checklist, not a complete universal autotile set.

## Assemble in Tiled

1. Create a project with separate folders for editable maps, tilesets, and art. Create finite, orthogonal maps with the proposed 16 x 16 tile size. Save editable maps and tilesets under `maps/` and runtime JSON under `public/assets/maps/`, consistent with the project source/export split.
2. Choose a tileset based on the exported atlas image. Set tile width/height to 16, spacing and margin to 0 if the atlas uses no padding. Keep the editable tileset external so both maps share its definitions.
3. Create the exact layers below. Paint placeholders first; furniture proportions and traversal determine the final room footprint.
4. Paint the floor/grass into `ground`. Add rugs, small floor accents, wall art, and other fixed scenery into `details` where appropriate.
5. Place point markers for furniture and actors in `entities`. Assign stable `entityId` string properties. Under this project's proposed contract, runtime factories supply their sprites; these points alone will not show finished furniture in Tiled. Use labels and collision rectangles for the initial blockout. A sprite-preview workflow would be a later adapter/editor extension.
6. Add collision rectangles only over solid footprints. Add reachable interaction rectangles beside/in front of activity props. Add named spawn points and door trigger rectangles.
7. Export JSON with embedded tilesets and numeric tile arrays. The editable external tileset remains shared; Tiled's Embed tilesets export option creates the self-contained runtime representation. Verify image paths relative to the exported map location.
8. In Phaser, load the JSON with `load.tilemapTiledJSON`, load the atlas PNG separately, and bind the exact Tiled tileset name with `addTilesetImage`. Create tile layers and explicitly create Arcade static bodies/colliders from the collision rectangles. Camera bounds, physics bounds, and body offsets are separate settings.
9. Walk both maps in the game before adding decorative density. The repository currently contains planning and reference assets; the map adapter and playable scenes still need implementation.

| Layer | Type | Contents |
|---|---|---|
| `ground` | Tile | Floors, grass, basic path surfaces |
| `details` | Tile | Rugs, ground accents, fixed scenery |
| `entities` | Object / point | Bed, desks, shelf, trees, actors; stable `entityId` |
| `overhead` | Tile | Only artwork that should always cover actors |
| `collisions` | Object / rectangle | Walls, furniture bases, trunks, boundaries |
| `spawns` | Object / point | Named safe entry positions |
| `interactions` | Object / rectangle | Reachable activity areas; `interactionId` |
| `transitions` | Object / rectangle | Doors; `destinationMap`, `destinationSpawn` |

The game sorts actors and suitable props by foot position: walking behind a tree should put Phuong behind it, while walking in front puts her in front. A permanently overhead whole tree would incorrectly cover her in both cases. Use a runtime prop for this case and reserve overhead tiles for truly overhead pieces. Visual size and solid footprint are separate.

Terrain Brush can choose matching path edges automatically after terrain definitions are authored. Begin with manual painting; add Terrain Sets once the path shapes are stable. A full two-terrain corner set has 16 patterns; more flexible mixed sets need more artwork. Disable terrain flipping/rotation for the initial project validation contract; allow transforms later after a fixture verifies them. Tiled chooses existing artwork; it does not draw missing transitions.

Avoid infinite maps, compressed tile data, image-collection tilesets, nested groups, rotated objects, and flipped tiles in this first workflow. This deliberately narrow authoring contract avoids supporting untested cases; it does not imply Phaser lacks every feature on that list. Let Phaser decode tile IDs rather than reimplementing its parser.

## Door connection example

| Source | Trigger properties | Destination point |
|---|---|---|
| House front door | `destinationMap = outside`, `destinationSpawn = porch` | `porch` in the outdoor `spawns` layer |
| Outside house entrance | `destinationMap = house`, `destinationSpawn = entry` | `entry` in the house `spawns` layer |

Also author `bedside` as the opening spawn. Keep destination spawns outside the destination door trigger, on clear walkable floor, so arrival does not immediately send the player back. The game needs transition gating and validation; property names by themselves do not cause a scene change.

## First useful milestone

Build the bed corner and house exit, plus a porch and short outdoor path. Validate native art scale, walkability, foreground ordering, bed state change, and both door directions. Then extend the same two maps to the remaining house zones and outdoor loop.

Acceptance checks: all six activity locations are reachable; Phuong and Jasper fit through doorways; prompt areas remain visible; trees/furniture overlap correctly; both door returns are safe; bed/shelf/food results survive leaving and returning; terrain seams and exported paths are correct. Do these in the playable game, since an editor preview cannot prove runtime behavior.

## Official references

- [Tiled introduction](https://doc.mapeditor.org/en/stable/manual/introduction/): map creation and shared external tilesets.
- [Working with objects](https://doc.mapeditor.org/en/stable/manual/objects/): markers, shapes, and properties.
- [Using terrains](https://doc.mapeditor.org/en/stable/manual/terrain/): Terrain Sets, brush behavior, and transformations.
- [Export formats](https://doc.mapeditor.org/en/stable/manual/export/): export options including embedded tilesets.
- [JSON map format](https://doc.mapeditor.org/en/stable/reference/json-map-format/): runtime map representation.
