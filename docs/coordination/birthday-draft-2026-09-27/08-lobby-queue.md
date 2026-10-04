# Task 08 — Birthday lobby queue and group server entry

Status: implementation-ready design draft only. This document does not build, import, publish, or verify a Roblox place.

## Scope and authority

The September 27 coordination packet is authoritative for this draft. The lobby remains a free waiting room. One clearly marked square is the only entry mechanism: the first entrant starts one shared 60-second queue; players may opt in or step out; at eight queued players the server shortens the existing deadline to no later than ten seconds from the shortening moment; capacity is ten; reaching ten never launches immediately. The queued party transfers to one gameplay server and arrives in Phuong’s existing bedroom beside Jasper. Progress is session-only and must survive reconnect to that running gameplay session, not recreate or extend the lobby queue.

PCW-17’s personal countdown, per-player early-entry pad, and same-place outdoor relocation are superseded for this wave. PCW-03 remains the route/camera foundation: ten safe arrival spots, independent third-person cameras, no global camera change, and measured route clearance are requirements, not evidence that the current scene already has those anchors.

The numeric timing and transfer policy below are coordinator defaults made concrete for implementation; they are not separate user approvals. Destination place/universe IDs, reserved-server API details, and exact Roblox service configuration remain unresolved placeholders until the integrator configures and tests them.

## Queue state and authoritative rules

The lobby server owns one `QueueState`:

```text
sessionGeneration: unique lobby queue generation
state: Empty | Open | Shortened | Frozen | Transferring | Completed | Failed
queuedUserIds: ordered unique set, max 10
startedAt: server time, only when first member joins
deadlineAt: server time, initially startedAt + 60
shortenedAt: server time or nil
rosterId: unique frozen roster identity or nil
destinationReservationId: unique transfer identity or nil
```

Clients never choose the deadline, membership, capacity, destination, roster, or session ID. The server validates that the player is alive, in this lobby server, within the square’s interaction volume, and not already queued. A join request is idempotent for that user and generation. A leave request is idempotent and removes only that user. A request from a player outside the square is rejected without changing state.

When the first valid join is accepted, `Open` starts with `deadlineAt = startedAt + 60`. Every accepted join after that can only reduce the deadline: if the accepted count becomes at least eight, set `deadlineAt = min(old deadlineAt, serverNow + 10)` and set `Shortened`. A later join never extends it. A count falling below eight never extends it or returns to `Open`. At ten, further joins are rejected with a readable “Queue full” response; there is no instant launch. If the queue becomes empty before freeze, the server resets all timing and transfer fields, increments `sessionGeneration`, and returns to `Empty`.

The server uses a monotonic server clock and treats expiry as `serverNow >= deadlineAt`. It freezes exactly once, snapshots the ordered unique roster, and removes the live join/leave affordance. The roster is the only group eligible for that transfer. Players who were not in the snapshot remain in the lobby and may start a later generation after the current generation has completed or failed.

## Exact player sequence

1. A fresh player spawns safely in the decorated birthday room. The room keeps the readable “Happy 24th Birthday, Phuong” greeting, favorite-things displays, eight seats, and a clear route. There is no personal timer.
2. The player walks onto the opt-in square. A touch-sized and desktop-readable prompt explains: “Join the birthday group — up to 10 players.” The player explicitly activates Join; standing on the square alone does not opt in.
3. The server accepts or rejects the request. On success, the player is added once to the shared roster, receives a queue badge, and can leave by activating the same square or a visible “Leave queue” action. On rejection, the client shows the server reason and remains movable.
4. The HUD shows roster count (`n/10`), a shared remaining time, queue status, and a short explanation that eight players shorten the remaining wait. It does not show a per-player deadline.
5. Other players independently join, leave, sit, stand, move, or inspect the room. Seats are presentation-only; a seat reservation must not block joining or transfer. If a seated avatar is frozen for transfer, the seat is released before character movement/teleport is attempted.
6. At eight accepted members, the server shortens only if ten seconds is earlier than the existing deadline. At ten, the server remains waiting until the deadline.
7. At expiry, the server atomically freezes the roster and creates one `rosterId`/destination reservation. All frozen members see “Group ready” and lose Join/Leave controls. Non-members see the lobby normally.
8. The transfer service sends the frozen roster to one configured gameplay destination. The destination creates exactly one birthday session keyed by `rosterId` and places members into ten safe `GameplayBedroomArrival` slots. The opening is playable immediately: independent cameras, movable avatars, bedroom access, and Jasper indoors; no mandatory cinematic or camera lock.
9. A member who does not arrive because of a transient transfer failure is retried against the same destination reservation, not a newly created party/session. A duplicate callback or retry is ignored after that member’s arrival receipt is recorded.
10. After the transfer window closes, the lobby marks the generation `Completed` only when the destination acknowledges the roster/session creation, or `Failed` with a recoverable user-facing result if no destination can be reached. A failed generation must not silently start a second session or reset a member’s in-game progress.

## Timing examples

All times are server-clock examples; `t0` means the first accepted join.

| Event | Result |
|---|---|
| First member at `t0` | Deadline `t0+60`. |
| Eight members accepted at `t5` | Existing deadline `t0+60`; new deadline `t15`. Departure occurs at `t15`, not immediately at eight. |
| Eight members accepted with 6 seconds left | Existing deadline is `now+6`; `min(now+6, now+10)` keeps 6 seconds. |
| Nine members arrive after shortening | No extension; the original shortened deadline remains. |
| One member leaves, count falls from 8 to 7 | No extension and no restoration to 60 seconds. |
| Ten members are queued | No instant launch; departure still waits for the deadline. |
| All members leave before expiry | Queue becomes empty and resets with a new generation. |

## Capacity, arrivals, absence, and reconnect

Membership is by unique Roblox `UserId`, not avatar count or display name. A player can occupy at most one place in the roster. An eleventh player receives “Queue full; wait for the next group” and cannot displace or follow a member. A disconnect before freeze removes that user after server cleanup; if this empties the queue, the generation resets. A disconnect after freeze does not alter the frozen roster, deadline, or destination reservation.

The queue does not require Phuong or a designated host to be present. If Phuong is absent, the group can transfer and complete activities; Phuong-gated spending/cake behavior must use the separate host-fallback rules owned by Task 09. No lobby player is treated as host merely because they joined first. A late lobby entrant after freeze waits for the next generation. A player whose transfer failed may rejoin the same destination reservation while it is open; they must not reset the lobby timer or create a second birthday session.

If a player returns to the gameplay server, the destination identifies the running birthday session by its server-owned session identity and user identity, restores current session progress, and does not resurrect the lobby timer. A new/restarted gameplay session starts fresh under the separate session-only rule. Rejoining must never duplicate a petal, fund reward, activity round, purchase, or cake state.

## UI and input contract

Desktop: walk into the square, face the sign, and activate the normal interaction key; keyboard movement and mouse/camera orbit remain available. Touch/tablet: the prompt is a large reachable button with an explicit Join/Leave label; the shared count and seconds use readable contrast and do not cover the movement thumbstick or camera controls. Both input paths call the same server action and receive the same accepted/rejected result.

Required visible states are `Waiting`, `Joined`, `Shortened`, `Full`, `Frozen`, `Transferring`, `TransferRetry`, `TransferFailed`, and `DestinationReady`. The shared seconds display must be derived from server time and tolerate ordinary replication delay; it must not count down locally as authoritative. Accessibility copy must explain that stepping off alone does not cancel membership, while activating Leave does; the final implementation should also make the queue badge and square visually distinct using the approved palette roles.

## Transfer and exactly-once interface

The later implementation should expose a narrow server-side interface, with details finalized by Task 09’s common contract:

```text
JoinQueue(userId, queueGeneration) -> accepted | reason, count, deadline
LeaveQueue(userId, queueGeneration) -> accepted | reason, count, deadline
FreezeQueue(queueGeneration) -> rosterId, orderedUserIds, destinationReservationId
CreateOrGetBirthdaySession(rosterId, destinationReservationId) -> sessionId
TransferMember(rosterId, destinationReservationId, userId) -> attemptId
RecordArrival(rosterId, destinationReservationId, userId, arrivalReceiptId)
Reconnect(sessionId, userId) -> current session snapshot | reject
```

Every request needs an action identity for deduplication. `rosterId` is created once at freeze; `destinationReservationId` is reused on retry; `sessionId` is created-or-returned exactly once for that roster; each member has one accepted arrival receipt. Partial failure recovery must retain the same destination and session keys. A timeout must not be interpreted as failure until the configured transfer window and retry policy say so.

The actual Roblox transport should be selected and verified against current official Roblox documentation during implementation. The design requires a published-compatible destination configuration, server-side authorization, and secure handoff data; it does not assert a particular service/API signature here. Required configuration placeholders are `UniverseId`, `LobbyPlaceId`, `GameplayPlaceId`, destination access/privacy configuration, transfer timeout, retry window, and arrival-slot anchor names. No fabricated IDs are allowed.

## Safety and bedroom arrival

The gameplay destination must provide ten measured, non-overlapping `GameplayBedroomArrival` slots around the existing bedroom, with clear paths away from the bed, Jasper, door, and interaction stations. Arrival slots should be server-assigned deterministically from the frozen roster order, then checked for occupancy before placement. If a slot is blocked, choose another unused slot; never stack avatars or place one inside furniture. Arrival does not force a camera angle, sleep animation, or teleport through an obstacle.

The lobby room must retain the existing eight-seat and central-route requirements, but queue membership is independent of seating. Transfer cleanup releases seats, prompts, and any temporary interaction reservation exactly once. Prompt/expiry, Join/Leave, disconnect, and reset races resolve on the server’s serialized queue state; stale client responses are ignored when their generation does not match.

## Acceptance scenarios

1. First join: one player explicitly joins; expected `1/10`, approximately 60 seconds, one roster entry, no personal timer.
2. Eight-at-five: eight valid joins complete by `t5`; expected deadline `t15`, no immediate transfer, all eight remain eligible.
3. Six-left: eight join with six seconds remaining; expected departure in six seconds, not ten.
4. No extension: after shortening, a ninth and tenth member join; expected unchanged deadline.
5. Drop below eight: one of eight leaves; expected unchanged deadline and seven-person roster.
6. Empty reset: the final member leaves; expected new generation, no stale countdown, next first join starts a fresh 60 seconds.
7. Capacity: eleven attempts; expected first ten accepted at most, eleventh rejected without displacement or launch.
8. Freeze boundary: Join/Leave racing expiry; expected one serialized outcome, frozen roster only contains accepted members, no duplicate transfer.
9. Non-member isolation: an unqueued lobby player remains in the lobby while the frozen roster transfers.
10. Partial transfer: one member times out; expected retry to the same destination/reservation and one arrival receipt, not a second group/session.
11. Host absence: Phuong is not in the roster; expected transfer still works and no unauthorized host control appears.
12. Reconnect: a transferred member reconnects; expected existing session/progress restoration without a lobby timer or duplicate rewards.
13. Ten bedroom arrivals: ten members arrive; expected ten distinct safe slots, movable avatars, independent camera views, no pile-up.
14. Device parity: desktop and touch users can join, leave, read status, move, orbit, and arrive without obstructed controls.

## Required downstream changes

- PCW-17: replace the per-player 60-second countdown, early-entry pad, and same-place outdoor relocation with this one opt-in shared square, server deadline, roster freeze, published group transfer, retry/idempotency behavior, and bedroom arrival.
- PCW-03: add the measured `BirthdayLobbyQueue` and ten `GameplayBedroomArrival` anchors, route-clearance evidence, and ten-avatar camera/slot checks; retain the 16-stud main-route and 12-stud secondary/door target measurements as test targets.
- PCW-02: replace personal timer/early-entry UI states with the shared queue states and touch/desktop copy above.
- PCW-04: add bedroom arrival-slot, Jasper-start, no-pile-up, and reconnect/session-identity dependencies.
- PCW-13/Task 09: consume `sessionId`, `rosterId`, action identity, accepted step, round receipt, once-only petal, and once-only fund reward; explicitly state that queue/reconnect cannot duplicate progression.
- PCW-16: add eight-to-ten real-player published-server rehearsal, simultaneous join/leave, late entrant, Phuong absence, partial transfer/retry, reconnect, and mixed-device evidence.
- Verification contract for PCW-17: remove obsolete personal-countdown criteria and add every acceptance scenario above. Do not mark a local concept or Studio-only simulation as published teleport proof.

## Bounded later implementation checklist

1. Confirm anchor names/measurements with Task 01 and record the actual lobby square, bedroom slots, route widths, and collision clearances.
2. Define the shared queue/session/action schemas with Task 09 and freeze the server ownership/idempotency rules.
3. Implement the lobby state machine and UI against a fake transfer adapter; test all timing, reset, capacity, race, seat, and disconnect cases.
4. Configure real published place/universe destination values and secure transfer handoff only after the integrator supplies them; never commit placeholders as live IDs.
5. Implement destination create-or-get session handling, deterministic safe slots, retry against the same reservation, arrival receipts, and reconnect restoration.
6. Run Studio/local tests for state-machine correctness, two-client behavior, camera independence, touch/desktop input, and slot safety.
7. Run separate published test places for real group transfer, destination availability, partial failure, retry, late join, reconnect, and ten-player arrival. Record logs and screenshots tied to the exact revision.
8. Have an independent verifier review the ticket and evidence, then conduct the PCW-16 human mixed-device/group rehearsal. Documentation alone cannot certify Roblox teleport readiness or fun.

## Evidence limits and unresolved choices

This draft has no live Roblox API, Studio, device, group, published-place, network-failure, or ten-player evidence. The current source files are planning inputs and do not prove that the named anchors, routes, bedroom slots, or destination configuration exist. Exact teleport API choice and current Roblox limits/semantics must be checked against official Roblox documentation at implementation time. Still unresolved are the actual place/universe IDs, access/privacy configuration, transfer timeout/retry window, destination server reservation mechanism, slot coordinates, queue UI art/layout, and the policy for a member who remains unavailable after all retries. The defaults here should be implemented only after those choices are recorded and independently reviewed.
