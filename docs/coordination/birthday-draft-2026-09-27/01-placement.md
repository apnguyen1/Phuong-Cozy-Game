# Task 01 — placement and bedroom arrival plan

Status: implementation-ready spatial proposal; not Studio approval, not a live-place measurement, and not a production-ready art claim.

## Scope and authority

This draft owns anchor names, spatial relationships, arrival occupancy, and route/camera constraints. The September 27 coordination packet is authoritative for the birthday lobby, ten-player target, six quest identities, shared session progress, and destination choices. Q01–Q06 mechanics remain owned by their activity drafts. The personal birthday note is intentionally not authored here.

Confirmed: the gameplay party arrives inside Phuong’s existing single detailed bedroom with Jasper; Q01 is at the bed; Q02 begins indoors and continues to the existing outdoor fetch area; Q03 uses a UDistrict crossing-side booth plus the bedroom display; Q04 uses the existing Quad blossom benches without changing Quad interior geometry; Q05 is a UDistrict-side vending machine outside the crossing/pedestrian route; Q06 is near FOB Poke Bar and Aladdins; the patio is reserved for the cake finale and ten seats. The numeric dimensions below are proposals unless explicitly marked as source-derived.

## Evidence boundary and coordinate frame

The source builder uses world X/Y/Z coordinates and derives new bedroom/neighborhood geometry from `Home.Floor.Position - Vector3.new(-28, .12, -108)`. Saved notes report the observed integration offset `(19, -0.1, -40)`, but a source value is not proof of the currently installed live Studio scene. Every later builder must read the current `Home.Floor.Position`, resolve named Instances, and record the actual CFrame/size before placing anything.

| Evidence / anchor | What is verified in source or saved evidence | Frame and proposed placement | Clearance / capacity / camera constraint |
|---|---|---|---|
| `GameplayBedroomArrival` | `Home.Floor` nominal source center `(-28,.12,-108)`, shell 64×48; front door opening x `[-24,-16]`, z about `-84`; notes report translated doorway centered near `(-1,6.2,-124)` for the observed offset | World anchor at the current door threshold, facing inward. Arrival rectangle 18×12 studs, centered 12 studs inside the door and aligned with the room’s long axis; proposal, not measured | Keep a 10-stud clear corridor from threshold to center. Capacity 10 as standing arrivals; no arrival spot may overlap bed, Jasper, door swing, desk, or another spot. Ceiling/camera check at normal third-person height |
| `BedroomArrival01–10` | No ten-slot set exists in the current source; lobby has a separate slot system | Proposed local offsets from room doorway center `(0,0,0)`, using x across doorway and z inward: `(-7,0,5), (0,0,5), (7,0,5), (-7,0,11), (0,0,11), (7,0,11), (-7,0,17), (0,0,17), (-4,0,23), (4,0,23)`; y is floor contact plus avatar hip offset at runtime | Each is a 4×4-person footprint with 2-stud buffer; reserve 2 studs between footprints. Spawn assignment must avoid occupied/blocked slots and never place on furniture. Re-check all ten with avatar collision capsules and camera raycasts |
| `BedroomSafeExitWest/East` | Bedroom notes say center/east half provides circulation; front door and station route are preserved | Proposed two-way exit lanes, each at least 8 studs wide: central-to-door lane and east-side bypass. Do not add barriers to create the spots | At least two avatars can pass each other; camera must see door, floor, and nearest interaction prompt without clipping into ceiling/furniture |
| `Q01Bed` | Source bedroom builder places bed base centered near `(-45,1.63,-115.6)`, mattress/headboard on north side; exact current placement must be read from `Home.Bedroom` | Keep bed footprint and orientation. Interaction approach is south/east side; proposed interaction rectangle 24×10 studs, no new bed geometry | Six active players can observe/work in shifts; two-person manipulation subareas must not block the bedroom exit. Bed prompt should face the open room, not the headboard |
| `JasperBedroomStart` | Bedroom builder notes identify Jasper’s cushioned bed and rabbit toy; no runtime Jasper start anchor is verified | Proposed anchor on the east/open side of bedroom, 6 studs from Q01 approach and 8 studs from door center; facing toward players, with a 6×6 idle footprint | One avatar interaction ring, plus 4 studs of passing clearance. Never spawn Jasper on the arrival set or in front of the door. Indoor greeting is optional and non-blocking |
| `JasperFetchYard` | Source draft reserves a dog park; fences run approximately x `76..160`, z `-142..-30`, with two west gates; saved notes confirm open fetch lawn and both gates | Use the current park’s verified open lawn and north bench as the source anchor. Proposed indoor-to-yard route exits through the nearest existing gate; fetch lane 12 studs wide, 36 studs long, parallel to open lawn, not across a gate | Ten players may watch; three target zones need 4-stud separation. Keep gates and bench approaches clear. Camera target must retain Jasper and throw target in view; exact lane awaits Q02 author and live navigation |
| `Q03FairCraft` | Street source is centered near x `-122`, sidewalk x about `-139`, crossings at z `-100,28,108`; no craft booth Instance is verified | Proposed booth on the UDistrict side of the crossing, outside the 24-stud road and continuous sidewalk: place on the east/safe side of the crossing with 12×10 footprint, counter facing sidewalk, booth normal perpendicular to road | Reserve 8 studs approach, 4 studs behind counter, and 6 studs around either end. Do not reduce crossing sightlines or block vehicle-free pedestrian route. Eight participants can split between booth and home display |
| `Q03BedroomDisplay` | Bedroom source has desk/shelf wall and notes identify the desk/craft/display context; exact display socket is not a current contract | Proposed display socket on the desk/shelf-facing side, 5×4 interaction area, visible from bedroom central aisle and not in the arrival corridor | One active display interaction plus observers; display must not add a second room or duplicate miniature state. Camera must show miniature and prompt together |
| `Q04QuadReading` | Source places `QuadBenchWest` near `(-72,.05,4)` and `QuadBenchEast` near `(51,.05,78)`; ticket requires existing blossom benches and preservation of Quad interior | Treat the two current bench Instances as candidate anchors; select the bench with live route evidence and expose both if both remain usable. No path/tree movement | Bench interaction footprint 10×8, off the through-route; 4-stud rear clearance and 8-stud path width. Ten players may gather nearby, but only a subset occupies the bench; preserve central cross, diagonals, blossoms, and photo sightlines |
| `Q05UDistrictVending` | Street lane/sidewalk source and storefront order are verified in builder notes: FOB, HeyTea, Aladdins north-to-south; sidewalk remains around x `-140..-134` | Proposed vending machine on the UDistrict side beyond the crossing, outside the sidewalk strip and pedestrian sightline; 4×3 footprint, front facing the safe plaza/side approach | 8-stud approach, 3-stud interaction depth, 4-stud side bypass. Never put it in the road, on a crosswalk, or between shop doors. Camera must keep machine, selected figure display, and fund/status UI legible |
| `Q06FOBCounter` | Current storefront notes identify FOB Poke Bar and its counter; exact counter CFrame must be read from live model. Saved view lists FOB front around `(-101,7.9,-136)` as capture evidence, not a measured contract | Use the existing FOB interior counter as the food station; do not move the shop. Proposed active counter zone 10×6, facing the existing open doorway | Keep 7.6-stud shop doorway and sidewalk unchanged. Two active workers plus observers; route through shop remains two-way and camera must not be trapped behind counter |
| `Q06AladdinsCounter` | Existing Aladdins storefront is north-to-south third shop; saved capture notes list front near `(-101,8.9,60)` as evidence only | Use the existing Aladdins counter for the complementary station; no new menu or real-world claim here. Proposed 10×6 active zone | Same doorway/sidewalk rules as FOB. Two active workers plus observers; no food props across the threshold |
| `Q06Serving` | Current courtyard source has base centered near `(120,.12,64)`, table around `(114,3.7,66)` and eight existing seats in the decorated party area | Q06 serving may stage near the two named shops, but `Q06Serving` must not consume the cake table/patio. Proposed temporary serving surface 12×6 outside the patio approach, pending Q06 draft | Preserve a 10-stud patio approach and 8-stud seat circulation. Cake table remains visually and physically dedicated to finale |
| `FinalePatio` | Source courtyard base 80×120 centered `(120,.12,64)`; saved builder places table near `(114,3.7,66)`, cake at `(114,4.25,66)`, and eight seats | Retain current patio, table, cake, pergola, and eight-seat layout. Add two clearly marked standing/photo positions to reach ten participants, not two extra seats | Ten guests can stand/sit without blocking cake cut, exits, or camera. Keep 10-stud perimeter walking lane and 6 studs behind every seated chair. No forced warp or camera lock |
| `BirthdayLobbyQueue` | Source lobby notes describe an enclosed lobby near `(2000,0,0)` and a current personal timer/pad system; this wave supersedes it with one shared queue square and free waiting lobby | Queue square is a lobby anchor owned by Task 08. Proposed 16×16 square with 4-stud perimeter, readable from lobby spawn, one shared 60-second deadline, capacity 10 | Eleven receives a graceful full response. Queue may accept/leave players; no unrelated lobby player transfers. This draft only requires its destination to resolve to `GameplayBedroomArrival` |

## Bedroom arrival sequence and occupancy contract

1. A queued party transfers to a gameplay server. Server resolves the current bedroom anchor and a generation-specific arrival roster; it does not reuse lobby coordinates or assume the saved offset.
2. The server reserves ten unique slots before moving characters. Each slot is validated against room geometry, avatar capsule size, bed/Jasper/door footprints, and the current occupancy. If fewer slots are valid, the transfer is held/retried or fails safely; it must not stack players.
3. Characters arrive standing on the floor with independent third-person cameras. There is no mandatory cinematic, forced sleep, or shared camera lock. The camera may briefly frame the room only if control remains available immediately.
4. The HUD identifies the session and six-petal shared progress. Arrival text is short and touch-readable; it must not cover the bed prompt or Roblox touch controls.
5. An optional local `Wake/Nudge` interaction may be offered near the bed for a brief contextual animation. It is not required for Q01, does not advance the petal, does not reset the room, and can be cancelled by movement or another player.
6. Jasper begins indoors at `JasperBedroomStart`, greets without blocking movement, and exposes the Q02 handoff toward `JasperFetchYard`. If navigation stalls, Q02 must expose its solo-friendly outdoor fallback; this plan does not invent the fallback mechanic.
7. Players may approach Q01, the desk display, Jasper, or the door in any order. Leaving and returning to the bedroom preserves session progress; reconnecting to the same running birthday session restores the session state, not the lobby timer. A restarted session starts fresh.

## Ten-player collision and camera checks

The later integrator must run a deterministic occupancy check before enabling the arrival anchor:

- Resolve each candidate spot’s floor ray, avatar capsule overlap, 2-stud neighbor buffer, door-swing exclusion, bed/Jasper/desk/closet exclusion, and route connectivity to the door.
- Reject any spot whose camera ray from avatar head to a 10-stud look target intersects the ceiling, wall, or a required prompt anchor at normal zoom. Test both shoulder directions and touch camera orbit.
- Simulate ten avatars entering in arbitrary order, then remove three, reset one, and rejoin one. Existing players keep their positions where safe; the replacement receives a newly free validated slot.
- Walk ten avatars from arrival to bed, Jasper, desk, and door. No player may be forced through furniture, outside the room, into the bed, or into another player by server placement.
- Check normal-speed traversal in desktop, tablet, and phone emulation, including thumbstick space and prompt reachability. This is a later Studio/device/group gate, not proven by this document.

## Controls, cancellation, replay, reconnect

All station interactions use a server-validated action identity and the shared activity contract: session identity, activity/round identity, action identity, contributor identity, accepted step, completion receipt, once-only petal, and once-only fund reward. Touch uses a large contextual button; desktop supports proximity prompt and keyboard/action equivalent. Movement cancels a pending local preview without cancelling other players’ accepted work.

Placement does not own quest replay rules. It requires that Q01–Q06 leave their approach/exit lanes usable after completion, keep completed props inspectable, and allow explicit replay only through the activity owner. Rejoin restores the running session’s shared state and revalidates physical placement. Duplicate teleport, duplicate action, reset, late arrival, and partial transfer must be idempotent; no duplicate petal or reward may result.

## Acceptance scenarios

| Scenario | Expected outcome |
|---|---|
| Ten-player party arrives together | All ten appear in unique floor-safe bedroom spots; no one is on the bed, Jasper, desk, door swing, or another avatar; every player can walk out |
| Arrival with one blocked candidate | Server skips the blocked spot or safely retries; it never stacks or places a player outside the room |
| Player walks to Q01 | Bed is visible from the approach, prompt is reachable on touch/desktop, and central/east circulation remains open |
| Player talks to indoor Jasper then follows route | Jasper start does not block arrival; route to the existing yard/gate is traversable and fetch lane remains separate from gate circulation |
| Q03 booth and bedroom display used by concurrent players | Booth is beside, not in, the crossing/sidewalk; bedroom display is visible and both refer to one shared miniature state |
| Q04 group photo | Existing Quad cross/diagonal/path/tree geometry is unchanged; benches are off-route and visible without blocking travel |
| Q05 machine and Q06 shops | Machine does not obstruct crossing or sidewalk; FOB/Aladdins counters remain inside existing door/route envelopes |
| Ten guests gather for cake | Existing eight seats plus two standing/photo positions support ten; cake cut and patio exits remain reachable without auto-warp |
| Reset/rejoin during session | New character receives a safe bedroom or session-valid location; progress is restored for same session, lobby queue/timer is not restarted |

## Required downstream updates before implementation

- PCW-03: replace generic map destination language with the named anchor contract and require current `Home.Floor.Position`/Instance-derived translation, not copied proposal coordinates.
- PCW-04: add `GameplayBedroomArrival`, ten-slot occupancy validation, door-swing/ceiling camera checks, and the single-room 10-player circulation target while preserving bed/desk/closet routes.
- PCW-05: add crossing-side `Q03FairCraft` and `Q05UDistrictVending` reservations; explicitly preserve the 24-stud road, continuous sidewalk, shop order, and 7.6-stud shop openings.
- PCW-06: add `Q04QuadReading` as an existing-bench anchor and prohibit changes to Quad interior path/tree geometry; require outside-edge additions only.
- MAP-02/MAP-03: bind the named anchor inventory, current-source/live-place CFrame capture, ten-arrival route evidence, patio ten-person evidence, and preservation comparison. Do not treat existing screenshots or source coordinates as live proof.
- PCW-07–12: each activity draft must declare its station footprint, approach/exit clearance, observer capacity, and camera target against these anchors; no activity may move the shared anchors independently.
- PCW-13/14: reference the shared session/reward contract and patio reservation; money/petals/cake state must not be inferred from physical location alone.
- PCW-16 and verifier contracts: add ten-player bedroom arrival, touch/desktop camera/route checks, reset/rejoin, crossing/sidewalk obstruction, and ten-person patio scenarios. These need live Studio and mixed-device/group evidence.
- PCW-17 / Task 08: retire the old per-player lobby countdown/individual entry assumption for this wave and specify one queue square whose successful destination is this bedroom anchor.

## Bounded later implementation checklist

1. In Studio, capture current CFrames/sizes for `Home.Floor`, `Home.FrontDoor`, `Home.Bedroom`, bed, Jasper, both park gates, Quad benches, crossing, FOB/Aladdins counters, courtyard/table/cake/seats, and lobby queue square.
2. Create a read-only anchor manifest with source path, live CFrame, footprint, orientation, and owning ticket; flag missing anchors instead of fabricating them.
3. Implement server-side bedroom slot reservation and collision/camera validation, then add the optional non-blocking wake prompt.
4. Integrate activity-owned footprints one at a time, checking route widths and sightlines after each addition.
5. Run the acceptance scenarios with 2, 8, and 10 simulated/real participants across desktop/tablet/phone emulation; include reset, disconnect, rejoin, late arrival, and duplicate-action cases.
6. Hand the manifest, Studio captures, navigation logs, and device/group results to an independent verifier. Do not mark this draft or any ticket final from documentation alone.

## Unresolved choices and evidence still required

- Exact live CFrames, floor heights, avatar capsule dimensions, and whether both Quad benches remain valid must be captured from the installed place.
- Task 08 must settle the shared queue object and teleport/transfer failure policy; this draft only defines its destination anchor.
- Q02 must choose the exact indoor Jasper route and outdoor fallback; Q06 must choose its serving surface without consuming the patio; Q03 must choose booth side after live crossing sightline inspection.
- The optional wake interaction’s wording/animation is intentionally open and must not become a required quest step.
- Published Roblox multi-server transfer, ten real participants, mixed-device controls, performance, and human comfort/fun remain unverified. Source coordinates, saved screenshots, harness passes, and this design cannot certify them.

