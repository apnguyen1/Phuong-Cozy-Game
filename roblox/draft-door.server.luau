-- Shared front door. The server owns its state and checks interaction distance.
local home = workspace:WaitForChild("CozyWorld_Draft01"):WaitForChild("Home")
local door = home:WaitForChild("FrontDoor")
local prompt = home:WaitForChild("DoorInteraction"):WaitForChild("DoorPrompt")
local tweenService = game:GetService("TweenService")
local closed = door:GetPivot()
local isOpen, busy = false, false
local closedCollision = {}
for _,part in ipairs(door:GetDescendants()) do
	if part:IsA("BasePart") then closedCollision[part] = part.CanCollide end
end

prompt.Triggered:Connect(function(player)
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if busy or not root or (root.Position - prompt.Parent.Position).Magnitude > 16 then return end
	busy = true
	prompt.Enabled = false
	isOpen = not isOpen
	-- A swinging decorative door must not pin guests against the bookcase.
	for part in pairs(closedCollision) do part.CanCollide = false end
	local pose = Instance.new("CFrameValue")
	pose.Value = door:GetPivot()
	local changed = pose:GetPropertyChangedSignal("Value"):Connect(function()
		door:PivotTo(pose.Value)
	end)
	-- The porch is local +Z: swing outward from the existing left hinge.
	local target = isOpen and closed * CFrame.Angles(0, math.rad(-100), 0) or closed
	local tween = tweenService:Create(pose, TweenInfo.new(.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {Value=target})
	tween:Play()
	tween.Completed:Wait()
	changed:Disconnect()
	pose:Destroy()
	if not isOpen then
		for part,collidable in pairs(closedCollision) do part.CanCollide = collidable end
	end
	door:SetAttribute("Open", isOpen)
	prompt.ActionText = isOpen and "Close" or "Open"
	prompt.Enabled = true
	busy = false
end)
