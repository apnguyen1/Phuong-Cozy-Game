# Merge checkpoint audit — 2026-09-27

This is an independent filesystem-metadata audit of the primary and named checkpoints. It does not edit `verification/mvp/merge-progress.json`, inspect Studio memory, prove byte identity, or establish gameplay readiness.

| File | Bytes | Observed LastWriteTime UTC | Truthful stage label |
|---|---:|---|---|
| `roblox/phuong-cozy-game.rbxl` | 1,718,440 | 2026-09-27 22:56:07 | Current filesystem state; feature attribution not independently proven |
| `roblox/checkpoints/phuong-cozy-game-before-main-fix-20260927-1531.rbxl` | 1,717,069 | 2026-09-27 22:41:22 | Pre-Main-fix label; historical Studio save time unknown |
| `roblox/checkpoints/phuong-cozy-game-post-main-20260927-1542.rbxl` | 1,717,088 | 2026-09-27 22:44:28 | Post-Main label; historical Studio save time unknown |
| `roblox/checkpoints/phuong-cozy-game-post-Q02-20260927-1556.rbxl` | 1,718,440 | 2026-09-27 22:56:22 | Post-Q02 label; historical Studio save time unknown |

The primary currently has the same byte length as the post-Q02 checkpoint. That does not prove byte identity or that every claimed feature is present. The merge ledger's embedded historical timestamps are therefore treated as claims requiring their own evidence, not as observed save times. An adjacent Q02 lock file exists; this audit makes no ownership or completion inference from it.

Task 09 remains source-present but not independently proven as a primary-place merge. No Studio or gameplay conclusion follows from this metadata audit.
