-- Source-independent correction to the existing saved lobby prompt.
-- No geometry or scripts replaced. Run only in Edit before final binding/save.
assert(not game:GetService("RunService"):IsRunning())
workspace.CozyWorld_Draft01.BirthdayLobby.Portal.PortalPrompt.EnterWorld.ActionText = "Enter Phuong's home"
game:GetService("StarterGui").ScreenOrientation = Enum.ScreenOrientation.LandscapeSensor
return "Lobby prompt spelling and mobile landscape orientation configured"
