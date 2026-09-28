# Task 07 source repair handoff

Date: 2026-09-27

Repaired only the Q06 test fixture and station builder. The CreateRound fixture now carries the canonical `actionId` string alongside `sessionId`, `activityId`, `roundId`, `stepId`, and numeric `actorUserId`; production validation was unchanged.

`Q06Station.luau` now validates all three required UDistrict anchors (`Q06FOBCounter`, `Q06AladdinsCounter`, `Q06Serving`), rejects unresolved anchors, checks every approved palette token, creates a detached folder through a factory, and installs only through the prebound `context.SafeReplace("Q06", factory)`. Every BasePart carries the required verification and placement attributes. Patio placement remains forbidden and measurements remain pending.

Commands and results:

```text
python verification/mvp/generate_luau_adapter.py
generated .../verification/mvp/run_module_specs.luau from 40 source files
verification/mvp/tools/luau-0.740/luau.exe verification/mvp/run_module_specs.luau
SUMMARY passed=9 failed=0
git diff --check
```

Source SHA-256:

```text
roblox/mvp/tests/Q06.spec.luau 049E7019ED0C4DA4DDACADE065B6A3B2BB4572D2EDA923AC34369F5006C24142
roblox/mvp/builders/Q06Station.luau 55884666A926FC9EBB481481B835212F284D8DF2E0F84F3EE00378E314160003
```

Independent verification and Studio installation/playtesting remain required; this handoff does not claim readiness or approval.
