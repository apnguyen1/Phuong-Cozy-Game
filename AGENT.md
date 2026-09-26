# Phuong’s Cozy World

## Living theme and game plan

**Version:** 0.8 — September 26, 2026

**Stage:** First Roblox environment draft built; arrival-to-house construction authorized, with iterative visual review next.
**Purpose:** Keep the project’s personal meaning, scope, gameplay, and future implementation work in one evolving document.

This document records decisions from the planning conversation. Confirmed direction takes precedence over earlier brainstorms. Items marked **provisional** or **to decide** are starting points for discussion, not implementation requirements. Future agents should preserve the confirmed direction and update this document when decisions change.

**Current map direction (September 26, 2026):** Build toward Roblox while retaining Phuong's Cozy World. Design components individually, prioritize free community environment assets, identify any custom 3D asset gaps, and blend the component designs at the end. The active living plan is [Roblox map design](docs/roblox-map-design.md), with an [asset register](docs/roblox-asset-register.md). The user explicitly authorized the first arrival-to-house draft in the open Place1 and asked to resume after an intentional interruption. See [Draft 01](docs/roblox-draft01.md) for the built scope and validation. The older Phaser/Tiled implementation specification below is historical and does not govern Roblox authoring. Preserve the personal content, KISS-first approach, and reference art.

The expanded-Quad layout is approved. [Detailed component studies](docs/roblox-component-designs.md) now plan for up to eight players and a mix of cozy activities and playful group games. Real friends explore together throughout with independently rotatable third-person cameras. Shared flower progression, curated decoration spots, and a host-ready celebration are proposed mechanics, not fully locked implementation requirements.

## 1. The heart of the game

Phuong’s Cozy World is a birthday gift: a small, cute, explorable world built around Phuong’s interests, hobbies, habits, and favorite things.

She explores with Jasper and real friends, discovers activities she loves, and completes cozy quests. A proposed shared completion flower leads toward a live birthday gathering with cake. The group can stay in the world and continue exploring afterward.

**Core experience:** Discover a favorite activity → complete its quest → leave a personal touch in the world → fill the completion flower → celebrate with friends.

The game should make her feel recognized and loved. Its organizing idea is Phuong herself—not a workday schedule, waiting for her boyfriend, or preparing for his arrival.

### Design principles

- **Personal:** Recognizable details matter more than the number of systems.
- **Explorational:** She chooses which available quest to follow and discovers small surprises between destinations.
- **Cute and tactile:** Tucking in plushies, placing tiny furniture, annotating a passage, and arranging figures should feel satisfying.
- **Gently structured:** Quests give purpose and fill a visible completion meter without creating pressure.
- **Affectionate:** Jokes about snoozing and Jasper’s antics should feel fond, never critical or humiliating.
- **Lasting:** Finished activities leave visible changes in her world.
- **Celebratory:** Completing the day leads to friends, cake, and birthday wishes; exploration remains available afterward.

## 2. Format and scope

| Item | Direction |
|---|---|
| Genre | Cozy multiplayer 3D exploration with independently rotatable third-person cameras |
| Recipient | Phuong |
| Platform | Roblox; target devices to confirm during map prototyping |
| Session length | Approximately 30 minutes for the main experience |
| Visual inspiration | Soft, stylized 3D with warm colors, retaining cozy exploration and relaxed discovery |
| World | A compact neighborhood with her house as its central hub |
| Players | Up to eight players; real friends participate throughout |
| Progression | Six main activity quests; one shared completion flower proposed |
| Ending | Friends gather in the birthday courtyard for a live cake celebration |
| After the ending | Continue exploring, collecting, decorating, and revisiting activities |
| Initial exclusions | Mobile support, extensive farming, an economy, seasons, relationship simulation, and a large open world |

The game will **not reproduce her existing Stardew Valley farm arrangement**. No farm screenshots are needed to establish the layout.

## 3. World and places

The current Roblox layout follows the user's September 25 sketch: Phuong's house at the north-center, Jasper's dog park northeast, birthday celebration area southeast, arrival plaza and 24th birthday sign south-center, and U District along the western edge. The user subsequently extended the blossom Quad into a continuous landscape across the central grounds, with roads and paths overlaid on it and outdoor minigame clearings in the western lawn. A central walking route connects arrival to the house, with cross-paths toward each destination and blossom planting on both sides. This replaces the earlier northwest-house/northeast-Quad layout. See the active [Roblox map design](docs/roblox-map-design.md) for proposed dimensions and component briefs.

**Provisional production scope:** One outdoor map and one house interior. Exact dimensions, transitions, and building interiors remain to be decided.

| Place | Main purpose and details |
|---|---|
| House | Green-sheeted bed, weighted dog and dinosaur plushies, Kindle nook, computer, craft desk, coloring supplies, books, collection shelves, and Jasper’s toys |
| Arrival and paths | South-center arrival with a 24th birthday sign, main approach to the house, and branching connections |
| Jasper's dog park | Northeast lawn for fetch, rabbit discoveries, shade, and a sniffing corner |
| UDistrict-inspired street | Cute storefronts, collectible displays, food references, and a possible nail salon detail referencing her mom |
| UW-inspired blossom Quad | Continuous central blossom landscape beneath the road/path network, with benches, reading, Lisa encounter, and western outdoor minigame clearings; specific new minigames remain to be chosen |
| Cooking courtyard/patio | KBBQ and seafood activity, followed by the birthday gathering |

Paths should form an easy-to-understand network around the arrival-to-house route, with short western loops and eastern branches. Destinations should be close enough that walking is enjoyable rather than filler. Collectibles and small visual interactions reward detours.

### Optional environmental ideas

These are candidate details, not additional required quests:

- A coloring page that can be displayed at home.
- A nail-art station or a birthday note at the salon.
- A tiny farm game visible on her computer.
- Fictional short-form clips she can send through an in-game boyfriend chat.
- Small nods to Barbie, Minecraft, Game of Thrones, favorite music, and clothing.
- An explorable close-up of the completed miniature, if production time allows.

## 4. Main playthrough

### Arrival in the world

The user's updated layout introduces an arrival plaza and 24th birthday sign at the southern entrance. Proposed opening: Phuong arrives here with a clear view toward her house. The earlier bedroom wake-up opening is superseded as the default; its optional snooze interaction can remain a home vignette. Exact opening storytelling and Jasper's initial position are still to be designed.

The journal introduces **“A Day Full of Favorite Things.”** Six illustrated quest slots correspond to the six petals of the completion flower. All main quests are available from the beginning; she can make the bed first or go exploring.

Movement and interaction instructions appear briefly when useful. The opening should get her playing quickly.

### Exploration and quests

She follows her curiosity between the house, UDistrict street, Quad, and courtyard. Each quest has a clear activity, a forgiving completion condition, and a visible or collectible result.

The journal provides a short next-step hint and a location cue when needed. It should help her find an activity without turning the screen into a dense task list.

### Completion and celebration

Proposed shared progression: the sixth unique completed quest fills the final petal and makes the celebration ready. Real friends already playing in the world receive a gentle invitation to gather at the birthday courtyard.

The cake moment waits for the group. A host-ready action is proposed so it does not start while someone is exploring or reconnecting; exact host permissions remain open. This replaces the earlier scripted arrival of NPC friends and home-door finale trigger for the active Roblox design.

Phuong's proposed **“Make a wish”** interaction extinguishes the candles and adds restrained confetti. Birthday wishes come from the real people present. The world remains open for photos, decorating, and exploration afterward.

## 5. The six main quests

| ID | Quest | Activity | Completion result |
|---|---|---|---|
| Q01 | Everything Tucked In | Smooth green sheets, align pillows, position the weighted dog and dinosaur, and tuck them in | Bed remains made; both plushies peek out; one petal fills |
| Q02 | Jasper’s Favorite Things | Find his misplaced rabbit, play fetch, and give him a Greenie | Happy Jasper portrait enters the scrapbook; one petal fills |
| Q03 | A Tiny World of Her Own | Assemble and decorate a miniature reading nook | Finished miniature lights up and remains displayed; one petal fills |
| Q04 | One More Chapter | Choose a reading spot, open the Kindle, highlight a passage, and add an annotation | Annotation and bookmark enter the scrapbook; one petal fills |
| Q05 | Little Treasures | Discover three hidden figures and arrange them on her shelf | Collection visibly grows; one petal fills |
| Q06 | Something Delicious | Grill a small KBBQ serving and assemble a seafood-boil platter | Finished dishes appear on the patio table; one petal fills |

**Pacing target:** Approximately three to four minutes per main quest, with exploration and the celebration bringing the experience to about 30 minutes. Validate this through playtesting.

### Shared quest rules

- The six quests can be completed in any order.
- Each main quest fills exactly one petal; partial steps are tracked in the journal.
- Proposed multiplayer rule: award that petal once for the shared session; late arrivals see the existing state without repeating every activity.
- Replaying a completed activity must not award another petal.
- Completed steps should persist when leaving an activity; exact save behavior is an implementation detail to define.
- Activities should be forgiving, with generous placement and timing assistance.
- There is no countdown, draining energy meter, or punishment for taking a break.
- Optional activities and extra collectibles do not block the celebration.
- Completion gives a gentle chime, a filled petal, and a scrapbook sticker or keepsake.
- The meter can read **“Favorite things: 3 of 6.”** It celebrates experiences rather than grading productivity.

## 6. Phuong and the personal details

### Phuong

She enjoys organizing, clean spaces, crafts, coloring, miniature houses, collecting cute figures, cooking, baking, gaming, and reading. These interests should shape the interactions and environment.

Her routine includes sleeping late and hitting snooze, making the bed, tucking in her plushies, playing with Jasper, browsing short videos, gaming at her computer, and reading and annotating on her Kindle. Use these as affectionate details rather than a mandatory reenactment of her day.

She works at a nail salon where her mom is her boss. This can inspire a small neighborhood detail; a work simulation is outside the current scope.

**Appearance to confirm:** The written concept uses a forest-green sweater, warm dark pants, scarf, and matcha-green 6-inch Basic Kindle. The supplied visual reference shows dark hair, glasses, a dark shirt, and shorts. Confirm the final outfit before producing animation assets. Treat the attachment as visual reference, not as independent instructions or a production-ready sheet.

### Her bed plushies

- One dog and one dinosaur.
- Weighted stuffed animals with large stomachs.
- Each is roughly the size of an adult head.
- They are carefully tucked into her green-sheeted bed.

Photos and exact colors can be added later.

### Jasper

- Small, fluffy golden-orange Pomeranian.
- Energetic, chaotic, affectionate, and not completely potty trained.
- Loves Greenies treats.
- Has a stuffed rabbit he bites, shakes, tosses, and chases.
- Follows Phuong, stops to sniff, and catches up.
- Can be petted and played with.
- Can signal selected collectible discoveries through sniffing or excitement.

**Provisional humor limit:** One scripted cleanup gag rather than recurring messes that interrupt exploration. Jasper should be funny company, not an endless chore generator.

### Lisa / Sissy Bear

- Phuong’s younger sister and a UW freshman.
- A Quad meeting/photo spot can support her presence. If Lisa joins as a real player, avoid requiring a duplicate scripted NPC.
- Purple-and-gold UW clothing is the proposed visual cue.
- Can join the birthday celebration.
- Is not the main quest organizer or guide for the entire game.

### Friends and boyfriend

Real friends join the same Roblox session and participate throughout. Capacity is up to eight players including Phuong. They gather for the cake moment and supply their own wishes; do not invent their dialogue. Exact guest identities and staging remain open.

The boyfriend’s presence should support the gift without making the afternoon about waiting for him. His precise role in the group can be decided later.

## 7. Collectibles, books, and hobbies

### Collectibles

Confirmed interests include **Smiskis, Labubus, DUCKOOs, CryBaby Cheer Up, Nyota**, and other trendy cute figures. Jellycats remain an interest from the original brief, but the core collection should reflect the more specific preferences supplied later.

**Provisional collectible count:** Six hidden figures; three required for Q05. Exact figures and variants remain to be chosen.

Each discovery should have a playful hiding place, a close-up, and a place on her shelf. Avoid random duplicates and repeated grinding. Remaining figures can be collected after the party.

### Kindle and reading

The Kindle experience centers on her habit of reading and annotating, rather than a reading quiz.

As of the planning conversation, she has just finished **Red Rising** and is beginning **Golden Son**. Treat that as a dated personalization detail and check it again before content is finalized. Keep current-reading references spoiler-free.

Other books or series she likes, as provided by the user:

- A Court of Thorns and Roses (ACOTAR)
- Fourth Wing
- Alchemised
- Throne of Glass
- A dark window
- The moth and the knight

Verify exact titles and capitalization with the user before creating final shelf labels or book art; do not silently replace uncertain titles.

The playable annotation activity uses a short original fantasy passage, with highlight and reaction options. Favorite titles can personalize the library around it.

### Wider interest bank

Stardew Valley, Minecraft, fall, green, rainy-day coziness, Rolife miniatures, coloring, crafts, baking, cooking, KBBQ, seafood boil, massages, Barbie movies, Taylor Swift, KATSEYE and “hootie fruitie” as supplied, Game of Thrones, Aritzia, UW, organization, and cute trinkets.

This is an inspiration bank, not a requirement to create a mechanic for every interest. Confirm ambiguous references before using them in finished content.

## 8. The personal birthday note — user authored only

**The boyfriend will write this note manually, from the heart.**

No agent should generate, complete, paraphrase, or replace the note. Editing should happen only if he specifically requests it. The game should provide a place to present his exact words.

**Content status:** Not yet supplied. Keep the slot empty in production planning; do not insert a sample sentimental letter.

The note can be presented as one of the gifts during the celebration and remain available to read afterward. Exact presentation and whether it includes recorded audio are to be decided.

## 9. Visual, sound, and interaction direction

### Confirmed direction

- Soft, stylized 3D with warm colors for the current Roblox map. The following pixel-art choices describe the earlier reference workflow, not the current 3D production pipeline.
- **A — Compact** character proportions, selected from the generated comparison; exact sprite dimensions still require a native-pixel test.
- Hybrid art production: generated visual references, finished and animated in Aseprite. See [the art and map plan](docs/art-and-map-plan.md) and its saved comparison reference. Appearance details in that reference are provisional.
- Desktop/laptop browser play; mobile can come later.
- Keyboard movement using WASD or arrows, with E to interact.
- Clear prompts, readable text, and gentle feedback.
- Warm greens, comfortable interiors, cute collectibles, and UW cherry blossoms.
- Music and effects should complement the activities and Jasper’s personality.

### Provisional implementation ideas

- Aseprite for sprites and Tiled for maps are now selected; export conventions are specified in section 10.
- Original gentle chiptune music with a warm pop/lofi mood, plus interaction effects.
- Web Audio synthesis for music or effects, with optional recorded audio assets.
- Keyboard-accessible activity controls, with optional mouse support for placement.
- Journal shortcut, pause/back controls, and separate music/effects volume settings.
- Saved progress so she can return later.

Exact resolution, tile sizes, sprite sizes, animations, map format, audio pipeline, and accessibility settings belong in the next implementation revision.

## 10. Historical Phaser technical plan and engineering conventions

**Superseded for the active Roblox map design as of September 25, 2026.** Retained for project history and the prior web concept. Roblox implementation details will be established after the component designs; do not apply Phaser, Tiled, pixel-scale, or browser-release requirements to Roblox work.

This revision specifies implementation; it does not start coding or deploy the game. The stack and coding rules below are user-selected. Architecture, dimensions, and workflow choices marked **proposed defaults** are recommendations to validate in the playable slice, not additional confirmed creative decisions.

### 10.1 Selected stack

| Tool | Responsibility |
|---|---|
| Phaser | Rendering, scenes, input, Arcade Physics, tilemaps, animation, and audio playback |
| Vite | Development server and production bundling |
| TypeScript | Game code and explicit data/interface contracts |
| Aseprite | Editable pixel art and sprite animation sources |
| Tiled | World layout, collision rectangles, spawn points, and interaction placement |

Use Context7 MCP to resolve the relevant library and consult current documentation before implementing unfamiliar APIs. Check examples against the installed version and its types; documentation for a newer release does not authorize mixing APIs. Select stable compatible package versions when scaffolding, record them in package.json and the lockfile, and document the required Node version. Exact versions and hosting provider remain open.

**Engine change:** Phaser replaces KAPLAY and supersedes the earlier `k` instance convention. **Proposed baseline:** pin Phaser **4.2.1**, the official stable release verified on September 20, 2026, and verify the bedroom slice against that version. Context7's version listing includes 3.90.0 and retrieved examples can target other versions; corroborate version-sensitive behavior with the 4.2.1 source/types. Do not mix Phaser 2/CE, Phaser 3, and Phaser 4 renderer/plugin instructions. Phaser Editor is optional; Aseprite and Tiled remain the authoring tools. No engine package is installed yet.

### 10.2 Mandatory coding conventions

- KISS is the primary design rule. Apply SOLID through focused responsibilities, composition, and explicit dependencies; do not introduce class hierarchies, dependency-injection containers, generic repositories, or a second entity-component framework without a concrete need.
- Create exactly one `Phaser.Game` in the entry point. Use focused `Phaser.Scene` subclasses and explicit scene APIs such as `this.add.sprite()`, `this.physics.add.sprite()`, and `this.load.aseprite()`. Pass a typed scene or narrower dependency to entity factories; engine-free state modules never import Phaser. Ordinary functions remain the default outside Phaser's lifecycle classes. No global `k` or compatibility wrapper is needed.
- Write idiomatic modern TypeScript/JavaScript. Use `const` by default and `let` when reassignment is needed; never `var`. Use destructuring, arrow functions, and array methods when they make intent clearer. A readable loop is preferable to a clever `reduce`.
- Keep input callbacks short: check the current input mode and delegate to named controller functions. Extract complex branching and avoid deeply nested handlers.
- Separate durable game state from Phaser objects. Objects may own transient movement, animation, and collision state; quest progress, inventory, keepsakes, and celebration progress belong in the plain state store. Do not duplicate that state in the Phaser registry or Scene Data Managers.
- Use exported module-level constants for fixed shared values such as `PLAYER_SPEED`, `TILE_SIZE`, and interaction distance. These are the project's equivalent of final globals, without adding properties to `window`. Keep feature-only constants close to their use.
- `const` prevents reassignment, not object mutation. Use `as const` or readonly types for configuration at compile time; use runtime freezing only if a concrete problem requires it.
- Put repeated content in typed data tables and map coordinates in Tiled. Keep unique activity behavior in straightforward code. Do not build a configuration language for six quests.
- Prefer small functions and cohesive feature modules. Split files when responsibilities diverge, not to achieve a target file count. Introduce shared helpers after a real repeated pattern emerges.
- Enable strict TypeScript checking. **Proposed additions:** `noUncheckedIndexedAccess`, `exactOptionalPropertyTypes`, and `verbatimModuleSyntax`; use `import type` for types. Prefer literal unions and ordinary objects over elaborate generic types.
- Avoid `any`, unchecked non-null assertions, and casts that conceal invalid data. Parse external data as `unknown` and validate at save/map boundaries. TypeScript types alone do not validate JSON at runtime.
- Comments explain constraints or intent; names and functions explain routine behavior. No health, combat, or score system is implied by the generic state-management guidance.

### 10.3 Proposed module structure

Create only the files needed for the current milestone; this is a growth map, not a scaffolding checklist.

```text
src/
  main.ts                 # Create store and one Phaser.Game, register scenes
  config.ts               # Shared tuning constants and input bindings
  assets.ts               # Asset names, URLs, and loading
  state/
    game-state.ts         # Types, initial state, commands, subscriptions
    save.ts               # Save validation, serialization, storage adapter
  scenes/
    boot.ts               # Load shared assets and register animations once
    house.ts
    neighborhood.ts
    ui.ts                 # Persistent HUD plus one activity/dialogue overlay
  world/
    tiled.ts              # Validate our map contract; adapt Phaser tilemaps/objects
    interactions.ts       # Select one nearby interaction and dispatch it
  entities/
    player.ts
    jasper.ts
  quests/
    definitions.ts        # Six quest IDs, steps, hints, rewards
    progression.ts        # Completion rules and finale eligibility
  activities/
    session.ts            # Open/close, input ownership, cleanup contract
    bed.ts                # Add other activity modules as implemented
  ui/
    journal.ts
    hud.ts
    dialogue.ts
  audio.ts                # Music ownership, sound playback, volume settings
art/                      # Editable .aseprite files
maps/                     # Editable Tiled maps, tilesets, and project file
public/assets/            # Exported runtime art, map JSON, and audio
```

Dependencies flow from scenes/controllers into state and rendering helpers. State and quest rules do not depend on scenes, DOM, or Phaser. Pass only needed dependencies; do not pass a universal services object to every function. Start with direct function calls and a small store subscription API; introduce a typed event bus only if several independent consumers need it.

Proposed lifecycle: Boot loads shared assets, then starts House and launches UI once. House and Neighborhood replace each other; UI stays active and renders the store. Use `init` for per-entry scene data, `preload` for loading, `create` for objects/controllers, and `update` for movement and selection. Constructors do not run again on every restart. Reset transient fields in `init`, and detach external subscriptions on `SHUTDOWN`, not only final destruction. Add a separate preload scene only if the loading screen warrants it.

### 10.4 State, quests, and durable results — proposed defaults

Use one store created at startup, containing a serializable `GameState`. It owns controlled command functions and exposes a readonly snapshot plus `subscribe()` returning an unsubscribe function. Subscribers update presentation after a command; UI code never mutates the state directly. Keep IDs stable even when displayed text changes.

| State area | Data to retain |
|---|---|
| Location | Map ID and a known safe spawn/checkpoint ID |
| Quests | Per-quest completed step IDs and any activity-specific progress |
| Collection | Unique discovered figure IDs and shelf placements |
| Home | Bed placements and miniature piece placements |
| Reading | Selected passage/highlight/annotation and bookmark |
| Jasper | Quest actions completed, rabbit found, portrait reward |
| Cooking | Validated preparation stages and completed dishes |
| Keepsakes | Unique scrapbook entries earned |
| Celebration | `locked`, `invited`, `gathered`, or `celebrated` |
| Settings | Music/effects volume and supported display/input preferences |

Transient input mode, selected interaction, animation frames, timers, Phaser objects, and DOM nodes are not serialized. Do not duplicate a saved fact when it can be derived: petal count comes from the six completed quests; made-bed and finished-dish visuals come from the corresponding activity state.

Commands such as `completeQuestStep(questId, stepId)` validate IDs and prerequisites, ignore an already-completed step, and award each quest/reward once. Quests are available in any order; steps within a quest may have prerequisites. Derive quest completion from required steps in the definitions table. Q05 requires three unique figures and their shelf arrangement, not repeated discovery of the same figure.

The sixth completion changes celebration state to `invited`. Only interacting with the home door advances it to `gathered`; the cake action advances it to `celebrated`. Re-entering a scene or reloading reconstructs the appropriate friends, cake, and world results without replaying rewards. After celebration, activities remain available and do not reset completed quests.

### 10.5 Activities, input, and lifecycle — proposed defaults

An activity opens as an overlay owned by the UI scene, with the originating world scene and return position recorded. Pause the world scene while the UI scene stays active; stop world velocity before pausing, gate its keyboard input explicitly, and restore input on close. Begin with three shared responsibilities: open with existing progress, commit validated steps through store commands, and dispose on exit. Each activity can have its own controls and internal structure; share placement/highlight helpers only when genuinely reusable. Do not create one permanent scene per activity.

- One explicit runtime input mode: exploration, activity, dialogue, journal, paused, or transition. Opening an overlay blocks world movement/interactions and overlapping overlays.
- WASD/arrows move; E interacts; Escape closes or pauses as appropriate. **Proposed:** J opens the journal. Activities expose keyboard alternatives for selecting, placing, and confirming items.
- Use Arcade Physics with zero X/Y gravity for top-down walking. Normalize the movement vector and set velocity in pixels per second; Arcade performs time integration. Use `delta / 1000` only for manually integrated non-physics motion. Stop velocity when controls are released or blocked. Clear held input on focus loss, pause, or scene changes.
- Select one eligible nearby object by distance, then stable ID to break ties. The visible prompt and E action refer to that same object. Use a press event for discrete interaction.
- Commit partial progress at meaningful steps. Cancelling preserves committed steps and discards only the unfinished gesture. Replaying a completed activity may change decoration but never grants another petal.
- Closing an activity returns control at its original valid world position. Reloading returns to a safe scene checkpoint with committed progress, rather than resuming a half-finished drag or timing animation.
- Dispose activity input handlers, timers, tweens, UI objects, and store subscriptions on close or scene shutdown. Phaser manages its own scene resources, but listeners attached to the store, game events, DOM, and other long-lived emitters need explicit removal. Repeated entry must not multiply callbacks. An overlay does not automatically block every other scene's keyboard listeners.
- One scene transition at a time; destination/spawn IDs are validated before switching. Rebuild dynamic decoration from saved state.

### 10.6 Tiled map contract — proposed defaults

Start with one finite orthogonal outdoor map and one house map. Proposed art grid: **16 x 16 pixel tiles**, with a **640 x 360 logical viewport**, nearest-neighbor rendering, and letterboxing. Prototype readability and movement before producing final art. Map dimensions and final character frame dimensions remain provisional.

Use Phaser's built-in `this.load.tilemapTiledJSON()`, `this.make.tilemap()`, `map.addTilesetImage()`, and tile layers. Keep a thin project adapter for validation, entity factories, and our object-layer metadata; do not rewrite Tiled tile decoding. The following is our deliberately limited initial authoring contract, not a list of Phaser's limits:

- Export finite maps with numeric tile-data arrays and embedded atlas tilesets; use one atlas initially. Keep editable sources separately. Reject infinite/chunked maps, compressed tile data, image-collection tilesets, rotated objects, and unsupported nested layers with useful validation errors.
- Layers: `ground` and `details` tile layers; an `entities` object layer for dynamic props; `overhead` tiles for canopies/roofs; `collisions`, `spawns`, `interactions`, and `transitions` object layers. Validate required names and supported object shapes.
- Use unrotated rectangles for solid collision and trigger regions, and point objects for named spawns and entity origins. Create static Arcade bodies from collision rectangles and explicitly register player colliders. Use overlaps/containment for door triggers and interaction eligibility. Tiled object rectangles do not become bodies automatically. Render collision regions invisibly in production and with a debug overlay in development. If tile-property collision is added later, mark the relevant tiles collidable and register a tile-layer collider; avoid doubling collision coverage with rectangles.
- Use authored string properties such as `entityId`, `interactionId`, `destinationMap`, and `destinationSpawn`, with unique stable IDs. Position lives in Tiled; activity behavior lives in TypeScript. Validate property types, duplicate IDs, and references.
- Let Phaser handle empty tiles and tileset GIDs. Match the tileset name authored in Tiled to `addTilesetImage` and separately supply the loaded texture key; load the PNG explicitly. Keep flipped/rotated tile IDs out of the initial validation contract until exercised in a fixture, even though Phaser supports tile transforms.
- Set actor origins to bottom-center, keep physics body size/offset explicit near the feet, and verify alignment in the physics debug view. Origin changes alone do not define the collision footprint. Sort actors and props by foot Y within a reserved world depth band; ground stays below and overhead stays above the maximum world depth. Keep UI in its own scene. Avoid putting independently sorted world props in different Containers, where depth values cannot interleave across parents.
- Resolve map/atlas asset URLs consistently with the exported directory structure. Include a tiny map fixture with a wall, spawn, interaction, and door in the first slice to verify coordinates and round-trip export.

The map adapter validates before rendering or changing scenes. Missing spawn points, unmatched tileset names, or invalid assets should produce an actionable load error, never a partly initialized world. Set both camera and physics world bounds explicitly; they are different systems. Center maps smaller than the viewport and test door spawns outside triggers.

### 10.7 Aseprite and asset pipeline — proposed defaults

**Reference assets available:** [Phuong, Lisa, and Jasper sprite sheets](art/references/sprite-sheets/README.md), plus the [editable Phuong animation draft and previews](art/characters/README.md). The user requested that these remain references, not final production models. The local Aseprite MCP has successfully created a layered native sprite, directional animation tags, and PNG/JSON/GIF exports. Only Phuong has a native Aseprite draft so far; Lisa and Jasper have generated reference sheets. The draft's 24 x 32 canvas does not finalize character dimensions.

Keep editable `.aseprite` files and exported runtime assets in version control initially; do not require every developer to own Aseprite just to run the game. Use lowercase kebab-case filenames and stable asset IDs.

Export PNG plus Aseprite JSON **array** metadata; load with `this.load.aseprite(key, pngUrl, jsonUrl)` in Boot's `preload`. After loading, `this.anims.createFromAseprite(key)` can register exported tags. Use Aseprite's item filename template **`{frame}`** (numeric frame names); the existing reference export uses other names and must be re-exported before using this convenience method. Keep equal untrimmed frames, a consistent foot anchor, and forward tags initially.

Global animation keys must identify the character: production tags such as `phuong:idle-down` and `phuong:walk-down`, with corresponding Lisa/Jasper prefixes. Register once, set walking to repeat indefinitely, and avoid restarting the same animation on every update (`play(key, true)`). Reference sheets retain their original names; verify frame names, loops, and timing in Phaser before bulk production. This does not promote the references to final assets.

Record the export command/settings alongside the sources. An asset manifest maps IDs to files; game logic uses IDs instead of scattered URL strings. A small validation step checks referenced files, expected frame sizes/tags, map IDs, and required layers. Public-asset URLs must include Vite's `import.meta.env.BASE_URL` so a deployment under a subpath works.

Load required assets before entering play and show a readable loading/failure screen. Validate one Phuong placeholder, one Jasper placeholder, and one tileset before final art production. Outfit, palette details, and personal references still require the content decisions listed elsewhere in this document.

### 10.8 Persistence and audio — proposed defaults

Use one localStorage save slot with a versioned envelope, for example `{ schemaVersion: 1, state: ... }`. Save after meaningful committed steps, scene checkpoints, settings changes, and celebration transitions; do not write every frame or rely on tab-close events. The save adapter catches parsing and storage errors.

Validate shape, known IDs, allowed values, and quest/celebration consistency before restoring. Unsupported or corrupt saves must not be silently overwritten: offer a fresh session without replacing the original until the user explicitly resets. Storage failure allows play to continue with a visible notice that progress cannot be saved. Reset requires confirmation. Add migrations only when an actual schema change exists. Saves are specific to the browser profile and site origin; development and deployed sites do not share them.

Use one audio owner over Phaser's Sound Manager so scene transitions cannot stack music. Start audio after a player gesture, retain separate music/effects volumes, pause appropriately on focus loss, and keep gameplay usable when sound cannot play. Scene transitions do not imply that shared music should restart. Evaluate custom synthesis only if it serves the chosen music direction. Audio content and final formats remain to be selected and tested on the target browser.

### 10.9 Development and verification — proposed defaults

Use the vanilla TypeScript Vite setup, npm with a committed lockfile, ESLint with TypeScript support, and Prettier. Keep the runtime dependency set small. Proposed scripts: `dev`, `typecheck` (`tsc --noEmit`), `lint`, `test` (Vitest), `build`, and `preview`. Production `build` must run type checking before `vite build`: Vite transpiles TypeScript but does not itself type-check it.

Use Phaser's bundled TypeScript definitions. Begin with `Phaser.AUTO`, pixel-art rendering, camera pixel rounding, and a fit/center scaling policy for the proposed 640 x 360 canvas. FIT may use fractional display scaling; validate crispness on the target laptop and use integer display scaling/letterboxing if needed. Keep gameplay coordinates in native world pixels. Test graphics support and load failures early. For initial Vite development, prefer a full page reload for engine changes; if accepting hot updates later, destroy the old game to avoid duplicate canvases, listeners, and audio.

Test behavior that could lose progress or block completion:

- Quest commands are idempotent, obey step prerequisites, and accept different quest orders; a petal is awarded exactly once per quest.
- Unique collectibles and arrangement determine Q05 completion; optional collectibles do not gate the finale.
- Save round trips retain partial activity progress; invalid/unsupported saves and unavailable storage are handled without silently overwriting data.
- Map validation catches unsupported formats, duplicate IDs, and missing destinations; a small fixture confirms tile coordinates and collision placement.
- The finale unlocks only after six quests and advances only through the door/cake interactions, including after reload.

Use browser playtesting for movement, collisions, depth sorting, interaction prompts, keyboard-only activity completion, focus loss, audio, and repeated open/close/scene entry. Test production preview with the intended base path. Add automated browser tests only when the first slice offers a stable player-facing flow; do not chase coverage targets or snapshot every decorative object.

Before a milestone is complete, run type checking, lint, relevant tests, and production build, then play the changed flow. The release rehearsal covers a fresh full run, a different quest order, mid-activity reload, post-party exploration, and the target laptop/browser. Hosting remains a later decision; the expected deliverable is Vite's static build.

### 10.10 First implementation slice and acceptance gate

**Proposed next coding scope:** one Tiled-authored bedroom, placeholder Phuong movement and collision, one Jasper pet interaction, the complete bed-making activity, a one-petal HUD/journal update, and save/reload. Use the real asset/import pipeline even with placeholder visuals.

Accept the slice when she can enter, move, interact, finish the bed using only the keyboard, leave/reopen the activity without lost committed steps, and reload with the bed still made and exactly one petal. Repeated interaction must not duplicate input handlers or rewards. Verify one blocked wall, one correctly layered prop, valid spawn placement, asset-load failure handling, and a successful production build. Expand to the second map and all six quests only after this foundation is proven.

Phaser-specific gate: correct zero-gravity movement and diagonal speed; foot-sized collisions; a Tiled map plus object metadata; all four animation directions with looping and distinct character keys; clean scene restart; UI modal input isolation; camera/physics bounds; and sharp art at the intended display size. An early doorway fixture may use a minimal outside map to verify both directions before building the full neighborhood.

### 10.11 Reference notes

Documentation consulted September 20, 2026:

- [TypeScript Design Goals](https://github.com/microsoft/TypeScript/wiki/TypeScript-Design-Goals): language-design context for idiomatic JavaScript and erasable types; not an application coding-style checklist.
- [Phaser stable release](https://phaser.io/download/release/v4.2.1): version baseline checked at revision time.
- Context7 `/phaserjs/phaser`: scene lifecycle, Arcade Physics, Tiled loading, and Aseprite integration. Check example versions against the installed package.
- [Phaser scenes](https://docs.phaser.io/phaser/concepts/scenes), [4.2.1 Aseprite loader](https://github.com/phaserjs/phaser/blob/v4.2.1/src/loader/filetypes/AsepriteFile.js), and [4.2.1 animation manager](https://github.com/phaserjs/phaser/blob/v4.2.1/src/animations/AnimationManager.js): source corroboration for loading, numeric frame names, and global animation keys.
- Context7 `/vitejs/vite`: [TypeScript behavior](https://vite.dev/guide/features.html#typescript) and [public base paths](https://vite.dev/guide/build.html#public-base-path).
- [Tiled JSON format](https://doc.mapeditor.org/en/stable/reference/json-map-format/) and [Aseprite export CLI](https://www.aseprite.org/docs/cli/). The restricted export contracts above are project choices.

## 11. Dedicated subagent jobs — provisional responsibility map

These are proposed future assignments. No agents are being dispatched and no code is requested at this stage. Final briefs must specify owned files, dependencies, interfaces, acceptance checks, and scope limits before implementation starts.

| Role | Dedicated responsibility | Expected deliverable |
|---|---|---|
| Design and content | Quest details, hints, environmental writing, friend dialogue from supplied details; excludes the personal note | Approved content and quest specification |
| Technical foundation | Movement, camera, collisions, interaction selection, scene transitions, common activity interface | Playable placeholder foundation |
| Art and asset pipeline | Palette, sprite specifications, asset checklist, export rules, reference preparation | Consistent asset guide and verified sample exports |
| World integration | House, street, Quad, courtyard, map import, placement, collision, navigation | Fully traversable compact world |
| Jasper and collectibles | Following, petting, rabbit play, treats, discovery hints, collection interactions | Jasper behaviors and collectible system |
| Home activities | Bed-making and miniature assembly, using shared activity interfaces | Two complete, replayable activities |
| Reading and cooking | Kindle annotation and KBBQ/seafood activities | Two complete, replayable activities |
| Progression and interface | Journal, quest state, six-petal meter, persistence, finale trigger | Reliable progression across activity order and reloads |
| Audio | Music moods, interaction sounds, playback and volume behavior | Integrated audio with consistent controls |
| Celebration and release | Friend arrival, cake interaction, user-authored note display, post-party state, deployment and playtesting | Complete birthday experience and tested delivery |

One integration owner should coordinate shared interfaces and state. Assignments may be combined if a smaller team is more practical. Agents must not independently invent conflicting quest, save, input, or audio systems.

### Required structure of each future assignment

1. Purpose and player-facing result.
2. Owned files or feature area.
3. Required inputs and dependencies.
4. Shared interfaces and events.
5. Behavior on completion, cancellation, replay, and reload.
6. Acceptance criteria and appropriate verification.
7. Explicit exclusions and unresolved decisions.

## 12. Implementation milestones — provisional

1. **Playable slice:** One room, movement, Jasper interaction, one complete activity, and a browser preview.
2. **Complete placeholder game:** All six quests, the world loop, progress tracking, and the birthday celebration.
3. **Personalization:** Finished art, collectible choices, book details, friends, music, and the user’s exact note.
4. **Birthday rehearsal:** Full fresh playthrough, alternate quest order, save/reload checks, keyboard use, audio settings, and target-laptop testing.

If scope must shrink, reduce decorative breadth and animation complexity before removing personal details or the birthday celebration.

## 13. Details to collect later

- Birthday deadline and available development time.
- Final Phuong outfit and character references.
- Photos or descriptions of the weighted dog and dinosaur, Jasper’s rabbit, and favorite shelf/craft details.
- Specific collectible variants and the sixth collectible choice.
- Friends’ names, appearances, birthday wishes, and desired role for the boyfriend.
- Cake appearance and celebration staging.
- Exact book-title spellings and updated reading status.
- Which optional hobbies deserve small interactive moments.
- Target laptop/browser and delivery/access preferences.
- Final art and music details, hosting provider, package versions, and validation of proposed technical defaults in section 10.
- The personal birthday note, supplied directly by the user when ready.

## 14. Decision history

| Date | Decision |
|---|---|
| September 26, 2026 | User approved first-draft construction in Studio and iterative revision; built the arrival, continuous blossom Quad/path network, cottage shell, and neighboring destination placeholders |
| September 25, 2026 | Approve expanded-Quad map; plan up to eight players and a mix of cozy and playful outdoor activities; record detailed component studies |
| September 25, 2026 | Reconcile current planning with the prior confirmed Roblox direction: real friends participate throughout with independent rotatable third-person cameras; shared flower and host-ready celebration remain proposals |
| September 25, 2026 | Target Roblox, retain Phuong's Cozy World, choose soft warm stylized 3D, prioritize free community assets, and design components before final blending; see the active Roblox map design and asset register |
| September 25, 2026 | Adopt the user's sketched layout with south arrival/24th birthday sign, north-center house, northeast dog park, southeast birthday area, center-left blossom Quad/minigames, and western U District |
| September 25, 2026 | Extend the blossom Quad across the central grounds, with the roads and paths overlaid on the shared landscape |
| September 20, 2026 | Establish a short, desktop-browser birthday game inspired by Stardew Valley |
| September 20, 2026 | Replace reconstruction of her farm with a house-centered neighborhood, UDistrict street, and UW Quad |
| September 20, 2026 | Make Phuong’s interests and exploration the focus; remove waiting-for-boyfriend framing |
| September 20, 2026 | Use six activity quests to fill a day-completion flower |
| September 20, 2026 | End main progression with friends arriving with cake and birthday wishes; allow continued exploration |
| September 20, 2026 | Reserve the personal birthday note for the user to write manually |
| September 20, 2026 | Create this living document; defer final technical choices and detailed agent briefs |
| September 20, 2026 | Select KAPLAY, Vite, TypeScript, Aseprite, and Tiled; establish explicit k usage, separate game state, modern TypeScript, and KISS-first modularity; document proposed implementation contracts and first-slice acceptance criteria |
| September 20, 2026 | Select hybrid art production with generated references and Aseprite finishing; choose A — Compact visual proportions, with exact pixel dimensions and final appearance still to validate |
| September 20, 2026 | Retain all three generated character sheets and the native Phuong animation as references; record the demonstrated Aseprite MCP creation/export workflow without finalizing production art |
| September 20, 2026 | Replace KAPLAY with Phaser; retain Vite, TypeScript, Aseprite, Tiled, and engine-independent state; propose Phaser 4.2.1, Arcade Physics, built-in Tiled loading, and revised scene/animation conventions |

### Updating this document

Keep confirmed direction separate from ideas. When a decision changes, update the relevant section and add a brief decision-history entry. Preserve user-supplied personal details accurately, and ask rather than inventing missing personal content.
