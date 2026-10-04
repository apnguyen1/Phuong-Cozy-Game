# Merge coverage audit — 2026-09-27

This records source coverage and the saved-place follow-up for the 13-chat feature merge. Final multiplayer, device, and human acceptance remain separate.

## Current saved coverage

All delivered runtime production sources from the 13 chats are installed and saved. Final bundle `D85456C6C543FEBE63001C797F500126D4475334B27E3E839CBE8291483AE58E` has 31 entries; the reopened primary returned 31/31 exact actual Source matches. The five remaining activity view/envelope fixes were applied and saved individually. Independent review found no additional omitted runtime production file. See `saved-place-progression-smoke-20260927.md` and `saved-place-progression-review-20260927.md` for the passing one-player progression run and its limits. Historical findings below are superseded by these final fixes.

## Earlier source follow-up

The Q03 empty-payload gap below has been repaired and independently checked against actual SessionService behavior. Final Q03 SHA-256 is `D72B4E25EA406E6E5BA99FDF7F195BD4962DA85EE213BABC8F8E5557EAB8C4D3`. The Main/server and client repairs also cleared independent source review and compilation. All 31 decoded package payloads, mapped file hashes, and the import index match final bundle `445F95762CA6779B9EF6E36D9939F3EECC71F1B06640279F8779005D4F2C4DA7`. The unused client descriptors are superseded by server views and the shared client renderer; no additional delivered runtime file was found omitted. Native saves and the new engine smoke remain separate evidence gates. The original findings below are retained as history.

## Task coverage

- Task 01: shared anchors/options, build-world, installer, and Main/client sources are represented by the reviewed package and overlays.
- Tasks 02–07: Q01–Q06 server activities and station builders are mounted. Q01/Q04/Q06 UI additions are carried by server `GetView` payloads and the generic client renderer.
- Task 08: QueueService, transfer adapters, and LobbyQueue builder are mounted.
- Task 09: Config, SessionService, CakeService, and CakeFinale are mounted and CakeFinale is registered with the installer.
- Tasks 10–12: SeattleBoundary, NightLighting, and GrassDecoration builders are mounted.
- Task 13: tests, adapters, verification scripts, handoffs, and review artifacts remain tooling/evidence and are intentionally not runtime mounts.

## Historical client descriptor audit

The unmounted Q02 descriptor is presentation guidance only: its prompt wording and the forgiving-lane note are duplicated or non-authoritative relative to Q02 `GetView` labels/actions. Q02 `GetView` supplies the action IDs and fetch payloads consumed by the generic renderer.

The unmounted Q03 descriptor is not fully superseded. `Q03:GetView` emits reserve/rotate/place/cancel/preview buttons with empty payloads, while `Q03:Apply` requires payload `action`, and for reserve/place also requires `socketId` and `partId` (for rotate, `socketId` and direction; finalize also needs presentation). The generic renderer therefore cannot complete Q03 from the current view alone. This is a Main/client or Q03 view binding gap, pending final repair.

Main/client remained pending final source repair and live smoke validation at the time of this audit. No runtime or final-acceptance claim is made here.
