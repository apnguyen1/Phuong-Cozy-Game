# Task 01 installer repair

`roblox/mvp/install.luau` is now a source-only Edit-mode installer module. Require it and invoke the returned function with `{Root, MVP, Anchors, Options, Builders}`. Options must provide measured `OuterQuadBounds`, `Keepouts`, and `WorldBounds`; anchors must be resolved BaseParts. The installer preflights every activity, lobby, and environment builder plus all required anchors before mutation, uses the exact eight project palette tokens, and installs through ownership-scoped `SafeReplace` transactions. Factories must return detached Folder/Model instances; failed installs restore staged folders and prior owned folders.

The installer invokes Q01–Q06, LobbyQueue, SeattleBoundary, NightLighting, and GrassDecoration. It does not write script source, publish, fabricate coordinates, or claim Studio readiness. Studio import, route, and multiplayer review remain independent gates.

Compiler evidence using `verification/mvp/tools/luau-0.740/luau-compile.exe`:

```text
install.luau exit 0
Q06Station.luau exit 0
install.luau SHA-256 5D47409C69E748ED4EC236735F49B799EAE9F7FE2C5E21565C1B30D9978FE243
Q06Station.luau SHA-256 5DFF5317CC0F8ED2902E367C14E67BD5988CE208D76EE7504903B222AF38519F
```
