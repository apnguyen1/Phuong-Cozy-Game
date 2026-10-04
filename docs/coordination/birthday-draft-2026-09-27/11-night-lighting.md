# Task 11 — Cozy nighttime lighting draft

Status: implementation-ready design proposal; not implemented, imported, or Studio-verified.

This draft owns the nighttime look and readability of the bedroom, birthday lobby, UDistrict, Quad, connecting routes, and finale patio. It keeps the waking introduction at night, preserves an attractive visible sky, and uses the existing eight-color world palette. All Roblox property values below are proposed starting points, not measured or tested facts.

## Scope and authority

Confirmed direction:

- The gameplay session begins inside Phuong's existing detailed bedroom at night, with Jasper present and no mandatory cinematic.
- The world supports eight real friends as the target and ten simultaneous participants as the capacity.
- Independent third-person cameras, touch/tablet/desktop access, readable figures/avatars, and safe navigation remain required.
- Seattle-inspired perimeter facades conceal unfinished edges without becoming an opaque fog wall; the night sky remains visible.
- Exact world palette is authoritative: forest `#365744`, sage `#A8B995`, cream `#F5F0E4`, wood `#95674B`, blossom `#E8B7C6`, brick `#B66C68`, golden `#E8C779`, ink `#26382E`.
- Textures and materials remain unchanged unless separately approved. Light can change perceived color, but does not authorize new base colors.

The following are coordinator defaults/proposals, not separate user approvals: Lighting property values, light counts/ranges/brightness, atmosphere density, exposure, clock time, sky asset choice, per-zone budgets, and the exact placement offsets. No downloaded sky asset is specified or assumed.

## Visual targets and palette handling

The intended read is “warm bedroom window at night, softly lit neighborhood, blossom-lit Quad, welcoming cake patio.” Golden is the light-warmth/completion accent, not a license to turn every surface yellow. Cream remains the readable light surface and UI text color; ink remains the dark outline/text color; forest remains wayfinding and action emphasis. Blossom is reserved for flowers/celebration accents, brick for paths/masonry, wood for floors and furniture, and sage for soft furnishings/secondary surfaces.

Lighting changes perceived color only. Base Part Color3, texture maps, SurfaceAppearance maps, and approved exceptions must still be checked against the palette workflow. Do not “fix” a too-dark or too-bright screenshot by recoloring the authored asset without a palette/design decision.

## Proposed global Lighting setup

Create one server-consistent nighttime Lighting configuration and tune locally by zone. Proposed starting values for a later Studio pass:

| Setting | Proposed start | Purpose / caveat |
|---|---:|---|
| ClockTime | 22.0 | Clearly night while retaining sky color; verify against the final sky asset. |
| Brightness | 2.0 | Moderate baseline; tune against low-graphics screenshots. |
| ExposureCompensation | 0 to +0.15 | Avoid crushed bedroom/route shadows; do not wash out cream. |
| GlobalShadows | true | Keep form and route cues; test mobile cost. |
| Technology | Future/ShadowMap, platform-tested | Select the supported production mode after profiling; do not claim either is live now. |
| Ambient | forest-tinted, low intensity | Proposed Color3 near forest, not a new palette color; exact value requires Studio inspection. |
| OutdoorAmbient | ink/forest-tinted, low intensity | Keeps outdoor forms visible without a daytime fill. |
| EnvironmentDiffuseScale | 0.35–0.5 | Suggested range; tune for avatar skin and cream readability. |
| EnvironmentSpecularScale | 0.1–0.2 | Suppresses distracting shine on simple props. |
| ShadowSoftness | 0.7–1.0 | Suggested range for cozy edges; verify on stairs, doorways and avatars. |

Use an authored sky or the project's already-approved sky reference if one exists. This draft does not invent or download a sky texture. The sky must show stars/cloud gradient/open darkness without an opaque horizon fog. If an Atmosphere is used, begin with Density 0.05–0.10, Haze 0.0–0.2, Glare 0.0–0.05, and Color/Decay derived from approved visible palette roles; these are tuning values only. Atmosphere must not erase facade silhouettes, route landmarks, Quad blossoms, or the moon/sky read.

Avoid a single strong global bloom. If post effects are later used, keep Bloom intensity at 0 or very low (proposed maximum 0.08), threshold high enough that golden accents do not halo, and test text/UI separately. Decorative bulbs should generally be emissive/bright-looking parts or SurfaceLight-free accents; only navigational and interaction-critical lights should cast dynamic shadows.

## Zone plan

The anchor names below are proposed interfaces from the coordination packet. Task 01 must replace them with measured Instance paths and local offsets before implementation.

| Zone / anchor | Proposed light placement and starting budget | Readability and sightline rules |
|---|---|---|
| Gameplay bedroom / `GameplayBedroomArrival` | 1 warm ceiling/room source, 1 soft desk or bedside source, 1 low-intensity window/fill source; 3 dynamic shadow lights maximum. Suggested ranges 18–28 studs, brightness 0.8–1.8 each. | Bed, Jasper, ten arrival spots, exits, Q01 bed interaction, and desk display must be distinguishable. Keep sleeping/waking context nighttime; do not spotlight the bed so strongly that avatars disappear in silhouette. |
| Birthday lobby / `BirthdayLobbyQueue` | 1 broad neutral-warm lobby source plus 2 queue-square markers; 1 dynamic shadow light for the readable queue area, markers preferably non-shadow. Suggested marker range 10–14 studs, brightness 0.8–1.2. | Queue square, count, countdown, capacity warning, and exit route must remain visible for 10 players. No personal arrival countdown or dark corner that hides a player leaving the square. |
| UDistrict crossing / `Q03FairCraft`, `Q05UDistrictVending`, Q06 counters | One source per activity cluster (craft booth, vending, food counters), plus route lamps at turns; target 4–6 dynamic shadow lights across the block, not one per bulb. Suggested range 16–24 studs, brightness 0.7–1.4. | The crossing stays readable as a route. Keep vending outside pedestrian flow; distinguish Q03 booth, Q05 machine, FOB/Aladdins counters and `Q06Serving` with golden/cream focal accents while facades stay subdued. |
| Bedroom-to-UDistrict route | Low, repeated wayfinding accents at entrances/turns, preferably emissive or non-shadow; target 1 route light every major decision point, not continuous bright strips. | Players can navigate without staring at UI. Never use glare, flashing, or a bright line that bypasses the intended route. Preserve open sky between facades. |
| Quad / `Q04QuadReading` | Soft blossom canopy uplight/fill around the existing trees; proposed 2–4 lights for the whole reading area, range 18–26 studs, brightness 0.5–1.0. | Do not alter existing interior tree/path geometry. Blossoms read pink in direct and low graphics; brick paths remain distinct; benches and bookmark interaction remain readable. Avoid lighting the whole Quad as a stage. |
| Outer Quad trees and boundary | Low ambient/facade separation lights outside the existing Quad; target 2–3 non-shadow sources. | Exterior trees can frame the area, but must not cast noisy shadows across the reading benches or block sky sightlines. |
| Cake patio / `FinalePatio` and `Q06Serving` | 1 broad patio fill, 2 soft cake/serving accents, 2 seating-area accents; target 4 dynamic shadow lights maximum. Suggested range 18–24 studs, brightness 0.7–1.3. | Cake, cutter, food, ten seating positions and guest avatars remain identifiable. Warmth is celebratory but not glare; patio remains open to sky and does not auto-darken after a petal completes. |
| Seattle-inspired perimeter | Facade-facing low fill or reflected-looking accents at 3–5 key silhouettes; no opaque fog wall. | Hide unfinished edges through silhouette, depth, and darkness. Do not create a bright ring around the map or a hard horizon seam. |

These budgets are per active zone, not a promise that all lights are simultaneously active. A later implementation should use a small reusable light set and distance/zone activation where safe, while keeping server/client state deterministic enough that participants see the same gameplay-critical highlights.

## Exact player sequence and states

1. A player enters the lobby and sees a nighttime sky, readable facades, the join square, and the queue UI. No personal timer starts merely from arrival.
2. The first entrant opts into the square. The server-owned shared queue begins its 60-second window. Lighting does not change by player count.
3. Other players enter/leave the square. Queue count, remaining time, capacity ten, and the route back out stay readable in both low and high graphics. At eight queued players the deadline may shorten to at most ten seconds; this is a state/timing rule, not a lighting transition.
4. The frozen roster transfers to the gameplay server. Each player arrives at a distinct bedroom arrival spot under the same nighttime configuration; no one is placed on the bed, inside Jasper, or blocking the exit.
5. Players can optionally wake/interact in the bedroom. The light supports the contextual action but never forces a camera lock or daytime reset. Jasper is visible indoors.
6. Players travel to Q01–Q06. Each activity anchor has one readable focal cue, while route light remains subdued enough that players can see landmarks and the sky.
7. After the six shared petals unlock the finale, players walk to the patio. The cake/fund/seat interactions use the patio accents; no forced warp or cinematic lighting change is required.
8. Completion, cancel, replay, disconnect, and rejoin preserve session state and activity permissions. Lighting is scene state, not reward state; a reconnect must not reset the world to daytime or remove required route cues.

## Concurrent roles for 8–10 participants

Lighting must support multiple simultaneous actions without moving spotlights or hiding players: two bedroom/Q01 players, two Jasper/Q02 players, two UDistrict players (Q03/Q05/Q06), two Quad readers, and up to two roaming/rejoining guests. The plan intentionally avoids per-player highlights. Activity-specific UI/action cues and the shared palette do the disambiguation. At ten players, avatar faces, skin/appearance readability, interaction prompts and nameplates must survive crowd overlap and shadow; if not, lower shadow softness/dynamic-light count before raising global brightness.

## Controls, UI text, and accessibility

Desktop and touch use the same interaction targets and state feedback. Proposed UI copy is functional, not personal birthday-note text:

- `Night lighting: low-detail mode` / `Night lighting: detailed mode` may appear in settings if the final graphics toggle exposes this choice.
- `Queue: 8/10 · 00:09` and `Join square` / `Leave square` must remain cream/ink readable over the background.
- `Interact`, `Wake`, `Read`, `Craft`, `Wish`, `Serve`, `Cut cake`, and `Eat` use the existing PCW-02 interaction treatment; do not encode meaning by light color alone.

Touch hitboxes must not depend on a tiny glowing bulb. Desktop prompts and touch buttons need contrast in both tiers. Do not add or paraphrase the personal birthday note.

## Graphics tiers and budgets

High/detailed mode may use the proposed shadow-light budgets, full atmosphere, and subtle soft shadows. Low/mobile mode should:

- disable or reduce nonessential dynamic shadows and post effects;
- retain one readable bedroom source, one lobby/queue source, one source per active activity cluster, one Quad reading fill, and one patio fill;
- retain sky visibility, route landmarks, queue UI, activity focal points, avatars, Jasper, cake, and interaction prompts;
- avoid particle-heavy stars, animated flicker, screen-space glare, and one-light-per-window decoration;
- be measured on a representative phone/tablet and desktop with 10 avatars, not inferred from editor appearance.

Proposed starting caps are 12 shadow-casting lights visible in high mode and 6 in low mode, with zone culling where it does not pop a required interaction cue. These are performance hypotheses, not Roblox limits or passing results. Record frame time, memory, draw calls/lighting cost if available, and screenshots from the same camera list in both tiers.

## Before/after camera evidence list

For each camera, capture high and low graphics, empty/8-player/10-player crowd states where practical, and day/night comparison only as a diagnostic (the shipped state remains night):

1. Bedroom arrival: bed, Jasper, ten arrival spots, desk, door and window/sky.
2. Bedroom Q01 close approach: tuckable objects and interaction prompt without glare.
3. Lobby queue square: join/leave affordance, queue count/timer, ten-player crowd and exit.
4. UDistrict crossing approach: facade skyline, craft booth, pedestrian route and open sky.
5. Q05 vending approach: machine controls readable outside the crossing route.
6. Q06 food approach: FOB/Aladdins counters, serving point and crowd clearance.
7. Route junction: two alternative directions, landmark visibility and no dark navigation trap.
8. Quad bench: blossom canopy, brick path, reading interaction and surrounding trees.
9. Patio wide: cake, ten seats, sky, facades and all route approaches.
10. Patio close: cake/cutter/food interaction, avatar skin/face readability and no golden bloom clipping.

Required comparisons are visual evidence only until an independent reviewer confirms the source scene, device, graphics tier, and revision identity. A screenshot cannot prove interactivity, performance, or live-server consistency.

## State, permissions, cancellation, replay, reconnect

Lighting is a server/session configuration selected at place load, with client graphics quality allowed to reduce nonessential effects. It must not change quest ownership, the shared birthday fund, petals, wish selection, or cake permissions. A player leaving an activity, disconnecting, rejoining the same session, or replaying a completed activity sees the same nighttime world and the required focal cues. If an effect cannot be streamed or rendered, the fallback is a simpler non-shadow/emissive cue, not a gameplay lock or a reward change.

If a zone is temporarily unloaded, its anchor must expose a safe, lit approach before interaction becomes available. Duplicate clients must not create duplicate dynamic lights. Late arrivals use the same active-session nighttime configuration.

## Dependencies and required downstream changes

Before implementation, update the following rather than treating this draft as approval:

- PCW-01: add nighttime perceived-color guidance, light/material separation, approved sky provenance, and visual checks for golden glare, blossom readability, and avatar/skin readability.
- PCW-02: add low/high graphics controls or documented automatic fallback, contrast requirements, camera/UI screenshots, and touch/desktop interaction text over nighttime backgrounds.
- PCW-03: add measured route/facade/sky sightline anchors and a lighting-zone ownership table; verify independent cameras do not enter unlit voids.
- MAP-02/MAP-03: add exact measured zone light anchors, facade edge-hiding review, open-sky review, and the rule that Quad interior geometry remains unchanged.
- PCW-04/05/06 and PCW-16: add bedroom, UDistrict, Quad, ten-avatar and mixed-device night screenshots plus performance logs. PCW-16 must test eight-to-ten participants, rejoin, late arrival, and crowd readability.
- Verification contracts: add authored Lighting/Atmosphere/Sky configuration and provenance artifacts, per-zone light counts/ranges/brightness, exact palette/base-color checks, before/after camera evidence, and separate Studio/device/human gates. Do not make proposed numeric values automatic pass criteria until a measured budget is approved.
- Task 01 placement draft: replace every proposed anchor/offset with measured scene paths and clearances. Task 10 boundary draft: coordinate facade silhouettes and sky sightlines. Task 12 decoration draft: avoid duplicating bulbs or shadow lights.

## Bounded later implementation checklist

1. Measure current bedroom, lobby, UDistrict, Quad, route and patio anchors in Studio; record the revision and camera transforms.
2. Establish the approved sky source/provenance, then apply one global nighttime configuration using the proposed values as a starting test only.
3. Add the smallest zone light set and mark each light as gameplay-critical, route-critical, or decorative.
4. Capture the ten-camera list in high and low graphics with one, eight and ten avatars where available.
5. Tune darkness, shadow count, range and brightness for queue text, figures, skin/avatar appearance, Jasper, blossoms, cake and route landmarks.
6. Profile representative phone/tablet/desktop hardware; reduce decorative lights/effects until the agreed budget is met without losing required cues.
7. Run independent palette/material review, Studio import/readiness review, mixed-device/group rehearsal, and human fun/readability review. Revise and retest; do not mark this draft or a `READY_FOR_REVIEW` artifact as final acceptance.

## Acceptance scenarios and expected outcomes

1. **Night arrival:** A fresh gameplay roster arrives at ten distinct bedroom spots. Expected: visible night sky/window context, bed/Jasper/door/desk readable, no avatar pile-up or pitch-black corner.
2. **Lobby queue:** Ten players occupy or leave the square. Expected: queue count/timer/capacity and join/leave controls remain readable; no lighting change falsely implies launch or resets when count drops.
3. **UDistrict route:** A player walks from the crossing to Q03, Q05 and Q06. Expected: route decisions, facades, counters and vending machine are distinguishable without glare or a continuous bright strip.
4. **Quad preservation:** A player reads at the existing blossom benches. Expected: original interior tree/path geometry is unchanged; blossom/brick/bench/read prompt remain identifiable in low and high modes.
5. **Cake crowd:** Ten participants gather at the patio. Expected: cake, cutter, food, seats, avatars and open sky remain readable; no player is hidden by a decorative light or hard shadow.
6. **Graphics fallback:** Switch between high and low settings on a supported test device. Expected: required interaction cues and UI remain, while decorative shadows/post effects reduce; no gameplay state changes.
7. **Palette/material review:** Compare base Part colors and texture sources before/after lighting. Expected: no unapproved recolor or invented texture exception; perceived shading is documented separately.
8. **Reconnect/late arrival:** Disconnect and rejoin the active session, then join after another player. Expected: nighttime configuration and required cues persist; no lobby timer restart, reward reset, or unlit spawn.
9. **Sky/perimeter review:** Inspect wide route and patio cameras. Expected: facades hide unfinished edges through silhouette, while the sky remains visibly open and attractive; no opaque fog ring or horizon seam.

## Unresolved choices and evidence limits

- Exact Roblox Lighting technology, supported post effects, sky source, clock time, and Atmosphere values remain unresolved until the actual current place and target devices are inspected.
- Exact light anchor positions/ranges/brightness and whether zone culling is viable require measured Studio geometry and group playtest; the numbers here are proposed starting ranges only.
- The final low/high graphics UX may be an explicit toggle or an automatic quality fallback; PCW-02 must settle this without removing required cues.
- No live Studio import, device profiling, group rehearsal, screenshot comparison, or Roblox server consistency test was performed for this draft.
- This document does not establish production-ready art, approved sky content, Roblox readiness, performance, or user acceptance.
