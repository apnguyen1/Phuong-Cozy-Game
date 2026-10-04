"""Generate a test-only loader for release contracts; never install in Roblox.

Authoring is preparation. Run only during PCW25 after every builder handoff.
Loads production module text unchanged. No game-engine behavior is simulated.
"""
from pathlib import Path
import hashlib
import json

ROOT = Path(__file__).resolve().parents[2]
HERE = Path(__file__).resolve().parent

def quote(text):
    level = "="
    while "]" + level + "]" in text:
        level += "="
    return "[" + level + "[" + text + "]" + level + "]"

sources = {}
hashes = {}
for path in sorted((ROOT / "roblox/mvp").rglob("*.luau")):
    name = path.relative_to(ROOT).as_posix()
    sources[name] = path.read_text(encoding="utf-8-sig")
    hashes[name] = hashlib.sha256(path.read_bytes()).hexdigest()
specs = []
for path in sorted(HERE.glob("*.spec.luau")):
    name = "roblox/mvp/tests/release_" + path.name
    sources[name] = path.read_text(encoding="utf-8-sig")
    hashes[name] = hashlib.sha256(path.read_bytes()).hexdigest()
    specs.append(name)
assert specs, "No release contract specs found"
header = "local sources = {\n" + ",\n".join(
    "[" + json.dumps(name) + "] = " + quote(source)
    for name, source in sources.items()
) + "\n}\nlocal specs = {" + ",".join(json.dumps(s) for s in specs) + "}\n"
body = r'''
local function node(name, parent, path)
    local value = {Name=name, Parent=parent, _path=path, _children={}}
    setmetatable(value, {__index=function(self, key) return self._children[key] end})
    function value:FindFirstChild(child) return self._children[child] end
    if parent then parent._children[name] = value end
    return value
end
local root, nodes = node("root", nil, ""), {}
for path in pairs(sources) do
    local parent, built = root, ""
    for segment in string.gmatch(path, "[^/]+") do
        built = built == "" and segment or built .. "/" .. segment
        parent = nodes[built] or node(segment, parent, built)
        nodes[built] = parent
        if string.sub(segment, -5) == ".luau" then
            parent.Parent._children[string.sub(segment, 1, -6)] = parent
        end
    end
end
local function loadModule(target)
    assert(type(target) == "table" and target._path, "Expected a synthetic ModuleScript node")
    if target._loaded then return target._value end
    local chunk, failure = loadstring(assert(sources[target._path]), "@" .. target._path)
    assert(chunk, failure)
    local env = setmetatable({script=target, warn=function(...) print("EXPECTED_OR_REVIEW_WARNING", ...) end}, {__index=_G})
    env.require = loadModule
    setfenv(chunk, env)
    target._value, target._loaded = chunk(), true
    return target._value
end
local passed, failed = 0, 0
for _, path in ipairs(specs) do
    local ok, result = xpcall(function() return loadModule(nodes[path]) end, debug.traceback)
    if ok and type(result) == "function" then ok, result = pcall(result) end
    if ok and result == true then
        passed += 1; print("PASS", path)
    else
        failed += 1; print("FAIL", path, result)
    end
end
print("RELEASE_CONTRACT_SUMMARY", passed, failed)
assert(failed == 0, "Release contracts failed")
'''
(HERE / "run_contracts.luau").write_text(header + body, encoding="utf-8")
(HERE / "contract-source-hashes.json").write_text(json.dumps(hashes, indent=2), encoding="utf-8")
print(f"Prepared {len(specs)} contract specs against {len(sources)} unchanged sources")
