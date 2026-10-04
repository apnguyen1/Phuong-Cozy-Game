# Birthday draft coordination - September 27, 2026

Status: user-approved direction; MVP implementation is authorized in scoped local sources and reversible local Studio work. Publishing/uploading remain out of scope; implementation and verification evidence are still separate gates.
Coordinator chat: 01a0e477-0493-74e0-b4c7-61ef81c56eb3.
All new work chats and explicitly delegated workers: GPT-5.6 Luna, Low reasoning (user's latest selection).
Source checkpoint at setup: c89ba7f (Draft 03 garden detail and environment polish); recheck current files rather than assuming installed/saved state.

## Authority and limits

The user's September 27 consultation below supersedes conflicting historical planning text only for these changes. Read AGENTS.md, docs/tickets/README.md, docs/design/map-proposal-v0.2.md, docs/design/visual-direction-v0.1.md, docs/design/mini-game-idea-plan.md, your associated tickets, and verification/README.md. Earlier map dimensions are proposals, not measured coordinates in the translated current scene.
This coordination packet is an explicit amendment reference. The original mini-game plan and PCW-11/PCW-17 still describe superseded behavior; do not silently follow them. Each draft must list exact downstream ticket, contract, UI and test updates needed before implementation. Preserve useful existing criteria.
Historical initial scope was draft creation. The subsequent user goal authorized implementing all13 tasks, local Studio copies/tests, and then integration into the primary place. The latest instruction is to apply feature changes one by one and save after every merge. Follow [the current integration handoff](implementation/current-install-handoff.md); do not treat historical no-code or pending broad-installer approval notes as a new veto. Publishing/uploading remain excluded. No personal birthday-note prose or invented guest wishes.
You are not alone in the repository. Change only your currently assigned files and responsibility. Do not revert others' changes or change the Git branch. Implementation and ticket/contract alignment are authorized within the assigned task; shared-scene mutations require the coordinator's exclusive Studio lease.

## Confirmed user decisions

1. Keep the birthday waiting lobby. No personal countdown on player arrival.
2. One join square. First entrant starts one shared 60-second queue. Others can enter/leave. Empty square resets. Only queued players transfer together.
3. At eight queued players, shorten the remaining countdown to at most 10 seconds. Capacity is 10; the world supports up to 10 simultaneously.
4. The queue leads to a group gameplay server, whose arrival is inside Phuong's existing detailed bedroom. The opening evokes Phuong waking up at night. Jasper starts there too. Keep independent third-person cameras; no mandatory cinematic.
5. Q01 Everything Tucked In stays at her bed.
6. Q02 Jasper's Favorite Things starts with Jasper in the bedroom. His existing outdoor fetch area remains available.
7. Q03 A Tiny World of Her Own: primary group craft booth beside the UDistrict crossing. The bedroom desk displays/contributes to the same miniature.
8. Q04 One More Chapter: benches beneath the existing Quad blossoms. Keep the Quad itself as it is; additional trees may surround its outside edges, without changing interior trees/path geometry.
9. Q05 A Labubu Wish: vending machine on the UDistrict side, outside the crossing and pedestrian route.
10. Q06 Something Delicious moves to UDistrict near FOB Poke Bar and Aladdins. The birthday patio is for the cake finale and dedicated group seating.
11. Surround the existing play area with Seattle-inspired building facades/backdrops to conceal unfinished map edges while retaining a nice open view of the night sky.
12. Cozy nighttime lighting, grass texture/material improvements and modest decoration are separate tasks. Preserve the exact world palette and scoped existing exceptions; do not assume a new texture exception.
13. One shared birthday fund everyone works toward replaces personal coin wallets. Prioritize helping Phuong obtain her wanted Labubu, then gather for cutting and eating cake.
14. Six shared quest petals remain. Aim for eight real friends with capacity for ten. Do not require all eight/ten to stay online to complete activities or cake.
15. Models: GPT-5.6 Luna with Low reasoning. Workers must receive precise context and ownership.

## Coordinator design defaults to make drafts concrete

These are proposed implementation details, not additional user-approved decisions. Label them as such and improve only within the confirmed direction; surface meaningful alternatives.
- Queue uses one server-owned deadline. At count >=8, deadline becomes min(current deadline, now + 10s). Joining never extends it; dropping below eight does not extend it; empty reset starts a new queue generation. No instant launch at ten. Capacity eleven is rejected gracefully. Queue count and remaining time are visible and touch-readable.
- At expiry freeze a roster and transfer that party to one reserved gameplay server; retain/retry failed members against the same destination. Specify cancellation, disconnect, partial failure, duplicate attempts and late-arrival handling. No unrelated lobby player is transported. Gameplay arrival/rejoin must not restart the lobby timer or reset a live session.
- Roblox published-session teleport verification is separate from Studio simulation. No destination IDs are known: use explicit configuration requirements, never fabricated IDs or claims of live testing.
- Ten unique safe bedroom arrival spots; no pile-up on the bed/Jasper/door. The bedroom stays one room, with free exits and 4-6 active interaction positions as a starting target. Read actual current anchors and derive local offsets; do not reapply old map coordinates directly.
- Waking is a brief optional contextual interaction or animation, not forced sleep, a morning/daytime reset, or a shared camera lock.
- Jasper's bedroom interaction is the Q02 quest start; the yard is the same quest's continuation/fetch station. Jasper moves/leads there; don't squeeze a fetch lane into the bedroom. Define a solo-friendly fallback and rejoin route if navigation stalls.
- Food venue placement is confirmed; exact revised recipe/menu is not. Draft a clear food-counter plan near the two existing storefronts, flag any FOB bowl/Aladdins plate adaptation as a proposal, and explain differences from the earlier KBBQ/seafood activity. Do not assert researched real menus.
- Shared fund starts at 0; first completed earning round per Q01/Q02/Q03/Q04/Q06 adds 20 once to the shared fund; later explicit completed rounds add 10 once. It is not per-player multiplication. Five first completions yield 100, enough for five 20-coin rolls. Contribution acknowledgements are personal, currency is shared. Do not force repeated grinding or require eight unique contributors.
- Q04 has one server-owned shared reward round too: independent bookmarks can contribute; simultaneous saves cannot accidentally pay multiple rewards. Reopening/resaving never pays. Explicit replay starts the next eligible round; do not erase other readers' partial work.
- Phuong selects the wanted figure and controls spending from the fund. Explicit host fallback handles temporary absence; ordinary guests cannot drain it. Everyone can inspect the goal, fund, figure display and skippable reveal. Q05 spends the fund and contributes its wanted-figure petal; vending, collection awards and gifts never earn fund currency.
- Keep the earlier chosen Big into Energy figures and custom probabilities: six regular figures each 16.5%, secret ID 1%, selected figure guaranteed on the fifth unsuccessful-sequence roll, including selected ID. Wanted choice locks until fulfilled. Preserve award-before-animation and exactly-once debit/award. New wanted choice after fulfillment resets its own counter.
- For simplicity, proposed birthday purchases award directly into Phuong's session collection; no personal wallet, coin transfer or gifting transaction is necessary for the core quest. Explicitly mark retiring personal gifting/collections as a simplification proposal, not a user decision about all optional collection features. Smiskis are not a required new quest or separate economy in this wave.
- Fund, petals, purchases, wish counter and accepted steps last only for the running birthday session; rejoining that session restores them. Different/restarted sessions start fresh. No cross-session datastore promise.
- Cake unlocks after the five earning petals plus Q05 wanted-Labubu petal. Money alone does not unlock it. Host invites/starts when ready; participants walk to the patio. Phuong cuts cake; seated guests can eat via forgiving actions. No required guest count, forced camera or auto-warp. Activities remain available afterward.

## Shared handoff contract for drafts

Use Q01-Q06 as stable identities. Describe actions/results using a small common contract: session identity; activity/round identity; action identity for deduplication; contributor identity; accepted step; round completion receipt; once-only petal; once-only fund reward. Task 09 owns proposed field/state semantics. Activity authors reference it rather than designing independent wallets.
Task 01 owns placement anchor names and footprint proposals. Activity authors declare required stations, queues and approach clearance; no worker owns changes to the entire map.
Suggested anchor keys: GameplayBedroomArrival, Q01Bed, JasperBedroomStart, JasperFetchYard, Q03FairCraft, Q03BedroomDisplay, Q04QuadReading, Q04BedroomKindle, Q05UDistrictVending, Q06FOBCounter, Q06AladdinsCounter, Q06Serving, FinalePatio, BirthdayLobbyQueue. Names are proposed contracts, not claims that those Instances currently exist.

## Task ownership and deliverables

| ID | Chat / scope | Sole owned draft | Associated source tickets |
|---|---|---|---|
| 01 | Placement and bedroom arrival plan | 01-placement.md | PCW-03/04/05/06, MAP-02/03 |
| 02 | Q01 Everything Tucked In | 02-q01-bedroom.md | PCW-07 |
| 03 | Q02 Jasper indoors and fetch outside | 03-q02-jasper.md | PCW-08 |
| 04 | Q03 UDistrict craft booth | 04-q03-craft.md | PCW-09 |
| 05 | Q04 Reading beneath Quad blossoms | 05-q04-reading.md | PCW-10 |
| 06 | Q05 Labubu vending machine | 06-q05-labubu.md | PCW-11 |
| 07 | Q06 UDistrict food activity | 07-q06-food.md | PCW-12 |
| 08 | Birthday queue and party transfer | 08-lobby-queue.md | PCW-17 |
| 09 | Shared birthday fund through cake | 09-progression-cake.md | PCW-02/13/14 |
| 10 | Seattle perimeter and skyline | 10-seattle-boundary.md | PCW-03, MAP-02/03 |
| 11 | Cozy nighttime lighting | 11-night-lighting.md | PCW-01/02, MAP-02/03 |
| 12 | Grass, decoration and outer Quad trees | 12-grass-decoration.md | PCW-06, MAP-03 |
| 13 | Independent draft review and rehearsal plan | 13-independent-review.md | PCW-16, verifier brief |

Every builder draft (01-12) must include: confirmed scope versus defaults/open choices; exact player sequence; station positions/footprints or measured-source requirements; useful simultaneous roles; touch/desktop interaction; state and permissions; cancellation/replay/rejoin; interface dependencies; precise acceptance scenarios with expected results; downstream source/ticket/contract changes; bounded implementation steps and explicit evidence still needed. Label measured observations, proposals and untested behavior separately. Use existing photos/approved sources only as references; no production-ready art claims.
For 10-12, replace activity mechanics with clear geometry/material/light ownership, mobile budget proposals, preservation rules, sightline/route checks and before/after evidence.
All figures and final assets still need exact reference/approved palette and Studio verification. World palette: forest #365744; sage #A8B995; cream #F5F0E4; wood #95674B; blossom #E8B7C6; brick #B66C68; golden #E8C779; ink #26382E.

## Coordination and sequence

All chats can draft concurrently into distinct files using this packet. If 01 or 09 is not yet available, state an explicit dependency and use the defaults here; do not block or invent measured data.
The independent brief review found no blocking conflict with the user's direction. Required alignment items: rename PCW-11's active title to A Labubu Wish in a later ticket revision while keeping Q05/PCW-11 identities; move Q06's map/counter contract from the patio to UDistrict; include player-facing transfer-failure recovery and stale/duplicate callback handling in PCW-17's replacement plan.
Implementation sequence for later: settle contracts and anchor plan (01/09), queue/arrival foundation (08), activities (02-07), bounded environment passes (10-12), integrated review/rehearsal (13). Only one designated integrator may mutate a shared Studio scene at a time.
Builders report documents and remaining decisions, never self-approve. Independent reviewer checks consistency and plans real later Studio/device/group evidence. A documentation review cannot certify a playable game.

