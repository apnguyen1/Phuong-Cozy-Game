# PCW-17 — CHANGES_REQUIRED

Stage: production · Iteration 1 · 20260926T200504Z-eab81a56

## Automatic checks

- **PASS** `ticket-approved`: Approved ticket required; a draft is not an assignment
- **PASS** `palette`: {'forest': '#365744', 'sage': '#A8B995', 'cream': '#F5F0E4', 'wood': '#95674B', 'blossom': '#E8B7C6', 'brick': '#B66C68', 'golden': '#E8C779', 'ink': '#26382E'}
- **PASS** `input:docs/tickets/PCW-17.md`: Required input exists
- **PASS** `input:docs/tickets/MAP-02.md`: Required input exists
- **PASS** `input:docs/lobby02-notes.md`: Required input exists
- **PASS** `input:roblox/build-lobby02.luau`: Required input exists
- **PASS** `input:roblox/birthday-lobby.server.luau`: Required input exists
- **PASS** `input:roblox/birthday-lobby.client.luau`: Required input exists
- **PASS** `input:roblox/finalize-draft02.luau`: Required input exists
- **PASS** `input:roblox/tests/lobby-runtime-check.luau`: Required input exists
- **PASS** `input:roblox/evidence/draft02/runtime-results.json`: Required input exists
- **PASS** `input:verification/check_lobby_runtime.py`: Required input exists
- **BLOCKED** `artifact:place`: Missing or empty artifact: roblox/Phuong-Cozy-World-Draft02.rbxl
- **BLOCKED** `artifact:studio-colors`: Missing or empty artifact: roblox/evidence/draft02/lobby-studio-colors.json
- **PASS** `artifact:runtime-results`: File present; format/import correctness is an independent review gate
- **BLOCKED** `artifact:console`: Missing or empty artifact: roblox/evidence/draft02/console.txt
- **BLOCKED** `artifact:views`: Missing or empty artifact: roblox/evidence/draft02/visual-evidence.json
- **FAIL** `test:captured-engine-behavior`: {'exit_code': 1, 'log': 'verification/runs/PCW-17/20260926T200504Z-eab81a56/captured-engine-behavior.log', 'sha256': 'dae4f20fbc05ffbbd19f0dc0af99cdabdf4a731808d9cc4fa899367c2efc60c1'}

## Required review

- `ticket-match` (independent): All ticket requirements and submitted source files are covered; the assigned object/activity was built, with no substituted scope.
- `shared-scope` (independent): Preserve touch/desktop access, independent third-person cameras, real group participation, one detailed bedroom, six quests and the empty user-authored note. No invented rooms, economy, forced cinematic or guest messages. Verify dependency interfaces and that automated tests exercise the actual ticket behavior.
- `visual-identity` (independent): Compare reference and actual result. Required silhouette, proportions, named features and color placement survive simplification; readability is clear at play scale.
- `roblox-import` (independent): Import this exact revision in Roblox Studio. Record place/model identity, scale, pivot, orientation, materials/textures, collision and console results; test it in context.
- `final-acceptance` (human): The user has reviewed this exact revision and explicitly accepted it as finished. Preserve their actual decision and comments.
- `playability` (independent): In Studio Play, demonstrate start, intended actions, feedback, forgiving mistakes, completion and exit on the target controls. Inspect client/server errors.
- `replay` (independent): Test cancellation/re-entry, three repeated plays, leaving/returning and reconnect. No stuck controls, duplicate callbacks/rewards or lost committed session progress. Test cross-session saves only when PCW-13 defines them; do not invent persistence guarantees.
- `mixed-device` (independent): Complete the changed flow via touch on phone/tablet and via desktop controls. Record named devices, readable text, unobstructed move/jump/orbit zones, close/cancel and busy/error states.
- `shared-session` (independent): Use at least two clients: simultaneous actions, competing slot, disconnect, reservation release, late join and one reward only. Cameras stay independent; Phuong finishing permissions hold. For PCW-16 rehearse with 8-10 participants on named devices.
- `fun` (human): User playtest: was the goal clear, did choices/actions feel satisfying, was pacing comfortable, and would you replay? Record duration, enjoyable moment, friction and requested change. User decides whether it is good enough.
- `PCW-17-AC01` (independent): A fresh player first spawns safely inside the decorated enclosed room, with Happy 24th Birthday, Phuong visible and readable.
- `PCW-17-AC02` (independent): Birthday decorations and favorite-things displays furnish the room; eight seats and a clear central walking route remain usable.
- `PCW-17-AC03` (independent): A visible personal countdown starts at 60 seconds and decreases toward automatic world entry.
- `PCW-17-AC04` (independent): At expiry, that player relocates to outdoor arrival, remains movable and no longer sees the lobby countdown HUD.
- `PCW-17-AC05` (independent): A clearly explained prompt at the pad permits early entry; remote or out-of-room triggering cannot move a player.
- `PCW-17-AC06` (independent): Each player has an independent deadline and transition state; one player's early entry cannot transport another player or change their deadline/camera.
- `PCW-17-AC07` (independent): Reset before entry creates one fresh countdown; an old character loop cannot move the replacement early or duplicate UI.
- `PCW-17-AC08` (independent): Reset after world entry returns to the world without a new lobby timer; disconnect cleanup and late join behave independently.
- `PCW-17-AC09` (independent): Seated expiry releases the seat and moves a usable character without transporting furniture; prompt/expiry races do not duplicate transitions.
- `PCW-17-AC10` (independent): At least two actual clients demonstrate simultaneous presence, separate cameras, early entry, late join and reconnect; eight-player placement uses distinct available slots.
- `PCW-17-AC11` (independent): Desktop and touch users can read countdown, discover/activate pad, move and orbit without UI obstruction.
- `PCW-17-AC12` (independent): Installed runtime source parses, matches saved source, keeps deadline/destination server-owned and passes meaningful behavior checks, with no new errors in the changed flow.
- `PCW-17-AC13` (independent): Authored room/UI colors conform to the palette, and the saved place contains this reviewed lobby revision.
- `PCW-17-scope` (independent): Deliverable: A decorated enclosed spawn room, eight guest seats, exact greeting Happy 24th Birthday, Phuong, favorite-things displays, discoverable teleport pad, visible 60-second per-player countdown, server-controlled same-place relocation, independent third-person camera framing and persisted builder/server/client sources. Include actual behavioral checks and Studio client/server evidence.
Limits/open decisions: This moves players between two regions in one place and needs no published destination. Favorite-things tables are decorative, not new quests. No purchases, forced cinematic, invented guest messages or birthday note are added. Rejoin is a fresh server visit; no cross-session lobby persistence is promised. Human clarity, pacing, enjoyment and exact-revision acceptance remain pending.
Validation: Run the actual server-source behavior checks in Studio, then observe real early prompt entry, one unshortened 60-second expiry, seated expiry, reset on both sides, repeated entry, late join and disconnect/rejoin. Use two clients and touch plus desktop input; record outcomes/console. Compare installed/saved code, independently capture live palette, review player-height screenshots and bind the saved artifact before finalization.

Fix failed checks, gather missing evidence, then create a new iteration. READY_FOR_REVIEW is not final acceptance.
