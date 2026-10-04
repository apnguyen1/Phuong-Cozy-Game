# PCW-24 - Phuong and Andrew host recovery controls

**Status:** IMPLEMENTED_PENDING_INTEGRATION. **Requested:** October 3, 2026. **Builder:** host_recovery. **Verifier:** independent final-stage reviewer.

## Dependencies and ownership

After 23.

Own only: New HostService; SessionService safe recovery helpers; Main server routing; client host panel; Config explicit IDs; narrowly scoped recovery methods in activities/finale where needed to keep local state and world presentation coherent. Preserve their normal flows rather than redesigning them. Do not change external Roblox access permissions.

## Purpose

Implement Phuong and Andrew host recovery controls for the October 3 birthday release, preserving the authorized shared game and the detailed requirements below.

## Deliverable

Provide a practical emergency panel, authenticated by server IDs only.
- Hosts: Phuong user3971290001 username Phamlet707; Andrew user1078077474 username IamBannedrew (live username lookup confirmed Oct3). Display names are not authorization. Ordinary guests never gain host power.
- Both get a discreet Host controls button on touch/desktop. Keep normal Phuong-first choices; an explicit Override mode lets either host recover when needed, including Andrew while Phuong is present. Show clear banner/audit entry while override is active.
- Bounded recovery actions: release stuck reservations; reset an incomplete activity round without erasing earned petals/funds; mark a chosen quest complete once with its normal missing reward only; top up shared fund by a fixed20; fulfill Phuong's currently selected wish once (or choose a valid target through normal data); invite/start/advance the cake recovery; return host to bedroom/patio.
- Do not add arbitrary code execution, text-to-command, client-supplied actor, global player kicks/bans, unlimited currency textbox, external account admin or destructive full-session reset.
- Before changing progress/funds, show current state, exact effect and Confirm/Cancel. Deduplicate requests with action IDs, rate-limit, validate allowed activity IDs and server session ID. Replays/duplicates cannot grant repeat money or petals.
- Server records a small bounded session audit (actor, action, affected activity, prior/new state, timestamp); display recent recovery results only to hosts. Server normal snapshots contain no sensitive unnecessary data.
- Recovery must update activity-local completion/collection/round state coherently with SessionService and world presentation. A petal flip alone leaving dead UI is not sufficient.
- All controls work on phone; clear success/failure toasts and cancel routes.

## Acceptance criteria

- Both real configured IDs can open/use controls; guests/spoofed payloads cannot.
- A stuck bed/food/craft session can be released/restarted without losing unrelated progress.
- Completing/recovering a quest grants only missing initial reward/petal, once.
- Desired Labubu recovery updates collection and exactly one Q05 petal, no extra reward.
- Finale recovery does not strand cameras/seats and normal Phuong trigger remains primary.
- Duplicate/malformed/spam requests are rejected or return original result; bounded audit is readable.
- No test-user override or permission based on display name ships.

## Delivery rules

Read AGENTS.md, docs/tickets/README.md, this ticket, docs/design/map-proposal-v0.2.md, docs/design/visual-direction-v0.1.md, verification/README.md, and docs/coordination/release-20261003/README.md. The October 3 user instruction authorizes this implementation and supersedes older no-code/publish exclusions for this release. Use Phuong and Andrew in all prose. Existing Roblox account IDs are authoritative; do not infer permissions from display names.

Work sequentially: only the currently assigned builder may edit production source. You are not alone in this checkout; preserve other changes and do not switch branches or revert files. No Studio access, playtests, test runs, publishing, or self-approval by builders. The orchestrator reviews each handoff for completeness, then installs and tests the complete build with an independent verifier at the end. Tests may be authored when meaningful, but execution is deferred. Report incomplete work honestly.

Use the existing exact palette. Preserve the room, map, approved assets, shared six-petal structure, currency rules, session-only persistence, real friends, touch access and independent cameras. Never write the personal birthday note. Do not add NPC guests, real-money purchases, compulsory typing, timers to pad activities, or a seventh required quest.

Deliver production source, any necessary integration manifest notes, and docs/coordination/release-20261003/handoffs/PCW-XX.md (substitute your ticket number). State changed files, exact behavior, dependencies, known limits, and deferred test scenarios. Status is IMPLEMENTED_PENDING_INTEGRATION, never PASS. The orchestrator owns final status changes.


## Limits and open decisions

The ownership and delivery rules above remain binding. Preserve exact palette, real friends, six shared petals, session-only progress and user-authored personal note. Builders do not approve their own delivery. Physical device and human group evidence cannot be replaced by desktop emulation or agent opinion. Andrew delegated autonomous implementation, agent review and publication; this is scope authorization, not an invented human review of the final revision. Report actual platform blockers.

## Validation

After all sequential builders deliver, follow docs/coordination/release-20261003/WALKTHROUGH.md and PCW-25. Bind final source to Studio, run meaningful contract checks, exercise the real controls and changed world feedback, retain screenshots/console and device evidence, and obtain independent verifier findings. Map every acceptance bullet above to observed evidence or an explicit unresolved limit. Fix defects and retest; do not infer playability or fun from source checks alone. No testing executes during the implementation queue.
