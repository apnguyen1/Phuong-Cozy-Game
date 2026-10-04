# PCW-24 delivery

Status: **IMPLEMENTED_PENDING_INTEGRATION**. Builder: host_recovery. October 3, 2026.

## Files and installation

| Source | Install as |
|---|---|
| `roblox/mvp/server/HostService.luau` | New ModuleScript `ServerScriptService.PhuongMVP.server.HostService` |
| `roblox/mvp/server/SessionService.luau` | Existing server SessionService ModuleScript |
| `roblox/mvp/server/activities/Q01.luau` through `Q06.luau` | Six existing server activity ModuleScripts |
| `roblox/mvp/server/Main.server.luau` | Existing Main Script; retains PCW-19 through PCW-23 integrations |
| `roblox/mvp/client/extensions/HostControls.luau` | New ModuleScript `ReplicatedStorage.PhuongMVP.client.extensions.HostControls` |
| `roblox/mvp/client/extensions/Q05Labubu.luau` | Existing extension; distinguish a free recovery result from a paid box |
| `roblox/mvp/client/extensions/FinalePresentation.luau` | Existing extension; restore the personal camera on local HostTravel |
| `roblox/mvp/client/Main.client.luau` | Existing StarterPlayerScripts.PhuongMVPClient LocalScript |

HostService requires existing server shared Config and FigureCatalog. Install the new modules and changed sources before enabling Main/client. Config was read and left unchanged: Phuong `Phamlet707` / `3971290001`, Andrew `IamBannedrew` / `1078077474`. Display names and client actor fields never grant access. No saved-world builder is needed. No place, original world geometry, audio source, account permissions, personal birthday note, or test permission was changed.

## Authority, confirmation and bounds

- Both exact configured IDs have a discreet Host controls button in the ordinary exploration HUD and a journal entry. All other players receive no `snapshot.host` data. The server private view includes current fund/petals, allowed actions, the actor's confirmation and the bounded audit. It excludes reading drafts, notes, arbitrary commands and other unnecessary player data.
- Override is explicitly enabled per host. Either host can recover while Phuong is present; normal Phuong-first activity/finale choices remain unchanged. The host HUD and panel show a golden HOST OVERRIDE banner with the active host names. Changes of mode are audited. Leaving World, reset/character removal or disconnect clears that host's mode and pending quote.
- Progress/fund/round/finale/travel recovery uses server Prepare -> Confirm or Cancel. Prepare returns the current state and exact effect. Its token belongs to that actor/session, lasts 30 seconds, and is consumed on confirmation. The server compares the captured fund, petals, host revision, affected activity state/round/steps and, for cake, generation/revision/phase before changing anything. Any relevant change requires a new preview.
- Requests use a strict field and operation allowlist. Actor comes only from Main's authenticated Player. Wrong session, arbitrary fields/actions/activities, altered request identities, cross-receipt IDs, expired/consumed/other-host quotes and missing Override reject with readable messages. Main additionally prevents a remembered host action ID from being repurposed as an ordinary mutation.
- Fresh valid host requests are limited to one per actor per 0.5 seconds. Accepted/processed requests are remembered without eviction, to a maximum of 512 per server session. This includes Prepare, Confirm, Cancel and mode changes; denied malformed/stale requests have no side effects. Exact duplicates return the recorded result, including at the limit. The audit retains the latest 32 entries with actor, action, activity, prior/new state and server timestamp. The panel shows six by default and can expand all retained entries. No cross-server persistence is added.
- Top-up is exactly 20, at most five times per server session and at least 30 seconds apart. These bounds and the number already used appear before confirmation. There is no amount field or unlimited currency input.

## Coherent recovery behavior

- **Release/restart:** Q01, Q03 and Q06 only, and only an incomplete round. Release clears all local held choices for the selected activity, including Q01 shelf holds, while preserving placed work. Restart cancels that incomplete SessionService round, clears its holds/placed work, starts a fresh unique round and updates Main.currentRounds to the activity's actual new round. Previously earned petals, all funds, other activities and committed optional shelf placement remain. Restart itself grants no reward; normal later completion of a restarted replay still uses the normal replay amount.
- **Complete a quest:** Q01/Q02/Q03/Q04/Q06 get only a missing initial reward of 20 and a missing petal. SessionService tracks initial rewards and also checks existing non-replay completion receipts, so recovery cannot pay a completed quest or grant a replay reward. The local activity is completed and its normal view/render hooks update. A quest without a round gets a real initial round with synchronized Main tracking. Q05 Complete quest delegates to the selected-wish recovery below; it cannot flip a petal without a collection award.
- **Bed:** fill only missing normal steps, preserve the shelf, finish with Soft and snug if no style exists; render all seven steps and final state. **Jasper:** complete his accepted steps, clear transient holds, settle his sequence happy in the yard with treat feedback. **Craft:** keep committed orientations and fill missing pieces at zero turns, complete six pieces in both normal world displays, leaving Phuong's cosmetic lamp choice available. **Reading:** save shared completion with a specifically labeled recovery step, preserve every draft/private note, and show a shared recovery acknowledgement without inventing anyone's reading choices. **Food:** retain accepted variants and fill missing slots using the disclosed defaults Rice, Tofu, Greens, Sauce, Plate and Cup, then render the complete shared dish.
- **Labubu:** one recovery for this server session, only for the currently normally confirmed, unfulfilled valid catalog wish. If no wish exists, the panel explains that it must be selected at the normal booth under normal authority. Recovery adds exactly one selected figure, fulfills that wish, grants only a missing Q05 petal, and grants/debits zero funds. `latestResult` has `recovery=true`, `cost=0`, `debitApplied=false`, saved copies and normal award metadata. Paid roll/miss counts and the fifth-roll guarantee are unchanged. The result card explicitly says Host recovery / no fund spent. Future optional normal collecting remains available.
- **Cake:** Invite calls the normal Arm path after six petals; it may begin immediately if Phuong is already seated. Start calls CakeService RecoverStart after Override and confirmation, requiring all six petals and no existing start. Advance calls RecoverCut, ending any remaining celebration and making the first cut once. The service's canonical generation/identity/presence checks remain. No operation resets generations, cuts, slices, eaten state or rewards. Main calls advanceCake and broadcasts the updated world/timeline so normal cameras and later PCW-26 music can finish together.
- **Return:** moves only the requesting host to the existing GameplayBedroomArrival or FinalePatio anchor, after validating the living character and destination, releasing only their own activity holds and leaving their seat. The local HostTravel observer explicitly restores an opted-in finale camera even if they were standing, avoiding dependence on MoveDirection/seat changes. Other players' positions/cameras stay independent.

## Server and client interfaces

```lua
local host = HostService.new(session, {
    activities = activities, cake = cake, clock = serverClock,
    runtime = {
        isWorld = function(actor) return boolean end,
        newRoundId = function(activityId) return uniqueRoundId end,
        setRoundId = function(activityId, roundId) end,
        travel = function(actor, destination) return boolean end, -- Bedroom or Patio
    },
})
host:GetView(actor) -- nil for guests; private host presentation data otherwise
host:ReleaseActor(actor) -- clear that host's mode and quote on departure/reset
host:Apply(request) -- {ok,code,message,confirmation?,receipt?,operation?,destination?}
```

Client requests use the existing Action RemoteEvent and `kind="Host"`. Main stamps actorUserId. `context.send` supplies current sessionId/actionId; callers never supply actor/player. Server requests use:

```lua
{sessionId=...,actionId=...,actorUserId=...,action="SetOverride",enabled=true}
{sessionId=...,actionId=...,actorUserId=...,action="Prepare",operation="CompleteQuest",activityId="Q01"}
{sessionId=...,actionId=...,actorUserId=...,action="Confirm",token=confirmation.token}
{sessionId=...,actionId=...,actorUserId=...,action="Cancel",token=confirmation.token}
```

Prepare operations: `ReleaseReservations`, `RestartRound`, `CompleteQuest` with activityId; `TopUp`, `FulfillWish`, `InviteCake`, `StartCake`, `AdvanceCake`, `ReturnBedroom`, `ReturnPatio` without activityId. FulfillWish also accepts the canonical internal Q05 target when the prepared quote is revalidated. Tokens use a deterministic server serial bound to actor; no engine dependency is needed in HostService.

Main replies include `hostResult` plus the recipient snapshot. Only authenticated hosts receive `snapshot.host`. Successful host requests broadcast refreshed recipient activity views; recovery failures with possible partial state also broadcast for coherence. Routine denied host requests do not fan out to all clients. No `payload.view` is sent as an ordinary activity response for host requests.

Every activity exposes `RecoveryState()` and `RecoverComplete(canonicalRecovery)`. Q01/Q03/Q06 also expose `RecoverRelease(canonicalRecovery)` and `RecoverRestart(canonicalRecovery,newRoundId)`. These are server methods, not extra public activity operations. Session helpers are `AssertRecovery`, `MissingInitialReward`, `RecoverCancel`, `RecoverStep`, and `RecoverCompleteRound`; HostService is the production confirmation/deduplication boundary. These helpers do not replace normal Apply paths.

HostControls uses `Init(getContext,registry)`, `RegisterPanel("HostControls",...)` and an observer, with its own confirmation and `context.send` rather than ordinary `runAction`. `context.pending` remains boolean. Main adds `context.activePanel` and `context.openPanel(id)` for the direct button and targeted refresh. Unsolicited host snapshots refresh only an already-open host panel; close/back does not reopen it. All UI colors use existing UI.Palette and normal 48/52-pixel controls. HostTravel is local-only and carries no server authority.

## Deferred checks and limits

No tests, compilation, Studio/tool access to the game, playthrough, world builder, save or publication occurred. This handoff is implementation delivery, not verification PASS, visual acceptance or physical-device evidence. Root authored `verification/release-20261003/host_contracts.spec.luau`; it remains unexecuted, as do all final-stage suites.

- Install all sources and compile only after the sequential implementation queue. Exercise both real configured IDs, Andrew with Phuong present/absent, and guests/spoofed/malformed envelopes. Confirm no test IDs/display-name authority ships.
- Use real current UI descriptors and server quotes: mode on/off, exact current effects, Cancel/Back/Close/timeout, stale fund/hold/round/wish/cake changes, both hosts racing, expired/other-host tokens, same and altered duplicates, old rounds, shared receipt reuse, rate limit, 512 request limit, fixed20 cap/cooldown, audit bound/privacy. Exact duplicate old-round activity receipts may replay their old result; fresh IDs with old round must reject.
- Q01/Q03/Q06 stuck holds, partial rounds, incomplete replay restart, currentRounds consistency, concurrent helpers and open panels, first vs replay reward preservation, no loss of unrelated petals/funds/shelf. Complete every quest from unstarted/partial state; confirm normal world feedback and later replay. Review disclosed default missing-bed/food/craft choices visually.
- Normal first completions before recovery, repeated completion attempts and independent initial reward receipts: only missing initial20/petal, no duplicate money/petal/replay10. Q04 private drafts and birthday note stay untouched.
- Selected regular/secret Q05 wish, early paid misses then recovery, no selected wish, already fulfilled wish, duplicate confirmation and a later optional wish. Verify collection exactly one, cost0/debitApplied=false, no false20-spent UI, no guarantee regression and world shelf/reveal consistency.
- Cake six-petal guards, already-seated Phuong, invite/delay/start/advance races, one generation/first cut, saved slices/eating, late joins, normal Phuong-first authority and Andrew explicit Override. Verify advance returns personal cameras and updates PCW-26 music; host return from seated and standing camera opt-in restores camera/controls and unseats safely without moving friends.
- Phone portrait/landscape, tablet and desktop: three HUD buttons/override banner, readable short status, confirmation scrolling, current-effect text, 52-pixel actions, cancel/back, selected quest and long audit. The panel places selected quest actions before the list of other quests to reduce repeat scrolling; physical touch comfort and view/control clearance remain unmeasured.
- Audit and session state are bounded/in-memory. Top-up maximum100 extra per server session and one wish recovery are deliberate displayed limits. Current-state revalidation can reject a quote while friends make progress; this requires a new preview, never an automatic retry. Presentation warnings or missing character/anchor return failures remain integration defects needing observed repair, not passed evidence.

No personal birthday note was written or altered.
