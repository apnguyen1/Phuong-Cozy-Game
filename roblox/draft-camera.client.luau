-- A north-facing starting view; the normal independently rotatable camera takes over.
local player = game:GetService("Players").LocalPlayer
local function frameArrival(character)
	local root = character:WaitForChild("HumanoidRootPart")
	local humanoid = character:WaitForChild("Humanoid")
	local camera = workspace.CurrentCamera
	camera.CameraType = Enum.CameraType.Custom
	camera.CameraSubject = humanoid
	camera.CFrame = CFrame.lookAt(root.Position + Vector3.new(0, 8, 17), root.Position + Vector3.new(0, 3, -22))
end
player.CharacterAdded:Connect(frameArrival)
if player.Character then frameArrival(player.Character) end
