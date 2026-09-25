# Phuong’s Cozy World

## Living theme and game plan

**Version:** 0.4 — September 22, 2026  
**Stage:** Creative direction and high-level gameplay agreed; Roblox confirmed as the engine/platform; detailed implementation planning comes next.  
**Purpose:** Keep the project’s personal meaning, scope, gameplay, and future implementation work in one evolving document.

This document records decisions from the planning conversation. Confirmed direction takes precedence over earlier brainstorms. Items marked **provisional** or **to decide** are starting points for discussion, not implementation requirements. Future agents should preserve the confirmed direction and update this document when decisions change.

## 1. The heart of the game

Phuong’s Cozy World is a birthday gift: a small, cute, explorable world built around Phuong’s interests, hobbies, habits, and favorite things.

Phuong and her real friends join the same Roblox session, explore with Jasper, and participate in activities centered on her interests. Decoration is now a major focus of the experience. Quests build toward the birthday celebration with cake and wishes from the actual friends playing together. Everyone can stay and enjoy the world afterward.

**Latest confirmed direction:** This is a shared birthday gathering with real participants, not a solo adventure followed by NPC friends arriving. Exact cooperative quest rules and decoration tools are still proposed below.

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
| Genre | Cozy exploration game with life-sim-inspired activities and a rotatable third-person camera |
| Recipient | Phuong |
| Platform | Roblox, initially targeting laptop/desktop play through the Roblox application |
| Session length | Approximately 30 minutes of guided activities, with an open-ended social gathering afterward; recheck pacing for the group |
| Visual inspiration | Stardew Valley’s warmth, readable spaces, relaxed discovery, and simple interface; final Roblox art style to be decided |
| World | A compact neighborhood with her house as its central hub |
| Progression | Six main activity quests filling a flower-shaped completion meter |
| Ending | The real players gather for cake, birthday wishes, and celebration after participating in the activities |
| After the ending | Continue exploring, collecting, decorating, and revisiting activities |
| Initial exclusions | Mobile support, extensive farming, an economy, seasons, relationship simulation, and a large open world |

The game will **not reproduce her existing Stardew Valley farm arrangement**. No farm screenshots are needed to establish the layout.

**Platform change:** Roblox replaces the original browser-game implementation. The theme, six quests, completion flower, and birthday celebration remain intact. Browser-only delivery and a mandatory 2D sprite/tile pipeline are superseded. Moving to Roblox does not by itself decide the camera, art style, or multiplayer scope.

## 3. World and places

Her house sits near the center, slightly offset above and to the left, with a welcoming porch and branching paths. This placement recalls the familiar home-and-spawn feeling of Stardew Valley without copying her farm.

**Provisional production scope:** One Roblox place containing the compact outdoor neighborhood and house interior. Exact dimensions, camera behavior indoors, transitions, and building interiors remain to be decided.

| Place | Main purpose and details |
|---|---|
| House | Green-sheeted bed, weighted dog and dinosaur plushies, Kindle nook, computer, craft desk, coloring supplies, books, collection shelves, and Jasper’s toys |
| Yard and paths | Jasper play, plants, discoveries, and connections between destinations |
| UDistrict-inspired street | Cute storefronts, collectible displays, food references, and a possible nail salon detail referencing her mom |
| UW Quad | Cherry blossoms, benches, reading opportunities, and a brief Lisa encounter |
| Cooking courtyard/patio | KBBQ and seafood activity, followed by the birthday gathering |

Paths should form an easy-to-understand loop. Destinations should be close enough that walking is enjoyable rather than filler. Collectibles and small visual interactions reward detours.

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

Phuong wakes in her bedroom. An optional snooze interaction jumps the clock forward nine minutes instantly. Jasper is nearby playing with his stuffed rabbit.

The journal introduces **“A Day Full of Favorite Things.”** Six illustrated quest slots correspond to the six petals of the completion flower. All main quests are available from the beginning; she can make the bed first or go exploring.

Movement and interaction instructions appear briefly when useful. The opening should get her playing quickly.

### Exploration and quests

She follows her curiosity between the house, UDistrict street, Quad, and courtyard. Each quest has a clear activity, a forgiving completion condition, and a visible or collectible result.

The journal provides a short next-step hint and a location cue when needed. It should help her find an activity without turning the screen into a dense task list.

### Completion and celebration

The sixth completed quest fills the final petal. The flower blooms and makes the cake celebration available. **Proposed final prompt: “Gather Around the Cake.”** This replaces the scripted arrival of NPC friends.

Friends already playing together gather at the patio. A proposed host-ready control lets the organizer wait for people to gather before starting; the celebration should not fire automatically while players are scattered or someone is reconnecting.

The real participants share their birthday wishes and celebrate with Phuong. Exact cake reveal, dialogue presentation, and Lisa’s participation depend on the guest plan. Jasper can excitedly investigate.

She approaches the cake and selects **“Make a wish.”** The candles go out, confetti appears, and the group wishes her a happy birthday.

The meter changes to **“A lovely day, complete.”** Friends remain available for extra dialogue, and the world stays open.

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
- Has a small role: waves from the Quad and shares a brief, affectionate interaction.
- Purple-and-gold UW clothing is the proposed visual cue.
- Can join the birthday celebration.
- Is not the main quest organizer or guide for the entire game.

### Friends and boyfriend

Real friends join the same Roblox session and participate in the activities before gathering for cake. Guest count, Roblox identities, avatars, and celebration staging will be supplied later. Do not write fictional dialogue for real friends unless requested. Lisa’s earlier NPC cameo can be revisited if Lisa herself joins.

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

- Roblox is the engine and delivery platform.
- Cozy, cute, Stardew-inspired atmosphere with a minimal interface; exact 3D or 2.5D presentation remains open.
- Desktop/laptop play through Roblox; mobile can come later.
- Keyboard movement and clear interaction prompts; retain the original WASD/arrows and E preference where practical, with final Roblox bindings to be specified.
- Clear prompts, readable text, and gentle feedback.
- Warm greens, comfortable interiors, cute collectibles, and UW cherry blossoms.
- Music and effects should complement the activities and Jasper’s personality.

### Provisional implementation ideas

- Build the world in Roblox Studio. A warm, stylized 3D environment with an elevated camera is a candidate, not a confirmed art-direction change.
- Confirmed September 22: rotatable third-person camera. Prototype default framing, zoom limits, and indoor visibility within that choice.
- Aseprite can still create pixel-style icons, scrapbook stickers, textures, or other 2D art. A sprite-sheet character pipeline and Tiled maps are no longer the default.
- Original gentle chiptune music with a warm pop/lofi mood, plus interaction effects.
- Use Roblox-compatible audio assets and playback. Replace the browser-specific Web Audio implementation; determine asset creation, upload, permissions, and moderation lead time later.
- Keyboard-accessible activity controls, with optional mouse support for placement.
- Journal shortcut, pause/back controls, and separate music/effects volume settings.
- Saved progress so she can return later.

Camera, character rigs, model scale, animation workflow, UI layout, audio pipeline, and accessibility settings belong in the next implementation revision. Do not begin producing a large asset library before settling the visual approach.

## 10. Technical plan — to develop

No implementation or deployment is authorized by creating this document. The current task is planning and documentation.

**Confirmed platform: Roblox.** Use Roblox Studio for building, testing, and publishing, with Luau for gameplay scripting. KAPLAY, Vite, JavaScript browser gameplay, Tiled map loading, Web Audio, and Netlify hosting are superseded as the implementation plan. Aseprite remains an optional art tool.

The experience will be published on Roblox, rather than deployed as a standalone website. Access settings and the intended birthday audience must be settled before release; do not assume a particular private-sharing setup until its current requirements are verified.

**Provisional architecture:** Client-side camera, interface, and visual feedback; server-validated quest completion and rewards; Roblox data stores for persistent player progress if saving is included. Define how progress and world changes belong to a player before implementing multiplayer behavior.

**Confirmed social scope:** Real friends and the boyfriend play together with Phuong in the same Roblox session. This replaces the earlier solo-focused/NPC-friend assumption. Define shared quest progress, object interactions, joining/rejoining, and access around an actual hosted birthday party.

| Decision area | Details to add |
|---|---|
| Studio workflow | Luau module layout, source control, Studio editing, and whether an external synchronization workflow is useful |
| World and camera | Place layout, model scale, collisions, interaction prompts, indoor visibility, camera style |
| Art pipeline | Roblox avatars or custom characters, rigs, models, textures, palette, animations, asset ownership |
| Quest architecture | Quest steps, client/server responsibilities, validated rewards, replay behavior, finale eligibility |
| Save system | Data-store plan, what persists, rejoin behavior, load/save failures, reset flow |
| Activity framework | World interactions versus UI panels, shared controls, partial progress, camera/input restoration |
| Audio | Created or recorded assets, upload process, asset permissions, readiness, playback, volume |
| Publishing and access | Roblox publishing, test access, birthday audience, experience link, updates, current release requirements |
| Social scope | Confirmed live group play; guest count, session access, shared progress, object ownership, joining/rejoining, and host controls to specify |
| Quality assurance | Studio playtests and Roblox application tests on the target laptop, pacing, rejoin/save recovery, collision and audio checks |

### Platform references

Technical references checked for this revision; revisit when implementing:

- [Roblox Studio](https://create.roblox.com/docs/studio)
- [Scripting with Luau](https://create.roblox.com/docs/scripting)
- [Data stores](https://create.roblox.com/docs/cloud-services/data-stores)
- [Publishing experiences and places](https://create.roblox.com/docs/production/publishing/publish-games-and-places)

## 11. Dedicated subagent jobs — provisional responsibility map

These are proposed future assignments. No agents are being dispatched and no code is requested at this stage. Final briefs must specify owned files, dependencies, interfaces, acceptance checks, and scope limits before implementation starts.

| Role | Dedicated responsibility | Expected deliverable |
|---|---|---|
| Design and content | Quest details, hints, environmental writing, friend dialogue from supplied details; excludes the personal note | Approved content and quest specification |
| Technical foundation | Roblox project structure, movement, camera, collisions, interaction prompts, client/server interfaces, common activity interface | Playable Studio foundation |
| Art and asset pipeline | Palette, model/rig and UI-art specifications, asset checklist, import rules, reference preparation | Consistent Roblox asset guide and verified sample imports |
| World integration | House, street, Quad, courtyard, Roblox environment construction, placement, collision, navigation | Fully traversable compact place |
| Jasper and collectibles | Following, petting, rabbit play, treats, discovery hints, collection interactions | Jasper behaviors and collectible system |
| Home activities | Bed-making and miniature assembly, using shared activity interfaces | Two complete, replayable activities |
| Reading and cooking | Kindle annotation and KBBQ/seafood activities | Two complete, replayable activities |
| Progression and interface | Journal UI, server-validated quest state, six-petal meter, data-store persistence, finale trigger | Reliable progression across activity order and rejoining |
| Audio | Music moods, interaction sounds, Roblox asset preparation, playback and volume behavior | Integrated audio with consistent controls |
| Celebration and release | Live group gathering, host controls, cake interaction, user-authored note display, post-party state, Roblox publishing and group playtesting | Complete birthday experience and tested delivery |

One integration owner should coordinate shared interfaces and state. Assignments may be combined if a smaller team is more practical. Agents must not independently invent conflicting quest, save, input, or audio systems. Define ownership of Studio objects as well as script files so concurrent work does not overwrite the same place or models.

### Required structure of each future assignment

1. Purpose and player-facing result.
2. Owned files or feature area.
3. Required inputs and dependencies.
4. Shared interfaces and events.
5. Behavior on completion, cancellation, replay, and reload.
6. Acceptance criteria and appropriate verification.
7. Explicit exclusions and unresolved decisions.

## 12. Implementation milestones — provisional

1. **Playable slice:** One room in Roblox Studio, a camera/style prototype, movement, Jasper interaction, and one complete activity.
2. **Complete placeholder game:** All six quests, the world loop, progress tracking, and the birthday celebration.
3. **Personalization:** Finished art, collectible choices, book details, friends, music, and the user’s exact note.
4. **Birthday rehearsal:** Full fresh playthrough in Roblox, alternate quest order, rejoin/save checks, keyboard use, audio settings, verified recipient access, and target-laptop testing.

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
- Target laptop and Roblox delivery/access preferences.
- Rotatable third-person camera tuning and final 3D art style.
- Guest count, Roblox identities, joining arrangements, and whether Lisa also joins in person as a player.
- Decoration scope: curated placements and color choices versus freely moving furniture.
- Final Roblox art, music, publishing, and technical choices.
- The personal birthday note, supplied directly by the user when ready.

## 14. Decision history

| Date | Decision |
|---|---|
| September 20, 2026 | Establish a short, desktop-browser birthday game inspired by Stardew Valley |
| September 20, 2026 | Replace reconstruction of her farm with a house-centered neighborhood, UDistrict street, and UW Quad |
| September 20, 2026 | Make Phuong’s interests and exploration the focus; remove waiting-for-boyfriend framing |
| September 20, 2026 | Use six activity quests to fill a day-completion flower |
| September 20, 2026 | End main progression with friends arriving with cake and birthday wishes; allow continued exploration |
| September 20, 2026 | Reserve the personal birthday note for the user to write manually |
| September 20, 2026 | Create this living document; defer final technical choices and detailed agent briefs |
| September 20, 2026 | Version 0.2: switch engine/platform to Roblox; supersede the standalone browser stack while preserving the theme, quests, meter, celebration, and user-authored note |
| September 20, 2026 | Version 0.3: confirm real friends participating together throughout the Roblox session; emphasize decoration and replace NPC-friend arrival with a live group cake celebration |
| September 22, 2026 | Version 0.4: confirm rotatable third-person camera; begin map-layout design in a separate task with the important project context |

## 15. Confirmed camera and proposed shared decoration

### Camera decision — confirmed September 22, 2026

Use a freely rotatable third-person camera for exploration. Comfortable elevated default framing, bounded zoom, optional activity close-ups, and a group-photo viewpoint remain proposed tuning/features. Let people inspect decor and see friends' avatars. Never move everyone’s camera because one player starts an activity.

A fixed dollhouse camera is no longer the planning alternative. Test one decorated room with several players to tune the selected third-person camera and room clearances.

### Art recommendation

Warm, stylized 3D resembling a handmade miniature: simple shapes, rounded plushies, painted wood, forest/sage green, cream, warm brown, and cherry-blossom pink. Use decorative detail in Phuong-specific objects while keeping walking routes spacious. Aseprite may supply scrapbook art and small pixel accents. Preserve Stardew’s warmth and readable spaces without assuming the whole world must use pixel textures.

### Proposed group quest adaptations

Keep the six existing quest identities, but revise their solo steps before implementation:

| Quest | Possible shared interaction |
|---|---|
| Everything Tucked In | Friends help with sheets/pillows; Phuong places or approves her plushies |
| Jasper’s Favorite Things | Find the rabbit together, take turns fetching, and give Jasper his treat |
| A Tiny World of Her Own | Everyone contributes a piece to one miniature and chooses small decorations |
| One More Chapter | Personal reading/annotation plus a shared book-nook decoration or bookmark activity; no synchronized reading requirement |
| Little Treasures | Discover figures together and add them to Phuong’s shelf |
| Something Delicious | Different participants grill, assemble the seafood platter, and set the party table |

**Proposed progress model:** One shared session flower, filled once per completed group quest. Friends contribute, while Phuong gets a meaningful finishing choice for personal decoration. No requirement for every guest to finish every activity. Late joiners see current progress; replay and reconnect must not double-award completion. Exact persistence and permissions need definition.

**Proposed decoration scope:** Begin with curated placement slots, a few color choices, and personal decorative props rather than a full free-build editor. Everyone sees committed changes. Define who can replace placed items, how simultaneous grabs are handled, and how Phuong can keep or change a result.

First group prototype: one living room, a shelf or craft table, two or more players, independent cameras, visible shared placement, and one shared quest completion. Test with the intended guest count before the birthday.

### Updating this document

Keep confirmed direction separate from ideas. When a decision changes, update the relevant section and add a brief decision-history entry. Preserve user-supplied personal details accurately, and ask rather than inventing missing personal content.
