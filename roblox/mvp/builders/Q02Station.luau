-- Q02 edit-mode builder. The integrator supplies the frozen builder context.
return function(context)
    assert(context and context.Root and context.MVP and context.Anchors and context.Palette, "Q02 builder context is required")
    assert(type(context.SafeReplace) == "function", "Q02 requires SafeReplace(name, factory)")
    local bedroom = context.Anchors.JasperBedroomStart
    local yard = context.Anchors.JasperFetchYard
    assert(bedroom and yard, "Q02 requires JasperBedroomStart and JasperFetchYard")
    assert(bedroom:GetAttribute("PlacementStatus") ~= "UNRESOLVED_LIVE_ANCHOR" and yard:GetAttribute("PlacementStatus") ~= "UNRESOLVED_LIVE_ANCHOR", "Q02 anchors cannot be unresolved")
    local requiredPalette = {"forest", "sage", "cream", "wood", "golden", "ink"}
    for _, token in ipairs(requiredPalette) do assert(context.Palette[token], "Q02 palette token is missing: " .. token) end

    local function factory()
        local folder = Instance.new("Folder")
        folder.Name = "Q02"
        folder:SetAttribute("VerificationTicket", "PCW-08")
        folder:SetAttribute("MVPBuilder", "Q02Station")
        folder:SetAttribute("Owner", "Q02")
        folder:SetAttribute("Status", "Source authored; Studio install and play verification pending")
        folder:SetAttribute("PalettePolicy", "Exact world palette until approved Jasper figure profile")
        local function marker(name, position, size, token, action, anchorName, footprint, clearance)
            local part = Instance.new("Part")
            part.Name, part.Size, part.CFrame = name, size, CFrame.new(position)
            part.Color, part.Anchored, part.CanCollide, part.CanTouch, part.CanQuery = context.Palette[token], true, false, false, true
            part.Transparency, part.Material = .45, Enum.Material.SmoothPlastic
            part:SetAttribute("VerificationTicket", "PCW-08")
            part:SetAttribute("PaletteToken", token)
            part:SetAttribute("MVPBuilder", "Q02Station")
            part:SetAttribute("Owner", "Q02")
            part:SetAttribute("AnchorName", anchorName)
            part:SetAttribute("Footprint", footprint)
            part:SetAttribute("ApproachClearance", clearance)
            part:SetAttribute("Q02Action", action)
            part.Parent = folder
        end
        local bedroomPosition, yardPosition = bedroom.Position, yard.Position
        marker("JasperBedroomGreeting", bedroomPosition, Vector3.new(5, 2, 5), "golden", "greet", "JasperBedroomStart", "5x2x5", "2 studs")
        marker("JasperFetchLane", yardPosition, Vector3.new(10, .3, 5), "forest", "throw", "JasperFetchYard", "10x0.3x5", "3 studs")
        for index = 1, 3 do marker("JasperRabbitBasket" .. string.char(64 + index), yardPosition + Vector3.new((index - 2) * 4, 1, 5), Vector3.new(2, 2, 2), "wood", "inspect", "JasperFetchYard", "2x2x2", "2 studs") end
        marker("JasperRabbitHandoff", yardPosition + Vector3.new(0, 1, -3), Vector3.new(3, 2, 3), "sage", "return_rabbit", "JasperFetchYard", "3x2x3", "2 studs")
        marker("JasperGreenie", yardPosition + Vector3.new(0, 1, -5), Vector3.new(3, 2, 2), "golden", "greenie", "JasperFetchYard", "3x2x2", "2 studs")
        folder:SetAttribute("PromptBindings", "JasperBedroomStart:greet; JasperFetchYard:inspect,throw,return_rabbit,greenie")
        folder:SetAttribute("SourceAnchorState", "validated")
        return folder
    end
    local installed = context.SafeReplace("Q02Station", factory)
    return {folder = installed, manifest = {ticket = "PCW-08", builder = "Q02Station", owner = "Q02", anchorNames = {"JasperBedroomStart", "JasperFetchYard"}, promptBindings = {"bedroom:greet", "yard:inspect", "yard:throw", "yard:return_rabbit", "yard:greenie"}, paletteTokens = requiredPalette, sourceReference = "Existing Jasper identity is preserved; this builder stages interaction markers only.", verification = "Studio install, navigation, figure identity, touch/desktop and group play remain pending."}}
end
