"""Generate the read-only Luau source-equality verifier from the approved RBXMX."""
from __future__ import annotations

import base64
import json
import xml.etree.ElementTree as ET
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
XML = ROOT / "verification" / "mvp" / "bundle-out" / "Phuong-Cozy-MVP-source.rbxmx"
OUT = ROOT / "verification" / "mvp" / "verify_installed_source.luau"
ROUNDTRIP = ROOT / "verification" / "mvp" / "verify_source_decoder.luau"

def fnv1a(data: bytes) -> int:
    # Small exact checksum for standalone Luau round-trip validation; raw equality
    # remains the authoritative installed-source comparison.
    value = 0
    for byte in data:
        value = (value + byte) % 65536
    return value

items = []
for item in ET.parse(XML).getroot().findall("Item"):
    props = item.find("Properties")
    name = props.findtext("string[@name='Name']")
    source = props.findtext("ProtectedString[@name='Source']") or ""
    # The bundle manifest is authoritative for targets; map by source/name order.
    items.append((name, item.attrib["class"], source))

manifest = json.loads((ROOT / "verification" / "mvp" / "bundle-out" / "source-hashes.json").read_text(encoding="utf-8-sig"))
if len(items) != len(manifest):
    raise SystemExit(f"XML items {len(items)} != manifest entries {len(manifest)}")

rows = []
for entry, (name, cls, source) in zip(manifest, items):
    target = entry["target"]
    if target.rsplit("/", 1)[-1] != name:
        raise SystemExit(f"target/name mismatch: {target} vs {name}")
    raw = source.encode("utf-8")
    rows.append({"target": target, "class": cls, "source": base64.b64encode(raw).decode("ascii"), "length": len(raw), "fnv": fnv1a(raw)})

lua_rows = ",\n".join(
    "    {target=%s, class=%s, source=%s, length=%d, fnv=%d}" % (
        json.dumps(row["target"]), json.dumps(row["class"]), json.dumps(row["source"]), row["length"], row["fnv"]
    )
    for row in rows
)

OUT.write_text(
    "-- Generated read-only verifier. Do not install into the place.\n"
    "local EXPECTED = {\n" + lua_rows + "\n}\n"
    + r'''local ALPHABET = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
local function decode(value)
    local out, buffer, bits = {}, 0, 0
    for i = 1, #value do
        local ch = value:sub(i, i)
        if ch ~= "=" then
            local digit = ALPHABET:find(ch, 1, true)
            buffer = buffer * 64 + digit - 1
            bits += 6
            if bits >= 8 then
                bits -= 8
                out[#out + 1] = string.char(math.floor(buffer / (2 ^ bits)) % 256)
                buffer = buffer % (2 ^ bits)
            end
        end
    end
    return table.concat(out)
end

local function normalize(value)
    return (value:gsub("\r\n", "\n"))
end

local function resolve(target)
    local node = game
    for part in target:gmatch("[^/]+") do
        node = node:FindFirstChild(part)
        if not node then return nil end
    end
    return node
end

local exact, normalized, mismatches = 0, 0, {}
for _, expected in ipairs(EXPECTED) do
    local node = resolve(expected.target)
    if not node then
        mismatches[#mismatches + 1] = expected.target .. " missing"
    else
        local source = decode(expected.source)
        local classOK = node.ClassName == expected.class
        if not classOK then
            mismatches[#mismatches + 1] = string.format("%s class=%s/%s", expected.target, node.ClassName, expected.class)
        else
            local actual = node.Source
            local rawOK = actual == source
            local normalizedOK = normalize(actual) == normalize(source)
            if rawOK then
                exact += 1
            elseif normalizedOK then
                normalized += 1
            else
                mismatches[#mismatches + 1] = string.format("%s class=%s/%s raw=%s normalized=%s", expected.target, node.ClassName, expected.class, tostring(rawOK), tostring(normalizedOK))
            end
        end
    end
end
print(string.format("SOURCE_EQUALITY expected=%d exact=%d normalized_only=%d mismatches=%d", #EXPECTED, exact, normalized, #mismatches))
for _, mismatch in ipairs(mismatches) do print("MISMATCH " .. mismatch) end
''',
    encoding="utf-8",
)
ROUNDTRIP.write_text(
    "-- Generated standalone decoder round-trip check.\n"
    "local EXPECTED = {\n" + lua_rows + "\n}\n"
    + r'''local A = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
local function decode(v)
    local out, buffer, bits = {}, 0, 0
    for i = 1, #v do
        local ch = v:sub(i, i)
        if ch ~= "=" then
            buffer = buffer * 64 + A:find(ch, 1, true) - 1
            bits += 6
            if bits >= 8 then
                bits -= 8
                out[#out + 1] = string.char(math.floor(buffer / (2 ^ bits)) % 256)
                buffer = buffer % (2 ^ bits)
            end
        end
    end
    return table.concat(out)
end
local function fnv(s)
    local value = 0
    for i = 1, #s do value = (value + string.byte(s, i)) % 65536 end
    return value
end
local failures = 0
for _, item in ipairs(EXPECTED) do
    local decoded = decode(item.source)
    if #decoded ~= item.length or fnv(decoded) ~= item.fnv then
        failures += 1
        print(string.format("ROUNDTRIP_MISMATCH %s length=%d/%d fnv=%d/%d", item.target, #decoded, item.length, fnv(decoded), item.fnv))
    end
end
print(string.format("ROUNDTRIP expected=%d passed=%d failed=%d", #EXPECTED, #EXPECTED - failures, failures))
''',
    encoding="utf-8",
)
print(f"generated {OUT} with {len(rows)} targets")
