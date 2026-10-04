# October 3 release coordination

## User authority and sequence

Andrew requested very detailed tickets, sequential sub-agent implementation, then integrated testing/bug fixes and autonomous publication when verified. His later instruction replaces the earlier request for one more pre-publish approval: he is away and asks the orchestrator to control the computer and publish with mobile access. Correct names are Phuong and Andrew. He authorizes both as emergency game hosts. This does not authorize inventing human playtest evidence or bypassing platform/account barriers.

One builder at a time. No concurrent implementation, test agent or Studio writer. Orchestrator reviews each delivery against its scope before releasing the next ticket; all execution tests and independent verification run after implementation, as requested. Preserve unrelated work and current environment. No branch switches, force resets or broad rebuilds.

## Current baseline

- Private shared world, voluntary immediate lobby-to-bedroom entry; no countdown or reserved-server transfer.
- Shared fund20 per first earning activity,10 per explicit replay; Q05 rolls20, chosen figure guaranteed by fifth roll; six petals unlock finale.
- Hosts verified live via Roblox username lookup: Phamlet707/3971290001 (Phuong), IamBannedrew/1078077474 (Andrew).
- Active Studio: phuong-cozy-game.rbxl. Current PlaceId/GameId0; publishing destination must be established before release.
- Live source/audio baseline exported under roblox/evidence/release-20261003/. A complete 1,608,565-byte before-release.rbxl backup was preserved with elevated read access after the restricted copy failed.
- Existing live CozyAudio and CozySoundEffectsClient must be preserved. The user selected birthday audio87992648461099 in the audio chat. Never reupload the rejected local music files.

## Work order

| Order | Ticket | Scope | Status |
|---|---|---|---|
| 1 | [PCW-18](../../tickets/PCW-18.md) | Guided mobile interface and destination markers | DELIVERED_PENDING_INTEGRATION |
| 2 | [PCW-19](../../tickets/PCW-19.md) | Intuitive bed and bedroom shelf organization | DELIVERED_PENDING_INTEGRATION |
| 3 | [PCW-20](../../tickets/PCW-20.md) | Build your food with clear choices and visible dishes | DELIVERED_PENDING_INTEGRATION |
| 4 | [PCW-21](../../tickets/PCW-21.md) | Labubu wish selection, reveal and collection clarity | DELIVERED_PENDING_INTEGRATION |
| 5 | [PCW-22](../../tickets/PCW-22.md) | Visible Jasper, craft and reading feedback | DELIVERED_PENDING_INTEGRATION |
| 6 | [PCW-23](../../tickets/PCW-23.md) | Phuong seated birthday celebration and cake eating | DELIVERED_PENDING_INTEGRATION |
| 7 | [PCW-24](../../tickets/PCW-24.md) | Phuong and Andrew host recovery controls | DELIVERED_PENDING_INTEGRATION |
| 8 | [PCW-26](../../tickets/PCW-26.md) | Birthday lobby and gameplay background music | DELIVERED_PENDING_INTEGRATION |
| 9 | [PCW-25](../../tickets/PCW-25.md) | Integrated walkthrough, independent verification and mobile release | INTEGRATING |

October 3 follow-up: Andrew added the linked audio task. PCW26 runs before final verification; all work remains sequential. A local pre-release rbxl backup was successfully copied with elevated read access after the restricted read failed (1,608,565 bytes). Live audio baseline is retained beside it.

## Handoff contract

Every builder records implementation, exact changed files, module import paths, payload/schema changes, world output ownership and deferred checks in handoffs/PCW-XX.md. Orchestrator records acceptance of delivery (not verification PASS) here, then starts the next builder. No worker may publish or mark human fun accepted.

## Shared integration conventions

- Existing server root: ServerScriptService.PhuongMVP; server modules under server, shared modules under shared.
- Replicated shared/client modules: ReplicatedStorage.PhuongMVP.shared and .client; client entry remains StarterPlayer.StarterPlayerScripts.PhuongMVPClient.
- Server world presentation owns a new MVP.RuntimePresentation subtree; preserve base geometry and bound updates. No required saved-world builders are needed for runtime-generated overlays.
- The main client may create modular activity presentation; new server views can add guide fields without breaking existing availableActions.
- Only orchestrator mutates Studio, integrates and saves. No test execution until PCW25.

