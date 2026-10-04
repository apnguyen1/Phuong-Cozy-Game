# PCW-21 - Labubu wish selection, reveal and collection clarity

**Status:** IMPLEMENTED_PENDING_INTEGRATION. **Requested:** October 3, 2026. **Builder:** labubu_wish. **Verifier:** independent final-stage reviewer.

## Dependencies and ownership

After 20.

Own only: Q05 activity, Q05Station builder, client Q05 extension, shared figure presentation data; Main snapshot/world hookup as needed.

## Purpose

Implement Labubu wish selection, reveal and collection clarity for the October 3 birthday release, preserving the authorized shared game and the detailed requirements below.

## Deliverable

Make the central birthday goal understandable and satisfying without changing the economy.
- Use seven labeled figure cards with simplified visual previews from current approved geometry. Keep existing IDs/probabilities, do not fabricate reference-accurate assets or new colors. Clearly identify secret figure.
- The live Q05 cabinet currently contains seven rectangular FigureSlot markers, not complete figure models. Supply bounded, recognizable simplified toy previews/reveals using native geometry and the approved palette instead of treating those rectangles as finished Labubus. Keep a coherent paired-ear, face/body silhouette and clear distinct labels. The old art/Q05 README is explicitly a proposal, not a claim of approved faithful reference colors; identify simplified art honestly in the handoff and require final visual review.
- Explain: friends earn together, Phuong picks her wish, 20 per roll, selected wish guaranteed by fifth roll. Show selected wish, shared balance, attempts remaining to guarantee, collection copies, latest result.
- Selecting a card previews it; explicit Confirm wish commits. Choice locks until fulfilled. A separate prominent Get a Labubu - 20 button confirms shared spending. Guests see watcher/help states, not a wall of unusable buttons.
- Authoritative purchase precedes reveal. Reveal has a short capsule/figure presentation, Skip and a persistent result card; never gate award on animation completion. Make the shared machine/display update so nearby friends see the result.
- Keep six regular16.5%/secret1%, fifth-roll guarantee including secret, duplicate action deduplication, session collection, exactly-one Q05 petal and no Q05 currency.
- After fulfillment, show the main story is complete for this task and next remaining goal/patio. Further collection is clearly optional and cannot relock cake.
- Integrate collection display with the bedroom shelf without overwriting organization/miniature-owned slots. Use a separate owned display region.
- Ensure invalid actions show a friendly reason (Phuong's choice, insufficient funds, locked wish, pending roll); avoid raw figure IDs in the player UI.

## Acceptance criteria

- Phuong can understand select/confirm/roll without instructions from Andrew.
- Friends can see why they are earning and who controls purchases.
- Five first earning activities fund the maximum five rolls; no grinding is required for first wish.
- Early win and fifth-roll win both fulfill the goal exactly once, including the secret.
- Close/reset/rejoin during reveal retains awarded figure and funds, with no second debit.
- Visual result is visible in-world and can be skipped without changing server state.

## Delivery rules

Read AGENTS.md, docs/tickets/README.md, this ticket, docs/design/map-proposal-v0.2.md, docs/design/visual-direction-v0.1.md, verification/README.md, and docs/coordination/release-20261003/README.md. The October 3 user instruction authorizes this implementation and supersedes older no-code/publish exclusions for this release. Use Phuong and Andrew in all prose. Existing Roblox account IDs are authoritative; do not infer permissions from display names.

Work sequentially: only the currently assigned builder may edit production source. You are not alone in this checkout; preserve other changes and do not switch branches or revert files. No Studio access, playtests, test runs, publishing, or self-approval by builders. The orchestrator reviews each handoff for completeness, then installs and tests the complete build with an independent verifier at the end. Tests may be authored when meaningful, but execution is deferred. Report incomplete work honestly.

Use the existing exact palette. Preserve the room, map, approved assets, shared six-petal structure, currency rules, session-only persistence, real friends, touch access and independent cameras. Never write the personal birthday note. Do not add NPC guests, real-money purchases, compulsory typing, timers to pad activities, or a seventh required quest.

Deliver production source, any necessary integration manifest notes, and docs/coordination/release-20261003/handoffs/PCW-XX.md (substitute your ticket number). State changed files, exact behavior, dependencies, known limits, and deferred test scenarios. Status is IMPLEMENTED_PENDING_INTEGRATION, never PASS. The orchestrator owns final status changes.


## Limits and open decisions

The ownership and delivery rules above remain binding. Preserve exact palette, real friends, six shared petals, session-only progress and user-authored personal note. Builders do not approve their own delivery. Physical device and human group evidence cannot be replaced by desktop emulation or agent opinion. Andrew delegated autonomous implementation, agent review and publication; this is scope authorization, not an invented human review of the final revision. Report actual platform blockers.

## Validation

After all sequential builders deliver, follow docs/coordination/release-20261003/WALKTHROUGH.md and PCW-25. Bind final source to Studio, run meaningful contract checks, exercise the real controls and changed world feedback, retain screenshots/console and device evidence, and obtain independent verifier findings. Map every acceptance bullet above to observed evidence or an explicit unresolved limit. Fix defects and retest; do not infer playability or fun from source checks alone. No testing executes during the implementation queue.
