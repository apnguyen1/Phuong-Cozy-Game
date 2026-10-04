# Q04 — One More Chapter: reading under Quad blossoms

Status: implementation-ready design draft only. This document does not authorize Roblox implementation, Studio edits, publishing, or final content approval.

## Scope and authority

Q04 is an asynchronous reading-and-annotation activity at the existing UW-inspired Quad blossom benches. The Quad’s current cross, diagonal paths, interior trees, lawns, and route geometry remain unchanged. The two benches are off circulation and face usable lawn/space; surrounding trees and environmental polish belong to task 12. The bedroom Kindle remains an optional second access point at the existing desk/bedroom display area, not a replacement for the Quad activity.

Confirmed requirements from PCW-10: three short original passages, each 50–80 words; three highlight choices; four reactions; three bookmark styles; optional typing; partial work survives dismissal; no quiz, synchronized reading, precision-only selection, forced keyboard, or shared camera. Final passage wording and any book/title labels require content review. Do not generate or paraphrase the user-authored birthday note.

The queue, shared fund, six-petal progression, and session lifetime follow the September 27 coordination packet. Its numeric reward defaults are proposals, not separately approved facts: the first completed Q04 earning round adds 20 to the shared birthday fund once; a later explicit completed Q04 round adds 10 once. The amount is one server-side round reward, never multiplied by player count.

## Content package (content briefs, not final prose)

Provide three original, spoiler-free passages, each independently readable in approximately 50–80 words. They should be warm, specific, and suitable for a birthday exploration game without inventing biographical facts about Phuong. A content reviewer supplies the final text and confirms title/attribution labels. Suggested briefs:

1. **Small worlds:** a quiet observation about how a tiny object, room, or handmade place can hold a large feeling. Avoid naming a real book or claiming a personal memory.
2. **Night pages:** a gentle passage about reading late, noticing one comforting detail, and choosing to continue or pause. No sleep requirement and no forced “waking” story.
3. **The next chapter:** an optimistic, non-spoiler reflection on friends sharing a moment while each person keeps their own pace. Do not turn this into a romantic message or the user’s personal note.

Each passage has a stable `passageId`, revision, word-count check, and accessibility label. The client displays one passage at a time with a clear passage title only after content approval. Reading a passage is not a correctness test.

## Player sequence and states

### Entry

1. A player walks to either the Quad reading bench or the optional bedroom Kindle and sees a generous contextual action: **Read**. The approach must remain possible from the main cross and diagonals without crossing the bench footprint.
2. Read opens only that player’s panel and camera state. Other players retain movement, free third-person camera rotation, and their own activity panels.
3. The server creates or restores a player-local Q04 draft for the current birthday `sessionId`, keyed by `activityId=Q04` and `passageId`. Opening does not award a petal or fund reward.

### Reading and annotation

4. The panel presents readable cream-on-ink/ink-on-cream text, passage progress, and **Close**. It must scroll without tiny drag precision; page-sized tap controls are acceptable.
5. The player chooses at most three highlights from large, pre-authored phrase/segment choices. Tapping a choice toggles it; the selected state uses outline, check, and label, not color alone. No freehand text selection is required.
6. The player may choose one of four reactions: **Moved**, **Cozy**, **Curious**, or **Made me smile**. These are personal annotations, not a group vote and not a quiz answer.
7. The player may choose one of three bookmark styles: **Ribbon**, **Pressed flower**, or **Star tab**. The bookmark is a personal saved state; it does not reserve the bench or close another reader’s panel.
8. An optional note field accepts typing on desktop and mobile. The player may leave it blank. On phone, the keyboard must not hide the active field, Save, or Close; the panel can scroll/reposition while the keyboard is open. No keyboard is required to finish.
9. **Save** submits a deduplicated snapshot. A visible saved receipt gives the player confidence without clearing the panel. **Close** autosaves the latest valid partial state before dismissal; Cancel/escape from an unsaved note asks whether to keep or discard only that local edit.

### Completion and replay

10. A personal read is complete when the player has opened a passage, selected at least one highlight, selected one reaction, and selected one bookmark. The optional note is never required. The server returns an `acceptedStep` and `completionReceipt` for that player and passage.
11. Any one or more completed personal reads can contribute to the current shared Q04 reward round. The server opens one `roundId` for the activity/session. The first accepted contribution(s) may arrive concurrently; a server transaction marks the round reward as paid exactly once. It does not pay 20 per player and does not require all eight or ten participants.
12. After the round is paid, later readers see **Round complete — read again or help elsewhere**. They can still finish a personal read, revise their bookmark/note, and receive personal contribution acknowledgement, but resaving cannot pay again.
13. Explicit **Start next reading round** is available only after the current round has a paid receipt and the player chooses replay. It creates a new `roundId`; it does not erase other players’ drafts or prior receipts. A later round’s proposed reward is 10 once.

## Concurrent roles and safety

Ten players may be in the Quad while Q04 is active. Each bench supports one local interaction position per player-facing side only if the measured model permits it; otherwise players queue visually in the surrounding clear space without holding a station reservation. The activity must never lock both benches or the Quad crossing. At least four players should be able to read independently across both benches, Kindle, and nearby exploration space; the remaining players can do other quests.

Every client action includes `sessionId`, `activityId`, `roundId` when applicable, `passageId`, `actionId`, `contributorId`, and expected draft revision. The server rejects stale revisions safely and returns the latest draft. Duplicate Save, double-tap, retry after latency, and simultaneous contributors resolve to one accepted action and one reward transaction. A player disconnecting releases only their local interaction slot; their accepted completion and valid draft remain in the running session. A rejoin restores session state, not a new lobby timer. A new/restarted birthday session starts fresh.

No Q04 action spends personal coins, transfers inventory, closes other readers, or pays a per-player reward. The server, not the client, owns the once-only petal and fund receipt. Q04’s petal is awarded once when the shared progression contract accepts the activity’s first eligible completion; further Q04 replays cannot create a second petal.

## Locations, footprint, and visual treatment

Required proposed anchors are `Q04QuadReading` and `Q04BedroomKindle`; task 01 owns final anchor placement. At the Quad, preserve the existing cross, diagonal panels, perimeter paths, interior trees, sightlines, and destination approaches from PCW-06. Place benches outside the through-path with a clear approach and a camera-facing open side; do not add trees inside routes or move the interior blossom planting. Exact offsets, collision bounds, seat orientation, and clearance must be measured from the current Studio scene rather than copied from provisional map coordinates.

The bedroom Kindle uses the existing desk/display relationship and must preserve the 12–16 stud room circulation strip and desk approach. It is an alternate interaction point, not a second Q04 station with separate progress. A player may begin on Kindle and continue at a Quad bench using the same session draft.

Use the approved palette only: forest `#365744`, sage `#A8B995`, cream `#F5F0E4`, wood `#95674B`, blossom `#E8B7C6`, brick `#B66C68`, golden `#E8C779`, ink `#26382E`. Suggested roles are brick path, wood bench, cream panel, ink text, forest action/selected emphasis, and golden saved/completion accent; final authored parts and UI require the palette gate. Detailed community-tree texture exceptions remain limited to the existing PCW-06 scope and do not exempt Q04 UI or bench materials.

## Controls and accessibility

Touch: tap the contextual **Read** action, tap large phrase cards, reaction cards, bookmark cards, Save, and Close. Scroll by a forgiving swipe or page buttons. Desktop: same labeled actions via mouse and keyboard equivalents; optional focus order is Read → passage → highlights → reaction → bookmark → note → Save → Close. No hover-only affordance, right-click, tiny mesh tap, precision drag, or simultaneous input is required.

Phone landscape is the current layout proposal; tablet uses extra width without shrinking controls. Reserve Roblox movement/jump and camera-drag zones when the panel is closed. When open, keep a visible close button, readable line length, high contrast, and a compact panel that does not require changing the player’s camera. Test keyboard avoidance, safe-area insets, focus visibility, and screen-reader-compatible labels where Roblox UI support permits.

## Cancellation, error, reconnect, and replay rules

- Close after a valid autosave restores exploration and preserves partial highlights, reaction, bookmark, and note draft.
- Discard explicitly removes only the current unsaved local edit; it does not erase the last server-saved draft.
- Network failure leaves the panel open with **Not saved — Retry**. Retry reuses the same `actionId`; it cannot duplicate a receipt or reward.
- A disconnect during reading restores the latest acknowledged draft on rejoin. A disconnect during reward payment resolves from the server receipt before allowing another attempt.
- If a passage revision is incompatible with an old draft, preserve the old draft as read-only history and ask the player to start the current passage; do not silently rewrite text.
- A player can replay after the round is explicitly reopened. Replaying must not reset another reader’s partial work, accepted contribution, personal note, or bookmark.
- If the activity is unavailable, the contextual action is disabled with a readable reason and the player can use the other station or continue exploring.

## Interfaces and dependencies

Depends on PCW-02 for shared mobile/desktop panel states and touch-safe composition; PCW-06 for the existing Quad geometry, benches, blossom routes, and Studio evidence; PCW-04 for the bedroom Kindle/desk anchor; PCW-13 (superseded/needs alignment) and task 09 for session progression, shared fund, petals, receipts, and deduplication; PCW-16 for mixed-device/group rehearsal; PCW-15 for final content and accessibility review. Task 01 must provide measured anchor/clearance names. Task 09 owns canonical field/state semantics; Q04 should consume them rather than define a private wallet or reward system.

Suggested Q04 contract calls are `OpenDraft`, `PatchDraft`, `SaveDraft`, `CompleteRead`, `StartNextRound`, and `GetRoundReceipt`. Responses must include accepted/rejected status, current revision, `completionReceipt` when earned, and `fundRewardReceipt`/`petalReceipt` only when the shared contract actually grants them. `fundRewardReceipt` is unique per `sessionId + activityId + roundId`; `petalReceipt` is unique per session and Q04.

## Acceptance scenarios for later verification

1. **Solo bench read:** one player opens a passage, selects one highlight, one reaction, one bookmark, leaves note blank, saves, and closes. Expected: readable completion receipt; no quiz; no camera change; Q04 accepted step appears.
2. **Phone partial work:** on a representative phone, player selects two highlights, types part of a note, dismisses the panel, and returns. Expected: partial state survives; keyboard never hides required controls; no typing is required to complete.
3. **Independent readers:** two players read different passages while a third walks through the Quad. Expected: each panel/draft/camera is independent; no synchronized page, forced camera, or blocked path.
4. **Three choices/four reactions/three bookmarks:** each option is reachable with touch and desktop input and has a non-color-only selected cue. Expected: all choices save with correct IDs.
5. **Concurrent reward:** eight players submit valid completions near-simultaneously. Expected: one Q04 round reward, one eligible Q04 petal, no per-player multiplication, no duplicate payout on retries/resaves.
6. **Replay:** after the first receipt, a player explicitly starts the next round. Expected: new round identity; prior drafts and receipts remain; later proposed reward is paid once only after an eligible completion.
7. **Disconnect/rejoin:** disconnect during save and rejoin the same server. Expected: latest acknowledged draft and any completed/reward receipts restore; no new lobby timer and no second payment.
8. **Crowded Quad:** ten avatars traverse the cross while readers use both benches. Expected: primary routes, camera sightlines, collision, and bench approaches remain usable; no station locks the crossing.
9. **Bedroom alternate:** start on Kindle, close, then finish at a Quad bench. Expected: same session draft and completion semantics, no duplicate activity or separate reward.
10. **Invalid actions:** stale revision, duplicate action ID, missing passage, and late reward retry. Expected: safe rejection or idempotent success with current state; no lost accepted work and no extra petal/fund.

These scenarios are design targets, not evidence of a working Roblox build. Later evidence must include Studio import/play tests, server/client logs, phone/tablet/desktop captures, 8–10-player rehearsal, low-graphics route checks, and an independent reviewer. Human readability, comfort, pacing, and fun remain user-playtest gates.

## Required downstream updates before implementation

- PCW-10: replace its broad “Kindle and reading/annotation” wording with the three-passage, 3-highlight/4-reaction/3-bookmark, optional-note, partial-save, independent-reader, and shared-round rules above.
- PCW-02: add Q04 panel states for saved, partial, retry/error, stale revision, keyboard-visible, and round-complete; specify focus order and touch-safe phone layouts.
- PCW-06: bind `Q04QuadReading` to measured off-route bench positions and preserve the current Quad geometry/interior tree rule.
- PCW-04: bind `Q04BedroomKindle` to the existing desk/display without adding a room or separate progression.
- PCW-13 and its verifier contract: retire any personal-wallet/per-player reward assumptions and encode one shared fund reward, one Q04 petal, session-only persistence, contributor acknowledgements, and idempotent receipts.
- PCW-15: add final passage word-count/content review, stable IDs, accessibility labels, and explicit exclusion of the user-authored personal note.
- PCW-16 and Q04 verification contract: add mixed-device independent reading, ten-avatar route safety, concurrent reward, replay, disconnect, stale-action, and alternate-location scenarios. Keep Studio/device/group/fun gates separate from document review.

## Bounded later implementation checklist

1. Measure current Quad bench candidates and bedroom desk/Kindle space; record anchors, collision, approach, camera sightlines, and route clearances.
2. Approve the three passages and labels; reject spoilers, invented personal facts, and any personal-note content.
3. Freeze shared Q04/session/receipt fields with task 09 and update tickets/contracts before scripting.
4. Build the smallest panel: readable text, three highlight choices, four reactions, three bookmarks, optional note, Save/Close/error states.
5. Implement server validation and idempotent draft, completion, petal, and shared-fund receipts; test concurrent requests and rejoin.
6. Add the alternate Kindle entry point using the same draft and round state.
7. Run independent build → verification → mixed-device/group playtest → revision → retest, including low graphics and ten-player Quad traversal.

## Evidence limits and unresolved choices

No current Studio measurement, live place import, Roblox device run, multiplayer rehearsal, final passage text, target phone model, or human readability/fun result is available in this draft. The exact bench side/orientation, number of simultaneous seat positions, final UI dimensions/orientation behavior, passage titles, and whether a round requires one or a configurable threshold of eligible contributors remain implementation/content decisions. The shared-round defaults above are proposed coordination defaults and must be confirmed in the canonical progression contract before production approval. Q04 is not READY_FOR_REVIEW or approved merely because this document is complete.
