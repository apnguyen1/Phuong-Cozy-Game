-- Edit-mode integrator. Require this module and invoke the returned function with measured inputs.
local REQUIRED_ANCHORS = { "GameplayBedroomArrival", "Q01Bed", "JasperBedroomStart", "JasperFetchYard", "Q03FairCraft", "Q03BedroomDisplay", "Q04QuadReading", "Q05UDistrictVending", "Q06FOBCounter", "Q06AladdinsCounter", "Q06Serving", "FinalePatio", "BirthdayLobbyQueue" }
local STATIONS = { "Q01Station", "Q02Station", "Q03Station", "Q04Station", "Q05Station", "Q06Station", "CakeFinale", "LobbyQueue" }
local ENVIRONMENT = { "SeattleBoundary", "NightLighting", "GrassDecoration" }
local PALETTE = { forest=Color3.fromHex("365744"), sage=Color3.fromHex("A8B995"), cream=Color3.fromHex("F5F0E4"), wood=Color3.fromHex("95674B"), blossom=Color3.fromHex("E8B7C6"), brick=Color3.fromHex("B66C68"), golden=Color3.fromHex("E8C779"), ink=Color3.fromHex("26382E") }

return function(context)
    assert(context and context.Root, "installer requires measured context.Root")
    local root = context.Root
    local mvp = assert(context.MVP or root:FindFirstChild("MVP"), "MVP folder required")
    local anchors = assert(context.Anchors or mvp:FindFirstChild("Anchors"), "resolved measured Anchors required")
    local options = assert(context.Options, "measured Options are required")
    assert(options.OuterQuadBounds and options.Keepouts and options.WorldBounds, "Options require OuterQuadBounds, Keepouts, and WorldBounds provenance")
    local resolvedAnchors, missing = {}, {}
    for _, name in ipairs(REQUIRED_ANCHORS) do
        local anchor = anchors[name] or anchors:FindFirstChild(name, true)
        local status = anchor and anchor:GetAttribute("PlacementStatus")
        if not anchor or not anchor:IsA("BasePart") or type(status) ~= "string" or status == "" or status == "UNRESOLVED_LIVE_ANCHOR" or status == "UNRESOLVED" then table.insert(missing, "Anchor:" .. name) else resolvedAnchors[name] = anchor end
    end
    local builders = assert(context.Builders or script.Parent:FindFirstChild("builders"), "builders folder required")
    local function builder(name) return builders.FindFirstChild and builders:FindFirstChild(name) or builders[name] end
    for _, name in ipairs(STATIONS) do if not builder(name) then table.insert(missing, "Builder:" .. name) end end
    for _, name in ipairs(ENVIRONMENT) do if not builder(name) then table.insert(missing, "Builder:" .. name) end end
    if #missing > 0 then error("MVP preflight failed before scene change: " .. table.concat(missing, ", ")) end
    local stations = mvp:FindFirstChild("Stations") or Instance.new("Folder"); stations.Name = "Stations"
    local environment = mvp:FindFirstChild("Environment") or Instance.new("Folder"); environment.Name = "Environment"
    local selected = {}
    if context.OnlyFeature ~= nil then
        assert(type(context.OnlyFeature) == "string" and context.OnlyFeature ~= "", "OnlyFeature must be a known nonempty string")
        for _, name in ipairs(STATIONS) do if name == context.OnlyFeature then table.insert(selected, {name=name, parent=stations}) end end
        for _, name in ipairs(ENVIRONMENT) do if name == context.OnlyFeature then table.insert(selected, {name=name, parent=environment}) end end
        assert(#selected == 1, "OnlyFeature must select exactly one canonical builder")
    else
        for _, name in ipairs(STATIONS) do table.insert(selected, {name=name, parent=stations}) end
        for _, name in ipairs(ENVIRONMENT) do table.insert(selected, {name=name, parent=environment}) end
    end
    local original, staged, restores = {}, {}, {}
    local function safeReplace(ownedName, ownedParent, name, factory)
        assert(name == ownedName, "SafeReplace name outside caller ownership"); assert(ownedParent == stations or ownedParent == environment, "SafeReplace parent outside MVP ownership")
        local parent = ownedParent
        local made = factory(); assert(made and (made:IsA("Folder") or made:IsA("Model")) and not made.Parent, "factory must return detached Folder/Model")
        local old = parent:FindFirstChild(name); original[name] = { old=old, parent=parent }; if old then old.Parent = nil end
        made.Name = name; made.Parent = parent; staged[name] = made; return made
    end
    local shared = { Root=root, MVP=mvp, Anchors=resolvedAnchors, Palette=PALETTE, RequiredPalette=PALETTE, Options=options, Lighting=context.Lighting or game:GetService("Lighting") }
    function shared:ValidateAnchors(names) for _, name in ipairs(names) do local a = self.Anchors[name]; local s = a and a:GetAttribute("PlacementStatus"); assert(a and a:IsA("BasePart") and type(s)=="string" and s~="" and s~="UNRESOLVED_LIVE_ANCHOR" and s~="UNRESOLVED", "unresolved anchor: " .. name) end return true end
    local ok, result = pcall(function()
        stations.Parent = mvp; environment.Parent = mvp
        local out = {}
        for _, entry in ipairs(selected) do local name, parent = entry.name, entry.parent; local c = table.clone(shared); c.SafeReplace=function(n,f) return safeReplace(name,parent,n,f) end; out[name] = require(builder(name))(c); if out[name].Restore then table.insert(restores,out[name].Restore) end end
        return out
    end)
    if not ok then for i=#restores,1,-1 do pcall(restores[i]) end; for _, item in pairs(staged) do if item then item:Destroy() end end; for _, backup in pairs(original) do if backup.old then backup.old.Parent = backup.parent end end; error("MVP install rolled back owned outputs: " .. tostring(result)) end
    return { folders = result, manifest = { RequiredAnchors=REQUIRED_ANCHORS, Stations=STATIONS, Environment=ENVIRONMENT, Measurements="provided by Task01", PaletteTokens=PALETTE } }
end
