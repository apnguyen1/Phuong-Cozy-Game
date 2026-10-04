-- Edit-only source import; building the feature is a separate explicit step.
local parent=assert(game:GetService("ServerStorage").PhuongMVPTools.builders)
local old=assert(parent:FindFirstChild("SeattleBoundary"))
assert(old:IsA("ModuleScript") and old:GetAttribute("PhuongMVPImportOwned"),"owned module required")
local expectedSource=[==[-- Edit-only Seattle enclosure. Decorative buildings are solid, shallow shells.
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
]==]
local n=Instance.new("ModuleScript");n.Name="SeattleBoundary"
n:SetAttribute("PhuongMVPImportOwned",true)
n:SetAttribute("PhuongMVPSourceSHA256","EF3C6C424F005AE7E63082952FB5FA6995C370418691BFEBF4681BFDA29B2CBD")
n.Source=expectedSource;assert(n.Source==expectedSource,"source readback mismatch")
n.Parent=parent;old:Destroy();return true
