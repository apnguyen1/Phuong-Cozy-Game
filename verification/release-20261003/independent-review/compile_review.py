"""Run original compile check; keep generated diagnostics in independent runs."""
from pathlib import Path
import importlib.util
ROOT = Path(__file__).resolve().parents[3]
if ROOT.name == 'verification':
    ROOT = ROOT.parent
spec = importlib.util.spec_from_file_location('release_compile', ROOT / 'verification/release-20261003/compile_sources.py')
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)
module.OUT = ROOT / 'verification/runs/PCW25-independent-20261003'
module.main()
