"""PCW25 only: rebuild the test loader from current sources, then execute it."""
from pathlib import Path
import subprocess
import sys

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[1]
subprocess.run([sys.executable, str(HERE / "generate_contract_runner.py")], cwd=ROOT, check=True)
result = subprocess.run([str(ROOT / "verification/mvp/tools/luau-0.740/luau.exe"),
                         str(HERE / "run_contracts.luau")], cwd=ROOT)
raise SystemExit(result.returncode)
