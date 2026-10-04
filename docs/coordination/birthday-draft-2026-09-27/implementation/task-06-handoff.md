# Task 06 Q05 implementation handoff

Files delivered:

- `roblox/mvp/server/activities/Q05.luau` — common adapter, wanted lock, seven outcomes, fifth-roll guarantee, shared-fund permission, atomic purchase, direct Phuong collection, petal and idempotent receipt.
- `roblox/mvp/builders/Q05Station.luau` — `function(context)` builder using `Root`, `MVP`, `Anchors`, `Palette`, and `ReplaceFolder`.
- `roblox/mvp/tests/q05.spec.luau` — deterministic four-miss/fifth-guarantee, debit, petal and duplicate-action checks.
- `docs/tickets/PCW-11.md` — active Q05 amendment.
- `roblox/mvp/art/Q05/README.md` — concrete native-geometry figure proposal with exact review swatches and identity cues.

Binding: the module follows the frozen `roblox/mvp/CONTRACT.md` adapter shape and uses `SessionService:CommitPurchase` plus `CompleteRound`. The client/router still needs registration and rendering of the canonical descriptor. Task 01 must install the station in Studio Edit mode after resolving the live anchor and route clearance.

Review repair: Q05 now reads presence exclusively from `SessionService:IsPresent` / `session.presence`; tests stamp authenticated identities with `SessionService:SetPresence`. Post-fulfillment replay, owned-figure new-wish completion, duplicate selection receipts, and selected-ID fifth-roll coverage are included.

Rerun repair: every Q05 completion path now sends the trusted `sessionId`, `activityId = "Q05"`, `roundId`, server action ID, and authenticated actor ID to `SessionService:CompleteRound`. No client-supplied session or activity value is used.

Owned-source compile checks passed with `verification/mvp/tools/luau-0.740/luau-compile.exe`: Q05 module exit 0; Q05 spec exit 0. Runtime/source adapter execution and independent verification remain required. The spec covers early/new-wish flow, owned-figure fulfillment, four misses plus fifth-roll guarantee including ID, debit, petal and duplicate-action checks. Remaining gates are all seven probability boundaries, concurrent spend, reconnect/interrupted reveal, exact figure palette/content review, Studio scale/collision, touch/desktop play, and independent 8–10-player verification. The station and figure proposal are native MVP geometry, not production-ready faithful figure assets.

Rerun 3 repair: wanted completion now calls canonical `SessionService:ApplyStep` with `stepId = "wanted-fulfilled"` and the full trusted envelope before `CompleteRound`; Q05 still earns zero fund reward. Raw command: `python verification/mvp/generate_luau_adapter.py; verification/mvp/tools/luau-0.740/luau.exe verification/mvp/run_module_specs.luau`. Result: Q05 spec **PASS**; overall adapter run `passed=8 failed=1`, with the unrelated Q06 fixture failure. Q05 source hash after repair: `9e11b89dbc64a17e4c0ca2598f56fbeeb94a4dc6`.

Installation repair: `Q05Station.luau` now uses only `context.SafeReplace("Q05", factory)`, returns `{folder, manifest}`, validates the resolved non-unresolved `Q05UDistrictVending` BasePart before factory mutation, and tags every BasePart with `VerificationTicket`, `PaletteToken`, `MVPBuilder`, `AnchorName`, `Footprint`, `ApproachClearance`, `Owner`, and `SourceBuilder`. Compile command: `verification/mvp/tools/luau-0.740/luau-compile.exe roblox/mvp/builders/Q05Station.luau` and the Q05 server module; result `BUILDER=0 Q05=0`. Builder hash: `ce9a3f7e9c8d054446974e1a7bd1d7d962cf45a0`.

Generic-view repair: `GetView` now exposes one payload-bearing selection action per figure with readable labels, includes rendered last-award/collection feedback in `instructions`, and reports `canReplay = false` because replay occurs by selecting a new target in the existing round. The default outcome now samples the configured six 16.5% regular weights plus 1% secret weight; `ctx.outcome` and `ctx.random` remain deterministic test seams. Raw command: `python verification/mvp/generate_luau_adapter.py; verification/mvp/tools/luau-0.740/luau.exe verification/mvp/run_module_specs.luau`. Result: `passed=10 failed=0`; Q05 spec PASS; compile exit 0. Q05 source hash: `db142ffd081e15780ee05682546d9eaca0a653db`.

Final view repair: collection feedback now sums actual awarded copies (0 initially, 5 after the five-roll test), and selection/last-award labels are neutral readable names (`Big Into Energy figure 1`…`6`, `Secret figure`) without inventing official names. SHA-256 from `Get-FileHash`: `3C9FC62692DFA1A7F16CD88D203BEB1367CBC8EBB6B72596B41FEEB0D3DB6B74`. Compile exit 0; actual adapter run `passed=10 failed=0`.
