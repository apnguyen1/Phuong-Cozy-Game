-- Reference-based Quad revision. Run in Edit mode. Backups are kept in ServerStorage.
local root=workspace:WaitForChild("CozyWorld_Draft01")
local SS=game:GetService("ServerStorage")
local assets=SS.CozyDraftAssets.Reviewed
local worldOffset=root.Home.Floor.Position-Vector3.new(-28,.12,-108)
local P={}
for k,h in {forest="365744",sage="A8B995",cream="F5F0E4",wood="95674B",blossom="E8B7C6",brick="B66C68",golden="E8C779",ink="26382E"} do P[k]=Color3.fromHex(h) end
local V,CF=Vector3.new,CFrame.new
local function model(name,parent)
 local m=Instance.new("Model");m.Name=name;m.Parent=parent;return m
end
local function part(name,size,cf,token,mat,parent,collide)
 local p=Instance.new("Part");p.Name=name;p.Size=size;p.CFrame=typeof(cf)=="CFrame" and cf or CF(cf)
 p.Color=P[token];p:SetAttribute("PaletteToken",token);p.Material=mat or Enum.Material.SmoothPlastic;p.Anchored=true;p.CanCollide=collide~=false;p.CanTouch=false;p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth;p.Parent=parent;return p
end
for _,name in {"Paths","QuadPlanting"} do
 local old=root:FindFirstChild(name)
 if old then old:Destroy() end
end
local paths=model("Paths",root);paths:SetAttribute("VerificationTicket","PCW-06")
local planting=model("QuadPlanting",root);planting:SetAttribute("VerificationTicket","PCW-06")
local routes={
 {"CentralSpine",{-15,-62},{-15,134},12},
 {"CentralCross",{-94,36},{64,36},12},
 {"WestBorder",{-94,-62},{-94,134},8},
 {"EastBorder",{64,-62},{64,134},8},
 {"NorthBorder",{-94,-62},{64,-62},8},
 {"SouthBorder",{-94,134},{64,134},8},
 {"NorthDiagonalA",{-94,-62},{64,36},8},
 {"NorthDiagonalB",{64,-62},{-94,36},8},
 {"SouthDiagonalA",{-94,36},{64,134},8},
 {"SouthDiagonalB",{64,36},{-94,134},8},
 {"ArrivalConnection",{-15,134},{8,151},12},
 {"PorchApproach",{-15,-62},{-20,-76},12},
 {"WestNorthLink",{-94,-62},{-139,-62},8},
 {"WestCrossLink",{-94,36},{-139,36},12},
 {"WestSouthLink",{-94,134},{-139,134},8},
 {"DogParkUpper",{64,-62},{76,-92},8},
 {"DogParkLower",{64,-30},{76,-52},8},
 {"BirthdayUpper",{64,36},{80,20},8},
 {"BirthdayLower",{64,96},{80,86},8},
 {"WestPromenade",{-104,-144},{-104,156},8},
}
local metadata=Instance.new("Folder");metadata.Name="RouteDefinitions";metadata.Parent=paths
local function surface(token,widthExtra,y,height,name)
 local pieces={}
 for _,r in routes do
  local a,b=V(r[2][1],y,r[2][2]),V(r[3][1],y,r[3][2])
  local p=part(r[1],V(r[4]+widthExtra,height,(b-a).Magnitude+.12),CF((a+b)/2,b),token,token=="brick" and Enum.Material.Brick or Enum.Material.Concrete,paths)
  table.insert(pieces,p)
 end
 local first=table.remove(pieces,1)
 local u=first:UnionAsync(pieces,Enum.CollisionFidelity.PreciseConvexDecomposition,Enum.RenderFidelity.Automatic)
 u.Name=name;u.UsePartColor=true;u.Color=P[token];u:SetAttribute("PaletteToken",token);u.Anchored=true;u.CanTouch=false;u.Parent=paths
 first:Destroy();for _,p in pieces do p:Destroy() end
 return u
end
surface("cream",1,.10,.22,"ContinuousPathBorder")
surface("brick",0,.19,.22,"BrickWalkNetwork")
for _,r in routes do
 local a=Instance.new("Configuration");a.Name=r[1];a:SetAttribute("From",V(r[2][1],.3,r[2][2]));a:SetAttribute("To",V(r[3][1],.3,r[3][2]));a:SetAttribute("Width",r[4]);a.Parent=metadata
end
local function nearPath(x,z)
 local point=Vector2.new(x,z);local distance=math.huge
 for _,r in routes do
  local a,b=Vector2.new(r[2][1],r[2][2]),Vector2.new(r[3][1],r[3][2])
  local t=math.clamp((point-a):Dot(b-a)/(b-a):Dot(b-a),0,1)
  distance=math.min(distance,(point-(a+(b-a)*t)).Magnitude-r[4]/2)
 end
 return distance
end
local function recolor(m)
 for _,p in m:GetDescendants() do
  if p:IsA("BasePart") then
   local token=p:IsA("Seat") and "wood" or p.Material==Enum.Material.Wood and "wood" or "forest"
   p.Color=P[token];p:SetAttribute("PaletteToken",token)
   if p:IsA("UnionOperation") then p.UsePartColor=true end
   if p:IsA("Seat") then p.CanTouch=true end
  end
 end
end
local function place(kind,name,x,z,yaw,scale)
 local m=assets[kind]:Clone();m.Name=name;m.Parent=planting;m:ScaleTo(m:GetScale()*scale);m:PivotTo(CF(x,.04,z)*CFrame.Angles(0,math.rad(yaw),0))
 return m
end
local treePoints={}
for _,x in {-78,48} do
 for _,z in {-48,-22,6,64,92,120} do
  local bestZ=z
  if nearPath(x,z)<4 then for _,offset in {7,-7,12,-12} do if nearPath(x,z+offset)>=4 then bestZ=z+offset;break end end end
  table.insert(treePoints,{x,bestZ})
 end
end
for _,p in {{-78,-112},{24,-128},{56,-124},{-88,160},{48,158},{168,133},{164,-138},{-148,-151},{-138,164}} do table.insert(treePoints,p) end
for i,p in treePoints do
 local tree=place("Blossom","Cherry"..i,p[1],p[2],(i*73)%360,.85+(i%4)*.06)
 tree:SetAttribute("CommunityAssetId","12800074855")
 for _,d in tree:GetDescendants() do if d:IsA("BasePart") then
  local token=d.Name=="Flowers" and "blossom" or "wood";d.Color=P[token];d:SetAttribute("PaletteToken",token)
 end end
 local col=part("TrunkCollision",V(1.8,8,1.8),V(p[1],4.1,p[2]),"wood",nil,tree,true);col.Transparency=1;col.CanQuery=false
 -- Actual small petals, scattered in irregular rings, avoiding clear paths.
 local petals=model("FallenPetals",tree)
 for j=1,18 do
  local a=j*2.3999+i;local radius=2+(j%7)*.9;local x,z=p[1]+math.cos(a)*radius,p[2]+math.sin(a)*radius
  if nearPath(x,z)>1 then
   local leaf=part("Petal",V(.35+.04*(j%3),.07,.58),CF(x,.10,z)*CFrame.Angles(0,a,0),j%5==0 and "cream" or "blossom",nil,petals,false);leaf.Shape=Enum.PartType.Ball
  end
 end
end
for i,p in {{-103,-100},{-103,78},{74,-4},{74,117},{-30,146},{1,-53}} do
 local lamp=place("Lantern","PathLantern"..i,p[1],p[2],0,.84);recolor(lamp)
 for _,d in lamp:GetDescendants() do if d:IsA("MeshPart") then d.TextureID="" end;if d:IsA("PointLight") then d.Color=P.golden;d.Brightness=.35 end;if d:IsA("BasePart") and d.Name=="Lamp Glass" then d.Color=P.golden;d:SetAttribute("PaletteToken","golden") end end
end
for i,p in {{-64,43,180},{32,29,0},{-65,-54,180},{37,126,0}} do
 local bench=place("Bench","ReadingBench"..i,p[1],p[2],p[3],1.12);recolor(bench)
 bench:SetAttribute("Activity","Reading and gathering")
 -- Stone feet and a little side table with closed book.
 local x,z=p[1]+6,p[2]
 part("BookTableLeg",V(.7,2.7,.7),V(x,1.45,z),"wood",Enum.Material.Wood,planting)
 part("BookTableTop",V(3,.3,3),V(x,2.95,z),"wood",Enum.Material.Wood,planting)
 part("BookPages",V(1.3,.22,1.9),V(x,3.25,z),"cream",nil,planting,false)
 part("BookCover",V(1.5,.08,2.1),V(x,3.4,z),"forest",nil,planting,false)
end
-- Smaller planted beds have actual stems, leaves, and flower heads instead of three bare balls.
local gardens={{-66,145},{-39,140},{30,147},{-44,-66},{14,-71},{-112,11},{73,53}}
for i,g in gardens do
 local m=model("FlowerBed"..i,planting)
 local x,z=g[1],g[2]
 local bed=part("Mulch",V(8,.16,4),V(x,.12,z),"wood",Enum.Material.Ground,m,false)
 for j=1,8 do
  local xx,zz=x-3+(j%4)*1.8,z-.9+math.floor((j-1)/4)*1.7
  local h=1.1+(j%3)*.3
  part("Stem",V(.12,h,.12),V(xx,h/2+.2,zz),"forest",nil,m,false)
  for k=0,4 do local a=k*math.pi*2/5
   local p=part("FlowerPetal",V(.65,.18,.9),CF(xx+math.cos(a)*.32,h+.2,zz+math.sin(a)*.32)*CFrame.Angles(0,-a,0),j%2==0 and "blossom" or "cream",nil,m,false);p.Shape=Enum.PartType.Ball
  end
  local center=part("FlowerCenter",V(.35,.22,.35),V(xx,h+.25,zz),"golden",nil,m,false);center.Shape=Enum.PartType.Ball
  for s=-1,1,2 do local l=part("Leaf",V(.7,.12,.28),CF(xx+s*.32,h*.55,zz)*CFrame.Angles(0,0,s*.35),"sage",nil,m,false);l.Shape=Enum.PartType.Ball end
 end
end
local function textSign(x,z,word)
 local m=model("QuadWayfinding",planting)
 part("Post",V(.5,4,.5),V(x,2,z),"wood",Enum.Material.Wood,m)
 local p=part("Plaque",V(8,2,.3),V(x,4,z),"forest",nil,m,false)
 local gui=Instance.new("SurfaceGui");gui.Face=Enum.NormalId.Back;gui.CanvasSize=Vector2.new(600,150);gui.LightInfluence=.15;gui.Parent=p
 local t=Instance.new("TextLabel");t.Size=UDim2.fromScale(1,1);t.BackgroundTransparency=1;t.Text=word;t.TextColor3=P.cream;t.Font=Enum.Font.GothamMedium;t.TextScaled=true;t.Parent=gui
end
textSign(-26,137,"The Blossom Quad")
textSign(73,-63,"Jasper's park")
textSign(72,98,"Birthday courtyard")
local ground=root.Landscape.QuadGround;ground.Color=P.sage;ground:SetAttribute("PaletteToken","sage")
workspace.Baseplate.Color=P.sage
root:SetAttribute("DraftVersion","02")
root:SetAttribute("Scope","UW-inspired brick Quad, referenced bedroom, birthday lobby and named stores")
-- The user may move the complete world between revisions; retain that placement.
paths:PivotTo(CF(worldOffset)*paths:GetPivot())
planting:PivotTo(CF(worldOffset)*planting:GetPivot())
for _,r in metadata:GetChildren() do
 r:SetAttribute("From",r:GetAttribute("From")+worldOffset)
 r:SetAttribute("To",r:GetAttribute("To")+worldOffset)
end
paths:SetAttribute("WorldOffset",worldOffset)
return "Quad: central cross, four full diagonal paths making two X panels, perimeter walks, 21 trees and four reading benches."
