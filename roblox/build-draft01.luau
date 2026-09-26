-- Run once in Studio Edit mode after prepare-assets.luau.
-- All new world geometry is grouped under CozyWorld_Draft01.
local W = workspace
local SS = game:GetService("ServerStorage")
local L = game:GetService("Lighting")
local assets = SS:WaitForChild("CozyDraftAssets"):WaitForChild("Reviewed")
assert(not W:FindFirstChild("CozyWorld_Draft01"), "Inspect existing draft before running again")
local V, CF, RGB = Vector3.new, CFrame.new, Color3.fromRGB
local palette = {
	grass=RGB(126,151,97), cream=RGB(241,227,197), green=RGB(62,91,65),
	sage=RGB(141,157,117), wood=RGB(155,110,72), darkwood=RGB(113,79,53),
	paving=RGB(210,201,182), edge=RGB(188,182,162), pink=RGB(228,174,191),
	glass=RGB(199,217,204), flower=RGB(248,230,214), leaf=RGB(91,127,72),
}
local function group(name,parent)
	local m=Instance.new("Model");m.Name=name;m.Parent=parent;return m
end
local root=group("CozyWorld_Draft01",W)
root:SetAttribute("DraftVersion","01")
root:SetAttribute("Scope","Arrival, blossom approach and cottage; surrounding destinations reserved")
local ground=group("Landscape",root)
local paths=group("Paths",root)
local home=group("Home",root)
local arrival=group("Arrival",root)
local planting=group("QuadPlanting",root)
local context=group("SurroundingContext",root)
local markers=Instance.new("Folder");markers.Name="ConnectionMarkers";markers.Parent=root
local function part(name,size,pos,color,material,parent,collide)
	local p=Instance.new("Part");p.Name=name;p.Size=size;p.CFrame=typeof(pos)=="CFrame" and pos or CF(pos)
	p.Color=color;p.Material=material or Enum.Material.SmoothPlastic;p.Anchored=true
	p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth
	p.CanCollide=collide~=false;p.CanTouch=false;p.Parent=parent;return p
end
local function ball(name,size,pos,color,parent)
	local p=part(name,size,pos,color,Enum.Material.SmoothPlastic,parent,false);p.Shape=Enum.PartType.Ball;return p
end
local function bar(name,a,b,width,height,color,parent)
	local p=part(name,V(width,height,(b-a).Magnitude),CF((a+b)/2,b),color,Enum.Material.SmoothPlastic,parent,false);return p
end
local function marker(name,x,z,width)
	local p=part(name,V(width,.1,1),V(x,.35,z),palette.green,nil,markers,false)
	p.Transparency=1;p.CanQuery=false;p:SetAttribute("ClearWidth",width)
end
local function placeAsset(kind,name,pos,yaw,scale,parent)
	local m=assets[kind]:Clone();m.Name=name;m.Parent=parent
	if scale then m:ScaleTo(m:GetScale()*scale) end
	m:PivotTo(CF(pos)*CFrame.Angles(0,math.rad(yaw or 0),0));return m
end
local function disk(name,x,z,r,color,parent,y)
	local p=part(name,V(.2,r*2,r*2),CF(x,y or .14,z)*CFrame.Angles(0,0,math.pi/2),color,Enum.Material.Concrete,parent)
	p.Shape=Enum.PartType.Cylinder;return p
end
local function path(name,points,width)
	local m=group(name,paths)
	for i=1,#points-1 do
		local a,b=V(points[i][1],.14,points[i][2]),V(points[i+1][1],.14,points[i+1][2])
		local len=(b-a).Magnitude; local cf=CF((a+b)/2,b)
		part("Paving",V(width,.2,len+.1),cf,palette.paving,Enum.Material.Concrete,m)
		for side=-1,1,2 do part("FlushEdge",V(.35,.21,len),cf*CF(side*(width/2-.2),0,0),palette.edge,Enum.Material.Concrete,m) end
		local n=math.floor(len/8)
		for j=1,n do part("PaverJoint",V(width-.6,.05,.1),cf*CF(0,.15,-len/2+j*len/(n+1)),palette.edge,nil,m,false) end
	end
	for i=2,#points-1 do disk("Junction",points[i][1],points[i][2],width/2,palette.paving,m,.145) end
end
local function shrub(parent,x,z,size,y)
	for i=-1,1 do ball("Shrub",V(size,size*.62,size*.85),V(x+i*size*.35,(y or .1)+size*.22,z+math.abs(i)*.35),i==0 and palette.leaf or palette.sage,parent) end
end
local function flowers(parent,x,z,y,count)
	for i=1,count do
		local angle=i*2.4;local radius=.4+math.sqrt(i)*.36
		local c=V(x+math.cos(angle)*radius,y+.18+(.1*(i%3)),z+math.sin(angle)*radius)
		for j=0,4 do local a=j*math.pi*2/5;ball("Petal",V(.48,.18,.48),c+V(math.cos(a)*.27,0,math.sin(a)*.27),i%3==0 and palette.pink or palette.flower,parent) end
		ball("FlowerCenter",V(.24,.19,.24),c+V(0,.03,0),RGB(225,191,103),parent)
	end
end
local function planter(parent,x,z,size)
	local m=group("WoodPlanter",parent)
	part("Box",V(size,2.4,size),V(x,1.3,z),palette.wood,Enum.Material.WoodPlanks,m)
	part("Soil",V(size-.45,.2,size-.45),V(x,2.57,z),RGB(91,74,51),Enum.Material.Ground,m,false)
	for _,side in {-1,1} do
		part("Rim",V(size+.25,.3,.3),V(x,2.65,z+side*size/2),palette.darkwood,Enum.Material.Wood,m,false)
		part("Rim",V(.3,.3,size+.25),V(x+side*size/2,2.65,z),palette.darkwood,Enum.Material.Wood,m,false)
	end
	shrub(m,x,z,size*.65,2.5);flowers(m,x,z,3.65,5)
	return m
end

-- Continuous ground with paths overlaid, preserving the approved layout.
part("QuadGround",V(360,.4,336),V(0,-.18,8),palette.grass,Enum.Material.Grass,ground)
local base=W:FindFirstChild("Baseplate")
if base then base.Position=V(0,-8.6,0);base.Color=palette.grass;base.Material=Enum.Material.Grass;for _,v in base:GetChildren() do if v:IsA("Texture") then v.Transparency=1 end end end
path("MainPromenade",{{8,138},{8,122},{8,94},{8,26},{6,-20},{8,-56},{8,-72},{-20,-76},{-20,-84}},12)
path("WestUpper",{{-104,-100},{-88,-66},{-72,-48},{-38,-46},{8,-40}},8)
path("WestMiddle",{{-104,28},{-72,32},{-38,42},{-8,42},{8,32}},8)
path("WestLower",{{-104,108},{-66,116},{-20,120},{8,114}},8)
path("DogParkUpper",{{8,-36},{44,-48},{62,-70},{76,-92}},8)
path("DogParkLower",{{8,0},{38,-8},{56,-28},{76,-52}},8)
path("BirthdayUpper",{{8,40},{46,44},{62,22},{80,20}},8)
path("BirthdayLower",{{8,114},{44,114},{62,98},{80,86}},8)
path("WestPromenade",{{-104,-144},{-104,156}},12)
marker("Arrival_Main",8,122,12);marker("House_Approach",8,-56,12);marker("House_Door",-20,-84,8)
marker("DogPark_Upper",76,-92,8);marker("DogPark_Lower",76,-52,8)
marker("Birthday_Upper",80,20,8);marker("Birthday_Lower",80,86,8)

-- Arrival pad and readable two-sided birthday sign.
part("GroupPlaza",V(56,.24,32),V(-8,.12,154),palette.paving,Enum.Material.Concrete,arrival)
for x=-32,16,8 do part("PaverJoint",V(.1,.05,32),V(x,.29,154),palette.edge,nil,arrival,false) end
for z=142,166,8 do part("PaverJoint",V(56,.05,.1),V(-8,.29,z),palette.edge,nil,arrival,false) end
local sign=group("BirthdaySign",arrival)
for _,x in {-62,-38} do
	part("WoodPost",V(.85,9,.85),V(x,4.6,148),palette.darkwood,Enum.Material.Wood,sign)
	ball("PostCap",V(1.2,.6,1.2),V(x,9.1,148),palette.wood,sign)
end
part("GreenFrame",V(24,7.5,.8),V(-50,6,148),palette.green,nil,sign)
for _,s in {-1,1} do
	local face=part("CreamFace",V(22.7,6.3,.1),V(-50,6,148+s*.45),palette.cream,nil,sign,false)
	local gui=Instance.new("SurfaceGui");gui.Name="BirthdayText";gui.Face=s==1 and Enum.NormalId.Back or Enum.NormalId.Front;gui.CanvasSize=Vector2.new(900,270);gui.LightInfluence=.35;gui.Parent=face
	local label=Instance.new("TextLabel");label.Size=UDim2.fromScale(.96,.92);label.Position=UDim2.fromScale(.02,.04);label.BackgroundTransparency=1;label.Text="24th\nBirthday";label.TextScaled=true;label.Font=Enum.Font.GothamBold;label.TextColor3=palette.green;label.Parent=gui
end
for i=-4,3 do
	local x1,x2=-50+i*3,-50+(i+1)*3
	local y1,y2=10.4-1.1*(i/4)^2,10.4-1.1*((i+1)/4)^2
	bar("CurvedCrown",V(x1,y1,148),V(x2,y2,148),.65,.55,palette.green,sign)
end
planter(arrival,-65,149,5);planter(arrival,-35,149,5)
placeAsset("Bench","ArrivalBench",V(-72,.05,151),180,1.1,arrival)
local spawn=Instance.new("SpawnLocation");spawn.Name="ArrivalSpawn";spawn.Size=V(30,.1,12);spawn.CFrame=CF(6,.31,158);spawn.Anchored=true;spawn.CanCollide=false;spawn.Transparency=1;spawn.Neutral=true;spawn.Duration=0;spawn.Parent=arrival

-- Cottage shell with actual window/door openings and an enterable interior.
part("Floor",V(64,.42,48),V(-28,.12,-108),palette.wood,Enum.Material.WoodPlanks,home)
part("WestWall",V(1,14,48),V(-60,7.34,-108),palette.cream,Enum.Material.SmoothPlastic,home)
part("EastWall",V(1,14,48),V(4,7.34,-108),palette.cream,Enum.Material.SmoothPlastic,home)
part("NorthWall",V(64,14,1),V(-28,7.34,-132),palette.cream,Enum.Material.SmoothPlastic,home)
local function frontWall(a,b,low,high)
	part("FrontWall",V(b-a,high-low,1),V((a+b)/2,(low+high)/2,-84),palette.cream,nil,home)
end
-- Windows: [-52,-38], [-10,0]. Door: [-24,-16].
for _,range in {{-60,-52},{-38,-24},{-16,-10},{0,4}} do frontWall(range[1],range[2],.34,14.34) end
frontWall(-52,-38,.34,4);frontWall(-52,-38,11.5,14.34)
frontWall(-10,0,.34,4);frontWall(-10,0,11.5,14.34)
frontWall(-24,-16,12.34,14.34)
local function window(a,b)
	local mid=(a+b)/2
	local glass=part("WindowGlass",V(b-a,7.5,.15),V(mid,7.75,-83.6),palette.glass,Enum.Material.Glass,home)
	glass.Transparency=.48;glass.Reflectance=.08
	for _,x in {a,b,mid} do part("SageMullion",V(.35,8,.45),V(x,7.75,-83.45),palette.sage,nil,home) end
	for _,y in {3.85,8,11.65} do part("SageFrame",V(b-a+.6,.35,.5),V(mid,y,-83.45),palette.sage,nil,home) end
	part("WoodSill",V(b-a+1,.35,1.2),V(mid,3.65,-83.35),palette.wood,Enum.Material.Wood,home)
end
window(-52,-38);window(-10,0)
for _,x in {-24.3,-15.7} do part("DoorFrame",V(.6,12.4,1.3),V(x,6.35,-83.7),palette.sage,nil,home) end
part("DoorLintel",V(9.2,.65,1.3),V(-20,12.65,-83.7),palette.sage,nil,home)
local door=group("FrontDoor",home)
part("DoorPanel",V(7.7,11.8,.5),V(-20,6.3,-84),palette.darkwood,Enum.Material.Wood,door)
for _,x in {-21.9,-18.1} do
	part("RaisedPanel",V(2.9,5,.18),V(x,3.45,-83.66),palette.wood,Enum.Material.Wood,door,false)
	part("DoorGlass",V(2.7,3.6,.2),V(x,9,-83.65),palette.glass,Enum.Material.Glass,door,false).Transparency=.22
end
ball("DoorHandle",V(.36,.36,.65),V(-17.15,6,-83.4),RGB(206,166,91),door)
door.WorldPivot=CF(-23.85,6.3,-84)
local promptPart=part("DoorInteraction",V(1,1,1),V(-20,5.4,-82.5),palette.green,nil,home,false)
promptPart.Transparency=1;promptPart.CanQuery=false
local prompt=Instance.new("ProximityPrompt");prompt.Name="DoorPrompt";prompt.ActionText="Open";prompt.ObjectText="Front door";prompt.MaxActivationDistance=12;prompt.RequiresLineOfSight=false;prompt.KeyboardKeyCode=Enum.KeyCode.E;prompt.Parent=promptPart
part("PorchDeck",V(56,.42,16),V(-28,.12,-76),palette.wood,Enum.Material.WoodPlanks,home)
for _,x in {-54,-2} do
	part("PorchPost",V(.9,12.5,.9),V(x,6.6,-69),palette.cream,nil,home)
	part("PostBase",V(1.6,1,1.6),V(x,.83,-69),palette.sage,nil,home)
end
part("PorchBeam",V(58,.9,1.2),V(-28,12.9,-69),palette.cream,nil,home)
part("PorchRoof",V(60,.7,18),CF(-28,13.7,-76)*CFrame.Angles(math.rad(4),0,0),palette.green,Enum.Material.Slate,home)
local slope=math.atan(10/26)
for _,s in {-1,1} do
	part("MainRoof",V(68,.7,math.sqrt(26^2+10^2)),CF(-28,19.65,-108+s*13)*CFrame.Angles(s*slope,0,0),palette.green,Enum.Material.Slate,home)
	part("EaveFascia",V(69,.7,.7),V(-28,14.4,-108+s*26),palette.sage,nil,home)
end
part("RoofRidge",V(69,.55,.9),V(-28,24.7,-108),palette.green,nil,home)
for _,x in {-60,4} do for z=-25,25,2 do
	local h=10*(1-math.abs(z)/26)
	part("RoofEndInfill",V(1,h,2.01),V(x,14.34+h/2,-108+z),palette.cream,nil,home)
end end
-- A small front-gable outline gives the porch its own silhouette.
bar("PorchGableLeft",V(-42,13.9,-67.8),V(-28,18.3,-67.8),.9,.7,palette.cream,home)
bar("PorchGableRight",V(-28,18.3,-67.8),V(-14,13.9,-67.8),.9,.7,palette.cream,home)
for i=-13,13 do
	local h=4.1*(1-math.abs(i)/14)
	part("GableInfill",V(1.03,math.max(.1,h),.45),V(-28+i,14+h/2,-68),palette.cream,nil,home,false)
end
for _,x in {-26.5,-13.5} do
	local mount=part("WallLantern",V(.75,1.5,.65),V(x,9.2,-82.8),RGB(244,216,160),Enum.Material.Neon,home,false)
	local light=Instance.new("PointLight");light.Range=11;light.Brightness=.5;light.Color=RGB(255,220,170);light.Parent=mount
	part("LanternCap",V(1,.25,.9),V(x,10.05,-82.8),palette.green,nil,home,false)
end
placeAsset("Bench","PorchBench",V(-46,.34,-77),180,1,home)
planter(home,-32,-78,3.2);planter(home,-8,-78,3.2)
planter(home,-54,-65,4.5);planter(home,-2,-65,4.5)
-- A few furniture placeholders establish human scale without committing the interior design.
part("ReadingRug",V(15,.06,13),V(-11,.365,-119),palette.sage,Enum.Material.Fabric,home,false)
part("CraftTableTop",V(10,.5,5),V(-48,3.2,-109),palette.wood,Enum.Material.Wood,home)
for _,x in {-52,-44} do for _,z in {-111,-107} do part("TableLeg",V(.55,3,.55),V(x,1.8,z),palette.darkwood,Enum.Material.Wood,home) end end
local ceilingLight=part("InteriorLamp",V(2,.2,2),V(-28,13,-110),palette.cream,Enum.Material.Neon,home,false)
local il=Instance.new("PointLight");il.Color=RGB(255,226,180);il.Brightness=.7;il.Range=42;il.Parent=ceilingLight

-- Shared tree family and restrained planting, leaving the main sightline and activities open.
local trees={
	{-88,150,1.05,20},{43,158,1.02,140},{-71,110,.92,80},{40,112,.94,200},
	{-46,92,1.02,15},{40,66,.9,90},{-36,18,1.02,210},{37,17,.9,25},
	{-49,-17,1,155},{36,-24,.88,70},{-82,-22,1,10},{-89,-72,1.05,90},
	{-76,-123,1.05,20},{22,-128,1.03,140},{58,-124,1.03,110},
	{-91,57,1,190},{-90,3,.91,80},{-14,92,.77,130},{67,143,.9,35},
	{165,131,1.08,200},{164,-138,1.12,40},{-132,164,1.04,60},{-151,-151,1.1,120},
}
for i,t in trees do
	local m=placeAsset("Blossom","Cherry"..i,V(t[1],.04,t[2]),t[4],t[3],planting)
	local trunk=part("TrunkCollision",V(1.8,9,1.8),V(t[1],4.55,t[2]),palette.darkwood,nil,m)
	trunk.Transparency=1;trunk.CanQuery=false
	if i%3==0 then placeAsset("Petals","FallenPetals"..i,V(t[1]+2,.06,t[2]+2),t[4],.65,planting) end
end
for _,p in {{-70,138},{-35,135},{31,135},{-49,-63},{-67,-78},{17,-72},{-38,-4},{45,87},{-81,14},{-75,102},{55,-116}} do shrub(planting,p[1],p[2],4);flowers(planting,p[1]+2,p[2]+1,1.4,4) end
for i,p in {{-17,132},{22,88},{-5,11},{22,-54},{-112,66},{-112,-57}} do placeAsset("Lantern","PathLantern"..i,V(p[1],.03,p[2]),0,.84,planting) end
placeAsset("Bench","QuadBenchWest",V(-72,.05,4),90,1.1,planting)
placeAsset("Bench","QuadBenchEast",V(51,.05,78),-90,1.1,planting)

-- Neighboring destinations are architectural context for this first slice.
part("UDistrictStreet",V(24,.18,312),V(-122,.1,8),RGB(110,116,107),Enum.Material.Asphalt,context)
part("ShopSidewalk",V(10,.25,312),V(-139,.135,8),palette.paving,Enum.Material.Concrete,context)
for _,z in {-100,28,108} do for x=-132,-112,5 do part("Crossing",V(3,.03,7),V(x,.215,z),palette.cream,nil,context,false) end end
for i,z in {-96,0,96} do
	local m=group("StorefrontMassing"..i,context)
	local colors={RGB(173,125,104),RGB(211,194,160),RGB(151,164,134)}
	part("Facade",V(28,19,54),V(-160,9.55,z),colors[i],Enum.Material.Brick,m)
	part("Cornice",V(30,1.1,56),V(-160,19.6,z),palette.cream,nil,m)
	for _,dz in {-16,0,16} do
		part("Display",V(.2,10,12),V(-145.8,7,z+dz),palette.glass,Enum.Material.Glass,m,false).Transparency=.15
		part("Awning",V(5,.5,13),CF(-143.8,12.5,z+dz)*CFrame.Angles(0,0,math.rad(-9)),palette.green,Enum.Material.Fabric,m,false)
	end
end
local dog=group("DogParkReservation",context)
local function fence(a,b)
	local len=(b-a).Magnitude;local count=math.ceil(len/9)
	for j=0,count do local p=a:Lerp(b,j/count);part("FencePost",V(.5,3.7,.5),p+V(0,1.85,0),palette.wood,Enum.Material.Wood,dog) end
	for _,y in {1.3,2.7} do bar("FenceRail",a+V(0,y,0),b+V(0,y,0),.3,.35,palette.wood,dog) end
end
fence(V(76,0,-142),V(160,0,-142));fence(V(160,0,-142),V(160,0,-30));fence(V(160,0,-30),V(76,0,-30))
fence(V(76,0,-142),V(76,0,-97));fence(V(76,0,-87),V(76,0,-57));fence(V(76,0,-47),V(76,0,-30))
local party=group("BirthdayReservation",context)
part("CourtyardBase",V(80,.2,120),V(120,.12,64),palette.paving,Enum.Material.Concrete,party)
for _,x in {91,149} do for _,z in {18,114} do part("PergolaPost",V(1.2,12,1.2),V(x,6.2,z),palette.wood,Enum.Material.Wood,party) end end
for _,x in {91,149} do part("PergolaSide",V(1,1,99),V(x,12.2,66),palette.darkwood,Enum.Material.Wood,party) end
for _,z in {18,114} do part("PergolaBeam",V(61,1,1.5),V(120,12.2,z),palette.darkwood,Enum.Material.Wood,party) end
for i=0,8 do ball("StringBulb",V(.6,.8,.6),V(92+i*7,11.25,114),RGB(255,222,163),party).Material=Enum.Material.Neon end
part("TablePlaceholder",V(28,.65,12),V(112,3.7,64),palette.wood,Enum.Material.WoodPlanks,party)
for _,x in {101,123} do for _,z in {60,68} do part("TableLeg",V(1,3.3,1),V(x,1.8,z),palette.darkwood,Enum.Material.Wood,party) end end
for i=0,3 do for _,z in {55,73} do
	local seat=Instance.new("Seat");seat.Name="PartySeat";seat.Size=V(3,.5,3);seat.CFrame=CF(102+i*6.5,2,z)*CFrame.Angles(0,z==55 and math.pi or 0,0);seat.Color=palette.wood;seat.Material=Enum.Material.Wood;seat.Anchored=true;seat.Parent=party
	part("ChairBack",V(3,3,.5),V(102+i*6.5,3,z+(z==55 and -1.5 or 1.5)),palette.wood,Enum.Material.Wood,party)
end end
-- Soft perimeter masses make the small neighborhood feel enclosed.
for i=0,14 do
	local x=-195+i*28
	ball("DistantCanopy",V(33,29,27),V(x,15,-176-(i%3)*9),RGB(105+i%3*8,133+i%3*7,94),context)
end
for i=0,10 do ball("DistantCanopy",V(30,25,35),V(185+(i%2)*10,12,-140+i*30),RGB(109,137,97),context) end

-- One global afternoon setup; originals remain backed up in ServerStorage.
local prior=Instance.new("Folder");prior.Name="OriginalLiveLighting";prior.Parent=SS.BeforeCozyDraft01
for _,v in L:GetChildren() do v.Parent=prior end
local sky=assets.CozySky:Clone();sky.Parent=L;sky.CelestialBodiesShown=true;sky.SunAngularSize=9
L.ClockTime=14.2;L.Brightness=2;L.Ambient=RGB(128,128,117);L.OutdoorAmbient=RGB(147,153,140)
L.EnvironmentDiffuseScale=.6;L.EnvironmentSpecularScale=.25;L.ExposureCompensation=.05;L.GlobalShadows=true
L.FogStart=500;L.FogEnd=1400;L.FogColor=RGB(213,224,224)
local atmosphere=Instance.new("Atmosphere");atmosphere.Density=.22;atmosphere.Offset=.1;atmosphere.Color=RGB(221,228,218);atmosphere.Decay=RGB(167,182,166);atmosphere.Glare=.08;atmosphere.Haze=.7;atmosphere.Parent=L
local grade=Instance.new("ColorCorrectionEffect");grade.Name="CozyGrade";grade.TintColor=RGB(255,247,233);grade.Contrast=.035;grade.Saturation=-.08;grade.Brightness=.015;grade.Parent=L
game:GetService("StarterPlayer").CameraMinZoomDistance=6
game:GetService("StarterPlayer").CameraMaxZoomDistance=36
game:GetService("StarterPlayer").CameraMode=Enum.CameraMode.Classic
W.CurrentCamera.CFrame=CF(V(13,14,175),V(-17,8,-75));W.CurrentCamera.FieldOfView=62
game:GetService("Selection"):Set({})
game:GetService("ChangeHistoryService"):SetWaypoint("Cozy arrival draft 01 geometry")
local count=0;for _,p in root:GetDescendants() do if p:IsA("BasePart") then count+=1 end end
return "Draft 01 built: "..count.." anchored parts; 23 community blossom trees; cottage entry (-20,-84)."
