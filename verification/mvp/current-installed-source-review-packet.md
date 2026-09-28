# Current installed-source review packet — 31-entry revision

## Ready state

This packet is prepared for a later narrow read-only Studio lease. No Studio access, play, save, or source comparison was performed for this packet. The current bundle has **31 manifest entries** and the current bundle SHA is `A2C8C5F10FCE67F5B3D4D962A54259AF3485DABDA36675D28D5E25511B108BD0`.

Executable helper: `verification/mvp/verify_installed_source.luau`, generated from the bundle XML by `generate_source_equality_verifier.py`. It embeds all 31 expected payloads, checks actual class and raw `Source` equality, separately reports CRLF-normalized-only matches, and prints only compact mismatch lines. The corrected decoder passed a standalone round-trip for **31/31 payloads**; local Luau compile passed. Current helper SHA-256 is `31F19162534B6B3B82C95698C5ACA5738438D1EF781A79677E37EC080C1673C9`; decoder SHA-256 is `31C5E7F564DBE21876D6CFC6C3218567C778C625F5519F27BF335C3175568E4C`. These are read-only verifier files and must not be installed into the place.

The merge ledger is not a complete installation proof: it records Main, installer support, Q02, and Q03 stages, while Q01 is explicitly rolled back. Its primary byte/timestamp claims also differ from the independent filesystem audit. Treat feature status as ledger-reported until exact installed `Source` comparison and per-feature checkpoint evidence exist.

## Exact expected mounts

| Expected target | Class |
|---|---|
| `ReplicatedStorage/PhuongMVP/shared/Anchors`, `Config` | ModuleScript |
| `ServerScriptService/PhuongMVP/shared/Anchors`, `Config`, `MeasuredInstallOptions` | ModuleScript |
| `ServerScriptService/PhuongMVP/server/SessionService`, `CakeService`, `QueueService`, `TeleportAdapter`, `LocalPartyTransferAdapter` | ModuleScript |
| `ServerScriptService/PhuongMVP/server/activities/Q01` through `Q06` | ModuleScript |
| `ServerScriptService/PhuongMVP/server/Main` | Script |
| `StarterPlayer/StarterPlayerScripts/PhuongMVPClient` | LocalScript |
| `ServerStorage/PhuongMVPTools/install` | ModuleScript |
| `ServerStorage/PhuongMVPTools/build-world` | Script |
| `ServerStorage/PhuongMVPTools/builders/Q01Station` through `Q06Station`, `CakeFinale`, `LobbyQueue`, `SeattleBoundary`, `NightLighting`, `GrassDecoration` | ModuleScript |

The verifier must read actual `Source` text for every target and compare it to the corresponding bundle XML `ProtectedString` payload. Attributes, counts, names, and source hashes alone are insufficient. Record class, Disabled state where applicable, raw equality, and CRLF→LF-normalized equality separately. `Main` requires sibling server services and `ServerScriptService/PhuongMVP/shared`; the client requires `ReplicatedStorage/PhuongMVP/Action`.

## Bounded runtime smoke after source equality

With all runtime entrypoints still disabled until the controlled smoke gate:

1. Verify remotes `Action`, `View`, and `QueueState`, exact service hierarchy, legacy-handler disabled states, and missing-anchor diagnostics.
2. Enable only the reviewed MVP entrypoints for the smoke window; capture console output and revert/disable after the bounded run.
3. Exercise lobby join/leave, eight-player shortening, cap ten, frozen roster, transfer response, and no immediate personal teleport.
4. Verify bedroom arrival slots, independent camera/UI bootstrap, snapshot/journal/view requests, and one server-validated Q01 contribution.
5. Exercise Q01–Q06 one at a time through the real router: create/view, accepted action, duplicate action, completion receipt, petal/fund mutation, and rejection for bad proximity/authority.
6. Verify Q05 selected wanted figure, spend authorization, fifth-roll guarantee path, atomic receipt, reconnect-visible result, and no Q05 earning fund reward.
7. Verify six-petal cake lock, both configured host controls, Phuong-specific fallback while absent, stranger/disconnected rejection, voluntary cut, and post-cut eligible eating.

Mark each assertion `executed-pass`, `executed-fail`, or `not-executed`; source/import equality is never a gameplay PASS.

## Current missing evidence

- Exact installed `Source` equality for all 31 objects.
- Truthful per-feature primary/checkpoint mapping after the Q01 rollback and subsequent Q02/Q03 stages.
- Engine smoke with runtime entrypoints enabled.
- Six-activity router behavior, placement/clearance, reconnect, device/group, and human-fun evidence.
