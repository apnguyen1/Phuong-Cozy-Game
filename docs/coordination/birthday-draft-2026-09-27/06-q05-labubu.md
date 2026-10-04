# Q05 — A Labubu Wish: shared-fund vending design

Status: implementation-ready design draft; no gameplay, Studio, asset, or publishing work is authorized by this document.

## Scope and authority

Q05 keeps the stable identity of PCW-11 while replacing its historical six-hidden-find / three-required treasure hunt with a UDistrict vending-machine activity. The machine sits outside the UDistrict crossing and pedestrian route, using the proposed `Q05UDistrictVending` anchor. The machine is a shared-world display, but its browsing and inspection UI is per player. It must not obstruct the crossing, pedestrian route, or independent third-person cameras.

The September 27 coordination packet confirms the shared birthday fund, the Big into Energy seven-figure set, session-only progress, and Phuong-priority completion. The numeric fund rates, exact machine footprint, interface dimensions, and exact figure visual palette remain proposed implementation defaults until the relevant shared contracts and art review settle them. This draft does not invent asset IDs, real-money purchases, Roblox place IDs, or production-ready figure art.

The proposed simplification is direct award to Phuong's session collection. It retires personal wallets, player-to-player coin transfers, personal collection ownership as the Q05 core, and the old gifting flow for this wave. That is a design proposal requiring PCW-02, PCW-13, PCW-15 and verifier-contract updates; it is not a claim that every optional future collection feature is permanently forbidden.

## Player experience

1. A player approaches the machine and taps/clicks **Inspect**. The panel shows the seven figures, wanted selection, shared-fund balance, roll price, guarantee progress, and the Q05 petal state. Friends can inspect concurrently.
2. Phuong selects one wanted figure and confirms **Lock wanted figure**. The server records the selection and locks it until fulfillment. The proposed host fallback may perform this action only when Phuong is temporarily absent and the session host explicitly accepts the responsibility. Ordinary guests cannot choose a different target or spend the fund.
3. Phuong or the explicit host opens the purchase confirmation and requests one roll. The panel clearly says that the purchase uses 20 shared-fund units and that the result goes to Phuong's session collection.
4. The server validates session identity, permission, wanted state, balance, and an unconsumed action identity. It atomically debits 20 and awards exactly one result before any reveal animation begins.
5. The result is shown in a short, skippable reveal. Closing, skipping, leaving the machine, or disconnecting cannot remove an already awarded figure. Everyone nearby may inspect the public result display, while the authoritative collection and guarantee state remain server-owned.
6. If the awarded result is the locked wanted figure, the server fulfills Q05 exactly once and awards the sixth flower petal exactly once. A duplicate result does not add another petal. If it is not the wanted figure, the unsuccessful-roll counter advances and the machine remains available.
7. After fulfillment, the machine remains browsable. A new wanted selection may start a new counter for continued session collecting, but it cannot award another Q05 petal. There is no required grind, shelf placement, gifting step, or cake block after the first fulfilled wish.

## Figure set and probability contract

The seven selectable identities are the six Big into Energy regular figures—Love, Happiness, Loyalty, Serenity, Hope, and Luck—and the secret figure ID. Each regular outcome has a proposed weight of 16.5%; ID has 1%. These sum to 100% for ordinary rolls. The exact identity keys are logical names only; implementation must obtain approved content identifiers later rather than inventing IDs.

The wanted guarantee applies to any selected figure, including ID. Before the fifth roll, an ordinary roll may produce the wanted figure and immediately fulfill the wish. If four consecutive rolls for the locked wanted figure are unsuccessful, the fifth roll must award that wanted figure regardless of its ordinary weight. The counter resets only when the wanted figure is fulfilled and a new target is explicitly selected. A wanted choice that is already fulfilled must not reopen Q05's petal.

## State, permissions, and transaction interfaces

The server owns `BirthdaySessionId`, `Q05ActivityState`, `WantedFigureId`, `UnsuccessfulRollCount`, `SharedFundBalance`, `Q05PetalReceipt`, `RollActionId`, `RollTransactionReceipt`, and the session collection awarded to Phuong. Use the common session/activity/action/contributor/accepted-step/round-receipt/once-only-reward contract owned by Task 09; the names here are proposed fields, not a competing schema.

Required logical actions are `InspectQ05`, `SelectWanted`, `ConfirmWanted`, `RequestRoll`, `SkipReveal`, `RejoinQ05`, and `ReplayQ05`. Inspection is read-only and available to every participant. Selection and spending require Phuong or the explicitly accepted host fallback. `RequestRoll` must be rejected if the session is absent, the actor lacks permission, no target is locked, the balance is below 20, a prior action is already committed, or the session has ended.

`RequestRoll` must be one server transaction: validate the current state; reserve/consume the action identity; determine the regular or guaranteed result; debit exactly 20; award exactly one figure to Phuong; update the guarantee counter; write a receipt; then publish the reveal. On retry with the same action identity, return the existing receipt without another debit or award. A client timeout must not cause a second roll. No debit is valid without a corresponding award receipt.

The proposed shared-fund defaults are: start at 0; the first accepted completion of each earning activity contributes 20 once; later explicit completed rounds contribute 10 once; contributions are shared rather than multiplied by player count. Q05 itself never adds fund units. The shared fund is session-only and is not Robux, a personal wallet, a tradeable balance, or a datastore promise. Rejoining the same running session restores its authoritative state; a new or restarted session starts fresh.

## Concurrency, cancellation, and recovery

- Multiple friends may browse and inspect without cabinet reservation. A player opening a panel never blocks another player from opening theirs.
- Two simultaneous roll requests are serialized by the server. At most one can consume a given current fund balance/action state. A losing request receives a clear busy or stale-state response and may refresh; it must not debit.
- If Phuong leaves while the panel is open but before commit, the uncommitted request is canceled. If she disconnects after commit, the award and receipt remain. The explicit host fallback may continue only after the server has recognized the temporary absence and the host has opted in; an ordinary guest cannot silently inherit spend rights.
- If a client disconnects during the reveal, the server receipt remains authoritative. Rejoin shows the awarded figure, updated balance, target, counter, and petal state; it does not replay a second transaction.
- If the activity panel closes, the player walks away, or the machine becomes unavailable, pending UI state is discarded but committed session state remains. `SkipReveal` is cosmetic and cannot cancel a committed roll.
- A session ending cancels uncommitted requests and prevents new rolls. Reconnect to a live session restores state; reconnect to a different/new session does not restore Q05 progress.
- Replay is explicit and means another roll after the current transaction has settled, subject to funds and permission. It does not reset the locked wanted figure or create another petal. Q05 remains usable after cake eligibility is reached.

## Controls and usability

On touch, the player taps the machine prompt, figure cards, **Lock wanted figure**, **Roll (20)**, **Close**, and **Skip reveal**. On desktop, the same controls are clickable and keyboard-focusable. Movement and jump regions remain clear; the panel must not remove free-camera drag space. Every modal has visible text and state cues for available, locked, insufficient funds, processing, awarded, canceled, error, and disconnected states. Text must identify that the fund is shared and the award goes to Phuong.

The reveal is short, readable on phone landscape and tablet, and skippable without changing the result. Buttons are disabled during a committed request, with a server-confirmed result replacing the spinner. Accessibility and contrast must be reviewed against PCW-02; this draft does not prescribe final typography or undocumented colors.

## Useful simultaneous roles for 8–10 participants

The eight-to-ten-player group can split across other quests while one authorized spender operates Q05. Friends can inspect the display, discuss the wanted choice, watch the public reveal, check fund/petal status, and continue earning shared-fund contributions elsewhere. No one needs to queue for the cabinet, and no absent participant is required for the roll or the cake. The design intentionally avoids giving ten players ten independent debit rights against one shared balance.

## Acceptance scenarios

1. **Inspection:** ten participants open the machine simultaneously. All receive the same session fund, target, counter, and petal state; no one reserves the cabinet or changes the state by inspecting.
2. **Permission:** Phuong locks Love and has 20 fund units. A guest's roll request is rejected with no state change. Phuong's request succeeds once and produces one receipt.
3. **Atomic success:** with balance 20, a committed roll awards exactly one figure and leaves balance 0. A repeated request using the same action identity returns the same receipt; balance and collection do not change again.
4. **Insufficient balance:** with balance 19, Phuong sees the disabled/blocked roll state. No random result, debit, counter increment, or petal occurs.
5. **Ordinary probabilities:** a deterministic test harness with a seeded outcome source exercises all seven outcomes and records six 16.5% regular weights plus 1% ID; the test must not treat physical blind-box odds as the game's contract.
6. **Early wanted win:** target ID is locked with counter 0, and the first roll resolves to ID. The figure is awarded, counter stops, and exactly one Q05 petal is committed.
7. **Guarantee:** target any regular figure; four committed misses increment the counter to 4. The fifth committed roll awards the target even if its ordinary random draw would miss, debits 20 once, and awards the petal once.
8. **ID guarantee:** target ID; four misses followed by the fifth roll award ID. The guarantee must not exclude the 1% identity.
9. **Concurrent requests:** two authorized requests race with only 20 units. Exactly one commits; the other receives stale/busy/insufficient state and no duplicate debit or award.
10. **Reveal disconnect:** Phuong disconnects after the server receipt but before the reveal finishes. Rejoining the same session shows the awarded figure, new balance, and petal; replaying the request is idempotent.
11. **Guest disconnect:** a guest disconnects while browsing. No reservation, debit, collection change, or petal is created.
12. **Host fallback:** Phuong is temporarily absent; the explicit host opts into fallback and completes a valid roll. A non-host guest attempting the same action is rejected. The fallback decision is logged in the receipt.
13. **Post-completion replay:** after Phuong receives the target and Q05 is complete, a later roll may award a duplicate if funds and permission exist, but no second Q05 petal is possible. Activities remain available.
14. **Session reset:** a new birthday session has fund 0, no wanted target, no Q05 receipt, and no collection from the prior session.

## Required downstream changes before implementation

- PCW-11 must replace its deliverable, acceptance criteria, and validation from six discoveries/three-required shelf flow to the UDistrict vending flow, shared-fund authorization, seven outcomes, guarantee, atomic transaction, and exactly-one Q05 petal. Keep the bedroom shelf only as optional display if separately approved.
- PCW-13 must define the shared fund, Phuong/host spending permission, session-only collection, action idempotency, transaction receipts, reconnect semantics, and the no-cross-session rule. Retire personal coin wallets, coin transfer, personal Q05 gifting, and player-owned Q05 completion criteria for this wave.
- PCW-02 must add the vending inspect/select/confirm/processing/awarded/insufficient/busy/disconnected layouts and equivalent touch/desktop routes.
- PCW-01 and PCW-15 must add approved Big into Energy figure references and an exact figure palette profile. The eight world colors remain authoritative: forest `#365744`, sage `#A8B995`, cream `#F5F0E4`, wood `#95674B`, blossom `#E8B7C6`, brick `#B66C68`, golden `#E8C779`, ink `#26382E`. Figure-specific colors cannot be inferred from shaded references or used to authorize extra world colors.
- PCW-05/map placement must reserve the `Q05UDistrictVending` footprint outside the crossing and pedestrian route, with approach clearance and sightlines for ten players. Task 01 owns the measured anchor and dimensions.
- PCW-14 must require six petals, with Q05 completion specifically defined as receipt of Phuong's wanted figure; money alone must not unlock cake.
- PCW-16 and the Q05 verifier contract must test 8–10 players, mixed touch/desktop interaction, concurrency, reconnect, late join, session reset, all outcomes, exact weights, guarantee cases, and no duplicate debit/award/petal.

## Bounded later implementation checklist

1. Settle Task 09's shared-state and transaction field names, permission fallback, and session lifecycle.
2. Measure and approve the UDistrict anchor, machine footprint, route clearance, interaction radius, and safe camera sightlines for ten players.
3. Approve figure references, logical IDs, exact figure palette profile, and simplified production geometry; do not claim references are production-ready.
4. Implement server-owned deterministic/testable Q05 state and atomic roll receipts before client reveal polish.
5. Implement touch/desktop UI states, independent-camera-safe prompts, refresh-on-reconnect behavior, and skippable reveal.
6. Add verifier tests for probabilities, guarantee, permissions, race handling, idempotency, disconnect/rejoin, and session reset.
7. Independently review the built result, then perform Studio import/scale/collision checks, mixed-device tests, and an 8–10-player rehearsal. Follow build → verify → playtest → revise → retest; this design draft cannot certify any of those gates.

## Evidence limits and unresolved choices

This document is a design specification only. No Roblox Studio scene, live server, teleport, machine model, figure asset, probability test, mobile test, group rehearsal, palette capture, or human fun review has been performed here. The current source documents do not establish measured live anchors or installed Studio state.

Unresolved choices are the exact machine dimensions and local anchor transform; final UI layout/typography; explicit host-fallback UX and timeout; the authoritative field names/receipt schema from Task 09; the exact approved figure references, IDs, palette profile and simplification level; and whether optional post-fulfillment collection display belongs in this wave. These must be resolved before implementation or production verification, without weakening the shared-fund, guarantee, atomicity, session-lifetime, or one-petal requirements.
