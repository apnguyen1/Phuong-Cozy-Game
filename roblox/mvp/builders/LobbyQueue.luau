-- Detached lobby queue builder. Task 01 supplies the prebound MVP SafeReplace helper.
local TICKET = "PCW-17"
local BUILDER = "LobbyQueue"

local function metadata(part, token, anchor, footprint, clearance)
	part:SetAttribute("VerificationTicket", TICKET)
	part:SetAttribute("PaletteToken", token)
	part:SetAttribute("MVPBuilder", BUILDER)
	part:SetAttribute("AnchorName", anchor)
	part:SetAttribute("Footprint", footprint)
	part:SetAttribute("ApproachClearance", clearance)
	part:SetAttribute("Owner", "Task08")
	part:SetAttribute("SourceBuilder", BUILDER)
end

local function part(parent, name, size, frame, token, footprint, clearance)
	local value = Instance.new("Part")
	value.Name = name
	value.Size = size
	value.CFrame = frame
	value.Anchored = true
	value.CanCollide = true
	metadata(value, token, "BirthdayLobbyQueue", footprint, clearance)
	value.Parent = parent
end

local function validate(context)
	assert(type(context) == "table", "LobbyQueue requires context")
	assert(type(context.SafeReplace) == "function", "LobbyQueue requires prebound SafeReplace")
	assert(type(context.ValidateAnchors) == "function", "LobbyQueue requires shared anchor validator")
	assert(context:ValidateAnchors({ "BirthdayLobbyQueue" }), "BirthdayLobbyQueue anchor validation failed")
	local anchor = context.Anchors and context.Anchors.BirthdayLobbyQueue
	assert(typeof(anchor) == "Instance" and anchor:IsA("BasePart"), "BirthdayLobbyQueue must be a measured BasePart")
	if context.RequiredPalette then
		assert(context.RequiredPalette.forest and context.RequiredPalette.cream, "queue palette unavailable")
	end
end

local function factory(anchorCFrame)
	local folder = Instance.new("Folder")
	folder.Name = "LobbyQueue"
	folder:SetAttribute("VerificationTicket", TICKET)
	folder:SetAttribute("MVPBuilder", BUILDER)
	folder:SetAttribute("Owner", "Task08")
	folder:SetAttribute("SourceBuilder", BUILDER)
	part(folder, "QueueFloor", Vector3.new(12, 0.2, 12), anchorCFrame, "forest", "12x12 opt-in square", "16 studs")
	part(folder, "QueueSign", Vector3.new(8, 4, 0.2), anchorCFrame * CFrame.new(0, 3, -6), "cream", "8x4 readable sign", "12 studs")
	return folder
end

return function(context)
	validate(context)
	local anchorCFrame = context.Anchors.BirthdayLobbyQueue.CFrame
	assert(typeof(anchorCFrame) == "CFrame", "BirthdayLobbyQueue requires measured CFrame")
	local installedFolder = context.SafeReplace("LobbyQueue", function()
		return factory(anchorCFrame)
	end)
	return {
		folder = installedFolder,
		manifest = { Ticket = TICKET, Builder = BUILDER, Owner = "Task08", AnchorName = "BirthdayLobbyQueue", Footprint = "12x12 square plus sign", ApproachClearance = "16 studs / 12 studs", QueueRule = "one opt-in queue, max 10, shared deadline" },
	}
end
