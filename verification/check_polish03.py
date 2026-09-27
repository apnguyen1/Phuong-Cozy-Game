"""Check captured static Draft 03 evidence; this does not run Roblox."""
from __future__ import annotations

import hashlib
import json
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
EVIDENCE = ROOT / "roblox/evidence/draft03"
PREFIX = "Workspace.CozyWorld_Draft01.VisualPolish03"


def require(value, message):
    if not value:
        raise ValueError(message)


def read(path):
    return json.loads(path.read_text(encoding="utf-8-sig"))


def check_capture(capture):
    require(capture.get("ticket_id") == "MAP-03" and capture.get("root") == PREFIX,
            "Capture must identify the assigned VisualPolish03 folder")
    parts = capture.get("parts")
    require(isinstance(parts, list) and 0 < len(parts) <= 750, "New native-part count must be 1–750")
    paths = [part.get("path") for part in parts]
    require(all(isinstance(path, str) and path.startswith(PREFIX + ".") for path in paths)
            and len(set(paths)) == len(paths), "Missing, duplicate or out-of-scope part paths")
    for part in parts:
        require(part.get("class") in {"Part", "WedgePart", "CornerWedgePart"}, "New geometry is not native primitive geometry")
        require(part.get("anchored") is True and part.get("can_collide") is False
                and part.get("can_touch") is False and part.get("can_query") is False,
                "Every added part must be anchored, noncolliding, non-touch and non-query")
    require(capture.get("textures") == [], "New decoration must not introduce color textures")
    others = capture.get("non_part_instances")
    require(isinstance(others, list), "Full new-folder class inventory is required")
    all_paths = paths + [item.get("path") for item in others]
    require(all(isinstance(path, str) and (path == PREFIX or path.startswith(PREFIX + ".")) for path in all_paths)
            and len(set(all_paths)) == len(all_paths), "New folder contains duplicate instance paths")
    for item in others:
        require(item.get("class") in {"Folder", "Model", "SpecialMesh"},
                "New folder contains an unexpected script, light, effect, interaction or asset")
        if item["class"] == "SpecialMesh":
            require(item.get("mesh_type") == "Sphere" and item.get("mesh_id") == "" and item.get("texture_id") == "",
                    "Only texture-free native sphere meshes are permitted in new decoration")
    return {"native_parts": len(parts), "non_part_instances": len(others), "textures": 0}


def check_preservation():
    counts = {}
    for kind, field in (("scene", "objects"), ("runtime", "scripts")):
        baseline = read(EVIDENCE / f"{kind}-baseline.json")[field]
        current = read(EVIDENCE / f"{kind}-current-independent.json")[field]
        require(isinstance(baseline, list) and baseline and isinstance(current, list), "Missing original-scene comparison")
        before = {item["path"]: item for item in baseline}
        after = {item["path"]: item for item in current}
        require(len(before) == len(baseline) and len(after) == len(current), "Duplicate original-scene identities")
        changes = sorted(path for path in before.keys() | after.keys() if before.get(path) != after.get(path))
        require(not changes, f"Original {kind} differs from captured baseline: {changes[:8]}")
        counts[kind] = len(current)
    return counts


def main():
    try:
        counts = check_capture(read(EVIDENCE / "polish-studio-colors.json"))
        preserved = check_preservation()
        audit = read(EVIDENCE / "save-audit.json")
        checkpoint = ROOT / "roblox/Phuong-Cozy-World-Draft03.rbxl"
        working = ROOT / "roblox/phuong-cozy-game.rbxl"
        require(checkpoint.read_bytes() == working.read_bytes(), "Working place and Draft 03 checkpoint differ")
        data = checkpoint.read_bytes()
        require(len(data) == audit.get("bytes") and hashlib.sha256(data).hexdigest() == audit.get("sha256"),
                "Current saved artifact differs from its recorded audit")
        baseline = ROOT / "roblox/Phuong-Cozy-World-Draft02.rbxl"
        require(hashlib.sha256(baseline.read_bytes()).hexdigest()
                == "c0d957546b23a58aa99337492edfe08fb383501f3e6d8d58ddab1b8063d3a418",
                "Original reviewed Draft 02 checkpoint changed")
        print(json.dumps({"status": "PASS", "mode": "Validate captured static evidence; does not rerun Roblox",
                          **counts, "saved_artifact_sha256": audit["sha256"],
                          "unchanged_captured_original_objects": preserved["scene"], "unchanged_runtime_sources": preserved["runtime"],
                          "limits": "Palette is checked separately by the harness. Preservation compares only captured fields. Actual route regressions, visual quality and human acceptance require independent evidence review."}, indent=2))
        return 0
    except (OSError, ValueError, TypeError, KeyError, AttributeError) as error:
        print(json.dumps({"status": "FAIL", "detail": str(error)}))
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
