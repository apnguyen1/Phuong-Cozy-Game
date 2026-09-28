# Task 12 implementation handoff

Status: source implementation complete; Studio installation and independent verification pending.

## Owned files

- `roblox/mvp/builders/GrassDecoration.luau`
- `roblox/mvp/art/garden/README.md`
- `docs/coordination/birthday-draft-2026-09-27/12-grass-decoration.md`

## What the builder does

`GrassDecoration.luau` is an Edit-mode-only, idempotent builder module. Requiring it has no side effects; the integrator invokes the returned function with `Root`, `MVP`, `Anchors`, `Palette`, `SafeReplace`, and `Options`. `Options.OuterQuadBounds` and `Options.Keepouts` must come from Task 01's measured anchor manifest, and required station/route anchors must resolve before replacement. The builder calls only `SafeReplace("GrassDecoration", factory)`; the detached factory result contains native untextured grass clumps and up to four outer-edge tree candidates derived from measured bounds. It returns `{ folder = installedFolder, manifest = {...} }`. New parts use only the eight approved palette colors, are anchored and noninteractive, and receive required verification/ownership attributes. It reads existing `Paths.RouteDefinitions` and rejects candidates too close to protected route widths. It does not touch `Paths`, `QuadGround`, `QuadPlanting`, existing trees, benches, signs, planters, window boxes, lights, gameplay scripts, or camera state.

## Installation

The designated integrator should run the source in Roblox Studio Edit mode against a copied current local place after Task 01 publishes live footprint anchors. Before execution, replace/confirm the provisional candidate sites against the measured outer Quad envelope and station/facade keepouts. Do not run in Play mode. Do not install external textures or assets. Review the generated folder and capture the baseline comparison before saving a new local checkpoint.

## Checks in source

- requires `CozyWorld_Draft01`, `Landscape.QuadGround`, `Paths`, and nonempty `RouteDefinitions`;
- calls only the shared `SafeReplace("GrassDecoration", factory)` callback;
- records prior route-part count and `QuadGround` CFrame/size, then asserts they are unchanged;
- checks route clearance for each candidate and grass site;
- rejects unknown palette tokens and uses no color maps or texture IDs;
- enforces a 250 new-BasePart limit;
- records part count, route count and baseline metadata on the generated folder.

## Shared invocation contract

The common installer should load the module, then call its returned function with:

```lua
builder({
    Root = root,
    MVP = mvp,
    Anchors = resolvedAnchors,
    Palette = sharedPalette,
    SafeReplace = safeReplace,
    Options = { OuterQuadBounds = anchors.OuterQuadBounds, Keepouts = measuredKeepouts },
})
```

Missing `OuterQuadBounds`, keepouts, unresolved required activity/route anchors, or palette mismatch must fail before replacement. The builder must not be executed by `require` alone.

## Actual test result

Not run: this worker is not permitted to mutate Studio or start a test window. Luau syntax/runtime, live anchor placement, visual composition, collision/query properties, low-graphics appearance, touch traversal, physical-device performance, 8–10-player group behavior, and independent review remain open gates.

## Dependencies and unresolved gates

- Bind candidate coordinates to Task 01's measured outer Quad and activity keepouts before installation; current bounds-based candidates are explicitly provisional.
- Integrator must compare original `Paths`, `QuadPlanting`, `QuadGround`, station, sign, gate, bench and facade transforms before/after.
- Independent reviewer must capture exact palette/material/texture evidence and verify that no new object relies on the existing community-tree texture exception.
- Task 11 must review nighttime silhouettes/open-sky sightlines; Task 10 must review facade overlap; Task 13 must run route, touch, low-graphics and 8–10-player rehearsal gates.

This handoff is not a self-approval or a claim that the Roblox MVP is playable.
