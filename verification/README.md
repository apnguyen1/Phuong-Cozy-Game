# Verification system

Every ticket follows **build → check → independent review → user playtest → revise → repeat**. A smaller, simpler result can pass when the correct features, assigned colors, interactions and Roblox behavior are present. Matching every decorative detail of a concept image is not required.

This is the first working harness, added September 24, 2026 on `codex/roblox-design-docs`. It includes a reusable [verifier agent](../.codex/agents/verifier.toml), executable checks, evidence forms and linked revision reports. The game tickets remain unimplemented; adding this system does not complete them.

## Use it through the agent

Ask: **“Use the verifier to review PCW-07's submitted build. Test its ticket requirements, record defects, and prepare the next iteration.”**

The coordinator supplies the ticket contract, builder identity and submitted files. The verifier inspects independently, runs checks, records evidence, and returns the failed criteria to that builder. The builder makes the next version and writes what changed. The verifier reruns the full ticket gate, including regression checks. The user can review each version and provides the final acceptance; an agent never writes that approval on the user's behalf.

The custom role follows the current [OpenAI custom-agent format](https://learn.chatgpt.com/docs/agent-configuration/subagents). Project role discovery depends on the Codex session; if `verifier` is unavailable, use its instructions as the reviewer brief. No background service, scheduler or API key is required. This is an on-demand workflow, not an always-running monitor.

## What is checked

| Gate | Evidence and decision |
|---|---|
| Correct ticket | The harness loads every acceptance bullet plus deliverable, limits and validation directly from `docs/tickets/PCW-XX.md`. The reviewer maps submitted work to each item, checks dependencies and finds omitted source files. |
| Exact palette | Visible source pixels and authored Roblox part colors are compared to the eight approved hex values. Required tokens and allowed subsets can be set per artifact. |
| Correct image/model | Independent inspection checks identity, silhouette, proportions, color placement, personal features and readability. Simpler geometry and fewer decorations are acceptable. |
| Correct game | Actual behavior tests plus Studio play verify the requested activity, input, feedback, completion, mistakes, exit, repeated play and committed session state. |
| Group and device play | Touch and desktop completion, independent cameras, concurrent contributions, slot contention/release, disconnect/rejoin, late join and one petal per quest. PCW-16 additionally covers the 8–10-player rehearsal. |
| Roblox readiness | A production asset/game must be imported and tested in Studio, with scale, pivot, materials, collision and console evidence. A concept has a handoff review instead and is labeled `concept`. |
| Fun | A human playtest records clarity, satisfying actions, pacing, replay interest, duration, friction and requested changes. The user decides whether the experience is good enough. |
| Final acceptance | All required gates pass, evidence exists, the reviewer differs from the builder, and the user accepts this exact revision. |

`READY_FOR_REVIEW` means the automatic checks passed. It is never final approval. Other outcomes are `CHANGES_REQUIRED`, `BLOCKED` for missing inputs/evidence, and `PASS` for a completed review. After three iterations by default, `NEEDS_DECISION` stops the loop for a scope/budget decision; it does not lower the quality bar. Tickets can set another agreed iteration budget.

## Palette source of truth

Use [palette.json](palette.json). The values come directly from the user's September 24 reply:

| Token | Hex | Intended role |
|---|---|---|
| forest | `#365744` | Primary actions, wayfinding, selected emphasis |
| sage | `#A8B995` | Bedding, soft furnishings, secondary surfaces |
| cream | `#F5F0E4` | Walls, warm white furniture, panels, light text |
| wood | `#95674B` | Floors, craft and table surfaces |
| blossom | `#E8B7C6` | Cherry blossoms and celebration accents |
| brick | `#B66C68` | Quad paths and masonry accents |
| golden | `#E8C779` | The user's “Gold”; light warmth and completion accents |
| ink | `#26382E` | Dark text and outlines |

Brick replaces the older `#B77C68`. The visual brief has been corrected; historical generated concepts have not been recolored. Do not infer hex values by sampling their shaded pixels.

Raster checking is exact on every visible pixel, including translucent edges and every animation frame; fully transparent pixels are ignored. It suits palette-constrained exports and albedo images. It deliberately rejects unapproved intermediate colors. Photographic references and shaded concept boards use `exists` plus visual review; a concept image contract also checks a separate authored flat palette export. Production images check the actual deliverable pixels, not a separate swatch standing in for it. A valid token on the wrong object still fails visual review.

Roblox uses [Color3](https://create.roblox.com/docs/reference/engine/datatypes/Color3) for precise part colors. Textures and [SurfaceAppearance color maps](https://create.roblox.com/docs/art/modeling/surface-appearance) also affect appearance, so passing part tint alone does not validate a textured asset. Every captured texture content ID must map to an actual `raster_palette` source artifact. The reviewer checks that the source is the one imported. Normals, roughness and metalness are not color-palette textures. Custom material variants, terrain, UI colors, lighting and final in-game appearance require separate visual/Studio review in this version.

## Local setup and commands

Use Python 3.11 or newer from this checkout. The harness is a small development tool, independent of game code. Pillow is its only external package.

```powershell
python -m venv .venv-verification
.\.venv-verification\Scripts\python.exe -m pip install -r verification/requirements.txt
.\.venv-verification\Scripts\python.exe -m unittest discover -s verification -p test_verify.py -v
```

[contracts](contracts/) contains draft manifests for all 16 current tickets. Drafts preserve the ticket IDs and defer real deliverable paths/test commands until a builder is assigned. Their existence does not authorize implementation. `approved_by` records who agreed the contract; agents must derive it from actual authorization rather than inventing approval.

To make another manifest from an existing Markdown ticket:

```powershell
.\.venv-verification\Scripts\python.exe verification/verify.py scaffold PCW-07 --kind game --stage production --out verification/contracts/PCW-07-new.json
```

Before its first build, the coordinator fills in real `inputs`, artifacts, meaningful test commands, allowed/required palette tokens and any additional criteria, then records the agreed contract. `inputs` must include all relevant source folders and configuration/lockfiles, not just the final asset. Add dependency sources when their interfaces affect this ticket. Freeze these inputs while reviewing.

Commands are argv arrays executed locally with `shell=False`. `{python}` resolves to the interpreter running this harness. Example shape: `{"id":"quest-rules","argv":["{python}","tests/check_quest_rules.py"],"cwd":".","timeout_seconds":60}`. Use the real project's tests, not a placeholder success command. On Windows use the executable appropriate to the tool (for example `npm.cmd`); shell syntax is not implicitly interpreted. Review argv before enabling execution. Keep tests finite; the harness times out its direct subprocess, but does not manage arbitrary child-process trees.

```powershell
.\.venv-verification\Scripts\python.exe verification/verify.py run verification/contracts/PCW-07.json --builder bed-builder --execute-checks
```

The command prints a unique `verification/runs/PCW-07/<run>/report.json` path and writes a readable `report.md`. Missing files, draft contracts, missing tools or unrun tests block readiness. A failing test or off-palette color requests changes. Reports and logs are local and ignored by Git; retain or copy the review packet when handing work off.

Using the printed report path, create a review form. Paths below containing `<run>` are placeholders to replace.

```powershell
.\.venv-verification\Scripts\python.exe verification/verify.py review verification/runs/PCW-07/<run>/report.json --reviewer verifier --reviewer-type agent --out verification/runs/PCW-07/<run>/agent-review.json
.\.venv-verification\Scripts\python.exe verification/verify.py review verification/runs/PCW-07/<run>/report.json --reviewer Andre --reviewer-type human --out verification/runs/PCW-07/<run>/human-review.json
```

Forms begin with `pending`. Each reviewed item needs `pass` or `fail`, notes, and nonempty local evidence file paths. Human reviewers can cover any gate; agents cannot satisfy the human fun/final-acceptance gates. Leave unreviewed items pending. Evidence may include screenshots, recordings, console logs and a playtest note containing the user's actual feedback. The coordinator can transcribe an actual user response with its context; never invent it. Do not include the personal birthday note as test content.

Record each defect using: **criterion → expected → observed → reproduction steps → evidence → suggested fix → owner**. For fun, describe the particular moment that felt satisfying or frustrating, not a fabricated numeric score.

```powershell
.\.venv-verification\Scripts\python.exe verification/verify.py finalize verification/runs/PCW-07/<run>/report.json --review verification/runs/PCW-07/<run>/agent-review.json --review verification/runs/PCW-07/<run>/human-review.json --out verification/runs/PCW-07/<run>/decision.json
```

This writes JSON and a readable `decision.md`. All checks and all required gates must pass; any included failure wins over another review claiming success. Finalization rehashes the ticket, palette, source folders (including added/deleted files), assets, tool and runtime versions. Changes require a new run. Reports are never overwritten; use a new output filename if only completing an unfinished review.

For version 2, the builder writes a short change note outside the runs folder, fixes the reported issues and reruns all checks:

```powershell
.\.venv-verification\Scripts\python.exe verification/verify.py run verification/contracts/PCW-07.json --builder bed-builder --execute-checks --previous verification/runs/PCW-07/<run>/report.json --changes deliverables/PCW-07/revision-2.md
```

The next report links the previous report and records the next iteration number. Reviews from version 1 cannot approve version 2. Do not reset the iteration count by starting a fresh chain to evade the budget. On reaching the budget, present the specific unresolved defect and scope/budget choice.

Exit codes: `0` = the requested stage succeeded (`run` readiness, form creation, or final `PASS`); `1` = checks/reviews did not pass; `2` = invalid input, stale evidence, existing output, or iteration stop. Only a `finalize` result with `status: PASS` is a completed acceptance gate. A concept PASS accepts a concept, not a playable game.

## Roblox evidence capture

The builder organizes each authored submission under a root with `VerificationTicket = "PCW-04"` (use the actual ticket) and assigns the appropriate `PaletteToken` attribute to each BasePart. These are string attributes. The verifier runs [capture.luau](roblox/capture.luau) against the intended Studio **edit** model after setting its two top-level constants. The capture reads properties and returns JSON; it does not change the model. Save that return value as the manifest's `studio_palette` artifact before starting the harness run.

The capture includes root identity, timestamp, place ID, part colors and size/collision/material metadata, and visible texture references. It is scoped to the authored root; keep avatars and unrelated world content outside it. Imported FBX/GLB/RBXM files still need real Studio import and play review. File existence alone cannot establish pivots, rigging, scale, collision, permissions, performance, or missing assets.

Re-capture after edits and record screenshots/logs of the exact revision. Inspect omitted/unmapped source assets and material variants. The local checker cannot prove that a hand-edited capture matches the live Studio scene; the independent reviewer must obtain it from Studio and verify its provenance. This version does not automatically start Studio, import into a live place or publish anything.

## Trust and limits

This is a cooperative quality workflow, not a signed approval service. Builder/reviewer identities are labels, and human feedback must genuinely come from the user; JSON cannot authenticate a person. Hashes catch ordinary stale files and bind decisions to reviewed bytes, but someone who can edit the harness/reports can bypass it. The reviewer owns completeness of the submitted file list, the relevance of tests, evidence interpretation and semantic correctness. A screenshot alone does not establish interactivity, and an automated test alone does not establish fun.

The regression suite exercises the harness with synthetic fixtures, including deliberately wrong colors and invalid approvals. It does not validate a real game, a real import or the fun of an unbuilt activity. Cross-session saving and device performance are gated on the actual PCW-13/PCW-16 decisions; they are not assumed implemented.
