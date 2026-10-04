# PCW-07 — Q01 — Everything Tucked In

**Status:** MVP implementation underway; acceptance remains evidence-gated  
**Priority:** P2 — after foundation  
**Suggested owner:** Activity design (unassigned)  
**Dependencies:** 02; 04; 13  
**Owned scope:** Bed activity only

## Purpose

Friends help make her bed and tuck in her two weighted plushies.

## Deliverable

Steps, placement slots, contributor positions, finishing choice, cancellation and replay specification.

## Acceptance criteria

- Touch can select sheets/pillows/plushies and generous slots.
- Dog and dinosaur remain round-bellied and head-sized.
- Phuong gets a meaningful finishing choice.
- Completion awards one shared petal once.

## Limits and open decisions

No timed chore or required exact drag; do not reset a completed bed when a guest joins.

## Validation

Later two simultaneous contributors, cancel/rejoin and replay checks.

## Current MVP amendment (September 27, 2026)

Implementation is authorized in `roblox/mvp/server/activities/Q01.luau`, `roblox/mvp/builders/Q01Station.luau`, `roblox/mvp/client/activities/Q01.luau`, and the Q01 pure-state test. The activity binds to the shared `SessionService` contract and does not own currency, petals, or cake state. It implements seven server-validated steps (`blanket_left`, `blanket_right`, `blanket_foot`, `pillow_left`, `pillow_right`, `plush_dog`, `plush_dinosaur`), per-step reservations with expiry, forgiving duplicate/wrong-step responses, a Phuong-only finishing choice, visible replay preview state, and once-only shared completion through `CompleteRound`. The native station builder is installable by the designated integrator only and resolves the live `Q01Bed` anchor; it does not claim measured Studio placement.

The current world direction is the existing bedroom, shared birthday fund, six shared petals, ten-player capacity, independent cameras, and touch/desktop parity. No personal wallet, timer, forced cinematic, or personal-note content is introduced. Acceptance still requires independent verification, actual Studio installation, device/group playtest, and human review; source tests are not Studio evidence.

## Execution boundary

Ticket creation is authorized. Implementation, scripting, Studio building and publishing are not started in this task. The user explicitly requested no code. Follow the [approved map](../design/map-proposal-v0.2.md) and [visual brief](../design/visual-direction-v0.1.md); measurements remain test targets.
