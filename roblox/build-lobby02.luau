-- Run in Studio Edit mode. Replaces only the generated BirthdayLobby model.
local root = assert(workspace:FindFirstChild("CozyWorld_Draft01"), "Build the outdoor world first")
local old = root:FindFirstChild("BirthdayLobby")
if old then old:Destroy() end
local V, CF, RGB = Vector3.new, CFrame.new, Color3.fromRGB
local P = {cream=RGB(245,240,228), sage=RGB(168,185,149), green=RGB(54,87,68), pink=RGB(232,183,198), rose=RGB(182,108,104), gold=RGB(232,199,121), wood=RGB(149,103,75), ink=RGB(38,56,46), paper=RGB(245,240,228), mint=RGB(168,185,149)}
local paletteTokens = {cream=P.cream,sage=P.sage,forest=P.green,blossom=P.pink,brick=P.rose,golden=P.gold,wood=P.wood,ink=P.ink}
local function tokenForColor(color)
	for token,approved in paletteTokens do if color==approved then return token end end
	error("Part color must be from the approved palette")
end
local function model(name,parent)
	local m=Instance.new("Model"); m.Name=name; m.Parent=parent; return m
end
local lobby=model("BirthdayLobby",root)
lobby:SetAttribute("Revision",2)
lobby:SetAttribute("VerificationTicket","PCW-17")
lobby:SetAttribute("CountdownSeconds",60)
lobby:SetAttribute("RegionCenter",V(2000,12,0))
lobby:SetAttribute("RegionSize",V(80,26,64))
lobby:SetAttribute("Greeting","Happy 24th Birthday, Phuong")
local shell=model("RoomShell",lobby)
local decor=model("PartyDecorations",lobby)
local interests=model("FavoriteThings",lobby)
local seats=model("EightGuestSeats",lobby)
local function part(name,size,at,color,parent,material,collide)
	local p=Instance.new("Part"); p.Name=name; p.Size=size; p.CFrame=typeof(at)=="CFrame" and at or CF(at)
	p.Color=color; p.Material=material or Enum.Material.SmoothPlastic; p.Anchored=true
	p:SetAttribute("PaletteToken",tokenForColor(color))
	p.CanCollide=collide==true; p.CanTouch=false; p.TopSurface=Enum.SurfaceType.Smooth; p.BottomSurface=Enum.SurfaceType.Smooth
	p.Parent=parent; return p
end
local function ball(name,size,at,color,parent)
	local p=part(name,size,at,color,parent)
	if size.X==size.Y and size.Y==size.Z then
		p.Shape=Enum.PartType.Ball
	else
		local mesh=Instance.new("SpecialMesh");mesh.Name="SoftEllipsoid";mesh.MeshType=Enum.MeshType.Sphere;mesh.Parent=p
	end
	return p
end
local function rod(name,a,b,thickness,color,parent,material)
	return part(name,V(thickness,thickness,(b-a).Magnitude),CF((a+b)/2,b),color,parent,material)
end
local function cylinder(name,radius,height,at,color,parent,material,collide)
	local p=part(name,V(height,2*radius,2*radius),CF(at)*CFrame.Angles(0,0,math.pi/2),color,parent,material,collide)
	p.Shape=Enum.PartType.Cylinder; return p
end
local function sign(name,text,size,at,color,bg,parent)
	local plaque=part(name,V(size.X,size.Y,.18),at,bg,parent)
	local gui=Instance.new("SurfaceGui");gui.Name="Lettering";gui.Face=Enum.NormalId.Back;gui.CanvasSize=Vector2.new(1000,math.floor(1000*size.Y/size.X));gui.LightInfluence=.15;gui.Parent=plaque
	local label=Instance.new("TextLabel");label.Name="Text";label.Size=UDim2.fromScale(.94,.86);label.Position=UDim2.fromScale(.03,.07)
	label.BackgroundTransparency=1;label.Text=text;label.TextColor3=color;label.TextScaled=true;label.Font=Enum.Font.GothamMedium;label.Parent=gui
	local padding=Instance.new("UIPadding");padding.PaddingLeft=UDim.new(0,12);padding.PaddingRight=UDim.new(0,12);padding.Parent=label
	return plaque
end
local function glow(at,range,brightness,parent)
	local bulb=ball("WarmBulb",V(.55,.55,.55),at,P.paper,parent);bulb.Material=Enum.Material.Neon
	local light=Instance.new("PointLight");light.Color=P.gold;light.Range=range;light.Brightness=brightness;light.Shadows=false;light.Parent=bulb
	return bulb
end

-- An enclosed room beyond the outdoor world, with a central clear walking lane.
part("OakFloor",V(80,.6,64),V(500,-.3,0),P.wood,shell,Enum.Material.WoodPlanks,true)
local ceiling=part("Ceiling",V(84,3,68),V(500,24.75,0),P.cream,shell,nil,true)
ceiling.CastShadow=true
for _,x in {460,540} do
	part("SideWall",V(.8,24,64),V(x,12,0),P.cream,shell,nil,true)
	part("SageWainscot",V(.92,5,64),V(x,2.5,0),P.sage,shell)
	part("PictureRail",V(1.12,.22,64),V(x,5.1,0),P.paper,shell)
	part("CrownMoulding",V(1.2,.6,64),V(x,23.1,0),P.paper,shell)
end
for _,z in {-32,32} do
	part("EndWall",V(80,24,.8),V(500,12,z),P.cream,shell,nil,true)
	part("SageWainscot",V(80,5,.92),V(500,2.5,z),P.sage,shell)
	part("PictureRail",V(80,.22,1.12),V(500,5.1,z),P.paper,shell)
	part("CrownMoulding",V(80,.6,1.2),V(500,23.1,z),P.paper,shell)
end
for x=463,537,4 do local seam=part("FloorSeam",V(.055,.025,62),V(x,.015,0),P.ink,shell);seam.Transparency=.75 end
for x=466,534,8 do
	for _,z in {-31.49,31.49} do part("WainscotBatten",V(.2,4.6,.1),V(x,2.5,z),P.paper,shell) end
end
part("MainSageRug",V(30,.045,31),V(500,.035,7),P.sage,decor,Enum.Material.Fabric)
for _,x in {485.5,514.5} do part("RugStitchedBorder",V(.16,.045,30),V(x,.066,7),P.cream,decor,Enum.Material.Fabric) end
for _,z in {-7.5,21.5} do part("RugStitchedBorder",V(29,.045,.16),V(500,.066,z),P.cream,decor,Enum.Material.Fabric) end

local spawn=Instance.new("SpawnLocation");spawn.Name="LobbySpawn";spawn.Size=V(24,.1,10);spawn.CFrame=CF(500,.15,21)
spawn.Anchored=true;spawn.CanCollide=false;spawn.CanTouch=false;spawn.Transparency=1;spawn.Neutral=true;spawn.Enabled=true;spawn.Duration=0;spawn.Parent=lobby
spawn.Color=P.cream;spawn:SetAttribute("PaletteToken","cream")
local arrival=root:WaitForChild("Arrival"):WaitForChild("ArrivalSpawn")
arrival.Enabled=false
local destination=part("WorldDestination",V(1,1,1),arrival.CFrame*CF(0,4,-4),P.gold,lobby)
destination.Transparency=1;destination.CanQuery=false

-- A readable focal wall and gold rounded numeral sculpture.
sign("WelcomeSign","Happy 24th Birthday, Phuong",Vector2.new(56,4.4),V(500,18.8,-31.25),P.green,P.cream,lobby)
sign("PartySubtitle","A little room of your favorite things",Vector2.new(36,1.5),V(500,15.3,-31.2),P.rose,P.cream,decor)
local function numeral(points,offset)
	for i=1,#points-1 do
		local a,b=V(offset+points[i][1],6.7+points[i][2],-29.9),V(offset+points[i+1][1],6.7+points[i+1][2],-29.9)
		rod("GoldenNumeral",a,b,.66,P.gold,decor,Enum.Material.Metal)
		ball("RoundedLetterJoin",V(.66,.66,.66),a,P.gold,decor)
	end
	local p=points[#points];ball("RoundedLetterJoin",V(.66,.66,.66),V(offset+p[1],6.7+p[2],-29.9),P.gold,decor)
end
numeral({{-2,5},{-1.6,6.2},{0,6.7},{1.7,6.2},{2,5},{1.6,4},{-1.8,.2},{2.1,.2}},496)
numeral({{1.8,6.7},{-2,2.2},{2.4,2.2}},503)
numeral({{1.8,6.7},{1.8,.2}},503)

local portal=model("Portal",lobby)
local pad=cylinder("TeleportPad",6,.18,V(500,.12,-17.5),P.green,portal,Enum.Material.SmoothPlastic,true)
cylinder("GoldPadBorder",6.25,.10,V(500,.08,-17.5),P.gold,portal,Enum.Material.Metal)
cylinder("PadInset",5.5,.025,V(500,.225,-17.5),P.sage,portal)
for _,x in {492.5,507.5} do
	part("ArchPost",V(.55,8.5,.55),V(x,4.25,-23),P.gold,portal,Enum.Material.Metal)
	ball("ArchFoot",V(1,.5,1),V(x,.3,-23),P.green,portal)
end
for i=0,19 do
	local a,b=i*math.pi/20,(i+1)*math.pi/20
	rod("RoundedArch",V(500+math.cos(a)*7.5,8.5+math.sin(a)*5,-23),V(500+math.cos(b)*7.5,8.5+math.sin(b)*5,-23),.55,P.gold,portal,Enum.Material.Metal)
end
sign("PortalTitle","THE BIRTHDAY WORLD",Vector2.new(13,1.1),V(500,5.8,-23.3),P.green,P.paper,portal)
sign("PortalInstructions","Explore this room for 60 seconds\nor use the pad to enter now",Vector2.new(25,2.4),V(500,3.2,-25),P.green,P.paper,portal)
local promptPart=part("PortalPrompt",V(1,1,1),V(500,3,-17.5),P.gold,portal);promptPart.Transparency=1;promptPart.CanQuery=false
local prompt=Instance.new("ProximityPrompt");prompt.Name="EnterWorld";prompt.ActionText="Enter world now";prompt.ObjectText="Phuong's birthday world";prompt.KeyboardKeyCode=Enum.KeyCode.E;prompt.MaxActivationDistance=8;prompt.RequiresLineOfSight=false;prompt.HoldDuration=.3;prompt.Parent=promptPart

local function gift(x,z,size,color)
	local h=size*.83
	part("WrappedGift",V(size,h,size),V(x,h/2,z),color,decor,nil,true)
	part("GiftLid",V(size+.14,.22,size+.14),V(x,h+.1,z),color,decor)
	part("RibbonAcross",V(size+.16,.04,.34),V(x,h+.24,z),P.paper,decor)
	part("RibbonAlong",V(.34,.045,size+.16),V(x,h+.25,z),P.paper,decor)
	for _,dx in {-1,1} do ball("GiftBowLoop",V(.7,.32,.42),V(x+dx*.32,h+.43,z),P.paper,decor) end
	part("RibbonFront",V(.34,h,.025),V(x,h/2,z+size/2+.02),P.paper,decor)
end
for _,g in {{482,-27,3.2,P.pink},{478,-25,2.5,P.sage},{485,-26,2,P.gold},{516,-27,3.5,P.sage},{520,-26,2.6,P.rose},{524,-27,2,P.gold},{470,24,2.8,P.sage},{473,26,2,P.pink}} do gift(table.unpack(g)) end
local function balloonCluster(x,z,height)
	for i=1,5 do
		local a=i*2.4;local b=V(x+math.cos(a)*1.5,height+(i%3)*1.2,z+math.sin(a)*.9)
		local c=({P.pink,P.sage,P.gold,P.paper,P.rose})[i]
		ball("PartyBalloon",V(2.15,2.7,2.15),b,c,decor)
		rod("BalloonString",V(x,.9,z),b-V(0,1.25,0),.035,P.paper,decor)
		ball("BalloonKnot",V(.2,.26,.2),b-V(0,1.37,0),c,decor)
	end
	cylinder("BalloonWeight",.42,.45,V(x,.25,z),P.gold,decor,Enum.Material.Metal)
end
balloonCluster(474,-27,10);balloonCluster(526,-27,10);balloonCluster(464,26,12);balloonCluster(535,24,11)

-- A ceiling canopy of warm light and sewn fabric pennants.
for _,z in {-8,12} do
	local last
	for i=0,16 do
		local x=462+i*4.75;local y=21.3-2.3*math.sin(i/16*math.pi);local point=V(x,y,z)
		if last then rod("LightCable",last,point,.055,P.ink,decor) end
		if i%2==0 then glow(point-V(0,.22,0),14,.22,decor) end
		last=point
	end
end
for i=0,19 do
	local x=463+i*3.85;local y=16.1-2.3*math.sin(i/19*math.pi)
	if i>0 then local px=463+(i-1)*3.85;local py=16.1-2.3*math.sin((i-1)/19*math.pi);rod("BuntingCord",V(px,py,28.8),V(x,y,28.8),.055,P.wood,decor) end
	local flag=part("FabricPennant",V(1.6,1.5,.07),CF(x,y-.65,28.8)*CFrame.Angles(0,0,math.rad(45)),({P.pink,P.sage,P.gold})[i%3+1],decor,Enum.Material.Fabric)
end
for i=1,75 do
	local x=463+(i*17.73)%73;local z=-28+(i*11.29)%56
	part("FloorConfetti",V(.25,.035,.55),CF(x,.08,z)*CFrame.Angles(0,i*2.4,0),({P.pink,P.gold,P.paper})[i%3+1],decor)
end
for _,x in {475,500,525} do glow(V(x,21,0),30,.25,decor) end
for _,x in {479,500,521} do
	for _,z in {-16,16} do
		local diffuser=part("CeilingLightDiffuser",V(8,.12,8),V(x,22.7,z),P.paper,decor,Enum.Material.Neon)
		diffuser.CastShadow=false
		local light=Instance.new("SurfaceLight");light.Name="EvenWarmInteriorFill";light.Face=Enum.NormalId.Bottom
		light.Color=P.cream;light.Brightness=.8;light.Range=38;light.Angle=160;light.Shadows=false;light.Parent=diffuser
	end
end

local function bench(x,z,yaw)
	local frame=CF(x,0,z)*CFrame.Angles(0,math.rad(yaw),0)
	part("SofaBase",V(17,1.2,4.6),frame*CF(0,1.25,0),P.wood,seats,Enum.Material.Wood,true)
	part("SofaBack",V(17,3.1,.55),frame*CF(0,3.1,2),P.sage,seats,Enum.Material.Fabric,true)
	for _,side in {-1,1} do part("SofaArm",V(.7,2,4.6),frame*CF(side*8.25,2.5,0),P.sage,seats,Enum.Material.Fabric,true) end
	for i=1,4 do
		local seat=Instance.new("Seat");seat.Name="GuestSeat";seat.Size=V(3.6,.45,3.5);seat.CFrame=frame*CF(-6+4*(i-1),2,0);seat.Color=P.cream;seat.Material=Enum.Material.Fabric;seat.Anchored=true;seat.Parent=seats
		seat:SetAttribute("PaletteToken","cream")
	end
	for _,side in {-1,1} do
		part("Cushion",V(2,2,.65),frame*CF(side*6.6,3.15,1.42)*CFrame.Angles(0,0,math.rad(side*9)),P.pink,seats,Enum.Material.Fabric)
	end
end
bench(470,7,-90);bench(530,7,90)

-- Small framed wall galleries make the room feel furnished above the seating.
for _,side in {-1,1} do
	for i,title in {"BOOKS & COZY DAYS","MAKE SOMETHING TINY","A ROOM FULL OF FAVORITES"} do
		local pose=CF(500+side*39.25,12.5,-15+(i-1)*16)*CFrame.Angles(0,-side*math.pi/2,0)
		part("GalleryFrame",V(11,8,.3),pose,P.wood,decor)
		part("GalleryMat",V(10.3,7.3,.1),pose*CF(0,0,.2),P.paper,decor)
		sign("GalleryCaption",title,Vector2.new(9.4,1),pose*CF(0,-2.5,.28),P.green,P.paper,decor)
		if i==1 then
			for j=1,4 do
				part("BookIllustration",V(1.2,2.8,.1),pose*CF(-3.25+j*1.35,.4,.29),({P.green,P.pink,P.gold,P.sage})[j],decor)
				part("BookSpineBand",V(1.1,.12,.12),pose*CF(-3.25+j*1.35,-.4,.36),P.paper,decor)
			end
		elseif i==2 then
			part("TinyHouseIllustration",V(4,2.7,.1),pose*CF(0,0,.29),P.sage,decor)
			part("TinyHouseWindow",V(1,1,.13),pose*CF(-.9,.3,.37),P.gold,decor)
			part("TinyHouseDoor",V(1,1.8,.13),pose*CF(.9,-.45,.37),P.green,decor)
			rod("TinyHouseRoof",(pose*CF(-2.5,1.3,.36)).Position,(pose*CF(0,2.8,.36)).Position,.3,P.rose,decor)
			rod("TinyHouseRoof",(pose*CF(0,2.8,.36)).Position,(pose*CF(2.5,1.3,.36)).Position,.3,P.rose,decor)
		else
			for j=0,4 do local a=j*math.pi*2/5;ball("BlossomWallPetal",V(1.7,1.7,.16),pose*CF(math.cos(a)*1.35,.7+math.sin(a)*1.35,.34),P.pink,decor) end
			ball("BlossomWallCenter",V(.9,.9,.22),pose*CF(0,.7,.43),P.gold,decor)
		end
	end
end

local function tableAt(name,x,z,w,d)
	local m=model(name,interests)
	part("Tabletop",V(w,.45,d),V(x,3.2,z),P.wood,m,Enum.Material.Wood,true)
	for _,sx in {-1,1} do for _,sz in {-1,1} do part("TableLeg",V(.35,3,d*.07),V(x+sx*(w/2-.6),1.5,z+sz*(d/2-.45)),P.green,m,Enum.Material.Wood,true) end end
	return m
end
local reading=tableAt("ReadingAndCrafts",473,-15,15,6)
sign("ReadingLabel","ONE MORE CHAPTER",Vector2.new(13,1.25),V(473,7.8,-20),P.green,P.paper,reading)
for i=1,6 do
	part("BookPages",V(2,.36,3),V(468,3.6+i*.4,-15),P.paper,reading)
	part("BookCover",V(2.12,.1,3.12),V(468,3.82+i*.4,-15),({P.green,P.rose,P.gold})[i%3+1],reading)
end
local kindle=part("MatchaKindle",V(2.4,.2,3.3),CF(473,3.55,-15)*CFrame.Angles(0,math.rad(-12),0),P.sage,reading)
part("KindleScreen",V(2.05,.035,2.7),kindle.CFrame*CF(0,.12,0),P.paper,reading)
for i=1,7 do part("KindleTextLine",V(1.5,.025,.04),kindle.CFrame*CF(0,.15,-1.05+i*.28),P.ink,reading) end
part("ColoringPaper",V(3,.04,3),CF(477,3.46,-14.5)*CFrame.Angles(0,.3,0),P.paper,reading)
for i=1,5 do
	rod("ColoringPencil",V(476+i*.28,3.55,-16),V(476+i*.28,3.55,-14.2),.1,({P.pink,P.sage,P.gold,P.rose,P.green})[i],reading)
end

local toys=tableAt("PlushAndMiniatures",527,-15,15,6)
sign("FavoritesLabel","LITTLE FAVORITE THINGS",Vector2.new(14,1.25),V(527,7.8,-20),P.green,P.paper,toys)
local function plush(x,z,dino)
	local c=dino and P.sage or P.wood
	ball("PlushBelly",V(2.9,2.5,2.3),V(x,4.6,z),c,toys)
	ball("PlushHead",V(2.2,1.9,1.8),V(x,6,z+.35),c,toys)
	for _,side in {-1,1} do
		ball("PlushFoot",V(.9,.7,1.1),V(x+side*.83,3.7,z+.8),c,toys)
		ball("ButtonEye",V(.16,.2,.12),V(x+side*.43,6.2,z+1.2),P.ink,toys)
		if not dino then ball("FloppyEar",V(.75,1.3,.65),V(x+side*1.02,5.9,z+.15),P.wood,toys) end
	end
	if dino then
		for i=1,4 do ball("DinoBackSpike",V(.55,.55,.55),V(x,6.4-i*.6,z-.72),P.paper,toys) end
		ball("DinoTail",V(.95,.75,2.1),V(x,4,z-1.4),c,toys)
	else ball("DogMuzzle",V(1.1,.6,.6),V(x,5.74,z+1.05),P.cream,toys);ball("DogNose",V(.27,.23,.2),V(x,5.84,z+1.4),P.ink,toys) end
end
plush(522,-14.3,false);plush(526,-14.3,true)
part("MiniatureBase",V(4,.25,3.6),V(531,3.57,-15),P.green,toys)
part("MiniatureBack",V(4,3,.18),V(531,5.1,-16.7),P.paper,toys)
part("MiniatureSide",V(.18,3,3.6),V(529.1,5.1,-15),P.paper,toys)
part("MiniatureSofa",V(2,.55,1),V(531,4,-15.5),P.pink,toys)
part("MiniatureSofaBack",V(2,1,.2),V(531,4.3,-16),P.pink,toys)
part("MiniatureTable",V(1,.15,.8),V(531,4.1,-14.1),P.wood,toys)
glow(V(532.5,6,-16.3),5,.13,toys)

local gameTable=tableAt("BirthdayBoardGames",520,23,8,5)
sign("GameLabel","COZY GAMES",Vector2.new(8,1.1),V(520,5.8,20.5),P.green,P.paper,gameTable)
part("GameBoard",V(4.4,.12,3.8),V(520,3.49,23),P.paper,gameTable)
for x=0,5 do for z=0,4 do if (x+z)%2==0 then part("BoardSquare",V(.7,.03,.7),V(518.25+x*.7,3.57,21.6+z*.7),P.sage,gameTable) end end end
for _,at in {V(518.25,3.8,21.6),V(519.65,3.8,21.6),V(521.05,3.8,24.4)} do cylinder("GamePiece",.24,.3,at,P.pink,gameTable) end
local teatable=tableAt("MatchaAndBirthdayCake",480,23,8,5)
cylinder("CakePlate",1.5,.15,V(480,3.55,23),P.paper,teatable)
cylinder("BirthdayCake",1.15,1,V(480,4.1,23),P.pink,teatable)
cylinder("CakeIcing",1.18,.15,V(480,4.64,23),P.cream,teatable)
for i=1,5 do local a=i*math.pi*2/5;ball("CakeStrawberry",V(.38,.5,.38),V(480+math.cos(a)*.8,4.9,23+math.sin(a)*.8),P.rose,teatable) end
for _,x in {477.5,482.5} do
	cylinder("MatchaCup",.5,1.2,V(x,4.03,23),P.paper,teatable)
	cylinder("MatchaTop",.43,.045,V(x,4.65,23),P.sage,teatable)
	rod("CupStraw",V(x,4.65,23),V(x+.18,5.5,23),.08,P.green,teatable)
end

local parts=0
for _,v in lobby:GetDescendants() do
	if v:IsA("BasePart") then
		parts+=1
		-- Keep the outdoor destination where it is; move only the enclosed room.
		if v~=destination then v.CFrame=CF(1500,0,0)*v.CFrame end
	end
end
lobby:SetAttribute("PartCount",parts)
return string.format("BirthdayLobby built: %d anchored parts, 8 usable seats, separate room and 60-second portal settings.",parts)
