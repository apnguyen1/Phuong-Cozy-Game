# Q06 — Something Delicious: UDistrict food activity draft

Status: implementation-ready design draft only. No gameplay, Studio, asset, publishing, or live-venue work is included here.

## Scope, authority, and proposal labels

Confirmed in the September 27 coordination packet:

- Q06 remains one of the six shared activities and awards one petal at most.
- Its location moves to the UDistrict area, near the existing FOB Poke Bar and Aladdins landmarks.
- The patio is reserved for the cake finale and group seating.
- Eight real participants are the target, with capacity for ten; cameras remain independent.
- The shared birthday fund and session-only progress contract apply. There are no personal wallets, restaurant economy, or cross-session promises.
- Touch, tablet, and desktop play must be equivalent, forgiving, and usable without precision timing.

The exact food menu is not user-approved. This draft proposes a compact **venue-inspired bowl/plate assembly** because it keeps useful jobs parallel, makes finished food visibly persist, and fits the UDistrict storefront context without claiming to reproduce either restaurant's actual menu. The proposal uses generic ingredients and fictional food names; it is not real restaurant menu research.

The historical PCW-12 wording (“patio cooking,” KBBQ, seafood-boil prep, and a 52 × 24 patio allocation) is retained as source history only. It must be amended before implementation: Q06 is a street-side assembly activity near FOB and Aladdins, and the cake patio is not a cooking station.

## Proposed placement and footprint

Use the proposed shared anchor `Q06FOBCounter` for the FOB-side prep counter, `Q06AladdinsCounter` for the Aladdins-side plate counter, and `Q06Serving` for the finished-food display/serving table. These names are interface proposals, not claims that the Instances currently exist.

The later placement owner must measure the translated scene and place the activity outside storefront doors and crossing lanes. Starting geometry target:

- Two shallow counters, each roughly 10–12 studs wide and 4 studs deep, facing the fair pedestrian route rather than projecting into it.
- A 12-stud clear approach in front of each counter and at least 8 studs behind an active player where the local scene allows it.
- A 10–12 stud serving table or counter parallel to the storefront edge, with four generous interaction sides and no seat, prop, sign, or avatar forced into a doorway.
- Preserve the UDistrict central route, crossing stripe visibility, fair tent strips, and any direct route between Q05, Q03, and the neighborhood. No queue rail is required; the station labels and overhead sign should communicate the activity.
- Keep the cake patio entirely free of Q06 stations, persistent food props, or mandatory return routing.

Suggested visual roles use only the approved world palette: wood counter/table surfaces, cream panels and labels, forest primary action/highlight, golden warmth and completion marks, ink outlines/text, with sage/blossom/brick accents where already appropriate in the environment. Ingredient colors and food shading require later visual review; do not invent a new world-palette exception.

## Coherent proposed activity: “Build the birthday spread”

One round creates a shared visible spread, not ten private meals. Four food jobs can be performed concurrently, with a fifth role available for a small group. The server owns accepted steps and the round receipt.

### Player sequence

1. A player approaches either counter or the serving table and taps the large contextual `Help make the spread` action. Desktop uses the same action prompt and an interact key.
2. The player chooses an open role from a compact panel. The panel shows the role, current step, and whether another player is using that individual slot. Leaving the panel does not reserve the whole activity.
3. The player completes one forgiving tap-select sequence:
   - **Rice/base role:** select rice, then select a bowl slot, then confirm.
   - **Fresh toppings role:** select cucumber, carrot, or greens, then select a topping slot, then confirm.
   - **Warm protein role:** select tofu, chicken, or mushroom, then select the warm plate slot, then confirm. This is a fictional ingredient choice, not a restaurant claim.
   - **Sauce/garnish role:** select a sauce or sesame garnish, then select the matching finishing slot, then confirm.
   - **Table host role:** select a plate, napkin, or cup, then tap one of four generous place-setting slots, then confirm.
4. The server validates the action against the current round, role reservation, and unfilled slot. A valid action produces an immediate world change and an action receipt. Repeated requests with the same action identity do not duplicate the ingredient, contribution, or reward.
5. Players may switch roles after committing a step. A player can also cancel an uncommitted selection; accepted prior steps remain.
6. When all required spread slots and at least two place settings are complete, the server creates one Q06 round-completion receipt. Finished bowls/plates and place settings remain visible for the remainder of the birthday session.
7. The shared flower receives the Q06 petal once. The first completed Q06 earning round adds the proposed shared-fund reward of 20; later explicit completed Q06 replays add 10 once. These numeric values are coordinator defaults, not independently user-approved facts, and must be implemented only after PCW-09 establishes the shared reward contract.
8. The activity displays `Spread ready` and a non-blocking suggestion to carry on exploring or gather at the patio when the host later starts the cake finale. Food is not automatically teleported, consumed, or removed during the cake sequence.

### Why this default is recommended

It adapts the old grill/seafood/table-setting intent into a legible street-food assembly with meaningful parallel work and no heat, burn, accuracy, or timing penalties. It also avoids asserting that FOB Poke Bar or Aladdins serve these exact fictional combinations. A later scope decision could instead move the historical KBBQ/seafood sequence outdoors, but that would require extra heat-safety feedback, larger props, and a less coherent relationship to the two nearby storefront landmarks.

## Concurrency, safety, and fairness

- The activity has at least five independent role slots. Ten players may participate safely by sharing the role panel, exploring nearby fair space, or helping with later replay steps; no one is required to stand shoulder-to-shoulder at a counter.
- Each role reserves only one step/slot for that player, with the shared default 15-second inactivity expiry. Disconnect or cancel releases only that reservation.
- A player cannot overwrite an accepted ingredient. If a slot is already filled, the client refreshes and offers another unfilled slot.
- The server accepts at most one transition for each action identity and round identity. Concurrent final taps resolve deterministically; one completion receipt, one petal, and one qualifying fund payment can result.
- Spectators and late joiners see the current spread and can use any open unfilled role. They do not receive a second petal for the already-completed round.
- A player may leave before completion without cancelling accepted work. If everyone leaves, the server retains the live session state according to the shared session contract; a later participant may finish it.
- No ingredient is thrown, dragged precisely, timed, burned, spoiled, or judged for accuracy. The avatar never needs to enter a storefront or block a door.

## Touch, tablet, and desktop controls

Touch uses large buttons and a three-step pattern: **tap ingredient → tap highlighted slot → tap Confirm**. A selected ingredient has an outline, check mark, and text label; selected/completed states do not rely on color alone. The panel has separate `Cancel`, `Back`, and `Close` controls with inset-safe spacing, and never covers the movement thumb, jump button, or camera-drag region.

Desktop uses the same labels, pointer selection, and an optional interact-key shortcut. No hover, right-click, tiny mesh tap, keyboard-only text entry, or simultaneous fingers are required. Camera rotation remains local to each player. The final target size and phone orientation remain device-test decisions; begin testing with roughly 48 screen-space units for touch targets.

## State and interface dependencies

Q06 references the common contract owned by Task 09 rather than defining a wallet or economy. Minimum conceptual records are:

```text
sessionId
activityId = Q06
roundId
actionId
contributorId
roleId / slotId
acceptedStepId
roundCompletionReceipt
onceOnlyPetalReceipt
onceOnlyFundRewardReceipt
visibleFoodState
```

Required server interfaces:

- `BeginOrJoinRound(sessionId, Q06)` returns current round state and available role slots.
- `ReserveStep(roundId, roleId, slotId, contributorId)` reserves one step with inactivity expiry.
- `AcceptStep(roundId, actionId, contributorId, selectedItem, targetSlot)` validates and commits one visible food step.
- `CancelStep(roundId, reservationId)` releases only unfinished work.
- `LeaveOrDisconnect(roundId, contributorId)` releases unfinished reservations while retaining accepted steps.
- `GetRoundState(sessionId, Q06)` restores the current visible spread for late join/reconnect.
- `CompleteRound(roundId)` creates the exactly-once completion, petal, and eligible fund receipts.
- `ReplayQ06(sessionId)` begins a new explicit round after completion without erasing the previous spread or re-paying its petal.

The UI depends on PCW-02 for shared panel conventions and touch safe areas; PCW-03/05 for measured storefront anchors and route clearance; PCW-13/Task 09 for session state, contribution, shared fund and once-only receipts; PCW-14 for cake unlock/host gathering; PCW-16 for mixed-device and 8–10-player rehearsal. Q06 must not own teleport, cake triggering, personal collections, or cross-session persistence.

## Completion, cancellation, replay, and reconnect

- **Partial completion:** accepted steps remain visible. A new player can finish missing roles.
- **Cancel before confirm:** no state or reward changes; return to exploration.
- **Cancel after an accepted step:** prior step remains; only the current reservation is released.
- **Disconnect/reconnect in the same session:** restore the live round, visible ingredients, petal/fund state, and available slots. A reconnect must not restart Q06 or create a second reward.
- **Late join:** show the existing spread and remaining jobs immediately. The joining player is not transported and does not need to repeat completed work.
- **Replay:** after the round is complete, an explicit `Make another spread` action starts a new round. The first round's food may remain as a display; a replay must not award another petal, and its proposed 10-fund reward follows the shared contract only when the replay is explicitly completed.
- **Duplicate or stale requests:** return the current authoritative state and no duplicate visible item, contribution, petal, or fund transaction.
- **Session end/new session:** reset Q06 progress and food state with the rest of the session; no DataStore or cross-session promise is made.

## Food-to-cake handoff

Q06 completion is an earning petal, not cake unlock by itself. The cake becomes available only when the five earning petals plus the Q05 wanted-Labubu petal are complete under the shared progression contract. When the host starts the finale, participants walk from wherever they are to the patio; Q06 food remains a visual accomplishment and optional social talking point. No player is forced to eat the food, sit, warp, or surrender their camera. Cake serving and eating are owned by PCW-14/Task 09, not this activity.

## Acceptance scenarios and expected outcomes

1. **Parallel first clear:** five players occupy rice, toppings, protein, sauce, and table roles. Each accepted step updates the world immediately; the spread completes once; exactly one Q06 petal appears.
2. **Ten-player arrival safety:** ten players approach together. No avatar is required inside a doorway; counters, serving table, and route remain usable; at least one player can leave without trapping others.
3. **Touch forgivingness:** on a representative phone, a player completes ingredient → slot → confirm using large controls. A near-center tap selects the intended option; no drag or precision timing is needed; movement and camera controls remain accessible.
4. **Desktop equivalence:** a desktop player completes the same role with the same action labels and no required touch gesture. Their camera remains independent of other players.
5. **Contention:** two players tap the same final slot. The server accepts one action identity, rejects the stale duplicate with refreshed state, and still issues only one round receipt/petal/fund payment.
6. **Cancel and disconnect:** a player selects an ingredient, cancels, disconnects, or becomes inactive before confirm. The slot reservation releases; accepted work from other players remains; another player completes it.
7. **Late join/reconnect:** a late player or reconnecting player sees the same visible finished food and only the remaining jobs. Q06 does not restart and no reward repeats.
8. **Replay:** after completion, a player explicitly starts and completes a second round. The first food remains visible or is replaced only by the documented replay display rule; no second petal is granted; the later proposed fund receipt is exactly once.
9. **Route preservation:** an independent review verifies that the activity does not occupy FOB/Aladdins doors, crossing stripes, central pedestrian lane, or the cake patio approach. This requires measured Studio evidence and cannot be proven by this document.
10. **Completion-to-cake:** after all required petals are present, the host starts the finale. Players walk to the patio without forced warp; Q06 state remains inspectable and does not claim ownership of cake seating or eating.

## Required ticket, contract, and UI changes before implementation

- Amend PCW-12 title scope from patio cooking to UDistrict food assembly near FOB/Aladdins; replace the 52 × 24 patio constraint with measured Q06 anchors and route-clearance checks.
- Replace the historical KBBQ/seafood deliverable with the approved-at-implementation menu choice. Until a user decision is recorded, use this bowl/plate proposal as a draft, not a fact.
- Preserve PCW-12's parallel-work, lasting-food, forgiving-touch, one-petal, cancel/rejoin, and cooking-to-party intent, translating “cooking” into assembly.
- Update PCW-02 with Q06 panel states, large tap targets, error/refresh behavior, role contention, and replay labels.
- Update PCW-03/05 and Task 01's placement contract with `Q06FOBCounter`, `Q06AladdinsCounter`, `Q06Serving`, door clearances, and measured path/crossing evidence.
- Update PCW-13 and Task 09 with Q06's round/action/receipt examples, shared-fund first-clear/later-replay defaults, and spectator/late-join rules.
- Update PCW-14 to state that Q06 food is a persistent optional display and does not occupy or unlock the cake patio.
- Add verifier contract cases for simultaneous final actions, role reservation expiry, phone and desktop completion, visible persistence, replay once-only receipts, and route obstruction. The verifier must not treat this design draft as Studio or live-play evidence.
- Update PCW-16's rehearsal matrix for 8–10 players around storefront doors, crossing lanes, reconnect, late join, and walking food-to-patio handoff.

## Bounded later implementation checklist

1. Measure the current UDistrict scene and establish the three Q06 anchors without moving the crossing, storefront doors, or patio.
2. Obtain the menu decision or record approval of this fictional bowl/plate proposal; name final ingredients and visual references.
3. Build low-detail counters, serving table, labels, and collision volumes using the approved palette roles.
4. Implement server-owned rounds, reservations, action deduplication, visible food state, completion receipt, and shared progression interfaces.
5. Implement one shared touch/desktop panel and all cancel, replay, late-join, and reconnect states.
6. Test solo, concurrent 5-player, 8-player, and 10-player cases before adding decorative detail.
7. Capture Studio placement, collision, palette, route, and performance evidence; run independent verification.
8. Run real mixed-device/group playtests, revise friction or crowding, then retest. Do not mark this design draft as playable approval.

## Evidence limits and unresolved choices

This draft is a proposal based on the coordination packet, source tickets, map proposal, visual brief, and verification guide. It does not establish that FOB Poke Bar, Aladdins, or the named anchor Instances exist in the current place; it does not measure the current scene; it does not verify door/crossing clearances, mobile performance, Roblox UI behavior, teleport/session recovery, or human enjoyment. The old PCW-12 acceptance text is not evidence of implementation.

Unresolved choices for the coordinator/user or later implementation gate:

- Approve this fictional bowl/plate assembly or choose a revised KBBQ/seafood sequence.
- Decide final ingredient names, visible food models, and whether a completed replay replaces or appends to the display.
- Confirm exact Q06 counter dimensions and the number of simultaneous table-setting slots after measuring the current UDistrict block.
- Confirm whether the proposed later-replay fund amount is retained with the shared progression defaults.
- Choose target phone/tablet devices and final touch target/orientation behavior.

