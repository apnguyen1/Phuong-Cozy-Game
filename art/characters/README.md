# Phuong native sprite draft

**Status: reference and MCP capability demonstration, not an approved final game asset.** Keep this draft and its exports for future art work. Its 24 x 32 canvas does not settle the final character dimensions. See [all three character reference sheets](../references/sprite-sheets/README.md).

Created through the locally configured Aseprite MCP server using its stdio protocol and `run_lua_script`, `get_sprite_info`, and export tools. The supplied pixel-art sheet guided the dark hair, glasses, blue-gray shirt, shorts, sneakers, and crossbody bag. This is a simplified native-pixel redraw, not an exact extraction of the generated reference.

- Editable source: `phuong-v1.aseprite`.
- Native canvas: 24 x 32, transparent RGBA; widened from the proposed 16 x 32 for glasses and hair.
- Four editable layers: legs/sneakers, shirt/shorts/arms, hair, face/glasses/bag.
- 20 frames; idle and four-frame walk for down, up, left, and right.
- Walking frames: 140 ms each, forward looping; idle poses: 250 ms.
- Frame indices in Aseprite are one-based; exported JSON tags are zero-based.
- Anchor for integration: bottom-center of the 24 x 32 canvas. No cropping or trimming.
- Runtime-format reference exports: `../../public/assets/characters/phuong-v1.png` and `phuong-v1.json`, JSON array with frame tags. Their location does not imply approval for final game integration.
- Enlarged walk GIFs, idle PNG, and sheet PNG are in `previews/`; these are for review, not runtime use.

Verified dimensions, frame count, layer count, tag ranges and exported durations; inspected the exported sheet. Movement speed, collisions, and appearance against the actual game map still need in-game testing. The artwork is an initial compact draft for user review.

`build-phuong.lua` preserves the drawing recipe. `run-aseprite-mcp.py` is a local reproduction helper using this machine's configured server and Aseprite paths. Running it regenerates v1 and overwrites its exports: save manual edits as a new version first.
