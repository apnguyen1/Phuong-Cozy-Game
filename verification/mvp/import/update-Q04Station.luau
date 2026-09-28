local HttpService=game:GetService("HttpService")
local parent=assert(game:GetService("ServerStorage").PhuongMVPTools.builders);local old=assert(parent:FindFirstChild("Q04Station"));assert(old:IsA("ModuleScript") and old:GetAttribute("PhuongMVPImportOwned"),"owned module required")
local expectedSource=HttpService:JSONDecode(HttpService:JSONEncode([=[return function(context)
    assert(context and context.Root and context.MVP and context.Anchors and context.Palette, "Q04 station context is required")
    assert(context.SafeReplace, "Q04Station requires SafeReplace")
    local function getAnchor(name)
        local anchor = context.Anchors[name]
        if not anchor then
            local markerRoot = context.MVP:FindFirstChild("Anchors")
            anchor = markerRoot and markerRoot:FindFirstChild(name, true) or nil
        end
        return anchor
    end
    local required = { "Q04QuadReading", "Q04BedroomKindle" }
    for _, name in ipairs(required) do
        local anchor = getAnchor(name)
        assert(anchor, "Required Q04 anchor missing: " .. name)
        local status = anchor:GetAttribute("PlacementStatus")
        assert(anchor:IsA("BasePart"), "Q04 anchor must be a BasePart: " .. name)
        assert(type(status) == "string" and status ~= "" and status ~= "UNRESOLVED" and status ~= "UNRESOLVED_LIVE_ANCHOR", "Q04 anchor unresolved: " .. name)
    end
    for _, token in ipairs({ "forest", "sage", "cream", "wood", "blossom", "brick", "golden", "ink" }) do
        assert(context.Palette[token], "Required palette token missing: " .. token)
    end
    local function factory()
        local folder = Instance.new("Folder")
        folder.Name = "Q04"
        folder:SetAttribute("VerificationTicket", "PCW-10")
        folder:SetAttribute("MVPBuilder", "Q04Station")
        local function prop(name, anchorName, token, offset, footprint, clearance)
            local part = Instance.new("Part")
            part.Name = name
            part.Size = Vector3.new(.8, .18, .55)
            part.CFrame = getAnchor(anchorName).CFrame * CFrame.new(offset)
            part.Color = context.Palette[token]
            part.Anchored = true
            part.CanCollide = false
            part.CanTouch = false
            part.CanQuery = false
            for key, value in { VerificationTicket = "PCW-10", PaletteToken = token, MVPBuilder = "Q04Station", AnchorName = anchorName, Footprint = footprint, ApproachClearance = clearance, Owner = "Task05", SourceBuilder = "roblox/mvp/builders/Q04Station.luau" } do
                part:SetAttribute(key, value)
            end
            part.Parent = folder
        end
        prop("QuadReadingBook", "Q04QuadReading", "wood", Vector3.new(0, 1.15, 0), "Existing bench only", "Measured by Task01")
        prop("QuadReadingPrompt", "Q04QuadReading", "golden", Vector3.new(0, 1.45, 0), "Existing bench only", "Measured by Task01")
        prop("BedroomKindlePrompt", "Q04BedroomKindle", "forest", Vector3.new(0, .25, 0), "Existing desk/display only", "Measured by Task01")
        return folder
    end
    local manifest = { VerificationTicket = "PCW-10", MVPBuilder = "Q04Station", Owner = "Task05", SourceBuilder = "roblox/mvp/builders/Q04Station.luau", RequiredAnchors = required, Preserves = { "Existing Quad benches", "QuadPlanting", "Quad paths", "Bedroom desk/Kindle" }, BasePartCount = 3 }
    local installed = context.SafeReplace("Q04Station", factory)
    return {
        folder = installed,
        manifest = manifest,
    }
end
]=]));local n=Instance.new("ModuleScript");n.Name="Q04Station";n:SetAttribute("PhuongMVPImportOwned",true);n:SetAttribute("PhuongMVPSourceSHA256","00655CA8B550D50AECD95589E78DFF7AED2B5143172877ED876E01EF6A73F2D5");n.Source=expectedSource;assert(n.Source==expectedSource,"source readback mismatch");n.Parent=parent;old:Destroy();return true
