-- Native, installable Q05 vending visuals. Task 01 owns Studio installation.
return function(context)
    assert(context and context.Root and context.MVP and context.Anchors and context.Palette and context.SafeReplace, "Q05Station context is incomplete")
    local anchor = context.Anchors.Q05UDistrictVending
    assert(anchor and anchor:IsA("BasePart"), "Q05Station requires Q05UDistrictVending BasePart")
    assert(anchor:GetAttribute("PlacementStatus") ~= "UNRESOLVED_LIVE_ANCHOR", "Q05 vending anchor is unresolved")
    local anchorCFrame = anchor.CFrame
    local manifest = {AnchorName = "Q05UDistrictVending", Footprint = "6.4 x 2.4 cabinet footprint", ApproachClearance = "Measured by integrator outside crossing and pedestrian route", Owner = "Task06", SourceBuilder = "roblox/mvp/builders/Q05Station.luau"}
    local installed = context.SafeReplace("Q05Station", function()
        local folder = Instance.new("Model"); folder.Name = "Q05LabubuVending"
        folder:SetAttribute("ActivityId", "Q05"); folder:SetAttribute("VerificationTicket", "PCW-11"); folder:SetAttribute("MVPBuilder", "Q05Station")
        for key, value in pairs(manifest) do folder:SetAttribute(key, value) end
        folder:SetAttribute("Interaction", "Inspect; select wanted; authorized shared-fund roll; skippable reveal")
        local function part(name, size, cf, token, material, collide)
            assert(context.Palette[token], "unknown palette token: " .. token)
            local item = Instance.new("Part"); item.Name = name; item.Size = size; item.CFrame = cf; item.Color = context.Palette[token]; item.Material = material or Enum.Material.SmoothPlastic; item.Anchored = true; item.CanCollide = collide == true; item.CanTouch = false; item.CanQuery = true
            item:SetAttribute("VerificationTicket", "PCW-11"); item:SetAttribute("PaletteToken", token); item:SetAttribute("MVPBuilder", "Q05Station"); item:SetAttribute("AnchorName", manifest.AnchorName); item:SetAttribute("Footprint", manifest.Footprint); item:SetAttribute("ApproachClearance", manifest.ApproachClearance); item:SetAttribute("Owner", manifest.Owner); item:SetAttribute("SourceBuilder", manifest.SourceBuilder); item.Parent = folder; return item
        end
        part("CabinetBody", Vector3.new(6, 7, 2), anchorCFrame * CFrame.new(0, 3.5, 0), "forest", Enum.Material.Wood, true)
        part("DisplayPanel", Vector3.new(5.2, 3.2, .18), anchorCFrame * CFrame.new(0, 5.05, -1.08), "cream", Enum.Material.Glass, false)
        part("GoldHeader", Vector3.new(5.4, .45, 2.15), anchorCFrame * CFrame.new(0, 7.2, 0), "golden", Enum.Material.Metal, false)
        part("Counter", Vector3.new(6.4, .35, 2.4), anchorCFrame * CFrame.new(0, 1.4, -.2), "wood", Enum.Material.Wood, true)
        for index = 1, 7 do part("FigureSlot" .. index, Vector3.new(.48, .72, .18), anchorCFrame * CFrame.new((index - 4) * .62, 5.05, -1.22), index == 7 and "blossom" or "sage", nil, false) end
        part("PromptPlate", Vector3.new(2.8, .5, .12), anchorCFrame * CFrame.new(0, 2.05, -1.22), "golden", Enum.Material.Neon, false)
        return folder
    end)
    return {folder = installed, manifest = manifest}
end
