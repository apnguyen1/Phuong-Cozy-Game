# PCW-20 delivery

Status: **IMPLEMENTED_PENDING_INTEGRATION**. Builder: guided_food. October 3, 2026.

## Changed files and installation

| Source | Install as |
|---|---|
| `roblox/mvp/server/activities/Q06.luau` | ModuleScript `ServerScriptService.PhuongMVP.server.activities.Q06` |
| `roblox/mvp/server/FoodFeedback.luau` | ModuleScript `ServerScriptService.PhuongMVP.server.FoodFeedback` |
| `roblox/mvp/shared/FoodPresentation.luau` | ModuleScript in **both** `ServerScriptService.PhuongMVP.shared.FoodPresentation` and `ReplicatedStorage.PhuongMVP.shared.FoodPresentation` |
| `roblox/mvp/client/extensions/Q06Food.luau` | ModuleScript `ReplicatedStorage.PhuongMVP.client.extensions.Q06Food` |
| `roblox/mvp/server/Main.server.luau` | Existing Script `ServerScriptService.PhuongMVP.server.Main` |
| `roblox/mvp/client/activities/Q06.luau` | Existing compatibility/presentation descriptor at `ReplicatedStorage.PhuongMVP.client.activities.Q06` |

Install the shared dependency in both trees before enabling Main or loading the extension. FoodFeedback requires `script.Parent.Parent.shared.FoodPresentation`; Q06Food requires `script.Parent.Parent.Parent.shared.FoodPresentation` and the existing Guidance module. Q06Food registers through PCW-18 `Init(getContext, registry)`, `RegisterActivity("Q06", ...)` and `RegisterObserver("Q06Food", ...)`. The real renderer and Main construction are wired; the static client activity descriptor alone is not the live UI.

No Q06Station builder change or builder run is required. No saved scene, original furniture, account ID, permission rule, SessionService economy setting, birthday note or audio source was changed. Main retains PCW-19 canonical actor/session/World/proximity checks, recipient-specific UI copies and activity views, reservation cleanup, Q01 expiry revisions, and the live `CozyAudio.Accepted` hook. Main's prior mixed line endings were normalized to UTF-8 LF while retaining its existing behavior and adding the Q06 integrations below. PCW-26 still owns permanent audio-source installation.

## Exact behavior

- Recipe guidance starts with FOB bowl → Aladdins sauce → serving table. All three existing prompts open the same shared Q06 round, including partial work and a completed dish. Opening the wrong current counter gives a destination and Track next counter with no distant ingredient cards.
- Six required slots remain: base, protein, toppings, sauce, settingA and settingB. The three FOB slots may be completed in any order/by different helpers. All three unlock the sauce step at Aladdins; sauce unlocks the two table settings, which may also be completed in either order. There is no required timing, gesture, typing, extra quest or carrying step.
- All original variants remain exact: rice; tofu/chicken/mushroom; greens/cucumber/carrot; sauce/sesame; left plate/napkin; right cup/napkin. Selecting a card and using Preview creates only a held selection. A labeled preview says Not added yet; the explicit Add/Place descriptor commits that exact held item. Selecting another allowed variant releases the previous hold. There is no implicit reserve-to-commit behavior and no default-food substitution.
- Holds belong to one actor and one slot; helpers can reserve different slots together. Other actors see In use for that slot only. Holds expire after 30 seconds with no pressure countdown, and cancel/close/lobby/reset/disconnect release them. Accepted ingredients survive all of those changes for the running server. An old-round Close cannot release a new-round hold.
- The authoritative dish advances to Aladdins after the FOB ingredients and to serving after sauce. Each accepted item is rebuilt in the one shared dish and listed by friendly slot/item name in the UI. The local viewport renders the same accepted shapes plus only that recipient's selected preview. A preview never appears in the shared world or earns progress.
- Completing all six calls SessionService once: first round adds 20, explicit completed-round replay adds 10, Q06 has one petal. Only `request.replay == true` can create a second round after completion. A new round clears the dish and held choices. Exact duplicate action envelopes replay their receipt without applying progress; changed-identity duplicates and old rounds reject. A fresh action against a completed round cannot pay again.
- Done is explicit. The completed UI points to funded unfinished Labubu, another incomplete activity, or Cake when all petals are complete. The existing Play again action stays optional.

## Main integration and source contract

`world.foodVenue(actor)` derives the closest existing food anchor within 24 studs from the real living character, only in World. This resolves the overlapping FOB/serving approach areas instead of trusting a client venue string. Main retains its slot-specific proximity guard; Q06 also checks current venue and recipe stage. A stale action after walking away returns a fresh view and friendly next-counter message without mutating food.

The existing one-second reservation service also observes Q06 expiry revisions and changes to open Q06 recipients' current venue. It broadcasts when those change, not every tick. Successful selects, additions, opens and closes use the existing per-recipient broadcast path. Closed panels stay closed. Expiry discovered while producing a view still reaches other helpers through the revision counter. The current generic renderer's `MainAction` is hidden by Q06Food only for a distant/completed view, its `TrackNextStep` label becomes Track next counter, and the extension preview mount is ordered before explicit Add/Place. It does not edit Main.client or UI.

No new remote kind. Use actual current descriptors with the existing canonical envelope:

```lua
{ kind = "ActivityAction", sessionId = currentSessionId, activityId = "Q06",
  roundId = currentRoundId, actionId = uniqueActionId,
  stepId = descriptor.stepId, payload = descriptor.payload }
```

| Operation | stepId | payload |
|---|---|---|
| Preview an allowed choice | Slot ID | `{action="select", slotId=slotId, itemId=itemId}` |
| Explicit Add or Place | Same slot ID | `{action="add", slotId=slotId, itemId=itemId}` |
| Put back held selection | Held slot ID | `{action="cancel", slotId=slotId, itemId=itemId}` |

The server requires `stepId == payload.slotId`, verifies the held item again on Add, and binds action receipts to actor, round, step, operation, slot and item. It rejects SessionService action IDs already used outside its own receipt path. Existing view fields remain, including foodDisplay, acceptedStepIds, progress and actorUserId. New fields: recipe, currentVenue, nextVenue, atCounter, nextActivity, dishSummary, held and guide. `foodDisplay` is the accepted receipts only; `held` contains this recipient's selected item/slot/label/destination/expiry only. Other actors' private holds are never sent. The historical direct Reserve/Cancel helpers are replaced by canonical Apply operations.

## World presentation ownership

New world instances exist only under `CozyWorld_Draft01.MVP.RuntimePresentation.FoodFeedback`. The folder owns one `SharedDish` model and three invisible route-label cues. It never destroys, moves or recolors the existing counters or any original furnishings.

FoodFeedback resolves `MVP.Stations.Q06Station.<anchorName>.ActionSurface` and places its mat just above that surface. If the existing surface is missing, its fallback uses the current Q06Station builder's anchor-relative surface height of 2.205 studs; final integration must inspect that fallback against the actual saved scene rather than assuming it has been measured. The existing anchors remain Q06FOBCounter, Q06AladdinsCounter and Q06Serving from the supplied scene manifest. No patio relocation occurs.

The mat is 6.5 × 2.8 studs within the builder's 8 × 3 action surface. The source has a maximum of 41 dish BaseParts for the largest combination plus three cue parts; the dish is replaced only on accepted progress/new round, so replay does not accumulate models. All authored BaseParts are anchored, noncolliding, nontouching, nonqueryable and tagged PCW-20 with exact palette tokens. No mesh, imported texture, physics, dynamic light, particle emitter or avatar/camera movement is introduced.

Shapes distinguish every variant: cream rice/Tofu cubes, golden rounded chicken, wood mushroom caps/cream stems, sage leaves, forest/sage cucumber rounds, golden carrot strips, wood sauce lines, golden sesame seeds, cream/sage plates, cream cups and folded sage/cream napkins. Golden is the approved stylized carrot/chicken/seed color, not an invented orange. The two optional napkins occupy their separate table spots and do not silently create a plate or cup. Palette and visual identity still require independent review in actual lighting.

## Deferred checks and limits

No tests, compilation, Studio access, playthrough, save or publication occurred. Source was read for delivery completeness only; this is not verification PASS or human visual/fun acceptance.

- Install both FoodPresentation copies and the extension recursively. Compile at the final stage. Exercise actual generic-client descriptor cards → Preview → Add/Place, and confirm the preview/action order and 52-pixel controls on phone/tablet/desktop, including scroll depth and Back/Close.
- Update `roblox/mvp/tests/Q06.spec.luau` before final execution: its old fixture has no `context.foodVenue`, calls removed Reserve/Cancel helpers, commits without select, omits explicit replay, and expects exceptions rather than friendly result tables. Use current descriptor envelopes and a server venue stub; do not loosen production guards to satisfy stale fixtures.
- Check all original variants, including both napkin slots together, UI summary/preview/world agreement, six accepted slots and first/replay rewards of 20/10 exactly once. Attempt altered duplicate action IDs, old-round actions/close, repeated completion, and simultaneous replay requests.
- Two real clients: different slots concurrently; same slot contention; replacing your held variant; add after expiry; close/cancel/reset/lobby/disconnect release; late join/rejoin; accepted progress survives counter travel and panels close without losing the dish.
- Walk between FOB and the nearby serving station with Q06 open, then between FOB/Aladdins/serving. Only current-stage current-venue actions should appear; stale actions must show Track guidance. Verify nearest-counter behavior and marker clarity at overlapping approach boundaries.
- Inspect the real surface and fallback height, the one-dish move at venue transitions, simple food silhouettes, exact palette, route-label readability, counter/road clearance and independent camera movement. An accepted final FOB ingredient immediately advances the whole dish to Aladdins; the route labels and UI must make that shared transition clear.
- Repeated selection and replay should leave one world dish and one mounted local preview with no accumulation. Verify final client/server bandwidth/frame time with the release group; recipient-specific snapshots carry accepted receipt data in foodDisplay as before.
- Regression-check Q01 expiry, all existing activities, live CozyAudio/CozySoundEffectsClient behavior and the later music/host/finale extensions. No audio implementation was replaced here.

Persistence remains session-only. Phuong/Andrew identity and the personal birthday note are unchanged.
