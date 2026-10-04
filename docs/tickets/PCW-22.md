# PCW-22 - Visible Jasper, craft and reading feedback

**Status:** IMPLEMENTED_PENDING_INTEGRATION. **Requested:** October 3, 2026. **Builder:** world_activities. **Verifier:** independent final-stage reviewer.

## Dependencies and ownership

After 21.

Own only: Q02/Q03/Q04 activity presentation and new shared WorldFeedback server module; their client extensions; Main hooks. Do not redesign approved environment.

## Purpose

Implement Visible Jasper, craft and reading feedback for the October 3 birthday release, preserving the authorized shared game and the detailed requirements below.

## Deliverable

Complete the shared activity feel after guidance/food/Labubu improvements.
- Connect existing Jasper moveJasperToYard/presentFetchTarget/petJasper hooks to real world actions. Start with bedroom greeting, guide to yard, show rabbit/toy pickup and forgiving throw, bounded fetch movement, return and treat feedback.
- Preserve existing Jasper model. Do not import uninspected new model assets as part of this ticket. Use server-owned anchored/kinematic movement if navigation is unreliable, with bounded recovery and no collisions with guests.
- Live read-only preflight found no named dog actor outside the weighted bed plush; Q02Station contains only marker/basket parts. Do not move the weighted plush as Jasper. If no real dog actor is available, create one bounded, palette-native simplified Pomeranian (fluffy body, pointed ears, muzzle, eyes, legs and curled tail) under owned RuntimePresentation.Jasper. Mark simplified geometry honestly; keep it distinct from the two weighted bed plushies. No more than 40 anchored/noncolliding parts for this actor.
- For craft, labeled part cards, highlighted matching sockets, easy rotation/confirm and visible miniature assembly. Booth and bedroom display represent one shared object; show correct progress in both places, never two independent reward tracks.
- For reading, keep readable passage, highlight/reaction/bookmark choices and optional note; show saved bookmark as a visible small shared accent/acknowledgment. Never author the personal birthday note or guest wishes.
- All accepted actions have modest visual feedback and clear completion. Avoid spawning unbounded particles, parts or event connections; no global camera changes.
- Next objective guidance must move Jasper from indoor greeting to outdoor fetch and craft to Phuong finishing when ready.
- Preserve all current round/reward/idempotence semantics and cooperative contributions.

## Acceptance criteria

- Jasper's interaction visibly changes the world; no accepted fetch is only a menu counter.
- Craft parts visibly assemble and both representations stay synchronized.
- Reading choices remain clear on phone and saved state survives closing.
- Every activity can recover from cancel, reset, disconnect and interrupted presentation.
- Effects are bounded, palette-correct and don't block routes or control cameras.
- Integration context actually supplies every hook the activities use.

## Delivery rules

Read AGENTS.md, docs/tickets/README.md, this ticket, docs/design/map-proposal-v0.2.md, docs/design/visual-direction-v0.1.md, verification/README.md, and docs/coordination/release-20261003/README.md. The October 3 user instruction authorizes this implementation and supersedes older no-code/publish exclusions for this release. Use Phuong and Andrew in all prose. Existing Roblox account IDs are authoritative; do not infer permissions from display names.

Work sequentially: only the currently assigned builder may edit production source. You are not alone in this checkout; preserve other changes and do not switch branches or revert files. No Studio access, playtests, test runs, publishing, or self-approval by builders. The orchestrator reviews each handoff for completeness, then installs and tests the complete build with an independent verifier at the end. Tests may be authored when meaningful, but execution is deferred. Report incomplete work honestly.

Use the existing exact palette. Preserve the room, map, approved assets, shared six-petal structure, currency rules, session-only persistence, real friends, touch access and independent cameras. Never write the personal birthday note. Do not add NPC guests, real-money purchases, compulsory typing, timers to pad activities, or a seventh required quest.

Deliver production source, any necessary integration manifest notes, and docs/coordination/release-20261003/handoffs/PCW-XX.md (substitute your ticket number). State changed files, exact behavior, dependencies, known limits, and deferred test scenarios. Status is IMPLEMENTED_PENDING_INTEGRATION, never PASS. The orchestrator owns final status changes.


## Limits and open decisions

The ownership and delivery rules above remain binding. Preserve exact palette, real friends, six shared petals, session-only progress and user-authored personal note. Builders do not approve their own delivery. Physical device and human group evidence cannot be replaced by desktop emulation or agent opinion. Andrew delegated autonomous implementation, agent review and publication; this is scope authorization, not an invented human review of the final revision. Report actual platform blockers.

## Validation

After all sequential builders deliver, follow docs/coordination/release-20261003/WALKTHROUGH.md and PCW-25. Bind final source to Studio, run meaningful contract checks, exercise the real controls and changed world feedback, retain screenshots/console and device evidence, and obtain independent verifier findings. Map every acceptance bullet above to observed evidence or an explicit unresolved limit. Fix defects and retest; do not infer playability or fun from source checks alone. No testing executes during the implementation queue.
