-- Install as ServerScriptService.BirthdayLobbyServer.
-- One private shared world. Manual entry only; every respawn returns to the lobby.
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local StarterPlayer = game:GetService("StarterPlayer")
local world = workspace:WaitForChild("CozyWorld_Draft01")
local lobby = world:WaitForChild("BirthdayLobby")
local lobbySpawn = lobby:WaitForChild("LobbySpawn")

local destination = world:WaitForChild("MVP"):WaitForChild("Anchors"):WaitForChild("GameplayBedroomArrival")
local promptPart = lobby:WaitForChild("Portal"):WaitForChild("PortalPrompt")
local prompt = promptPart:WaitForChild("EnterWorld")
local center = lobbySpawn.Position + Vector3.new(0,12,-16)
local size = lobby:GetAttribute("RegionSize")
local states = {}
local occupiedSlots = {}

local function allocateSlot(player)
	-- Reserve the lowest free slot once per connection, independent of UserId.
	-- The intended eight-player session occupies slots 0..7 without collisions.
	local slot = 0
	while occupiedSlots[slot] do slot += 1 end
	occupiedSlots[slot] = player
	return slot
end

local function liveCharacter(player)
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if not root or not humanoid or humanoid.Health <= 0 or character:GetAttribute("BirthdayPlacementReady")~=true then return nil end
	return character, root, humanoid
end

local function inLobby(root)
	local offset = root.Position - center
	return math.abs(offset.X) <= size.X/2 and math.abs(offset.Z) <= size.Z/2 and math.abs(offset.Y) <= size.Y/2
end

local function relocate(character, root, humanoid, target)
	local seat = humanoid.SeatPart
	humanoid.Sit = false
	if seat then
		local weld = seat:FindFirstChild("SeatWeld")
		if weld then weld:Destroy() end
	end
	root.AssemblyLinearVelocity = Vector3.zero
	root.AssemblyAngularVelocity = Vector3.zero
	character:PivotTo(target)
end

local function destinationFor(player)
	local slot = states[player].slot
	local slots=world.MVP.Anchors.BedroomArrivalSlots
	local target=slots:FindFirstChild(string.format("Slot%02d",slot % 10 + 1)) or destination
	return target.CFrame + Vector3.new(0,3,0)
end

local function joinWorld(player, fromPad)
	local state = states[player]
	if not state or state.joined or state.moving then return false end
	local character, root, humanoid = liveCharacter(player)
	if not character or not inLobby(root) then return false end
	if fromPad and (root.Position - promptPart.Position).Magnitude > 10 then return false end
	state.moving = true
	-- No yielding between validation and the per-player state transition.
	character:SetAttribute("BirthdayPlacementReady",false)
	relocate(character, root, humanoid, destinationFor(player))
	state.joined = true
	state.deadline = nil
	state.moving = false
	player.RespawnLocation = lobbySpawn
	player:SetAttribute("BirthdayJoinedWorld",true)
	player:SetAttribute("LobbyCountdownEnd",nil)
	character:SetAttribute("BirthdayPlacementReady",true)
	player:SetAttribute("BirthdayLocation","World")
	return true
end

local function onCharacter(player, character)
	local state = states[player]
	if not state then return end
	state.joined = false
	player:SetAttribute("BirthdayJoinedWorld",false)
	state.generation += 1
	local generation = state.generation
	state.deadline=nil
	state.moving=false
	character:SetAttribute("BirthdayPlacementReady",false)
	character:SetAttribute("BirthdayPlacementGeneration",generation)
	player:SetAttribute("BirthdayLocation","Loading")
	player:SetAttribute("LobbyCountdownEnd",nil)
	local root = character:WaitForChild("HumanoidRootPart",15)
	local humanoid = character:WaitForChild("Humanoid",15)
	local function isCurrent()
		return player.Parent==Players and player.Character==character and states[player]==state and state.generation==generation and humanoid and humanoid.Health>0
	end
	if not root or not humanoid or not isCurrent() then return end
	-- CharacterAdded precedes appearance loading, parenting, rig scaling, and
	-- the engine's final spawn move. Wait on lifecycle facts, not a sleep delay.
	local needsAppearance=player.CanLoadCharacterAppearance and not StarterPlayer:FindFirstChild("StarterCharacter")
	while isCurrent() and (not character:IsDescendantOf(workspace) or (needsAppearance and state.appearanceCharacter~=character)) do
		RunService.Heartbeat:Wait()
	end
	if not isCurrent() then return end
	RunService.Heartbeat:Wait()
	if not isCurrent() then return end
	local slot = state.slot
	local start = lobbySpawn.CFrame * CFrame.new((slot % 4 - 1.5)*5,4,(math.floor(slot/4) % 3)*4-2)
	local target=start
	player.RespawnLocation=lobbySpawn
	local function atTarget()
		local offset=root.Position-target.Position
		return Vector2.new(offset.X,offset.Z).Magnitude<2 and math.abs(offset.Y)<6
	end
	local placed=false
	for _=1,3 do
		if not isCurrent() then return end
		relocate(character,root,humanoid,target)
		RunService.Heartbeat:Wait()
		if not isCurrent() then return end
		if atTarget() then
			RunService.Heartbeat:Wait()
			if not isCurrent() then return end
			if atTarget() then placed=true;break end
		end
	end
	if not placed then
		warn("Birthday placement did not settle for "..player.Name.."; character remains Loading")
		return
	end
	character:SetAttribute("BirthdayPlacementReady",true)
	player:SetAttribute("BirthdayJoinedWorld",false)
	player:SetAttribute("LobbyCountdownEnd",nil)
	player:SetAttribute("BirthdayLocation","Lobby")
end

local function onPlayer(player)
	if states[player] then return end
	states[player] = {joined=false,moving=false,generation=0,slot=allocateSlot(player)}
	player:SetAttribute("BirthdaySpawnSlot",states[player].slot)
	player.RespawnLocation = lobbySpawn
	player:SetAttribute("BirthdayJoinedWorld",false)
	player:SetAttribute("BirthdayLocation","Loading")
	player:SetAttribute("LobbyCountdownEnd",nil)
	player.CharacterAppearanceLoaded:Connect(function(character)
		local state=states[player]
		if state and player.Character==character then state.appearanceCharacter=character end
	end)
	player.CharacterAdded:Connect(function(character) onCharacter(player,character) end)
	player.CharacterRemoving:Connect(function(character)
		character:SetAttribute("BirthdayPlacementReady",false)
		local state=states[player]
		if state then state.generation+=1;state.deadline=nil;state.appearanceCharacter=nil end
		player:SetAttribute("LobbyCountdownEnd",nil)
		player:SetAttribute("BirthdayLocation","Loading")
	end)
	if player.Character then
		if player:HasAppearanceLoaded() then states[player].appearanceCharacter=player.Character end
		task.spawn(onCharacter,player,player.Character)
	end
end

prompt.Triggered:Connect(function(player) joinWorld(player,true) end)
Players.PlayerAdded:Connect(onPlayer)
Players.PlayerRemoving:Connect(function(player)
	local state=states[player]
	if state then occupiedSlots[state.slot]=nil end
	states[player]=nil
end)
for _,player in Players:GetPlayers() do onPlayer(player) end
