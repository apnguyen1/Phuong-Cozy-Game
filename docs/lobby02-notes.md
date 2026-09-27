# Birthday welcome room — revision 02

The enclosed 80 × 64 stud room at `(2000, 0, 0)` introduces the birthday before the player enters the outdoor world. It sits beyond the visible outdoor neighborhood. The focal wall says **Happy 24th Birthday, Phuong**, following the user's corrected spelling. Cream plaster, sage paneling, wood floorboards, a stitched rug, warm string lights, fabric bunting, confetti, wrapped gifts, balloon clusters, and a rounded gold 24 display give the room a finished party identity. The authored geometry and UI use the eight approved palette colors; the root is tagged `VerificationTicket = PCW-17`, and every part records its `PaletteToken`.

Eight usable sofa seats face the central rug. Four favorite-things displays include books and a matcha Kindle, coloring pencils, weighted-style dog and dinosaur plushies, a tiny furnished room, a decorative board game, matcha cups, and a strawberry birthday cake. These are environmental references, not new quest systems. No personal birthday note has been written.

The golden pad in front of the birthday wall leads to the existing outdoor arrival. A fresh player receives a personal 60-second countdown on arrival. The room sign and the small screen card explain that the pad enters early; the prompt supports keyboard and touch. At zero, that player moves automatically. Other players keep their own deadlines, and respawning after entry returns to the world. Respawning before entry starts a fresh countdown without retaining the old timer. Each connection reserves a unique free spawn slot, keeps it through respawns, and releases it on departure. `BirthdaySpawnSlot` exposes the allocation for verification.

Interior illumination combines six broad cream ceiling lights, softer golden strings, and a thick opaque ceiling. While a player is in the lobby, that client's lighting disables the directional sun and uses neutral warm ambient fill. On world entry it restores all five modified outdoor lighting properties exactly. Other players' views are unaffected; loading/death retains the appropriate lighting until the new location is confirmed. This lighting must be reviewed in Client play mode because Edit mode retains the outdoor day setup.

## Integration

1. Run `roblox/build-lobby02.luau` in Edit mode. It replaces only `CozyWorld_Draft01.BirthdayLobby` and disables the existing outdoor default spawn.
2. Install `roblox/birthday-lobby.server.luau` as `ServerScriptService.BirthdayLobbyServer`.
3. Install `roblox/birthday-lobby.client.luau` as `StarterPlayer.StarterPlayerScripts.BirthdayLobbyClient`.
4. Disable the old `CozyDraftCamera` initializer to avoid competing initial views. This feature frames the current player's view toward the greeting on lobby arrival and toward the Quad on world transport/respawn; normal independently rotatable camera control remains active immediately afterward. Its temporary room lighting changes are local to that player and restore on world entry.

The room includes `LobbySpawn`, `WorldDestination`, and `Portal.PortalPrompt.EnterWorld`. The destination derives from the current `ArrivalSpawn.CFrame`, so the user's translated outdoor map is preserved. Server-owned player attributes are `BirthdayJoinedWorld`, `BirthdayLocation`, and `LobbyCountdownEnd`. The server validates a living character inside the room, distance for the early-entry prompt, and expiration for automatic entry. Destination and duration are never supplied by a client. There is no client-to-server remote event. This is movement between two parts of the same Roblox place; it does not require a published destination place.

Character placement follows Roblox's normal automatic loading lifecycle. A new character immediately gets `BirthdayPlacementReady = false`, a generation identifier, and player location `Loading`. The server waits until its appearance has loaded and it belongs to Workspace, then waits an engine frame before moving it. It confirms the destination across physics frames before marking that specific character ready and exposing the new `Lobby`/`World` location. Standard appearance-disabled or custom `StarterCharacter` configurations skip the appearance-event requirement. This avoids racing the engine's later spawn placement without replacing Roblox's character lifecycle or adding a long fixed delay.

## Required play verification

- Fresh spawn is inside the decorated room; greeting and gold pad are visible; the HUD initially shows 60 seconds and decreases.
- Walk to the pad, press E, and confirm relocation to the outdoor arrival with hidden lobby HUD.
- Wait out a new full 60-second session without touching the pad, and confirm automatic relocation.
- Reset before entry and confirm a fresh countdown, no old timer transporting the replacement character, and no duplicate HUD.
- Reset after entry and confirm respawn at the outdoor arrival without a lobby countdown.
- For reset assertions, capture the previous Character and wait for a different current Character whose `BirthdayPlacementReady` is true. Then verify its actual position and the player location. A `Lobby`/`World` value on the Player alone may still describe the previous character.
- Enter while seated when the timer expires and confirm no attached seat or immobilized character.
- Check a second player or simulated independent server player: one player's early entry must not move the other or change the other's deadline.
- Connect eight players and confirm eight distinct `BirthdaySpawnSlot` values and positions; remove one and confirm a joining player receives the freed slot while existing assignments remain unchanged.
- Compare Client lighting in the room and after entry: no diagonal blue/gold divide indoors, and the outdoor brightness, ambient colors, diffuse scale, and specular scale exactly match their pre-lobby values.
- Confirm eight functional seats, no scripts under room geometry, no loose parts, traversable center lane, and no new runtime errors.

Suggested review cameras: room overview `(2000, 14, 28)` toward `(2000, 9, -19)`; party wall `(1999, 9, 4)` toward `(2000, 12, -28)`; favorite things `(1987, 9, -5)` toward `(1972, 5, -15)`. Actual screenshot and runtime review remain the integration owner's responsibility.

The proximity-prompt behavior follows the [Roblox prompt documentation](https://create.roblox.com/docs/reference/engine/classes/ProximityPrompt) and the additional validation recommended in [Roblox's client-server boundary guidance](https://create.roblox.com/docs/scripting/security/client-server-boundary).

## Runtime iteration 01 correction

The recorded two-client test in `roblox/evidence/draft02/runtime-iteration01-raw.json` passed the full 60-second automatic entry and seated detachment, but repeated world resets showed a `World` location while the new avatar was physically back in the lobby. The source now delays final placement until the documented [character loading event sequence](https://create.roblox.com/docs/reference/engine/classes/Player#LoadCharacterAsync) has reached appearance and Workspace readiness, and publishes a per-character ready marker only after position confirmation. The earlier reset-before-entry assertion also inspected a previous location value; the next test must use the replacement-character readiness rule above. These corrections require a fresh Studio runtime run before acceptance.
