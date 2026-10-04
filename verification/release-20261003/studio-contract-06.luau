_G.__PCW25ContractText..=[==[essionId = snapshot.sessionId end
	if snapshot.cake then cakeState = snapshot.cake end
	local count = Guidance.PetalCount(lastSnapshot.petals)
	if count > oldCount then
		showToast(count == 6 and "All six petals are complete! Everyone head to the birthday table." or string.format("Another petal! %d of 6 complete together.", count))
		if count == 6 then explicitTrack = "Cake"; trackedWasComplete = false end
	end
	refreshHud()
	layout()
end

action.OnClientEvent:Connect(function(payload)
	if type(payload) ~= "table" then return end
	if type(payload.sessionId) == "string" and payload.sessionId ~= "" then sessionId = payload.sessionId end
	local expected = pending
	local matched = expected ~= nil and payload.actionId == expected.id
	if matched then pending = nil end
	if payload.snapshot then mergeSnapshot(payload.snapshot) end
	if payload.cake then cakeState = payload.cake end
	if inWorld() then
		local currentResponse = matched and expected.epoch == epoch
		local unsolicitedActiveView = payload.actionId == nil and panelMode == "activity" and currentView and payload.view and payload.view.activityId == currentView.activityId
		if payload.view and ((currentResponse and (expected.kind == "RequestView" or expected.kind == "ActivityAction")) or unsolicitedActiveView) then
			if currentResponse then
				selectedAction, confirmation = nil, nil
				if expected.payloadAction == "reserve" or expected.payloadAction == "place" or expected.payloadAction == "cancel" then activeGroup = nil end
			end
			if Guidance.Activities[payload.view.activityId] then
				renderActivity(payload.view, unsolicitedActiveView or expected and expected.kind == "ActivityAction")
			else
				closeActivity()
				showToast("This activity is not ready. Try another petal or ask a host for help.", true)
			end
		elseif currentResponse and expected.kind == "RequestView" then
			closeActivity()
			if payload.ok ~= false then showToast("The activity did not send its choices. Please reopen it.", true) end
		end
		if currentResponse and expected.kind == "ActivityAction" and not payload.view and currentView then renderActivity(currentView, true) end
		if panelMode == "journal" and payload.snapshot then renderJournal(lastSnapshot, true) end
		if payload.journal and currentResponse and panelMode == "journal" then renderJournal(payload.journal) end
		if panelMode == "cake" and (payload.cake or payload.snapshot and payload.snapshot.cake) then renderCake(cakeState, true) end
		if payload.kind == "Result" and currentResponse then
			if payload.ok == false then showToast(Guidance.FriendlyError(payload.code, payload.errorText), true)
			elseif expected.kind == "ActivityAction" then showToast("Your choice is saved for the group.") end
		end
	end
	if matched and panelMode == "extension" then extensionContext().refresh() end
	Extensions.Notify(payload, extensionContext())
end)

journalButton.Activated:Connect(function()
	closeActivity()
	renderJournal(lastSnapshot)
	send({ kind = "RequestJournal" })
end)
hostButton.Activated:Connect(function()
	extensionContext().openPanel("HostControls")
	send({ kind = "RequestSnapshot" })
end)
trackButton.Activated:Connect(function()
	track(explicitTrack or recommended)
	local info = Guidance.Activities[explicitTrack or recommended]
	if info then showToast(info.destination .. " · follow the marker.") end
end)
close.Activated:Connect(closeActivity)
back.Activated:Connect(function()
	if confirmation then confirmation = nil; renderActivity(currentView)
	elseif panelMode == "journal" then closeActivity()
	else closeActivity(); renderJournal(lastSnapshot) end
end)

local bound = setmetatable({}, { __mode = "k" })
local function bind(prompt)
	if not prompt:IsA("ProximityPrompt") or bound[prompt] then return end
	local id = prompt:GetAttribute("ActivityId") or (prompt.Parent and prompt.Parent:GetAttribute("ActivityId"))
	if not Guidance.Activities[id] then return end
	bound[prompt] = true
	prompt.Triggered:Connect(function(who)
		if who and who ~= player then return end
		if not inWorld() then return end
		if id == "Cake" then closeActivity(); renderCake(cakeState); send({ kind = "RequestSnapshot" })
		else requestView(id) end
	end)
end
for _, instance in ipairs(workspace:GetDescendants()) do bind(instance) end
workspace.DescendantAdded:Connect(bind)

UserInputService.InputBegan:Connect(function(input, processed)
	if processed then return end
	if input.KeyCode == Enum.KeyCode.Escape and panel.Visible then closeActivity(); return end
	if input.KeyCode == Enum.KeyCode.J and inWorld() then
		if panelMode == "journal" then closeActivity() else closeActivity(); renderJournal(lastSnapshot) end
		return
	end
	if not currentView or not panel.Visible or confirmation or pending then return end
	local directionValue = input.KeyCode == Enum.KeyCode.Q and -1 or input.KeyCode == Enum.KeyCode.E and 1
	if not directionValue then return end
	for _, descriptor in ipairs(currentView.availableActions or {}) do
		local payload = descriptor.payload or {}
		if descriptor.enabled ~= false and payload.action == "rotate" and payload.direction == directionValue then runDescriptor(currentView, descriptor); break end
	end
end)

local function locationChanged()
	if not inWorld() then
		closeActivity()
		explicitTrack, recommended = nil, nil
		navigator:Clear()
		toast.Visible = false
	else refreshHud() end
	Extensions.Notify({ kind = "LocationChanged", inWorld = inWorld() }, extensionContext())
end
player:GetAttributeChangedSignal("BirthdayLocation"):Connect(locationChanged)
player.CharacterRemoving:Connect(function()
	navigator.suspended = true
	closeActivity()
	explicitTrack = nil
	navigator:Clear()
	Extensions.Notify({ kind = "CharacterRemoving" }, extensionContext())
end)
player.CharacterAdded:Connect(function(character)
	task.spawn(function()
		character:WaitForChild("HumanoidRootPart", 10)
		if player.Character == character then navigator.suspended = false; refreshHud() end
	end)
end)

-- Optional modules under client.extensions export Init(getContext, Extensions).
-- getContext() returns fresh state; registered renderers/observers also receive it.
local loaded = setmetatable({}, { __mode = "k" })
local function loadExtension(module)
	if not module:IsA("ModuleScript") or loaded[module] then return end
	loaded[module] = true
	local ok, result = pcall(require, module)
	if ok and type(result) == "table" and type(result.Init) == "function" then
		local initOk, err = pcall(result.Init, extensionContext, Extensions)
		if not initOk then warn("Birthday extension initialization failed", module.Name, err) end
	elseif not ok then warn("Birthday extension load failed", module.Name, result) end
end
local function loadExtensionFolder(folder)
	if folder.Name ~= "extensions" then return end
	local modules = folder:GetChildren()
	table.sort(modules, function(a, b) return a.Name < b.Name end)
	for _, module in ipairs(modules) do loadExtension(module) end
	folder.ChildAdded:Connect(loadExtension)
end
local extensionFolder = client:FindFirstChild("extensions")
if extensionFolder then loadExtensionFolder(extensionFolder) end
client.ChildAdded:Connect(loadExtensionFolder)

RunService.Heartbeat:Connect(function(delta)
	heartbeatElapsed += delta
	if heartbeatElapsed < .25 then return end
	heartbeatElapsed = 0
	if inWorld() then refreshHud() else navigator:Clear() end
end)
layout()
locationChanged()
action:FireServer({ kind = "RequestSnapshot", actionId = freshId() })
]=],
["roblox/mvp/client/Navigator.luau"] = [=[local UI = require(script.Parent.UI)
local Guidance = require(script.Parent.Parent.shared.Guidance)
local Navigator = {}
Navigator.__index = Navigator

function Navigator.new(player, gui)
	local self = setmetatable({ player = player, gui = gui, cache = {} }, Navigator)
	return self
end

function Navigator:Resolve(name)
	local cached = self.cache[name]
	if cached and cached:IsDescendantOf(workspace) then return cached end
	local world = workspace:FindFirstChild("CozyWorld_Draft01")
	local mvp = world and world:FindFirstChild("MVP")
	local found = mvp and mvp:FindFirstChild(name, true)
	if found and found:GetAttribute("PlacementStatus") ~= "UNRESOLVED_LIVE_ANCHOR" then
		local part = found:IsA("BasePart") and found or found:FindFirstChildWhichIsA("BasePart", true)
		self.cache[name] = part
		return part
	end
	return nil
end

function Navigator:Root()
	local character = self.player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if not humanoid or humanoid.Health <= 0 then return nil end
	return character:FindFirstChild("HumanoidRootPart")
end

function Navigator:Nearest(id, view)
	local root = self:Root()
	local best, distance = nil, math.huge
	for _, name in ipairs(Guidance.AnchorNames(id, view)) do
		local anchor = self:Resolve(name)
		if anchor then
			local d = root and (anchor.Position - root.Position).Magnitude or 0
			if d < distance then best, distance = anchor, d end
		end
	end
	return best, distance
end

function Navigator:Distances(views)
	local distances = {}
	for _, id in ipairs(Guidance.Order) do
		local _, distance = self:Nearest(id, views[id])
		distances[id] = distance
	end
	return distances
end

function Navigator:Clear()
	if self.billboard then self.billboard:Destroy(); self.billboard = nil end
	if self.highlight then self.highlight:Destroy(); self.highlight = nil end
	self.anchor, self.activityId = nil, nil
end

function Navigator:SetTarget(id, view)
	if self.suspended or self.player:GetAttribute("BirthdayLocation") ~= "World" or not self:Root() then self:Clear(); return end
	local anchor = self:Nearest(id, view)
	if not anchor then self:Clear(); return end
	if self.anchor == anchor and self.activityId == id then return end
	self:Clear()
	self.anchor, self.activityId = anchor, id
	local billboard = Instance.new("BillboardGui")
	billboard.Name = "BirthdayDestinationMarker"
	billboard.Adornee = anchor
	billboard.AlwaysOnTop = true
	billboard.Size = UDim2.fromOffset(218, 68)
	billboard.StudsOffsetWorldSpace = Vector3.new(0, 5, 0)
	billboard.MaxDistance = 900
	billboard.Active = false
	billboard.Parent = self.gui
	local background = Instance.new("Frame")
	background.Size = UDim2.fromScale(1, 1)
	background.BackgroundColor3 = UI.Palette.cream
	background.BorderSizePixel = 0
	background.Parent = billboard
	UI.Corner(background)
	UI.Padding(background, 8)
	local label = UI.Label(background, "Destination", "", 15, UI.Palette.forest)
	label.Size = UDim2.fromScale(1, 1)
	label.AutomaticSize = Enum.AutomaticSize.None
	label.TextXAlignment = Enum.TextXAlignment.Center
	label.TextYAlignment = Enum.TextYAlignment.Center
	self.billboard, self.label = billboard, label
	local highlight = Instance.new("Highlight")
	highlight.Name = "BirthdayDestinationOutline"
	highlight.Adornee = anchor
	highlight.FillTransparency = 1
	highlight.OutlineColor = UI.Palette.golden
	highlight.OutlineTransparency = 0
	highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	highlight.Parent = self.gui
	self.highlight = highlight
end

function Navigator:Update()
	local root, anchor = self:Root(), self.anchor
	if self.suspended or not root or not anchor or not anchor:IsDescendantOf(workspace) or self.player:GetAttribute("BirthdayLocation") ~= "World" then
		self:Clear()
		return ""
	end
	local info = Guidance.Activities[self.activityId]
	local distance = math.floor((root.Position - anchor.Position).Magnitude + .5)
	local camera = workspace.CurrentCamera
	local hint = "Walk toward the marker"
	if distance <= 12 then
		hint = "You're here · use the nearby prompt"
	elseif camera then
		local _, onScreen = camera:WorldToViewportPoint(anchor.Position + Vector3.new(0, 5, 0))
		local relative = camera.CFrame:PointToObjectSpace(anchor.Position)
		if relative.Z > 0 then hint = "↶ Turn around"
		elseif not onScreen then hint = relative.X > 0 and "→ Turn right" or "← Turn left"
		else hint = "↑ Follow the marker" end
	end
	self.label.Text = "◆ " .. info.short .. "\n" .. tostring(distance) .. " studs"
	return hint .. " · " .. tostring(distance) .. " studs"
end

return Navigator
]=],
["roblox/mvp/client/UI.luau"] = [=[-- Shared primitives. All authored colors are exact approved palette tokens.
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
]=],
["roblox/mvp/environment-detail04.luau"] = [=[-- Edit-only ground and green-tree detail pass. Cherry assets and gameplay are preserved.
local RunService = game:GetService("RunService")
assert(not RunService:IsRunning(), "Environment details require Edit mode")
local root = assert(workspace:FindFirstChild("CozyWorld_Draft01"))
local V, CF = Vector3.new, CFrame.new
local palette = {
    forest=Color3.fromHex("365744"), sage=Color3.fromHex("A8B995"),
    cream=Color3.fromHex("F5F0E4"), wood=Color3.fromHex("95674B"),
    blossom=Color3.fromHex("E8B7C6"), brick=Color3.fromHex("B66C68"),
    golden=Color3.fromHex("E8C779"), ink=Color3.fromHex("26382E"),
}
local stage = Instance.new("Folder")
stage.Name = "EnvironmentDetail04"
stage:SetAttribute("SourceBuilder", "roblox/mvp/environment-detail04.luau")
stage:SetAttribute("VerificationTicket", "MAP-03")
stage:SetAttribute("TexturePolicy", "Native materials only; original cherry textures untouched")
local count = 0
local function part(name, size, cf, token, parent, material)
    local p=Instance.new("Part");p.Name=name;p.Size=size;p.CFrame=cf
    p.Color=palette[token];p:SetAttribute("PaletteToken",token)
    p.Material=material or Enum.Material.SmoothPlastic;p.Anchored=true
    p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.CastShadow=false
    p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth
    p.Parent=parent;count+=1;return p
end
local function ball(name,size,cf,token,parent,material)
    local p=part(name,size,cf,token,parent,material)
    local mesh=Instance.new("SpecialMesh");mesh.MeshType=Enum.MeshType.Sphere;mesh.Parent=p
    return p
end
local ground=Instance.new("Folder");ground.Name="GroundDetails";ground.Parent=stage
local foliage=Instance.new("Folder");foliage.Name="GreenTreeDetails";foliage.Parent=stage
local n=root.SurroundingContext.NeighborhoodDetails02
local field=root.Landscape.QuadGround
local fieldY=field.Position.Y+field.Size.Y/2
local road=root.SurroundingContext.UDistrictStreet
local sidewalk=root.SurroundingContext.ShopSidewalk
local sidewalkTop=sidewalk.Position.Y+sidewalk.Size.Y/2
-- Flush sidewalk seams, a curb edge, and small recessed drain grilles.
for i=0,24 do
    local z=sidewalk.Position.Z-sidewalk.Size.Z/2+6+i*12
    part("SidewalkJoint_"..i,V(sidewalk.Size.X,.025,.055),CF(sidewalk.Position.X,sidewalkTop+.015,z),"sage",ground,Enum.Material.Concrete)
end
part("StreetCurb",V(.35,.20,sidewalk.Size.Z),CF(sidewalk.Position.X+sidewalk.Size.X/2,sidewalkTop+.025,sidewalk.Position.Z),"cream",ground,Enum.Material.Concrete)
for i=1,6 do
    local z=road.Position.Z-road.Size.Z/2+20+i*40
    local x=road.Position.X-road.Size.X/2+1.6
    local y=road.Position.Y+road.Size.Y/2+.015
    part("DrainFrame_"..i,V(1.4,.04,2.5),CF(x,y,z),"ink",ground,Enum.Material.Metal)
    for j=1,5 do part("DrainSlat_"..i.."_"..j,V(1.18,.035,.12),CF(x,y+.025,z-1+j*.34),"sage",ground,Enum.Material.Metal) end
end
-- The world has moved since these route attributes were authored. Resolve their
-- translation from the current home anchor instead of moving existing geometry.
local authoredOffset=root.Paths:GetAttribute("WorldOffset")
assert(typeof(authoredOffset)=="Vector3","Route offset provenance required")
local routeDelta=(root.Home.Floor.Position-V(-28,.12,-108))-authoredOffset
local routes={}
for _,definition in root.Paths.RouteDefinitions:GetChildren() do
    local a,b=definition:GetAttribute("From"),definition:GetAttribute("To")
    assert(typeof(a)=="Vector3" and typeof(b)=="Vector3","Measured route required")
    table.insert(routes,{name=definition.Name,a=a+routeDelta,b=b+routeDelta,width=definition:GetAttribute("Width")})
end
local function nearOtherRoute(point,current)
    local p=Vector2.new(point.X,point.Z)
    for _,route in routes do if route~=current then
        local a,b=Vector2.new(route.a.X,route.a.Z),Vector2.new(route.b.X,route.b.Z)
        local d=b-a;local t=math.clamp((p-a):Dot(d)/d:Dot(d),0,1)
        if (p-a-d*t).Magnitude<route.width/2+1 then return true end
    end end
    return false
end
local walk=root.Paths.BrickWalkNetwork
local pavingY=walk.Position.Y+walk.Size.Y/2+.014
for _,route in routes do
    local length=(route.b-route.a).Magnitude
    local direction=(route.b-route.a).Unit
    for distance=4,length-3,6 do
        local position=route.a+direction*distance
        if not nearOtherRoute(position,route) then
            local cf=CFrame.lookAt(V(position.X,pavingY,position.Z),V(route.b.X,pavingY,route.b.Z))
            part("PavingCourse_"..route.name.."_"..math.floor(distance),V(route.width-.50,.025,.06),cf,"wood",ground,Enum.Material.Concrete)
        end
    end
end
-- Native grass and bark supply real surface texture, with explicit leaf silhouettes.
local changedMaterials={}
for _,tree in n.PerimeterGardens:GetChildren() do
    if tree:IsA("Model") and tree.Name:match("^LayeredTree%d+$") then
        local index=tonumber(tree.Name:match("%d+"))
        local details=Instance.new("Model");details.Name=tree.Name;details.Parent=foliage
        local trunk=assert(tree:FindFirstChild("TreeTrunk"))
        local center=V(trunk.Position.X,fieldY,trunk.Position.Z)
        local mulch=part("MulchBed",V(.07,6.6,6.6),CF(center+V(0,.045,0))*CFrame.Angles(0,0,math.pi/2),"wood",details,Enum.Material.Ground)
        mulch.Shape=Enum.PartType.Cylinder
        -- No change to existing trunk/crown footprint, placement, or collision.
        for _,p in tree:GetChildren() do
            if p:IsA("BasePart") and (p.Name:match("LeafCrown") or p.Name=="TopCrown" or p.Name:match("UnderstoryShrub")) then
                table.insert(changedMaterials,{part=p,material=p.Material})
                p.Material=Enum.Material.Grass
                for j=1,(p.Name:match("Understory") and 2 or 3) do
                    local angle=j*2.09+index*.43
                    local offset=V(math.cos(angle)*p.Size.X*.33,p.Size.Y*.23,math.sin(angle)*p.Size.Z*.32)
                    ball(p.Name.."_LeafCluster"..j,V(3.2,2.0,2.6),CF(p.Position+offset)*CFrame.Angles(.12*j,angle,.15),
                        (j+index)%3==0 and "sage" or "forest",details,Enum.Material.Grass)
                end
            end
        end
        -- Six narrow bark ridges provide trunk relief visible near the tree.
        local height=trunk.Size.X
        for j=1,6 do
            local angle=j*math.pi/3+index*.2
            part("BarkRidge_"..j,V(.10,height*.68,.16),CF(center+V(math.cos(angle)*.84,height*.40,math.sin(angle)*.84))*CFrame.Angles(0,-angle,0),
                j%3==0 and "ink" or "wood",details,Enum.Material.Wood)
        end
        -- Low native leaf litter stays within existing tree beds.
        for j=1,4 do
            local angle=j*1.73+index
            ball("FallenLeaf_"..j,V(.48,.045,.24),CF(center+V(math.cos(angle)*2.8,.09,math.sin(angle)*2.8))*CFrame.Angles(0,angle,0),
                j%2==0 and "sage" or "golden",ground,Enum.Material.Grass)
        end
    end
end
-- Grass tufts on the outer verges, clear of shops, park gates, arrival and paths.
local bounds=root.MVP.Environment.SeattleBoundary
local minX,maxX=bounds:GetAttribute("EnclosureMinX"),bounds:GetAttribute("EnclosureMaxX")
local minZ,maxZ=bounds:GetAttribute("EnclosureMinZ"),bounds:GetAttribute("EnclosureMaxZ")
assert(minX and maxX and minZ and maxZ,"Install the enclosed boundary first")
for side=1,2 do for i=1,20 do
    local x=side==1 and minX+7 or maxX-7
    local z=minZ+18+i*(maxZ-minZ-40)/21
    for j=1,3 do
        ball("VergeTuft_"..side.."_"..i.."_"..j,V(.20,.38+j*.12,.60),CF(x+(j-2)*.28,fieldY+.22,z)*CFrame.Angles(0,j*.9+i,.22),j==2 and "sage" or "forest",ground,Enum.Material.Grass)
    end
end end
assert(count<=1100,"Environment detail exceeds its 1100-part budget")
stage:SetAttribute("PartCount",count);stage:SetAttribute("ChangedNativeMaterials",#changedMaterials)
local old=root:FindFirstChild(stage.Name)
if old then old:Destroy() end
stage.Parent=root
game:GetService("ChangeHistoryService"):SetWaypoint("Ground and green-tree surface detail 04")
return {parts=count,greenTrees=#foliage:GetChildren(),changedNativeMaterials=#changedMaterials}
]=],
["roblox/mvp/ground-city-boundary.luau"] = [=[-- Edit-mode repair: extend city facades downward, preserving their roof height.
local root=workspace.CozyWorld_Draft01
local field=root.Landscape:WaitForChild("QuadGround")
local groundY=field.Position.Y+field.Size.Y/2
local boundary=root.MVP.Environment:WaitForChild("SeattleBoundary")
local count=0
for _,p in boundary:GetDescendants() do
 if p:IsA("BasePart") and (p.Name:match("^Shell%d+$") or (p.Name=="Body" and p.Parent.Parent.Name=="CompressedSeattleSkyline")) then
  local top=p.Position.Y+p.Size.Y/2
  if p.Position.Y-p.Size.Y/2>groundY then
   local height=top-groundY
   p.Size=Vector3.new(p.Size.X,height,p.Size.Z)
   p.CFrame=p.CFrame+Vector3.new(0,groundY+height/2-p.Position.Y,0)
   count+=1
  end
 end
end
boundary:SetAttribute("GroundedFieldY",groundY)
return {extended=count,fieldY=groundY}
]=],
["roblox/mvp/install.luau"] = [=[-- Edit-mode integrator. Require this module and invoke the returned function with measured inputs.
local REQUIRED_ANCHORS = { "GameplayBedroomArrival", "Q01Bed", "JasperBedroomStart", "JasperFetchYard", "Q03FairCraft", "Q03BedroomDisplay", "Q04QuadReading", "Q05UDistrictVending", "Q06FOBCounter", "Q06AladdinsCounter", "Q06Serving", "FinalePatio", "BirthdayLobbyQueue" }
local STATIONS = { "Q01Station", "Q02Station", "Q03Station", "Q04Station", "Q05Station", "Q06Station", "CakeFinale", "LobbyQueue" }
local ENVIRONMENT = { "SeattleBoundary", "NightLighting", "GrassDecoration" }
local PALETTE = { forest=Color3.fromHex("365744"), sage=Color3.fromHex("A8B995"), cream=Color3.fromHex("F5F0E4"), wood=Color3.fromHex("95674B"), blossom=Color3.fromHex("E8B7C6"), brick=Color3.fromHex("B66C68"), golden=Color3.fromHex("E8C779"), ink=Color3.fromHex("26382E") }

return function(context)
    assert(context and context.Root, "installer requires measured context.Root")
    local root = context.Root
    local mvp = assert(context.MVP or root:FindFirstChild("MVP"), "MVP folder required")
    local anchors = assert(context.Anchors or mvp:FindFirstChild("Anchors"), "resolved measured Anchors required")
    local options = assert(context.Options, "measured Options are required")
    assert(options.OuterQuadBounds and options.Keepouts and options.WorldBounds, "Options require OuterQuadBounds, Keepouts, and WorldBounds provenance")
    local resolvedAnchors, missing = {}, {}
    for _, name in ipairs(REQUIRED_ANCHORS) do
        local anchor = anchors[name] or anchors:FindFirstChild(name, true)
        local status = anchor and anchor:GetAttribute("PlacementStatus")
        if not anchor or not anchor:IsA("BasePart") or type(status) ~= "string" or status == "" or status == "UNRESOLVED_LIVE_ANCHOR" or status == "UNRESOLVED" then table.insert(missing, "Anchor:" .. name) else resolvedAnchors[name] = anchor end
    end
    local builders = assert(context.Builders or script.Parent:FindFirstChild("builders"), "builders folder required")
    local function builder(name) return builders.FindFirstChild and builders:FindFirstChild(name) or builders[name] end
    for _, name in ipairs(STATIONS) do if not builder(name) then table.insert(missing, "Builder:" .. name) end end
    for _, name in ipairs(ENVIRONMENT) do if not builder(name) then table.insert(missing, "Builder:" .. name) end end
    if #missing > 0 then error("MVP preflight failed before scene change: " .. table.concat(missing, ", ")) end
    local stations = mvp:FindFirstChild("Stations") or Instance.new("Folder"); stations.Name = "Stations"
    local environment = mvp:FindFirstChild("Environment") or Instance.new("Folder"); environment.Name = "Environment"
    local selected = {}
    if context.OnlyFeature ~= nil then
        assert(type(context.OnlyFeature) == "string" and context.OnlyFeature ~= "", "OnlyFeature must be a known nonempty string")
        for _, name in ipairs(STATIONS) do if name == context.OnlyFeature then table.insert(selected, {name=name, parent=stations}) end end
        for _, name in ipairs(ENVIRONMENT) do if name == context.OnlyFeature then table.insert(selected, {name=name, parent=environment}) end end
        assert(#selected == 1, "OnlyFeature must select exactly one canonical builder")
    else
        for _, name in ipairs(STATIONS) do table.insert(selected, {name=name, parent=stations}) end
        for _, name in ipairs(ENVIRONMENT) do table.insert(selected, {name=name, parent=environment}) end
    end
    local original, staged, restores = {}, {}, {}
    local function safeReplace(ownedName, ownedParent, name, factory)
        assert(name == ownedName, "SafeReplace name outside caller ownership"); assert(ownedParent == stations or ownedParent == environment, "SafeReplace parent outside MVP ownership")
        local parent = ownedParent
        local made = factory(); assert(made and (made:IsA("Folder") or made:IsA("Model")) and not made.Parent, "factory must return detached Folder/Model")
        local old = parent:FindFirstChild(name); original[name] = { old=old, parent=parent }; if old then old.Parent = nil end
        made.Name = name; made.Parent = parent; staged[name] = made; return made
    end
    local shared = { Root=root, MVP=mvp, Anchors=resolvedAnchors, Palette=PALETTE, RequiredPalette=PALETTE, Options=options, Lighting=context.Lighting or game:GetService("Lighting") }
    function shared:ValidateAnchors(names) for _, name in ipairs(names) do local a = self.Anchors[name]; local s = a and a:GetAttribute("PlacementStatus"); assert(a and a:IsA("BasePart") and type(s)=="string" and s~="" and s~="UNRESOLVED_LIVE_ANCHOR" and s~="UNRESOLVED", "unresolved anchor: " .. name) end return true end
    local ok, result = pcall(function()
        stations.Parent = mvp; environment.Parent = mvp
        local out = {}
        for _, entry in ipairs(selected) do local name, parent = entry.name, entry.parent; local c = table.clone(shared); c.SafeReplace=function(n,f) return safeReplace(name,parent,n,f) end; out[name] = require(builder(name))(c); if out[name].Restore then table.insert(restores,out[name].Restore) end end
        return out
    end)
    if not ok then for i=#restores,1,-1 do pcall(restores[i]) end; for _, item in pairs(staged) do if item then item:Destroy() end end; for _, backup in pairs(original) do if backup.old then backup.old.Parent = backup.parent end end; error("MVP install rolled back owned outputs: " .. tostring(result)) end
    return { folders = result, manifest = { RequiredAnchors=REQUIRED_ANCHORS, Stations=STATIONS, Environment=ENVIRONMENT, Measurements="provided by Task01", PaletteTokens=PALETTE } }
end
]=],
["roblox/mvp/server/activities/Q01.luau"] = [=[-- Server-owned room activity. Only the seven bed steps earn Q01.
local Q01 = {}
Q01.__index = Q01
Q01.ActivityId = "Q01"
Q01.StepIds = { "blanket_left", "blanket_right", "blanket_foot", "pillow_left", "pillow_right", "plush_dog", "plush_dinosaur" }
Q01.StepLabels = {
	blanket_left = "Smooth the left blanket edge", blanket_right = "Smooth the right blanket edge",
	blanket_foot = "Fold the cream quilt", pillow_left = "Place the left pillow", pillow_right = "Place the right pillow",
	plush_dog = "Tuck in the round-bellied dog", plush_dinosaur = "Tuck in the dinosaur plush",
}
local ITEMS = {
	blanket_left = { label = "Left blanket edge", destination = "Left side of the sage bed", verb = "Tuck" },
	blanket_right = { label = "Right blanket edge", destination = "Right side of the sage bed", verb = "Tuck" },
	blanket_foot = { label = "Cream quilt", destination = "Foot of the sage bed", verb = "Fold" },
	pillow_left = { label = "Left cream pillow", destination = "Left pillow spot", verb = "Place" },
	pillow_right = { label = "Right cream pillow", destination = "Right pillow spot", verb = "Place" },
	plush_dog = { label = "Round-bellied dog plush", destination = "Dog's spot beside the pillows", verb = "Tuck" },
	plush_dinosaur = { label = "Dinosaur plush", destination = "Dinosaur's spot beside the pillows", verb = "Tuck" },
}
local SHELF_ITEMS = { { id = "book_sage", label = "Sage book" }, { id = "book_cream", label = "Cream book" }, { id = "small_figure", label = "Small shelf figure" } }
local SHELF_SLOTS = { { id = "left", label = "Top shelf · left" }, { id = "middle", label = "Top shelf · middle" }, { id = "right", label = "Top shelf · right" } }
Q01.ReservationSeconds = 30
local function now(self) return self.clock and self.clock() or os.clock() end
local function find(list, id) for _, item in ipairs(list) do if item.id == id then return item end end end
local function copyMap(source) local result = {}; for k, v in pairs(source) do result[k] = v end; return result end

function Q01.new(context)
	assert(context and context.session, "Q01 requires a shared session")
	return setmetatable({ session = context.session, clock = context.clock, feedback = context.feedback,
		reserved = {}, reservationByActor = {}, visibleState = {}, currentRoundId = nil, finishedPreview = nil,
		finalChoices = { soft_snug = "Soft and snug", neat_layered = "Neatly layered" },
		shelfSlots = {}, shelfHolds = {}, shelfItemHolds = {}, shelfSlotHolds = {}, actions = {}, expiryRevision = 0,
	}, Q01)
end
Q01.New = Q01.new
function Q01:_round() return self.currentRoundId and self.session.rounds[self.currentRoundId] or nil end
function Q01:_active(roundId)
	local round = self:_round()
	return roundId == self.currentRoundId and round and round.state == "IN_PROGRESS" and round or nil
end
function Q01:_host(actor)
	return actor == self.session.phuongUserId or (self.session.hostUserId ~= 0 and actor == self.session.hostUserId)
end
function Q01:_releaseBed(actor)
	local hold = self.reservationByActor[actor]
	if hold then self.reserved[hold.stepId] = nil; self.reservationByActor[actor] = nil end
end
function Q01:_releaseShelf(actor)
	local hold = self.shelfHolds[actor]
	if hold then
		self.shelfItemHolds[hold.itemId] = nil
		if hold.slotId then self.shelfSlotHolds[hold.slotId] = nil end
		self.shelfHolds[actor] = nil
	end
end
function Q01:ReleaseActor(actor, roundId)
	-- A delayed close from an older round must not release a new-round choice.
	if roundId and roundId ~= self.currentRoundId then return end
	self:_releaseBed(actor); self:_releaseShelf(actor)
end
function Q01:ExpireReservations(at)
	local timestamp, changed = at or now(self), false
	for actor, hold in pairs(self.reservationByActor) do
		if hold.expiresAt <= timestamp then self:_releaseBed(actor); changed = true end
	end
	for actor, hold in pairs(self.shelfHolds) do
		if hold.expiresAt <= timestamp then self:_releaseShelf(actor); changed = true end
	end
	if changed then self.expiryRevision += 1 end
	return changed
end
function Q01:CreateRound(request)
	assert(not self:_round() or self:_round().state ~= "IN_PROGRESS", "Q01 round already active")
	assert(not self:_round() or request.replay == true or request.isReplay == true, "explicit replay required")
	self.session:CreateRound(self.ActivityId, request.roundId, request.actorUserId)
	self.currentRoundId = request.roundId
	self.reserved, self.reservationByActor, self.visibleState = {}, {}, {}
	self.shelfHolds, self.shelfItemHolds, self.shelfSlotHolds = {}, {}, {}
	self.finishedPreview = nil
	-- Committed shelf layout intentionally persists across bed replays.
	if self.feedback then
		local ok,err=pcall(self.feedback.BeginRound,self.feedback,request.roundId)
		if not ok then warn("Bedroom round presentation needs attention",err) end
	end
	return self:GetView(request.actorUserId)
end
Q01.Start = Q01.CreateRound

function Q01:_bed(request, action)
	local actor, stepId = request.actorUserId, request.stepId
	local round = self:_active(request.roundId)
	if not round then return false, "ROUND_CHANGED", "This bed round changed. Reopen it to see the current tasks." end
	if not ITEMS[stepId] then return false, "INVALID_STEP", "Choose one of the bed task cards." end
	if action == "cancel" then self:_releaseBed(actor); return true, "CANCELLED" end
	if round.steps[stepId] then return false, "ALREADY_DONE", "That spot is already tidy. Choose another bed task." end
	local held = self.reserved[stepId]
	if action == "reserve" then
		if held and held.actorUserId ~= actor then return false, "IN_USE", "A friend is using that spot. Choose another task or try again shortly." end
		self:_releaseBed(actor); self:_releaseShelf(actor)
		local hold = { actorUserId = actor, stepId = stepId, expiresAt = now(self) + self.ReservationSeconds }
		self.reserved[stepId], self.reservationByActor[actor] = hold, hold
		retu]==]
return #_G.__PCW25ContractText