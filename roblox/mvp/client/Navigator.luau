local UI = require(script.Parent.UI)
local Guidance = require(script.Parent.Parent.shared.Guidance)
local Navigator = {}
Navigator.__index = Navigator

function Navigator.new(player, gui)
	local self = setmetatable({ player = player, gui = gui, cache = {} }, Navigator)
	return self
end

function Navigator:Resolve(name)
	local cached = self.cache[name]
	if cached and cached:IsDescendantOf(workspace) then return cached end
	local world = workspace:FindFirstChild("CozyWorld_Draft01")
	local mvp = world and world:FindFirstChild("MVP")
	local found = mvp and mvp:FindFirstChild(name, true)
	if found and found:GetAttribute("PlacementStatus") ~= "UNRESOLVED_LIVE_ANCHOR" then
		local part = found:IsA("BasePart") and found or found:FindFirstChildWhichIsA("BasePart", true)
		self.cache[name] = part
		return part
	end
	return nil
end

function Navigator:Root()
	local character = self.player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if not humanoid or humanoid.Health <= 0 then return nil end
	return character:FindFirstChild("HumanoidRootPart")
end

function Navigator:Nearest(id, view)
	local root = self:Root()
	local best, distance = nil, math.huge
	for _, name in ipairs(Guidance.AnchorNames(id, view)) do
		local anchor = self:Resolve(name)
		if anchor then
			local d = root and (anchor.Position - root.Position).Magnitude or 0
			if d < distance then best, distance = anchor, d end
		end
	end
	return best, distance
end

function Navigator:Distances(views)
	local distances = {}
	for _, id in ipairs(Guidance.Order) do
		local _, distance = self:Nearest(id, views[id])
		distances[id] = distance
	end
	return distances
end

function Navigator:Clear()
	if self.billboard then self.billboard:Destroy(); self.billboard = nil end
	if self.highlight then self.highlight:Destroy(); self.highlight = nil end
	self.anchor, self.activityId = nil, nil
end

function Navigator:SetTarget(id, view)
	if self.suspended or self.player:GetAttribute("BirthdayLocation") ~= "World" or not self:Root() then self:Clear(); return end
	local anchor = self:Nearest(id, view)
	if not anchor then self:Clear(); return end
	if self.anchor == anchor and self.activityId == id then return end
	self:Clear()
	self.anchor, self.activityId = anchor, id
	local billboard = Instance.new("BillboardGui")
	billboard.Name = "BirthdayDestinationMarker"
	billboard.Adornee = anchor
	billboard.AlwaysOnTop = true
	billboard.Size = UDim2.fromOffset(218, 68)
	billboard.StudsOffsetWorldSpace = Vector3.new(0, 5, 0)
	billboard.MaxDistance = 900
	billboard.Active = false
	billboard.Parent = self.gui
	local background = Instance.new("Frame")
	background.Size = UDim2.fromScale(1, 1)
	background.BackgroundColor3 = UI.Palette.cream
	background.BorderSizePixel = 0
	background.Parent = billboard
	UI.Corner(background)
	UI.Padding(background, 8)
	local label = UI.Label(background, "Destination", "", 15, UI.Palette.forest)
	label.Size = UDim2.fromScale(1, 1)
	label.AutomaticSize = Enum.AutomaticSize.None
	label.TextXAlignment = Enum.TextXAlignment.Center
	label.TextYAlignment = Enum.TextYAlignment.Center
	self.billboard, self.label = billboard, label
	local highlight = Instance.new("Highlight")
	highlight.Name = "BirthdayDestinationOutline"
	highlight.Adornee = anchor
	highlight.FillTransparency = 1
	highlight.OutlineColor = UI.Palette.golden
	highlight.OutlineTransparency = 0
	highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	highlight.Parent = self.gui
	self.highlight = highlight
end

function Navigator:Update()
	local root, anchor = self:Root(), self.anchor
	if self.suspended or not root or not anchor or not anchor:IsDescendantOf(workspace) or self.player:GetAttribute("BirthdayLocation") ~= "World" then
		self:Clear()
		return ""
	end
	local info = Guidance.Activities[self.activityId]
	local distance = math.floor((root.Position - anchor.Position).Magnitude + .5)
	-- On arrival the HUD and interaction prompt already name the destination.
	-- Keep the world object visible instead of covering it with a second sign.
	self.billboard.Enabled = self.gui.Enabled and distance > 12
	self.highlight.Enabled = self.gui.Enabled
	local camera = workspace.CurrentCamera
	local hint = "Walk toward the marker"
	if distance <= 12 then
		hint = "You're here · use the nearby prompt"
	elseif camera then
		local _, onScreen = camera:WorldToViewportPoint(anchor.Position + Vector3.new(0, 5, 0))
		local relative = camera.CFrame:PointToObjectSpace(anchor.Position)
		if relative.Z > 0 then hint = "↶ Turn around"
		elseif not onScreen then hint = relative.X > 0 and "→ Turn right" or "← Turn left"
		else hint = "↑ Follow the marker" end
	end
	self.label.Text = "◆ " .. info.short .. "\n" .. tostring(distance) .. " studs"
	return hint .. " · " .. tostring(distance) .. " studs"
end

return Navigator
