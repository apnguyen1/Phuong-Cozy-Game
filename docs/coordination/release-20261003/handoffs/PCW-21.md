# PCW-21 delivery

Status: **IMPLEMENTED_PENDING_INTEGRATION**. Builder: labubu_wish. October 3, 2026.

## Files and installation

| Source | Install as |
|---|---|
| `roblox/mvp/server/activities/Q05.luau` | Existing `ServerScriptService.PhuongMVP.server.activities.Q05` |
| `roblox/mvp/server/LabubuFeedback.luau` | ModuleScript `ServerScriptService.PhuongMVP.server.LabubuFeedback` |
| `roblox/mvp/shared/FigureCatalog.luau` | ModuleScript in **both** `ServerScriptService.PhuongMVP.shared` and `ReplicatedStorage.PhuongMVP.shared` |
| `roblox/mvp/shared/FigurePresentation.luau` | ModuleScript in **both** shared trees above |
| `roblox/mvp/client/extensions/Q05Labubu.luau` | ModuleScript `ReplicatedStorage.PhuongMVP.client.extensions.Q05Labubu` |
| `roblox/mvp/server/Main.server.luau` | Existing Main Script; added LabubuFeedback require, construction and Q05 context dependency only |

Install shared modules before enabling Main/client extensions. FigureCatalog requires sibling Config; FigurePresentation requires sibling FigureCatalog. Q05 requires server shared FigureCatalog. LabubuFeedback requires server shared FigureCatalog/FigurePresentation. Q05Labubu requires replicated shared FigureCatalog/FigurePresentation/Guidance and registers through PCW-18 `Init(getContext, registry)`. No builder run, Main.client edit, new remote, Config/economy change, saved-world edit or audio replacement is needed. Preserve PCW-19/20 guards, broadcast/snapshot behavior, expiry and CozyAudio hook. PCW-26 still owns audio source installation.

## Behavior and request schema

- Seven labeled cards show the same native toy geometry as the machine/collection, regular/secret odds and owned copies. Tapping previews locally; an explicit Confirm wish control inside the selected card opens the shared confirmation flow. Guests can inspect cards and track earning activities without disabled purchase controls. Phuong controls wishes/purchases; the existing SessionService permission allows Andrew only while Phuong is absent. Account IDs are unchanged.
- Confirmed wishes lock until fulfilled. A separate Get a Labubu - 20 action confirms the shared spend. Fund, confirmed wish, attempts remaining, copies and latest result remain visible. The five first earning activities still supply the maximum 100 needed; six regular probabilities remain 16.5% each, secret 1%, and the fifth-roll guarantee includes a selected secret.
- A purchase's debit, figure copy, receipt and any first Q05 petal are committed in the same non-yielding server path before presentation. Exactly repeated actor/envelope requests return their receipt; changed-identity duplicates, cross-activity receipt reuse, stale wishes and stale expected roll numbers reject. Two fresh action IDs for the same displayed box cannot debit twice. Q05 still grants no currency and at most one petal.
- A 1.6-second local capsule opening has Skip, followed by a persistent result card. Skip/Close send no award acknowledgement. The latest result and collection are server state through close/reset/lobby/rejoin; no cross-server saving is added. World result updates immediately after purchase, so nearby friends see it even without a panel. Optional later wishes never remove the petal or relock cake; selecting an already-owned figure fulfills that optional wish without spending. The UI points to a remaining earning activity or patio.

Use actual current `GetView` descriptors with the existing canonical envelope:

```lua
{ kind = "ActivityAction", sessionId = currentSessionId, activityId = "Q05",
  roundId = currentRoundId, actionId = uniqueActionId,
  stepId = descriptor.stepId, payload = descriptor.payload }
```

| stepId | payload |
|---|---|
| `select-wanted` | `{figureId=chosenId, wishVersion=currentVersion}` |
| `roll` | `{wishVersion=currentVersion, rollNumber=nextExpectedRoll}` |

Card previews are local; the historical `inspect` action is replaced by those cards. `select-wanted` is the explicit confirmation, not preview. `wishVersion` increments on confirmed choices; rollNumber starts at 1 per wish. Receipt identity binds actor, round, step, figure, wish version and roll number. Failures return friendly `result.message` and a fresh view. Main remains responsible for actual actor/session/World/proximity validation.

Existing useful view fields remain. Additions: `figures` (friendly label, odds, copies, selected), `wantedLabel`, `wishVersion`, `rollCount`, `attemptsRemaining`, `wishFulfilled`, `collectionCount`, `canControl`, `canChooseWish`, `controlMessage`, `nextActivity`, `latestResult`, and guide. latestResult includes receiptId, awardFigureId/awardLabel, wantedFigureId/wantedLabel, wantedFulfilled, awardedAt (server clock), wishVersion, rollNumber, copies and saved debit/petal flags. `state`/progress/q05Petal stay complete after the first wish even during optional collecting; `wishFulfilled` describes the current optional wish separately. `canReplay` remains false because optional collecting uses the same session round.

## World/UI ownership and limits

New world instances are exclusively under `CozyWorld_Draft01.MVP.RuntimePresentation.LabubuFeedback`: Machine, LatestResult and BedroomCollection. The seven exact `MVP.Stations.Q05Station.FigureSlot1..7` rectangular placeholders are hidden at runtime and restored by Destroy; cabinet surfaces/geometry are preserved. Seven labeled previews fit the cabinet face; a single latest figure/open capsule sits at the existing counter. Selection updates labels; purchases replace bounded result/collection models, never accumulate them.

BedroomCollection adds a 7.2 × .65-stud noncolliding ledge at the **front of the fourth shelf**, below the fifth shelf. Its outer edge projects .675 studs beyond the original shelf front. One .4-scale toy per owned identity has a copy label; duplicates increase counts. Original jars/plants/bookcase, PCW-19 top-shelf organization and lower miniature/Q03 slots remain untouched. Placement derives from actual shelf CFrames and the supplied bedroom builder/scene manifest; final live clearance/lighting is unverified. Missing anchors/shelves warn and leave authoritative UI/collection available.

Figures use bounded native rounded parts: paired long ears, cream face, ink eyes/toothy smile, body/arms/feet and small distinct chest motifs. The largest figure uses 23 BaseParts. All authored world geometry is anchored, noncolliding/nontouching/nonqueryable, tagged PCW-21 and uses exact palette tokens. These are **simplified world-palette toy interpretations, not approved faithful reference art**. Figure labels and token mapping follow the existing proposal; no new colors, textures or asset IDs were introduced. Require independent silhouette/palette/visual acceptance.

The client uses the existing safe-inset shell and 52-pixel buttons. Its mount hides the generic duplicate Q05 action groups through a scoped ChildAdded listener; generic confirmation, pending-request handling and Back/Close remain. The listener/tweens are disconnected/cancelled with the mount; delayed reveal callbacks guard destroyed mounts. No avatar or gameplay camera moves.

## Deferred checks

No tests, compiler, Studio access, playtest, save or publication occurred. This is source delivery, not PASS or human acceptance.

- Install/compile all dependencies, then use the real client descriptor envelopes. Update `roblox/mvp/tests/Q05.spec.luau`: old fixtures omit canonical session/activity/payload fields and expected wish/roll values, assert obsolete generic labels, and attempt a roll after selecting an already-owned wish. Preserve the early/fifth/secret/economy criteria while updating fixture requests; no production guards should be relaxed.
- Verify regular/secret boundary draws, early win/fifth win, owned optional wish, exact one petal/no currency, 100 maximum first-wish cost, duplicates/changed actors/cross-activity action collisions, concurrent fresh IDs for the same box, stale confirm/roll and insufficient funds. Confirm atomic state survives a deliberately failing feedback renderer.
- Two clients: Phuong/guest/Andrew-with-Phuong-present-and-absent, shared fund changes, live watcher result, no closed-panel reopen, close/reset/lobby/rejoin during reveal, late join, Skip/rapid taps/timeouts and persistent result without a second debit.
- Phone/tablet/desktop: seven cards and in-card confirmation, scroll position after selecting/confirming, separate spend confirmation, reveal/Skip and optional collection clarity, readable labels/errors, control/camera clearance. Confirm mount-scoped generic-group hiding works under actual Roblox event scheduling; no claims of measured UI/device performance.
- Inspect booth previews/counter result and fourth-shelf ledge against the live cabinet, jars/plants, Q01 top shelf and Q03 miniature; verify placeholder hide/restore, lighting/palette/silhouette, labels and walking/camera clearance. Check bounded part counts and reveal cleanup after repeated purchases. Perform required independent visual and real-group review.

No personal birthday note was written or altered.
