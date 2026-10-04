# PCW-12 — Q06 — Something Delicious

**Status:** Planned; not started  
**Priority:** P2 — after foundation  
**Suggested owner:** Activity design (unassigned)  
**Dependencies:** 02; 03; 13  
**Owned scope:** UDistrict food assembly and shared serving activity near FOB Poke Bar and Aladdins. The patio is reserved for the cake finale.

## September 27, 2026 MVP amendment

Implementation is authorized for the local Roblox MVP, subject to independent verification and later user playtesting. Q06 uses the proposed, fictional venue-inspired bowl/plate assembly described in [the implementation draft](../coordination/birthday-draft-2026-09-27/07-q06-food.md). This is not a claim about either real restaurant's menu and remains tunable until the user reviews the playable result.

The activity is built at the measured `Q06FOBCounter`, `Q06AladdinsCounter`, and `Q06Serving` anchors. It must keep storefront doors, the UDistrict crossing, the central pedestrian lane, and the FinalePatio approach clear. The historical KBBQ/seafood wording below is preserved as planning history; it no longer authorizes patio placement or precision cooking.

The Q06 module binds to `roblox/mvp/CONTRACT.md`: one session-owned adapter instance, `CreateRound`, `Apply`, `GetView`, server-validated accepted steps, and SessionService-owned once-only petal/fund receipts. The first completed Q06 round uses the shared first-clear reward default; explicit replays use the shared replay default and never grant a second petal. All progress is session-only.

## Purpose

Give multiple friends useful cooking and decoration roles.

## Deliverable

KBBQ station, seafood-boil prep, serving table and place-setting slots.

## Acceptance criteria

- Grill, seafood and table-setting can happen in parallel.
- Food remains visible afterward.
- Touch actions forgiving.
- Station users do not block cake space or entrances.
- One petal only.

## Limits and open decisions

No precision timing or restaurant economy. Preserve 52 × 24 gathering space within patio.

## Validation

Later six contributors plus spectators, cancel/rejoin and cooking-to-party transition.

## Execution boundary

Ticket creation is authorized. Implementation, scripting, Studio building and publishing are not started in this task. The user explicitly requested no code. Follow the [approved map](../design/map-proposal-v0.2.md) and [visual brief](../design/visual-direction-v0.1.md); measurements remain test targets.

The September 27 implementation amendment supersedes that historical execution sentence for the scoped local MVP. Studio installation, live play, publishing, and final acceptance remain separate gates owned by the designated integrator and independent reviewer.
