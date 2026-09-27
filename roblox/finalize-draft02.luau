-- Apply after the four Draft 02 builders. Preserves the user's moved world.
local root=workspace:WaitForChild("CozyWorld_Draft01")
local palette={forest="365744",sage="A8B995",cream="F5F0E4",wood="95674B",blossom="E8B7C6",brick="B66C68",golden="E8C779",ink="26382E"}
local colors={};for token,hex in palette do colors[token]=Color3.fromHex(hex) end
local recolored,ellipsoids,renamed=0,0,0
for _,p in root:GetDescendants() do
 if p:IsA("BasePart") then
  local token=p:GetAttribute("PaletteToken")
  if not colors[token] then
   local closest=math.huge
   for name,color in colors do
    local distance=(p.Color.R-color.R)^2+(p.Color.G-color.G)^2+(p.Color.B-color.B)^2
    if distance<closest then closest=distance;token=name end
   end
   if p.Material==Enum.Material.Neon then token="golden"
   elseif p.Material==Enum.Material.Wood or p.Material==Enum.Material.WoodPlanks then token="wood"
   elseif string.find(p.Name,"Wall") then token="cream" end
   p:SetAttribute("PaletteToken",token);recolored+=1
  end
  p.Color=colors[token]
  if p:IsA("UnionOperation") then p.UsePartColor=true end
  -- Roblox balls do not reliably provide elongated silhouettes. Use the built-in
  -- sphere mesh for intentionally unequal axes, without external mesh or texture IDs.
  if p:IsA("Part") and p.Shape==Enum.PartType.Ball and not p:FindFirstChildOfClass("SpecialMesh") and (math.abs(p.Size.X-p.Size.Y)>.01 or math.abs(p.Size.Y-p.Size.Z)>.01) then
   p.Shape=Enum.PartType.Block
   local mesh=Instance.new("SpecialMesh");mesh.Name="Ellipsoid";mesh.MeshType=Enum.MeshType.Sphere;mesh.Parent=p
   ellipsoids+=1
  end
 end
end
-- Opaque interior blinds need a continuous window surface that the default
-- zoom camera recognizes. More transparent glass let the view sit outside,
-- with the blind slats obscuring the player. Keep the original window collision.
for _,p in root.Home:GetChildren() do
 if p:IsA("BasePart") and p.Name:find("WindowGlass") then
  p.Transparency=.2;p.Color=colors.cream;p:SetAttribute("PaletteToken","cream")
 end
end
-- Keep unique lookup names stable; number only subsequent repeated siblings.
-- This also makes the verification capture's full paths unambiguous.
local function uniqueChildren(parent)
 local used,seen={},{}
 for _,c in parent:GetChildren() do used[c.Name]=true end
 for _,c in parent:GetChildren() do
  local name=c.Name
  if seen[name] then
   local number=2
   while used[string.format("%s_%03d",name,number)] do number+=1 end
   c.Name=string.format("%s_%03d",name,number);used[c.Name]=true;renamed+=1
  else seen[name]=true end
  uniqueChildren(c)
 end
end
uniqueChildren(root)
local markers=root:FindFirstChild("ConnectionMarkers")
if markers then
 local routes=root.Paths.RouteDefinitions
 markers.Arrival_Main.Position=routes.ArrivalConnection:GetAttribute("To")
 markers.House_Approach.Position=routes.PorchApproach:GetAttribute("From")
end
root:SetAttribute("VerificationTicket","MAP-02")
root:SetAttribute("DraftVersion","02")
root:SetAttribute("FinalizationRevision",1)
game:GetService("ChangeHistoryService"):SetWaypoint("Draft 02 integration and unique evidence paths")
return {recolored=recolored,ellipsoids=ellipsoids,renamed=renamed}
