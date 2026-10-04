# Q01 — Everything Tucked In

Design draft for the bedroom bed activity. This is an implementation plan, not a playable build or approval. It follows PCW-07, the current PCW-04 bedroom scope, the shared birthday-wave decisions, and the shared activity contract owned by draft 09.

## Scope and assumptions

Confirmed scope: Q01 stays at Phuong's bed, begins after the group arrives in the existing bedroom, has seven preparation actions plus one finishing action, awards one shared flower petal once, and has no chore timer, forced cinematic, exact drag requirement, or personal wallet. The finished bed remains visible during later replay previews.

The following are concrete proposals for implementation, not separately approved facts: the action order may be flexible; a completed preparation step is server-owned and persistent for the current birthday session; a contributor reserves one local slot for 15 seconds or until cancellation/disconnect; and the first accepted Q01 completion adds the common proposed first-clear reward of 20 to the shared birthday fund, with later explicit completed rounds adding 10 once. Draft 09 must confirm the final receipt and reward fields.

The bed, headboard, surrounding floor, and approach clearances must be measured from the current Studio bedroom rather than copied from historical map dimensions. Required proposed anchor is `Q01Bed`, with seven preparation sockets around the accessible sides and one Phuong finishing position. The bed remains a bedroom prop when the activity is inactive; no extra room or NPC is added.

## Player-facing sequence

Arrival shows the normal independent third-person camera in the bedroom. A short optional contextual action, such as “Wake up gently,” may provide a small local animation or text cue about the bed activity. It is skippable, never locks the camera, and does not reset the bed or require Phuong to be present. Players can immediately approach the bed and select “Help tuck in.”

The round opens with a readable panel: “Everything Tucked In,” a 0/7 preparation count, the six-petal progress indicator, and “Phuong finishes the bed.” The seven actions are unambiguous:

1. Smooth the left blanket.
2. Smooth the right blanket.
3. Fold the foot blanket.
4. Place the left pillow.
5. Place the right pillow.
6. Tuck in the round-bellied dog plush.
7. Tuck in the head-sized dinosaur plush.

The final action is not another guest task: Phuong chooses the finishing style from two or more approved options, proposed as “soft and snug” or “neatly layered,” then confirms “Finish the bed.” The choice changes a visible final blanket fold/trim or small approved bedside detail while preserving the recognizable sage bedding and both plushies. If Phuong is absent, the round may reach 7/7 and remain “Ready for Phuong”; it must not auto-finish, consume a petal, or block other activities. A host fallback or explicitly agreed host permission is required if the design wants someone else to finish; do not silently grant it.

Each preparation action is a contextual interaction with generous slot highlighting. Touch selects the highlighted action and then the large “Place”/“Tuck” confirmation; desktop uses the same labels with an interaction key and click confirmation. A player may walk away or press Cancel before confirmation. A wrong object, wrong socket, duplicate step, or stale prompt gives a forgiving message (“That spot is already handled—choose another bed task”) and leaves all accepted progress unchanged. There is no punishment, animation lock, or progress loss.

## State and action contract

The server owns `sessionId`, `activityId = Q01`, `roundId`, `actionId`, contributor identity, accepted step IDs, reservations, final-choice status, completion receipt, once-only petal receipt, and once-only shared-fund receipt. Clients request actions; they do not award progress locally.

Suggested step IDs are `blanket_left`, `blanket_right`, `blanket_foot`, `pillow_left`, `pillow_right`, `plush_dog`, and `plush_dinosaur`. A request includes the round, step, intended socket, and client action ID. The server accepts only an available step in the current session, atomically commits it, records the contributor, releases that contributor's reservation, and returns the accepted-step result. Repeated action IDs or retries return the original result without duplicate credit. A reservation is local to one step, never the whole bed, and expires after the proposed 15 seconds of inactivity. A player disconnecting or cancelling releases only their unfinished reservation.

State progression is `Inactive → Open → InProgress → ReadyForPhuong → Finished`. `Open` can be entered by any participant. `InProgress` exposes the seven steps concurrently. Accepted steps survive a contributor leaving. `ReadyForPhuong` is entered at 7/7 and waits for Phuong's valid finishing choice. `Finished` stores the visible final bed and one round-completion receipt. A replay preview can show the finished bed and contribution acknowledgements without undoing it. An explicit replay starts a new eligible round only after the previous round is complete; it must not erase the finished appearance or pay the petal twice.

On successful finish, the server emits a round-completion receipt, then exactly once emits the Q01 petal receipt and the shared birthday-fund receipt according to draft 09. The petal is shared, not multiplied by contributors. The receipt must be safe to replay after reconnect. Personal currency, gifting, and private wallets are not part of this activity.

## Cooperative use and safety

All seven preparation steps are independently reservable, so two to seven friends can help simultaneously without waiting for one lead player. Ten arrivals can occupy the bedroom safely if the arrival/placement plan supplies ten non-overlapping arrival points away from the bed and Jasper. The Q01 bed interaction should target four to six active positions initially; extra guests can inspect the progress, use another activity, or watch the bed preview. No guest is required to repeat a step, and completion does not require eight or ten people to remain online.

If two players request the same step, the server accepts the first valid request and the other receives the forgiving already-handled response. If two requests race across different steps, both may succeed. If a contributor leaves, the accepted step stays accepted and only their uncommitted reservation is released. If Phuong disconnects at `ReadyForPhuong`, the state remains ready; reconnecting to the same session restores it. A new session starts fresh. Late joiners see the current accepted count and visible finished bed rather than a reset bedroom.

The bed must never reserve an entire walkable room, force a warp, disable camera rotation, or require a player to stand on another player's avatar. Completed plushies remain round-bellied and head-sized in normal and replay views; no stacking or hidden replacement is acceptable.

## Interface and dependency requirements

Q01 depends on the PCW-04 bedroom shell and measured `Q01Bed` anchor, PCW-02 interaction/UI rules, PCW-13/shared progression semantics, PCW-14 cake unlock reading the six-petal state, and the shared activity receipt contract from draft 09. It also consumes the group arrival/session identity from draft 08. Draft 01's arrival clearance must reserve the bed approach and prevent the ten arrival points from overlapping the bed sockets.

The UI must show the activity name, 0–7/7 preparation count, per-step labels, local reservation/availability state, Cancel, Phuong-only finishing choice when applicable, and a non-color-only completion cue with label and check. Touch targets should follow the visual brief's roughly 48 screen-space-unit initial target, with camera-drag space kept clear. Desktop shows key/click hints but the same actions and labels. Tablet may use the wider panel; no touch joystick is shown on desktop. There is no countdown or pressure banner.

## Acceptance scenarios

1. A solo player completes all seven preparation actions in any supported order, cancels once, then resumes. Expected: accepted progress survives cancellation; the player can finish the remaining actions; no timer or reset occurs.
2. Two players select different blanket/pillow tasks simultaneously. Expected: both commits succeed, each contributor is recorded once, and the count increments by two.
3. Two players race for one pillow socket. Expected: exactly one accepted step; the other receives an understandable already-handled response and can select another task.
4. A player disconnects after accepting the dinosaur but before the round finishes. Expected: dinosaur remains visibly tucked; the player's unfinished reservation, if any, releases; another player can continue.
5. A non-Phuong player reaches 7/7. Expected: state is ReadyForPhuong, no petal or fund reward is issued, and the player sees that Phuong must choose the finish.
6. Phuong chooses each finishing option in separate test rounds. Expected: the selected approved final presentation is visible, the round completes once, and the chosen result is preserved in replay preview.
7. Completion is retried after a timeout/reconnect. Expected: the same round/petal/fund receipts are returned; no duplicate petal or shared-fund payment occurs.
8. A late joiner enters after completion. Expected: they see the finished bed and replay/preview state, not seven empty tasks or a reset bedroom.
9. Ten players arrive nearby and four to six interact. Expected: no bed pile-up, camera remains rotatable for each player, actions remain readable on touch and desktop, and non-participants can leave without blocking completion.
10. Three explicit replay rounds are completed after the first. Expected: the finished appearance remains visible between rounds; each eligible round has one completion receipt and the later shared-fund reward follows the common rule; the shared petal remains one.

## Required ticket/contract updates

Before implementation, update PCW-07 to name the seven step IDs, Phuong-only finishing gate, visible replay behavior, concurrent reservations, reconnect semantics, and exact once-only receipt dependencies. Update PCW-04 to expose a measured bed anchor, socket footprint/clearance evidence, and low-graphics plush readability. Update PCW-02 with Q01's seven-step panel, forgiving invalid response, touch target, and desktop equivalent. Update PCW-13 and the shared contract to replace any personal-wallet wording with the shared birthday fund and to define Q01's first/later reward receipt. Update PCW-14 to consume the once-only Q01 petal rather than infer it from money. Update the PCW-07 verifier contract when the implementation paths and real tests exist; include concurrency, cancellation, reconnect, late join, replay, device, and receipt checks.

## Bounded later implementation checklist

1. Measure the current Studio bed, approach, headboard, and usable side clearances; record the anchor and ten arrival-safe offsets.
2. Author only the seven step sockets, bed state visuals, dog/dinosaur placement, and approved finishing variants using the exact palette roles from `verification/palette.json`.
3. Implement server-owned round/action/reservation/receipt handling against the shared contract; keep UI and camera client-side.
4. Add touch, tablet, and desktop interaction states with Cancel and forgiving invalid responses.
5. Test solo, two-player race, 8–10-player arrival safety, disconnect/rejoin, late join, Phuong absence, replay, and duplicate-request behavior in Studio.
6. Capture independent build evidence, run the PCW-07 verifier, then obtain separate device/group playtest and human fun review. A document or harness pass cannot establish Roblox readiness or final acceptance.

## Open choices and evidence limits

The number and wording of final finishing choices, whether the finishing change is a fold style or another small approved bed detail, the exact reservation timeout, the host fallback while Phuong is absent, and the precise shared-fund receipt schema remain dependent on the coordinator's contract decisions. The current bedroom anchor, dimensions, socket positions, arrival offsets, plush meshes, collision, and mobile performance have not been measured or Studio-tested in this draft. No claim is made here that the bed activity is implemented, imported, playable, or production-ready.
