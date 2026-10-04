# PCW-19 delivery

Status: **IMPLEMENTED_PENDING_INTEGRATION**. Builder: bed_shelf. October 3, 2026.

## Changed files and installation

| Source | Install as |
|---|---|
| `roblox/mvp/server/activities/Q01.luau` | ModuleScript `ServerScriptService.PhuongMVP.server.activities.Q01` |
| `roblox/mvp/server/BedroomFeedback.luau` | ModuleScript `ServerScriptService.PhuongMVP.server.BedroomFeedback` |
| `roblox/mvp/server/Main.server.luau` | Existing Script `ServerScriptService.PhuongMVP.server.Main` |
| `roblox/mvp/client/extensions/Q01Bedroom.luau` | ModuleScript `ReplicatedStorage.PhuongMVP.client.extensions.Q01Bedroom` |
| `roblox/mvp/builders/Q01Station.luau` | Compatibility builder source only; execution is unnecessary for this release |

Install dependencies before enabling Main. Q01Bedroom uses PCW-18 `Init(getContext, registry)` with `RegisterActivity("Q01", ...)` and an alphabetically loaded observer. No edit to Main.client/UI/Guidance was needed. Preserve the exported live `CozyAudio` and `CozySoundEffectsClient`: Main now includes `require(script.Parent.CozyAudio)` and invokes `CozyAudio.Accepted(r,result)` after a successful activity result. PCW-26 still owns their permanent source installation. Main module paths remain relative to its existing server folder.

No station or room builder run is required. The updated Q01Station builder only returns a metadata Model referencing the original SageBed, preventing future rebuilds from making the old duplicate bed. Runtime feedback hides only existing `MVP.Stations.Q01Station` BaseParts and disables their collision/touch/query, retaining their original values for restoration. The detailed room is not replaced.

## Behavior

- Seven required bed tasks remain: left/right blanket edges, foot quilt, left/right cream pillows, dog plush and dinosaur plush. Friendly cards identify item and destination; selecting/picking up creates a hold, then Place/Tuck/Fold commits. Cancel is explicit. Completed tasks leave the action list and appear in the client's expandable Done list.
- Each actor holds one bed or shelf item at a time. Bed spots and shelf items/slots reserve independently for 30 seconds. Other helpers see In use and can choose a different task. Choosing another item releases the previous hold. Close, lobby return, character reset and disconnect release holds; Main checks expiry once per second and broadcasts changed views.
- Final style is still Phuong's, with SessionService's configured Andrew fallback only when Phuong is absent. SessionService owns completion/reward; Q01 does not add funds or petals itself. Seven accepted steps plus final style grant one first-round reward of 20, then 10 only on explicit completed-round replay, with the same single Q01 petal. Both allowed styles remain.
- The optional shelf is accessible through the bookcase prompt and Q01's optional shelf cards: choose a sage book, cream book or existing-style small shelf figure; choose left/middle/right top shelf; confirm. Guests fill empty spots using unplaced items. Phuong and Andrew can move/rearrange displayed items even when both are present. Replaced owned items return to their tray. This layout persists for the running server and through bed replay, without any reward, extra required step or petal.
- Local held-item previews clone existing room/owned geometry into one small ViewportFrame. A local box cue and Place here label show the recipient's current destination. They are destroyed when the panel hides, with the presentation mount, or on lobby/reset. Camera and player transforms are never changed by the extension. Missing or streamed-out targets leave text guidance usable.

## Runtime ownership and geometry

New instances are exclusively under `CozyWorld_Draft01.MVP.RuntimePresentation.BedroomFeedback`: `Targets`, `BedDetails`, and `Shelf`. `Q01Shelf` is a runtime anchor under Shelf; Main adds it to the server anchors map, and PCW-18 Navigator resolves it recursively. Its prompt advertises `ActivityId = "Q01"`.

The existing bed at `Home.Bedroom.SageBed` supplies SageDuvet, both DuvetSideDrape parts, both CreamSleepingPillow parts and their hems, FoldedCreamQuilt with its fold/piping/floral decoration, and `BedPlushies.WeightedDog`/`WeightedDinosaur`. Each round captures task-part CFrames/sizes, poses those details slightly untidily inside the existing bed, and restores each task's saved pose when committed. Two owned sage fabric wrinkle strips disappear on smoothing. Soft and snug gives the existing plushies a small final pose adjustment; Neatly layered keeps the restored pose. Replay first restores the prior task baseline, captures the next baseline and resets those tasks only. Bed frame/mattress/headboard, lights, other furnishings and activity displays remain untouched.

Shelf geometry uses the topmost `FilledBookcase.Shelf` surface. Small owned books and a sanitized clone of its existing `ShelfFigure` move between an owned back tray and three front target pads. No new personal likeness, collectible name or book title is invented. Original books/figures, the miniature on the lower shelf, the plant at the top right, and Q03/Q05 display ownership are preserved. Exact eight-token palette values are used; cloned original figure part colors/tokens are retained. All new parts are anchored and noncolliding/nontouching/nonqueryable. The legacy MVP bed is hidden only when the detailed SageBed/SageDuvet exists. `BedroomFeedback:Destroy()` restores the owned task and legacy-station values if a runtime cleanup is required.

## Remote and descriptor contract

No new remote request kind. Use the existing canonical envelope supplied by Main.client:

```lua
{ kind = "ActivityAction", sessionId = currentSessionId, activityId = "Q01",
  roundId = currentRoundId, actionId = uniqueActionId,
  stepId = descriptor.stepId, payload = descriptor.payload }
```

Main rejects client `actorUserId`/`player`, derives actor from the actual Player, requires a current session and World location, checks a live character/proximity, then calls Q01. Bed actions must be within 24 studs of Q01Bed; shelf actions use `stepId = "shelf"` and must be within 18 studs of runtime Q01Shelf. RequestView accepts proximity to either. Requests contain IDs only; client transforms, reward amounts and permissions have no authority.

| stepId | payload |
|---|---|
| One of Q01.StepIds | `{action="reserve"}` / `{action="place"}` / `{action="cancel"}` |
| `finish` | `{action="finish", choiceId="soft_snug" or "neat_layered"}` |
| `shelf` | `{action="shelf_select", itemId="book_sage" or "book_cream" or "small_figure"}` |
| `shelf` | `{action="shelf_slot", slotId="left" or "middle" or "right"}` |
| `shelf` | `{action="shelf_place"}` / `{action="shelf_cancel"}` |

Q01 uses action-ID receipts bound to actor and round, without implicit reserve-to-place conversion. Repeated actions do not commit twice; stale round IDs reject. A shelf commit rechecks occupancy, item hold, slot hold and host permission. Clear recoverable errors are returned as `result.message`, shown by Q01Bedroom's observer. Internal direct `Reserve`/`Finish`/`Cancel` methods from the historical module are replaced by the canonical Apply path.

Existing view fields remain. Additions: `held = {stepId,label,destination,targetName,expiresAt}`, `doneLabels`, `shelf = {ready,optional,items,slots,held}`, descriptive `guide`, and explicit `groupId`/`description`/`primary`/`confirm` fields on descriptors. Shelf slots expose public item labels and a busy boolean; another actor's held item/action descriptors are not sent. A shelf hold has `itemId`, `label`, optional `slotId`/`targetName`, and `expiresAt`. No shared item is client-authoritative.

## Shared Main integration for following tickets

Main tracks each successful opened activity by actual UserId; closing the matching round, lobby entry, character removal and player removal clear it. After successful actions/opens/closes and Q01 expiry, each connected player gets their own `GetView(userId)` in `payload.view` only for their tracked activity. These broadcasts omit actionId. PCW-18 refreshes only the same already-open panel, so a closed panel stays closed. The separate `snapshot.activityViews` map always contains that recipient's own views for journal/wayfinding caches. A UI-safe copy drops Instances/functions/cycles; other players' permission-specific views and action receipts are never reused. Main canonical validation now also requires BirthdayLocation World and a table payload for ActivityAction.

Following server builders should retain this broadcast, canonical/proximity path and the CozyAudio hook. PCW-24 can extend host controls without deriving identity from names. Config IDs are unchanged: Phuong 3971290001 / Phamlet707; Andrew 1078077474 / IamBannedrew.

## Deferred checks and known limits

No tests, compiler, Studio session, playtest, save or publication was run. This is implementation delivery, not verification or visual acceptance.

- Compile/install all modules and exercise actual GetView descriptor envelopes through the live client. The old `Q01_activity.spec.luau` fixture calls the removed direct helpers, omits canonical step/session fields, uses a helper not marked present and assumes a 15-second expiry. Update that fixture for actual descriptors and 30-second expiry before running it; do not relax production identity checks to match it.
- Two real clients: different bed steps together; same-spot contention; changing held items; shelf item and slot contention; both-host rearrangement; guest occupied-slot rejection; replace/move an item while another actor holds its source/destination; duplicated actions/finish/replay and stale envelopes.
- Bed initial untidy poses, each visible change, both final styles, replay baseline restoration, no repeated reward, one petal, and retained shelf layout. Confirm no task decoration was missed by current live names.
- Close/back, request timeout, expiration, reset, lobby, disconnect/rejoin and late join must release held resources and show authoritative state. Check broadcasts never open closed panels or show another actor's held action.
- Inspect runtime top-shelf clearance against the actual plant/room and camera; supplied source/scene paths establish placement intent but no live screenshot or measured result is claimed. Confirm legacy duplicate bed is hidden without affecting the Q01Bed prompt.
- Phone/tablet/desktop preview sizes, Done expansion, optional shelf discoverability, labels and scroll depth, joystick/jump/camera clearance, and missing/streamed art behavior. Preview/target rendering and overall room warmth need independent visual review.
- Final mixed-player bandwidth/frame-time check: recipient-specific snapshots include all six views on ordinary results/broadcasts, not a timed polling stream. Existing click/success/Jasper audio and later activity/finale extensions need regression checks.

All persistence here is session-only. No personal birthday note was generated or changed.
