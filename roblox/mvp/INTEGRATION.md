# Phuong's Cozy World MVP integration

This is the scoped source integration contract for the local MVP. It targets the existing `Workspace.CozyWorld_Draft01` hierarchy and derives all world anchors from live Instances at install time. Builders, session kernel, queue, cake service, six activity modules, server router, and client renderer now exist in the saved source tree. It does not overwrite the saved Draft 02/03 checkpoints, publish, or claim Studio/device verification.

## Ownership

`shared/Anchors.luau` owns vocabulary and live anchor resolution. `build-world.luau` creates only the `MVP` folder and marker parts. `server/Main.server.luau` owns session, arrival slots, optional wake, and server proximity validation. `client/Main.client.luau` owns local camera/UI prompts. Activity owners add their own round logic behind the shared anchor names; they must not move the anchors.

## Installation order

Run `build-world.luau` in Studio Edit mode against a copied local place, inspect the generated `MVP.AnchorMarkers`, then install the server/client scripts through `install.luau`. The installer is intentionally source-only and must be run by the designated integrator. Current live CFrames, collision, multi-player, touch, and camera behavior remain gates for Task 13.

## Anchor contract

Required names are documented in `shared/Anchors.luau`: bedroom arrival/slots, Q01 bed, Jasper indoor/outdoor, Q03 booth/display, Q04 benches, Q05 vending, Q06 counters/serving, finale patio, and lobby queue. Missing optional activity anchors are reported and left unresolved; no guessed PlaceIds or asset IDs are introduced.

## Station builder contract

Each activity owner supplies one builder at `roblox/mvp/builders/Q01Station.luau` through `Q06Station.luau`. Builders are Edit-mode functions, not runtime scripts, and must expose:

```lua
return function(context)
    -- context.Root: Workspace.CozyWorld_Draft01
    -- context.MVP: context.Root.MVP
    -- context.Anchors: resolved named anchor Instances
    -- context.Palette: exact project palette tokens
    -- context.ReplaceFolder: builder-owned replacement folder
    -- context.SafeReplace(name, factory): replace only this builder's folder
end
```

The integrator invokes builders in Q01–Q06 order with a shared context. A builder may create or replace only `MVP.Stations.Q0X`; it must not destroy or move `Home`, `QuadPlanting`, storefront shells, courtyard geometry, another activity folder, runtime scripts, or existing source backups. Builders must tag every authored BasePart with `VerificationTicket`, `PaletteToken`, and `MVPBuilder`, set anchored/static collision intentionally, and fail loudly when a required anchor is missing. Re-running the same builder must be idempotent and must preserve other builders' folders.

The builder receives resolved live anchors, not copied historical coordinates. It may derive offsets from an anchor's current CFrame and must store a compact placement manifest under its station folder: `AnchorName`, `Footprint`, `ApproachClearance`, `Owner`, and `SourceBuilder`. Visual evidence still requires actual Studio inspection.

## Activity service and client view contract

Runtime activity modules live under `roblox/mvp/server/activities/Q01.luau` through `Q06.luau`. They bind to the shared Task 09 contract when available:

```lua
local activity = Module.new({
    session = session,
    clock = clock,
    world = world,
})
local round = activity:CreateRound({
    sessionId = session.id,
    activityId = "Q01",
    roundId = "Q01-round-1",
    actorUserId = serverPlayer.UserId, -- stamped by server, never accepted from client
})
local result = activity:Apply({
    sessionId = session.id,
    activityId = "Q01",
    roundId = round.roundId,
    actionId = actionId,
    stepId = stepId,
    actorUserId = serverPlayer.UserId, -- stamped by server router
    payload = payload,
})
local view = activity:GetView(serverPlayer.UserId)
```

`Module.new(ctx)` is server-only and returns one session-owned module instance per activity. The instance exposes `CreateRound(request)`, `Apply(request)`, and `GetView(actorUserId)` directly; `CreateRound` does not return a second activity object. Requests carry the canonical string envelope (`sessionId`, `activityId`, `roundId`, `actionId`, `stepId` where applicable) plus numeric `actorUserId` stamped from the authenticated server `Player`. Clients cannot provide authority-bearing actor data. `Apply` performs proximity, permission, payload allow-list, round, and action-id deduplication checks before shared completion/fund/petal hooks. It returns `{ok, code, receipt, view}` and never trusts client state. `GetView(actorUserId)` is read-only and returns serializable state only; data-only views do not grant permission. The module must not bind permanently to the first actor.

The client renderer consumes a common descriptor rather than activity-specific GUI construction:

```lua
{
    activityId = "Q01",
    roundId = "Q01-round-1",
    state = "Open", -- Open/InProgress/ReadyForPhuong/Finished/etc.
    title = "Everything Tucked In",
    instructions = "Help with an available step",
    progress = {done = 0, total = 7},
    availableActions = {{id = "step-1", label = "...", stepId = "step-1", payload = {}, enabled = true, reason = nil}},
    acceptedStepIds = {},
    contributors = {},
    busyReason = nil,
    errorText = nil,
    canReplay = false,
}
```

The renderer must work with touch taps and desktop click/keyboard equivalents, use large labeled controls, preserve camera drag and Roblox touch controls, and show non-color-only state cues. Action requests carry a fresh client action ID; the server router supplies the authenticated Player and the server returns the authoritative view/receipt. A reconnect requests `GetView` again. No module may create a personal wallet, client-authoritative petal, duplicate miniature, or direct cake reward.

## Integrator bootstrap checklist

The integrator installer resolves the current root and anchors, creates the shared remotes, invokes each Q01–Q06 station builder with the context above, registers the six activity modules against the canonical session contract, and installs the common client renderer. It must print a manifest of missing anchors/builders and stop before partial installation when required foundation anchors are absent. Current source presence does not certify Studio import, route safety, touch parity, or multiplayer behavior.

