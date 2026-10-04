local HttpService=game:GetService("HttpService")
local parent=assert(game:GetService("ServerStorage").PhuongMVPTools.builders)
local old=assert(parent:FindFirstChild("Q06Station"));assert(old:IsA("ModuleScript") and old:GetAttribute("PhuongMVPImportOwned"),"owned module required")
local expectedSource=HttpService:JSONDecode(HttpService:JSONEncode([=[-- Q06 station builder. Geometry is derived from measured UDistrict anchors only.
return function(context)
    assert(context and context.Root and context.MVP and context.Anchors and context.Palette and context.SafeReplace, "Q06Station context is incomplete")
    local required = { "Q06FOBCounter", "Q06AladdinsCounter", "Q06Serving" }
    for _, name in ipairs(required) do
        local anchor = context.Anchors[name]
        assert(anchor and anchor:IsA("BasePart"), "Q06Station requires anchor BasePart: " .. name)
        assert(anchor:GetAttribute("Status") ~= "UNRESOLVED" and anchor:GetAttribute("PlacementStatus") ~= "UNRESOLVED_LIVE_ANCHOR", "Q06 anchor unresolved: " .. name)
    end
    for _, token in ipairs({ "forest", "sage", "cream", "wood", "blossom", "brick", "golden", "ink" }) do assert(context.Palette[token], "Required palette token missing: " .. token) end
    local manifests = {}
    for _, name in ipairs(required) do manifests[name] = { AnchorName=name, Footprint="10 x 4 station footprint", ApproachClearance="Measured UDistrict route clearance", Owner="Task07", SourceBuilder="roblox/mvp/builders/Q06Station.luau" } end
    local function factory()
        local folder = Instance.new("Folder"); folder.Name = "Q06"; folder:SetAttribute("ActivityId", "Q06"); folder:SetAttribute("VerificationTicket", "PCW-12"); folder:SetAttribute("MVPBuilder", "Q06Station")
        local function part(parent, name, size, cf, token, manifest, collide)
            local item = Instance.new("Part"); item.Name, item.Size, item.CFrame, item.Color = name, size, cf, context.Palette[token]; item.Anchored, item.CanCollide, item.CanTouch, item.CanQuery = true, collide == true, false, true
            for key, value in pairs({ VerificationTicket="PCW-12", PaletteToken=token, MVPBuilder="Q06Station", AnchorName=manifest.AnchorName, Footprint=manifest.Footprint, ApproachClearance=manifest.ApproachClearance, Owner=manifest.Owner, SourceBuilder=manifest.SourceBuilder }) do item:SetAttribute(key, value) end
            item.Parent = parent
        end
        for _, name in ipairs(required) do
            local station = Instance.new("Model"); station.Name = name; station.Parent = folder
            local anchor, manifest = context.Anchors[name], manifests[name]
            part(station, "Counter", Vector3.new(10,2,4), anchor.CFrame * CFrame.new(0,1,0), "wood", manifest, true)
            part(station, "ActionSurface", Vector3.new(8,.15,3), anchor.CFrame * CFrame.new(0,2.1,0), "cream", manifest, false)
            part(station, "StationLabel", Vector3.new(4,1,.15), anchor.CFrame * CFrame.new(0,3,-1.8), "forest", manifest, false)
        end
        return folder
    end
    local installedFolder = context.SafeReplace("Q06Station", factory)
    assert(installedFolder and installedFolder.IsA and (installedFolder:IsA("Folder") or installedFolder:IsA("Model")), "Q06 SafeReplace must return installed Folder or Model")
    return { folder=installedFolder, manifest={ VerificationTicket="PCW-12", MVPBuilder="Q06Station", Owner="Task07", SourceBuilder="roblox/mvp/builders/Q06Station.luau", RequiredAnchors=required, PatioPlacement="forbidden", Measurements="pending" } }
end
]=]));local n=Instance.new("ModuleScript");n.Name="Q06Station";n:SetAttribute("PhuongMVPImportOwned",true);n:SetAttribute("PhuongMVPSourceSHA256","79EE132C0E70020683A6EC1F1C8287854A81311C0D8FBA3C4D933937F5656FC3");n.Source=expectedSource;assert(n.Source==expectedSource,"source readback mismatch");n.Parent=parent;old:Destroy();return true
