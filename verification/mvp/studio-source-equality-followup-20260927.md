# Studio source equality follow-up — 2026-09-27

Target: saved and natively reopened `roblox/phuong-cozy-game.rbxl`, Studio ID `ac69268a-efcf-4a1a-b2f2-98cdf22947d7`, Edit mode. This was a read-only comparison; no play, enable, edit, or save action was performed.

## Fresh bounded comparison

The current UTF-8 RBXMX bundle was regenerated into a bounded Luau helper from the three assigned XML payloads, then executed against the live Edit DataModel. The helper resolved each target by hierarchy, checked `ClassName`, decoded the complete base64 payload, and compared the actual `Source` string byte-for-byte. Studio console output recorded:

```text
EXACT ServerScriptService/PhuongMVP/server/activities/Q01
EXACT ServerScriptService/PhuongMVP/server/activities/Q03
EXACT StarterPlayer/StarterPlayerScripts/PhuongMVPClient
THREE_SOURCE_EQUALITY exact=3 expected=3
```

Result: **3/3 exact raw matches, 0 normalized-only matches, 0 class mismatches, 0 missing targets.**

Bundle evidence: `Phuong-Cozy-MVP-source.rbxmx` SHA-256 `96213B7C301130FAA6D7816275B8557D8D12F1C3BCA534BF017D33043C76E5E6`; the source index was read from the same `bundle-out` directory. The bounded helper source is retained at `verification/mvp/verify_three_current.luau`; its generator is `verification/mvp/make_three_verifier.py`.

## Disposition

The saved Studio sources were already correct; the expected bundle encoding was repaired before this verification, and the current bundle now matches those installed sources for all three targets. This evidence covers source import equality only. It does not approve gameplay, Studio runtime behavior, visual acceptance, the known Q04 placement defect, or human/final acceptance. The coordinator should link this report to the prior `studio-readonly-audit-20260927.md` and rerun any ticket-level finalization that depends on the corrected source result.
