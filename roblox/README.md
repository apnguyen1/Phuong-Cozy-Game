# Draft 01 authoring files

The complete draft was saved by the user as `phuong-cozy-game.rbxl`. `Phuong-Cozy-World-Draft01.rbxl` is an identical numbered checkpoint. Both files were verified on disk, including their Roblox binary header and matching SHA-256 hashes. The Luau files below are source records for continued development, not an automatic one-click installer.

- `prepare-assets.luau` derives static reviewed templates from the five inspected imports in `ServerStorage.CozyDraftAssets.Incoming`.
- `build-draft01.luau` creates native geometry using those templates and the existing `BeforeCozyDraft01` backup folder. It refuses to run if the draft model already exists, preventing accidental duplicate builds.
- `draft-door.server.luau` is installed as `ServerScriptService.CozyDraftDoor`.
- `draft-camera.client.luau` is installed as `StarterPlayer.StarterPlayerScripts.CozyDraftCamera`.

Continue editing `phuong-cozy-game.rbxl` and use a new numbered checkpoint when the next iteration is ready. Do not rerun the build script into the current scene. Asset IDs, adaptations, and remaining checks are recorded in `docs/roblox-asset-register.md`.
