# Task 09 — Shared birthday fund, wanted figure, and cake finale

Status: implementation-ready design draft only. No Roblox code, Studio mutation, publishing, or approval is included.

## Scope and authority

The confirmed direction is one shared birthday fund, six shared quest petals, session-only progress, a wanted Big into Energy Labubu outcome, and a voluntary cake gathering. This draft owns the common progression contract used by Q01–Q06 and the finale. It does not own station geometry, individual activity rules, queue transfer, or the personal birthday note.

The following are coordinator defaults proposed to make implementation concrete, not separately user-approved numeric decisions: first completion of each earning activity pays 20 fund units, later explicit completed rounds pay 10, and a Labubu roll costs 20. Thus five first earning rounds produce 100 units and five rolls. The coordinator may revise those amounts before implementation without changing the receipt model. The user-approved requirement is shared spending and priority for Phuong's wanted figure, not these exact rates.

## End-to-end player experience

1. The queued party arrives in one gameplay server at ten distinct bedroom arrival spots. A server-created `BirthdaySessionId` begins at `BedroomArrival`; it is not a personal lobby timer. Players may move, inspect the empty user-authored note holder, and use the bedroom activities independently. No cinematic, forced sleep, camera lock, or note prose is generated.
2. Q01–Q04 and Q06 expose their own stations. A participant can start or join an available round, contribute through the activity's accepted action, cancel, leave, or reconnect. Every accepted contribution is acknowledged personally, but the eligible fund reward is credited once to the shared session fund. Q04 bookmarks remain independent until the server commits its shared round.
3. Each of the five earning activities has one first-clear round. A successful first round creates its activity petal and the first-round fund receipt. Later replay rounds may create additional fund receipts at the proposed 10-unit rate, but never another petal. Replay is voluntary; five first clears are sufficient for the intended five rolls.
4. Q05's UDistrict vending activity is the sixth petal. Its wanted-figure selection is made by Phuong (or the configured host fallback when Phuong is temporarily absent). The selection locks until fulfilled. Spending is authorized only after the selected figure and purchase action are visible in the shared fund panel.
5. A purchase validates balance, wanted selection, and a fresh action ID before debiting. The award is committed before the reveal animation; reconnecting during the reveal returns the committed result. An early wanted result fulfills the Q05 petal. If the first four eligible rolls miss the wanted selection, the fifth eligible roll guarantees it, including when the selected ID is the secret figure. The secret figure has the existing proposed 1% chance outside the guarantee; six regular figures are proposed at 16.5% each. These probabilities remain a Q05 contract dependency and need explicit alignment before implementation.
6. After five earning petals and the Q05 wanted-Labubu petal are committed, the shared flower shows six petals and the finale unlocks. Fund balance alone never unlocks it. The host/Phuong control shows `Invite to cake`, `Wait`, and `Start gathering`; waiting does not reset progress and allows reconnecting friends to return.
7. Invited players receive a non-blocking patio destination cue. They walk voluntarily to the existing ten-seat `FinalePatio`; there is no forced teleport or camera switch. Phuong's cut action is available at the cake when she is present or to the configured host fallback when she is temporarily absent. A cut receipt is once-only. Guests can sit or use a forgiving eat action from the seating area; eating does not require all ten seats or all original participants. After the cut, the world remains free play and all activities remain available.

## Common server contract

Every request is client-originated and server-validated. Suggested records are conceptual names, not current Roblox Instances.

```text
BirthdaySession { sessionId, generation, hostUserId, phuongUserId,
  phase, petals[Q01..Q06], fundBalance, wantedFigureId,
  wantedRollCount, finaleState, participantIds }
ActivityRound { sessionId, activityId, roundId, state, startedBy,
  acceptedStepIds[], contributorIds[], reservations[], completedAt }
AcceptedStep { sessionId, activityId, roundId, stepId, actorUserId,
  actionId, acceptedAt, payloadHash }
CompletionReceipt { sessionId, activityId, roundId, receiptId,
  petalGranted, fundRewardGranted, contributors[], committedAt }
FundReceipt { sessionId, receiptId, activityId, roundId, amount,
  reason, contributorIds[], committedAt }
PurchaseReceipt { sessionId, actionId, wantedFigureId, cost,
  debitApplied, awardFigureId, wantedRollCountAfter, committedAt }
```

IDs are opaque, unique within their scope, and retained for the running session. A repeated `actionId`, `stepId`, `roundId`, or receipt returns the original result rather than applying it again. A round cannot pay merely because a client watched, tapped repeatedly, joined late, or sent requests for multiple players. The server derives contributors from accepted steps and never multiplies the reward by player count. A solo Phuong run is valid wherever the activity's own accepted action permits it.

### State and transitions

`BirthdaySession`: `ACTIVE → FINALE_READY → INVITE_OPEN → CUT → FREE_PLAY`; `ACTIVE → ABORTED` only for a server/session failure. A reconnect restores the same live record. A genuinely restarted session creates a new `sessionId` with zero fund, no petals, no wanted selection, and no purchase history.

`ActivityRound`: `OPEN → IN_PROGRESS → COMPLETED`, or `OPEN/IN_PROGRESS → CANCELLED/EXPIRED`. Accepted steps survive a participant disconnect. Their unfinished reservation is released after the activity's inactivity limit; the whole station is never held by one player. `COMPLETED` is immutable. An explicit replay creates a new `roundId`; reopening or resaving an old round cannot pay.

`Q05 purchase`: `OFFERED → VALIDATING → COMMITTED`, or `OFFERED/VALIDATING → REJECTED`. Debit and award are one server transaction. If the client retries after a timeout, `actionId` returns the committed receipt. A disconnect cannot roll back a committed award.

`Finale`: `LOCKED → READY → INVITED → CUT → EATING → FREE_PLAY`. `CUT` requires all six petals and an authorized cutter. `EATING` is open to any present participant; guests may arrive late, decline, disconnect, or continue exploring.

## Permissions and collection choices

Phuong's configured user ID is the default wanted-selection, fund-spending, and cake-cut authority. A separately configured host fallback may perform those actions only while Phuong is absent or unavailable; it must be visible in the session permissions panel. Ordinary guests may inspect the fund, wanted figure, roll counter, petal state, and receipts, and may contribute to activities, but cannot spend, change the wanted selection, cut the cake, or debit another player. No personal wallet, coin transfer, gifting transaction, or cross-session collection is required for the core quest. Direct award into Phuong's session collection is a proposed simplification, not a decision that forbids optional future collection features.

The fund panel should show: `Fund / next roll cost`, six petals with committed/locked state, wanted figure and lock state, roll progress, recent contribution acknowledgements, who may spend, and a clear `session only` label. A voluntary collection display may let players inspect the awarded figure; it must not turn into a grind or hide the shared balance. The personal birthday note area remains empty until the user supplies its exact text; no placeholder prose, paraphrase, or generated guest wish is allowed. Guests may submit their own wishes as private/session text only if a later content design specifies moderation and storage; this draft does not author those messages.

## Concurrent roles for 8–10 participants

The design supports a useful eight-person party without requiring everyone to be online at each gate: two players can operate an activity while others explore, read the shared panel, prepare another station, or watch without receiving a reward. Q03 can split craft and bedroom-display roles; Q04 can bookmark independently; Q01/Q02/Q06 can have separate contributors or observers. The server should expose free/occupied station cues and personal acknowledgements so a contributor knows what counted. At ten participants, no action assumes more than ten avatars, ten patio seats, or one shared interaction target. Arrival positions and patio seating must be safe for ten; late joiners receive the committed state and may participate in remaining rounds or eat cake.

## Input, accessibility, and feedback

Touch: tap an interaction prompt, tap a contribution button, use a readable fund/petal panel, press `Cancel`, `Replay`, `Invite`, `Wait`, `Start`, `Spend`, or `Eat`. Desktop: the same actions are available through the prompt and keyboard/mouse route. Keep movement and camera-drag space clear; no full-screen forced modal is required for watching. Every busy, saved, rejected, insufficient-fund, disconnected, and already-completed state has text plus a color/state cue using the approved UI palette. The current UI ticket must specify exact layout, focus order, and accessible text before implementation.

## Failure, reconnect, cancellation, and replay

- If a player cancels, only their unfinished reservation is released; accepted steps and a completed round remain valid.
- If a player disconnects before commit, the server preserves accepted steps and releases only their unfinished reservation. If they reconnect to the same session, they see the current state and may continue. A completed reward/petal does not require the contributor to remain online.
- If the server receives duplicate taps, duplicate teleports, duplicate purchase requests, or stale client state, it returns the existing receipt or a readable stale-state error; it never pays twice.
- If Q05 cannot commit, no debit occurs. If debit and award have committed, reconnect shows the award and updated fund even if the reveal was unseen.
- If the finale invite is cancelled or delayed, `INVITED` returns to `READY` without changing petals or fund. The host may invite again. `CUT` cannot be repeated.
- A late joiner to the gameplay server does not restart queue timing or reset session state. A player entering after the cut may eat if the cake remains available, or continue free play if the eating interaction has ended.
- A failed destination transfer is owned by the queue/party-transfer draft; this progression contract begins only after a valid gameplay session exists.

## Dependencies and interfaces

Required proposed anchor/activity IDs: `Q01Bed`, `JasperFetchYard`, `Q03FairCraft`, `Q03BedroomDisplay`, `Q04QuadReading`, `Q04BedroomKindle`, `Q05UDistrictVending`, `Q06FOBCounter`, `Q06AladdinsCounter`, `Q06Serving`, `FinalePatio`, and `GameplayBedroomArrival`. Task 01 must replace proposals with measured anchors and clearance evidence. Q01–Q04/Q06 drafts must declare their accepted steps, contributor derivation, round completion condition, and replay behavior against this contract. Q05 must reconcile its vending identity with this shared fund and remove personal-wallet assumptions. PCW-02 must define the common panel and control routes. PCW-16 must rehearse eight to ten participants, late join, reconnect, simultaneous requests, and independent cameras.

## Acceptance scenarios (expected outcomes)

1. **Solo first clears:** Phuong completes Q01, Q02, Q03, Q04, and Q06 alone. Expected: five distinct petals, five receipts, proposed fund balance 100, no player-count multiplier.
2. **Eight contributors:** Eight friends contribute across independent activities. Expected: each accepted contributor gets an acknowledgement; the shared fund receives only the qualifying activity reward, not eight copies; no one needs all five activities.
3. **Watcher/repeated tap:** A non-contributor watches; one contributor sends the same action 20 times. Expected: watcher receives no reward; one accepted step and one reward only.
4. **Q04 concurrency:** Two players save different bookmarks at once and one reopens/resaves. Expected: valid independent contributions can complete one server-owned round; exactly one petal and one eligible fund receipt; resave cannot pay again.
5. **Disconnect/rejoin:** A contributor disconnects before completion, then rejoins the same session. Expected: accepted work remains, unfinished reservation releases safely, and a completed receipt is not lost or duplicated.
6. **Wanted roll:** Phuong selects a figure, spends five eligible 20-unit rolls after the five first clears, and misses the first four. Expected: fifth roll awards the wanted figure, exactly five debits and awards, Q05 petal once, and direct session collection; no fund overspend.
7. **Early wanted win/retry:** The wanted figure appears on roll one; the client retries the same action ID. Expected: one debit, one award, selection fulfilled, retry returns the same receipt.
8. **Permissions:** A guest attempts to change the wanted selection, spend, or cut. Expected: rejected with no state change; configured Phuong/host fallback succeeds under its availability rule.
9. **Finale without full roster:** Two players remain after the sixth petal. Expected: host can delay or start; no absent guest blocks cake, no forced warp/camera, Phuong can cut, and guests can eat or continue free play.
10. **Fresh session:** The party restarts a new session. Expected: zero fund, zero petals, no wanted lock/counter, and no cross-session collection or note text.

## Required updates before implementation

- Amend PCW-13 to replace personal wallets with one server-owned shared fund, define the receipt/idempotency contract, and state the proposed payout amounts separately from confirmed direction.
- Amend PCW-14 to require the six-petal gate, voluntary patio walk, authorized cutter/fallback, reconnect-safe invitation, no guest-count requirement, and post-cake free play.
- Amend PCW-11/Q05 and its verifier contract to use the shared fund, wanted selection, five-roll guarantee, direct session award proposal, and exactly-once purchase/petal receipts; remove the three-discovery rule as a cake gate.
- Amend PCW-02 and its contract with fund/petal/wanted/finale states, touch and desktop routes, cancellation, busy/error/insufficient-fund feedback, and readable permissions.
- Amend PCW-07–12 and PCW-16 contracts to test solo completion, concurrent contributions, no multiplication, watcher behavior, duplicate actions, reconnect, late join, replay, and 8–10-player rehearsal.
- Keep the existing build → independent verify → device/group playtest → revise → retest sequence. Documentation cannot establish Roblox import, live multiplayer, device performance, or fun.

## Bounded later implementation checklist

1. Confirm the session/host/Phuong configuration and replace proposed anchors with measured Studio references.
2. Implement one server-owned session record, activity/round/action IDs, immutable completion receipts, and atomic fund receipts.
3. Implement Q01–Q06 adapters against the contract, starting with one solo activity and one concurrent Q04 case.
4. Implement Q05 wanted selection, balance validation, award-before-reveal, fifth-roll guarantee, and retry recovery.
5. Implement the common fund/petal UI and finale invite/cut/eat states for touch and desktop.
6. Run independent unit/integration checks, then Studio edit/play tests with 2, 8, and 10 players, including disconnect/rejoin and late join.
7. Capture evidence, have the verifier review it, run mixed-device/group rehearsal, and leave the personal note empty pending the user's supplied text.

## Evidence limits and unresolved choices

No current Studio run, import, live teleport, device test, ten-player rehearsal, or human fun review was performed for this draft. Current anchor names are proposed interfaces, not verified Instances. The following remain open: final numeric payout and roll cost; exact host fallback policy and timeout; whether guest wishes are supported and how they are moderated; the final Big into Energy asset/probability reference; the exact patio seating and cake interaction footprint; and whether awarded figures need any optional non-core collection display. Resolve these before freezing PCW-13/14, Q05, UI, and verifier contracts.
