# Phuong-Cozy-Game

A personal Roblox birthday game dedicated to my Pookie. Friends explore, decorate, enjoy her favorite things, and celebrate together.

## Agreed Roblox plan

**Stage: approved map plan, visual concepts, and implementation tickets. No gameplay code or published experience yet.**

- **Platform:** Roblox, with mobile, tablet, and desktop support from the start.
- **Players:** Phuong, her boyfriend, and real friends participate together in the same session, designed for 8–10 players.
- **Camera:** Freely rotatable third-person view; each player keeps their own camera during activities.
- **Experience:** Cozy exploration, decoration, and personal activities, aiming for about 30 minutes before open-ended social time.
- **World:** A compact connected neighborhood with Phuong’s bedroom house, Jasper’s yard, a UDistrict street fair, the UW Quad, and a cooking/birthday patio.
- **Interior:** Only Phuong’s bedroom is detailed, based on the supplied photos. The earlier four-room house is superseded.
- **Celebration:** Six activities build toward cake and birthday wishes from the actual participants. The boyfriend writes the personal note himself; its content remains empty until supplied.

One Roblox place is the current planning baseline. Dimensions, camera tuning, shared-progress permissions, and device performance targets still need later validation. The warm miniature art treatment remains a visual proposal; the user supplied the exact palette on September 24 in [verification/palette.json](verification/palette.json).

## Six favorite activities

| Activity | Main location |
|---|---|
| Everything Tucked In | Green-sheeted bed and weighted dog/dinosaur plushies |
| Jasper’s Favorite Things | Yard, rabbit toy, fetch, and Greenie |
| A Tiny World of Her Own | Bedroom desk, with an optional shared fair craft booth |
| One More Chapter | Kindle at home or a Quad bench |
| A Labubu Wish | Street-fair vending machine, with an optional bedroom collection display |
| Something Delicious | Patio KBBQ, seafood boil, and table setting |

All activities must support touch as well as desktop input. Decoration uses proposed curated choices and generous placement slots. The group can contribute in parallel, and readers work at their own pace.

The [Mini Game Idea Plan](docs/design/mini-game-idea-plan.md) records the deeper gameplay for all six activities. Q05 now uses personal coins earned through the other five activities to roll for Big into Energy Labubu figures, with gifting and a fifth-roll guarantee for the selected wanted figure. This plan supersedes the earlier treasure-hunt design; detailed ticket and verifier alignment remains the next implementation step.

## Map and visual concepts

- [Approved map proposal v0.2](docs/design/map-proposal-v0.2.md) — zone placement, room layout, street/Quad references, mobile design, and build sequence.
- [Visual direction and UI brief](docs/design/visual-direction-v0.1.md) — palette, interface states, and review notes on the renders.
- [Map and color concept](docs/design/concepts/map-color-concept-v1.png).
- [Mobile interface concept](docs/design/concepts/mobile-ui-concept-v1.png).
- [Image-generation prompts](docs/design/concepts/generation-prompts.md).

![Map and proposed color palette](docs/design/concepts/map-color-concept-v1.png)

![Mobile exploration and decoration UI concept](docs/design/concepts/mobile-ui-concept-v1.png)

These are rendered design concepts, not screenshots of a working Roblox game. The dimensioned map plan governs layout when an illustration differs. The photos inform recognizable details; the world does not recreate her Stardew farm.

## Dedicated tickets

[The ticket board](docs/tickets/README.md) contains 16 local project tickets with scope, dependencies, acceptance criteria, and validation steps. They cover art and UI, world/camera layout, the bedroom, UDistrict, the Quad, all six activities, shared progress, celebration, personal content, and mixed-device rehearsal.

Future game implementation begins with the room/camera and touch interaction prototype, then connected reference geometry, shared activities, personal detail, and a group rehearsal. Ticket creation does not start that implementation.

## Verification workflow

The [verification system](verification/README.md) adds a reusable verifier agent, exact palette checks, ticket acceptance gates, Roblox evidence capture, and a build–review–revise loop. All 16 ticket contracts begin as drafts until their actual deliverables and test commands are assigned. Automatic checks are followed by independent review and human playtesting/final acceptance. No gameplay implementation or publishing is included.

## Earlier planning references

- [Historical map proposal v0.1](docs/design/map-proposal-v0.1.md).
- [Living design v0.4 — preserved source snapshot](docs/design/references/Phuongs-Cozy-World-Living-Design-v0.4.md).

The approved v0.2 map and later explicit user decisions take precedence over earlier material. Browser-game delivery, mobile-later scope, the four-room interior, and NPC friends arriving only at the finale are superseded.
