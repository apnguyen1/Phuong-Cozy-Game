-- Shared primitives. All authored colors are exact approved palette tokens.
local UI = {}
UI.Palette = {
	forest = Color3.fromRGB(54, 87, 68), sage = Color3.fromRGB(168, 185, 149),
	cream = Color3.fromRGB(245, 240, 228), wood = Color3.fromRGB(149, 103, 75),
	blossom = Color3.fromRGB(232, 183, 198), brick = Color3.fromRGB(182, 108, 104),
	golden = Color3.fromRGB(232, 199, 121), ink = Color3.fromRGB(38, 56, 46),
}

function UI.Corner(instance, radius)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius or 12)
	corner.Parent = instance
	return corner
end

function UI.Padding(instance, amount)
	local padding = Instance.new("UIPadding")
	padding.PaddingTop = UDim.new(0, amount)
	padding.PaddingBottom = UDim.new(0, amount)
	padding.PaddingLeft = UDim.new(0, amount)
	padding.PaddingRight = UDim.new(0, amount)
	padding.Parent = instance
	return padding
end

function UI.List(instance, padding)
	local layout = Instance.new("UIListLayout")
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Padding = UDim.new(0, padding or 8)
	layout.Parent = instance
	return layout
end

function UI.Label(parent, name, value, size, color)
	local label = Instance.new("TextLabel")
	label.Name = name
	label.Text = value or ""
	label.TextColor3 = color or UI.Palette.ink
	label.BackgroundTransparency = 1
	label.BorderSizePixel = 0
	label.Font = Enum.Font.GothamMedium
	label.TextSize = size or 16
	label.TextWrapped = true
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextYAlignment = Enum.TextYAlignment.Top
	label.Size = UDim2.new(1, 0, 0, 0)
	label.AutomaticSize = Enum.AutomaticSize.Y
	label.Parent = parent
	return label
end

function UI.Button(parent, name, value, callback, secondary)
	local button = Instance.new("TextButton")
	button.Name = name
	button.Text = value or ""
	button.TextSize = 16
	button.Font = Enum.Font.GothamBold
	button.TextWrapped = true
	button.TextColor3 = secondary and UI.Palette.ink or UI.Palette.cream
	button.BackgroundColor3 = secondary and UI.Palette.sage or UI.Palette.forest
	button.BorderSizePixel = 0
	button.Size = UDim2.new(1, 0, 0, 52)
	button.AutoButtonColor = true
	button.Selectable = true
	button.Parent = parent
	UI.Corner(button, 10)
	local padding = UI.Padding(button, 8)
	padding.PaddingTop = UDim.new(0, 6)
	padding.PaddingBottom = UDim.new(0, 6)
	button.Activated:Connect(function() if button.Active then callback() end end)
	return button
end

function UI.SetEnabled(button, enabled, secondary)
	button.Active = enabled
	button.Interactable = enabled
	button.AutoButtonColor = enabled
	button.BackgroundColor3 = enabled and not secondary and UI.Palette.forest or UI.Palette.sage
	button.TextColor3 = enabled and not secondary and UI.Palette.cream or UI.Palette.ink
end

function UI.Card(parent, name, token)
	local frame = Instance.new("Frame")
	frame.Name = name
	frame.Size = UDim2.new(1, 0, 0, 0)
	frame.AutomaticSize = Enum.AutomaticSize.Y
	frame.BackgroundColor3 = UI.Palette[token or "sage"]
	frame.BorderSizePixel = 0
	frame.Parent = parent
	UI.Corner(frame)
	UI.Padding(frame, 12)
	UI.List(frame, 7)
	return frame
end

function UI.Clear(container)
	for _, child in ipairs(container:GetChildren()) do
		if child:IsA("GuiObject") then child:Destroy() end
	end
end

return UI
