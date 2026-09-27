-- Temporary Play-client diagnostic only. Never install in the saved Edit place.
-- Call _G.Polish03Walk(name, Vector3 waypoints); read _G.Polish03WalkResults.
local player = game:GetService("Players").LocalPlayer
assert(player and player.Character, "Requires an active Play client")
_G.Polish03WalkResults = {}
_G.Polish03Walking = false
_G.Polish03Walk = function(name, points)
	assert(not _G.Polish03Walking, "Previous walk still running")
	_G.Polish03Walking = true
	task.spawn(function()
		local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
		local root = player.Character:FindFirstChild("HumanoidRootPart")
		local route = {name=name,walk_speed=humanoid.WalkSpeed,start={root.Position.X,root.Position.Y,root.Position.Z},waypoints={},passed=true}
		table.insert(_G.Polish03WalkResults,route)
		for _, target in points do
			local started=os.clock()
			humanoid:MoveTo(target)
			local distance
			repeat
				task.wait(0.1)
				distance=Vector3.new(root.Position.X-target.X,0,root.Position.Z-target.Z).Magnitude
			until distance<2 or os.clock()-started>7.5
			local grounded=humanoid.FloorMaterial~=Enum.Material.Air
			local heightError=math.abs(root.Position.Y-target.Y)
			local passed=distance<2 and heightError<1.5 and grounded and humanoid.Health>0 and not humanoid.Sit
			table.insert(route.waypoints,{target={target.X,target.Y,target.Z},actual={root.Position.X,root.Position.Y,root.Position.Z},seconds=os.clock()-started,distance=distance,height_error=heightError,grounded=grounded,floor_material=humanoid.FloorMaterial.Name,passed=passed,seated=humanoid.Sit,health=humanoid.Health})
			if not passed then route.passed=false; break end
		end
		_G.Polish03Walking=false
	end)
	return {started=name,waypoints=#points}
end
return {ready=true,method="Actual normal-speed Humanoid.MoveTo; records actual positions; no teleport and no speed changes"}
