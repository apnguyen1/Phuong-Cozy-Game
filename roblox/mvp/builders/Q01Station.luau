-- Native, installable Q01 bed/station visuals. Task 01 owns actual Studio installation.
local Q01Station = {}

local COLORS = {
	Forest = Color3.fromRGB(54, 87, 68), Sage = Color3.fromRGB(168, 185, 149), Cream = Color3.fromRGB(245, 240, 228),
	Wood = Color3.fromRGB(149, 103, 75), Golden = Color3.fromRGB(232, 199, 121), Ink = Color3.fromRGB(38, 56, 46),
}

local function part(parent, name, size, cframe, color, canCollide)
	local p = Instance.new("Part")
	p.Name, p.Size, p.CFrame, p.Color, p.Anchored, p.CanCollide = name, size, cframe, color, true, canCollide ~= false
	p.Material = Enum.Material.SmoothPlastic
	p:SetAttribute("VerificationTicket", "PCW-07")
	p:SetAttribute("PaletteToken", color == COLORS.Sage and "sage" or color == COLORS.Wood and "wood" or color == COLORS.Cream and "cream" or color == COLORS.Forest and "forest" or color == COLORS.Golden and "golden" or "ink")
	p:SetAttribute("MVPBuilder", "Q01Station")
	p.Parent = parent
	return p
end

function Q01Station.Build(anchorCFrame)
	assert(anchorCFrame, "Q01Station.Build requires Q01Bed CFrame")
	local model = Instance.new("Model")
	model.Name = "Q01EverythingTuckedIn"
	model:SetAttribute("ActivityId", "Q01")
	model:SetAttribute("VerificationTicket", "PCW-07")
	local base = anchorCFrame
	part(model, "BedFrame", Vector3.new(7, 1, 10), base * CFrame.new(0, 0.5, 0), COLORS.Wood)
	part(model, "SageBedding", Vector3.new(6.7, 0.55, 8.6), base * CFrame.new(0, 1.25, 0.2), COLORS.Sage)
	part(model, "Headboard", Vector3.new(7, 4, 0.5), base * CFrame.new(0, 2.5, -4.7), COLORS.Cream)
	local pillows = { { "PillowLeft", -1.7 }, { "PillowRight", 1.7 } }
	for _, data in ipairs(pillows) do part(model, data[1], Vector3.new(2.5, 0.45, 1.5), base * CFrame.new(data[2], 1.75, -3), COLORS.Cream, false) end
	part(model, "RoundBelliedDog", Vector3.new(1.7, 1.6, 1.7), base * CFrame.new(-2.1, 2, -0.6), COLORS.Golden, false)
	part(model, "DinosaurPlush", Vector3.new(1.5, 1.8, 2), base * CFrame.new(2.1, 2.1, -0.4), COLORS.Forest, false)
	local socketOffsets = { blanket_left = Vector3.new(-3.8, 1.5, 0), blanket_right = Vector3.new(3.8, 1.5, 0), blanket_foot = Vector3.new(0, 1.5, 5.1), pillow_left = Vector3.new(-1.7, 1.9, -3), pillow_right = Vector3.new(1.7, 1.9, -3), plush_dog = Vector3.new(-2.1, 2.2, -0.6), plush_dinosaur = Vector3.new(2.1, 2.2, -0.4) }
	for stepId, offset in pairs(socketOffsets) do
		local socket = part(model, "Socket_" .. stepId, Vector3.new(2.2, 0.15, 1.8), base * CFrame.new(offset), COLORS.Golden, false)
		socket.Transparency = 0.65
		socket:SetAttribute("StepId", stepId)
	end
	model.PrimaryPart = model:FindFirstChild("BedFrame")
	return model
end

return function(context)
	assert(context and context.Root and context.MVP and context.Anchors and context.SafeReplace, "Q01Station context is incomplete")
	local anchor = context.Anchors.Q01Bed
	assert(anchor, "Q01Station requires resolved Q01Bed anchor")
	local placementStatus = anchor:GetAttribute("PlacementStatus")
	assert(placementStatus and not string.find(placementStatus, "UNRESOLVED", 1, true), "Q01Bed anchor lacks valid live placement provenance")
	local anchorCFrame = anchor:IsA("BasePart") and anchor.CFrame or CFrame.new(anchor.Position)
	local manifest = {
		AnchorName = "Q01Bed",
		Footprint = "7x10 bed; sockets remain outside collision",
		ApproachClearance = "Measured by integrator from live anchor",
		Owner = "Task02",
		SourceBuilder = "roblox/mvp/builders/Q01Station.luau",
	}
	local installedFolder = context.SafeReplace("Q01Station", function()
		local model = Q01Station.Build(anchorCFrame)
		model:SetAttribute("Owner", manifest.Owner)
		model:SetAttribute("MVPBuilder", "Q01Station")
		model:SetAttribute("AnchorName", manifest.AnchorName)
		model:SetAttribute("Footprint", manifest.Footprint)
		model:SetAttribute("ApproachClearance", manifest.ApproachClearance)
		model:SetAttribute("SourceBuilder", manifest.SourceBuilder)
		return model
	end)
	return { folder = installedFolder, manifest = manifest }
end
