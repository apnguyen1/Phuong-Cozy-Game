# PCW-26 delivery

Status: **IMPLEMENTED_PENDING_INTEGRATION**. Builder: cozy_music. October 3, 2026.

## Files and installation

| Source | Install as |
|---|---|
| `roblox/mvp/shared/AudioConfig.luau` | New ModuleScript at **both** `ServerScriptService.PhuongMVP.shared.AudioConfig` and `ReplicatedStorage.PhuongMVP.shared.AudioConfig`; identical source |
| `roblox/mvp/server/CozyAudio.luau` | Replace existing live ModuleScript `ServerScriptService.PhuongMVP.server.CozyAudio` with this permanent source |
| `roblox/mvp/client/CozySoundEffectsClient.client.luau` | Replace existing live `StarterPlayer.StarterPlayerScripts.CozySoundEffectsClient` LocalScript; do not retain another running copy |
| `roblox/mvp/client/extensions/MusicController.luau` | New ModuleScript `ReplicatedStorage.PhuongMVP.client.extensions.MusicController`; existing Main extension loader invokes `Init(getContext,registry)` |
| `roblox/mvp/client/Main.client.luau` | Existing `StarterPlayer.StarterPlayerScripts.PhuongMVPClient`; only audio top-inset layout integration added after PCW-24 |
| `roblox/mvp/client/extensions/FinalePresentation.luau` | Existing replicated extension; banner follows audio top inset and listens for changes |
| `roblox/mvp/server/Main.server.luau` | Existing Main Script; accepted-audio call now protected with pcall, plus audio Destroy at Main destruction |

Install shared and audio modules before enabling entrypoints. No saved-world builder is needed. `require(script.Parent.CozyAudio)` and successful `CozyAudio.Accepted(r,result)` remain in Main. The accepted action is committed by the existing activity before the cosmetic audio hook, and a cosmetic exception cannot break its reply. PCW-18 through PCW-24 sources, actor/host IDs, remote authority, rewards and world geometry are preserved. The exported live baseline audio remains unchanged in `roblox/evidence/release-20261003/`.

## Exact assets and levels

| Use | Asset ID | Base volume |
|---|---|---|
| Lobby loop and one shared-timeline finale excerpt | `87992648461099` | .22 |
| World loop: user-selected Slow Mornings, gentle acoustic guitar | `139568344220252` | .18 |
| SoftClick | `88442833509532` | .18 |
| SuccessChime | `103516326607012` | .22 |
| JasperBark | `135016436724006` | .25 |
| JasperPant | `6463651038` | .10 |

Music defaults to 50% of its base volume, giving .11 birthday and .09 world. Controls adjust by 25 percentage points up to the modest base volume; mute preserves the selected level. Volume Up or Unmute from zero restores an audible preference. SFX has its own on/off setting. No new ID, substitute song, audio upload, external permission change or Pomeranian import was made. These configured levels are not an audition or loudness qualification.

## Local ownership and timeline

- The MusicController singleton owns exactly two local Sound instances, `SoundService.CozyMusicLocal.Birthday` and `.World`. Lobby and finale reuse the same Birthday sound. PCW-23 creates no competing birthday Sound. Duplicate initialization returns the existing controller; an already-present owned folder prevents a second controller instance from another module copy.
- `BirthdayLocation=Lobby` selects the looping birthday track; `World` selects the looping instrumental unless the shared cake timeline is active. Unknown location is quiet. No activity panel, currentView, runAction, queue state, or reward path is involved.
- Ordinary location changes crossfade over .65 seconds. The outgoing track pauses after fading to zero; the incoming ambient track resumes its position. Unrelated snapshots only update targets when they change and do not reset a loaded/playing track. Music mute/level affects only the local listener.
- A valid CELEBRATING cake state requires the current session, generation greater than zero, startedAt and endsAt. The controller remembers the session/generation and starts its birthday excerpt at most once for that run. It uses `workspace:GetServerTimeNow()` and seeks to elapsed server time **after** loading, including late load/join. If the excerpt/timeline already ended before loading, it does not begin stale playback. The birthday Sound is nonlooping during finale. A naturally shorter sound marks the local run finished; it never loops/restarts that excerpt.
- World music fades to zero and pauses for the finale. Birthday volume fades over the last .65 seconds of the shared timeline, then world music resumes. Skip or recovery-shortened celebration fades the outgoing birthday sound and resumes world; the controller does not prolong the authoritative celebration. It checks time at 10 Hz even if no new snapshot arrives. Normal fade duration is .65 seconds; a Skip/recovery transition may have that short cosmetic tail after the server phase changes.
- `FinaleCameraSkipped` and the existing `FinaleSkippedSessionId` **plus** `FinaleSkippedGeneration` attributes suppress only the matching local generation. Camera Started/Returned events do not create another player. The camera extension's death, character removal, travel and Skip cleanup can therefore also return music to normal exploration without modifying shared cake state. Local mute may allow an inaudible timeline to advance, so unmuting during the same excerpt remains synchronized.
- Character respawn retains the singleton, ScreenGui and local Player attributes `CozyMusicMuted`, `CozyMusicVolume`, `CozyEffectsEnabled`. These are client preferences only, not authority or cross-server persistence. The server session/generation prevents snapshot retries from retriggering the finale.

## Controls and status paths

`PlayerGui.CozyAudioControls` is a separate `ResetOnSpawn=false` ScreenGui. Its controls remain available when PhuongMVPHud is hidden in Lobby or temporarily disabled by the optional camera.

- `CozyAudioControls.AudioBar.MusicMute`, `VolumeDown`, `VolumeUp`, `EffectsToggle` are four controls with 48-pixel height and at least 48-pixel width. Only UI.Palette colors are authored. The full row reserves 64 pixels at the safe top through `PhuongMVPHud.AudioControlsInset`; Main HUD/panel/toast and the finale banner follow that inset.
- At width 650 or greater, `CozyAudioControls.AudioOptions` is an 84-by-48 Audio button in the left gutter beside the centered HUD/panel. It toggles the full row. Narrower landscape also collapses there while ActivityPanel is open, retaining the existing panel height. Opening/closing a gameplay panel resets the expanded audio controls to the compact state. Narrow portrait shows the row directly. There is no bottom overlay or input-consuming fullscreen backdrop.
- Actual phone/tablet landscape and portrait clearance, lobby overlay overlap, text wrapping, safe insets, reading height and physical touch comfort are **unverified**. In particular, expanding audio temporarily reserves 64 pixels on compact landscape; the collapse restores the panel's prior height. Root must assess the composition in final device checks.
- `MusicMute` and the collapsed Audio label show Loading/Unavailable when applicable. The host's Journal offers **Audio status** via `Extensions.panels.AudioStatus`, visible only when the existing private snapshot says `host.authorized=true`. It lists both selected IDs and loading state, plus all four effect loading states. Reopening refreshes that diagnostic display. No new host permissions or client-supplied actor fields are added.
- For final probes, `SoundService.CozyMusicLocal` exposes `Configuration`, `Mode`, `TimelineKey`, `FinaleStartedKey`, `BirthdayStatus`, `WorldStatus`, `MusicMuted`, `MusicVolume`, and `EffectsEnabled` attributes. Each music Sound also exposes `LoadStatus`. `SoundService.CozySoundEffectsLocal` exposes `SoftClickStatus`, `SuccessChimeStatus`, `JasperBarkStatus`, and `JasperPantStatus`. Inspect actual `IsLoaded`, `IsPlaying`, `TimePosition` and `TimeLength` in addition to those labels; labels alone do not establish playback.

## Bounded loading and preserved effects

- Each listener preloads the two music assets and four known effects once, asynchronously. IsLoaded/Loaded, preload failure and an eight-second deadline settle the state. Timeout disconnects the Loaded listener and cancels a still-pending preload worker where possible. Late completions cannot restart a failed/timed-out track. No automatic retry, repeated warning loop, infinite WaitForChild or gameplay loading gate is introduced by these sources. An unavailable track remains quiet for the session; no guessed substitute plays.
- AudioConfig supplies both roots. Exact-ID fallback data in the permanent audio sources allows missing configuration/templates to degrade without waiting. CozyAudio lazily resolves the existing world/MVP/Anchors and creates only missing known-ID templates in `SoundService.CozySoundEffects`. It preserves/normalizes the four specified IDs/volumes, sets finite spatial distances, and never waits for an anchor/container.
- The existing successful Q02 hook retains greet/pet/Greenie/fetch barking at the same bedroom/yard anchors with a four-second cooldown. A request identity is remembered before cooldown suppression; an exact retry cannot bark later. Duplicate result codes are ignored. The remembered set is capped at 4096 with no eviction; reaching the cap silences further accepted bark cues without changing gameplay.
- Ambient Jasper panting retains the 25–45-second interval, eight-second exclusion after bark, World-player proximity within 30 studs and first nearby bedroom/yard anchor behavior. One Heartbeat scheduler replaces the startup-dependent waiting loop. Missing anchors simply produce no cosmetic sound.
- The server emits one short-lived spatial Sound per accepted/ambient cue under the existing anchor's `JasperAudioEmitter`. `CozySoundEffect`, `CozyAutoPlay`, `CozyEmittedAt` and `CozyLifetime` identify this cosmetic emission. The SFX client plays it at most once only after its known-ID preload succeeds, seeking to the small elapsed offset and discarding expired cues. The server does not repeatedly call Play for unavailable assets. This changes only listener playback delivery; the server still chooses whether/where/when a cue exists. There is no new RemoteEvent or client authority.
- `CozySoundEffectsLocal.EffectsVolume` is the local SoundGroup for clicks, chimes and marked Jasper emissions. SFX off silences the listener's currently playing Jasper sounds and prevents new local cue playback. Turning it back on does not replay suppressed cues. Click and completion chime remain local, with the original .08-second and one-second cooldowns.
- Completion handling normalizes Q06's nested `receipt.completion` and case-insensitive `completed` / `ROUND_COMPLETED`. It deduplicates the stable completion `receiptId` first, then actionId fallback; fresh request envelopes containing the same reward receipt cannot chime again. Duplicate result codes are suppressed. The local receipt set is capped at 4096 without eviction; over-cap cues become quiet, never repeat old rewards. No audio path retries a gameplay request or grants currency/petals.

## Cleanup and limits

Destroying Main/module/owned overlay removes the music sounds and UI, disconnects registered events/Heartbeat/Loaded listeners, cancels preload/deadline tasks, removes observer/panel registrations, and clears the reserved UI band. SFX destruction disconnects remote/button/descendant listeners, stops owned spatial playback, restores prior SoundGroups, cancels loads and removes its four local templates/group. Button destruction drops its event records during ordinary panel reconstruction. Server cleanup removes owned live emissions/attachments and its scheduler; existing baseline template container/sounds are retained. Debris bounds each emitted bark to five seconds and pant to four. No geometry, asset catalogue, private reading draft or personal birthday note is touched.

Source inspection is the only review performed by this builder. **No compilation, execution tests, Studio calls, builders, save, publication or self-approval occurred.** The requested song's actual permission, quality, music/SFX mix, looping seam and the twelve-second birthday excerpt's musical ending remain **UNTESTED**. IsLoaded or asset metadata cannot stand in for listening. Initial engine permission/moderation errors may still be reported by Roblox itself; the application adds no repeating warning/retry loop.

## Deferred final-stage checks

1. Install/compile the listed sources and replace the original SFX LocalScript rather than retaining two. Bind exact source files to Studio and capture the two shared AudioConfig roots. Confirm one controller, one Birthday Sound and unchanged accepted-action hook/gameplay authority.
2. Audition both exact assets in Lobby/World and the actual twelve-second finale excerpt, including its ending; inspect IsLoaded and time progression and qualify actual published-experience asset permission. If denied/moderated, record exact IDs and external blocker without substituting/reuploading.
3. Lobby -> World -> Lobby, rapid travel, unrelated snapshots, all volume levels/mute/SFX combinations, respawn and UI destruction. Verify crossfade volumes and retained world position, no loud overlap/reset loop, persistent preferences and cleanup.
4. Normal Phuong-triggered finale and Andrew authorized recovery: early/late listeners, late asset load, natural song end shorter than timeline, host-shortened endsAt, shared end without snapshot, Skip before Watch/after Watch, mute/unmute during excerpt, death/respawn/travel, same generation repeated snapshots, and both late-subscriber skip attributes. Confirm one start per session/generation, no seek before load, no stale excerpt after expiration, and correct gameplay resume.
5. Missing config/templates/anchors, simulated failure/timeout, slow completion after deadline and missing SFX client. Verify startup/actions remain live, unavailable audio stays quiet, statuses are readable, and no repeated Play/preload/console spam occurs. Observe server-created Jasper emissions on at least two real local listeners; check replication timing, early/late clone arrival, spatial attenuation and independent SFX mute.
6. Actual accepted Q02 greet/fetch/Greenie/pet and nearby panting; duplicate and new-envelope same-receipt retries; Q01/Q03/Q04/Q06 first/replay completion, Q06 nested receipt, Q05 petal/recovery, click cooldown and destroyed/recreated activity buttons. Confirm reward correctness remains solely server-owned and no chime/bark duplicates arise from broadcast or retry.
7. Phone portrait/landscape, tablet and desktop in Lobby, exploring, all activity panels, Journal/Audio status, host Override and optional camera: clear mute/volume/SFX labels, compact Audio access, safe top inset, no movement/jump overlap, sufficient scrolling area and camera visibility. Gather real device/group evidence and independent verifier findings; source delivery is not PASS.

No personal birthday note was written or altered.
