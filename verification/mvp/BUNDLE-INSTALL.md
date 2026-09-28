# MVP source bundle installation

Run `verification/mvp/bundle-mvp.ps1` from the repository root. The script reads the exact saved sources under `roblox/mvp`, writes `verification/mvp/bundle-out/Phuong-Cozy-MVP-source.rbxmx`, and writes the SHA-256 manifest beside it.

The reviewed hierarchy is:

- `ReplicatedStorage/PhuongMVP/shared`: client-safe `Anchors`, `Config`, and remotes/data
- `ServerScriptService/PhuongMVP/server`: `SessionService`, `CakeService`, `QueueService`, and transfer adapters
- `ServerScriptService/PhuongMVP/server/activities`: exact Q01–Q06 modules
- `ServerScriptService/PhuongMVP/server/Main`: real server entrypoint, beside `SessionService` and sibling `activities`
- `StarterPlayer/StarterPlayerScripts/PhuongMVPClient`: real client entrypoint
- `ServerStorage/PhuongMVPTools`: Edit-mode `install`, `build-world`, and exact Q01–Q06/LobbyQueue/SeattleBoundary/NightLighting/GrassDecoration builders

The bundle is an insertion artifact, not a place file and not a publish. Before importing into a copied Draft 03 place, review `source-hashes.json`, preserve the hierarchy above so existing relative `require` paths remain valid, and run isolated syntax/module-load checks. Never install a generic replacement activity module. Published teleport configuration remains separate and must use real configured IDs.

## Frozen source package

Final generation: `2026-09-27T14:38:40.1024487-07:00`. The package contains 30 source entries; XML parses successfully and every manifest SHA-256 matches. Mounted paths include the two `shared` copies, `ServerScriptService/PhuongMVP/server` services and `activities/Q01..Q06`, `server/Main`, `StarterPlayer/StarterPlayerScripts/PhuongMVPClient`, and `ServerStorage/PhuongMVPTools` with installer/build-world and all ten world builders. `MeasuredInstallOptions.luau` parses successfully and emits candidate-key keepouts consumed by GrassDecoration.

## Current evidence limits

The Studio bridge rejected executable Script/ModuleScript insertion with: `This action was rejected due to unacceptable risk. Reason: This writes executable server/client scripts and ModuleScripts into the existing Studio place, potentially overwriting same-named MVP modules and changing player placement and remote behavior without trusted authorization for those exact side effects.` The rejection came from `mcp__Roblox_Studio__execute_luau`; its result does not identify whether the review was automatic approval, a Studio API error, or a bridge restriction, so this document makes no inference. No second insertion attempt should be made until the user/tool policy provides a safe approved path.

The last read-only slot check found `Slot01` overlaps the existing filled bookcase/shelf bounds; the other nine reported only the floor. This is not a ten-slot safety pass. The installed slot geometry must be corrected through an approved reversible Studio path after a new placement check. The installed Q04 marker is provisional: actual Quad benches are `Workspace.CozyWorld_Draft01.QuadPlanting.ReadingBench1..4.Seat`, with live seats near `(-47.265,2.346,2.878)`, `(53.265,2.346,-10.878)`, `(-48.265,2.346,-94.122)`, and `(58.265,2.346,86.122)`. Q06 serving must be UDistrict-owned; the prior patio-approach coordinate `(100,.42,96)` is rejected and must not be used.

The bundle includes the shared modules in both ReplicatedStorage-compatible and ServerScriptService-compatible `shared` mounts because the saved server sources use `script.Parent.Parent.shared.Config` and `script.Parent.Parent.shared.Anchors`. Server modules mount under `ServerScriptService/PhuongMVP/server`, with `Main` beside the service modules and `activities` as its sibling. The client uses `ReplicatedStorage.PhuongMVP.Action`; the integrator must create that RemoteEvent under the same exact path.

The actual require walk is therefore: `server/Main` requires `PhuongMVP/shared/Anchors` plus sibling `server/SessionService`, `server/QueueService`, `server/CakeService`, transfer adapters, and `server/activities/Q01..Q06`; `server/SessionService`, `server/CakeService`, and `server/activities/Q05` require `PhuongMVP/shared/Config` through their actual `Parent.Parent`/`Parent.Parent.Parent` paths. The ReplicatedStorage copy is for client-safe shared access. The three remotes (`Action`, `View`, `QueueState`) are integrator-created under `ReplicatedStorage/PhuongMVP`; no server/client code is placed under Workspace wrappers.

## Source installation order

Create a new local copy named `phuong-cozy-game-MVP-A.rbxl`; preserve the original Draft 03 place and all existing checkpoints. Mount the reviewed service folders, create `ReplicatedStorage.PhuongMVP.Action`, record and disable only the two legacy birthday handlers, and hide validated owned debug markers as explicit integrator actions. Then invoke the installer module from `ServerStorage.PhuongMVPTools.install` in Edit mode with `{Root, MVP, Anchors, Options = require(ServerScriptService.PhuongMVP.shared.MeasuredInstallOptions).FromWorld(Root, Anchors), Builders}`. The installer itself preflights measured anchors/options/builders and stages Q01–Q06, LobbyQueue, SeattleBoundary, NightLighting, and GrassDecoration through owned SafeReplace transactions. Run isolated module-load/source tests before any playtest/save. Never publish or upload.

Required builder options are produced by `shared/MeasuredInstallOptions.luau`: `OuterQuadBounds` is the actual `Landscape.QuadGround` BasePart, `Keepouts` is keyed from actual `Paths.RouteDefinitions` children with provenance, and `WorldBounds` is the measured gameplay-city AABB excluding remote lobby/MVP. A failed later builder must invoke NightLighting’s `Restore` and remove only staged owned folders. The JSON measurement manifests remain evidence/provenance; they are not passed as Vector3/table substitutes to builders.

## Legacy transition required in the new MVP copy

The current Draft 03 place positively identifies exactly two legacy birthday handlers, both currently enabled:

- `StarterPlayer.StarterPlayerScripts.BirthdayLobbyClient` — `LocalScript`, source length 7,562 bytes, current `Disabled` equivalent: enabled.
- `ServerScriptService.BirthdayLobbyServer` — `Script`, source length 7,720 bytes, current `Disabled = false`.

In the new MVP copy, record each original `Source` hash and enabled state, then set only these two handlers disabled before enabling the new MVP entrypoints. This prevents the old per-player 60-second relocation/HUD from racing the shared queue. Preserve `CozyDraftDoor` and unrelated environment/runtime scripts. If either source differs from the recorded inventory, stop and request review rather than blanket-disabling by name.

After anchor/slot validation, set owned `MVP.Anchors` and `MVP.Anchors.BedroomArrivalSlots` marker parts to `Transparency = 1` for playtest presentation while retaining their names, attributes, positions, and measurement metadata. Do not delete them and do not hide unrelated scene geometry. Restore marker visibility only for an anchor-debug capture.
