# Q03 — A Tiny World of Her Own: UDistrict craft booth

Status: implementation-ready design draft; no Roblox implementation or Studio approval.

## Scope and authority

Q03 is one shared, curated miniature assembled by the group at a craft booth beside the UDistrict crossing. Its six parts are a rug, chair, bookcase, side table, plant, and lamp. The bedroom desk is a second access point to the same server-owned miniature, not a second reward or a second copy. The committed miniature remains displayed on Phuong's bedroom desk after completion, cancellation, replay, and rejoin within the running birthday session.

Confirmed direction: the booth is outside the crossing route; the bedroom remains one detailed room; placement is curated rather than a general furniture editor; touch and desktop controls are equivalent; cameras remain independent; Q03 contributes one shared quest petal and does not add a seventh quest. The exact booth transform, desk transform, socket offsets, reward arithmetic, and final art dimensions still require the placement/contract owners to settle and measure in Studio.

Coordinator defaults used here, still proposals: the booth supports ten participants nearby, with 4–6 active placers as a comfortable target; an unfinished socket reservation expires after 15 seconds of inactivity; the first accepted completion round earns the shared birthday fund's proposed first-clear amount, and later explicit replays use the proposed later-round amount. Q03 must call the shared progression contract rather than own a wallet or reward value.

## Proposed geometry and route protection

Use the proposed `Q03FairCraft` anchor on the east side of the UDistrict crossing, outside the crossing stripes and central pedestrian lane. The craft footprint is a compact rectangular pad, proposed at 14 × 10 studs including the working table and interaction margin. Put the table against the far edge of the pad, with a minimum 3-stud approach aisle on the player-facing side and 2-stud side aisles so multiple avatars can reach separate sockets. Keep all booth posts, table corners, part trays, prompts, signs, and avatar collision volumes out of the crossing and its 20-stud east–west route.

The working table is proposed at 8 × 4 studs, waist height, with three usable working sides: front, left, and right. The rear side is reserved for the booth shell/visual backing and is not a required approach. The six visible sockets should be arranged in two rows of three, with at least 1.5 studs between interaction centers and no socket requiring an avatar to stand in the aisle. Part trays sit above or behind the table and are visual only; the selected part appears as a ghost at the candidate socket.

The bedroom desk uses the proposed `Q03BedroomDisplay` anchor. It must show the final miniature without requiring the booth to remain loaded or occupied. If the desk is crowded, the miniature display has priority over optional desk clutter; do not add a second miniature, teleport, or locked room. The implementation must derive offsets from measured current anchors, not copy these proposed numbers directly.

## Parts, sockets, and acceptance rules

Each part has one canonical part ID and one compatible socket:

| Part ID | Display piece | Canonical socket | Accepted orientation |
|---|---|---|---|
| `rug` | small floor rug | `rugSocket` | quarter turns; symmetric visual may make values equivalent |
| `chair` | reading chair | `chairSocket` | quarter turns; front must face the miniature reading area |
| `bookcase` | low/tall bookcase | `bookcaseSocket` | quarter turns; front must face outward |
| `side_table` | side table | `sideTableSocket` | quarter turns; tabletop remains level |
| `plant` | potted plant | `plantSocket` | quarter turns; upright only |
| `lamp` | floor/table lamp | `lampSocket` | quarter turns; upright only |

The server accepts a placement only when the selected part is compatible with the socket, the socket is uncommitted or reserved by that contributor, the orientation is one of the four quarter-turn values, the part pivot is within the socket tolerance, and the placed bounds do not overlap another committed part or leave the curated display bounds. Client previews are advisory; the server recomputes the transform and validates it.

The six sockets together define the miniature's canonical display state. A part cannot be placed in another part's socket, duplicated, or committed twice. A visually similar bedroom desk prop is not a Q03 part and cannot satisfy a socket. The same state is read by the booth and desk display.

## Player sequence and controls

1. A player approaches the booth and activates the contextual `Craft together` action. The UI opens locally; movement and camera rotation remain available unless the player voluntarily focuses the panel.
2. The player selects an uncommitted part from six large buttons. A selected part is highlighted in the tray and a ghost appears at compatible sockets.
3. The player selects a socket. The closest valid candidate is highlighted with a forest outline; an incompatible socket gives a clear ink/brick warning and does not reserve it.
4. The player rotates the ghost with quarter-turn controls: `Rotate left` and `Rotate right` buttons, each changing orientation by 90 degrees. Desktop also supports Q/E as equivalent optional shortcuts; touch must not depend on a keyboard.
5. The player presses `Place`/`Confirm`. The server validates the action and returns accepted, rejected, or stale-reservation feedback. Accepted placement becomes committed immediately for everyone.
6. Other players may fill other sockets concurrently. A socket shows `Available`, `Reserved by <display name>`, or `Placed`; only the reservation owner may edit an unfinished candidate.
7. Once all six parts are committed, the server creates one Q03 completion receipt and requests the shared progression service to award the once-only Q03 petal and qualifying fund reward. Repeated confirmations cannot create another receipt.
8. Phuong, or the host fallback defined by the shared progression contract when Phuong is temporarily absent, chooses the final lamp light/arrangement presentation from the curated options. This is a final presentation choice, not a new part or extra reward. Everyone sees the selected final display.
9. Players can choose `Preview at home` to view the committed miniature at the bedroom desk. Preview does not move or reset the booth object and does not pay a reward. The group may replay explicitly after completion to try the curated arrangement choice or practice, while the original committed home display remains intact unless the shared contract explicitly permits a later final presentation update.

Touch targets should start at approximately 48 screen-space units, with `Place`, `Cancel`, and rotation controls separated from the movement thumb area and camera-drag area. Desktop uses mouse/touch-equivalent buttons and optional Q/E shortcuts. No camera is changed for another player; no forced warp or cinematic is used.

## Concurrent reservations and lifecycle

The server owns session, activity-round, action, contributor, socket, and committed-part state. A reservation records `sessionId`, `roundId`, `socketId`, `partId`, `ownerUserId`, `reservationId`, candidate orientation, last activity time, and status. All client actions carry a unique action ID for deduplication.

- Reserving a free socket succeeds once. A competing request receives `socket-busy` and leaves the first reservation unchanged.
- A reservation owner may rotate, replace the candidate, or cancel before commit. Rotation refreshes activity but never changes another player's socket.
- `Cancel` releases the reservation and removes only that player's ghost. It never removes committed parts.
- Fifteen seconds without a valid interaction releases an unfinished reservation. The UI warns before release when practical; the server timeout is authoritative.
- Disconnect, leaving the session, teleport failure, or explicit close releases unfinished reservations. Committed parts and the completion receipt remain.
- Rejoin to the same running birthday session restores committed parts, Q03 petal status, and the final home display. It does not restore an expired reservation or reopen an old candidate.
- A late joiner sees the current miniature, socket statuses, and round state, and can fill remaining sockets or preview at home. A restarted/different session starts a fresh miniature.
- If the player cancels after a part was accepted, the accepted part stays committed; the UI must distinguish `Cancel editing` from any proposed future `Remove committed part` action. No removal action is required for the first implementation.

The Q03 round must use the common contract's accepted-step and round-completion receipt. It must not award directly, multiply a reward by player count, or treat a spectator viewing the display as a contributor. A contributor can be acknowledged once per accepted step; the shared service decides whether that affects the proposed first/later fund reward.

## Phuong/host final choice

After all six parts are committed, present Phuong with a small, skippable final panel containing the curated lamp state and arrangement choice. The choice changes only the shared display presentation, such as lamp-on/lamp-off warmth or one of two authored rotations, and must be validated against an allow-list. Phuong's selection is stored on the session's miniature record and replicated to booth/home viewers. If Phuong is absent or temporarily disconnected, use the host fallback and show that the choice is provisional or host-selected according to PCW-13/14's final permission model. Ordinary guests cannot spend shared funds, alter a fulfilled petal, or silently replace the committed miniature.

## Safety and usability for ten participants

The booth must remain usable with ten avatars present: collision-free approach lanes, no required single-file queue, socket labels readable at player height, and no interaction prompt hidden behind another avatar. Active placement is distributed across six sockets; only the relevant owner sees a full edit overlay, while others see the shared state and can contribute elsewhere. If the pad becomes visually crowded, prompts remain accessible through a nearby interaction fallback or socket selection list. The crossing remains walkable and readable from both approaches.

The bedroom desk is a display/preview station, not a second high-capacity assembly surface. Four to six active bedroom interactors are the target; the booth remains the preferred group location. Camera obstruction must be tested indoors and at the street corner on low graphics and touch devices.

## Acceptance scenarios

1. **Shared identity:** Player A commits the rug at the booth; Player B opens the bedroom desk. Expected: both see the same rug and five empty sockets; no duplicate reward or separate miniature exists.
2. **Concurrent sockets:** Six players reserve six different sockets and confirm valid pieces. Expected: all six accepted steps persist, the miniature completes once, and exactly one Q03 petal/round receipt is emitted.
3. **Conflict:** Players A and B request the same empty socket at nearly the same time. Expected: one server-ordered reservation succeeds; the other receives a readable busy result and can select another socket.
4. **Orientation:** A rotates the chair through 0/90/180/270 degrees and confirms an allowed orientation. Expected: the server stores the selected quarter turn; an invalid arbitrary angle is rejected or quantized by server policy, never trusted from the client.
5. **Incorrect part/socket:** A selects the plant and targets `chairSocket`. Expected: preview is marked invalid, no reservation or committed state is created, and the player can recover without leaving the panel.
6. **Cancel and timeout:** A reserves a socket, cancels; B reserves it. Separately, C stops interacting for 15 seconds. Expected: cancel and timeout release only unfinished reservations; committed parts remain untouched.
7. **Disconnect/rejoin:** A commits a part, then disconnects during another reservation and rejoins the same session. Expected: the committed part is present, the unfinished reservation is released, and A can continue without restarting Q03.
8. **Completion and replay:** The sixth part is confirmed twice due to duplicate client requests. Expected: one completion receipt, one Q03 petal, one qualifying fund reward; replay/preview never pays again or erases the home display.
9. **Ten-player safety:** Ten avatars gather around the booth. Expected: the crossing remains traversable, all six socket states are inspectable, and at least one player can approach each working side without forced camera changes.
10. **Touch/desktop parity:** One touch player and one desktop player each complete a valid placement. Expected: both can select, rotate, cancel, confirm, and read feedback with equivalent results and no controls over the camera orbit/movement zones.
11. **Final choice:** Phuong chooses an allowed lamp presentation; a guest attempts an unlisted state or fund action. Expected: Phuong's valid choice replicates; the guest request is rejected and the shared fund/petal is unchanged.

## Interfaces and dependencies

Required proposed anchors: `Q03FairCraft` and `Q03BedroomDisplay`. Required shared interfaces: session identity; activity/round identity; unique action IDs; contributor identity; accepted-step receipt; round-completion receipt; once-only Q03 petal; once-only shared-fund reward; reconnect/session lookup; host/Phuong permission resolution. Task 09 owns the field and transaction semantics. Task 01 owns measured placement, footprint, approach clearance, and route/sightline validation. PCW-02 owns common UI style and controls; PCW-04 owns the desk/bedroom scene; PCW-05 owns street/fair crossing geometry; PCW-13/14 own progression and cake implications.

## Required ticket, contract, and UI updates

- Amend PCW-09 to include all six named parts, quarter-turn validation, socket reservation/commit lifecycle, booth/home shared state, final Phuong/host presentation choice, and the acceptance scenarios above.
- Amend PCW-02 with the six-part tray, socket-status legend, 90-degree rotation controls, invalid/busy/stale/timeout messages, `Cancel editing` versus committed state, and touch-safe placement of controls.
- Amend PCW-04 and PCW-05 to name `Q03BedroomDisplay` and `Q03FairCraft`, preserve one miniature, and keep the crossing and bedroom routes clear.
- Amend PCW-13 and the Q03 verifier contract so Q03 uses shared fund/once-only receipts, session-only rejoin behavior, no personal wallets, and no reward multiplication.
- Add automated contract cases for duplicate action IDs, concurrent reservation ordering, timeout/disconnect release, six-part completion, replay no-pay, late join, and desk/booth state equivalence. Add Studio evidence for collision, pivots, palette tokens, scale, low-graphics sightlines, and 8–10-player behavior.

## Bounded later implementation checklist

1. Task 01 measures and publishes the two anchors, booth footprint, crossing clearance, and desk display offsets.
2. Task 09 freezes shared field/receipt semantics and the proposed reward amounts or records an explicit alternative.
3. Build one server-owned Q03 state machine and one replicated miniature model; expose booth and desk as views of it.
4. Add six curated assets with approved palette tokens and collision/pivot metadata; do not add a general editor or seventh part.
5. Implement reservation, validation, timeout, disconnect, deduplication, completion, replay, and same-session rejoin tests.
6. Implement shared touch/desktop UI and accessibility/readability states, then test with independent cameras.
7. Test the booth with ten avatars and the bedroom display with 4–6 active interactors; capture route, crossing, and camera evidence.
8. Run the independent build → verify → playtest → revise → retest workflow. A document or harness pass cannot substitute for real Studio import, device, group, and human-fun evidence.

## Unresolved choices and evidence limits

- Exact booth transform, socket coordinates, display bounds, collision margins, and desk placement are not measured here and must come from Task 01/current Studio anchors.
- The final presentation choice's exact visual variants and whether a later replay may update that presentation without removing parts remain open with the shared progression/host policy.
- The coordinator's first-clear/later-round fund values are proposed defaults, not separately user-approved facts; Q03 must not hard-code them.
- The final host fallback when Phuong is absent needs one authoritative PCW-13/14 decision.
- This draft does not prove that the current Roblox scene contains the proposed anchors, imported assets, functioning replication, touch controls, route clearance, ten-player performance, or valid Studio palette/collision evidence. Those require later implementation and independent review; `READY_FOR_REVIEW` will not equal final approval.
