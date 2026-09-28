"""Generate a test-only Luau ModuleScript-tree adapter from untouched source."""
from pathlib import Path
import hashlib

ROOT = Path(__file__).resolve().parents[2]
OUT = Path(__file__).resolve().parent / "run_module_specs.luau"
files = sorted((ROOT / "roblox" / "mvp").rglob("*.luau"))
entries = {}
hashes = {}
for path in files:
    rel = path.relative_to(ROOT).as_posix()
    text = path.read_text(encoding="utf-8")
    entries[rel] = text
    hashes[rel] = hashlib.sha256(path.read_bytes()).hexdigest().upper()
extra = ROOT / "verification" / "mvp" / "view_actions_check.spec.luau"
entries["roblox/mvp/tests/view_actions_check.spec.luau"] = extra.read_text(encoding="utf-8")
hashes["roblox/mvp/tests/view_actions_check.spec.luau"] = hashlib.sha256(extra.read_bytes()).hexdigest().upper()

def lua_quote(value: str) -> str:
    level = "="
    while "]" + level + "]" in value:
        level += "="
    return "[" + level + "[" + value + "]" + level + "]"

def lua_key(value: str) -> str:
    return '"' + value.replace('\\', '\\\\').replace('"', '\\"').replace('\n', '\\n') + '"'

lua_entries = ",\n".join(f"    [{lua_key(k)}] = {lua_quote(v)}" for k, v in entries.items())
lua_hashes = ",\n".join(f"    [{lua_key(k)}] = {lua_quote(v)}" for k, v in hashes.items())
template = r'''-- GENERATED TEST-ONLY ADAPTER. Do not install in Roblox.
-- It loads original source strings and supplies synthetic ModuleScript nodes.
local sources = {
__SOURCES__
}
local hashes = {
__HASHES__
}

local function node(name, parent, path)
    local n = {Name = name, Parent = parent, _path = path, _children = {}, _module = nil}
    setmetatable(n, {__index = function(self, key) return self._children[key] end})
    function n:FindFirstChild(child)
        return self._children[child]
    end
    if parent then parent._children[name] = n end
    return n
end

local root = node("root", nil, "")
local nodes = {}
for path in pairs(sources) do
    local parent = root
    local built = ""
    for segment in string.gmatch(path, "[^/]+") do
        built = built == "" and segment or built .. "/" .. segment
        parent = nodes[built] or node(segment, parent, built)
        nodes[built] = parent
        if string.sub(segment, -5) == ".luau" then
            local alias = string.sub(segment, 1, -6)
            parent.Parent._children[alias] = parent
            nodes[string.sub(built, 1, -6)] = parent
        end
    end
end

local function loadModule(target)
    if target._module ~= nil then return target._module end
    local source = sources[target._path]
    assert(source, "not a module source: " .. tostring(target._path))
    local chunk, compileError = loadstring(source, "@" .. target._path)
    assert(chunk, compileError)
    local environment = setmetatable({script = target}, {__index = _G})
    environment.require = function(child)
        assert(type(child) == "table" and child._path, "test adapter require expects a ModuleScript node")
        return loadModule(child)
    end
    setfenv(chunk, environment)
    target._module = assert(chunk())
    return target._module
end

local specs = {
    "roblox/mvp/tests/session_service.spec.luau",
    "roblox/mvp/tests/queue_service.spec.luau",
    "roblox/mvp/tests/cake_service.spec.luau",
    "roblox/mvp/tests/Q01_activity.spec.luau",
    "roblox/mvp/tests/Q02_activity.spec.luau",
    "roblox/mvp/tests/Q03.spec.luau",
    "roblox/mvp/tests/Q04.spec.luau",
    "roblox/mvp/tests/q05.spec.luau",
    "roblox/mvp/tests/Q06.spec.luau",
    "roblox/mvp/tests/view_actions_check.spec.luau",
}

for path, digest in pairs(hashes) do
    if string.find(path, "roblox/mvp/server/") then
        print("SOURCE_HASH " .. path .. " " .. digest)
    end
end

local passed, failed = 0, 0
for _, path in ipairs(specs) do
    print("RUN " .. path)
    local ok, result = xpcall(function() return loadModule(nodes[path]) end, debug.traceback)
    if ok and type(result) == "function" then
        ok, result = pcall(result)
    end
    if ok and result == true then
        passed += 1
        print("PASS " .. path)
    else
        failed += 1
        print("FAIL " .. path .. " " .. tostring(result))
    end
end
print(string.format("SUMMARY passed=%d failed=%d", passed, failed))
if failed > 0 then error("module specs failed") end
'''
OUT.write_text(template.replace("__SOURCES__", lua_entries).replace("__HASHES__", lua_hashes), encoding="utf-8")
print(f"generated {OUT} from {len(files)} source files")
