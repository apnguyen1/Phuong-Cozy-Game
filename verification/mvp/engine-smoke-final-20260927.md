# Engine smoke evidence — 2026-09-27

Current outcome: the repaired, reopened primary passed the subsequent one-player progression run. See [saved-place progression smoke](saved-place-progression-smoke-20260927.md) and [independent assessment](saved-place-progression-review-20260927.md). The observations below retain earlier failures and queue evidence as history; they are not the final activity status.


Scope: one real local Studio player; no publish, save, state injection, or fake rewards.

## Completed observations

- Fresh play started in Studio instance `9e64c5fd-8541-4726-b46a-cf5d7ab5f08e`.
- Before any movement, the character was at approximately `(1995.58, 3.80, -1.98)`, inside the saved BirthdayLobby region centered at `(2000, 12, 0)`.
- `BirthdayLobbyServer` was present but disabled. `PhuongMVP.server.Main` was enabled.
- Saved spawn inventory had `BirthdayLobby.LobbySpawn` enabled and `Arrival.ArrivalSpawn` disabled.
- Client HUD rendered queue, petals, fund, and session status.
- Physical queue entry on `MVP.Stations.LobbyQueue.QueueFloor` showed `joined • 1/10 • 43s • Open`.
- Moving away showed `waiting • 0/10 • Empty`.
- Re-entering and waiting the real countdown showed `joined • 1/10 • 0s • Completed`.
- Transfer completed with `MVPArrivalStatus=Transferred`, `MVPArrivalSlot=Slot01`; server assignment was `BedroomArrivalSlots.Slot01`.

## Not completed

Q01 and subsequent route/UI probes were not completed. The navigation call toward Q01 was interrupted by coordinator lease revocation. No gameplay pass is claimed.

## Route correction and action failure

- The initial Q04 panel observation is withdrawn as a proven route defect. A later trace confirmed the direct Q01 prompt emitted `activityId=Q01`, created the round, and returned the Q01 view titled `Everything Tucked In`.
- The real offered-action path did expose a concrete Q01 runtime defect: selecting an offered action produced `ActionRejected` with `Q01:110: reserve this bed spot first`, leaving progress `0/7`. The existing harness manually calls `Reserve` before `Apply`, so it does not cover this client envelope path.
- Q01 action dispatch/dynamic view handling was handed back to the owner for repair; no completion is claimed here.

## Additional live route findings from independent trace

- Q02 `RequestView` reached round creation but returned `RoundRejected`: `Q02:40 authenticated actor required`. Main sends a numeric `actorUserId`, while the module was reading `request.actor.UserId`.
- Q03 created a round and accepted its offered reserve action.
- Q04 created a round and returned reading text, but applying an offered highlight failed at `SessionService:52` because the module omitted the canonical `sessionId`; its view also exposed singular highlight payloads while Apply expects the highlights array/save contract.
- Q05 created and returned Inspect successfully, but its offered Select Wanted action lacked a usable figure payload.
- Q06 created successfully and accepted the first offered toppings/carrot action, reaching progress `1/6`.

These are one-player local route observations; no multiplayer or full completion claim is made. Owners are repairing Q01, Q02, Q04, and Q05 separately.

## Final source adapter check

After all five owner freezes, `python verification/mvp/generate_luau_adapter.py` generated the adapter from 44 source files. `verification/mvp/tools/luau-0.740/luau.exe verification/mvp/run_module_specs.luau` returned `SUMMARY passed=10 failed=0`. Q01, Q02, Q04, Q05, and Q06 each compiled with Luau 0.740 (exit 0). The adapter source hashes matched all five supplied hashes exactly.

The final source paths now expose generic-envelope-compatible payloads: Q01 reserve/place/cancel/finish payloads include step IDs; Q02 basket actions carry numeric actor identity and concrete choices; Q04 highlight choices include `highlights={id}` and Save sets `complete` when selections are ready; Q05 emits per-figure `figureId` payloads; Q06 emits slot/item payloads. The earlier real-engine failures remain historical evidence until a new Studio run exercises the repaired overlays.
