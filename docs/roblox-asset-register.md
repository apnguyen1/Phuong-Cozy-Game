# Roblox environment asset register

Initial research: September 25, 2026. Arrival-to-house shortlist and preview review: September 26, 2026. Companion to the [map design](roblox-map-design.md).

Creator Store availability and free price were checked through the live Roblox asset search. Five candidates have now been inspected and used in the first Studio draft as recorded below. Other entries remain candidates. Draft adoption does not establish original authorship or final production suitability.

## Draft 01 adoption — September 26

| Asset | Contents inspected and adaptations | Current result |
|---|---|---|
| Blossom `12800074855` — Hachi_OfficialBACK | Imported to ServerStorage. Found two animation/character scripts and disabled them in the original. Reviewed template contains only two static MeshParts and visual children; removed character, animation, particle, joint, and script content. Normalized to 32 studs and varied repeated scale. Added simple invisible trunk collisions; canopy is non-colliding. | 23 trees in the actual draft. Arrival-to-porch traversal passed. Leaf detail is denser than the soft concept and remains a visual review item. |
| Lantern `14212653287` — 9bsts | No scripts. Kept two mesh parts, removed halo GUI, replaced four lights with one dim warm light, recolored pole dark green. | Six path lamps, reduced to about 14 studs tall. No visual load errors in the draft captures. |
| Bench `741384218` — FoxyTheSaphradite | No scripts. Ten unions and two Seats. Matched wood and metal colors; anchored geometry; enabled Seat touch behavior. | Four benches placed. Original-author provenance remains uncertain because the listing acknowledges reuse. Seating requires further player verification. |
| Sky `591067775` — Yourius | Sky instance, no scripts. Used with shared atmosphere, warm color correction, and afternoon lighting. | Actual sky and horizon reviewed with arrival and cottage. Visible open horizon remains around the placeholder outer boundary. |
| Petals `12071076692` — FANFIK_BOOK | No scripts. Selected one mesh-based ground pile; removed emitter and light; disabled collision. | Seven small accents under selected trees. Further close-up review can determine whether they add enough value to keep. |

Original imports remain in `ServerStorage.CozyDraftAssets.Incoming`. Adopted script-free templates are in `Reviewed`. The draft requires no external 3D import. The Synty pack is still a candidate; current storefronts are native placeholder masses.

The following shortlist preserves the research findings and planned checks from before assembly. The adoption table above is the current status for those five assets.

## Arrival-to-house shortlist — September 26

The user accepted the [visual direction](roblox-arrival-visual-study.md) and requested assets and a check of autonomous building capabilities. The following free listings were rechecked live and their public 420-pixel thumbnails inspected before the authorized Studio build.

| Priority / role | Candidate | Preview findings | Planned adaptation and remaining check |
|---|---|---|---|
| First: blossoms | [Cherry Blossom Tree](https://create.roblox.com/store/asset/12800074855) — Hachi_OfficialBACK | Pink, fairly dense irregular canopy on a short visible trunk; closer to the concept than a generic recolored green tree | Test at player height; check transparency, leaf detail, trunk/canopy proportions, collisions, and cost of repeating it. The asset may need more open spacing than the illustration. |
| First: path lanterns | [Street Lamp](https://create.roblox.com/store/asset/14212653287) — 9bsts | Tall dark classic lantern post with warm pale glass; close to the concept's silhouette | Recolor dark green if editable; reduce harsh glow; inspect light settings and any bundled scripts. |
| First: benches | [The Generic Park Bench with Seats](https://create.roblox.com/store/asset/741384218) — FoxyTheSaphradite | Slatted brown bench, dark curved metal supports and armrests | Match wood/metal colors and seating height. Creator explicitly says the bench was not originally theirs and they added seats; provenance and seat behavior still need review. Prefer an equivalent piece from the coherent pack if its fit is better. |
| First: sky comparison | [Sunless Blue Sky Skybox](https://create.roblox.com/store/asset/591067775) — Yourius | Bright saturated blue with white clouds; a possible base, not already the concept's softer lighting | Inspect all faces/horizon and compare under the warm material sample. Terrain and background planting must conceal an unsuitable horizon. |
| Optional: petal accents | [Flowers](https://create.roblox.com/store/asset/12071076692) — FANFIK_BOOK | Thumbnail shows scattered pink flowers/petals spread across a ground plane | Test thin ground accents beneath a few trees; keep collisions disabled if adopted, avoid surface flicker, and check texture transparency. This is not an upright flower-bed model. |
| Later: western storefronts and common props | [Synty City Pack](https://create.roblox.com/store/asset/6933556508) — Roblox | Listing describes modular shops, roads, and park pieces. Thumbnail is obstructed and does not establish the useful sub-models' appearance | Inspect only relevant low-rise facade and park pieces. Official listing states the pack is licensed for Roblox games. Do not copy the entire city into the map. |
| Reserve: flowering shrubs | [Flower Bush](https://create.roblox.com/store/asset/8344171779) — Woof_HDPlay | Rounded leafy bush with purple/pink flower heads; more detailed than the desired broad stylized planting | Use only if it blends with the chosen tree and can be simplified/recolored; otherwise use a simpler common shrub family. |

**Build directly from native parts:** the cream/green cottage shell and porch, pale paving and edging, birthday sign with native text, simple wooden planter boxes, and the continuous lawn base. This keeps the approved proportions editable and needs no external 3D import for the first prototype. Reuse compatible community doors/windows/props where they actually save work.

### Candidates that did not match the first view

| Asset | Observed reason | Disposition |
|---|---|---|
| [Cottage House](https://create.roblox.com/store/asset/12346232595) — paraghoul | Thumbnail shows a tall two-story cottage, steep roof, chimneys, shutters, and raised entry | Do not use as the main house shell; substantially different from the approved one-story broad cottage |
| [Park Bench](https://create.roblox.com/store/asset/393609716) — AeliteOfficial | Thumbnail shows a picnic table with attached benches | Could suit the optional Quad picnic; not the arrival bench |
| [Street Lamp Light](https://create.roblox.com/store/asset/15472204631) — BryanROBLOXgamer10 | Thumbnail shows a curved modern roadway light | Not the proposed classic lantern family |

### First inspection and assembly sequence

1. Confirm the intended open Studio place. Read-only checks found an unpublished `Place1` in Edit mode with a baseplate, spawn, and one additional Part. Existing content should be inspected and preserved when preparing the prototype.
2. Put candidate models in a separate asset-review container, away from the map. Inspect scripts and dependencies before any playtest; keep unneeded behavior out of the adopted decorative models.
3. Compare one tree, lantern, bench, and sky against native wall/roof/paving samples and the selected avatar. Check scale, materials, collision, and repeated foliage performance before adopting a family.
4. Build the arrival pad, main approach, and cottage/porch from the component plan; retain the extended Quad beneath the paths and reserve side branches.
5. Place only inspected props, tune lighting, inspect the arrival view and porch camera, then test walking and save a local checkpoint. Publishing is a separate step.

**Verified build workflow:** direct Roblox tools imported and inspected models, built geometry, configured lighting, installed the two authored scripts, and completed a single-client walk/door test. Windows computer use successfully targeted Studio for its editor panels; refresh window state before UI input because focus may change while the user works.

## First candidates

| Use | Exact asset and creator | Asset ID | Price / source status | Review focus |
|---|---|---|---|---|
| Buildings, storefronts, roads, park props | [Synty City Pack](https://create.roblox.com/store/asset/6933556508) — Roblox | `6933556508` | Free; listing describes licensing for use in Roblox games | Preferred coherent kit to evaluate. Select low-rise pieces, test scale and recoloring, and keep only needed pieces. Listing includes modular roads and shop fronts; vehicles are decorative props. |
| Soft sky candidate | [Sunless Blue Sky Skybox](https://create.roblox.com/store/asset/591067775) — Yourius | `591067775` | Free | Check cloud appearance, six-face seams, horizon, and compatibility with warm lighting. Name alone is not visual verification. |
| Sky alternative | [Modern City Skybox](https://create.roblox.com/store/asset/13406777949) — mothmage | `13406777949` | Free | Compare against the soft-blue candidate; reject if skyline/detail overwhelms the small cozy setting. |
| Road alternative | [MODULAR ROAD KIT V1](https://create.roblox.com/store/asset/11000704910) — TheLionDeveloper | `11000704910` | Free | Creator describes 23 connectable parts and a HELP script. Compare widths and curb heights against the building kit; inspect contents before use. |
| Blossom tree | [Cherry Blossom Tree](https://create.roblox.com/store/asset/12800074855) — Hachi_OfficialBACK | `12800074855` | Free | Inspect ground-level silhouette, canopy opacity, materials, scale, and collision; no useful description supplied. C06 candidate only. |
| Generic home furniture | [Low poly furniture pack](https://create.roblox.com/store/asset/7214655203) — thatfrenchfried | `7214655203` | Free | Compare a table, shelf, and chair with the cottage and selected avatar. Confirm useful pieces and style before adopting. C04 candidate only. |
| Earlier cottage candidate | [Cottage House](https://create.roblox.com/store/asset/12346232595) — paraghoul | `12346232595` | Free; creator describes an empty interior with fence, mailbox, and planters | September 26 thumbnail review: reject as the main shell because its two-story proportions differ from the approved concept. |

Start by comparing a few useful Synty pieces under both sky candidates. Do not combine multiple building and road kits until their proportions and materials have been compared side by side.

## Open-license external fallbacks

These would require downloading and importing selected 3D files. They are fallback sources, not required for the first blockout. License labels below were verified on the authors' official pages; retain the license supplied with any actual download.

| Source | Potential gap | Verified source information | Still to check |
|---|---|---|---|
| [Kenney City Kit — Suburban](https://kenney.nl/assets/city-kit-suburban) | Small houses and neighborhood shells | Free; Creative Commons CC0; 40 files listed | Actual file formats, door/interior suitability, scale, and style alongside the selected Roblox kit |
| [Kenney City Kit — Commercial](https://kenney.nl/assets/city-kit-commercial) | Additional building pieces | Creative Commons CC0; 50 files listed | Whether the pack's architecture fits a tiny neighborhood rather than a larger city |
| [Kenney Nature Kit](https://kenney.nl/assets/nature-kit) | Trees, rocks, shared foliage | Free; Creative Commons CC0; 330 files listed | Shape/detail compatibility, texture setup, and whether any tree is suitable as a blossom-tree base |
| [Kenney Furniture Kit](https://kenney.nl/assets/furniture-kit) | Generic tables, chairs, beds, storage | Free; Creative Commons CC0; 140 files listed | Selected pieces, actual formats, materials, scale, and match to the cottage; external import fallback for C04 |

## How candidates advance

`Candidate → thumbnail reviewed → contents inspected in Studio → style accepted → scale/collision tested → adopted`

When an asset advances, add the inspection date, selected sub-models, destination component, any modifications, source terms/license file, and test result to this register. Reject or replace candidates that need more adaptation than simple native construction.

## Research references

- [Synty City Pack listing](https://create.roblox.com/store/asset/6933556508/Synty-City-Pack): component families, decorative vehicles, and Roblox-use licensing statement.
- [Roblox Importer](https://create.roblox.com/docs/studio/importer): supported formats and import settings.
- [Roblox third-party software overview](https://create.roblox.com/docs/art/overview-dcc): external modeling workflow.
- [Roblox Clouds](https://create.roblox.com/docs/reference/engine/classes/Clouds): native cloud treatment; use alongside the chosen sky/lighting setup if it fits.
