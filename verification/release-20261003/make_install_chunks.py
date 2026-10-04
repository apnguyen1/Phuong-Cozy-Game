"""Create reviewable Edit-mode source updates; never runs Studio or tests."""
from pathlib import Path
import json

OUT = Path(__file__).resolve().parent


def quote(text):
    delimiter = "="
    while "]" + delimiter + "]" in text:
        delimiter += "="
    return "[" + delimiter + "[" + text + "]" + delimiter + "]"


INSTALL = '''local HttpService = game:GetService("HttpService")
assert(not game:GetService("RunService"):IsRunning(), "Stop play before installing")
assert(workspace:FindFirstChild("CozyWorld_Draft01"), "Expected existing world missing")
local entries = HttpService:JSONDecode(__PAYLOAD__)
local installed = {}
for _, entry in ipairs(entries) do
    local segments = string.split(entry.target, ".")
    local parent = game:GetService(segments[1])
    for index = 2, #segments - 1 do
        local child = parent:FindFirstChild(segments[index])
        if not child then child = Instance.new("Folder"); child.Name = segments[index]; child.Parent = parent end
        parent = child
    end
    local object = parent:FindFirstChild(segments[#segments])
    if object then assert(object.ClassName == entry.class, "Unexpected class at " .. entry.target)
    else object = Instance.new(entry.class); object.Name = segments[#segments]; object.Parent = parent end
    if object:IsA("BaseScript") then object.Enabled = false end
    object.Source = entry.source
    assert(object.Source == entry.source, "Source write mismatch: " .. entry.target)
    table.insert(installed, {target = entry.target, bytes = #object.Source, sha256 = entry.sha256})
end
return HttpService:JSONEncode(installed)
'''

VERIFY = '''local HttpService = game:GetService("HttpService")
assert(not game:GetService("RunService"):IsRunning(), "Bind saved Edit sources, not a Play copy")
local entries = HttpService:JSONDecode(__PAYLOAD__)
local bound = {}
for _, entry in ipairs(entries) do
    local segments = string.split(entry.target, ".")
    local object = game:GetService(segments[1])
    for index = 2, #segments do
        object = assert(object:FindFirstChild(segments[index]), "Missing source: " .. entry.target)
    end
    assert(object.ClassName == entry.class, "Wrong source class: " .. entry.target)
    assert(object.Source == entry.source, "Source differs from reviewed disk file: " .. entry.target)
    if object:IsA("BaseScript") then assert(object.Enabled, "Release entrypoint disabled: " .. entry.target) end
    table.insert(bound, {target=entry.target, source_path=entry.source_path,
        sha256=entry.sha256, bytes=#object.Source, exact_equal=true,
        enabled=object:IsA("BaseScript") and object.Enabled or nil})
end
return HttpService:JSONEncode(bound)
'''


def main():
    entries = json.loads((OUT / "install-manifest.json").read_text(encoding="utf-8"))
    chunks, current, size = [], [], 0
    for entry in entries:
        length = len(json.dumps(entry, ensure_ascii=False))
        if current and size + length > 42000:
            chunks.append(current)
            current, size = [], 0
        current.append(entry)
        size += length
    if current:
        chunks.append(current)
    index = []
    for number, chunk in enumerate(chunks, 1):
        name = f"install-{number:02d}.luau"
        payload = json.dumps(chunk, ensure_ascii=False)
        (OUT / name).write_text(INSTALL.replace("__PAYLOAD__", quote(payload)), encoding="utf-8")
        verify_name = f"verify-source-{number:02d}.luau"
        (OUT / verify_name).write_text(VERIFY.replace("__PAYLOAD__", quote(payload)), encoding="utf-8")
        index.append({"file": name, "verify_file": verify_name, "targets": [entry["target"] for entry in chunk]})
    (OUT / "chunk-index.json").write_text(json.dumps(index, indent=2), encoding="utf-8")
    print(json.dumps({"chunks": len(chunks), "entries": len(entries)}))


if __name__ == "__main__":
    main()
