"""Bind independently executed Studio contracts and installed source to disk.

This verifies retained results, not a replacement execution or simulated pass.
Four actual contract suites were run in Studio Edit by release_verifier.
"""
from pathlib import Path
import hashlib
import json

ROOT = Path(__file__).resolve().parents[3]
if ROOT.name == 'verification':
    ROOT = ROOT.parent
HERE = Path(__file__).resolve().parent

def read(name):
    return json.loads((HERE / name).read_text(encoding='utf-8-sig'))

result = read('studio-contract-results.json')
assert result['reviewer'] == 'release_verifier'
assert result['result'].get('isError') is False
messages = json.loads(result['result']['content'][0]['text'])
assert messages['ok'] is True
passed = [v for v in messages['messages'] if v.startswith('PASS\t')]
assert len(passed) == 4 and 'RELEASE_CONTRACT_SUMMARY\t4\t0' in messages['messages']
assert not any(v.startswith('FAIL') for v in messages['messages'])
hashes = read('contract-source-hashes.json')
for name, expected in hashes.items():
    source = ROOT / name
    if name.startswith('roblox/mvp/tests/release_'):
        source = ROOT / 'verification/release-20261003' / name.split('release_',1)[1]
    assert source.is_file(), str(source)
    assert hashlib.sha256(source.read_bytes()).hexdigest() == expected, name
binding = read('installed-source-binding.json')
assert len(binding['entries']) == 48
for entry in binding['entries']:
    assert entry['exact_equal'] is True
    source = ROOT / entry['source_path']
    raw = hashlib.sha256(source.read_bytes()).hexdigest()
    normalized = source.read_text(encoding='utf-8-sig').encode('utf-8')
    assert raw == entry['disk_sha256'], entry['source_path']
    assert hashlib.sha256(normalized).hexdigest() == entry['sha256'], entry['target']
native = ROOT / 'roblox/Phuong-Cozy-World-Release20261003.rbxl'
assert hashlib.sha256(native.read_bytes()).hexdigest() == 'f2883cf44cb19319171c47cbf8c7f015416623671062baf55293f429c906c90c'
print(json.dumps({'studio_contracts_executed':4,'passed':4,'failed':0,
    'source_hashes_bound':len(hashes),'installed_sources_exact':48,
    'method':result['method'],'native_candidate_sha256':hashlib.sha256(native.read_bytes()).hexdigest()}))
