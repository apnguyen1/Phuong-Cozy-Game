-- One bounded runtime dish, plus route labels on the existing three counters.
local FoodPresentation = require(script.Parent.Parent.shared.FoodPresentation)
local FoodFeedback = {}
FoodFeedback.__index = FoodFeedback
local VENUES = {
	{ id = "FOB", anchor = "Q06FOBCounter", label = "1 · FOB", task = "Rice + protein + fresh topping", next = "Next · Aladdins" },
	{ id = "Aladdins", anchor = "Q06AladdinsCounter", label = "2 · Aladdins", task = "Sauce or sesame", next = "Next · serving table" },
	{ id = "Serving", anchor = "Q06Serving", label = "3 · Serving table", task = "Left + right table settings", next = "Share your meal" },
}
local function folder(parent, name)
	local value = Instance.new("Folder"); value.Name = name; value.Parent = parent; return value
end
local function surface(mvp, anchor)
	local stations = mvp:FindFirstChild("Stations")
	local station = stations and stations:FindFirstChild("Q06Station")
	local counter = station and station:FindFirstChild(anchor.Name, true)
	local top = counter and counter:FindFirstChild("ActionSurface")
	if top and top:IsA("BasePart") then return top.CFrame * CFrame.new(0, top.Size.Y / 2 + .03, 0) end
	-- Matches the existing Q06Station counter contract. No builder is invoked.
	return anchor.CFrame * CFrame.new(0, 2.205, 0)
end
function FoodFeedback.new(mvp, anchors)
	local runtime = mvp:FindFirstChild("RuntimePresentation") or folder(mvp, "RuntimePresentation")
	assert(not runtime:FindFirstChild("FoodFeedback"), "FoodFeedback is already running")
	local root = folder(runtime, "FoodFeedback"); root:SetAttribute("VerificationTicket", "PCW-20")
	local self = setmetatable({ root = root, frames = {}, labels = {} }, FoodFeedback)
	for _, venue in ipairs(VENUES) do
		local anchor = anchors[venue.anchor]
		if anchor and anchor:IsA("BasePart") then
			self.frames[venue.id] = surface(mvp, anchor)
			local cue = Instance.new("Part")
			cue.Name, cue.Size, cue.CFrame = venue.anchor .. "Cue", Vector3.new(.1, .1, .1), self.frames[venue.id] * CFrame.new(0, 1.9, -1)
			cue.Anchored, cue.CanCollide, cue.CanTouch, cue.CanQuery, cue.Transparency = true, false, false, false, 1
			cue.Color = Color3.fromRGB(54, 87, 68); cue:SetAttribute("PaletteToken", "forest"); cue:SetAttribute("VerificationTicket", "PCW-20"); cue.Parent = root
			local gui = Instance.new("BillboardGui")
			gui.Name, gui.Size, gui.AlwaysOnTop, gui.MaxDistance = "FoodRoute", UDim2.fromOffset(250, 92), false, 38
			gui.Adornee, gui.Parent = cue, cue
			local text = Instance.new("TextLabel")
			text.Name, text.Size, text.Font, text.TextSize = "RouteText", UDim2.fromScale(1, 1), Enum.Font.GothamMedium, 14
			text.BackgroundColor3, text.TextColor3, text.BorderSizePixel = Color3.fromRGB(245, 240, 228), Color3.fromRGB(38, 56, 46), 0
			text.TextWrapped, text.Parent = true, gui
			self.labels[venue.id] = text
		else warn("PCW-20 food counter anchor is unavailable", venue.anchor) end
	end
	self:Render(nil, {}, "FOB", false)
	return self
end
function FoodFeedback:Render(roundId, accepted, venueId, complete)
	-- Rebuild only on accepted progress or a new round, never on selections or views.
	-- At most one six-ingredient dish exists, including across repeated replays.
	if self.dish then self.dish:Destroy(); self.dish = nil end
	local frame = self.frames[venueId]
	if frame then
		local model = FoodPresentation.Build(accepted)
		model:SetAttribute("RoundId", roundId); model:SetAttribute("VenueId", venueId); model:SetAttribute("Completed", complete)
		model.Parent = self.root; model:PivotTo(frame); self.dish = model
	end
	self.root:SetAttribute("RoundId", roundId); self.root:SetAttribute("VenueId", venueId)
	for _, venue in ipairs(VENUES) do
		local label = self.labels[venue.id]
		if label then
			local state = complete and "Done · meal ready at serving" or venue.id == venueId and "Build the shared meal here" or "Current step · " .. (venueId == "Serving" and "serving table" or venueId)
			label.Text = venue.label .. "\n" .. venue.task .. "\n" .. state .. "\n" .. venue.next
		end
	end
end
function FoodFeedback:Destroy() self.root:Destroy() end
return FoodFeedback
