# PCW-26 - Birthday lobby and gameplay background music

**Status:** DELIVERED_PENDING_INTEGRATION. **Requested:** October 3, 2026 follow-up. **Order:** after PCW-24, before final PCW-25 verification. **Builder:** cozy_music.

## Authority and inputs

Andrew explicitly added the task from chat 01a102c3-0ad2-7f41-9b11-586163d89e6c to this release. That chat supplied lobby birthday audio 87992648461099 and proposed Creator Store gameplay candidates. Current installed source contains CozyAudio and CozySoundEffectsClient plus four effects under SoundService.CozySoundEffects. Preserve these.

Andrew selected Gentle acoustic guitar - Slow Mornings in this chat. Use Slow Mornings Folk Guitar Instrumental, asset139568344220252. Candidate metadata was found, but actual audio quality/permission is unverified until final audition. Do not call it auditioned.

## Ownership

A new client AudioController or MusicController; shared AudioConfig; existing live audio sources copied/preserved into source files; minimal Main/client/finale extension hook integration. Do not change environment, currency, host IDs or external asset permissions. Never upload rejected MP3s.

## Required reading

AGENTS.md; docs/tickets/README.md; this ticket; map-proposal-v0.2.md; visual-direction-v0.1.md; verification/README.md; docs/coordination/release-20261003/README.md; PCW-23 handoff and exported baseline audio sources.

## Purpose

Implement Birthday lobby and gameplay background music for the October 3 birthday release, preserving the authorized shared game and the detailed requirements below.

## Deliverable

1. One local listener/controller per client; music follows BirthdayLocation. Lobby plays birthday song87992648461099 at modest volume; world plays the selected gameplay instrumental, looping quietly.
2. Smooth short crossfade on entry/return; never overlap full-volume tracks or repeatedly restart on unrelated attribute/snapshot updates. Clean up all sounds/connections on shutdown.
3. Cake timeline ducks/stops gameplay and starts the birthday song in sync with server start time. Use the actual PCW23 phase/generation data. Late join seeks appropriately when loaded; return to gameplay after celebration. Prevent duplicate birthday playback between PCW23 and this controller.
4. Provide obvious music mute/unmute and volume controls on touch/desktop; session-local preference survives character respawn and is respected during cake. Sound effects can have separate toggle or follow a clearly named sound option.
5. Graceful bounded loading: inspect IsLoaded and handle preload failure without infinite waits or gameplay delays. Missing/unauthorized audio gives a quiet fallback and host-readable status, never repeated console spam. Do not substitute guessed asset IDs.
6. Preserve soft click/chime/Jasper sound effects and the existing accepted-action audio hook. Source modules must not WaitForChild forever if a sound container is absent; fallback setup may create exact known-ID templates.
7. Root final testing auditions lobby, gameplay, crossfade and finale and confirms sound load permission in the published experience where possible. The builder does not run tests/Studio or claim permission based only on metadata.
8. No request to import the Pomeranian model is included in this audio ticket; that separate chat mention is context only.

## Acceptance criteria

- Lobby and gameplay use distinct specified tracks with no overlapping loud playback or reset loops.
- Cake music is synchronized once and respects mute/volume and Skip; it resumes correctly afterward.
- UI is understandable and usable on phone/tablet/desktop; no music control blocks movement.
- Existing effects continue and no new audio path blocks server startup or quest progress.
- Approved assets actually load in final tested context, or the exact external permission/moderation blocker is reported.
- No rejected music upload, invented consent/rights claim, or silent switch to unrelated music.
- Handoff records file/module paths, configured IDs and untested audition/permission limits.

## Sequential delivery

You are not alone in the codebase. Preserve previous agents' source and do not revert or switch branches. Do not spawn agents or access Studio/save/publish. No tests until final PCW25. Deliver docs/coordination/release-20261003/handoffs/PCW-26.md with IMPLEMENTED_PENDING_INTEGRATION and exact checks remaining. Never self-approve.


## Limits and open decisions

The ownership and delivery rules above remain binding. Preserve exact palette, real friends, six shared petals, session-only progress and user-authored personal note. Builders do not approve their own delivery. Physical device and human group evidence cannot be replaced by desktop emulation or agent opinion. Andrew delegated autonomous implementation, agent review and publication; this is scope authorization, not an invented human review of the final revision. Report actual platform blockers.

## Validation

After all sequential builders deliver, follow docs/coordination/release-20261003/WALKTHROUGH.md and PCW-25. Bind final source to Studio, run meaningful contract checks, exercise the real controls and changed world feedback, retain screenshots/console and device evidence, and obtain independent verifier findings. Map every acceptance bullet above to observed evidence or an explicit unresolved limit. Fix defects and retest; do not infer playability or fun from source checks alone. No testing executes during the implementation queue.
