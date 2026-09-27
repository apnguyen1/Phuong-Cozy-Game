# Roblox authoring files

## Draft 02

The saved place is the complete artifact; the source files are editable construction records. Preserve `BeforeCozyDraft02` and the user's translated world. Do not rerun Draft 01 over this scene.

Draft 02 authoring order in Studio Edit mode:

1. `build-quad02.luau` replaces only Paths and QuadPlanting using the reviewed community templates.
2. `build-neighborhood02.luau` stages and replaces its owned neighborhood details.
3. `build-bedroom02.luau` replaces only the named bedroom content within the existing cottage.
4. `build-lobby02.luau` builds the enclosed birthday room beyond the outdoor map and reads the actual arrival destination.
5. `finalize-draft02.luau` applies inherited palette tags, native ellipsoid rendering and deterministic unique sibling names for unambiguous verification.

Install `birthday-lobby.server.luau` as `ServerScriptService.BirthdayLobbyServer` and `birthday-lobby.client.luau` as `StarterPlayer.StarterPlayerScripts.BirthdayLobbyClient`. Keep `CozyDraftDoor`; disable the older `CozyDraftCamera` because the lobby client now handles initial framing and normal Custom cameras.

`tests/lobby-runtime-check.luau` is a temporary Studio ServerScript used by `StudioTestService:ExecuteMultiplayerTestAsync(2,"Draft02Lobby")`. It tests the actual installed game logic with actual local clients. Remove it from the saved production place. The runtime validator consumes its saved evidence and checks source hashes; it does not launch Studio by itself.

The `studies/` folder contains rejected visual experiments, not deployed builders. See [Draft 02](../docs/roblox-draft02.md) and its independent review for current test and save status.

## Draft 01 archive

The complete draft was saved by the user as `phuong-cozy-game.rbxl`. `Phuong-Cozy-World-Draft01.rbxl` is an identical numbered checkpoint. Both files were verified on disk, including their Roblox binary header and matching SHA-256 hashes. The Luau files below are source records for continued development, not an automatic one-click installer.

- `prepare-assets.luau` derives static reviewed templates from the five inspected imports in `ServerStorage.CozyDraftAssets.Incoming`.
- `build-draft01.luau` creates native geometry using those templates and the existing `BeforeCozyDraft01` backup folder. It refuses to run if the draft model already exists, preventing accidental duplicate builds.
- `draft-door.server.luau` is installed as `ServerScriptService.CozyDraftDoor`.
- `draft-camera.client.luau` is installed as `StarterPlayer.StarterPlayerScripts.CozyDraftCamera`.

Continue editing `phuong-cozy-game.rbxl` and use a new numbered checkpoint when the next iteration is ready. Do not rerun the build script into the current scene. Asset IDs, adaptations, and remaining checks are recorded in `docs/roblox-asset-register.md`.
