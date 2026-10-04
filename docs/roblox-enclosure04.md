# October 3 — enclosed Seattle neighborhood and surface detail

The teleport destination now has a continuous ring of 58 shallow roofed buildings at the existing perimeter. Brick/concrete walls, framed windows, closed decorative doors, shop glazing, fabric awnings, cornices, roof vents and rain downpipes replace the tall flat panels. Solid building bodies and four overlapping tall boundary colliders close edges and corners. A native grass floor fills the previously exposed strip around the original lawn; the sky remains open.

Ground details include Quad paving courses, sidewalk joints, curb and drainage grilles, tree mulch beds, fallen leaves and verge tufts. All 16 green perimeter trees retain their original placement and size, with native grass foliage materials, leaf clusters and bark relief. The original cherry trees/textures, real shop doors, bedroom, activity anchors and runtime scripts are preserved.

- Boundary builder: `roblox/mvp/builders/SeattleBoundary.luau`; 1,931 anchored parts, 2,300 maximum.
- Ground/tree builder: `roblox/mvp/environment-detail04.luau`; 1,054 decorative parts, 1,100 maximum. Decorative geometry has collision, touch and query disabled.
- Repeatable import: `verification/mvp/import/update-SeattleBoundary.luau` updates the owned builder module only; invoking the builder is a separate Edit-mode operation.
- Contract: `verification/contracts/MAP-03-enclosure04.json`.
- Independent review: `verification/runs/map-03-enclosure04/`.
- Immutable evidence and local save binding: `roblox/evidence/enclosure04/`.

The current translated world is preserved. The enclosure measures its initial front planes from the live earlier perimeter and persists those world coordinates for reruns. Ground decoration corrects older route metadata using the current home-floor anchor and the recorded route offset. It does not move the route network.

Independent review, human visual acceptance and physical phone/tablet/group performance remain separate gates. This revision does not publish the place or author the birthday note.
