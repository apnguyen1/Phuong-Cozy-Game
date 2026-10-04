# Bounded engine smoke checklist — after Q04 placement repair

Prepared read-only on 2026-09-27. Execute only after the placement writer has repaired Q04, enabled exactly `ServerScriptService/PhuongMVP/server/Main` and `StarterPlayer/StarterPlayerScripts/PhuongMVPClient`, and saved the place.

1. Confirm the target place is the saved primary and Studio is in Edit mode before starting.
2. Start local Play once. Capture console output and record any `activityErrors` or startup errors.
3. Confirm the server starts the birthday session path without test doubles or injected helpers.
4. Confirm the client creates the real `PhuongMVPHud` and activity panel, with no UI construction errors.
5. Confirm the real remotes `Action`, `View`, and `QueueState` are present and usable by the enabled scripts.
6. Inspect all six activity routes (`Q01`–`Q06`) for load/real-view responses and available prompts/actions. Record exact missing or failing activity IDs.
7. Confirm prompts are discoverable in the live scene and that the Q04 reading prompt is positioned at the repaired bench location.
8. Stop Play, capture final console output, and verify no new runtime errors appeared during shutdown.

This checklist is an engine smoke gate only. It cannot establish multiplayer behavior, device coverage, fun, visual acceptance, saved progress, or final user acceptance.
