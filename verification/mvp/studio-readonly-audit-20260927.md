# Read-only Studio audit — 2026-09-27

Target: `C:\Users\andre\Repos\Phuong-Cozy-Game\roblox\phuong-cozy-game.rbxl`, Studio ID `ac69268a-efcf-4a1a-b2f2-98cdf22947d7`, Edit mode. No play, enable, edit, or save action was performed.

## Installed source equality

All **31/31** bundle targets were checked against the current approved XML payload in bounded batches. Class expectations were checked before reading `Source`. Result: **28 exact raw matches, 3 substantive mismatches, 0 class mismatches, 0 missing targets**. The previously canceled batch was retried successfully.

Exact target status (all 31 checked): `ReplicatedStorage/PhuongMVP/shared/Anchors` exact; `ReplicatedStorage/PhuongMVP/shared/Config` exact; `ServerScriptService/PhuongMVP/shared/Anchors` exact; `ServerScriptService/PhuongMVP/shared/Config` exact; `ServerScriptService/PhuongMVP/shared/MeasuredInstallOptions` exact; `ServerScriptService/PhuongMVP/server/SessionService` exact; `CakeService` exact; `QueueService` exact; `TeleportAdapter` exact; `LocalPartyTransferAdapter` exact; `server/activities/Q01` mismatch; `Q02` exact; `Q03` mismatch; `Q04` exact; `Q05` exact; `Q06` exact; `server/Main` exact; `StarterPlayer/StarterPlayerScripts/PhuongMVPClient` mismatch; `ServerStorage/PhuongMVPTools/install` exact; `build-world` exact; builders `Q01Station`, `Q02Station`, `Q03Station`, `Q04Station`, `Q05Station`, `Q06Station`, `CakeFinale`, `LobbyQueue`, `SeattleBoundary`, `NightLighting`, and `GrassDecoration` exact.

Mismatches:

- `ServerScriptService/PhuongMVP/server/activities/Q01`: actual 8,203 bytes vs expected 8,218; first difference is the quoted error text containing an actual UTF-8 em dash versus the bundled mojibake sequence. This is not newline-only.
- `ServerScriptService/PhuongMVP/server/activities/Q03`: actual 8,333 bytes vs expected 8,335; first difference is the `Rotate 90°` label versus the bundled mojibake sequence. This is not newline-only.
- `StarterPlayer/StarterPlayerScripts/PhuongMVPClient`: raw source mismatch; no class mismatch. A bounded first-difference extraction was not completed because the bridge rejected the generated command, so the client mismatch requires follow-up before equality approval.

All other mounts matched raw source in the bounded comparisons. This is source-import evidence only, not gameplay approval.

## Scene and runtime inventory

- `Workspace.CozyWorld_Draft01.MVP` contains 8 station folders/models: Q01–Q06, LobbyQueue, CakeFinale; and 3 environment folders: NightLighting, GrassDecoration, SeattleBoundary.
- Lighting read-only values: `ClockTime=22`, `Brightness=2`, `ExposureCompensation=0.1`, `GlobalShadows=true`, `Ambient=(0.211765,0.341176,0.266667)`, `OutdoorAmbient=(0.14902,0.219608,0.180392)`.
- Remotes exist at `ReplicatedStorage.PhuongMVP.Action`, `View`, and `QueueState`, all `RemoteEvent`; shared folder also exists.
- `ServerScriptService.PhuongMVP.server.Main`, `StarterPlayer.StarterPlayerScripts.PhuongMVPClient`, and both legacy birthday handlers were disabled during the inspection.
- Ten named bedroom arrival slots were present. Their measured positions were returned by the read-only inventory; no collision/pass judgment is claimed from positions alone.

## Concrete placement findings

- Q04 marker: `Q04QuadReading=(-50,0.42,3)`. Actual `ReadingBench1.Seat=(-44.27,2.35,1.88)`. Installed `QuadReadingBook=(-50,1.57,3)` and `QuadReadingPrompt=(-50,1.87,3)`. Their tops are approximately 1.66 and 1.96, respectively—below the seat center and below the seat’s lower surface—so they are likely hidden/too low relative to the actual bench. This is a placement defect, not accepted because of a `MEASURED` attribute.
- The exact `Workspace.CozyWorld_Draft01.SurroundingContext.NeighborhoodDetails02.BirthdayCourtyard` query returned eight `Seat` instances: `CelebrationChair`, `_002`, `_003`, `_004`, `_005`, `_006`, `_007`, `_008`, all at y=2.12. `MVP.Stations.CakeFinale` separately returned two `Seat` instances: `EndSeatWest.Seat` at (118,2.12,25) and `EndSeatEast.Seat` at (154,2.12,25). Thus the observed layout totals ten seats when the eight courtyard seats and two CakeFinale seats are combined; the earlier six-seat count was a truncated/filter-limited observation and is superseded.

## Disposition

Do not grant source-equality PASS or engine smoke approval. Route Q01/Q03/client payload mismatches to the source packager; route Q04 prop height and patio seat count to the scene/integrator owner. The read-only lease is released after this report.
