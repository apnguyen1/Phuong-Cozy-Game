-- Install as StarterPlayerScripts.BirthdayLobbyClient.
-- Presentation only: the server supplies location and an absolute deadline.
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local player = Players.LocalPlayer
local world=workspace:WaitForChild("CozyWorld_Draft01")
local lobby=world:WaitForChild("BirthdayLobby")
local center=lobby:WaitForChild("LobbySpawn").Position+Vector3.new(0,12,-16)
local region=lobby:GetAttribute("RegionSize")
local outdoorLighting
local function restoreOutdoorLighting()
	if not outdoorLighting then return end
	for property,value in outdoorLighting do Lighting[property]=value end
	outdoorLighting=nil
end
local function updateRoomLighting()
	local location=player:GetAttribute("BirthdayLocation")
	if location=="World" then restoreOutdoorLighting();return end
	if location~="Lobby" or outdoorLighting then return end
	outdoorLighting={}
	for _,property in {"Brightness","Ambient","OutdoorAmbient","EnvironmentDiffuseScale","EnvironmentSpecularScale"} do
		outdoorLighting[property]=Lighting[property]
	end
	-- Per-client room lighting prevents the outdoor sun/sky splitting the room
	-- into blue and gold halves. Other players outside retain their world lighting.
	Lighting.Brightness=0
	Lighting.Ambient=Color3.fromRGB(118,110,100)
	Lighting.OutdoorAmbient=Color3.fromRGB(118,110,100)
	Lighting.EnvironmentDiffuseScale=0
	Lighting.EnvironmentSpecularScale=0
end
player:GetAttributeChangedSignal("BirthdayLocation"):Connect(updateRoomLighting)
script.Destroying:Connect(restoreOutdoorLighting)
updateRoomLighting()
local function frameArrival()
	local location=player:GetAttribute("BirthdayLocation")
	if location~="Lobby" and location~="World" then return end
	local character=player.Character
	if not character then return end
	task.spawn(function()
		local root=character:WaitForChild("HumanoidRootPart",10)
		local humanoid=character:WaitForChild("Humanoid",10)
		if not root or not humanoid then return end
		-- Wait for the server relocation to replicate before choosing the starting view.
		for _=1,30 do
			if player.Character~=character or player:GetAttribute("BirthdayLocation")~=location then return end
			local nearRoom=math.abs(root.Position.X-center.X)<region.X/2
			if character:GetAttribute("BirthdayPlacementReady")==true and ((location=="Lobby" and nearRoom) or (location=="World" and not nearRoom)) then break end
			RunService.Heartbeat:Wait()
		end
		RunService.RenderStepped:Wait()
		if player.Character~=character or player:GetAttribute("BirthdayLocation")~=location or character:GetAttribute("BirthdayPlacementReady")~=true then return end
		local camera=workspace.CurrentCamera
		camera.CameraType=Enum.CameraType.Custom
		camera.CameraSubject=humanoid
		if location=="Lobby" then
			camera.CFrame=CFrame.lookAt(root.Position+Vector3.new(0,7,8),Vector3.new(center.X,10,center.Z-30))
		else
			camera.CFrame=CFrame.lookAt(root.Position+Vector3.new(0,7,14),root.Position+Vector3.new(0,3,-16))
		end
	end)
end
player:GetAttributeChangedSignal("BirthdayLocation"):Connect(frameArrival)
frameArrival()
