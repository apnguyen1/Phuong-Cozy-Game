# PCW-18 - Guided mobile interface and destination markers

**Status:** IMPLEMENTED_PENDING_INTEGRATION. **Requested:** October 3, 2026. **Builder:** guided_ui. **Verifier:** independent final-stage reviewer. Source delivery reviewed by orchestrator; no runtime approval yet.

## Dependencies and ownership

First. Foundation for 19-24.

Own only: roblox/mvp/client/Main.client.luau; new client support ModuleScripts and shared Guidance.luau only. Do not modify server activities. Preserve installed audio hooks by comparing the live baseline.

## Purpose

Implement Guided mobile interface and destination markers for the October 3 birthday release, preserving the authorized shared game and the detailed requirements below.

## Deliverable

The current giant action list shows internal states and often gives no next step. Build a readable, compact interface that teaches each task and exposes one sensible next action while keeping alternatives available.
- Show a small world HUD: birthday goal, fund, six petals, current next objective and Track button. Journal names all six activities, current progress and destinations, with completed checkmarks.
- Put navigation in a pure data module: activity ID, friendly title, anchor names and default hints. Prefer incomplete nearby/open activity, then Labubu when funded, then patio at six petals. Allow explicit tracking without forcing order.
- Create local-only destination marker/Highlight/Billboard at existing anchors, readable from the path; include distance and an offscreen direction hint if needed. Remove/reassign on completion, exit, reset and lobby entry. Do not warp players or move anchors.
- Responsive phone landscape/tablet/desktop layout, safe inset, large taps (48+), no fixed 260-pixel title subtraction on narrow widths, scroll only where necessary, visible Close and Back. Leave movement, jump and camera drag usable.
- Activity renderer supports a new optional view.guide={headline,detail,stepLabel,nextAnchor,preview,groups} descriptor plus normal availableActions. Support choice cards, a clearly labeled main action, confirmation before spending/finishing, disabled reasons, and a world-preview space or compact preview cards for later tickets.
- Show friendly status/error toast. Do not show raw enum states, table addresses or action IDs. Throttle duplicate taps until a response; recover from timeout/rejection. Snapshot broadcasts must not unexpectedly reopen a closed panel.
- Preserve Q04 reading text and choices, CloseActivity reservation release, replay route, request IDs, authenticated server ownership, current lobby hiding and optional per-player camera.
- Expose a small documented client extension surface for later activity previews/finale/host UI; keep all new dependencies resolvable after installation. Prefer client modules beneath ReplicatedStorage.PhuongMVP.client; document exact paths.

## Acceptance criteria

- New player can identify goal and find a first activity without verbal coaching.
- Every task has readable purpose, next action, progress, success and exit. Locked actions explain who/what is needed.
- Tracking updates to the actual current anchor; zero markers remain in lobby.
- Phone-sized title/buttons do not overlap or conceal movement controls; keyboard-only actions have touch equivalents.
- Existing remotes/payload contract survives; error and pending state cannot permanently freeze the UI.
- No quest/currency/permission rule is silently changed.

## Delivery rules

Read AGENTS.md, docs/tickets/README.md, this ticket, docs/design/map-proposal-v0.2.md, docs/design/visual-direction-v0.1.md, verification/README.md, and docs/coordination/release-20261003/README.md. The October 3 user instruction authorizes this implementation and supersedes older no-code/publish exclusions for this release. Use Phuong and Andrew in all prose. Existing Roblox account IDs are authoritative; do not infer permissions from display names.

Work sequentially: only the currently assigned builder may edit production source. You are not alone in this checkout; preserve other changes and do not switch branches or revert files. No Studio access, playtests, test runs, publishing, or self-approval by builders. The orchestrator reviews each handoff for completeness, then installs and tests the complete build with an independent verifier at the end. Tests may be authored when meaningful, but execution is deferred. Report incomplete work honestly.

Use the existing exact palette. Preserve the room, map, approved assets, shared six-petal structure, currency rules, session-only persistence, real friends, touch access and independent cameras. Never write the personal birthday note. Do not add NPC guests, real-money purchases, compulsory typing, timers to pad activities, or a seventh required quest.

Deliver production source, any necessary integration manifest notes, and docs/coordination/release-20261003/handoffs/PCW-XX.md (substitute your ticket number). State changed files, exact behavior, dependencies, known limits, and deferred test scenarios. Status is IMPLEMENTED_PENDING_INTEGRATION, never PASS. The orchestrator owns final status changes.


## Limits and open decisions

The ownership and delivery rules above remain binding. Preserve exact palette, real friends, six shared petals, session-only progress and user-authored personal note. Builders do not approve their own delivery. Physical device and human group evidence cannot be replaced by desktop emulation or agent opinion. Andrew delegated autonomous implementation, agent review and publication; this is scope authorization, not an invented human review of the final revision. Report actual platform blockers.

## Validation

After all sequential builders deliver, follow docs/coordination/release-20261003/WALKTHROUGH.md and PCW-25. Bind final source to Studio, run meaningful contract checks, exercise the real controls and changed world feedback, retain screenshots/console and device evidence, and obtain independent verifier findings. Map every acceptance bullet above to observed evidence or an explicit unresolved limit. Fix defects and retest; do not infer playability or fun from source checks alone. No testing executes during the implementation queue.
