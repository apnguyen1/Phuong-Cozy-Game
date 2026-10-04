"""Prepare a source-only Studio update manifest. Does not access Studio or test code."""
from pathlib import Path
import hashlib
import json

ROOT = Path(__file__).resolve().parents[2]
MVP = ROOT / "roblox/mvp"
OUT = Path(__file__).resolve().parent


def source(path):
    return path.read_text(encoding="utf-8-sig").replace("\r\n", "\n").replace("\r", "\n")


def main():
    entries = []

    def add(path, target, kind="ModuleScript"):
        body = source(path)
        entries.append({"source_path": path.relative_to(ROOT).as_posix(), "target": target,
                        "class": kind, "source": body,
                        "sha256": hashlib.sha256(body.encode()).hexdigest()})

    for path in sorted((MVP / "shared").glob("*.luau")):
        if path.stem == "MeasuredInstallOptions":
            continue
        for parent in ("ServerScriptService.PhuongMVP.shared", "ReplicatedStorage.PhuongMVP.shared"):
            add(path, parent + "." + path.stem)
    add(ROOT / "roblox/draft-door.server.luau", "ServerScriptService.CozyDraftDoor", "Script")
    for path in sorted((MVP / "server").glob("*.luau")):
        if path.name == "Main.server.luau":
            add(path, "ServerScriptService.PhuongMVP.server.Main", "Script")
        elif path.stem not in {"QueueService", "TeleportAdapter", "LocalPartyTransferAdapter"}:
            add(path, "ServerScriptService.PhuongMVP.server." + path.stem)
    for path in sorted((MVP / "server/activities").glob("*.luau")):
        add(path, "ServerScriptService.PhuongMVP.server.activities." + path.stem)
    for path in sorted((MVP / "client").rglob("*.luau")):
        relative = path.relative_to(MVP / "client")
        module_target = ".".join(relative.with_suffix("").parts)
        if path.name == "Main.client.luau":
            add(path, "StarterPlayer.StarterPlayerScripts.PhuongMVPClient", "LocalScript")
        elif path.name.endswith(".client.luau"):
            add(path, "StarterPlayer.StarterPlayerScripts." + path.name.removesuffix(".client.luau"), "LocalScript")
        else:
            add(path, "ReplicatedStorage.PhuongMVP.client." + module_target)
    (OUT / "install-manifest.json").write_text(json.dumps(entries, indent=2), encoding="utf-8")
    (OUT / "source-hashes.json").write_text(json.dumps([{k: v for k, v in e.items() if k != "source"}
                                                       for e in entries], indent=2), encoding="utf-8")
    print(json.dumps({"entries": len(entries), "manifest": str(OUT / "install-manifest.json")}))


if __name__ == "__main__":
    main()
