# PCW-13 — Shared progress and contribution rules

**Status:** MVP foundation implemented locally; independent review and Studio/group gates remain  
**Priority:** P1 — foundation  
**Suggested owner:** Systems/design (unassigned)  
**Dependencies:** 02; approved map v0.2  
**Owned scope:** Common session behavior and permission specification

## Purpose

Keep ten friends contributing without lost progress or surprise overwrites.

## Deliverable

Session ownership, six-petal rules, Phuong finishing permissions, slot reservations, late-join/rejoin and replay behavior.

## Acceptance criteria

- One petal per identity.
- Late join reflects committed state.
- Reservations release safely.
- Personal finishing changes have defined permissions.
- No absent guest blocks cake.
- Whole stations are not monopolized.

## Limits and open decisions

Design shared session progress separately from cross-session saves. Exact persistence/reset ownership still requires a decision; no datastore promises.

## Validation

Review state scenarios on paper first, then later concurrent-device and disconnection tests.

## Execution boundary

Ticket creation is authorized. Implementation, scripting, Studio building and publishing are not started in this task. The user explicitly requested no code. Follow the [approved map](../design/map-proposal-v0.2.md) and [visual brief](../design/visual-direction-v0.1.md); measurements remain test targets.

## MVP amendment (2026-09-27)

The shared progression kernel is server-owned and session-only. One fund starts at 0; Q01/Q02/Q03/Q04/Q06 first completed rounds credit 20 once, explicit replay rounds credit 10 once, and Q05 never earns. These are tunable MVP defaults. Rewards never multiply by contributor count. Activity/round/action IDs and immutable completion receipts deduplicate repeated taps, saves, retries, and reconnects. Rejoining the same session restores accepted steps and committed state; a new session resets it. See `roblox/mvp/CONTRACT.md`.
