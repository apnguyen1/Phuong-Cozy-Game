# PCW-10 — Q04 — One More Chapter

**Status:** MVP implementation in progress; evidence-gated  
**Priority:** P2 — after foundation  
**Suggested owner:** Activity/UI design (unassigned)  
**Dependencies:** 02; 04; 06; 13  
**Owned scope:** Kindle and reading/annotation experience

## Purpose

Celebrate her reading habit in a relaxed mobile interaction.

## Deliverable

Readable Kindle panel, phrase selection, reaction/bookmark choices, optional note field and room/bench access.

## Acceptance criteria

- No synchronized reading.
- Text readable on phones.
- Annotation never requires precision selection or keyboard typing.
- Other players keep their cameras.
- Partial work survives dismissal.

## Limits and open decisions

No quiz, spoilers or invented book-title corrections. Final passage and exact reading status require content review.

## Validation

Later small-screen reading, keyboard covering, cancel and alternative-spot checks.

## Execution boundary

Ticket creation is authorized. Implementation, scripting, Studio building and publishing are not started in this task. The user explicitly requested no code. Follow the [approved map](../design/map-proposal-v0.2.md) and [visual brief](../design/visual-direction-v0.1.md); measurements remain test targets.

## September 27 MVP amendment

The current implementation authority is `roblox/mvp/server/activities/Q04.luau`, with station/UI descriptors in `roblox/mvp/builders/Q04Station.luau` and `roblox/mvp/client/activities/Q04.luau`. Q04 is asynchronous at measured off-route Quad blossom benches, with the existing bedroom Kindle as an alternate entry point using the same session draft. It preserves the Quad cross, diagonal paths, interior trees, route clearance, independent third-person cameras, and optional typing.

The MVP content contract is three provisional original passages of 50–80 words, three phrase/highlight choices, four reactions, three bookmark styles, and an optional note. A player must save at least one highlight, one reaction, and one bookmark to complete; notes and typing are never required. Partial drafts survive close, reconnect, and alternate-location continuation. No quiz, synchronized reading, forced camera, precision selection, or closure of another reader is allowed.

One server-owned Q04 round accepts independent readers. The first eligible completion closes that round and calls the shared session completion primitive for one Q04 petal and one shared-fund reward; retries, reopening, resaving, and simultaneous saves cannot pay again. Any participant may explicitly start a later replay after completion; prior drafts and receipts remain and old saved content cannot silently complete the new round. Reward amounts and receipt semantics are governed by `roblox/mvp/CONTRACT.md` and remain evidence-gated.

This amendment authorizes source implementation only. Live Studio installation, actual anchor measurement, touch/tablet/desktop play, concurrent 8–10-player behavior, reconnect evidence, low-graphics route checks, accessibility, human readability/fun review, and final passage approval remain required gates. The previous execution-boundary text is retained as historical context and is superseded only for this scoped MVP implementation.
