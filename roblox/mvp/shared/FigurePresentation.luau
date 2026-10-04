-- Bounded native geometry shared by world displays and client ViewportFrames.
-- All figures retain paired long ears, a cream face, eyes, a toothy smile,
-- rounded body and feet. Labels distinguish the seven simplified toy styles.
local Catalog = require(script.Parent.FigureCatalog)
local Presentation = {}
Presentation.Palette = {
	forest = Color3.fromRGB(54, 87, 68), sage = Color3.fromRGB(168, 185, 149),
	cream = Color3.fromRGB(245, 240, 228), wood = Color3.fromRGB(149, 103, 75),
	blossom = Color3.fromRGB(232, 183, 198), brick = Color3.fromRGB(182, 108, 104),
	golden = Color3.fromRGB(232, 199, 121), ink = Color3.fromRGB(38, 56, 46),
}
function Presentation.Part(parent, name, size, cf, token, shape)
	local value = Instance.new("Part")
	value.Name, value.Size, value.CFrame = name, size, cf
	value.Shape = shape or Enum.PartType.Block
	value.Color, value.Material, value.CastShadow = Presentation.Palette[token], Enum.Material.SmoothPlastic, false
	value.Anchored, value.CanCollide, value.CanTouch, value.CanQuery = true, false, false, false
	value:SetAttribute("PaletteToken", token); value:SetAttribute("VerificationTicket", "PCW-21")
	value.Parent = parent; return value
end
function Presentation.Build(id, scale)
	local entry = assert(Catalog.ById[id], "Unknown figure presentation")
	local model = Instance.new("Model"); model.Name = "Figure"; model.WorldPivot = CFrame.identity
	model:SetAttribute("FigureId", id); model:SetAttribute("FigureLabel", entry.label)
	model:SetAttribute("SimplifiedArt", true); model:SetAttribute("VerificationTicket", "PCW-21")
	scale = scale or 1
	local function shape(name, size, position, token, block, rotation)
		return Presentation.Part(model, name, size * scale, CFrame.new(position * scale) * (rotation or CFrame.identity), token, block and Enum.PartType.Block or Enum.PartType.Ball)
	end
	shape("Body", Vector3.new(1.04, 1.2, .72), Vector3.new(0, .88, 0), entry.body)
	shape("Head", Vector3.new(1.32, 1.08, .84), Vector3.new(0, 1.8, 0), entry.body)
	shape("Face", Vector3.new(1.05, .78, .23), Vector3.new(0, 1.76, -.4), "cream")
	for _, side in ipairs({ -1, 1 }) do
		local tilt = CFrame.Angles(0, 0, -side * .12)
		shape("LongEar", Vector3.new(.37, 1, .35), Vector3.new(side * .38, 2.58, .01), entry.body, false, tilt)
		shape("InnerEar", Vector3.new(.16, .67, .08), Vector3.new(side * .38, 2.58, -.17), entry.accent, false, tilt)
		shape("Eye", Vector3.new(.13, .17, .07), Vector3.new(side * .24, 1.89, -.53), "ink")
		shape("Arm", Vector3.new(.29, .65, .35), Vector3.new(side * .57, .99, -.01), entry.body, false, CFrame.Angles(0, 0, side * .18))
		shape("Foot", Vector3.new(.45, .27, .55), Vector3.new(side * .3, .16, -.12), entry.body)
	end
	shape("ToothySmile", Vector3.new(.55, .2, .06), Vector3.new(0, 1.57, -.53), "ink")
	for index = 1, 5 do shape("Tooth", Vector3.new(.065, .095, .035), Vector3.new((index - 3) * .09, 1.605, -.568), "cream", true) end
	-- Distinct small chest motifs, never a replacement for the paired-ear shape.
	local badge = Vector3.new(0, .98, -.37)
	if entry.badge == "heart" then
		for _, side in ipairs({ -1, 1 }) do shape("Heart", Vector3.new(.24, .34, .07), badge + Vector3.new(side * .085, 0, 0), entry.accent, false, CFrame.Angles(0, 0, side * -.55)) end
	elseif entry.badge == "pair" or entry.badge == "bow" then
		for _, side in ipairs({ -1, 1 }) do shape("PairedBadge", Vector3.new(.23, .22, .08), badge + Vector3.new(side * .13, 0, 0), entry.accent) end
	elseif entry.badge == "clover" then
		for index = 1, 4 do local angle = index * math.pi / 2; shape("Clover", Vector3.new(.2, .2, .07), badge + Vector3.new(math.cos(angle) * .11, math.sin(angle) * .11, 0), entry.accent) end
	elseif entry.badge == "star" then
		shape("SecretBadge", Vector3.new(.3, .3, .07), badge, entry.accent, true, CFrame.Angles(0, 0, math.pi / 4))
	else
		shape("RoundBadge", Vector3.new(.34, .34, .08), badge, entry.accent)
		if entry.badge == "moon" then shape("MoonCutout", Vector3.new(.26, .26, .04), badge + Vector3.new(.1, .05, -.05), entry.body) end
	end
	return model
end
function Presentation.Capsule(scale, opened)
	scale = scale or 1
	local model = Instance.new("Model"); model.Name = "Capsule"; model.WorldPivot = CFrame.identity
	model:SetAttribute("VerificationTicket", "PCW-21")
	Presentation.Part(model, "Lower", Vector3.new(1.5, .9, 1.5) * scale, CFrame.new(0, .45 * scale, 0), "golden", Enum.PartType.Ball)
	Presentation.Part(model, "Upper", Vector3.new(1.5, .9, 1.5) * scale, CFrame.new(0, (opened and 1.8 or 1.02) * scale, 0), "cream", Enum.PartType.Ball)
	Presentation.Part(model, "Seam", Vector3.new(.08, 1.49, 1.49) * scale, CFrame.new(0, .74 * scale, 0) * CFrame.Angles(0, 0, math.pi / 2), "forest", Enum.PartType.Cylinder)
	return model
end
return Presentation
