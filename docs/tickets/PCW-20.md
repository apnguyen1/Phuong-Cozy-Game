# PCW-20 - Build your food with clear choices and visible dishes

**Status:** IMPLEMENTED_PENDING_INTEGRATION. **Requested:** October 3, 2026. **Builder:** guided_food. **Verifier:** independent final-stage reviewer. Source delivery reviewed by orchestrator; no runtime approval yet.

## Dependencies and ownership

After 19.

Own only: Q06 server activity, Q06Station builder, client Q06 extension; Main.server and world feedback hooks only as necessary.

## Purpose

Implement Build your food with clear choices and visible dishes for the October 3 birthday release, preserving the authorized shared game and the detailed requirements below.

## Deliverable

Replace the opaque slot:item list with a guided food-building flow.
- Start with a simple recipe explanation: make a bowl at FOB, add sauce at Aladdins, then set the table at serving. Show location and next destination at each transition.
- Present base, protein, toppings, sauce and table settings as labeled ingredient cards. Select -> show preview/selection -> Add/Place. Do not auto-submit an accidental ingredient tap.
- Preserve the current allowed choices and forgiving rules; accept genuine variants without silently substituting a different food. Use friendly names (rice, tofu/chicken/mushroom, greens/cucumber/carrot, sauce/sesame, plate/cup/napkin).
- Add shared visible bowl/plate ingredients and table settings at the current station anchors using palette-compliant simple geometry. Update from authoritative accepted choices; remain nonblocking and bounded.
- Only show actions available at the current venue; distant steps offer Track next counter rather than an unexplained TooFar error. Continue partial work across counters/close/rejoin.
- Preserve six required steps, once-only first reward20 and explicit replay10 via SessionService. Slot contention, cancellation, duplicate actions and completed rounds must stay safe.
- Completed dish has a clear Done message and points to another incomplete activity/Labubu; no compulsory replay.

## Acceptance criteria

- First-time user can finish by following instructions across all three counters.
- Each accepted ingredient appears in the shared dish and UI summary.
- Variant choices are honored, no precision gestures/timing/typing required.
- Two helpers can contribute safely; busy state is legible and temporary.
- Reopen/rejoin restores the dish; replay has a clean new dish and cannot repay an old round.
- Source wiring reaches the live renderer and world effect, not only unused helper modules.

## Delivery rules

Read AGENTS.md, docs/tickets/README.md, this ticket, docs/design/map-proposal-v0.2.md, docs/design/visual-direction-v0.1.md, verification/README.md, and docs/coordination/release-20261003/README.md. The October 3 user instruction authorizes this implementation and supersedes older no-code/publish exclusions for this release. Use Phuong and Andrew in all prose. Existing Roblox account IDs are authoritative; do not infer permissions from display names.

Work sequentially: only the currently assigned builder may edit production source. You are not alone in this checkout; preserve other changes and do not switch branches or revert files. No Studio access, playtests, test runs, publishing, or self-approval by builders. The orchestrator reviews each handoff for completeness, then installs and tests the complete build with an independent verifier at the end. Tests may be authored when meaningful, but execution is deferred. Report incomplete work honestly.

Use the existing exact palette. Preserve the room, map, approved assets, shared six-petal structure, currency rules, session-only persistence, real friends, touch access and independent cameras. Never write the personal birthday note. Do not add NPC guests, real-money purchases, compulsory typing, timers to pad activities, or a seventh required quest.

Deliver production source, any necessary integration manifest notes, and docs/coordination/release-20261003/handoffs/PCW-XX.md (substitute your ticket number). State changed files, exact behavior, dependencies, known limits, and deferred test scenarios. Status is IMPLEMENTED_PENDING_INTEGRATION, never PASS. The orchestrator owns final status changes.


## Limits and open decisions

The ownership and delivery rules above remain binding. Preserve exact palette, real friends, six shared petals, session-only progress and user-authored personal note. Builders do not approve their own delivery. Physical device and human group evidence cannot be replaced by desktop emulation or agent opinion. Andrew delegated autonomous implementation, agent review and publication; this is scope authorization, not an invented human review of the final revision. Report actual platform blockers.

## Validation

After all sequential builders deliver, follow docs/coordination/release-20261003/WALKTHROUGH.md and PCW-25. Bind final source to Studio, run meaningful contract checks, exercise the real controls and changed world feedback, retain screenshots/console and device evidence, and obtain independent verifier findings. Map every acceptance bullet above to observed evidence or an explicit unresolved limit. Fix defects and retest; do not infer playability or fun from source checks alone. No testing executes during the implementation queue.
