-- Install as StarterPlayerScripts.BirthdayLobbyClient.
-- Presentation only: the server supplies location and an absolute deadline.
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local player = Players.LocalPlayer
local gui = Instance.new("ScreenGui")
gui.Name = "BirthdayLobbyHUD"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = false
gui.DisplayOrder = 5
gui.Enabled = false
gui.Parent = player:WaitForChild("PlayerGui")
local card = Instance.new("Frame")
card.Name="CountdownCard";card.AnchorPoint=Vector2.new(.5,0);card.Position=UDim2.new(.5,0,0,12);card.Size=UDim2.new(.9,0,0,100)
card.BackgroundColor3=Color3.fromRGB(245,240,228);card.BackgroundTransparency=.04;card.BorderSizePixel=0;card.Parent=gui
local corner=Instance.new("UICorner");corner.CornerRadius=UDim.new(0,16);corner.Parent=card
local stroke=Instance.new("UIStroke");stroke.Color=Color3.fromRGB(168,185,149);stroke.Thickness=2;stroke.Parent=card
local size=Instance.new("UISizeConstraint");size.MaxSize=Vector2.new(410,100);size.MinSize=Vector2.new(270,100);size.Parent=card
local title=Instance.new("TextLabel");title.Name="CountdownText";title.Position=UDim2.fromOffset(16,9);title.Size=UDim2.new(1,-32,0,30)
title.BackgroundTransparency=1;title.TextColor3=Color3.fromRGB(54,87,68);title.TextSize=22;title.Font=Enum.Font.GothamMedium;title.Parent=card
local hint=Instance.new("TextLabel");hint.Name="EarlyEntryHint";hint.Position=UDim2.fromOffset(16,41);hint.Size=UDim2.new(1,-32,0,35)
hint.BackgroundTransparency=1;hint.Text="Explore, or use the golden pad to enter now.";hint.TextColor3=Color3.fromRGB(38,56,46);hint.TextSize=15;hint.Font=Enum.Font.Gotham;hint.TextWrapped=true;hint.Parent=card
local track=Instance.new("Frame");track.Name="TimeTrack";track.Position=UDim2.new(0,18,1,-14);track.Size=UDim2.new(1,-36,0,5);track.BorderSizePixel=0;track.BackgroundColor3=Color3.fromRGB(168,185,149);track.Parent=card
local fill=Instance.new("Frame");fill.Name="RemainingTime";fill.Size=UDim2.fromScale(1,1);fill.BorderSizePixel=0;fill.BackgroundColor3=Color3.fromRGB(232,199,121);fill.Parent=track
local function layoutCountdown()
	local camera=workspace.CurrentCamera
	local compact=camera and camera.ViewportSize.Y<500
	card.AnchorPoint=Vector2.new(.5,compact and 1 or 0)
	card.Position=compact and UDim2.new(.5,0,1,-14) or UDim2.new(.5,0,0,12)
	card.Size=UDim2.new(compact and .54 or .9,0,0,compact and 70 or 100)
	size.MinSize=compact and Vector2.new(240,70) or Vector2.new(270,100)
	size.MaxSize=compact and Vector2.new(360,70) or Vector2.new(410,100)
	corner.CornerRadius=UDim.new(0,compact and 12 or 16)
	title.Position=UDim2.fromOffset(compact and 10 or 16,compact and 4 or 9)
	title.Size=UDim2.new(1,compact and -20 or -32,0,compact and 24 or 30)
	title.TextSize=compact and 18 or 22
	hint.Position=UDim2.fromOffset(compact and 10 or 16,compact and 29 or 41)
	hint.Size=UDim2.new(1,compact and -20 or -32,0,compact and 22 or 35)
	hint.TextSize=compact and 12 or 15
	track.Position=UDim2.new(0,compact and 12 or 18,1,compact and -8 or -14)
	track.Size=UDim2.new(1,compact and -24 or -36,0,compact and 4 or 5)
end
local viewportConnection
local function watchViewport()
	if viewportConnection then viewportConnection:Disconnect() end
	local camera=workspace.CurrentCamera
	if camera then viewportConnection=camera:GetPropertyChangedSignal("ViewportSize"):Connect(layoutCountdown) end
	layoutCountdown()
end
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(watchViewport)
watchViewport()
local lastSecond
local totalSeconds=60
local world=workspace:WaitForChild("CozyWorld_Draft01")
local lobby=world:WaitForChild("BirthdayLobby")
totalSeconds=math.clamp(lobby:GetAttribute("CountdownSeconds") or 60,1,60)
local center=lobby:GetAttribute("RegionCenter")
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
RunService.Heartbeat:Connect(function()
	local character=player.Character
	local root=character and character:FindFirstChild("HumanoidRootPart")
	local humanoid=character and character:FindFirstChildOfClass("Humanoid")
	local deadline=player:GetAttribute("LobbyCountdownEnd")
	local offset=root and root.Position-center
	local inside=offset and math.abs(offset.X)<=region.X/2 and math.abs(offset.Z)<=region.Z/2 and math.abs(offset.Y)<=region.Y/2
	local visible=player:GetAttribute("BirthdayLocation")=="Lobby" and type(deadline)=="number" and humanoid and humanoid.Health>0 and character:GetAttribute("BirthdayPlacementReady")==true and inside
	gui.Enabled=visible and true or false
	if not visible then lastSecond=nil;return end
	local remaining=math.clamp(deadline-workspace:GetServerTimeNow(),0,totalSeconds)
	local second=math.ceil(remaining)
	if second~=lastSecond then
		lastSecond=second
		title.Text=second>0 and string.format("Your world opens in %ds",second) or "Entering the birthday world..."
	end
	fill.Size=UDim2.fromScale(remaining/totalSeconds,1)
end)
