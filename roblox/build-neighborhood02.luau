-- Studio Edit-mode authoring. Builds a staged replacement, then swaps only owned context.
-- Re-running replaces NeighborhoodDetails02; original placeholders remain backed up.
local SS = game:GetService("ServerStorage")
local world = workspace:WaitForChild("CozyWorld_Draft01")
local context = world:WaitForChild("SurroundingContext")
local V, CF, RGB = Vector3.new, CFrame.new, Color3.fromRGB
local floorAnchor=world:WaitForChild("Home"):WaitForChild("Floor")
assert(floorAnchor:IsA("BasePart"),"Expected original Home.Floor placement anchor")
local worldOffset=floorAnchor.Position-V(-28,.12,-108)
local P = {
	forest=RGB(54,87,68), sage=RGB(168,185,149), cream=RGB(245,240,228),
	wood=RGB(149,103,75), blossom=RGB(232,183,198), brick=RGB(182,108,104),
	golden=RGB(232,199,121), ink=RGB(38,56,46),
}
local function group(name,parent,ticket)
	local m=Instance.new("Model"); m.Name=name; m.Parent=parent
	m:SetAttribute("VerificationTicket",ticket or "MAP-02"); return m
end
local stageName="NeighborhoodDetails02_Staging"
local oldStage=SS:FindFirstChild(stageName)
if oldStage then oldStage:Destroy() end
local stage=group(stageName,SS)
stage:SetAttribute("AuthoringVersion","02")
stage:SetAttribute("OwnedScope","Three storefronts, birthday courtyard, dog park, perimeter trees")
local function part(name,size,cf,token,material,parent,collide,className)
	local p=Instance.new(className or "Part"); p.Name=name; p.Size=size
	p.CFrame=typeof(cf)=="CFrame" and cf or CF(cf); p.Color=P[token]; p.Material=material or Enum.Material.SmoothPlastic
	p:SetAttribute("PaletteToken",token); p.Anchored=true; p.CanCollide=collide~=false
	p.CanTouch=false; p.TopSurface=Enum.SurfaceType.Smooth; p.BottomSurface=Enum.SurfaceType.Smooth; p.Parent=parent
	return p
end
local function ball(name,size,pos,token,parent)
	local p=part(name,size,pos,token,Enum.Material.SmoothPlastic,parent,false); p.Shape=Enum.PartType.Ball; return p
end
local function cylinder(name,radius,height,pos,token,material,parent,collide)
	local p=part(name,V(height,radius*2,radius*2),CF(pos)*CFrame.Angles(0,0,math.pi/2),token,material,parent,collide)
	p.Shape=Enum.PartType.Cylinder; return p
end
local function beam(name,a,b,width,token,parent,material,collide)
	return part(name,V(width,width,(b-a).Magnitude),CF((a+b)/2,b),token,material,parent,collide)
end
local function label(face,text,side,color,font)
	local g=Instance.new("SurfaceGui"); g.Name="ReadableSign"; g.Face=side or Enum.NormalId.Right
	g.CanvasSize=Vector2.new(1000,240); g.LightInfluence=.35; g.SizingMode=Enum.SurfaceGuiSizingMode.FixedSize; g.Parent=face
	local t=Instance.new("TextLabel"); t.Size=UDim2.fromScale(.96,.9); t.Position=UDim2.fromScale(.02,.05)
	t.BackgroundTransparency=1; t.Text=text; t.Font=font or Enum.Font.GothamBold; t.TextScaled=true
	t.TextColor3=P[color or "cream"]; t.Parent=g; return t
end
local function planter(parent,x,z,token,size,y)
	y=y or .3; size=size or 2.8
	local m=group("PottedPlant",parent)
	cylinder("CeramicPot",size*.45,1.6,V(x,y+.8,z),token or "brick",Enum.Material.CeramicTiles,m)
	cylinder("PotRim",size*.51,.24,V(x,y+1.57,z),token or "brick",Enum.Material.SmoothPlastic,m,false)
	cylinder("Soil",size*.41,.08,V(x,y+1.71,z),"wood",Enum.Material.Ground,m,false)
	for i=0,3 do
		local a=i*math.pi/2; local leaf=ball("PlantLeaf",V(size*.5,size*1.1,size*.46),V(x+math.cos(a)*size*.21,y+2.6,z+math.sin(a)*size*.21),i%2==0 and "forest" or "sage",m)
		leaf.CFrame*=CFrame.Angles(math.sin(a)*.4,0,math.cos(a)*.4)
	end
	return m
end
local function chair(parent,pos,yaw,token,name)
	local m=group(name or "Chair",parent); local cf=CF(pos)*CFrame.Angles(0,math.rad(yaw),0)
	local seat=part("Seat",V(3.2,.4,3.2),cf*CF(0,2,0),token or "wood",Enum.Material.Wood,m,true,"Seat")
	seat.CanTouch=true
	for _,x in {-1.2,1.2} do for _,z in {-1.15,1.15} do part("ChairLeg",V(.32,1.8,.32),cf*CF(x,.95,z),"wood",Enum.Material.Wood,m) end end
	for _,x in {-1.32,1.32} do part("BackUpright",V(.32,3.6,.32),cf*CF(x,2.05,1.4),"wood",Enum.Material.Wood,m) end
	for _,y in {3.1,4.15} do part("BackSlat",V(2.7,.6,.25),cf*CF(0,y,1.4),token or "wood",Enum.Material.Wood,m) end
	return m
end
local function cup(parent,x,y,z,token)
	cylinder("TeaCup",.4,1.0,V(x,y+.5,z),token,Enum.Material.SmoothPlastic,parent,false)
	cylinder("CupLid",.46,.12,V(x,y+1.05,z),"cream",Enum.Material.SmoothPlastic,parent,false)
	part("Straw",V(.08,.68,.08),CF(x+.12,y+1.39,z)*CFrame.Angles(0,0,.12),"forest",nil,parent,false)
end
local function cafeTable(parent,x,z)
	local m=group("CafeTable",parent)
	cylinder("Tabletop",2.6,.3,V(x,3.5,z),"cream",Enum.Material.Marble,m)
	cylinder("Pedestal",.28,3.0,V(x,1.9,z),"forest",Enum.Material.Metal,m)
	cylinder("Foot",1.4,.25,V(x,.42,z),"forest",Enum.Material.Metal,m)
	cup(m,x-.6,3.65,z,"sage"); cup(m,x+.75,3.65,z+.5,"blossom")
	chair(m,V(x, .2,z-4.0),180,"forest"); chair(m,V(x,.2,z+4.0),0,"forest")
end
local function bench(parent,x,z,yaw)
	local m=group("GardenBench",parent); local cf=CF(x,.2,z)*CFrame.Angles(0,math.rad(yaw),0)
	for _,xv in {-2.7,2.7} do for _,zv in {-.75,.75} do part("BenchLeg",V(.42,2,.42),cf*CF(xv,1,zv),"forest",Enum.Material.Metal,m) end end
	for _,zv in {-.75,0,.75} do part("BenchSlat",V(8,.28,.65),cf*CF(0,2.1,zv),"wood",Enum.Material.Wood,m) end
	for _,xv in {-3.2,3.2} do part("BackPost",V(.36,4,.36),cf*CF(xv,2,1.03),"forest",Enum.Material.Metal,m) end
	for _,y in {3,3.8} do part("BackSlat",V(8,.55,.27),cf*CF(0,y,1.04),"wood",Enum.Material.Wood,m) end
	for _,xv in {-1.9,1.9} do
		local s=part("BenchSeat",V(3.5,.15,2.5),cf*CF(xv,2.24,0),"wood",nil,m,true,"Seat"); s.Transparency=1; s.CanTouch=true
	end
	return m
end

-- The front of each shop faces east (+X), with a real open doorway at local Z +17.
local stores=group("Storefronts",stage,"PCW-05")
local specs={
	{name="FOB",z=-96,wall="brick",trim="forest",awning="forest",caption="POKE BAR  ·  BUILD YOUR BOWL",kind="poke"},
	{name="HeyTea",z=0,wall="cream",trim="forest",awning="sage",caption="TEA",kind="tea"},
	{name="Aladdins",z=96,wall="cream",trim="brick",awning="brick",caption="GYROS  ·  FALAFEL  ·  FRIES",kind="food"},
}
for _,s in specs do
	local z=s.z; local m=group(s.name,stores,"PCW-05")
	m:SetAttribute("DisplayName",s.name); m:SetAttribute("DoorCenter",V(-145.65,.3,z+17)); m:SetAttribute("DoorClearWidth",7.6)
	part("ShopFloor",V(28,.3,54),V(-160,.2,z),"cream",Enum.Material.CeramicTiles,m)
	part("RearWall",V(.7,17,54),V(-174,8.65,z),s.wall,Enum.Material.Brick,m)
	for _,side in {-1,1} do
		part("SideWall",V(28,17,.7),V(-160,8.65,z+side*27),s.wall,Enum.Material.Brick,m)
		part("FrontPilaster",V(1.15,17,1.7),V(-145.7,8.7,z+side*25.9),s.trim,Enum.Material.SmoothPlastic,m)
	end
	-- Window range -23..+8, doorway +13.2..+20.8. Upper fascia is continuous.
	for _,range in {{-27,-23},{8,13.2},{20.8,27}} do
		part("FacadePier",V(.7,13,range[2]-range[1]),V(-146,6.8,z+(range[1]+range[2])/2),s.wall,Enum.Material.Brick,m)
	end
	part("FacadeHeader",V(.8,4,54),V(-146,15.2,z),s.wall,Enum.Material.Brick,m)
	part("WindowBase",V(.9,2.8,31),V(-145.9,1.65,z-7.5),s.trim,Enum.Material.SmoothPlastic,m)
	local glass=part("DisplayGlass",V(.12,9.3,31),V(-145.54,7.75,z-7.5),"sage",Enum.Material.Glass,m)
	glass.Transparency=.76; glass.Reflectance=.05
	for _,dz in {-23,-12.7,-2.3,8} do part("WindowMullion",V(.32,9.75,.35),V(-145.35,7.75,z+dz),s.trim,Enum.Material.Metal,m) end
	for _,y in {3.0,10.35,12.6} do part("WindowFrame",V(.4,.28,31.7),V(-145.34,y,z-7.5),s.trim,Enum.Material.Metal,m) end
	for _,dz in {13,21} do part("DoorJamb",V(.9,12.5,.35),V(-145.6,6.6,z+dz),s.trim,Enum.Material.Metal,m) end
	part("DoorTransom",V(.2,1.65,7.6),V(-145.56,12.2,z+17),"sage",Enum.Material.Glass,m).Transparency=.62
	part("DoorTransomFrame",V(.4,.3,8),V(-145.3,11.28,z+17),s.trim,Enum.Material.Metal,m)
	-- A visibly open door leaf tucked against the inside wall leaves 7.6 studs clear.
	local door=part("OpenDoorLeaf",V(5.9,10.4,.25),V(-149.1,5.65,z+20.7),s.trim,Enum.Material.Wood,m)
	part("DoorWindow",V(4.8,6.9,.1),V(-149.1,6.7,z+20.51),"sage",Enum.Material.Glass,m,false).Transparency=.35
	part("DoorHandle",V(.25,1.3,.45),V(-151.4,5.7,z+20.34),"golden",Enum.Material.Metal,m,false)
	part("Threshold",V(1.5,.15,7.6),V(-145.45,.38,z+17),s.trim,Enum.Material.Marble,m)
	part("FlatRoof",V(29,.7,55),V(-160,17.65,z),s.trim,Enum.Material.Slate,m)
	part("Cornice",V(1.7,.75,56),V(-145.75,17.9,z),"cream",Enum.Material.SmoothPlastic,m)
	part("ParapetCap",V(30,.35,56),V(-160,18.15,z),"cream",Enum.Material.Concrete,m)
	for _,dz in {-25,25} do part("Downpipe",V(.35,14.5,.35),V(-145.15,7.5,z+dz),s.trim,Enum.Material.Metal,m,false) end
	local sign=part("StoreNameSign",V(.45,3.25,35),V(-145.17,15.3,z-3),s.trim,nil,m,false)
	label(sign,s.name,Enum.NormalId.Right,"cream")
	if s.kind=="poke" then
		local secondary=part("PokeBarSign",V(.16,1.5,13),V(-145.38,3.7,z-7.5),"forest",nil,m,false)
		label(secondary,"POKE BAR",Enum.NormalId.Right,"cream")
	end
	-- Awning stays west of the clear street-side walking strip (X -140..-134).
	local awning=part("FabricAwning",V(4.5,.28,33),CF(-143.4,12.8,z-7.5)*CFrame.Angles(0,0,.11),s.awning,Enum.Material.Fabric,m,false)
	part("AwningValance",V(.2,.72,33),V(-141.2,12.1,z-7.5),s.awning,Enum.Material.Fabric,m,false)
	for j=0,10 do part("AwningStripe",V(4.45,.035,1.45),awning.CFrame*CF(0,.16,-15+j*3),"cream",Enum.Material.Fabric,m,false) end
	local blade=part("ProjectingSign",V(3.9,2.2,.28),V(-143.0,9.0,z+23),s.trim,nil,m,false)
	label(blade,s.name,Enum.NormalId.Back,"cream"); label(blade,s.name,Enum.NormalId.Front,"cream")
	beam("SignBracket",V(-146,10.5,z+23),V(-141,10.5,z+23),.18,"forest",m,Enum.Material.Metal,false)
	for _,dz in {-20,4} do
		local lamp=part("WarmWallLamp",V(.65,1.1,.65),V(-145,13.1,z+dz),"golden",Enum.Material.Neon,m,false)
		local light=Instance.new("PointLight"); light.Color=P.golden; light.Range=12; light.Brightness=.3; light.Parent=lamp
	end
	-- Compact interior: counter, casework, shelf products, pendant lights, and readable board.
	part("ServiceCounter",V(4.0,3.3,26),V(-165.5,2.02,z-6),s.trim,Enum.Material.WoodPlanks,m)
	part("CounterTop",V(4.5,.25,27),V(-165.5,3.8,z-6),"cream",Enum.Material.Marble,m)
	for dz=-17,5,3.7 do part("CounterFluting",V(.12,2.9,.14),V(-163.43,2.05,z+dz),"wood",Enum.Material.Wood,m,false) end
	for _,y in {5.5,8.5} do
		part("BackShelf",V(2.4,.3,29),V(-172.5,y,z-6),"wood",Enum.Material.Wood,m)
		for j=0,5 do
			local token=({"cream","sage","blossom","golden"})[j%4+1]
			cylinder("IngredientJar",.53,1.3,V(-172.1,y+.8,z-18+j*4.6),token,Enum.Material.Glass,m,false)
			cylinder("JarLid",.58,.15,V(-172.1,y+1.5,z-18+j*4.6),s.trim,Enum.Material.Metal,m,false)
		end
	end
	local board=part("InteriorBoard",V(.15,3.3,21),V(-173.5,12.25,z-6),"forest",nil,m,false)
	label(board,s.caption,Enum.NormalId.Right,"cream")
	for _,dz in {-16,0,16} do
		cylinder("PendantShade",.9,.65,V(-157,13.8,z+dz),s.trim,Enum.Material.Metal,m,false)
		part("PendantCord",V(.1,3.0,.1),V(-157,15.4,z+dz),"ink",nil,m,false)
		local lightPart=ball("PendantBulb",V(.6,.7,.6),V(-157,13.35,z+dz),"golden",m); lightPart.Material=Enum.Material.Neon
		local light=Instance.new("PointLight"); light.Color=P.golden; light.Range=17; light.Brightness=.45; light.Parent=lightPart
	end
	for j=0,3 do
		if s.kind=="tea" then cup(m,-165,3.94,z-16+j*5,"sage")
		elseif s.kind=="food" then
			part("ServingTray",V(2,.1,2.8),V(-165,3.98,z-16+j*5),"cream",Enum.Material.Metal,m,false)
			for k=0,2 do part("Fries",V(.18,.18,1.2),CF(-165.5+k*.3,4.17,z-16+j*5)*CFrame.Angles(0,k*.2,0),"golden",nil,m,false) end
			ball("Falafel",V(.65,.6,.65),V(-164.6,4.3,z-16+j*5),"wood",m)
		elseif s.kind=="poke" then
			local bz=z-16+j*5
			cylinder("PokeBowl",1.05,.55,V(-165,4.23,bz),"wood",Enum.Material.SmoothPlastic,m,false)
			cylinder("Rice",.93,.1,V(-165,4.56,bz),"cream",nil,m,false)
			for k=0,2 do
				part("SalmonCube",V(.42,.25,.42),CF(-165.4+k*.4,4.76,bz-.3)*CFrame.Angles(0,k*.45,0),"blossom",nil,m,false)
				ball("Edamame",V(.35,.22,.3),V(-165.4+k*.4,4.74,bz+.33),"sage",m)
			end
			part("Chopsticks",V(.075,.075,2.5),CF(-164.1,4.72,bz)*CFrame.Angles(0,.22,0),"wood",Enum.Material.Wood,m,false)
			part("Chopsticks",V(.075,.075,2.5),CF(-163.94,4.72,bz)*CFrame.Angles(0,.22,0),"wood",Enum.Material.Wood,m,false)
		end
	end
	if s.kind=="poke" then
		local guard=part("CounterGlassGuard",V(.12,2.7,24),V(-163.0,5.3,z-8),"sage",Enum.Material.Glass,m,false); guard.Transparency=.72
		for _,dz in {-20,4} do part("GuardSupport",V(.2,2.6,.2),V(-163,5.3,z+dz),"forest",Enum.Material.Metal,m,false) end
	end
	planter(m,-142.4,z-25,s.trim,2.4); planter(m,-142.4,z+25,s.trim,2.4)
	cafeTable(m,-155,z+15)
	-- Pocket patio beside the shop (never on the north/south sidewalk or road).
	part("SidePatio",V(26,.13,13),V(-160,.12,z+34),"cream",Enum.Material.Concrete,m)
	cafeTable(m,-161,z+34); planter(m,-171,z+35,s.trim,2.8)
end

-- A furnished celebration space with a clear central route and eight actual seats.
local party=group("BirthdayCourtyard",stage)
part("CourtyardBase",V(80,.2,120),V(120,.12,64),"cream",Enum.Material.Concrete,party)
for x=88,152,16 do part("CourtyardJoint",V(.07,.03,120),V(x,.235,64),"sage",nil,party,false) end
for z=12,116,16 do part("CourtyardJoint",V(80,.03,.07),V(120,.235,z),"sage",nil,party,false) end
for _,x in {91,149} do for _,z in {18,114} do
	part("PergolaPost",V(1.15,12,1.15),V(x,6.2,z),"wood",Enum.Material.Wood,party)
	part("PostFoot",V(1.7,.8,1.7),V(x,.62,z),"forest",Enum.Material.Metal,party)
end end
for _,x in {91,149} do part("PergolaSideBeam",V(1,1,100),V(x,12.3,66),"wood",Enum.Material.Wood,party) end
for _,z in {18,114} do part("PergolaEndBeam",V(62,1,1),V(120,12.3,z),"wood",Enum.Material.Wood,party) end
for z=18,114,8 do part("PergolaSlat",V(61,.5,.65),V(120,13.0,z),"wood",Enum.Material.Wood,party,false) end
for _,z in {22,64,108} do
	for j=0,11 do
		local function bulbPos(i) return V(92+i*5.1,11.6-math.sin(i/11*math.pi)*1.65,z) end
		local pos=bulbPos(j)
		if j<11 then beam("LightCable",pos,bulbPos(j+1),.07,"forest",party,nil,false) end
		part("BulbSocket",V(.18,.3,.18),pos+V(0,-.12,0),"forest",nil,party,false)
		local bulb=ball("WarmStringBulb",V(.45,.58,.45),pos+V(0,-.49,0),"golden",party); bulb.Material=Enum.Material.Neon
	end
end
part("CelebrationRug",V(39,.055,30),V(114,.27,66),"sage",Enum.Material.Fabric,party,false)
for _,z in {52,80} do part("RugBorder",V(37,.02,.45),V(114,.305,z),"cream",Enum.Material.Fabric,party,false) end
part("GatheringTable",V(28,.5,12),V(114,3.7,66),"wood",Enum.Material.Wood,party)
for _,x in {103,125} do for _,z in {62,70} do part("TableLeg",V(.8,3.3,.8),V(x,1.85,z),"wood",Enum.Material.Wood,party) end end
part("CreamTablecloth",V(28.4,.09,12.4),V(114,4.005,66),"cream",Enum.Material.Fabric,party,false)
for _,z in {59.8,72.2} do part("ClothDrape",V(28.4,1.1,.09),V(114,3.5,z),"cream",Enum.Material.Fabric,party,false) end
part("BlossomTableRunner",V(27,.035,2.2),V(114,4.075,66),"blossom",Enum.Material.Fabric,party,false)
for j=0,3 do for _,side in {-1,1} do
	local x=104+j*6.5; local z=66+side*4.1
	chair(party,V(x,.22,66+side*9),side==-1 and 180 or 0,"sage","CelebrationChair")
	cylinder("DinnerPlate",1.08,.1,V(x,4.12,z),"cream",Enum.Material.SmoothPlastic,party,false)
	cylinder("PlateInset",.8,.025,V(x,4.18,z),"blossom",nil,party,false)
	part("FoldedNapkin",V(1.1,.08,.65),CF(x,4.25,z)*CFrame.Angles(0,.22,0),"sage",Enum.Material.Fabric,party,false)
	part("Fork",V(.1,.07,1.2),V(x-1.45,4.14,z),"golden",Enum.Material.Metal,party,false)
	part("Knife",V(.16,.07,1.2),V(x+1.45,4.14,z),"golden",Enum.Material.Metal,party,false)
	cylinder("DrinkingGlass",.35,.85,V(x+1.0,4.54,z-side*1.65),"sage",Enum.Material.Glass,party,false).Transparency=.55
end end
-- Cake with frosting, berries, candles, and a literal 24 topper.
local cake=group("BirthdayCake",party)
cylinder("CakeStand",3.0,.2,V(114,4.25,66),"golden",Enum.Material.Metal,cake,false)
cylinder("CakeLowerTier",2.65,1.5,V(114,5.1,66),"cream",nil,cake,false)
cylinder("CakeUpperTier",1.85,1.2,V(114,6.4,66),"blossom",nil,cake,false)
for i=0,9 do local a=i*math.pi/5; ball("IcingRosette",V(.48,.38,.48),V(114+math.cos(a)*1.8,7.05,66+math.sin(a)*1.8),"cream",cake) end
for _,x in {113.4,114.6} do
	part("Candle",V(.14,1.0,.14),V(x,7.5,66),"golden",nil,cake,false)
	local flame=ball("CandleFlame",V(.15,.34,.15),V(x,8.15,66),"golden",cake); flame.Material=Enum.Material.Neon
end
local topper=part("AgeTopper",V(2,.9,.08),V(114,8,66.1),"cream",nil,cake,false); topper.Transparency=1
label(topper,"24",Enum.NormalId.Back,"forest"); label(topper,"24",Enum.NormalId.Front,"forest")
-- Dessert sideboard and wrapped gifts provide finished secondary focal points.
part("DessertSideboard",V(7,3.7,18),V(140,2.1,38),"wood",Enum.Material.WoodPlanks,party)
part("SideboardCloth",V(7.3,.09,18.3),V(140,4.0,38),"cream",Enum.Material.Fabric,party,false)
for i=0,3 do
	cylinder("DessertPlate",1,.1,V(140,4.1,32+i*4),"golden",nil,party,false)
	cylinder("CupcakeBase",.55,.55,V(140,4.42,32+i*4),"wood",nil,party,false)
	ball("CupcakeFrosting",V(1.25,.8,1.25),V(140,4.85,32+i*4),i%2==0 and "blossom" or "cream",party)
end
for i=0,5 do
	local x=135+(i%3)*5; local z=94+math.floor(i/3)*5; local h=2.5+(i%3)*.7
	part("WrappedGift",V(3.4,h,3.3),V(x,.25+h/2,z),({"sage","blossom","golden"})[i%3+1],nil,party)
	part("GiftRibbon",V(.35,h+.1,3.36),V(x,.25+h/2,z),"cream",Enum.Material.Fabric,party,false)
	part("GiftCrossRibbon",V(3.46,.1,.35),V(x,.32+h,z),"cream",Enum.Material.Fabric,party,false)
	for _,side in {-1,1} do ball("RibbonLoop",V(1.1,.38,.5),CF(x+side*.48,h+.52,z)*CFrame.Angles(0,side*.4,0),"cream",party) end
end
for _,p in {{86,16},{154,16},{86,116},{154,116},{140,50},{139,82}} do planter(party,p[1],p[2],"brick",3.2) end
for _,x in {91,149} do
	for j=0,7 do
		local z=29+j*10
		beam("BuntingCord",V(x,10.7,z-5),V(x,10.7,z+5),.07,"forest",party,nil,false)
		local flag=part("BuntingFlag",V(.08,1.7,1.6),CF(x,9.9,z)*CFrame.Angles(0,0,math.pi),j%2==0 and "blossom" or "sage",Enum.Material.Fabric,party,false,"WedgePart")
	end
end

-- Dog-park fence and recognizable care/play objects, leaving the middle for fetch.
local dog=group("JasperDogPark",stage)
local function fence(a,b)
	local n=math.ceil((b-a).Magnitude/9)
	for j=0,n do
		local p=a:Lerp(b,j/n)
		part("FencePost",V(.55,3.8,.55),p+V(0,1.9,0),"wood",Enum.Material.Wood,dog)
		ball("PostCap",V(.75,.4,.75),p+V(0,3.9,0),"wood",dog)
	end
	for _,y in {1.1,2.7} do beam("FenceRail",a+V(0,y,0),b+V(0,y,0),.36,"wood",dog,Enum.Material.Wood,true) end
end
fence(V(76,0,-142),V(160,0,-142)); fence(V(160,0,-142),V(160,0,-30)); fence(V(160,0,-30),V(76,0,-30))
fence(V(76,0,-142),V(76,0,-97)); fence(V(76,0,-87),V(76,0,-57)); fence(V(76,0,-47),V(76,0,-30))
local dogSign=part("DogParkSign",V(.2,2.7,13),V(75.6,5,-107),"forest",nil,dog,false)
label(dogSign,"Jasper’s Park",Enum.NormalId.Left,"cream")
bench(dog,151,-83,90); bench(dog,106,-134,180)
local basket=group("ToyBasket",dog)
part("BasketBase",V(5,.4,3.6),V(147,.35,-92),"wood",Enum.Material.Wood,basket)
for _,z in {-93.8,-90.2} do part("BasketSide",V(5,1.6,.2),V(147,1.0,z),"wood",Enum.Material.Wood,basket) end
for _,x in {144.5,149.5} do part("BasketEnd",V(.2,1.6,3.6),V(x,1,-92),"wood",Enum.Material.Wood,basket) end
for i=0,4 do part("BasketWeave",V(.08,1.55,3.65),V(145+i,1.1,-92),"golden",nil,basket,false) end
for i=0,2 do ball("FetchBall",V(1.1,1.1,1.1),V(145.7+i*1.4,1.3,-92),i%2==0 and "sage" or "golden",basket) end
part("DogWaterMat",V(7,.04,5),V(150,.08,-100),"sage",Enum.Material.Fabric,dog,false)
cylinder("WaterBowl",1.6,.5,V(150,.34,-100),"cream",Enum.Material.Metal,dog)
cylinder("WaterSurface",1.3,.025,V(150,.60,-100),"sage",Enum.Material.Glass,dog,false).Transparency=.42
for _,p in {{99,-46},{137,-117}} do
	ball("FetchBall",V(1.4,1.4,1.4),V(p[1],.75,p[2]),"golden",dog)
	part("BallStripe",V(.15,1.3,1.1),CF(p[1],.75,p[2])*CFrame.Angles(0,.4,0),"cream",nil,dog,false)
end
local tunnel=group("LowDogAgilityHoop",dog)
-- A faceted ring with open centre is a decorative play prop, never an invisible obstacle.
for i=0,11 do
	local a,b=i*math.pi/6,(i+1)*math.pi/6
	beam("HoopSegment",V(132+math.cos(a)*3,3.3+math.sin(a)*3,-47),V(132+math.cos(b)*3,3.3+math.sin(b)*3,-47),.32,"sage",tunnel,nil,false)
end
for _,x in {128,136} do part("HoopFoot",V(1,.3,3),V(x,.2,-47),"wood",Enum.Material.Wood,tunnel) end
for _,p in {{81,-137},{154,-137},{154,-35},{85,-35}} do planter(dog,p[1],p[2],"brick",3.4,.05) end

-- Layered crowns with visible trunks and branches replace the distant sphere masses.
local perimeter=group("PerimeterGardens",stage)
local function tree(x,z,height,index)
	local m=group("LayeredTree"..index,perimeter)
	cylinder("TreeTrunk",.85,height*.62,V(x,height*.31,z),"wood",Enum.Material.Wood,m)
	for j=0,2 do
		local a=j*math.pi*2/3+index*.7
		beam("TreeBranch",V(x,height*.39,z),V(x+math.cos(a)*height*.22,height*.69,z+math.sin(a)*height*.22),.7,"wood",m,Enum.Material.Wood,false)
	end
	for j=0,4 do
		local a=j*math.pi*2/5+index*.4
		local size=height*(.48+(j%2)*.08)
		local leaf=ball("LeafCrown",V(size,size*.82,size*.88),CF(x+math.cos(a)*height*.2,height*.70+(j%2)*height*.10,z+math.sin(a)*height*.19)*CFrame.Angles(.1*j,.27*j,.1*(j%2)),j%3==0 and "sage" or "forest",m)
	end
	ball("TopCrown",V(height*.46,height*.42,height*.43),V(x,height*.94,z),"forest",m)
	for j=0,2 do
		local a=j*2.2
		ball("UnderstoryShrub",V(5,3.2,4),V(x+math.cos(a)*5.5,1.3,z+math.sin(a)*5.5),j%2==0 and "sage" or "forest",m)
	end
end
for i=0,8 do tree(-177+i*40,-177-(i%3)*8,25+(i%4)*3,i+1) end
for i=0,6 do tree(188+(i%2)*6,-127+i*46,26+(i%3)*3,i+10) end

-- Preserve the user's whole-map translation; never move existing context in place.
stage:SetAttribute("WorldOffset",worldOffset)
for _,v in stage:GetDescendants() do
	if v:IsA("BasePart") then v.CFrame+=worldOffset end
	local door=v:GetAttribute("DoorCenter")
	if typeof(door)=="Vector3" then v:SetAttribute("DoorCenter",door+worldOffset) end
end
local count=0
for _,v in stage:GetDescendants() do
	assert(not v:IsA("LuaSourceContainer"),"Neighborhood authoring must not insert runtime scripts")
	if v:IsA("BasePart") then count+=1; assert(v.Anchored and v:GetAttribute("PaletteToken"),"Missing static/palette contract: "..v:GetFullName()) end
end
assert(count<=1500,"Neighborhood exceeds 1500-part budget: "..count)
local backup=SS:FindFirstChild("BeforeNeighborhood02")
if not backup then backup=Instance.new("Folder"); backup.Name="BeforeNeighborhood02"; backup.Parent=SS end
for _,v in context:GetChildren() do
	if v.Name:match("^StorefrontMassing%d+$") or v.Name=="DogParkReservation" or v.Name=="BirthdayReservation" or v.Name=="DistantCanopy" then
		v.Parent=backup
	end
end
local previous=context:FindFirstChild("NeighborhoodDetails02")
if previous then previous:Destroy() end
stage.Name="NeighborhoodDetails02"; stage.Parent=context
stage:SetAttribute("PartCount",count)
game:GetService("ChangeHistoryService"):SetWaypoint("Neighborhood 02 detailed storefronts and gardens")
return "Neighborhood 02 installed: "..count.." anchored parts; three enterable named stores; eight celebration seats; original context backed up; preserved offset "..tostring(worldOffset).."."
