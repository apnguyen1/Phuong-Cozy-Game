-- Edit-mode builder for the two missing end seats at the existing birthday table.
-- Requiring this module has no live-world side effects; the integrator invokes
-- the returned function with the shared builder context.

return function(context)
    assert(context and context.Root and context.MVP and context.Anchors and context.Palette,
        "CakeFinale context requires Root, MVP, Anchors and Palette")
    assert(context.SafeReplace, "CakeFinale requires SafeReplace")
    local patioMarker = assert(context.Anchors.FinalePatio, "FinalePatio anchor is required")
    local courtyard = patioMarker:FindFirstAncestor("BirthdayCourtyard")
        or context.Root:FindFirstChild("BirthdayCourtyard", true)
    assert(courtyard, "Existing BirthdayCourtyard is required")
    local gatheringTable = assert(courtyard:FindFirstChild("GatheringTable", true), "Existing GatheringTable is required")
    assert(gatheringTable:IsA("BasePart"), "GatheringTable must be a BasePart")
    local cake = assert(courtyard:FindFirstChild("BirthdayCake", true), "Existing BirthdayCake is required")
    local existingSeats = {}
    for _, object in courtyard:GetDescendants() do
        if object:IsA("Seat") or object:IsA("VehicleSeat") then table.insert(existingSeats, object) end
    end
    assert(#existingSeats == 8, "CakeFinale expects exactly 8 existing seats; found " .. #existingSeats)
    local seatHeight = existingSeats[1].Position.Y
    local tableHalfX = gatheringTable.Size.X / 2
    local seatOffset = tableHalfX + 4
    local V, CF = Vector3.new, CFrame.new
    local candidates = {
        {name = "EndSeatWest", sign = -1},
        {name = "EndSeatEast", sign = 1},
    }

    local function candidateCFrame(sign)
        local localPosition = V(sign * seatOffset, seatHeight - gatheringTable.Position.Y, 0)
        return gatheringTable.CFrame * CF(localPosition) * CFrame.Angles(0, sign * math.pi / 2, 0)
    end

    local overlapParams = OverlapParams.new()
    overlapParams.FilterType = Enum.RaycastFilterType.Exclude
    overlapParams.FilterDescendantsInstances = {courtyard, context.MVP}
    for _, candidate in candidates do
        local seatCFrame = candidateCFrame(candidate.sign)
        local blockers = workspace:GetPartBoundsInBox(seatCFrame, V(3, 4, 3), overlapParams)
        assert(#blockers == 0, "CakeFinale seat conflict before mutation: " .. candidate.name)
    end

    for _, token in {"forest", "sage", "cream", "wood", "blossom", "brick", "golden", "ink"} do
        assert(context.Palette[token], "CakeFinale missing palette token: " .. token)
    end

    local folder = Instance.new("Folder")
    folder.Name = "CakeFinale"
    folder:SetAttribute("Owner", "Task09")
    folder:SetAttribute("MVPBuilder", "CakeFinale")
    folder:SetAttribute("SourceBuilder", "roblox/mvp/builders/CakeFinale.luau")
    folder:SetAttribute("VerificationTicket", "PCW-14")
    folder:SetAttribute("Status", "Source authored; Studio collision/route verification pending")
    folder:SetAttribute("Preserves", "BirthdayCourtyard.BirthdayCake, GatheringTable, and 8 existing seats")
    folder:SetAttribute("SeatCountAdded", 2)
    folder:SetAttribute("SeatCountExpected", 10)

    local seatManifest = {}
    local function makePart(name, size, cframe, token, parent, canCollide)
        local part = Instance.new("Part")
        part.Name = name
        part.Size = size
        part.CFrame = cframe
        part.Color = context.Palette[token]
        part:SetAttribute("PaletteToken", token)
        part:SetAttribute("Owner", "Task09")
        part:SetAttribute("MVPBuilder", "CakeFinale")
        part:SetAttribute("VerificationTicket", "PCW-14")
        part:SetAttribute("SourceBuilder", "roblox/mvp/builders/CakeFinale.luau")
        part.Anchored = true
        part.CanCollide = canCollide
        part.CanTouch = canCollide
        part.CanQuery = canCollide
        part.Parent = parent
        return part
    end

    for _, candidate in candidates do
        local model = Instance.new("Model")
        model.Name = candidate.name
        model:SetAttribute("Owner", "Task09")
        model:SetAttribute("Interaction", "OptionalEatOrSit")
        model:SetAttribute("ApproachRule", "Voluntary walk; no auto-warp or camera lock")
        model.Parent = folder
        local seatCFrame = candidateCFrame(candidate.sign)
        local seat = Instance.new("Seat")
        seat.Name = "Seat"
        seat.Size = V(2, 0.4, 2)
        seat.CFrame = seatCFrame
        seat.Color = context.Palette.wood
        seat:SetAttribute("PaletteToken", "wood")
        seat:SetAttribute("Owner", "Task09")
        seat:SetAttribute("MVPBuilder", "CakeFinale")
        seat:SetAttribute("VerificationTicket", "PCW-14")
        seat:SetAttribute("SourceBuilder", "roblox/mvp/builders/CakeFinale.luau")
        seat:SetAttribute("AnchorName", "FinalePatio")
        seat.Anchored = true
        seat.Parent = model
        makePart("Back", V(2, 2.2, 0.35), seatCFrame * CF(0, 1.1, 0.8), "sage", model, true)
        table.insert(seatManifest, "BirthdayCourtyard.CakeFinale." .. candidate.name .. ".Seat")
    end

    local installed = context.SafeReplace("CakeFinale", function()
        return folder
    end)
    return {
        folder = installed,
        manifest = {
            name = "CakeFinale",
            sourceBuilder = "roblox/mvp/builders/CakeFinale.luau",
            preserved = {"BirthdayCourtyard.BirthdayCake", "BirthdayCourtyard.GatheringTable", "8 existing Seat instances"},
            addedSeatReferences = seatManifest,
            expectedTotalSeats = 10,
            tableDerivedSeatOffset = seatOffset,
            tableDerivedSeatHeight = seatHeight,
            runtimeHooks = {"FinalePatio proximity", "CakeService Invite/CancelInvite/Cut/Eat"},
            pendingEngineChecks = {"route clearance", "collision overlap", "ten-player seating", "post-cut free play"},
        },
    }
end
