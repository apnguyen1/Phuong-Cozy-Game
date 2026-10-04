# Shared MVP contract

This is the authoritative server-side boundary for the birthday session. Activity modules must call these APIs; they must not own wallets, petals, or duplicate reward logic.

## IDs and request shape

Every request carries string `sessionId`, `activityId`, `roundId`, `actionId`, and (for step requests) `stepId`. `actorUserId` is the numeric Roblox UserId stamped by the trusted server, never a client-selected opaque ID. The server rejects missing/stale IDs and returns the prior receipt for a repeated `actionId`.

## Activity adapter API

Each activity module exports exactly these server-only functions:

```lua
local activity = Activity.new({session = session, clock = clock, world = worldContext})
activity:CreateRound(request) -- {activityId, roundId, replay?}
activity:Apply(request)       -- {roundId, stepId, actionId, payload}; actor is authenticated server context
activity:GetView(actorUserId) -- UI-safe descriptor; never returns mutable server tables
```

The integrator owns one session-created instance per activity. `Module.new(ctx)` must not bind permanently to the first actor. The server sets the authenticated actor from the actual Roblox `Player` for every request; clients never supply authority-bearing `actorUserId`. `CreateRound` validates activity identity, presence, capacity, replay intent, and that the round ID is new. `Apply` validates actor/presence, station rules, payload, action uniqueness, and accepted-step eligibility; it never credits currency. The adapter must call `SessionService:CompleteRound` only after its own validated completion condition is true. Clients never call `ApplyStep` or `CompleteRound` directly. `ctx` supplies `session`, injectable `clock`, and world context.

`SessionService:SetPresence(userId, isPresent)` is the only presence update boundary; it is called from trusted server `PlayerAdded`/`PlayerRemoving` integration. The kernel never infers online state from request payloads. Accepted steps and completed round receipts remain after a player leaves; only the activity adapter's unfinished reservations may be released.

`Apply` returns `{ok, code, receipt, view}`. `GetView` and returned `view` use exactly these UI-safe fields: `activityId`, `roundId`, `state`, `title`, `instructions`, `progress {done,total}`, `availableActions` (each `{id,label,stepId,payload,enabled,reason}`), `acceptedStepIds`, `contributors`, `busyReason`, `errorText`, and `canReplay`. Empty optional fields are allowed. Views do not grant permission; the server validates every action again.

Q04 maps each player's private bookmark/draft to accepted steps in one server-owned shared round. `StartNextRound` is explicit after the previous round is complete; old saves cannot reward a new round. `CanFinish` requires the activity's validated completion condition and a present authorized finisher. `CanSpend` requires present Phuong (`Phamlet707`, ID `3971290001`) or the configured host ID only while Phuong is absent. Celebration controls separately accept either present verified host (`Phamlet707`/`3971290001` or `IamBannedrew`/`1078077474`).

## SessionService API

```lua
local session = SessionService.new({sessionId = "s", phuongUserId = 7, hostUserId = 7})
session:CreateRound("Q01", "r1", 7)
session:ApplyStep({activityId="Q01", roundId="r1", stepId="fold-1", actionId="a1", actorUserId=7})
session:CompleteRound({activityId="Q01", roundId="r1", actionId="complete-1", actorUserId=7})
session:StartNextRound("Q01", "r2", 7)
session:CommitPurchase({actionId="roll-1", actorUserId=7, cost=20, awardFigureId="BigIntoEnergy01"})
local snapshot = session:GetSnapshot()
```

`ApplyStep` records one accepted step and contributor. `CompleteRound` creates exactly one immutable completion receipt, grants one petal if that activity has none, and credits the first-clear or replay reward once. Q01/Q02/Q03/Q04/Q06 earn 20 on their first completed round and 10 on each explicit replay; Q05 never earns. Rewards are session-wide and never multiplied by contributor count. `CommitPurchase` is the atomic debit/award receipt primitive for Q05; the Q05 owner chooses the outcome and inventory policy.

Completion idempotency is round-scoped: a second completion action ID for an already completed activity/round returns the original receipt and cannot pay again. Replay rewards are derived from prior completed rounds, never from a client-controlled replay flag. `ApplyStep` requires matching session/activity/round identity and returns a normalized accepted or duplicate result.

`GetSnapshot` returns UI-safe state: phase, fund balance, petals, wanted figure/counter, round summaries, and permission flags. Rejoining the same server reads the same snapshot; a new session starts empty.

## CakeService API

`CakeService` consumes the session snapshot. It exposes `Invite`, `CancelInvite`, `Cut`, and `Eat`. Both present verified hosts may invite/cancel/cut; guests and disconnected actors may not. Q05 owns wanted selection, probabilities, inventory, and calls `SessionService:CommitPurchase` after its server-side outcome decision. Cake requires all six petals, then an invitation and voluntary arrival; it has no full-roster gate or forced camera/teleport.

All state is session-only. The personal birthday note is never populated by these modules.
