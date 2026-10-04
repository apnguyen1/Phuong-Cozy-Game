# Final-stage observations to resolve in play

These are source-review concerns, not executed test results. Do not call them confirmed defects before observing the actual client.

- Phone landscape has limited content height after the fixed title and Back/Close rows. Check that instructions, selected item and main action remain easy to find without repeated long scrolls. Generic card selection resets the scroll to the top; custom previews must not bury the submit action again. Check bed, food and Labubu especially.
- A shared broadcast refreshes an open activity panel. Check optional reading-note typing while another client contributes elsewhere: local unsaved text should survive and focus/keyboard should not be repeatedly lost. The note is optional, private and user-authored; never insert test prose into the personal birthday note.
- Q03 grants its petal after six parts, then offers Phuong's cosmetic finishing touch. This is preserved behavior, so test guidance explicitly rather than assuming the finishing choice grants the reward. Replay remains optional and can begin after six parts.
- Jasper's motion is bounded and kinematic. Observe the entire bedroom/door/porch/yard route and ground height, then the toy arcs. Accepted input may run ahead of its cosmetic queue; verify the final visible action still makes sense and no replay leaves old motion active.
- Runtime palette capture must use unique instance paths and include all new owned roots, including Jasper separate from WorldFeedback. Native meshes have no texture IDs. Inspect original objects hidden by overlays and confirm unrelated bedroom/plinth/shelf geometry survives.
- Module contract tests are authored in verification/release-20261003 and use actual GetView envelopes. Historical September fixtures remain stale; do not relax production guards to make those old shortcut requests valid. Choose/update the current meaningful test coverage explicitly.
- Host wish recovery may create a no-cost receipt. Q05 result UI currently describes a paid purchase; PCW24 must distinguish recovery from an actual20 debit when introducing such receipts.
- Audio IsLoaded/time progression is playback evidence, not a claim of listening to the sound. State audition limits accurately if no listening capability is available.
- Normal finale requires the real Phuong role, while the signed-in solo Studio client is Andrew. If necessary, run a clearly labeled Studio-only role simulation by disabling Main before Play, changing the required Config table in the running Server only, then enabling unchanged Main. Do not edit saved Config source or ship a test permission. Stop Play afterward, restore entrypoint Enabled state, and bind final sources to the real configured IDs. This tests normal control wiring under a simulated role; it is not evidence of Phuong actually joining. Test Andrew's recovery separately under the real configuration.

No new gameplay tests, compilation, release installation, save or publication has run yet.

## Official test-tool references checked October 3

Studio's Server & Clients mode supports up to eight simulated clients; F7 starts it and End Session closes the simulations. Device emulation can exercise touch layouts but remains simulation. [Studio testing modes](https://create.roblox.com/docs/studio/testing-modes).

If the installed version exposes them, documented Studio-only APIs can make the final probes precise: StudioTestService.ExecuteMultiplayerTestAsync(count,args), AddPlayers(count), GetTestArgs(), LeaveTest() and EndTest(result). These have not been invoked in this release. [StudioTestService](https://create.roblox.com/docs/reference/engine/classes/StudioTestService).

StudioDeviceSimulatorService documents GetDeviceListAsync/GetDeviceInfoAsync/GetDeviceAsync, SetDeviceAsync, SetOrientationAsync, SetResolutionAsync and StopSimulationAsync. Use discovered presets and restore the previous setting. [StudioDeviceSimulatorService](https://create.roblox.com/docs/reference/engine/classes/StudioDeviceSimulatorService). The new Device Simulator is a beta that can require restart; prefer existing available controls over enabling a beta/restarting a place just for testing. [Device Simulator](https://create.roblox.com/docs/studio/device-simulator).
