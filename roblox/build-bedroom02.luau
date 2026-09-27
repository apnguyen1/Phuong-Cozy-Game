-- Studio Edit-mode builder. Replaces only Home.Bedroom and named Draft 01 props.
-- The existing cottage shell, entrance, door scripts and exterior are preserved.
local home = workspace:WaitForChild("CozyWorld_Draft01"):WaitForChild("Home")
local placementOffset = home:WaitForChild("Floor").Position - Vector3.new(-28,.12,-108)
local previous = home:FindFirstChild("Bedroom")
if previous then previous:Destroy() end
for _, child in home:GetChildren() do
	if table.find({"ReadingRug", "CraftTableTop", "TableLeg", "InteriorLamp"}, child.Name) then child:Destroy() end
end

local V, CF = Vector3.new, CFrame.new
local palette = {
	forest=Color3.fromHex("365744"), sage=Color3.fromHex("A8B995"),
	cream=Color3.fromHex("F5F0E4"), wood=Color3.fromHex("95674B"),
	blossom=Color3.fromHex("E8B7C6"), brick=Color3.fromHex("B66C68"),
	golden=Color3.fromHex("E8C779"), ink=Color3.fromHex("26382E"),
}
local function group(name, parent)
	local m=Instance.new("Model"); m.Name=name; m.Parent=parent; return m
end
local room=group("Bedroom",home)
room:SetAttribute("VerificationTicket","PCW-04")
room:SetAttribute("DraftVersion","02")
room:SetAttribute("RoomCount",1)
room:SetAttribute("ReferenceImages","image-2.jpg; image-3.jpg")
room:SetAttribute("EntryClearanceStuds",8)
room:SetAttribute("Layout","Bed and fairy-light wall north; desk and bookcase south; one open room")

local function part(name,size,position,token,parent,material,solid)
	assert(palette[token],"Unknown palette token: "..tostring(token))
	local p=Instance.new("Part"); p.Name=name; p.Size=size
	p.CFrame=typeof(position)=="CFrame" and position or CF(position)
	p.Color=palette[token]; p:SetAttribute("PaletteToken",token)
	-- White furniture is painted; visible grain belongs on the natural wood accents.
	p.Material=(token=="cream" and material==Enum.Material.Wood) and Enum.Material.SmoothPlastic or (material or Enum.Material.SmoothPlastic)
	p.Anchored=true; p.CanCollide=solid==true; p.CanTouch=false; p.CanQuery=solid==true
	p.TopSurface=Enum.SurfaceType.Smooth; p.BottomSurface=Enum.SurfaceType.Smooth
	p.CastShadow=solid==true or (math.max(size.X,size.Y,size.Z)>=1.5 and material==Enum.Material.Fabric)
	p.Parent=parent; return p
end
local function ellipsoid(name,size,position,token,parent,material)
	-- Ball parts constrain their rendered shape to a sphere. A built-in Sphere mesh
	-- on a Block part preserves the separate axes needed by leaves, pillows and cloth.
	local p=part(name,size,position,token,parent,material)
	local mesh=Instance.new("SpecialMesh"); mesh.Name="SoftShape"; mesh.MeshType=Enum.MeshType.Sphere
	mesh.Scale=V(1,1,1); mesh.Parent=p
	return p
end
local function cylinder(name,size,position,token,parent,material)
	local p=part(name,size,position,token,parent,material); p.Shape=Enum.PartType.Cylinder; return p
end
local function rod(name,a,b,diameter,token,parent,material)
	return part(name,V(diameter,diameter,(b-a).Magnitude),CF((a+b)/2,b),token,parent,material)
end
local function leaf(name,pos,yaw,scale,token,parent)
	return ellipsoid(name,V(.48*scale,.1*scale,1.05*scale),CF(pos)*CFrame.Angles(math.rad(25),yaw,math.rad(25)),token,parent)
end
local function cushion(name,size,position,token,parent)
	local c=ellipsoid(name,size,position,token,parent,Enum.Material.Fabric)
	return c
end
local function pointLight(parent,brightness,range,token)
	local light=Instance.new("PointLight"); light.Name="WarmLight"; light.Color=palette[token or "cream"]
	light.Brightness=brightness; light.Range=range; light.Shadows=false; light.Parent=parent
end
local function plant(parent,origin,scale)
	local m=group("PottedPlant",parent)
	cylinder("Pot",V(.7*scale,1*scale,1*scale),CF(origin+V(0,.35*scale,0))*CFrame.Angles(0,0,math.pi/2),"cream",m)
	cylinder("Soil",V(.05*scale,.85*scale,.85*scale),CF(origin+V(0,.72*scale,0))*CFrame.Angles(0,0,math.pi/2),"wood",m)
	for i=0,6 do
		local a=i*math.pi*2/7
		local endPoint=origin+V(math.cos(a)*.65*scale,(1.1+(i%3)*.21)*scale,math.sin(a)*.65*scale)
		rod("Stem",origin+V(0,.65*scale,0),endPoint,.045*scale,"forest",m)
		leaf("Leaf",endPoint,a,scale,i%2==0 and "forest" or "sage",m)
	end
	return m
end
local function book(parent,frame,width,height,depth,token,lean)
	local cf=frame*CFrame.Angles(0,0,math.rad(lean or 0))
	part("BookPages",V(width*.84,height-.08,depth-.14),cf,"cream",parent)
	part("BookSpine",V(width,height,.13),cf*CF(0,0,depth/2),token,parent)
	for _,side in {-1,1} do part("BookCover",V(.075,height,depth),cf*CF(side*width/2,0,0),token,parent) end
	for _,y in {-.3,.32} do part("SpineBand",V(width*.72,.06,.025),cf*CF(0,y*height,depth/2+.07),"golden",parent) end
end
local function smallFigure(parent,origin,token,ears)
	local m=group("ShelfFigure",parent)
	ellipsoid("Body",V(.7,.85,.63),origin+V(0,.44,0),token,m)
	ellipsoid("Head",V(.65,.6,.58),origin+V(0,.96,0),token,m)
	if ears then for _,s in {-1,1} do ellipsoid("Ear",V(.2,.38,.2),origin+V(s*.22,1.29,0),token,m) end end
	for _,s in {-1,1} do ellipsoid("Eye",V(.055,.08,.025),origin+V(s*.12,1.01,.285),"ink",m) end
	return m
end
local function drawerFront(parent,cf,width,height)
	part("DrawerFace",V(width,height,.18),cf,"cream",parent)
	part("DrawerPull",V(width*.23,.11,.15),cf*CF(0,.08,.17),"wood",parent)
end

-- Continuous floor, perimeter trim and a domestic ceiling; there are no partitions.
local shell=group("InteriorFinishes",room)
local floorColors={"wood"}
for column=0,15 do
	local x=-58+column*4
	local z=-131.4
	local row=0
	while z < -84.65 do
		local length=math.min(7+(column*7+row*5)%9,-84.65-z)
		if length>.05 then
			local p=part("WoodFloorPlank",V(3.97,.075,math.max(.025,length-.035)),V(x,.368,z+length/2),floorColors[(column+row*2)%#floorColors+1],shell,Enum.Material.Wood)
			p:SetAttribute("SurfaceDetail","Staggered wood boards")
		end
		z+=length; row+=1
	end
end
for _,x in {-59.35,3.35} do
	part("Skirting",V(.22,.75,46.9),V(x,.76,-108),"cream",shell,Enum.Material.Wood)
	part("CrownMolding",V(.35,.3,47),V(x,13.83,-108),"cream",shell)
end
part("NorthSkirting",V(62.7,.75,.22),V(-28,.76,-131.35),"cream",shell,Enum.Material.Wood)
part("NorthCrown",V(62.7,.3,.35),V(-28,13.83,-131.35),"cream",shell)
for _,range in {{-59.35,-24.5},{-15.5,3.35}} do
	part("FrontSkirting",V(range[2]-range[1],.75,.2),V((range[1]+range[2])/2,.76,-84.65),"cream",shell,Enum.Material.Wood)
end
part("Ceiling",V(62.8,.18,46.8),V(-28,14.03,-108),"cream",shell,Enum.Material.SmoothPlastic,true)
local ceiling=group("CeilingFixture",shell)
cylinder("DarkMount",V(.18,2.6,2.6),CF(-28,13.85,-110)*CFrame.Angles(0,0,math.pi/2),"ink",ceiling)
local dome=ellipsoid("GlassDome",V(2.3,1.1,2.3),V(-28,13.42,-110),"cream",ceiling,Enum.Material.Neon)
ellipsoid("Finial",V(.3,.38,.3),V(-28,12.85,-110),"ink",ceiling)
pointLight(dome,.6,40)
local fill=part("ReadingLight",V(.1,.1,.1),V(-43,10,-114),"cream",shell)
fill.Transparency=1; pointLight(fill,.16,23)

-- Bed from the reference: rounded upholstered headboard, sage cover and folded layers.
local bed=group("SageBed",room)
bed:SetAttribute("ReferenceFeature","Sage bed; cream quilt; floral throw; dog and dinosaur plushies")
for _,x in {-54,-36} do for _,z in {-127,-104} do part("BedLeg",V(.65,1.2,.65),V(x,1.05,z),"wood",bed,Enum.Material.Wood,true) end end
part("UpholsteredBase",V(20,1.1,27),V(-45,1.63,-115.6),"cream",bed,Enum.Material.Fabric,true)
part("MattressSeam",V(20.1,.17,27.1),V(-45,2.25,-115.6),"ink",bed,Enum.Material.Fabric)
part("Mattress",V(20.1,1.15,27.1),V(-45,2.83,-115.6),"cream",bed,Enum.Material.Fabric,true)
part("HeadboardBody",V(21,6,.7),V(-45,4.1,-129.4),"cream",bed,Enum.Material.Fabric,true)
ellipsoid("HeadboardSoftTop",V(21,1.1,1),V(-45,7,-129.4),"cream",bed,Enum.Material.Fabric)
for _,x in {-50.3,-45,-39.7} do ellipsoid("HeadboardButton",V(.19,.19,.1),V(x,5.4,-128.98),"wood",bed) end
part("SageDuvet",V(20.35,.3,23.9),V(-45,3.58,-113.85),"sage",bed,Enum.Material.Fabric)
for _,x in {-55.23,-34.77} do part("DuvetSideDrape",V(.2,1.1,24),V(x,3.13,-113.8),"sage",bed,Enum.Material.Fabric) end
for _,x in {-52.2,-48.6,-45,-41.4,-37.8} do part("DuvetStitch",V(.035,.015,22.9),V(x,3.739,-113.7),"forest",bed,Enum.Material.Fabric) end
for _,z in {-123.3,-117.8,-112.3,-106.8} do part("DuvetCrossStitch",V(20,.015,.035),V(-45,3.74,z),"forest",bed,Enum.Material.Fabric) end
for _,x in {-50.2,-40} do
	cushion("CreamSleepingPillow",V(8.8,1.7,4.7),CF(x,4.27,-125.5)*CFrame.Angles(math.rad(-6),0,0),"cream",bed)
	part("PillowHem",V(7,.025,.045),V(x,4.91,-124.13),"cream",bed,Enum.Material.Fabric)
end
cushion("SageBolster",V(3.6,2.4,11.8),CF(-53.1,4.3,-119.1)*CFrame.Angles(0,0,math.rad(11)),"sage",bed)
cushion("RoundAccentPillow",V(4.3,1.6,4.3),V(-50.1,4.6,-120),"cream",bed)
part("FoldedCreamQuilt",V(19.8,.75,5.9),V(-45,4.05,-105.5),"cream",bed,Enum.Material.Fabric)
cushion("SoftQuiltFold",V(19.75,.4,1.1),V(-45,4.23,-102.65),"cream",bed)
for _,z in {-108.28,-108.04,-102.88,-103.08} do part("QuiltPiping",V(19.2,.06,.08),V(-45,4.44,z),"golden",bed,Enum.Material.Fabric) end
part("FloralThrow",V(16,.26,4.1),CF(-45,4.57,-105.5)*CFrame.Angles(0,math.rad(3),0),"cream",bed,Enum.Material.Fabric)
for _,p in {{-51,-105.8},{-45,-104.6},{-39,-106.3}} do
	rod("PrintedStem",V(p[1]-1.1,4.72,p[2]-.7),V(p[1]+1.3,4.72,p[2]+.7),.07,"forest",bed)
	for i=0,7 do local a=i*2.399; ellipsoid("PrintedHydrangea",V(.64,.04,.6),V(p[1]+math.cos(a)*.75,4.73,p[2]+math.sin(a)*.6),i%2==0 and "blossom" or "sage",bed) end
	for _,d in {-1,1} do ellipsoid("PrintedLeaf",V(1.1,.035,.5),CF(p[1]+d*1.4,4.73,p[2]+d*.5)*CFrame.Angles(0,math.rad(30*d),0),"forest",bed) end
end

local plushies=group("BedPlushies",bed)
local dog=group("WeightedDog",plushies)
ellipsoid("RoundBelly",V(3.5,2.6,3.2),V(-39.1,4.8,-122.3),"cream",dog,Enum.Material.Fabric)
ellipsoid("Head",V(2.6,2.4,2.25),V(-39.1,6,-123.1),"cream",dog,Enum.Material.Fabric)
for _,s in {-1,1} do
	ellipsoid("FloppyEar",V(.85,2.15,.65),CF(-39.1+s*1.12,5.8,-123.05)*CFrame.Angles(0,0,math.rad(s*18)),"wood",dog,Enum.Material.Fabric)
	ellipsoid("Eye",V(.16,.2,.1),V(-39.1+s*.49,6.1,-121.99),"ink",dog)
	ellipsoid("Paw",V(1.2,.7,1.3),V(-39.1+s*.86,3.96,-120.94),"cream",dog,Enum.Material.Fabric)
end
ellipsoid("Muzzle",V(1.5,.9,.68),V(-39.1,5.53,-121.92),"cream",dog,Enum.Material.Fabric)
ellipsoid("Nose",V(.34,.26,.21),V(-39.1,5.78,-121.55),"ink",dog)
local dinosaur=group("WeightedDinosaur",plushies)
ellipsoid("RoundBelly",V(3.3,2.85,3.3),V(-35.9,4.84,-119.9),"forest",dinosaur,Enum.Material.Fabric)
ellipsoid("CreamBelly",V(2.15,1.95,.3),V(-35.9,4.71,-118.42),"sage",dinosaur,Enum.Material.Fabric)
ellipsoid("Head",V(2.35,2.1,2.4),V(-35.9,6.4,-120.05),"forest",dinosaur,Enum.Material.Fabric)
ellipsoid("Snout",V(2.1,.85,1.2),V(-35.9,6.05,-118.97),"sage",dinosaur,Enum.Material.Fabric)
for _,s in {-1,1} do
	ellipsoid("Eye",V(.16,.18,.08),V(-35.9+s*.53,6.62,-118.9),"ink",dinosaur)
	ellipsoid("Foot",V(1.15,.7,1.2),V(-35.9+s*.85,3.91,-118.95),"forest",dinosaur,Enum.Material.Fabric)
end
for i=0,3 do ellipsoid("SoftBackSpike",V(.62,.8,.55),V(-35.9,7.25-i*.67,-120.3-i*.48),"sage",dinosaur,Enum.Material.Fabric) end
ellipsoid("Tail",V(1.4,.9,2.7),CF(-34.4,4.34,-120.8)*CFrame.Angles(0,math.rad(-35),0),"forest",dinosaur,Enum.Material.Fabric)
for i,token in {"wood","sage","cream"} do
	local f=smallFigure(plushies,V(-53.1+(i-1)*1.6,6.5,-129),token,true)
	f.Name="HeadboardAnimal"..i
end

-- Fairy curtain and ivy sit behind the headboard. Only two light sources, not a light per bulb.
local curtain=group("IvyAndFairyLights",room)
curtain:SetAttribute("ReferenceFeature","Warm vertical light curtain and trailing ivy above the bed")
part("CreamBackdrop",V(25.4,12.25,.1),V(-45.8,7.2,-131.33),"cream",curtain,Enum.Material.Fabric)
rod("LightHeader",V(-58.2,12.8,-130.8),V(-32.6,12.8,-130.8),.055,"wood",curtain)
for column=0,14 do
	local x=-57.6+column*1.73
	local low=column%2==0 and 5.8 or 7.4
	rod("VerticalLightWire",V(x,12.78,-130.65),V(x,low,-130.65),.028,"wood",curtain)
	for y=low,12.7,.86 do
		ellipsoid("FairyBulb",V(.15,.24,.15),V(x+.08*math.sin(y*3),y,-130.53),"golden",curtain,Enum.Material.Neon)
	end
	local vineEnd=10.45-(column%4)*.25
	rod("IvyVine",V(x,13.1,-130.42),V(x+.23,vineEnd,-130.3),.035,"forest",curtain)
	for j=0,4 do
		local yy=12.9-j*.48
		for _,side in {-1,1} do
			local pos=V(x+side*.27,yy,-130.1)
			ellipsoid("IvyLeaf",V(.52,.77,.075),CF(pos)*CFrame.Angles(0,0,math.rad(side*35)),j%2==0 and "forest" or "sage",curtain)
		end
	end
end
for _,x in {-54,-38} do local glow=part("FairyGlow",V(.1,.1,.1),V(x,9.5,-130),"golden",curtain); glow.Transparency=1; pointLight(glow,.18,11,"golden") end
-- Ivy continues a short way around the neighboring wall as in the photograph.
for i=0,9 do
	local z=-129+i*1.5
	rod("SideVine",V(-59.05,12.6,z),V(-59.05,11.7-(i%3)*.35,z+.25),.035,"forest",curtain)
	for j=0,2 do ellipsoid("SideIvyLeaf",V(.08,.65,.46),CF(-58.95,12.45-j*.4,z+j*.16)*CFrame.Angles(math.rad(25),0,0),"sage",curtain) end
end

-- A shallow open closet display belongs to this same room; it is not another interior.
local closet=group("ClosetRecess",room)
closet:SetAttribute("IsAdditionalRoom",false)
part("RecessShadow",V(13.5,11.5,.18),V(-23.3,6.5,-131.3),"ink",closet)
for _,x in {-30.3,-16.3} do part("ClosetJamb",V(.55,12.2,3.2),V(x,6.45,-129.85),"cream",closet,Enum.Material.Wood,true) end
part("ClosetHeader",V(14.55,.65,3.2),V(-23.3,12.53,-129.85),"cream",closet,Enum.Material.Wood,true)
part("UpperShelf",V(13.4,.24,2.7),V(-23.3,10.75,-129.9),"cream",closet,Enum.Material.Wood)
rod("HangingRail",V(-29.65,9.75,-129.6),V(-16.9,9.75,-129.6),.11,"wood",closet,Enum.Material.Metal)
for i,token in {"forest","cream","sage","blossom","wood","cream"} do
	local x=-28.4+(i-1)*2.05
	rod("HangerLeft",V(x-.7,9.18,-129.65),V(x,9.65,-129.65),.055,"wood",closet)
	rod("HangerRight",V(x,9.65,-129.65),V(x+.7,9.18,-129.65),.055,"wood",closet)
	part("HangingGarment",V(1.65,5,.44),CF(x,6.6,-129.6)*CFrame.Angles(0,0,math.rad((i%3-1)*3)),token,closet,Enum.Material.Fabric)
	part("GarmentFold",V(.055,4.1,.065),V(x+.31,6.4,-129.34),token=="forest" and "sage" or "cream",closet,Enum.Material.Fabric)
end
for _,x in {-26.7,-20.1} do
	part("LinenBasket",V(4.5,1.55,2.3),V(x,11.7,-129.8),"wood",closet,Enum.Material.Wood)
	part("BasketLabel",V(1.1,.45,.035),V(x,11.68,-128.63),"cream",closet)
end
part("ToteBag",V(2.6,2.8,.65),V(-16.7,6.1,-128),"forest",closet,Enum.Material.Fabric)
for _,x in {-17.35,-16.1} do rod("ToteHandle",V(x,7.4,-128),V(x,8.25,-128),.08,"cream",closet) end
rod("ToteHandleTop",V(-17.35,8.25,-128),V(-16.1,8.25,-128),.08,"cream",closet)

local bedside=group("BedsideDrawer",room)
part("Cabinet",V(4.6,3.8,4.6),V(-30.3,2.3,-123.7),"cream",bedside,Enum.Material.Wood,true)
part("CabinetTop",V(4.9,.25,4.9),V(-30.3,4.34,-123.7),"cream",bedside,Enum.Material.Wood)
for _,y in {1.15,2.3,3.45} do drawerFront(bedside,CF(-30.3,y,-121.34),4.3,1.05) end
local cup=group("GreenTumbler",bedside)
cylinder("Cup",V(1.6,.82,.82),CF(-30.35,5.27,-123.3)*CFrame.Angles(0,0,math.pi/2),"sage",cup)
cylinder("Lid",V(.13,.92,.92),CF(-30.35,6.1,-123.3)*CFrame.Angles(0,0,math.pi/2),"cream",cup)
rod("Straw",V(-30.45,6.16,-123.3),V(-30.55,6.86,-123.3),.07,"cream",cup)
rod("CupHandleSide",V(-29.6,5.1,-123.3),V(-29.6,5.94,-123.3),.12,"sage",cup)
for _,y in {5.1,5.94} do rod("CupHandleJoin",V(-30, y,-123.3),V(-29.6,y,-123.3),.12,"sage",cup) end
part("EReader",V(1.5,.12,2.1),CF(-29.2,4.53,-124.2)*CFrame.Angles(0,math.rad(-9),0),"sage",bedside)
part("EReaderScreen",V(1.15,.015,1.5),CF(-29.2,4.6,-124.2)*CFrame.Angles(0,math.rad(-9),0),"cream",bedside)

-- Desk wall opposes the bed. Local furniture faces +Z, rotated toward the room.
local desk=group("StudyDesk",room)
local df=CF(-45,0,-89.25)*CFrame.Angles(0,math.pi,0)
local function dp(name,size,pos,token,material,solid) return part(name,size,df*CF(pos),token,desk,material,solid) end
dp("Desktop",V(18,.42,6.5),V(0,4.8,0),"cream",Enum.Material.Wood,true)
dp("DrawerPedestal",V(4,4.25,5.8),V(6.3,2.45,0),"cream",Enum.Material.Wood,true)
for i=0,4 do drawerFront(desk,df*CF(6.3,.83+i*.8,3.04),3.7,.69) end
for _,z in {-2.5,2.5} do dp("DeskLeg",V(.35,4.2,.35),V(-8,2.48,z),"cream",Enum.Material.Metal,true) end
dp("MonitorFoot",V(3,.14,1.7),V(-1,5.08,-1.4),"cream",nil)
dp("MonitorStand",V(.5,1.6,.4),V(-1,5.9,-1.68),"cream",nil)
dp("MonitorBezel",V(7.8,4.5,.34),V(-1,8.3,-1.75),"cream",nil)
dp("MonitorScreen",V(7.3,4.02,.03),V(-1,8.3,-1.56),"sage",nil)
-- Abstract cozy desktop scene; no third-party screen image or invented personal message.
dp("ScreenHorizon",V(7.1,.85,.025),V(-1,7.35,-1.53),"forest",nil)
ellipsoid("ScreenSun",V(.74,.74,.025),df*CF(1.25,9.15,-1.52),"golden",desk)
for i=0,2 do dp("ScreenWindow",V(1.36,.11,.026),V(-3.45,8.2+i*.5,-1.51),"cream",nil) end
dp("KeyboardBase",V(5.1,.18,1.7),V(-1.05,5.11,1.35),"cream",nil)
for row=0,3 do for col=0,11 do dp("Key",V(.32,.065,.27),V(-3.17+col*.38,5.232,.86+row*.34),row==3 and col>3 and col<8 and "sage" or "cream",nil) end end
dp("MouseMat",V(2.8,.045,2.3),V(-5.8,5.04,1),"sage",Enum.Material.Fabric)
ellipsoid("Mouse",V(.8,.38,1.18),df*CF(-5.8,5.25,.96),"cream",desk)
dp("MouseButtonSplit",V(.035,.03,.44),V(-5.8,5.443,.67),"wood",nil)
-- Open miniature and stationery are the photo's layered desktop display.
local mini=group("MiniatureCraftDisplay",desk)
local mf=df*CF(5.6,5.1,-1.5)
part("MiniatureBase",V(4.4,.18,2.6),mf,"wood",mini,Enum.Material.Wood)
part("TinyRoomBack",V(4.4,2.75,.13),mf*CF(0,1.4,-1.22),"cream",mini)
part("TinyRoomSide",V(.13,2.75,2.6),mf*CF(2.12,1.4,0),"cream",mini)
part("TinyShelf",V(2.6,.15,.7),mf*CF(.3,1.48,-.8),"sage",mini)
for i=0,5 do book(mini,mf*CF(-.7+i*.34,1.91,-.72),.25,.75,.35,({"forest","brick","sage","golden","cream","blossom"})[i+1]) end
part("TinyArmchair",V(1.3,.85,1.1),mf*CF(-1.1,.58,.33),"sage",mini)
part("TinyArmchairBack",V(1.3,1.3,.25),mf*CF(-1.1,.98,-.17),"sage",mini)
plant(mini,(mf*CF(1.2,.18,.4)).Position,.45)
local pencilOrigin=(df*CF(7.3,5.1,1.3)).Position
cylinder("PencilPot",V(1,.8,.8),CF(pencilOrigin+V(0,.5,0))*CFrame.Angles(0,0,math.pi/2),"cream",desk)
for i=0,6 do
	local a=i*2.4; local pos=pencilOrigin+V(math.cos(a)*.23,.7,math.sin(a)*.23)
	rod("ColoringPencil",pos,pos+V(.1*(i%2),1.15,0),.065,({"forest","sage","brick","golden","blossom","wood","cream"})[i+1],desk)
end
dp("CraftPaperStack",V(2.5,.17,2),V(2.15,5.08,1.1),"cream",nil)
for _,x in {1.6,2.1,2.6} do dp("ColoringStroke",V(.11,.012,1.1),V(x,5.173,1.1),x==2.1 and "blossom" or "sage",nil) end

-- White/black rolling chair with arm rests and hanging headphones.
local chair=group("RollingChair",room)
local ch=CF(-44,0,-98.3)*CFrame.Angles(0,math.pi,0)
local function cp(name,size,pos,token,material,solid) return part(name,size,ch*CF(pos),token,chair,material,solid) end
cp("Seat",V(4.6,.52,4.4),V(0,2.78,0),"ink",Enum.Material.Fabric,true)
ellipsoid("SeatCushion",V(4.65,.65,4.5),ch*CF(0,3.02,0),"ink",chair,Enum.Material.Fabric)
cp("SeatPost",V(.55,1.7,.55),V(0,1.6,0),"wood",Enum.Material.Metal)
cp("BackFrame",V(4.6,5,.48),V(0,5.45,-1.85),"cream",nil,true)
cp("BackMesh",V(4.03,4.45,.15),V(0,5.47,-1.52),"ink",Enum.Material.Fabric)
for i=0,7 do cp("MeshRib",V(3.83,.06,.09),V(0,3.7+i*.49,-1.42),"forest",nil) end
for _,side in {-1,1} do
	cp("ArmStem",V(.2,1.8,.2),V(side*2.48,3.45,.2),"cream",Enum.Material.Metal)
	cp("ArmRest",V(.8,.27,2.8),V(side*2.48,4.38,.3),"ink",nil)
end
for i=0,4 do
	local a=i*math.pi*2/5; local p=V(math.cos(a)*2.7,.75,math.sin(a)*2.7)
	rod("ChairSpoke",(ch*CF(0,.95,0)).Position,(ch*CF(p)).Position,.22,"cream",chair,Enum.Material.Metal)
	cylinder("Caster",V(.43,.67,.67),ch*CF(p+V(0,-.18,0)),"ink",chair)
end
local hp=group("Headphones",chair)
for i=0,10 do
	local a=math.pi*i/10
	local b=math.pi*(i+1)/10
	if i<10 then rod("Headband",(ch*CF(2.9,5+math.sin(a)*1.1,math.cos(a)*.93)).Position,(ch*CF(2.9,5+math.sin(b)*1.1,math.cos(b)*.93)).Position,.16,"cream",hp) end
end
for _,side in {-1,1} do ellipsoid("EarCup",V(.65,1.1,.74),ch*CF(2.9,4.94,side*.9),"ink",hp) end

local shelf=group("FilledBookcase",room)
local sf=CF(-31.2,0,-86.6)*CFrame.Angles(0,math.pi,0)
local function sp(name,size,pos,token,material,solid) return part(name,size,sf*CF(pos),token,shelf,material,solid) end
sp("BookcaseBack",V(8.4,11.3,.25),V(0,6.17,-1.5),"cream",Enum.Material.Wood,true)
for _,x in {-4.15,4.15} do sp("BookcaseSide",V(.25,11.6,3.2),V(x,6.32,0),"cream",Enum.Material.Wood,true) end
for _,y in {.7,3.25,5.5,7.75,10,12} do sp("Shelf",V(8.6,.2,3.35),V(0,y,0),"cream",Enum.Material.Wood,true) end
for _,y in {1.36,2.47} do drawerFront(shelf,sf*CF(0,y,1.76),7.96,1) end
for i=0,9 do
	local w=.48+(i%3)*.05; local h=1.4+(i%4)*.16
	book(shelf,sf*CF(-3.5+i*.7,5.61+h/2,.58),w,h,1.55,({"forest","ink","brick","golden","sage","cream"})[i%6+1],i==9 and -8 or 0)
end
for i=0,4 do
	local p=(sf*CF(-3.15+i*1.6,10.12,.45)).Position
	local f=smallFigure(shelf,p,({"cream","wood","blossom","sage","golden"})[i+1],i%2==0)
	f:PivotTo(sf*CF(-3.15+i*1.6,10.12,.45)*CFrame.new(0,.65,0))
end
plant(shelf,(sf*CF(-2.75,7.86,.2)).Position,.95)
plant(shelf,(sf*CF(2.95,12.12,0)).Position,1.0)
for i=0,4 do sp("CraftPaintJar",V(.6,.8,.6),V(-.6+i*.72,8.3,.62),({"blossom","sage","golden","cream","forest"})[i+1]) end
sp("DisplayPlinth",V(2.9,.23,1.85),V(-2.35,3.48,.3),"wood")
sp("MiniatureFacade",V(1.65,1.48,.18),V(-2.35,4.28,-.12),"sage")
sp("MiniatureDoor",V(.54,.95,.06),V(-2.32,4.02,.015),"cream")
for _,x in {-2.9,-1.8} do sp("MiniatureWindow",V(.32,.38,.06),V(x,4.54,.015),"golden") end
for i=0,3 do
	sp("HorizontalBook",V(2.8,.24,1.75),V(2.03,3.49+i*.26,.22),({"forest","blossom","sage","cream"})[i+1])
end
local trailing=group("ShelfTrailingPlant",shelf)
for i=0,6 do
	local p=(sf*CF(3.68,12.6-i*.5,1.42)).Position
	if i>0 then rod("TrailingStem",p+V(0,.5,0),p,.04,"forest",trailing) end
	ellipsoid("Leaf",V(.55,.65,.15),CF(p)*CFrame.Angles(0,0,math.rad(i%2==0 and 25 or -25)),"sage",trailing)
end

-- A wheeled three-tier cart and a small white fan sit near the TV wall.
local cart=group("StorageCart",room)
for _,x in {-3.8,1.4} do for _,z in {-119.8,-117} do
	part("CartUpright",V(.16,5,.16),V(x,3.14,z),"cream",cart,Enum.Material.Metal)
	cylinder("CartCaster",V(.25,.6,.6),CF(x,.77,z),"ink",cart)
end end
for _,y in {1.14,3.14,5.14} do
	part("CartTray",V(5.65,.2,3.3),V(-1.2,y,-118.4),"cream",cart,Enum.Material.Metal)
	for _,z in {-120.05,-116.75} do part("CartLip",V(5.65,.65,.13),V(-1.2,y+.35,z),"cream",cart,Enum.Material.Metal) end
end
for i=0,4 do cylinder("CraftBottle",V(.7+(i%2)*.25,.48,.48),CF(-3.2+i*.92,3.8,-118.4)*CFrame.Angles(0,0,math.pi/2),({"blossom","sage","cream","wood","golden"})[i+1],cart) end
for i=0,3 do part("StorageBox",V(.95,1.05,2),V(-3.08+i*1.23,1.8,-118.35),i%2==0 and "sage" or "cream",cart) end
plant(cart,V(.55,5.25,-118.25),.75)
for i=0,2 do part("FoldedCraftCloth",V(2.3,.24,2.3),V(-2.4,5.4+i*.25,-118.35),i==1 and "blossom" or "cream",cart,Enum.Material.Fabric) end
local fan=group("SmallFanAndBin",room)
cylinder("Bin",V(1.9,1.6,1.6),CF(.7,1.36,-114.5)*CFrame.Angles(0,0,math.pi/2),"cream",fan)
cylinder("BinLid",V(.2,1.67,1.67),CF(.7,2.41,-114.5)*CFrame.Angles(0,0,math.pi/2),"ink",fan)
part("FanBase",V(1.8,.24,1.5),V(.3,.52,-111.3),"cream",fan)
part("FanStem",V(.35,1.1,.35),V(.3,1.12,-111.3),"cream",fan)
cylinder("FanHousing",V(.65,2.1,2.1),CF(.3,2.4,-111.3)*CFrame.Angles(0,math.pi/2,0),"cream",fan)
cylinder("FanGrille",V(.035,1.72,1.72),CF(.3,2.4,-110.94)*CFrame.Angles(0,math.pi/2,0),"ink",fan)
for i=0,3 do
	local a=i*math.pi/2
	rod("FanSpoke",V(.3,2.4,-110.9),V(.3+math.cos(a)*.8,2.4+math.sin(a)*.8,-110.9),.055,"cream",fan)
end
ellipsoid("FanHub",V(.34,.34,.13),V(.3,2.4,-110.83),"cream",fan)

-- Wall TV, a simple reflective mirror and a hand-built botanical print.
local wallDetails=group("WallDetails",room)
local tvf=CF(3.29,8.6,-111)*CFrame.Angles(0,-math.pi/2,0)
part("TVBezel",V(11.8,6.7,.35),tvf,"ink",wallDetails)
part("TVScreen",V(11.24,6.14,.025),tvf*CF(0,0,.19),"ink",wallDetails,Enum.Material.Glass).Reflectance=.14
for i=0,2 do part("SoftScreenReflection",V(2.1,.08,.015),tvf*CF(2.7,-1.3+i*.24,.21),"forest",wallDetails) end
local mirror=CF(3.22,7.6,-94.1)*CFrame.Angles(0,-math.pi/2,0)
part("MirrorFrame",V(5,7,.33),mirror,"cream",wallDetails,Enum.Material.Wood)
local glass=part("MirrorGlass",V(4.2,6.2,.05),mirror*CF(0,0,.2),"sage",wallDetails,Enum.Material.Glass)
glass.Reflectance=.48
local print=CF(3.23,8,-101)*CFrame.Angles(0,-math.pi/2,0)
part("BotanicalFrame",V(5.3,7,.22),print,"wood",wallDetails,Enum.Material.Wood)
part("BotanicalPaper",V(4.93,6.63,.03),print*CF(0,0,.14),"cream",wallDetails)
for row=0,2 do for col=0,2 do
	local x=-1.52+col*1.51; local y=-2.1+row*1.97
	rod("PrintedStem",(print*CF(x,y-.48,.18)).Position,(print*CF(x,y+.48,.18)).Position,.03,"forest",wallDetails)
	for j=0,2 do for _,s in {-1,1} do
		ellipsoid("BotanicalLeaf",V(.32,.62,.014),print*CF(x+s*.16,y-.3+j*.25,.2)*CFrame.Angles(0,0,math.rad(s*36)),row%2==0 and "forest" or "sage",wallDetails)
	end end
end end
-- Wall socket and restrained cable detail below the television.
part("SocketPlate",V(.13,.7,.5),V(3.27,1.8,-109.2),"cream",wallDetails)
rod("TVCable",V(3.05,5.2,-109.2),V(3.05,1.8,-109.2),.05,"ink",wallDetails)

-- Pleated white curtains and horizontal blinds frame both original front windows.
local windows=group("CurtainsAndBlinds",room)
for _,range in {{-52,-38},{-10,0}} do
	local mid=(range[1]+range[2])/2; local width=range[2]-range[1]
	rod("CurtainRod",V(range[1]-1.2,12.35,-85.08),V(range[2]+1.2,12.35,-85.08),.13,"wood",windows)
	for i=0,13 do part("BlindSlat",V(width-.4,.32,.14),CF(mid,4.3+i*.49,-84.88)*CFrame.Angles(math.rad(13),0,0),"cream",windows) end
	for _,side in {-1,1} do
		local x=mid+side*(width/2+.1)
		for fold=0,4 do
			local panel=part("CurtainPleat",V(.42,10.8,.22),V(x+side*(fold-2)*.35,6.65,-85.28+(fold%2)*.12),"cream",windows,Enum.Material.Fabric)
			panel.Transparency=fold%2==0 and .035 or 0
		end
		for i=0,3 do ellipsoid("CurtainRing",V(.11,.34,.34),V(x+(i-1.5)*.37,12.28,-85.08),"cream",windows) end
	end
end

local dresser=group("LowDresserAndDogBed",room)
part("DresserBody",V(4.8,4.45,11.8),V(-56.4,2.58,-96.2),"cream",dresser,Enum.Material.Wood,true)
part("DresserTop",V(5.1,.3,12.1),V(-56.4,4.96,-96.2),"cream",dresser,Enum.Material.Wood)
for _,z in {-99.3,-93.1} do for _,y in {1.4,2.8,4.1} do
	drawerFront(dresser,CF(-53.88,y,z)*CFrame.Angles(0,math.pi/2,0),5.7,1.12)
end end
plant(dresser,V(-56.5,5.11,-99.7),1.15)
for i=0,2 do part("FoldedLinen",V(3.3,.3,3.4),V(-56.4,5.31+i*.29,-92.7),i==1 and "sage" or "cream",dresser,Enum.Material.Fabric) end
local dogbed=group("JasperBed",room)
part("DogBedBase",V(7,.65,5.6),V(-5,.79,-92),"cream",dogbed,Enum.Material.Fabric)
cushion("DogBedCushion",V(6.2,.7,4.9),V(-5,1.13,-92),"cream",dogbed)
for _,x in {-8.3,-1.7} do cushion("DogBedBolster",V(1,1.35,5.9),V(x,1.26,-92),"cream",dogbed) end
for _,z in {-94.45,-89.55} do cushion("DogBedBolster",V(6.8,1.35,1),V(-5,1.26,z),"cream",dogbed) end
local toy=smallFigure(dogbed,V(-4.8,1.28,-92.7),"wood",true); toy.Name="RabbitToy"
-- Slippers are small, non-colliding accents at the foot of the bed.
for _,x in {-36.8,-35.1} do
	ellipsoid("SlipperSole",V(1.1,.28,2),CF(x,.58,-99.6)*CFrame.Angles(0,math.rad(-9),0),"sage",room)
	ellipsoid("SlipperUpper",V(1.15,.62,1.1),V(x,.82,-100.02),"sage",room,Enum.Material.Fabric)
	ellipsoid("SlipperOpening",V(.67,.065,.53),V(x,1.04,-99.68),"ink",room)
end

local total=0
for _,instance in room:GetDescendants() do
	if instance:IsA("BasePart") then
		total+=1
		assert(instance.Anchored and instance:GetAttribute("PaletteToken"),"Unanchored or untagged bedroom part")
	end
end
room:SetAttribute("AuthoredPartCount",total)
-- Preserve the user's current cottage position rather than resetting it to Draft 01 coordinates.
room:PivotTo(CF(placementOffset)*room:GetPivot())
room:SetAttribute("PlacementOffset",placementOffset)
game:GetService("ChangeHistoryService"):SetWaypoint("Bedroom reference interior draft 02")
return string.format("Bedroom built: %d anchored palette-tagged parts; one room; original door and shell retained.",total)
