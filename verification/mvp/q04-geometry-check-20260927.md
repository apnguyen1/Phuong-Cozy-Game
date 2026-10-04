# Q04 geometry check — 2026-09-27

Read-only inspection of the saved primary in Studio `ac69268a-efcf-4a1a-b2f2-98cdf22947d7`, Edit mode. No Play, enable, edit, or save action.

The corrected `ReadingBench1.Seat` is centered at `(-44.2650681, 2.34648705, 1.8777504)`, rotated with the bench, and has top Y `2.45848705`. `QuadReadingBook` is centered at `(-44.2650681, 2.56999993, 1.8777504)`, shares the bench orientation and x/z center, and has bottom Y `2.47999993` (about 0.0215 studs above the seat top). `QuadReadingPrompt` shares the same x/z and orientation with center Y `2.86999989`, bottom Y `2.77999989`; both parts are anchored and non-collidable/non-touching.

The corrected `StudyDesk.Desktop` top is Y `4.91000076` at x/z `(-23, -130.25)`. `Q04BedroomKindle` is centered exactly on that x/z and y `4.90999985`; `BedroomKindlePrompt` is centered at y `5.15999985`, with bottom Y `5.06999985` (about 0.16 studs above the desk top). The marker and prompt are anchored and non-collidable/non-touching.

Result: **PASS for the assigned Q04 placement geometry check.** Both props are above their supporting surfaces, within supporting x/z bounds, and introduce no blocking collision or seat usability impact. Existing bench and desk geometry are preserved. This is placement evidence only; runtime, gameplay, visual, multiplayer, and final acceptance remain separate gates.
