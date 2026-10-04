-- Apply in Studio Edit mode after updating the Main and QueueService sources.
local root=workspace.CozyWorld_Draft01
local portal=root.BirthdayLobby.Portal
local old=root.MVP.Stations:FindFirstChild("LobbyQueue")
if old then old:ClearAllChildren() end
local pad=portal.TeleportPad
local anchor=root.MVP.Anchors:FindFirstChild("BirthdayLobbyQueue",true)
if anchor then anchor.CFrame=CFrame.new(pad.Position) end
local oldGui=pad:FindFirstChild("BoardingCountdown")
if oldGui then oldGui:Destroy() end
for _,v in portal.PortalInstructions:GetDescendants() do if v:IsA("TextLabel") then v.Text="Enter Phuong’s home whenever you’re ready\nPress E at the circle • tap on mobile" end end
local prompt=portal.PortalPrompt.EnterWorld
prompt.Enabled=true; prompt.ActionText="Enter Phuong’s home"; prompt.ObjectText="Birthday world"; prompt.HoldDuration=0; prompt.KeyboardKeyCode=Enum.KeyCode.E
return "Boarding circle installed; obsolete square removed"
