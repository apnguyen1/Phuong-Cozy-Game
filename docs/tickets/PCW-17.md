# PCW-17 — Birthday welcome room and timed world entry

**Status:** Implementation scope authorized by the active September 26, 2026 user goal; independent review in progress. Final acceptance is pending.

**Builder:** World integration and component builders. **Reviewer:** Independent verifier, separate from builders.

## Purpose

Let friends first arrive in a birthday room full of Phuong's favorite things, with a visible personal countdown and optional early-entry pad leading into the existing world.

## Deliverable

A decorated enclosed spawn room, eight guest seats, exact greeting Happy 24th Birthday, Phuong, favorite-things displays, discoverable teleport pad, visible 60-second per-player countdown, server-controlled same-place relocation, independent third-person camera framing and persisted builder/server/client sources. Include actual behavioral checks and Studio client/server evidence.

## Acceptance criteria

- A fresh player first spawns safely inside the decorated enclosed room, with Happy 24th Birthday, Phuong visible and readable.
- Birthday decorations and favorite-things displays furnish the room; eight seats and a clear central walking route remain usable.
- A visible personal countdown starts at 60 seconds and decreases toward automatic world entry.
- At expiry, that player relocates to outdoor arrival, remains movable and no longer sees the lobby countdown HUD.
- A clearly explained prompt at the pad permits early entry; remote or out-of-room triggering cannot move a player.
- Each player has an independent deadline and transition state; one player's early entry cannot transport another player or change their deadline/camera.
- Reset before entry creates one fresh countdown; an old character loop cannot move the replacement early or duplicate UI.
- Reset after world entry returns to the world without a new lobby timer; disconnect cleanup and late join behave independently.
- Seated expiry releases the seat and moves a usable character without transporting furniture; prompt/expiry races do not duplicate transitions.
- At least two actual clients demonstrate simultaneous presence, separate cameras, early entry, late join and reconnect; eight-player placement uses distinct available slots.
- Desktop and touch users can read countdown, discover/activate pad, move and orbit without UI obstruction.
- Installed runtime source parses, matches saved source, keeps deadline/destination server-owned and passes meaningful behavior checks, with no new errors in the changed flow.
- Authored room/UI colors conform to the palette, and the saved place contains this reviewed lobby revision.

## Limits and open decisions

This moves players between two regions in one place and needs no published destination. Favorite-things tables are decorative, not new quests. No purchases, forced cinematic, invented guest messages or birthday note are added. Rejoin is a fresh server visit; no cross-session lobby persistence is promised. Human clarity, pacing, enjoyment and exact-revision acceptance remain pending.

## Validation

Run the actual server-source behavior checks in Studio, then observe real early prompt entry, one unshortened 60-second expiry, seated expiry, reset on both sides, repeated entry, late join and disconnect/rejoin. Use two clients and touch plus desktop input; record outcomes/console. Compare installed/saved code, independently capture live palette, review player-height screenshots and bind the saved artifact before finalization.
