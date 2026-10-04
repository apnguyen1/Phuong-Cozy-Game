-- Edit-only ground and green-tree detail pass. Cherry assets and gameplay are preserved.
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
