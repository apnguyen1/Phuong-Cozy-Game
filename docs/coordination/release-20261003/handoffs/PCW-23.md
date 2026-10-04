# PCW-23 delivery

Status: **IMPLEMENTED_PENDING_INTEGRATION**. Builder: birthday_finale. October 3, 2026.

## Files and installation

| Source | Install as |
|---|---|
| `roblox/mvp/server/CakeService.luau` | Existing ModuleScript `ServerScriptService.PhuongMVP.server.CakeService` |
| `roblox/mvp/server/FinalePresentation.luau` | New ModuleScript `ServerScriptService.PhuongMVP.server.FinalePresentation` |
| `roblox/mvp/client/extensions/FinalePresentation.luau` | New ModuleScript `ReplicatedStorage.PhuongMVP.client.extensions.FinalePresentation` |
| `roblox/mvp/server/Main.server.luau` | Existing Main Script, retaining PCW-19 through PCW-22 integrations |
| `roblox/mvp/client/Main.client.luau` | Existing StarterPlayerScripts.PhuongMVPClient LocalScript |

Install modules before enabling Main/client. No builder, saved-place or map edit is required; CakeFinale compatibility builder is unchanged and must not run to add more seats. Existing CozyAudio, accepted-action sound hooks, activity views, expiry, actor cleanup and recipient snapshots are preserved. No Sound instance, animation asset, new music ID, personal note or gameplay reward is created by this ticket.

## Authoritative behavior

- Six petals move LOCKED to GATHERING automatically, unless either configured host explicitly used Delay (READY). Hosts can delay before unlock and arm afterward. Arm evaluates Phuong's current authenticated seat occupant immediately, so already-seated-at-unlock is supported. The normal flow has no Start button and no participant-count gate.
- Exactly eight side seats under `SurroundingContext.NeighborhoodDetails02.BirthdayCourtyard` and the existing two seats under `MVP.Stations.CakeFinale.EndSeatWest.Seat` / `EndSeatEast.Seat` are resolved. West is Phuong's designated seat. Lobby, porch and other seats are excluded; no seats are added, moved, replaced or disabled. Wrong-player occupancy cannot start. GetPlayerFromCharacter, current character, live Humanoid, actual SeatPart and World location authenticate the occupant.
- Normal sequence: LOCKED -> GATHERING (or delayed READY) -> CELEBRATING -> CAKE_READY -> EATING. Phuong's seat starts one generation. Main polls at the existing one-second cadence; it also advances on snapshots/actions. Celebration lasts 12 server seconds and advances without camera/audio acknowledgement. Phuong makes the normal first cut after CELEBRATING. `cutAt` distinguishes ready-to-cut from ready-for-slices within CAKE_READY. First eating changes the shared phase to EATING; later arrivals can still take/eat their own slice.
- A participant takes one slice and saves one first eating moment. Another little bite is repeatable cosmetic feedback, with a 1.6-second bite cooldown. No additional funds, petals, rewards, slice purchases or new quests. Participant state survives character reset, lobby travel and disconnect/rejoin to this same server; there is no cross-server persistence.
- Standing, reseating, reset, disconnect, duplicate requests and host re-invites cannot restart the generation or erase cut/eaten state. Host delay is unavailable once started. Phuong remains the only normal cut actor; Andrew's presence or Phuong's absence does not silently grant normal Cut authority.
- All accepted actions bind actor, original action, generation and recovery status to actionId, and occupy the shared receipt namespace. Reused/altered identities, stale generations, wrong session, malformed envelopes and cross-activity IDs reject. Fresh mutation requests have a .3-second rate limit. Server errors are friendly strings; successful cake responses no longer assign a table address to errorText.

## Request, snapshot and PCW-24 contract

The client uses its own confirmation cards and `context.send`; `context.pending` is boolean. Cut and host timing changes require an explicit confirmation card. Main stamps the real actor and rejects client actor fields. Reopening the cake prompt requests a fresh recipient snapshot for proximity-dependent actions. Close emits a new local `PanelClosed` observer event so unfinished confirmation is discarded.

```lua
-- Client: context.send adds current sessionId and unique actionId.
{ kind = "Cake", action = descriptor.action, generation = descriptor.generation }

-- Server-only service API:
local cake = CakeService.new(session, { clock = serverClock })
cake:SetRuntime({
    isWorld = function(actor) return boolean end,
    isAtPatio = function(actor) return boolean end,
    occupant = function() return actualSeatedUserIdOrNil end,
    scene = function() return sceneTableOrNil end,
})
cake:Tick() -- returns whether this call advanced state
cake:GetState(actorUserId) -- recipient-specific availableActions/slice flags
cake:Apply({ sessionId=..., actionId=..., actorUserId=..., action=..., generation=... })
```

Normal actions: Arm, Delay, Cut, TakeSlice, Eat, Bite. Canonical legacy aliases Invite -> Arm and CancelInvite -> Delay remain, with all current validation/generation requirements. Historical direct Invite/Cut/Eat methods are removed; old smoke/test callers must use current canonical actions without relaxing authority.

PCW-24 may call `cake:Recover(request)` with `action="RecoverStart"` or `"RecoverCut"` **after** HostService authenticates explicit Override and confirmation. CakeService independently checks configured host ID, presence/World, generation, action identity and progression. RecoverStart requires all six petals and no previous start. RecoverCut requires CELEBRATING or CAKE_READY, ends the celebration early if necessary and records the first cut once. Neither resets/restarts anything. The ordinary Cake remote does not expose recovery. PCW-24 owns audit, confirmation and panel routing; it should call `advanceCake()` and broadcast after a recovery so world/cameras/music refresh. Host Arm/Delay use normal Apply and cannot undo an existing celebration.

Every `snapshot.cake` contains `phase` and identical `finaleState`, `generation`, `revision`, `unlockedAt`, `startedAt`, `endsAt`, nominal `duration=12`, `cutAt`, `armed`, `delayed`, `invitation`, `atPatio`, personal `sliceTaken`/`hasEaten`/`biteCount`, `guide` and `availableActions`. Timeline times use `workspace:GetServerTimeNow()`; omitted times have not occurred. Generation starts at zero and becomes one once. Recovery can shorten endsAt; startedAt never changes. Actor descriptors contain id/action/label/generation/enabled/reason and optional confirm copy. Main sends each recipient their own descriptors, including initial and late snapshots, and broadcasts a changed revision even if a private snapshot advanced the timeline first.

`scene` contains tablePath, phuongSeatPath, seatCount=10, and center/phuongSeatPosition as plain `{x,y,z}` tables (not Vector3/CFrame, which Main.uiCopy strips). Service `participants` is server-only state used by presentation, not a cross-recipient view.

## Camera and PCW-26 music contract

The extension uses `Init(getContext, registry)`. The first argument is a function. A small Happy Birthday, Phuong banner offers Watch birthday view and a 52-pixel Skip / Return. No camera changes occur until that player opts in near the patio. The pan uses the shared timeline, so late opt-ins see its remaining portion. It never disables player controls or moves the avatar. Movement or leaving a seat immediately returns to exploration. Ordinary HUD visibility, CameraType, subject, CFrame and field of view restore on completion, Skip, movement/unseat, death, CharacterRemoving, lobby entry, camera replacement or owned UI/module destruction. Respawn repairs an orphaned subject to the new Humanoid. Skip is remembered for this local session/generation; no remote skip or progress acknowledgement is sent.

PCW-26 alone owns birthday asset `87992648461099` and gameplay `139568344220252` playback, loading, duck/resume, mute and volume. Use snapshot.cake's phase/generation/startedAt/endsAt with server time; do not depend on the cake panel being open. There is no birthday Sound in either PCW-23 module.

Local observer events delivered through `Extensions.Notify`:

- `FinaleCameraStarted`: opted into the view.
- `FinaleCameraReturned`: camera restored; reason includes complete, skip, death, returned-to-exploring or cleanup.
- `FinaleCameraSkipped`: local opt-out; includes sessionId, generation, startedAt, endsAt and reason. Skip also works without having opted into the camera. PCW-26 should respect it without changing shared state.

For a late-loading MusicController, `context.gui` also stores local `FinaleSkippedSessionId` and `FinaleSkippedGeneration` attributes. Match **both** before suppressing that generation's birthday playback. Treat generation zero as no begun finale. LocationChanged and CharacterRemoving remain available. The current shared CELEBRATING duration is 12 seconds; final audio audition must judge the specified song's playback/ending against this duration rather than claiming a full-track audition from source.

## World ownership and limitations

All new world objects live only in `MVP.RuntimePresentation.FinalePresentation`: SeatCues, BirthdayCaption, Celebration, Serving and PersonalSlices. New parts use unique sibling names, exact eight-token palette values and PCW-23/PaletteToken attributes. Geometry is anchored, noncolliding, nontouching and nonqueryable. The saved cake, candle/topper, tablecloth, table and chairs stay intact.

Ten short seat labels mark Phuong and guest seats during gathering. A birthday caption, 18 restrained native confetti pieces and six golden candle accents play during celebration. The first cut animates a small cake server and reveals a shared slice. Each current World participant who took cake has a plate, frosted slice and utensil; a server-timed utensil-to-mouth motion uses R6/R15 hands with a body fallback and reduces the visible slice after first eating. No avatar motors or uploaded animations are required. Leaving World/reset/disconnect removes only that actor's temporary geometry; the saved slice state restores it on return.

At most 40 fixed BaseParts plus six per present slice holder (100 at ten people). One cosmetic Heartbeat updates at most 20 Hz. Models are reused and removed on departure rather than appended per bite. Destroy disconnects and removes only the owned subtree. Missing/incorrect seat/table/cake roots produce a warning and leave gameplay source running; this is a final integration defect requiring repair, not a passed seat trigger.

## Deferred checks

No tests, compilation, Studio access, playthrough, builder execution, save or publication occurred. This handoff and source reading are not PASS, palette capture, physical-device or human acceptance.

- Install/compile all five sources; exercise actual cake prompt and descriptor envelopes on touch/desktop. Confirm shared revisions, recipient actions, no successful errorText and ordinary Q01-Q06/audio regressions. Root's `verification/release-20261003/cake_contracts.spec.luau` is authored but unexecuted.
- Before/six-petal unlock; Phuong already seated; host Delay before unlock, Arm while seated, guest in designated seat, Phuong in another seat, 1/8/10 participants, simultaneous unlock/snapshot, unseat/reseat and every reset/disconnect/late join phase. Authenticate both actual IDs, reject guests and payload spoofing.
- Normal Phuong cut, Andrew explicit PCW-24 recovery while Phuong is present/absent, no repeated generation/cut/reward, all stale/duplicate/cross-activity identities, rate limits, per-person TakeSlice/Eat/Bite and same-server rejoin. Verify recovery updates world state and local camera/audio together.
- View opt-in/Skip without watching/late opt-in, free movement, unseat, death, character removal, lobby travel, respawn, camera replacement and UI destruction. Check CameraType/subject/FOV and usable controls afterward; one player's choice must not alter another's view or shared timeline. Confirm the short pan has clear sightlines in the saved patio and streaming does not show missing scenery.
- Phone portrait/landscape/tablet/desktop: banner, 52-pixel watch/skip/cake/confirmation controls, ordinary journal visibility afterward, scroll and touch controls. Physical chair clearance, ten real avatars, table/camera occlusion, slice/utensil hand and mouth placement for default rigs, native palette and unique-path capture, lighting, confetti cost and repeated-bite cleanup need actual evidence.
- PCW-26 music: birthday asset permission/load, elapsed-time sync and late seek, skip/mute/volume, recovery-shortened end, 12-second timeline ending, lobby/world transitions, one birthday player, background duck/resume and failure without gameplay stalls. No audio permission or quality claim is made here.

No personal birthday note was written or altered.
