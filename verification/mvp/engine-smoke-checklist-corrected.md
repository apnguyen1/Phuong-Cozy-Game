# Corrected engine smoke checklist

Use after Owner01's Main.server/Main.client revision is installed and saved. Run one fresh local Play session with the real enabled scripts. Do not call module methods directly or use test doubles.

1. Confirm Edit mode, exact primary place, and only the two intended entrypoints enabled.
2. Start Play and capture console. Record the session ID, `activityErrors`, and any constructor/load errors. Q06's dependency error is a hard failure until repaired.
3. Confirm real `PhuongMVPHud`, `ActivityPanel`, journal, and queue labels exist.
4. Confirm `Action`, `View`, and `QueueState` are `RemoteEvent` instances.
5. Use the actual lobby queue pad: physically move the player onto it, send or trigger the real join interaction, and capture `Result` code plus `QueueState`. Repeat leave, deadline/shortened countdown, and transfer behavior where the one-player local session permits. Record each expected and actual code.
6. Confirm the assigned arrival slot maps to the player's real `MVPArrivalSlot` and that entering/leaving the lobby/world flow updates the real player attributes and UI.
7. For each activity Q01–Q06, use a real prompt or the exact client path. If probing the envelope directly, include a fresh unique `actionId` and the live `sessionId`; capture the returned `Result` code, `activityId`, `roundId`, and `view` payload. A request without `actionId` is invalid evidence.
8. Confirm each returned view has real available actions/prompts. For Q01, perform one legitimate contribution through the real activity action envelope with its returned `roundId`, `stepId`, fresh `actionId`, and live actor identity; capture accepted result, progress, and fund change.
9. Open the real journal and confirm its visibility/content. Confirm the cake/finale view is reachable only when its real prerequisites permit it; do not force completion.
10. Stop Play, capture shutdown console, verify no new errors, and confirm Studio returns to Edit mode.

Meaningful gate: PASS requires all six constructors/routes to load, valid Result/view evidence for all six, discoverable prompts, and the feasible queue/lobby/Q01/journal checks. Any Q06 constructor error, missing station prompts, malformed-only evidence, or unobserved route remains unresolved.
