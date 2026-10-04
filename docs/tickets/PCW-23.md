# PCW-23 - Phuong seated birthday celebration and cake eating

**Status:** IMPLEMENTED_PENDING_INTEGRATION. **Requested:** October 3, 2026. **Builder:** birthday_finale. **Verifier:** independent final-stage reviewer.

## Dependencies and ownership

After 22.

Own only: CakeService; new FinalePresentation server/client modules; CakeFinale builder; Main/client integration. Preserve existing CozyAudio/SoundEffects and use their hooks where suitable.

## Purpose

Implement Phuong seated birthday celebration and cake eating for the October 3 birthday release, preserving the authorized shared game and the detailed requirements below.

## Deliverable

Create the requested group birthday payoff.
- At six petals, announce the patio invitation to all present world participants and track the table. Use existing table and ten seats; mark Phuong's designated seat and provide guest seat cues.
- Existing eight side seats are under SurroundingContext.NeighborhoodDetails02.BirthdayCourtyard; the two end seats are separately under MVP.Stations.CakeFinale.EndSeatWest.Seat and EndSeatEast.Seat. Include both roots when identifying the ten patio seats; do not collect lobby/porch seats or create duplicate end seats. GatheringTable center is approximately (346,3.6,98.608), end seats at x328 and364, y2.12, z98.608. Current snapshot is in roblox/evidence/release-20261003/scene-manifest.json.
- Guests sit first; unlock automatically arms the gathering unless a host explicitly delays it. Once armed, Phuong sitting in her designated seat starts exactly one celebration, without an extra unexplained Start button. The host can deliberately arm/delay/recover; no random guest can start. Do not require all ten potential guests online. If Phuong was already seated before unlock, give her a clear stand/sit cue or evaluate the authenticated current occupant once on arming; never silently strand the trigger.
- Server owns timeline/generation/start time and seat identity. Late joiners receive current phase; standing/reset/duplicate events cannot restart it. Session state survives character reset.
- Suggested phases: LOCKED, READY/GATHERING, CELEBRATING, CAKE_READY, EATING/COMPLETE. Keep compatible legacy action mapping only where useful; no invite can reset completed state by accident.
- Offer a short 10-15-second local camera pan around the table with Happy Birthday, Phuong text and clear Skip/Return. Each player independently opts out; restore CameraType, subject and usable controls on skip, death, lobby entry, respawn or destruction.
- Celebrate with restrained palette-correct hearts/confetti, candle/cake presentation, shared cake cutting and visible individual slices with a simple eating/hand-to-mouth or utensil motion. Animations may be procedural and should support default rigs without requiring uploaded animations.
- Use the user's chosen Happy Birthday asset 87992648461099 for the birthday song if it loads/has permission. Preserve existing audio configuration; do not upload rejected MP3s or select unapproved music. Duck/resume background sound, provide mute/skip-safe behavior, never block progress if audio fails.
- Coordinate with PCW-26, which owns actual music playback after this ticket. Expose/document stable cake phase, generation, server start/end times and a local camera-skip signal for its MusicController; do not leave two independent birthday Sound players active. The final integrated behavior must include the song/duck/resume above, even if this ticket supplies only the timeline hook and PCW-26 supplies the sounds.
- Phuong controls normal cut/start; Andrew gets explicit recovery through PCW24. Each participant can take/eat cake once with repeatable harmless cosmetic bites, then free play/photos remain available.
- Dedupe all authoritative finale actions; friendly errors and no table-address errorText.

## Acceptance criteria

- Six petals visibly invite everyone; before unlock, sitting cannot start the finale.
- Only designated Phuong-seat occupancy starts normal celebration, once.
- Non-hosts cannot force/cancel/reset the celebration; Andrew recovery is explicit.
- Late arrival, unseat/reseat, disconnect and reset do not restart or strand phases.
- Camera Skip restores ordinary third-person control on every exit path.
- Everyone can visibly eat cake and keep exploring; audio failure cannot block the story.
- Ten-seat physical clearance and actual timeline/audio behavior are checked in final integration, not self-certified.

## Delivery rules

Read AGENTS.md, docs/tickets/README.md, this ticket, docs/design/map-proposal-v0.2.md, docs/design/visual-direction-v0.1.md, verification/README.md, and docs/coordination/release-20261003/README.md. The October 3 user instruction authorizes this implementation and supersedes older no-code/publish exclusions for this release. Use Phuong and Andrew in all prose. Existing Roblox account IDs are authoritative; do not infer permissions from display names.

Work sequentially: only the currently assigned builder may edit production source. You are not alone in this checkout; preserve other changes and do not switch branches or revert files. No Studio access, playtests, test runs, publishing, or self-approval by builders. The orchestrator reviews each handoff for completeness, then installs and tests the complete build with an independent verifier at the end. Tests may be authored when meaningful, but execution is deferred. Report incomplete work honestly.

Use the existing exact palette. Preserve the room, map, approved assets, shared six-petal structure, currency rules, session-only persistence, real friends, touch access and independent cameras. Never write the personal birthday note. Do not add NPC guests, real-money purchases, compulsory typing, timers to pad activities, or a seventh required quest.

Deliver production source, any necessary integration manifest notes, and docs/coordination/release-20261003/handoffs/PCW-XX.md (substitute your ticket number). State changed files, exact behavior, dependencies, known limits, and deferred test scenarios. Status is IMPLEMENTED_PENDING_INTEGRATION, never PASS. The orchestrator owns final status changes.


## Limits and open decisions

The ownership and delivery rules above remain binding. Preserve exact palette, real friends, six shared petals, session-only progress and user-authored personal note. Builders do not approve their own delivery. Physical device and human group evidence cannot be replaced by desktop emulation or agent opinion. Andrew delegated autonomous implementation, agent review and publication; this is scope authorization, not an invented human review of the final revision. Report actual platform blockers.

## Validation

After all sequential builders deliver, follow docs/coordination/release-20261003/WALKTHROUGH.md and PCW-25. Bind final source to Studio, run meaningful contract checks, exercise the real controls and changed world feedback, retain screenshots/console and device evidence, and obtain independent verifier findings. Map every acceptance bullet above to observed evidence or an explicit unresolved limit. Fix defects and retest; do not infer playability or fun from source checks alone. No testing executes during the implementation queue.
