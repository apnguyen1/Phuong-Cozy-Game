# PCW-18 delivery

Status: **IMPLEMENTED_PENDING_INTEGRATION**. Builder: guided_ui. October 3, 2026.

## Files and installation

| Source | Install as |
|---|---|
| roblox/mvp/client/Main.client.luau | LocalScript StarterPlayer.StarterPlayerScripts.PhuongMVPClient |
| roblox/mvp/client/UI.luau | ModuleScript ReplicatedStorage.PhuongMVP.client.UI |
| roblox/mvp/client/Navigator.luau | ModuleScript ReplicatedStorage.PhuongMVP.client.Navigator |
| roblox/mvp/client/Extensions.luau | ModuleScript ReplicatedStorage.PhuongMVP.client.Extensions |
| roblox/mvp/shared/Guidance.luau | ModuleScript ReplicatedStorage.PhuongMVP.shared.Guidance |

Install dependencies before enabling Main. Existing Action RemoteEvent and server envelopes are preserved. No server source, saved map, installer, activity module, audio script, account ID, economy, or permission rule was modified.

Compared supplied live PhuongMVPClient and read live CozySoundEffectsClient. Sound effects independently bind GuiButtons and listen to Action results. New controls remain ordinary GuiButtons; requests retain the result/action-ID contract. Preserve existing CozyAudio and CozySoundEffectsClient. This ticket does not replace either or replay music.

## Implemented behavior

- Shared birthday goal, fund, six-petal count, next activity, journal and track controls. Journal names all six activities, purposes, destinations, known steps, rewards and completion checkmarks. Optional replay remains explicit.
- Recommendation prefers incomplete nearby activities, then funded Labubu when appropriate, then patio at six petals. Explicit tracking supports any activity, including completed activities for optional revisits.
- Local BillboardGui/Highlight targets existing MVP anchors. Distance and camera-relative left/right/turn-around hints update four times per second. No geometry, player position or camera changes. Markers clear on lobby entry/reset and update for steps/completion.
- Responsive safe-inset panel with separate title row and always-visible 48-pixel Back/Close. Regular buttons are 52 pixels. Side/bottom world/control space remains available; only activity content scrolls.
- Expandable groups, selectable cards with check/outline, one main action, primary hints, progress bar, compact previews and optional activity-specific preview mounting area. Disabled cards show reasons. Their group heading remains usable, but unavailable cards cannot select/submit.
- Confirmation for spending, locking a Labubu wish and finishing. Server validation remains authoritative.
- Friendly status/errors omit raw enums, table addresses and script tracebacks. Q04 passage remains verbatim. Keyboard rotation still has touch cards.
- One pending request, unique IDs, eight-second timeout, no automatic purchase retry. Timeout closes the panel and requests a snapshot; reopening obtains fresh choices. Close/back releases reservations and invalidates the request epoch, preventing late replies from reopening panels.
- Routine snapshots update HUD/journal/cake data only. They do not reopen closed panels or dismiss activity confirmation. Unsolicited views refresh only the same open activity; a confirmation survives if its action remains enabled.

## Descriptor contract for later builders

All original view/action fields remain. Example optional guide:

    view.guide = {
        headline = "Build Phuong's bowl",
        detail = "Choose a topping, then add it to the bowl.",
        stepLabel = "Step 2 of 6",
        nextAnchor = "Q06FOBCounter",
        preview = {
            title = "Your shared bowl", detail = "Rice is ready.",
            items = {{label = "Rice", complete = true}, {label = "Topping", detail = "Choose next"}},
        },
        groups = {
            {id = "toppings", title = "Choose a topping", detail = "Everyone shares this bowl.",
             kind = "choices", actionIds = {"existing-action-id-1", "existing-action-id-2"}},
        },
    }

Additional optional action descriptor fields:

    descriptor.groupId = "toppings" -- alternative to actionIds
    descriptor.description = "Add a crunchy topping."
    descriptor.selected = true -- authoritative choice gets check/outline
    descriptor.primary = true -- one sensible next action, not every choice
    descriptor.confirm = {title = "Finish this bowl?", detail = "Save it for the group.", label = "Finish bowl"}

Ungrouped availableActions stay accessible in fallback groups. Order groups/actions intentionally. Group kind is reserved metadata; both choices/actions currently use deliberate card selection followed by the main action. Use confirm=false only for a deliberately noncommitting preview, never actual spending/finishing. Supply friendly labels and reasons; IDs are not label fallbacks.

## Client extension API

Optional ModuleScripts under ReplicatedStorage.PhuongMVP.client.extensions export Init(getContext, Extensions). The first argument is a function: call getContext() whenever fresh state is needed. Initial children load once in alphabetical name order; use a numeric prefix if necessary. Later-added modules load on arrival. Register without yielding and require dependencies explicitly. Observers and journal links also use alphabetical IDs.

- Extensions.RegisterActivity(activityId, renderer): renderer(container, view, context) mounts an optional preview before the generic groups. Container is destroyed/recreated each render; clean up custom connections/animations accordingly.
- RegisterActivity("Cake", renderer) replaces baseline cake actions. Renderer receives scrollContainer, cakeState, context; use LayoutOrder 3 or higher.
- Extensions.RegisterPanel(id, descriptor): descriptor has label, title, optional visible(context) predicate and render(container, context). Adds a journal entry, suitable for host or music controls. Host visibility must use server-authored roles/IDs.
- Extensions.RegisterObserver(id, callback): callback(payload, context) receives every remote payload plus LocationChanged and CharacterRemoving. Suitable for optional per-player finale cameras/audio; never assume panel visibility.

Context: UI, gui, player, snapshot, sessionId, pending; functions toast(message,isError), track(activityId,optionalAnchor), close(), send(request), requestView(id,replay), runAction(descriptor,confirmed), refresh(). Send supplies current session/request IDs, strips client actor fields, throttles duplicates and returns success boolean. Use fresh renderer/observer contexts rather than retaining initial state. UI exports Palette, Corner, Padding, List, Label, Button, SetEnabled, Card and Clear.

Minimal extension example, requiring no edit to Main:

    local Module = {}
    function Module.Init(getContext, registry)
        registry.RegisterPanel("music", {
            label = "Music", title = "Music settings",
            render = function(container, context)
                context.UI.Button(container, "MusicHelp", "Music settings", function()
                    getContext().toast("Use the controls here to change your music.")
                end)
            end,
        })
    end
    return Module

Activity/extension containers are presentation mounts, not authority boundaries. Use context.send({kind = "ExistingServerKind", ...}) for supported server commands; it overwrites actionId/sessionId and removes actorUserId/player. An extension must register its own observer to interpret command-specific results. The current extension panel refreshes automatically when its matching reply arrives. Activity mutations should use context.runAction(descriptor, false) so default confirmations are retained. Scene/camera observers may act without an open panel, but must restore local state on LocationChanged/CharacterRemoving.

## Server integration required for current shared views

Baseline broadcasts only petals/fund/cake. Without per-activity summaries, unvisited journal entries show purpose/destination rather than invented step counts, and intermediate changes by another player require Refresh.

Minimal contract for PCW-19 Main server editor:

1. Track each player's successfully opened activity on RequestView; clear on CloseActivity/lobby entry/removal.
2. After changes, construct each recipient's own GetView(userId) and send payload.view with no actionId alongside snapshot. Never send another actor's permission-specific view.
3. Client accepts an unsolicited view only for the same already-open activity. Closed panels stay closed.
4. Optional snapshot.activityViews = {Q01 = ownView, ...} refreshes journal/navigation caches without opening panels; client already supports it. Use UI-safe cloned descriptors.

## Deferred checks and limits

No tests, compilation, Studio access, playthrough, save, publication or independent approval occurred. Source was read for completeness only. Final integration must check:

- Module installation, deterministic extensions, absence of duplicate Main LocalScripts.
- Phone landscape/portrait, tablet/desktop sizing, long text, scroll depth, joystick/jump/camera clearance.
- Real current action envelopes for all six activities, reservation release, replay, Q04 text, authenticated ownership.
- Two clients changing steps with panels open; disabled-group reasons, selection/confirmation updates, broadcasts while closed.
- Rapid taps, rejection, timeout, close before reply, reset, lobby return; no duplicate purchase/stale reopen.
- Anchor/stage/completion/replay routing, missing/streamed anchors, zero markers in lobby.
- Existing click/success sounds, future finale/music/host extensions, independent third-person cameras.

Markers are directional waypoints rather than collision-aware pathfinding. Missing/streamed anchors produce no fabricated location; journal hints remain. No measured mobile performance, human fun or release-readiness claim is made.
