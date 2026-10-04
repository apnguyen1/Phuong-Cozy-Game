# PCW-19 - Intuitive bed and bedroom shelf organization

**Status:** IMPLEMENTED_PENDING_INTEGRATION. **Requested:** October 3, 2026. **Builder:** bed_shelf. **Verifier:** independent final-stage reviewer. Source delivery reviewed by orchestrator; no runtime approval yet.

## Dependencies and ownership

After 18.

Own only: Q01 server activity; Q01Station builder; a new BedroomFeedback server module if needed; Main.server wiring and client Q01 presentation extension. Coordinate with existing guidance.

## Purpose

Implement Intuitive bed and bedroom shelf organization for the October 3 birthday release, preserving the authorized shared game and the detailed requirements below.

## Deliverable

Turn abstract reserve/place into approachable room organization.
- Preserve seven required bed actions and Phuong's final style choice. Players first pick a clear blanket/pillow/plush card, see the target highlighted, then tap Place/Tuck. One tap may reserve and the second commits; friendly cancel/retry must work.
- Show descriptive step names, held item and remaining tasks. Hide completed steps from the main action area or group under Done. Other users' reserved items show In use without locking the whole bed.
- Render real shared visible progress: blanket edges smoothing, pillows and dog/dinosaur plush placement using existing room geometry or small owned overlays. Save baseline transforms per runtime round and reset only owned task geometry on explicit replay.
- Live structure: the detailed original bed is Home.Bedroom.SageBed (SageDuvet, DuvetSideDrape, CreamSleepingPillow, FoldedCreamQuilt, BedPlushies); the optional shelf is Home.Bedroom.FilledBookcase. A separate simple MVP.Stations.Q01Station already exists. Do not add a third bed or treat a crude duplicate as the intended finished bedroom. Prefer acting on the detailed bed with safely restored per-round transforms and small owned target cues. Current paths/positions are recorded in roblox/evidence/release-20261003/scene-manifest.json.
- Add optional shelf/room tidying at the existing bedroom display/shelf: choose a book/collectible, choose a labeled shelf slot, confirm; show the moved object to everyone. This is part of room interaction and does NOT add a seventh petal, a required extra grind or extra money. Preserve any miniature/Labubu display slots owned by other activities.
- Use server-owned per-slot occupancy/reservation, release on close/timeout/disconnect, no client-authoritative transforms or rewards. Shared display can be changed by Phuong/Andrew; guests can fill empty slots. Avoid destroying or relocating original furnishings.
- Final choice remains Phuong's (configured fallback when absent); bed completion grants one reward through SessionService. Never invent names/likenesses for personal objects.
- If shelf needs a new request kind, include canonical identity, proximity, allowlist and idempotence in Main, and document descriptor shape.

## Acceptance criteria

- Touch/desktop flow explains item and destination before commitment; no raw reserve/place jargon.
- Two helpers can work different slots; occupied-slot contention gives a clear recoverable response.
- Bed changes visibly for all clients; replay restores only owned details and doesn't duplicate rewards.
- Shelf organization is discoverable and visibly persistent within the running server, without affecting six-petal completion.
- Camera and bedroom circulation remain clear; decorations use exact palette.
- Closing/reset/disconnect releases held resources, and resuming shows authoritative progress.

## Delivery rules

Read AGENTS.md, docs/tickets/README.md, this ticket, docs/design/map-proposal-v0.2.md, docs/design/visual-direction-v0.1.md, verification/README.md, and docs/coordination/release-20261003/README.md. The October 3 user instruction authorizes this implementation and supersedes older no-code/publish exclusions for this release. Use Phuong and Andrew in all prose. Existing Roblox account IDs are authoritative; do not infer permissions from display names.

Work sequentially: only the currently assigned builder may edit production source. You are not alone in this checkout; preserve other changes and do not switch branches or revert files. No Studio access, playtests, test runs, publishing, or self-approval by builders. The orchestrator reviews each handoff for completeness, then installs and tests the complete build with an independent verifier at the end. Tests may be authored when meaningful, but execution is deferred. Report incomplete work honestly.

Use the existing exact palette. Preserve the room, map, approved assets, shared six-petal structure, currency rules, session-only persistence, real friends, touch access and independent cameras. Never write the personal birthday note. Do not add NPC guests, real-money purchases, compulsory typing, timers to pad activities, or a seventh required quest.

Deliver production source, any necessary integration manifest notes, and docs/coordination/release-20261003/handoffs/PCW-XX.md (substitute your ticket number). State changed files, exact behavior, dependencies, known limits, and deferred test scenarios. Status is IMPLEMENTED_PENDING_INTEGRATION, never PASS. The orchestrator owns final status changes.


## Limits and open decisions

The ownership and delivery rules above remain binding. Preserve exact palette, real friends, six shared petals, session-only progress and user-authored personal note. Builders do not approve their own delivery. Physical device and human group evidence cannot be replaced by desktop emulation or agent opinion. Andrew delegated autonomous implementation, agent review and publication; this is scope authorization, not an invented human review of the final revision. Report actual platform blockers.

## Validation

After all sequential builders deliver, follow docs/coordination/release-20261003/WALKTHROUGH.md and PCW-25. Bind final source to Studio, run meaningful contract checks, exercise the real controls and changed world feedback, retain screenshots/console and device evidence, and obtain independent verifier findings. Map every acceptance bullet above to observed evidence or an explicit unresolved limit. Fix defects and retest; do not infer playability or fun from source checks alone. No testing executes during the implementation queue.
