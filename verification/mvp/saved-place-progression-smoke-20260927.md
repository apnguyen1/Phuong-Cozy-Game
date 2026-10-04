# Saved-place progression smoke — 2026-09-27

Status: one-player local Studio progression smoke passed. This is not final ticket acceptance or an 8–10-player/device rehearsal.

- Build: `roblox/phuong-cozy-game.rbxl`, 1,739,536 bytes; native save September 27, 17:47:14 Pacific, then closed and reopened.
- Studio: `41aeca53-fc7d-4a04-9233-99b2b9734ec4`.
- Package SHA-256: `D85456C6C543FEBE63001C797F500126D4475334B27E3E839CBE8291483AE58E`.
- Independent read-only comparison against reopened actual Script.Source: expected 31, exact 31, normalized-only 0, mismatches 0.
- Real local player: IamBannedrew, user ID 1078077474; session `MVP-1790556552`. Phuong was absent, so the configured host fallback was exercised. No player identity, fund, petal, draw outcome, or role was injected.

## Method and observed outcomes

The test positioned the real character at each required activity anchor using temporary Play-mode positioning. This does not prove walking routes or camera clearance. The test-only client probe used the real RemoteEvent and the exact server-offered GetView action descriptors, with fresh action IDs; Main stamped authenticated actor identity and performed proximity checks. Visible mouse-clicked UI controls separately exercised Q01 reserve/place, cake opening/invite/cut/eat, Q06 replay, and the journal.

| Activity | Observed outcome | Shared fund after first completion |
|---|---|---:|
| Q01 Everything Tucked In | Seven bed steps, authorized finish; first reserve/place accepted through actual buttons | 20 |
| Q02 Jasper | Bedroom greeting, yard basket/rabbit return, three fetches, Greenie completion | 40 |
| Q03 Tiny World | Six reserve/place pairs and authorized lamp presentation | 60 |
| Q04 One More Chapter | 316-character reading text rendered; highlight, reaction, bookmark, Save completion | 80 |
| Q06 Something Delicious | Base/protein/toppings at FOB, sauce at Aladdins, two settings at serving station | 100 |
| Q05 Labubu Wish | Wanted secret selected; five real 20-unit purchases; fifth awarded the wanted secret and sixth petal | 0 |

Q05 outcomes were BigIntoEnergy03, BigIntoEnergy03, BigIntoEnergy03, BigIntoEnergy06, BigIntoEnergySecret. The first four missed the selected wanted figure; the fifth guarantee fulfilled it. Collection copies displayed 5 and the last awarded label displayed Secret figure. No random outcome provider was overridden.

Cake button became visible at six petals. Opening it did not invite automatically; real UI clicks changed cake state LOCKED → INVITED → CUT → EATING. The HUD showed `6 / 6 petals • Cake ready` and shared fund 0.

Q06's actual Replay button then created `round:Q06:7`, displaying 0/6 instead of the previous completed round; its next valid serving action reached 1/6 while fund stayed 0 and all six existing petals remained. This run did not complete the replay; independent source tests cover its 10-unit once-only replay reward.

The journal rendered all six completed petal entries. Console output contained only the server integration startup line with no missing anchors; no production errors or warnings were observed. Play was stopped and Studio returned to Edit. The Play session and test probe were not saved into the place.

Raw event and UI result evidence: `verification/mvp/live-route-result-20260927.json`. Test-only probe: `verification/mvp/live-client-route-probe.luau`.

## Earlier queue evidence and remaining gates

The unchanged final Main/client hashes were tested earlier with the physical one-player queue: empty reset, real 60-second countdown, and transfer to assigned BedroomArrivalSlots.Slot01 passed. See `engine-smoke-final-20260927.md`. This newer progression run positioned the character directly for focused activity checks and did not repeat the 60-second queue test.

Still unverified: real 8–10-person concurrency and the eight-player countdown shortening, phone/tablet controls, walking/camera clearance, reconnect and late join in a live multiplayer server, human fun/visual acceptance, and published reserved-server transfer. GameplayPlaceId remains unconfigured; Studio uses the local party transfer adapter. No publishing or upload occurred.

Diagnostic follow-up: successful cake responses also contain an unused `errorText` string representation of the result table due to Lua's `ok and nil or ...` expression in Main. The `ok=true` UI path showed accepted actions correctly; this did not block progression, but response cleanup remains a nonblocking follow-up.
