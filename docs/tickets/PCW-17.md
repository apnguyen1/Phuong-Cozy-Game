# PCW-17 â€” Birthday welcome room and shared group entry

**Status:** Implementation scope authorized by the active September 26, 2026 user goal; independent review in progress. Final acceptance is pending.

**Builder:** World integration and component builders. **Reviewer:** Independent verifier, separate from builders.

## October 3, 2026 private-world amendment

The current user request supersedes timed group boarding and reserved-server transfers. This is one private server for Andre and friends, with one shared play world. Guests may stay in the birthday lobby indefinitely. Pressing E at the existing left circle (or using its touch prompt) enters Phuong’s bedroom inside her home immediately, without waiting for others. Death/reset returns to the lobby and entry can be repeated. Shared petals and activity progress remain in server memory until that server restarts; character death does not reset them. Progress HUD and Journal are hidden while in the lobby. There is no countdown, queue square, batch roster, or gameplay PlaceId requirement in this flow. Player capacity follows the experience’s configured server limit; the entry flow imposes no ten-person boarding cap. Publishing/private access remains separate.

## September 27, 2026 implementation amendment

The earlier personal countdown, per-player early-entry pad, and same-place outdoor relocation below are retained as historical Draft 02 requirements only. For the current MVP, the active behavior is one explicit opt-in existing left-hand circular portal pad in the free lobby. Anyone may wait indefinitely without joining. The first accepted member starts one server-owned 60-second deadline. When the accepted count reaches eight, the deadline becomes `min(existing deadline, serverNow + 10 seconds)`; dropping below eight never extends it, and an empty queue resets to a new generation. Capacity is ten and reaching ten never launches immediately. The server-owned countdown and occupancy appear above the circle. Stepping out removes a waiting member. The obsolete right-hand square and its sign are removed. A completed group transfer resets the lobby queue for the next group; each production group reserves a fresh gameplay server.

At expiry, only the exact frozen roster transfers together to one reserved gameplay server and arrives in the existing bedroom using ten safe arrival slots. Lobby bystanders and late entrants remain in the lobby. Production transfer uses a real configured Roblox reserved destination; the marked Studio-only local party adapter is only a playtest aid and is not teleport evidence. Real published-server, mixed-device, reconnect, failure/retry and group evidence remain required; this amendment does not mark any criterion passed.

## Purpose

Let friends first arrive in a birthday room full of Phuong's favorite things, then explicitly join one shared timed group transfer into the existing bedroom.

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
