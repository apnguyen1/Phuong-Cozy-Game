# MVP nighttime lighting assets

This folder intentionally contains no downloaded sky or image assets. The
lighting builder uses native Roblox settings and preserves any existing `Sky`
instance so the integrator can verify its provenance independently.

Owned implementation: `roblox/mvp/builders/NightLighting.luau`.

The builder creates only `MVP/NightLighting` fixtures from resolved MVP anchors.
It does not create map-edge geometry, recolor authored parts, replace textures,
or run automatically when required. Proposed budgets are 12 shadow fixtures in
high mode and 6 in low mode; Studio/device profiling remains required.
