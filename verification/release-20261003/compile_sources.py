"""Final-stage source compiler; run only after the implementation queue closes."""
from pathlib import Path
import hashlib
import json
import subprocess

ROOT = Path(__file__).resolve().parents[2]
OUT = Path(__file__).resolve().parent
COMPILER = ROOT / "verification/mvp/tools/luau-0.740/luau-compile.exe"


def main():
    results = []
    for path in sorted(list((ROOT / "roblox/mvp").rglob("*.luau")) + [ROOT / "roblox/draft-door.server.luau"]):
        # The release source tree includes runtime, authored builders and specs.
        # Compilation checks syntax only; it does not prove live API behavior.
        try:
            result = subprocess.run([str(COMPILER), str(path)], cwd=ROOT,
                                    capture_output=True, text=True, encoding="utf-8",
                                    errors="replace", timeout=30)
            results.append({"path": path.relative_to(ROOT).as_posix(),
                            "sha256": hashlib.sha256(path.read_bytes()).hexdigest(),
                            "returncode": result.returncode,
                            "diagnostics": result.stderr.strip(),
                            "failure_output": result.stdout[-8000:] if result.returncode else ""})
        except (OSError, subprocess.TimeoutExpired) as error:
            results.append({"path": path.relative_to(ROOT).as_posix(), "returncode": -1,
                            "diagnostics": str(error)})
    failed = [result for result in results if result["returncode"] != 0]
    (OUT / "compile-results.json").write_text(json.dumps(results, indent=2), encoding="utf-8")
    print(json.dumps({"compiled": len(results), "failed": len(failed), "failures": failed}, indent=2))
    raise SystemExit(bool(failed))


if __name__ == "__main__":
    main()
