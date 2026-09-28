# Task 09 foundation audit — current merge ledger

## Current verdict

Task 09 is **source-present and CLI-verified, but not complete as a primary-place foundation merge**. The merge ledger currently records only the Main bedroom-arrival fix as `SAVED_PRIMARY`; it does not record a Task 09 foundation import/save. Do not mark Task 09 complete merely because the repository modules exist or the adapter suite passes.

## What exists in reviewed source

- `roblox/mvp/shared/Config.luau`: shared activity IDs, reward/Q05 constants, and configured Phuong/host IDs.
- `roblox/mvp/server/SessionService.luau`: session-only fund/petal/round/receipt state, replay rewards, presence, and atomic purchase boundary.
- `roblox/mvp/server/CakeService.luau`: six-petal gate plus invite/cancel/cut/eat state.
- `roblox/mvp/client/Main.client.luau`: shared flower/fund HUD, journal/view rendering, authoritative snapshot handling, and cake/result display paths.
- `roblox/mvp/CONTRACT.md` and `INTEGRATION.md`: canonical session/action/receipt and cake permissions boundary.
- Current CLI evidence: focused host-policy SessionService/CakeService/Q05 coverage and the supported adapter suite pass **9/9**. This remains source/module evidence, not primary-place or gameplay evidence.

## What the ledger proves was imported

The current `verification/mvp/merge-progress.json` proves only `ServerScriptService.PhuongMVP.server.Main` was saved to the primary place by the recorded Main-fix operation. It does not prove that Config, SessionService, CakeService, the client HUD, remotes, or the finale objects were imported and saved in the primary place. Those require a separate per-feature merge record and source/class/disabled-state verification.

## Still pending before Task 09 foundation can be called merged

1. Import and save the shared Config, SessionService, CakeService, client HUD, and required remotes into the primary copy, with exact target paths and source hashes recorded.
2. Confirm runtime `Main` uses the imported shared services and that both configured birthday hosts, Phuong-specific spending/finalization fallback, disconnected rejection, and guest eating policy are wired in the installed tree.
3. Install and validate the six-petal/fund HUD in the real client path; source presence does not prove readable touch/desktop layout.
4. Install/validate the finale patio, cake interaction footprint, voluntary arrival cue, and post-cut free-play geometry. These are not delivered by the three kernel modules.
5. Run the first engine smoke after merge: six-petal gate, both-host invite/cancel/cut, disconnected/guest rejection, post-cut eating, and snapshot/reconnect visibility. Only then can the Task 09 foundation be handed to independent play verification.

The personal birthday note remains empty and user-authored. No note text is part of this foundation audit.
