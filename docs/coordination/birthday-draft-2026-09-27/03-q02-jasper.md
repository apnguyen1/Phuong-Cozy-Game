# Q02 — Jasper’s bedroom greeting and garden fetch

Status: implementation-ready design draft, not implemented or approved. This document narrows PCW-08 to one shared Jasper activity: greet Jasper in the existing bedroom, discover his rabbit clue, then use the existing outdoor garden fetch lane. It does not claim that the current Roblox scene, anchors, navigation mesh, or Jasper asset have been measured or installed.

## Confirmed scope and proposed defaults

Confirmed by the September 27 coordination brief and PCW-08: Q02 starts with Jasper in Phuong’s existing bedroom; his outdoor fetch area remains available; Jasper is a fluffy golden-orange Pomeranian; rabbit discovery, fetch, treat, petting, touch throw, cooperative access, leave/rejoin continuity, and exactly one flower petal are required. The bedroom remains one room, with independent third-person cameras and no mandatory cinematic.

The outdoor sequence below is a concrete proposal so it can be implemented and tested. It is not a separately user-approved fact: one sniff clue identifies one rabbit hidden in one of three garden baskets; the rabbit is carried or returned to Jasper; three generous fetch targets are thrown once each; the final action is a Greenie treat followed by optional petting. The exact target meshes, basket arrangement, lane dimensions, reward feedback, and Jasper animation set remain open until source inspection and playtest.

## Player experience and exact sequence

1. **Arrival and greeting.** The queued party arrives at ten server-owned, non-overlapping bedroom arrival spots. Jasper starts at `JasperBedroomStart`, clear of the bed, door, and players. Each player keeps an independent camera. A short proximity prompt, “Say hi to Jasper,” is available from a forgiving radius; one accepted greeting starts Q02 for the session, but every nearby player may greet and receive acknowledgement. The server owns the greeting state and deduplicates each player’s action.
2. **Bedroom clue.** After the first accepted greeting, Jasper performs a brief bark/look/sniff cue and a readable clue appears: follow Jasper outside to find his rabbit. No player is locked in dialogue or camera control. A second player may accept the same clue while the first is moving. The bedroom door remains usable; crowding the door does not block the activity.
3. **Transition to the garden.** Jasper leads toward the existing outdoor fetch lane. The route must use an actual clear doorway and existing garden connection, not a new bedroom fetch arena. A waypoint marker and subtle Jasper sniff trail are available to all participants. Players can walk ahead or remain inside. If navigation stalls for the configured short timeout, Jasper returns to the nearest valid waypoint and the server enables a “Show garden clue” interaction that reveals the three basket locations; this is a fallback, not a teleport or forced warp.
4. **Rabbit discovery.** Three baskets are readable and reachable from the lane. Exactly one contains the rabbit for the round. Any player may inspect a basket; incorrect baskets give a harmless “not here” response and do not consume progress. The correct basket reveals one shared rabbit object and a server receipt. Repeated inspection after discovery is idempotent. The rabbit is not duplicated for each player.
5. **Return and handoff.** Any participant may carry/interact with the discovered rabbit and bring it to Jasper’s handoff radius. The server accepts one handoff, marks the rabbit step complete, and shows a shared acknowledgement. A player leaving after discovery cannot erase it; another player can finish the handoff. If the carrier disconnects, the rabbit reservation releases and the object returns to its basket or a safe handoff reset point.
6. **Three fetch rounds.** Jasper presents three distinct, generous targets in sequence (for example, ball, rope, and plush), each used once. The current target is visible near Jasper and in compact UI. Any participant inside the throw zone can tap/click “Throw” and aim with a forgiving lane target; a throw request is server-validated. One player cannot reserve all rounds: each accepted round immediately advances to the next target, and the next thrower can be anyone. A duplicate request, late request for an already completed target, or repeated tap produces no second reward or petal.
7. **Fetch recovery.** If a target lands outside the pickup corridor, the server resets it to a clearly marked retry spot after a short timeout. If a thrower leaves, the target remains available. If Jasper’s return navigation stalls, the same fallback waypoint interaction makes the target recoverable without requiring an NPC path to complete. No target is permanently lost because of one player’s disconnect.
8. **Greenie and petting finish.** After all three targets are accepted, Jasper enables one shared “Give Greenie” action. Any participant may complete it once. This awards the Q02 round completion receipt, the one Q02 petal, and the applicable shared-fund reward through PCW-13’s server contract. Petting is then available as an optional, repeatable social interaction; repeated pet taps produce animation/acknowledgement only, never manufactured currency, duplicate petals, or duplicate treats. Jasper remains present for replay.

## Shared state, permissions, and replay

Use the common session/activity contract rather than a local wallet:

```text
sessionId
activityId = Q02
roundId
actionId
contributorId
acceptedStep = greet | rabbitFound | rabbitReturned | fetch1 | fetch2 | fetch3 | greenie
roundCompletionReceipt
onceOnlyPetal(Q02)
onceOnlyFundReward
```

The server owns Jasper’s state, rabbit location, current fetch target, reservations, action deduplication, completion receipt, petal, and fund reward. Clients own prompts, local camera, input, and non-authoritative animation requests. Any player may help with an unfinished accepted step. A participant may not complete the same step twice for additional rewards. Q02 must not require all eight or ten arrivals to remain online.

Leaving releases only that player’s unfinished carry/throw reservation; accepted steps persist in the running birthday session. Rejoining the same gameplay server restores the current Q02 state and shows the active target or completed state. A new birthday session starts Q02 fresh. An explicit replay after completion creates a new `roundId`, keeps Q02’s petal at one, and pays only the later-round reward specified by the shared fund contract. Replay must not reset another player’s in-progress round or duplicate Jasper/rabbit instances.

If the bedroom is crowded, prompts use distance and line-of-sight tolerances rather than exclusive seats. Ten arrivals must have clear paths around Jasper, the bed, and the door. A participant arriving late to the gameplay server sees the current shared state; a failed teleport or temporary disconnect must be handled by the queue/transfer contract, not by restarting Q02 locally.

## Controls and usability

Desktop: movement plus the normal interact key for greet, inspect, handoff, Greenie, and pet; mouse click or key prompt for throw, with a visible landing indicator. Touch/tablet: large context buttons with equivalent actions, tap a basket/target, and a thumb-friendly throw button. Prompts must be readable against the bedroom’s nighttime lighting and remain usable at camera angles that preserve an independent third-person view. Do not require precision aiming, rapid tapping, or a forced camera.

## Required stations and geometry contract

These are proposed interface names, not claims that Instances currently exist:

- `JasperBedroomStart`: Jasper start/interaction anchor, with a player-free radius and bed/door clearance.
- `JasperBedroomGreeting`: shared greeting approach volume.
- `GameplayBedroomArrival`: ten arrival offsets that do not overlap `JasperBedroomStart`.
- `JasperFetchYard`: garden entry/waypoint and fetch lane origin.
- `JasperRabbitBasketA/B/C`: three baskets inside the reachable clue area.
- `JasperRabbitHandoff`: Jasper-facing rabbit return radius.
- `JasperFetchThrow`: throw approach volume and target corridor.
- `JasperGreenie`: final treat interaction point.

The placement owner must measure the current bedroom door, garden entrance, basket clearance, and route before implementation. Preserve the existing outdoor garden identity and route; do not invent old map coordinates. The Jasper model must retain a fluffy golden-orange Pomeranian silhouette and approved palette/reference review. World colors remain the exact shared palette; any figure-specific colors require an explicitly reviewed profile.

## Acceptance scenarios

1. One player greets Jasper, finds the correct basket, returns the rabbit, completes three throws, gives Greenie, and sees exactly one Q02 petal and one first-clear fund receipt.
2. Eight to ten players arrive. All can see Jasper and the clue; no player is trapped in the bed, door, or basket lane, and at least two different players can complete different fetch rounds.
3. Two players tap Throw simultaneously. The server accepts at most one action for the current target, advances once, and offers the next target without duplicate reward.
4. A player inspects two wrong baskets. Both responses are harmless; the correct basket remains discoverable and the petal is still awarded only after the full sequence.
5. The rabbit carrier disconnects. The accepted discovery remains; the reservation releases and another player can return the rabbit.
6. A thrower disconnects or throws outside the corridor. The target recovers at the retry spot; another participant completes that target.
7. Jasper navigation stalls. The fallback clue/waypoint action lets the group continue without forced warp or a permanently blocked round.
8. A player leaves after completion and rejoins the same session. Q02 remains complete, Jasper is present, and no second petal or first-clear reward is paid.
9. A completed player explicitly replays. The new round is available, but Q02’s petal remains one and only the later-round shared-fund reward can apply.
10. Touch and desktop players each complete the equivalent greeting, basket, throw, Greenie, and pet actions while cameras remain independent.

## Changes required before implementation

- **PCW-08:** replace the broad “rabbit/treat progress” wording with the ordered shared steps, three one-use fetch targets, Greenie finish, navigation fallback, and exact disconnect/replay behavior above; retain the one optional accident gag limit.
- **PCW-04 / PCW-03:** add measured bedroom arrival, bed/door/Jasper clearance, doorway route, and garden transition evidence. Do not claim current anchors until captured from Studio.
- **PCW-13 / shared progression contract:** define Q02’s once-only petal, first/later shared-fund receipt, contributor acknowledgement, action deduplication, and round replay fields.
- **PCW-02:** add touch/desktop prompts for shared greeting, basket inspection, throw, Greenie, pet, retry/fallback, and active-round status.
- **PCW-16 / verifier contract:** add 8–10-player crowd, simultaneous throw, basket contention, navigation stall fallback, disconnect/rejoin, late join, touch/desktop, repeated pet, and three replay scenarios.
- **PCW-15:** require the approved fluffy golden-orange Pomeranian reference/model profile, rabbit, three targets, Greenie, basket variants, and animation/interaction states.

## Bounded later implementation checklist

1. Measure and record the bedroom/garden anchors and clearances in Studio.
2. Confirm or author Jasper, rabbit, basket, target, Greenie, and animation references under the exact palette/reference review process.
3. Implement the server-owned Q02 state machine against the shared action/receipt contract.
4. Add independent-camera prompts and equivalent touch/desktop input.
5. Add reservation expiry, target reset, pathfinding fallback, leave/rejoin, late join, and replay handling.
6. Capture automated state tests, Studio edit/play evidence, mixed-device evidence, and 8–10-player group evidence.
7. Hand the build to an independent verifier; then conduct human fun and usability playtest. This draft itself is not evidence of implementation, Studio import, performance, or final acceptance.

## Unresolved choices

- Which three existing garden fetch targets and which three basket locations best fit the measured scene?
- What are the actual Jasper rig/animation assets, and which figure-specific swatches are approved?
- What timeout values feel fair for navigation stall and dropped targets after mixed-device playtest?
- Is carrying the rabbit preferable to a proximity handoff for the final interaction, given mobile readability?
- Does the garden have a confirmed navigable connection today, or does the placement task need a bounded route adjustment?

