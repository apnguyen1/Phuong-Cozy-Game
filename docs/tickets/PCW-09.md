# PCW-09 — Q03 — A Tiny World of Her Own

**Status:** MVP implementation authored; Studio installation and independent evidence pending  
**Priority:** P2 — after foundation  
**Suggested owner:** Activity design (unassigned)  
**Dependencies:** 02; 04; 05; 13  
**Owned scope:** Shared miniature at desk and fair craft booth

## Purpose

Let friends contribute to one miniature without crowding the bedroom.

## Deliverable

Part/socket list, tap placement flow, booth-to-home relationship, final display state.

## Acceptance criteria

- Desk and booth contribute to the same miniature.
- No duplicate quest reward.
- Slots visibly reserved while used and released on cancel/disconnect.
- Final miniature remains in her room.
- Six canonical pieces are validated server-side: rug, chair, bookcase, side table, plant, and lamp.
- Rotation is limited to quarter turns; incompatible piece/socket requests and duplicate actions are rejected or replay their prior receipt.
- Per-socket reservations support simultaneous different pieces, conflict resolution, cancel, disconnect release, and 15-second inactivity expiry.
- Booth and bedroom desk read the same session miniature; completion emits one Q03 receipt, one petal, and one shared-fund reward through the common session contract.
- Phuong finalizes an allow-listed lamp presentation; configured host fallback is permitted only by the shared session permission contract.

## Limits and open decisions

Curated placements, not a full furniture editor. Booth does not create a seventh quest.

## Validation

Later simultaneous booth/desk placement, conflict and rejoin checks.

## MVP implementation boundary

The authored implementation is limited to `roblox/mvp/server/activities/Q03.luau`, `roblox/mvp/builders/Q03Station.luau`, the Q03 client descriptor, Q03 native parts, and Q03 tests. It does not install into Studio, publish, own shared session/reward logic, or replace the crossing/bedroom anchors. The shared contract at `roblox/mvp/CONTRACT.md` is authoritative; all reward and petal changes go through `SessionService`.

Studio import, route clearance, pivots, collision, mobile/desktop controls, ten-player behavior, reconnect in a live server, and human-fun review remain evidence-gated. The former personal-wallet/gifting wording in historical Q05/Q13 planning does not apply to Q03 MVP; Q03 uses the shared birthday fund and session-only state.
