_G.__PCW25ContractText..=[==[ors.Q03BedroomDisplay, "Q03BedroomDisplay anchor required")
    assert(boothAnchor:GetAttribute("PlacementStatus") ~= "UNRESOLVED_LIVE_ANCHOR", "Q03FairCraft anchor unresolved")
    assert(homeAnchor:GetAttribute("PlacementStatus") ~= "UNRESOLVED_LIVE_ANCHOR", "Q03BedroomDisplay anchor unresolved")
    local palette = assert(context.Palette, "Q03Station palette required")
    for _, token in ipairs({"forest", "sage", "cream", "wood", "blossom", "golden", "ink"}) do assert(palette[token], "missing palette token: " .. token) end
    local manifest = {AnchorName="Q03FairCraft;Q03BedroomDisplay", Footprint="14x10 proposed; measured anchors required", ApproachClearance="3 front; 2 side proposed", Owner="Task04", SourceBuilder="roblox/mvp/builders/Q03Station.luau"}
    local function factory()
        local folder = Instance.new("Folder"); folder.Name = "Q03"; folder:SetAttribute("VerificationTicket", "PCW-09"); folder:SetAttribute("MVPBuilder", "Q03Station"); folder:SetAttribute("Owner", "Task04")
        local function part(name,size,cf,token,parent,collide)
            local p=Instance.new("Part"); p.Name=name; p.Size=size; p.CFrame=cf; p.Color=palette[token]; p.Anchored=true; p.CanCollide=collide==true
            for key,value in pairs({VerificationTicket="PCW-09",PaletteToken=token,MVPBuilder="Q03Station",AnchorName=manifest.AnchorName,Footprint=manifest.Footprint,ApproachClearance=manifest.ApproachClearance,Owner=manifest.Owner,SourceBuilder=manifest.SourceBuilder}) do p:SetAttribute(key,value) end
            p.Parent=parent; return p
        end
        local function piece(name,size,cf,token) local m=Instance.new("Model"); m.Name=name; m.Parent=folder; part("Body",size,cf,token,m,false); return m end
        local b,h=boothAnchor.CFrame,homeAnchor.CFrame
        part("CraftTable",Vector3.new(8,2,4),b*CFrame.new(0,1,0),"wood",folder,true)
        for i=1,6 do local x=((i-1)%3-1)*2.2; local z=(math.floor((i-1)/3)-.5)*1.5; part("Socket_"..i,Vector3.new(1.4,.08,1.1),b*CFrame.new(x,2.05,z),"golden",folder,false) end
        piece("Rug",Vector3.new(2.4,.08,1.8),b*CFrame.new(-2.2,2.12,-.75),"sage"); piece("Chair",Vector3.new(1.2,1.4,1.2),b*CFrame.new(0,2.8,-.75),"sage"); piece("Bookcase",Vector3.new(1.1,1.8,.45),b*CFrame.new(2.2,2.9,-.75),"wood"); piece("SideTable",Vector3.new(1,.8,1),b*CFrame.new(-2.2,2.55,.75),"wood"); piece("Plant",Vector3.new(.7,1.2,.7),b*CFrame.new(0,2.7,.75),"forest"); piece("Lamp",Vector3.new(.6,1.4,.6),b*CFrame.new(2.2,2.8,.75),"golden")
        local home=Instance.new("Model"); home.Name="HomeDisplay"; home.Parent=folder; part("DisplayBase",Vector3.new(7,.3,5),h*CFrame.new(0,.2,0),"wood",home,false); home:SetAttribute("SharedState","Q03 server miniature; booth and desk are one state"); home:SetAttribute("NoDuplicateReward",true)
        return folder
    end
    local installed=context.SafeReplace("Q03Station",factory)
    return {folder=installed,manifest=manifest}
end
]=],
["roblox/mvp/builders/Q04Station.luau"] = [=[return function(context)
    assert(context and context.Root and context.MVP and context.Anchors and context.Palette, "Q04 station context is required")
    assert(context.SafeReplace, "Q04Station requires SafeReplace")
    local function getAnchor(name)
        local anchor = context.Anchors[name]
        if not anchor then
            local markerRoot = context.MVP:FindFirstChild("Anchors")
            anchor = markerRoot and markerRoot:FindFirstChild(name, true) or nil
        end
        return anchor
    end
    local required = { "Q04QuadReading", "Q04BedroomKindle" }
    for _, name in ipairs(required) do
        local anchor = getAnchor(name)
        assert(anchor, "Required Q04 anchor missing: " .. name)
        local status = anchor:GetAttribute("PlacementStatus")
        assert(anchor:IsA("BasePart"), "Q04 anchor must be a BasePart: " .. name)
        assert(type(status) == "string" and status ~= "" and status ~= "UNRESOLVED" and status ~= "UNRESOLVED_LIVE_ANCHOR", "Q04 anchor unresolved: " .. name)
    end
    for _, token in ipairs({ "forest", "sage", "cream", "wood", "blossom", "brick", "golden", "ink" }) do
        assert(context.Palette[token], "Required palette token missing: " .. token)
    end
    local function factory()
        local folder = Instance.new("Folder")
        folder.Name = "Q04"
        folder:SetAttribute("VerificationTicket", "PCW-10")
        folder:SetAttribute("MVPBuilder", "Q04Station")
        local function prop(name, anchorName, token, offset, footprint, clearance)
            local part = Instance.new("Part")
            part.Name = name
            part.Size = Vector3.new(.8, .18, .55)
            part.CFrame = getAnchor(anchorName).CFrame * CFrame.new(offset)
            part.Color = context.Palette[token]
            part.Anchored = true
            part.CanCollide = false
            part.CanTouch = false
            part.CanQuery = false
            for key, value in { VerificationTicket = "PCW-10", PaletteToken = token, MVPBuilder = "Q04Station", AnchorName = anchorName, Footprint = footprint, ApproachClearance = clearance, Owner = "Task05", SourceBuilder = "roblox/mvp/builders/Q04Station.luau" } do
                part:SetAttribute(key, value)
            end
            part.Parent = folder
        end
        prop("QuadReadingBook", "Q04QuadReading", "wood", Vector3.new(0, 1.15, 0), "Existing bench only", "Measured by Task01")
        prop("QuadReadingPrompt", "Q04QuadReading", "golden", Vector3.new(0, 1.45, 0), "Existing bench only", "Measured by Task01")
        prop("BedroomKindlePrompt", "Q04BedroomKindle", "forest", Vector3.new(0, .25, 0), "Existing desk/display only", "Measured by Task01")
        return folder
    end
    local manifest = { VerificationTicket = "PCW-10", MVPBuilder = "Q04Station", Owner = "Task05", SourceBuilder = "roblox/mvp/builders/Q04Station.luau", RequiredAnchors = required, Preserves = { "Existing Quad benches", "QuadPlanting", "Quad paths", "Bedroom desk/Kindle" }, BasePartCount = 3 }
    local installed = context.SafeReplace("Q04Station", factory)
    return {
        folder = installed,
        manifest = manifest,
    }
end
]=],
["roblox/mvp/builders/Q05Station.luau"] = [=[-- Native, installable Q05 vending visuals. Task 01 owns Studio installation.
return function(context)
    assert(context and context.Root and context.MVP and context.Anchors and context.Palette and context.SafeReplace, "Q05Station context is incomplete")
    local anchor = context.Anchors.Q05UDistrictVending
    assert(anchor and anchor:IsA("BasePart"), "Q05Station requires Q05UDistrictVending BasePart")
    assert(anchor:GetAttribute("PlacementStatus") ~= "UNRESOLVED_LIVE_ANCHOR", "Q05 vending anchor is unresolved")
    local anchorCFrame = anchor.CFrame
    local manifest = {AnchorName = "Q05UDistrictVending", Footprint = "6.4 x 2.4 cabinet footprint", ApproachClearance = "Measured by integrator outside crossing and pedestrian route", Owner = "Task06", SourceBuilder = "roblox/mvp/builders/Q05Station.luau"}
    local installed = context.SafeReplace("Q05Station", function()
        local folder = Instance.new("Model"); folder.Name = "Q05LabubuVending"
        folder:SetAttribute("ActivityId", "Q05"); folder:SetAttribute("VerificationTicket", "PCW-11"); folder:SetAttribute("MVPBuilder", "Q05Station")
        for key, value in pairs(manifest) do folder:SetAttribute(key, value) end
        folder:SetAttribute("Interaction", "Inspect; select wanted; authorized shared-fund roll; skippable reveal")
        local function part(name, size, cf, token, material, collide)
            assert(context.Palette[token], "unknown palette token: " .. token)
            local item = Instance.new("Part"); item.Name = name; item.Size = size; item.CFrame = cf; item.Color = context.Palette[token]; item.Material = material or Enum.Material.SmoothPlastic; item.Anchored = true; item.CanCollide = collide == true; item.CanTouch = false; item.CanQuery = true
            item:SetAttribute("VerificationTicket", "PCW-11"); item:SetAttribute("PaletteToken", token); item:SetAttribute("MVPBuilder", "Q05Station"); item:SetAttribute("AnchorName", manifest.AnchorName); item:SetAttribute("Footprint", manifest.Footprint); item:SetAttribute("ApproachClearance", manifest.ApproachClearance); item:SetAttribute("Owner", manifest.Owner); item:SetAttribute("SourceBuilder", manifest.SourceBuilder); item.Parent = folder; return item
        end
        part("CabinetBody", Vector3.new(6, 7, 2), anchorCFrame * CFrame.new(0, 3.5, 0), "forest", Enum.Material.Wood, true)
        part("DisplayPanel", Vector3.new(5.2, 3.2, .18), anchorCFrame * CFrame.new(0, 5.05, -1.08), "cream", Enum.Material.Glass, false)
        part("GoldHeader", Vector3.new(5.4, .45, 2.15), anchorCFrame * CFrame.new(0, 7.2, 0), "golden", Enum.Material.Metal, false)
        part("Counter", Vector3.new(6.4, .35, 2.4), anchorCFrame * CFrame.new(0, 1.4, -.2), "wood", Enum.Material.Wood, true)
        for index = 1, 7 do part("FigureSlot" .. index, Vector3.new(.48, .72, .18), anchorCFrame * CFrame.new((index - 4) * .62, 5.05, -1.22), index == 7 and "blossom" or "sage", nil, false) end
        part("PromptPlate", Vector3.new(2.8, .5, .12), anchorCFrame * CFrame.new(0, 2.05, -1.22), "golden", Enum.Material.Neon, false)
        return folder
    end)
    return {folder = installed, manifest = manifest}
end
]=],
["roblox/mvp/builders/Q06Station.luau"] = [=[-- Q06 station builder. Geometry is derived from measured UDistrict anchors only.
return function(context)
    assert(context and context.Root and context.MVP and context.Anchors and context.Palette and context.SafeReplace, "Q06Station context is incomplete")
    local required = { "Q06FOBCounter", "Q06AladdinsCounter", "Q06Serving" }
    for _, name in ipairs(required) do
        local anchor = context.Anchors[name]
        assert(anchor and anchor:IsA("BasePart"), "Q06Station requires anchor BasePart: " .. name)
        assert(anchor:GetAttribute("Status") ~= "UNRESOLVED" and anchor:GetAttribute("PlacementStatus") ~= "UNRESOLVED_LIVE_ANCHOR", "Q06 anchor unresolved: " .. name)
    end
    for _, token in ipairs({ "forest", "sage", "cream", "wood", "blossom", "brick", "golden", "ink" }) do assert(context.Palette[token], "Required palette token missing: " .. token) end
    local manifests = {}
    for _, name in ipairs(required) do manifests[name] = { AnchorName=name, Footprint="10 x 4 station footprint", ApproachClearance="Measured UDistrict route clearance", Owner="Task07", SourceBuilder="roblox/mvp/builders/Q06Station.luau" } end
    local function factory()
        local folder = Instance.new("Folder"); folder.Name = "Q06"; folder:SetAttribute("ActivityId", "Q06"); folder:SetAttribute("VerificationTicket", "PCW-12"); folder:SetAttribute("MVPBuilder", "Q06Station")
        local function part(parent, name, size, cf, token, manifest, collide)
            local item = Instance.new("Part"); item.Name, item.Size, item.CFrame, item.Color = name, size, cf, context.Palette[token]; item.Anchored, item.CanCollide, item.CanTouch, item.CanQuery = true, collide == true, false, true
            for key, value in pairs({ VerificationTicket="PCW-12", PaletteToken=token, MVPBuilder="Q06Station", AnchorName=manifest.AnchorName, Footprint=manifest.Footprint, ApproachClearance=manifest.ApproachClearance, Owner=manifest.Owner, SourceBuilder=manifest.SourceBuilder }) do item:SetAttribute(key, value) end
            item.Parent = parent
        end
        for _, name in ipairs(required) do
            local station = Instance.new("Model"); station.Name = name; station.Parent = folder
            local anchor, manifest = context.Anchors[name], manifests[name]
            part(station, "Counter", Vector3.new(10,2,4), anchor.CFrame * CFrame.new(0,1,0), "wood", manifest, true)
            part(station, "ActionSurface", Vector3.new(8,.15,3), anchor.CFrame * CFrame.new(0,2.1,0), "cream", manifest, false)
            part(station, "StationLabel", Vector3.new(4,1,.15), anchor.CFrame * CFrame.new(0,3,-1.8), "forest", manifest, false)
        end
        return folder
    end
    local installedFolder = context.SafeReplace("Q06Station", factory)
    assert(installedFolder and installedFolder.IsA and (installedFolder:IsA("Folder") or installedFolder:IsA("Model")), "Q06 SafeReplace must return installed Folder or Model")
    return { folder=installedFolder, manifest={ VerificationTicket="PCW-12", MVPBuilder="Q06Station", Owner="Task07", SourceBuilder="roblox/mvp/builders/Q06Station.luau", RequiredAnchors=required, PatioPlacement="forbidden", Measurements="pending" } }
end
]=],
["roblox/mvp/builders/SeattleBoundary.luau"] = [=[-- Edit-only Seattle enclosure. Decorative buildings are solid, shallow shells.
return function(context)
    assert(context and context.Root and context.MVP and context.SafeReplace,"Measured builder context required")
    assert(not game:GetService("RunService"):IsRunning(),"Build in Edit mode")
    local root=context.Root
    local palette=context.Palette or {
        forest=Color3.fromHex("365744"),sage=Color3.fromHex("A8B995"),cream=Color3.fromHex("F5F0E4"),wood=Color3.fromHex("95674B"),
        blossom=Color3.fromHex("E8B7C6"),brick=Color3.fromHex("B66C68"),golden=Color3.fromHex("E8C779"),ink=Color3.fromHex("26382E"),
    }
    local V,CF=Vector3.new,CFrame.new
    local existing=root.MVP.Environment:FindFirstChild("SeattleBoundary")
    local minX,maxX,minZ,maxZ
    -- Frozen world-space measurements make reruns independent of world translations.
    if existing and existing:GetAttribute("EnclosureMinX") then
        minX,maxX=existing:GetAttribute("EnclosureMinX"),existing:GetAttribute("EnclosureMaxX")
        minZ,maxZ=existing:GetAttribute("EnclosureMinZ"),existing:GetAttribute("EnclosureMaxZ")
    elseif existing and existing:FindFirstChild("WestUDistrictBackdrop") then
        minX=existing.WestUDistrictBackdrop:FindFirstChild("Shell1",true).Position.X
        maxX=existing.EastQuadBackdrop:FindFirstChild("Shell1",true).Position.X
        minZ=existing.NorthHouseJasperBackdrop:FindFirstChild("Shell1",true).Position.Z
        maxZ=existing.SouthArrivalPatioBackdrop:FindFirstChild("Shell1",true).Position.Z
    else
        local b=assert(context.Options and context.Options.WorldBounds,"Measured world bounds required")
        minX,maxX,minZ,maxZ=b.minX-12,b.maxX+12,b.minZ-12,b.maxZ+12
    end
    assert(minX<maxX and minZ<maxZ,"Invalid enclosure bounds")
    local field=root.Landscape.QuadGround
    local y=field.Position.Y+field.Size.Y/2
    local stage=Instance.new("Folder");stage.Name="SeattleBoundary"
    stage:SetAttribute("BuilderSource","roblox/mvp/builders/SeattleBoundary.luau")
    stage:SetAttribute("VerificationTicket","MAP-03")
    stage:SetAttribute("EnclosureMinX",minX);stage:SetAttribute("EnclosureMaxX",maxX)
    stage:SetAttribute("EnclosureMinZ",minZ);stage:SetAttribute("EnclosureMaxZ",maxZ)
    stage:SetAttribute("GroundedFieldY",y)
    stage:SetAttribute("CollisionPolicy","Solid closed shells; four overlapping 96-stud boundary colliders")
    stage:SetAttribute("SkylinePolicy","Open sky; roofed shallow perimeter buildings")
    stage:SetAttribute("TexturePolicy","Native Roblox materials; approved Color3 palette")
    local count=0
    local function group(name,parent)
        local m=Instance.new("Model");m.Name=name;m.Parent=parent;return m
    end
    local function part(name,size,cf,token,parent,material,collide,query)
        local p=Instance.new("Part");p.Name=name;p.Size=size;p.CFrame=cf;p.Color=assert(palette[token])
        p:SetAttribute("PaletteToken",token);p:SetAttribute("MVPBuilder","SeattleBoundary")
        p.Material=material or Enum.Material.SmoothPlastic;p.Anchored=true
        p.CanCollide=collide==true;p.CanTouch=false;p.CanQuery=query==true
        p.CastShadow=collide==true;p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth
        p.Parent=parent;count+=1;return p
    end
    local function window(name,base,x,h,z,parent)
        part(name.."Frame",V(4.1,4.9,.20),base*CF(x,h,z),"cream",parent,Enum.Material.Concrete)
        part(name.."Pane",V(3.5,4.25,.12),base*CF(x,h,z-.15),"ink",parent,Enum.Material.Glass)
        part(name.."Mullion",V(.13,4.25,.13),base*CF(x,h,z-.24),"cream",parent,Enum.Material.Metal)
        part(name.."Sill",V(4.5,.25,.65),base*CF(x,h-2.55,z-.15),"cream",parent,Enum.Material.Concrete)
    end
    local function building(name,base,width,index,parent)
        local m=group(name,parent)
        local variant=index%5;local height=26+variant*3;local depth=10
        local masonry=variant==1 or variant==4
        m:SetAttribute("DetailType","ClosedSeattleBuilding");m:SetAttribute("FacadeHeight",height)
        part("ClosedShell",V(width+.04,height,depth),base*CF(0,height/2,depth/2),masonry and "brick" or "cream",m,
            masonry and Enum.Material.Brick or Enum.Material.Concrete,true,true)
        part("Roof",V(width+.55,.65,depth+.7),base*CF(0,height+.30,depth/2),"ink",m,Enum.Material.Slate,true,true)
        part("Cornice",V(width+.55,.55,1.1),base*CF(0,height-.30,-.30),"cream",m,Enum.Material.Concrete)
        part("WaterTable",V(width,.65,.28),base*CF(0,.75,-.18),"wood",m,Enum.Material.Concrete)
        part("StoryBand",V(width,.30,.32),base*CF(0,10.4,-.20),"cream",m,Enum.Material.Concrete)
        local bay=variant==2 and -.55 or -.16
        for row=1,2 do for column=1,2 do
            window("Upper"..row.."_"..column,base,(column==1 and -1 or 1)*width*.27,14+(row-1)*8,bay,m)
        end end
        -- Decorative doors are closed; playable storefront entrances are preserved.
        part("DoorFrame",V(4.5,8.9,.22),base*CF(0,4.65,-.16),"wood",m,Enum.Material.Wood)
        part("ClosedDoor",V(3.8,8.2,.17),base*CF(0,4.35,-.32),variant%2==0 and "forest" or "wood",m,Enum.Material.Wood)
        part("DoorGlass",V(2.65,3.8,.10),base*CF(0,5.8,-.46),"ink",m,Enum.Material.Glass)
        part("DoorRail",V(3.5,.16,.12),base*CF(0,3.9,-.49),"wood",m,Enum.Material.Wood)
        part("DoorHandle",V(.12,1.0,.18),base*CF(1.3,3.7,-.54),"golden",m,Enum.Material.Metal)
        for column=1,2 do
            local x=(column==1 and -1 or 1)*width*.29
            part("ShopFrame"..column,V(width*.32,6.7,.16),base*CF(x,4.5,-.14),"wood",m,Enum.Material.Wood)
            part("ShopGlass"..column,V(width*.32-.45,6.12,.12),base*CF(x,4.5,-.26),"ink",m,Enum.Material.Glass)
        end
        local awningToken=variant%2==0 and "forest" or "wood"
        part("Awning",V(width*.80,.26,2.6),base*CF(0,9.1,-1.35)*CFrame.Angles(math.rad(9),0,0),awningToken,m,Enum.Material.Fabric)
        part("AwningValance",V(width*.80,.60,.15),base*CF(0,8.65,-2.62),awningToken,m,Enum.Material.Fabric)
        part("RainDownpipe",V(.22,height-.7,.24),base*CF(width/2-.6,height/2,-.30),"ink",m,Enum.Material.Metal)
        if variant==3 then
            part("RoofVent",V(3,1.6,3),base*CF(width*.15,height+1.2,6),"sage",m,Enum.Material.Metal)
        end
    end
    local depth=10
    local function row(name,base,length,variant)
        local m=group(name,stage);local pieces=math.ceil(length/30);local width=length/pieces
        for i=1,pieces do building(string.format("Building%02d",i),base*CF((i-(pieces+1)/2)*width,0,0),width,i+variant,m) end
    end
    row("NorthHouseJasperBackdrop",CF((minX+maxX)/2,y,minZ)*CFrame.Angles(0,math.pi,0),maxX-minX+depth*2,1)
    row("SouthArrivalPatioBackdrop",CF((minX+maxX)/2,y,maxZ),maxX-minX+depth*2,3)
    row("WestUDistrictBackdrop",CF(minX,y,(minZ+maxZ)/2)*CFrame.Angles(0,-math.pi/2,0),maxZ-minZ,2)
    row("EastQuadBackdrop",CF(maxX,y,(minZ+maxZ)/2)*CFrame.Angles(0,math.pi/2,0),maxZ-minZ,4)
    local floor=part("PerimeterGround",V(maxX-minX+1,.32,maxZ-minZ+1),CF((minX+maxX)/2,y-.20,(minZ+maxZ)/2),"sage",stage,Enum.Material.Grass,true,true)
    floor:SetAttribute("DetailType","GroundClosure")
    local barrier=group("ContinuousEnclosure",stage)
    local wallY=y-4+96/2
    local walls={
        {"North",V(maxX-minX+24,96,2),CF((minX+maxX)/2,wallY,minZ+1)},
        {"South",V(maxX-minX+24,96,2),CF((minX+maxX)/2,wallY,maxZ-1)},
        {"West",V(2,96,maxZ-minZ+4),CF(minX+1,wallY,(minZ+maxZ)/2)},
        {"East",V(2,96,maxZ-minZ+4),CF(maxX-1,wallY,(minZ+maxZ)/2)},
    }
    for _,spec in walls do
        local p=part(spec[1],spec[2],spec[3],"ink",barrier,Enum.Material.SmoothPlastic,true,false)
        p.Transparency=1;p.CastShadow=false;p:SetAttribute("DetailType","WorldBoundary")
    end
    assert(count<=2300,"Seattle enclosure exceeds 2300 parts: "..count)
    for _,p in stage:GetDescendants()do if p:IsA("BasePart")then
        assert(p.Color==palette[p:GetAttribute("PaletteToken")] and p.Anchored,"Invalid palette/static part")
    end end
    stage:SetAttribute("PartCount",count)
    stage:SetAttribute("BuildingCount",math.ceil((maxX-minX+20)/30)*2+math.ceil((maxZ-minZ)/30)*2)
    stage:SetAttribute("Status","Built; independent review and human playtest pending")
    local installed=context.SafeReplace("SeattleBoundary",function()return stage end)
    game:GetService("ChangeHistoryService"):SetWaypoint("Seattle enclosed and detailed buildings 04")
    return {folder=installed or stage,manifest={PartCount=count,Bounds={minX,maxX,minZ,maxZ},GroundY=y}}
end
]=],
["roblox/mvp/client/activities/Q01.luau"] = [=[-- View descriptor consumed by the common activity renderer.
return {
	activityId = "Q01",
	title = "Everything Tucked In",
	state = "Open",
	instructions = "Help with an available bed step",
	progress = { done = 0, total = 7 },
	availableActions = {},
	acceptedStepIds = {},
	contributors = {},
	busyReason = nil,
	errorText = nil,
	canReplay = false,
	steps = {
		{ id = "blanket_left", label = "Smooth the left blanket", verb = "Smooth", socket = "Socket_blanket_left" },
		{ id = "blanket_right", label = "Smooth the right blanket", verb = "Smooth", socket = "Socket_blanket_right" },
		{ id = "blanket_foot", label = "Fold the foot blanket", verb = "Fold", socket = "Socket_blanket_foot" },
		{ id = "pillow_left", label = "Place the left pillow", verb = "Place", socket = "Socket_pillow_left" },
		{ id = "pillow_right", label = "Place the right pillow", verb = "Place", socket = "Socket_pillow_right" },
		{ id = "plush_dog", label = "Tuck in the round-bellied dog", verb = "Tuck", socket = "Socket_plush_dog" },
		{ id = "plush_dinosaur", label = "Tuck in the dinosaur plush", verb = "Tuck", socket = "Socket_plush_dinosaur" },
	},
	finish = {
		permission = "PhuongOnly",
		label = "Choose how to finish the bed",
		choices = { { id = "soft_snug", label = "Soft and snug" }, { id = "neat_layered", label = "Neatly layered" } },
	},
	controls = { touch = { select = "Tap highlighted step", confirm = "Tap Place or Tuck", cancel = "Tap Cancel" }, desktop = { select = "Click highlighted step", confirm = "Click Place or Tuck", cancel = "Press Escape or click Cancel" } },
	messages = { alreadyDone = "That spot is already handled—choose another bed task", inUse = "Someone else is handling that spot; choose another bed task", needsPhuong = "Ready for Phuong to finish" },
}
]=],
["roblox/mvp/client/activities/Q02.luau"] = [=[-- UI-safe descriptor for Q02. Main client owns rendering and input routing.
return {
    activityId = "Q02",
    title = "Jasper's Favorite Things",
    prompts = {
        greet = {desktop = "Interact", touch = "Say hi to Jasper"},
        rabbitFound = {desktop = "Interact", touch = "Inspect basket"},
        rabbitReturned = {desktop = "Interact", touch = "Return rabbit"},
        fetch = {desktop = "Click / Throw", touch = "Throw"},
        greenie = {desktop = "Interact", touch = "Give Greenie"},
        pet = {desktop = "Interact", touch = "Pet Jasper"},
    },
    note = "Throw uses a forgiving lane target; no camera lock or repeated-pet reward.",
}
]=],
["roblox/mvp/client/activities/Q03.luau"] = [=[return {
    ActivityId = "Q03",
    Controls = {"Select piece", "Select socket", "Rotate left", "Rotate right", "Place", "Cancel", "Preview at home"},
    Keyboard = {RotateLeft="Q", RotateRight="E"},
    TouchTargetMinimum = 48,
    States = {"Available", "Reserved", "Placed", "Invalid", "Busy", "Expired", "Completed"},
}
]=],
["roblox/mvp/client/activities/Q04.luau"] = [=[return {
    activityId = "Q04",
    title = "One More Chapter",
    entryActions = { "Read" },
    panel = { name = "ReadingPanel", scroll = true, close = true, save = true, retry = true, keyboardOptional = true },
    highlightChoices = { "small-detail", "comforting-moment", "shared-spark" },
    reactions = { "moved", "cozy", "curious", "smile" },
    bookmarks = { "ribbon", "pressed-flower", "star-tab" },
    anchors = { "Q04QuadReading", "Q04BedroomKindle" },
}
]=],
["roblox/mvp/client/activities/Q06.luau"] = [=[-- UI-safe Q06 descriptor. Client code renders this; it never grants progress.
return {
	activityId = "Q06",
	title = "Something Delicious",
	menuStatus = "Build a bowl at FOB, add sauce at Aladdins, then set the serving table",
	anchors = { "Q06FOBCounter", "Q06AladdinsCounter", "Q06Serving" },
	roles = {
		{ id = "base", label = "Choose a base", items = { "rice" } },
		{ id = "protein", label = "Choose a protein", items = { "tofu", "chicken", "mushroom" } },
		{ id = "toppings", label = "Choose a fresh topping", items = { "greens", "cucumber", "carrot" } },
		{ id = "sauce", label = "Choose a finish", items = { "sauce", "sesame" } },
		{ id = "settingA", label = "Left table setting", items = { "plate", "napkin" } },
		{ id = "settingB", label = "Right table setting", items = { "cup", "napkin" } },
	},
	input = { sequence = { "choose-card", "preview-selection", "add-or-place" }, cancel = "tap-cancel", desktopEquivalent = true, minTargetScreenUnits = 48 },
	feedback = { accepted = "Added to the shared meal", busy = "A friend is choosing for this spot", complete = "Done! Your shared meal is ready" },
}
]=],
["roblox/mvp/client/CozySoundEffectsClient.client.luau"] = [=[-- Permanent export of live SFX client. Replace the old LocalScript, do not add a second copy.
local Players = game:GetService("Players")
local SoundService = game:GetService("SoundService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContentProvider = game:GetService("ContentProvider")
local player = Players.LocalPlayer
if SoundService:FindFirstChild("CozySoundEffectsLocal") then return end
local specs = {
    SoftClick={id="88442833509532",volume=.18}, SuccessChime={id="103516326607012",volume=.22},
    JasperBark={id="135016436724006",volume=.25}, JasperPant={id="6463651038",volume=.10},
}
local root = ReplicatedStorage:FindFirstChild("PhuongMVP")
local shared = root and root:FindFirstChild("shared")
local configModule = shared and shared:FindFirstChild("AudioConfig")
if configModule and configModule:IsA("ModuleScript") then
    local ok, config = pcall(require,configModule)
    if ok and type(config)=="table" and type(config.Effects)=="table" then specs=config.Effects end
end
if type(player:GetAttribute("CozyEffectsEnabled")) ~= "boolean" then player:SetAttribute("CozyEffectsEnabled",true) end
local folder = Instance.new("Folder")
folder.Name, folder.Parent = "CozySoundEffectsLocal", SoundService
local group = Instance.new("SoundGroup")
group.Name, group.Parent = "EffectsVolume", folder
local destroyed, cooldown, lastChime, seenCount = false, -math.huge, -math.huge, 0
local connections, buttons, seen, loads, previousGroups, pendingSpatial = {}, {}, {}, {}, {}, {}
local trySpatial
local function enabled() return player:GetAttribute("CozyEffectsEnabled") ~= false end
local function setVolume() group.Volume = enabled() and 1 or 0 end
setVolume()
table.insert(connections, player:GetAttributeChangedSignal("CozyEffectsEnabled"):Connect(setVolume))
local function cancelThread(thread)
    if thread and coroutine.status(thread) ~= "dead" then pcall(task.cancel,thread) end
end
local function makeSound(name)
    local spec = specs[name]
    local templates = SoundService:FindFirstChild("CozySoundEffects")
    local original = templates and templates:FindFirstChild(name)
    local sound = original and original:IsA("Sound") and original:Clone() or Instance.new("Sound")
    sound.Name, sound.SoundId, sound.Volume = name, "rbxassetid://"..spec.id, spec.volume
    sound.Looped, sound.SoundGroup, sound.Parent = false, group, folder
    sound.PlayOnRemove = false
    local entry = {sound=sound,status="Loading"}
    loads[name] = entry
    folder:SetAttribute(name.."Status",entry.status)
    local function finish(status)
        if destroyed or entry.status ~= "Loading" then return end
        entry.status = status; folder:SetAttribute(name.."Status",status)
        if entry.loaded then entry.loaded:Disconnect(); entry.loaded=nil end
        if trySpatial then
            for pending in pairs(pendingSpatial) do if pending.Name==name then trySpatial(pending) end end
        end
    end
    entry.loaded = sound.Loaded:Connect(function() if sound.IsLoaded then finish("Loaded") end end)
    entry.worker = task.defer(function()
        local ok = pcall(function()
            ContentProvider:PreloadAsync({sound},function(_,status)
                if status ~= Enum.AssetFetchStatus.Success then finish("Unavailable") end
            end)
        end)
        if destroyed then return end
        if sound.IsLoaded then finish("Loaded") elseif not ok then finish("Unavailable") end
    end)
    entry.timeout = task.delay(8,function()
        if destroyed or entry.status ~= "Loading" then return end
        finish(sound.IsLoaded and "Loaded" or "Timed out")
        cancelThread(entry.worker)
    end)
    return entry
end
local click, chime = makeSound("SoftClick"), makeSound("SuccessChime")
makeSound("JasperBark"); makeSound("JasperPant")
local function play(entry)
    if destroyed or not enabled() or entry.status ~= "Loaded" then return end
    pcall(function() entry.sound.TimePosition=0; entry.sound:Play() end)
end
local function bindButton(button)
    if not button:IsA("GuiButton") or buttons[button] then return end
    local record = {}
    buttons[button] = record
    record.activated = button.Activated:Connect(function()
        if not button.Active or not button.Interactable or os.clock()-cooldown < .08 then return end
        cooldown = os.clock(); play(click)
    end)
    record.destroying = button.Destroying:Connect(function()
        record.activated:Disconnect(); record.destroying:Disconnect(); buttons[button]=nil
    end)
end
local boundGui, boundRoots, boundRemotes = {}, {}, {}
local function bindGui(gui)
    if not gui:IsA("PlayerGui") or boundGui[gui] then return end
    boundGui[gui]=true
    table.insert(connections,gui.DescendantAdded:Connect(bindButton))
    for _,child in ipairs(gui:GetDescendants()) do bindButton(child) end
end
local function bindRemote(remote)
    if remote.Name~="Action" or not remote:IsA("RemoteEvent") or boundRemotes[remote] then return end
    boundRemotes[remote]=true
    table.insert(connections,remote.OnClientEvent:Connect(function(payload)
        if type(payload)~="table" or payload.kind~="Result" or payload.ok~=true then return end
        if string.lower(tostring(payload.code))=="duplicate" or type(payload.result)=="table" and string.lower(tostring(payload.result.code))=="duplicate" then return end
        local receipt=payload.receipt
        local completion=type(receipt)=="table" and (type(receipt.completion)=="table" and receipt.completion or receipt) or nil
        local code=string.lower(tostring(payload.code))
        local complete=code=="completed" or code=="round_completed" or completion and completion.petalGranted==true
        local identity=completion and (completion.receiptId or completion.actionId) or payload.actionId
        if not complete or type(identity)~="string" then return end
        local key=tostring(payload.sessionId)..":"..identity
        if seen[key] or seenCount>=4096 then return end
        seen[key],seenCount=true,seenCount+1
        if os.clock()-lastChime<1 then return end
        lastChime=os.clock(); play(chime)
    end))
end
local function bindRoot(candidate)
    if candidate.Name~="PhuongMVP" or boundRoots[candidate] then return end
    boundRoots[candidate]=true
    table.insert(connections,candidate.ChildAdded:Connect(bindRemote))
    for _,child in ipairs(candidate:GetChildren()) do bindRemote(child) end
end
trySpatial=function(sound)
    if destroyed or not sound.Parent then pendingSpatial[sound]=nil; return end
    local entry=loads[sound.Name]
    if not entry or entry.status=="Loading" then return end
    pendingSpatial[sound]=nil
    if entry.status~="Loaded" or not enabled() then return end
    local emitted=sound:GetAttribute("CozyEmittedAt")
    local lifetime=sound:GetAttribute("CozyLifetime")
    if type(emitted)~="number" or type(lifetime)~="number" then return end
    local elapsed=math.max(0,workspace:GetServerTimeNow()-emitted)
    if elapsed>=lifetime or entry.sound.TimeLength>0 and elapsed>=entry.sound.TimeLength then return end
    pcall(function() sound.TimePosition=elapsed; sound:Play() end)
end
-- A local SoundGroup also silences replicated Jasper sounds for this listener.
local function bindSpatial(sound)
    if not sound:IsA("Sound") or sound:IsDescendantOf(folder) or previousGroups[sound] then return end
    local spec=specs[sound.Name]
    if not spec or sound.SoundId~="rbxassetid://"..spec.id then return end
    if sound:GetAttribute("CozySoundEffect")~=true and not (sound.Parent and sound.Parent.Name=="JasperAudioEmitter") then return end
    previousGroups[sound]={group=sound.SoundGroup}
    sound.SoundGroup=group
    local connection
    connection=sound.Destroying:Connect(function()
        previousGroups[sound]=nil
        pendingSpatial[sound]=nil
        connection:Disconnect()
    end)
    previousGroups[sound].connection=connection
    if sound:GetAttribute("CozyAutoPlay")==true then pendingSpatial[sound]=true; trySpatial(sound) end
end
table.insert(connections,workspace.DescendantAdded:Connect(bindSpatial))
for _,child in ipairs(workspace:GetDescendants()) do bindSpatial(child) end
table.insert(connections,player.ChildAdded:Connect(bindGui))
for _,child in ipairs(player:GetChildren()) do bindGui(child) end
table.insert(connections,ReplicatedStorage.ChildAdded:Connect(bindRoot))
for _,child in ipairs(ReplicatedStorage:GetChildren()) do bindRoot(child) end
local function destroy()
    if destroyed then return end
    destroyed=true
    for _,connection in ipairs(connections) do connection:Disconnect() end
    for _,record in pairs(buttons) do record.activated:Disconnect(); record.destroying:Disconnect() end
    for sound,record in pairs(previousGroups) do
        record.connection:Disconnect()
        if sound.Parent and sound:GetAttribute("CozyAutoPlay")==true then sound:Stop() end
        if sound.Parent and sound.SoundGroup==group then sound.SoundGroup=record.group end
    end
    for _,entry in pairs(loads) do
        if entry.loaded then entry.loaded:Disconnect() end
        cancelThread(entry.worker); cancelThread(entry.timeout)
    end
    folder:Destroy()
    table.clear(buttons); table.clear(previousGroups); table.clear(seen); table.clear(pendingSpatial)
end
table.insert(connections,script.Destroying:Connect(destroy))
table.insert(connections,folder.Destroying:Connect(destroy))
]=],
["roblox/mvp/client/extensions/FinalePresentation.luau"] = [=[-- One optional local camera. Music belongs exclusively to PCW-26.
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Module = {}

function Module.Init(getContext, registry)
    local initial = getContext()
    local player, UI = initial.player, initial.UI
    local latest, active, confirmation, destroyed
    local skipped, connections = {}, {}
    local offeredKey, invitationKey
    local P = UI.Palette
    local overlay = Instance.new("ScreenGui")
    overlay.Name, overlay.ResetOnSpawn, ov]==]
return #_G.__PCW25ContractText