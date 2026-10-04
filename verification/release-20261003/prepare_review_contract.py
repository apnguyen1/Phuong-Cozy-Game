"""Prepare an independent-review contract without running any checks.

Run after final sources/evidence exist. Every release ticket criterion is loaded
through the existing harness parser, never replaced by a shorter checklist.
"""
from pathlib import Path
import importlib.util
import json

ROOT = Path(__file__).resolve().parents[2]
spec = importlib.util.spec_from_file_location("ticket_verify", ROOT / "verification/verify.py")
verify = importlib.util.module_from_spec(spec)
spec.loader.exec_module(verify)
sources = ["docs/tickets/README.md", "docs/design/map-proposal-v0.2.md",
           "docs/design/visual-direction-v0.1.md", "docs/coordination/release-20261003/README.md"]
criteria = []
for number in range(18, 27):
    path, _, _, inherited = verify.source_criteria(ROOT, f"PCW-{number}")
    sources.append(path)
    if number != 25:
        criteria.extend(inherited)
contract = {
    "schema_version": 1, "id": "PCW-25", "kind": "game", "stage": "production", "target": "roblox",
    "title": "October 3 complete birthday game release",
    "intent": "Verify all sequential activity, finale, recovery, guidance and audio deliveries together in the existing Roblox world.",
    "status": "approved",
    "approved_by": "Andrew's October 3 request to implement detailed tickets sequentially, verify with agents, then publish while he is away. Scope authorization only; no human revision acceptance is asserted.",
    "max_iterations": 3, "sources": sources,
    "inputs": ["roblox/mvp", "docs/coordination/release-20261003/handoffs",
               "verification/release-20261003/compile_sources.py",
               "verification/release-20261003/generate_contract_runner.py",
               "verification/release-20261003/run_contract_checks.py",
               "verification/release-20261003/prepare_install.py",
               "verification/release-20261003/make_install_chunks.py",
               "verification/release-20261003/capture_runtime_palette.luau",
               "verification/release-20261003/inspect_client_ui.luau",
               "verification/release-20261003/inspect_audio.luau",
               "verification/release-20261003/performance_probe.luau"],
    "artifacts": [
        {"id": "release-place", "path": "roblox/Phuong-Cozy-World-Release20261003.rbxl", "check": "exists"},
        {"id": "runtime-palette", "path": "roblox/evidence/release-20261003/runtime-palette.json", "check": "studio_palette",
         "allowed_tokens": sorted(verify.TOKENS), "required_tokens": [], "texture_sources": {}},
        {"id": "installed-source-binding", "path": "roblox/evidence/release-20261003/installed-source-binding.json", "check": "exists"},
        {"id": "walkthrough", "path": "roblox/evidence/release-20261003/walkthrough-results.md", "check": "exists"},
        {"id": "console", "path": "roblox/evidence/release-20261003/console.txt", "check": "exists"}
    ],
    "commands": [
        {"id": "source-compile", "argv": ["{python}", "verification/release-20261003/compile_sources.py"], "cwd": ".", "timeout_seconds": 180},
        {"id": "release-contracts", "argv": ["{python}", "verification/release-20261003/run_contract_checks.py"], "cwd": ".", "timeout_seconds": 120}
    ],
    "criteria": criteria
}
contract["inputs"].extend(str(p.relative_to(ROOT)).replace("\\", "/")
                          for p in sorted(Path(__file__).parent.glob("*.spec.luau")))
destination = ROOT / "verification/contracts/PCW-25-release20261003.json"
destination.write_text(json.dumps(contract, indent=2), encoding="utf-8")
print(destination)
