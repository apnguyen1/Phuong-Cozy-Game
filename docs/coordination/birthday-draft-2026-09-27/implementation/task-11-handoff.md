# Task 11 implementation handoff — nighttime lighting

Status: implementation delivered; Studio installation and independent verification pending.

## Owned files

- `roblox/mvp/builders/NightLighting.luau`
- `roblox/mvp/art/lighting/README.md`
- `docs/coordination/birthday-draft-2026-09-27/11-night-lighting.md`

## Exports and integration

The canonical export is `return function(context)`. It consumes `context.Root`, `context.MVP`, `context.Anchors`, `context.Palette`, optional `context.Options`, optional `context.Lighting`, and `context.SafeReplace`. It validates all required anchors and palette tokens before constructing or mutating anything, builds a detached fixture folder, then calls only `context.SafeReplace("NightLighting", factory)`. `context.Options.lowGraphics = true` disables fixture shadows and caps fixture brightness at 1. The result consistently exposes `folder`, `manifest`, and an extra `Restore` function.

The integrator must require this module from the approved source location and call it against the copied local `CozyWorld_Draft01` in Studio Edit mode after Task 01 resolves live anchors. It must not be run against an unmeasured live place. The module preserves any existing `Lighting.Sky` and unrelated lights; it creates/updates only the owned `MVPNightAtmosphere` and the documented global Lighting values. The install transaction is: preflight -> detached build -> capture globals -> apply owned atmosphere/global settings -> `SafeReplace`. If SafeReplace or a later integration step fails, call `Restore`; it restores captured globals and owned atmosphere state. The detached folder is never parented under Root before SafeReplace.

## Actual checks performed

- Read-only inspection confirmed `roblox/mvp/shared/Anchors.luau`, `CONTRACT.md`, and `INTEGRATION.md` are available.
- Source review confirmed the module has no top-level `Apply` call, no external asset/image IDs, no camera mutation, and no direct Studio execution.
- No Roblox Studio run, place mutation, device test, lighting screenshot, multiplayer rehearsal, or live-server test was performed in this worker chat.
- Current source SHA-256: `6FEF0BB78720D6F71F9F47BAA8E71738EA5F474685A0216C7B1DBEE21E84C286`.

## Known dependencies and gates

- Task 01 must install/resolve measured anchors and owns Studio scene installation.
- Task 10 must provide boundary geometry; this module does not hide unfinished edges or create fog walls.
- Task 12 must avoid duplicating decorative bulbs or shadow lights.
- Task 13/integrator must verify open sky, avatar/figure/UI readability, low/high graphics behavior, shadow counts, route navigation, and 8–10-player crowd conditions.
- Existing Sky provenance and final Lighting technology remain unresolved until independent Studio review.

This is not self-approval or Roblox readiness evidence.
