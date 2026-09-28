# PCW-08 — Q02 — Jasper's Favorite Things

**MVP amendment (September 27, 2026):** Implementation is authorized for the shared-session Roblox MVP. The owned source is `roblox/mvp/server/activities/Q02.luau`, with the edit-mode station/model source in `roblox/mvp/builders/Q02Station.luau` and UI descriptor in `roblox/mvp/client/activities/Q02.luau`. The activity begins with Jasper inside the existing bedroom, leads to the existing outdoor yard, uses one shared rabbit discovered across three baskets, three one-use fetch targets, and a Greenie finish. It calls the shared `SessionService` contract for the one Q02 petal and shared-fund reward; it does not create personal wallets or local reward logic. Studio installation, navigation, figure fidelity, touch/desktop play, 8–10-player play, and human fun review remain evidence-gated.

**Status:** Planned; not started  
**Priority:** P2 — after foundation  
**Suggested owner:** Activity design (unassigned)  
**Dependencies:** 02; 03; 13  
**Owned scope:** Yard activity and Jasper interaction boundaries

## Purpose

Make Jasper playful company around rabbit, fetch and Greenie.

## Deliverable

Rabbit discovery, turn-taking fetch, treat action, petting and clear fetch lane.

## Acceptance criteria

- Fluffy golden-orange Pomeranian identity preserved.
- Tap-to-throw works.
- One thrower cannot lock all interactions.
- Rabbit/treat progress survives a participant leaving.
- One petal only.

## Limits and open decisions

At most one optional accident gag; no recurring cleanup or punishment.

## Validation

Later touch throw, interruption, gate clearance and competing-player checks.

## Execution boundary

Ticket creation is authorized. Implementation, scripting, Studio building and publishing are not started in this task. The user explicitly requested no code. Follow the [approved map](../design/map-proposal-v0.2.md) and [visual brief](../design/visual-direction-v0.1.md); measurements remain test targets.
