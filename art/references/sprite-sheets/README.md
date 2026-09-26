# Generated sprite references

**Status: retained as character design references, not final production assets.**

| Character | Generated sprite sheet |
|---|---|
| Phuong | [Phuong reference](phuong-v1.png) |
| Lisa | [Lisa reference](lisa-v1.png) |
| Jasper | [Jasper reference](jasper-v1.png) |

The [native Phuong Aseprite draft](../../characters/phuong-v1.aseprite), [enlarged sheet](../../characters/previews/phuong-sheet.png), and [walking previews](../../characters/README.md) are also retained as references and a demonstration of the MCP workflow. The local Aseprite MCP successfully created editable layers, 20 frames, eight animation tags, and PNG/JSON/GIF exports. Lisa and Jasper currently have generated reference boards only; native Aseprite animations have not yet been made for them.

Created with the built-in image generation tool. These PNG boards are visual references for Aseprite finishing, not runtime sprite atlases or editable .aseprite files. Each board contains four facing directions, with one idle and four walking pose studies per direction.

Before runtime use: clean backgrounds/grid/labels and edge artifacts; redraw at chosen native resolution; align uniform frame canvases and anchors; correct walk timing and repeated poses; preserve asymmetric details across frames (Phuong's bag strap currently changes orientation in one rear pose); export PNG plus JSON array metadata. Lisa's board has visible edge artifacts that need cleanup. Neither human sheet has been validated as a seamless walk loop.

Lisa's blue sweatshirt and gray trousers follow the supplied photo for this draft. Jasper uses the dog in that photo as appearance reference. Phuong follows the supplied sheet. These images do not independently finalize all character design decisions.

## Generation prompts

### phuong

Use case: stylized-concept. Create a polished pixel-art sprite reference sheet for PHUONG matching the attached character design: dark shoulder-length hair, black rectangular glasses, dark blue-gray T-shirt with tiny pale chest motif, black shorts, pale sneakers, black diagonal crossbody bag. Preserve this outfit rather than a green sweater. Compact cute RPG proportions, crisp pixel clusters, restrained palette, no blur. REFERENCE IMAGE is character and style guidance only; correct its mistaken walking directions. Landscape sheet on flat pale gray background, title 'PHUONG'. Exactly 4 ROWS and 5 COLUMNS in a uniform subtly ruled grid. Column headings 'idle', 'step 1', 'step 2', 'step 3', 'step 4'. Row labels 'down', 'up', 'left', 'right'. Each cell contains ONE complete same-sized Phuong, feet consistently aligned, generous separation. Down row ALL front-facing; up row ALL true rear-facing showing back of hair and shirt, NO face or glasses; left row ALL strict left-facing; right row ALL strict right-facing. First column neutral stationary stance, remaining four columns coherent walk cycle: contact, passing, opposite contact, passing, alternating arms/legs with subtle bob. Keep head, outfit and body size consistent. No hearts, dog, Kindle, props, perspective changes or extra miniatures. Whole sheet uncropped. This is a drawing reference for Aseprite finishing, not a screenshot of an editor.

### lisa

Create a pixel-art character sprite reference sheet titled LISA. Reference image 1 is STYLE ONLY: compact cute RPG pixel character proportions, crisp dark outlines, restrained colors. Reference image 2 supplies Lisa's appearance: young adult woman with long straight dark brown hair parted to one side, no glasses, warm medium-light skin, loose blue sweatshirt, light gray sweatpants. Give her simple white sneakers. Draw Lisa ALONE, not holding the dog. Flat opaque PALE CREAM background across whole sheet, dark readable labels, no shadows or vignette. Exactly four rows and five columns in evenly spaced cells, full body in every cell, consistent scale and foot baseline. Columns: idle, step 1, step 2, step 3, step 4. Rows: down, up, left, right. ALL five down row characters face camera; ALL five up row characters show back of head and clothing with NO face; ALL five left row characters face LEFT; ALL five right row characters face RIGHT. Idle stands still. Four walk drawings per row show contact, passing with feet near together, opposite leg contact, opposite passing. Maintain identity, proportions, outfit and hair throughout. Human anatomy two arms and two legs. Matching compact cozy pixel-art game aesthetic. No hearts, dog, accessories, or extra figures. Clean reference board for later Aseprite cleanup, not a rendered editor UI.

### jasper

Create a polished pixel-art sprite reference sheet titled JASPER for a compact cozy top-down RPG. Reference image 1 supplies pixel-art aesthetic ONLY. Reference image 2 supplies the DOG appearance ONLY: small fluffy golden-orange Pomeranian, cream muzzle and thick cream chest ruff, dark round eyes, small black nose, upright triangular ears, darker golden back, large fluffy tail curled over back. NO humans. Exactly 4 rows by 5 columns of evenly sized separated cells. Column headings idle, step 1, step 2, step 3, step 4. Row labels down, up, left, right. Row down: all five dogs face viewer, front paws visible, ears symmetrical. Row up: all five dogs face away, back of head and ears, hindquarters and curled tail, NO face. Row left: all five dogs point muzzle LEFT. Row right: all five dogs point muzzle RIGHT. First column neutral four-paw standing pose, remaining four columns a coherent four-legged walk sequence with alternating fore/hind paws, contact and passing poses, subtle fur bounce. Every cell has ONE complete consistent sized dog on a consistent baseline. Compact adorable proportions, crisp pixel clusters with dark warm outlines and simple limited fur shading. No human posture, no clothing, no leash, no hearts, no props, no extra poses outside grid. Opaque solid light cream background, readable dark text and fine gray grid, no dark background, gradients, glow, shadows, vignette, blur or editor UI. This is an Aseprite drawing reference board; do not include any claims of exact runtime pixel dimensions.
