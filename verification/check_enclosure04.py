"""Check independently captured enclosure evidence; does not simulate Roblox."""
from pathlib import Path
import hashlib
import json

ROOT = Path(__file__).resolve().parents[1]
EVIDENCE = ROOT / "roblox/evidence/enclosure04"

def read(name):
    return json.loads((EVIDENCE / name).read_text(encoding="utf-8-sig"))

def require(condition, message):
    if not condition:
        raise ValueError(message)

def sample_count(value):
    return len(value) if isinstance(value, list) else value

def main():
    counts = {}
    for name, budget in (("seattle", 2300), ("detail", 1100)):
        data = read(name + "-colors.json")
        require(data["schema_version"] == 1 and data["ticket_id"] == "MAP-03", "Wrong capture scope")
        parts = data["parts"]
        require(0 < len(parts) <= budget, name + " part budget exceeded")
        require(len({p["path"] for p in parts}) == len(parts), name + " duplicate part identities")
        require(data["textures"] == [], name + " contains unauthorized external textures")
        for part in parts:
            require(part["anchored"] is True and part["can_touch"] is False, "Unanchored/touch part")
            if name == "detail":
                require(part["can_collide"] is False and part["can_query"] is False, "Decoration blocks gameplay/camera")
            else:
                expected = part["path"].endswith((".ClosedShell", ".Roof", ".PerimeterGround")) or ".ContinuousEnclosure." in part["path"]
                require(part["can_collide"] == expected, "Unexpected enclosure collision role: " + part["path"])
        counts[name + "_parts"] = len(parts)
    preserved = read("preservation.json")
    require(preserved["unexpected_changes"] == [], "Unexpected changes to original geometry")
    require(preserved["runtime_source_changes"] == [], "Runtime source changed")
    require(preserved["parts_preserved"] > 0 and preserved["runtime_sources_preserved"] > 0, "Missing preservation comparison")
    require(sample_count(preserved["allowed_material_changes"]) == 144, "Unexpected native-material scope")
    collision = read("collision.json")
    require(sample_count(collision["edge_samples"]) >= 40 and sample_count(collision["corner_samples"]) >= 4, "Incomplete edge/corner sampling")
    require(collision["missed_samples"] == [], "Escape gap found")
    audit = read("save-audit.json")
    saved = (ROOT / "roblox/phuong-cozy-game.rbxl").read_bytes()
    require(saved[:8] == b"<roblox!", "Invalid Roblox saved-place header")
    require(len(saved) == audit["bytes"] and hashlib.sha256(saved).hexdigest() == audit["sha256"], "Saved-place binding differs")
    for path, expected in audit["source_sha256"].items():
        require(hashlib.sha256((ROOT / path).read_bytes()).hexdigest() == expected, "Source binding differs: " + path)
    print(json.dumps({"static_checks": "PASS", **counts, "collision_edges": sample_count(collision["edge_samples"]),
                      "collision_corners": sample_count(collision["corner_samples"]), "saved_place_bytes": len(saved),
                      "scope": "captured static evidence; movement/visual/human/device review remains independent"}))
    return 0

if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except (OSError, ValueError, KeyError, TypeError) as error:
        print("FAIL: " + str(error))
        raise SystemExit(1)
