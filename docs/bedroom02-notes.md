# Bedroom reference interior, iteration 02

The builder creates `Workspace.CozyWorld_Draft01.Home.Bedroom` inside the existing 64 × 48 stud cottage. It keeps exactly one room. The decorative open closet is a shallow wardrobe recess inside that room, not a passage into another space.

The arrangement follows the supplied room photographs and PCW-04: the sage bed, cream upholstered headboard, trailing ivy, and vertical warm light curtain occupy the north wall; the white desk and densely filled bookcase face them from the south wall. Nominally, the cottage's front doorway is at x = −24 to −16, z = −84. The builder reads the current `Home.Floor` position and translates only the new Bedroom by the user's existing shell offset. At integration time that offset was reported as (19, −0.1, −40), so the live doorway is centered at (−1, 6.2, −124). The center and east half of the room provide circulation around the stations.

`roblox/build-bedroom02.luau` is a standalone Edit-mode builder. Re-running it replaces only `Home.Bedroom` and removes the explicitly named Draft 01 furniture placeholders: `ReadingRug`, `CraftTableTop`, `TableLeg`, and `InteriorLamp`. The existing shell, front door, exterior planting, and runtime scripts are untouched.

## Authored details

- Warm cream interior finishes, staggered wood boards, baseboards, crown trim, and a dome ceiling fixture.
- Sage duvet with quilt seams and side drapes; cream sleeping pillows, a sage bolster, round cushion, folded cream quilt, and a floral throw built from small petal and leaf shapes.
- Rounded dog and dinosaur plushies with bellies, paws, faces, dog ears, dinosaur spikes and tail; three smaller headboard animals.
- Vertical fairy-light strands and hanging ivy; emissive bulbs share two small light sources.
- Cream bedside drawers, handled sage tumbler with straw, and a small e-reader.
- Shallow closet with a rail, hangers, clothes, shelf baskets, and a tote.
- White desk with drawer pedestal, monitor, individual keyboard keys, mouse and mat, pencil cup, coloring paper, and a miniature reading-room craft display.
- White/ink rolling chair, mesh ribs, five caster spokes, arm rests, and hanging headphones.
- White bookcase with varied plain book spines, figures, plants, jars, a miniature house, and horizontal book stacks. No invented titles or personal messages.
- Three-tier wheeled storage cart, storage boxes and craft supplies, a little fan, bin, TV, wall socket and cable.
- Botanical print composed from native leaf shapes, framed glass mirror, curtain pleats and blinds, low dresser, Jasper's cushioned bed and rabbit toy, and sage slippers.

## Palette and verification handoff

Every authored BasePart has a `PaletteToken` attribute and uses one of the exact approved colors: forest `#365744`, sage `#A8B995`, cream `#F5F0E4`, wood `#95674B`, blossom `#E8B7C6`, brick `#B66C68`, golden `#E8C779`, and ink `#26382E`. The Bedroom root has `VerificationTicket = "PCW-04"`. No imported texture or external script is required. Native material response, shadows, and warm lights supply surface variation.

The builder asserts that every authored part is anchored and tagged. The source compiled successfully through Studio's Luau compiler without executing the builder. Neither check establishes visual fidelity or playable circulation. The coordinator must integrate, capture, compare, and walk through the live result before approving PCW-04.

Suggested Studio captures below use nominal coordinates (camera position → target; approximately 65° FOV). Add the `Bedroom.PlacementOffset` attribute to both vectors. With the current offset, the entrance capture is (0, 8.9, −131) → (−25, 5.9, −162).

| View | Position | Target | Purpose |
|---|---|---|---|
| Entrance toward bed | (−19, 9, −91) | (−44, 6, −122) | Bed, light curtain, closet and bedside objects |
| Bed detail | (−31, 8, −111) | (−45, 5, −123) | Bedding, pillows, plush silhouettes, ivy |
| Desk and shelf wall | (−22, 9, −114) | (−42, 6, −89) | Photo 3 composition, desk, chair, books, curtains |
| Broad room | (−3, 11, −96) | (−35, 5.5, −113) | One-room composition and open circulation |

Required visual and runtime review:

1. Compare both supplied room photos, including the bed/light wall opposing the desk/shelf wall.
2. View every station at normal third-person height and on low graphics; the main props must remain recognizable without the small emissive bulbs.
3. Enter through the original door, move down the central aisle, approach the bedside, desk, closet and cart, and return outside. Check the front-door swing and third-person camera under the ceiling.
4. Rehearse 4–6 visitors around the room, with no collision trap around the desk chair or bed. Decorative small pieces are non-colliding; major furniture is solid.
5. Capture the Bedroom root through the existing verification system and confirm the exact palette.

## First render review and corrections

The actual `bedroom-bed-first.png` and `bedroom-desk-first.png` captures showed excessive yellow fill, raw wood grain on cream furniture, and missing leaf, pillow and floral shapes. The important geometry fault was using `Part.Shape = Ball` for nonuniform ellipsoids: the visible result collapsed slender shapes toward spheres. The builder now uses a Block part with Roblox's built-in `SpecialMesh` Sphere, preserving independent axis proportions without an uploaded mesh or texture. The official [SpecialMesh documentation](https://create.roblox.com/docs/reference/engine/classes/SpecialMesh) documents this distinction.

Cream-painted furniture and the ceiling now use SmoothPlastic. Natural wood remains on the floor, baskets, bed legs and small accents. The floor uses continuous wood color instead of distracting brick-colored boards. Main light intensity decreased from 1.15 to 0.6, the reading fill from 0.45 to 0.16, and the two fairy fills from 0.5 to 0.18. General lamps use the cream light color; the localized fairy glow remains golden. Larger fabric props now cast shadows, and a rounded fold softens the quilt edge.

These changes address visible faults found in the first captures. A second live render is required to verify them; the screenshots from before these changes cannot establish the revised result.

## Limits of this iteration

This is a stylized reconstruction of the photographed objects inside an already enlarged game shell, not a measured copy of the physical room. Plushies and miniature figures are native-shape interpretations; no exact collectible meshes were supplied. The mirror uses glass reflectance and does not render a live reflection. The fan, TV, closet garments and chair wheels are decorative. No quest interactions, generated birthday note, copyrighted book art or personal messages have been added. Visual approval is pending the live Studio render and circulation checks.
