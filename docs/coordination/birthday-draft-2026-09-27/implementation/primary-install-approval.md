# Prepared primary-place installation

The working destination is `roblox/phuong-cozy-game.rbxl`. It was saved on September 27 at 3:31:13 PM, 1,717,073 bytes. It contains imported source, the shared queue connections, disabled old personal countdown handlers, and corrected placement markers. The new stations and scenery are not installed or tested yet.

The preserved original is `roblox/phuong-cozy-game-primary-backup-20260927-1500.rbxl`, 1,648,676 bytes. Before the next installation, preserve the current integration checkpoint as well.

## Exact next changes

Run the prepared local world installer against Studio instance `dd967171-b918-43a9-8046-83eeaada4381`, whose MCP name and native full-path title now both identify `phuong-cozy-game.rbxl`.

| Owned builder | Intended result |
|---|---|
| Q01Station | Bed activity in Phuong's bedroom |
| Q02Station | Jasper's bedroom start and yard fetch activity |
| Q03Station | Craft booth beside the UDistrict crossing and bedroom display |
| Q04Station | Reading activity beside an existing Quad bench |
| Q05Station | Labubu vending activity in the UDistrict |
| Q06Station | Food activity at FOB and Aladdins, with serving in the UDistrict |
| LobbyQueue | One shared waiting square, capacity ten, with the approved 60-second/8-player shortening rules |
| SeattleBoundary | Seattle-inspired surrounding facades to hide unfinished map edges while retaining the sky |
| NightLighting | Nighttime lighting and cozy warm lights |
| GrassDecoration | Grass detail and decoration around the Quad exterior |

The installer stages owned content under `Workspace.CozyWorld_Draft01.MVP` and applies the intended lighting changes. Preserve existing world geometry and Quad interior. Apply the prepared Main-only source update that fixes lookup of the ten bedroom arrival slots. Enable only the server Main and client entrypoint for the subsequent local smoke test; the Edit-only build tool stays disabled. Save progress to the primary file. Publishing and uploading are not included.

## Placement checkpoint

Recent corrections saved in the primary: bedroom arrival `(-6, 0.5, -152)`; craft `(-103, 0.42, -141)` beside Crossing_003; reading `(-50, 0.42, 3)` beside ReadingBench1.Seat; serving `(-119.5, 0.42, -132)` near FOB. Ten arrival slots have recorded live overlap checks. The installed stations still need footprint, route, camera, and usability checks; marker measurements are not a gameplay pass.

## Prepared sources and review

- World invocation: `verification/mvp/import/install-world.luau`, SHA-256 `F9F94F446E101128410D86DF3D88235EC58FD4F2E51C8AB72AABC8B647B9E417`.
- Main-only update: `verification/mvp/import/update-main.luau`, SHA-256 `63DA4E4298892E998F2081B9CFB3C49C851E2B6B4B5D8B2793876F808500918F`.
- Current source bundle: `32044A609209D7C63B4A67C8B045ED18D6EA84B989C7E8A6757DEFDF44FE0865`.
- The invocation and Main update received independent source review. Main compiles. Existing actual-source module checks passed nine specs before this isolated arrival lookup fix; no completed Studio gameplay test is claimed.

## Why additional authorization is requested

Automatic approval review rejected `mcp__Roblox_Studio__execute_luau` for the prepared installer after target identity was resolved. Its stated reason was that the installer may add or replace substantial world content and lighting, and its full mutation scope and reversibility were not established. It explicitly required a materially safer alternative or user approval informed by this risk.

The practical risk is an unintended layout or lighting change within the local place. Backups are preserved and the implementation uses staged replacement and rollback handling, but a successful full rollback has not yet been demonstrated in Studio. No rejected operation has been retried through another channel. After approval, run the scoped installer normally, save the result, and obtain independent engine checks before asking for the user's playtest.
