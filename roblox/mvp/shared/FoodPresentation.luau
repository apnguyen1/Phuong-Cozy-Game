-- Deterministic presentation only. Server and local preview use the same shapes.
-- No rewards, permissions, remote requests or user transforms belong here.
local FoodPresentation = {}
local P = {
	forest = Color3.fromRGB(54, 87, 68), sage = Color3.fromRGB(168, 185, 149),
	cream = Color3.fromRGB(245, 240, 228), wood = Color3.fromRGB(149, 103, 75),
	blossom = Color3.fromRGB(232, 183, 198), brick = Color3.fromRGB(182, 108, 104),
	golden = Color3.fromRGB(232, 199, 121), ink = Color3.fromRGB(38, 56, 46),
}
local LABELS = { rice = "Rice", tofu = "Tofu", chicken = "Chicken", mushroom = "Mushroom", greens = "Greens", cucumber = "Cucumber", carrot = "Carrot", sauce = "Sauce", sesame = "Sesame", plate = "Plate", cup = "Cup", napkin = "Napkin" }
local ORDER = { "base", "protein", "toppings", "sauce", "settingA", "settingB" }
local function part(parent, name, size, frame, token, shape)
	local value = Instance.new("Part")
	value.Name, value.Size, value.CFrame = name, size, frame
	value.Shape = shape or Enum.PartType.Block
	value.Anchored, value.CanCollide, value.CanTouch, value.CanQuery = true, false, false, false
	value.Color, value.Material, value.CastShadow = P[token], Enum.Material.SmoothPlastic, false
	value:SetAttribute("PaletteToken", token); value:SetAttribute("VerificationTicket", "PCW-20")
	value.Parent = parent; return value
end
local function disc(parent, name, diameter, height, frame, token)
	return part(parent, name, Vector3.new(height, diameter, diameter), frame * CFrame.Angles(0, 0, math.pi / 2), token, Enum.PartType.Cylinder)
end
local function round(parent, name, size, frame, token)
	return part(parent, name, size, frame, token, Enum.PartType.Ball)
end
local function ingredient(parent, slot, item)
	local model = Instance.new("Model"); model.Name = slot; model.Parent = parent
	model:SetAttribute("SlotId", slot); model:SetAttribute("ItemId", item); model:SetAttribute("ItemLabel", LABELS[item])
	local y = .65
	if item == "rice" then
		disc(model, "RiceBase", 2.05, .16, CFrame.new(0, .49, 0), "cream")
		for index = 1, 8 do
			local angle = index * math.pi / 4
			round(model, "RiceGrain", Vector3.new(.27, .1, .12), CFrame.new(math.cos(angle) * .7, .6, math.sin(angle) * .7) * CFrame.Angles(0, angle, 0), "cream")
		end
	elseif item == "tofu" or item == "chicken" then
		for index = 1, 4 do
			local frame = CFrame.new(-.55 + (index % 2) * .65, y + .08, -.62 + math.floor((index - 1) / 2) * .6) * CFrame.Angles(0, index * .35, 0)
			if item == "tofu" then part(model, "TofuCube", Vector3.new(.45, .34, .45), frame, "cream")
			else round(model, "ChickenPiece", Vector3.new(.58, .34, .42), frame, "golden") end
		end
	elseif item == "mushroom" then
		for index = 1, 3 do
			local frame = CFrame.new(-.72 + index * .38, y, -.45 + (index % 2) * .43)
			part(model, "MushroomStem", Vector3.new(.14, .3, .15), frame, "cream")
			round(model, "MushroomCap", Vector3.new(.52, .23, .43), frame * CFrame.new(0, .17, 0), "wood")
		end
	elseif item == "greens" then
		for index = 1, 5 do round(model, "Leaf", Vector3.new(.38, .12, .55), CFrame.new(-.8 + index * .29, y + .1, .53 + (index % 2) * .15) * CFrame.Angles(0, index * .75, .2), "sage") end
	elseif item == "cucumber" then
		for index = 1, 4 do
			local frame = CFrame.new(-.7 + (index - 1) * .45, y + .07, .5)
			disc(model, "CucumberSkin", .48, .1, frame, "forest")
			disc(model, "CucumberCenter", .36, .11, frame * CFrame.new(0, .01, 0), "sage")
		end
	elseif item == "carrot" then
		for index = 1, 5 do part(model, "CarrotStrip", Vector3.new(.12, .1, .65), CFrame.new(-.65 + index * .22, y + .12, .52) * CFrame.Angles(0, index * .17, 0), "golden") end
	elseif item == "sauce" then
		for index = 1, 3 do part(model, "SauceDrizzle", Vector3.new(1.6, .06, .09), CFrame.new(0, 1, -.5 + index * .32) * CFrame.Angles(0, -.25, 0), "wood") end
	elseif item == "sesame" then
		for index = 1, 9 do
			local angle = index * 2.4
			round(model, "SesameSeed", Vector3.new(.12, .06, .07), CFrame.new(math.cos(angle) * (.25 + index * .045), 1, math.sin(angle) * (.25 + index * .045)) * CFrame.Angles(0, angle, 0), "golden")
		end
	elseif item == "plate" then
		disc(model, "PlateRim", 1.9, .12, CFrame.new(-2.25, .14, 0), "cream")
		disc(model, "PlateWell", 1.5, .04, CFrame.new(-2.25, .21, 0), "sage")
	elseif item == "cup" then
		disc(model, "CupBody", .8, .85, CFrame.new(2.15, .49, 0), "cream")
		disc(model, "CupInside", .62, .04, CFrame.new(2.15, .925, 0), "wood")
		part(model, "CupHandle", Vector3.new(.26, .38, .17), CFrame.new(2.65, .54, 0), "cream")
	elseif item == "napkin" then
		local x = slot == "settingA" and -2.25 or 2.15
		part(model, "FoldedNapkin", Vector3.new(1.25, .09, .95), CFrame.new(x, .16, 0) * CFrame.Angles(0, .13, 0), "sage")
		part(model, "NapkinFold", Vector3.new(.6, .035, .95), CFrame.new(x + .25, .22, 0) * CFrame.Angles(0, .13, 0), "cream")
	end
	return model
end
function FoodPresentation.Build(accepted, held)
	local model = Instance.new("Model"); model.Name = "SharedDish"
	model:SetAttribute("VerificationTicket", "PCW-20"); model.WorldPivot = CFrame.identity
	part(model, "ServingMat", Vector3.new(6.5, .06, 2.8), CFrame.new(0, .03, 0), "wood")
	disc(model, "BowlFoot", 1.5, .12, CFrame.new(0, .13, 0), "cream")
	disc(model, "BowlBody", 2.5, .36, CFrame.new(0, .33, 0), "cream")
	disc(model, "BowlInside", 2.15, .025, CFrame.new(0, .52, 0), "sage")
	for _, slot in ipairs(ORDER) do
		local choice = accepted and accepted[slot]
		local item = type(choice) == "table" and choice.itemId or nil
		if item and LABELS[item] then ingredient(model, slot, item) end
	end
	-- Local-only preview. Server never passes a hold to shared world rendering.
	if held and LABELS[held.itemId] and not (accepted and accepted[held.slotId]) and table.find(ORDER, held.slotId) then
		local selection = ingredient(model, held.slotId, held.itemId)
		selection.Name = "SelectedPreview"; selection:SetAttribute("PreviewOnly", true)
	end
	return model
end
return FoodPresentation
