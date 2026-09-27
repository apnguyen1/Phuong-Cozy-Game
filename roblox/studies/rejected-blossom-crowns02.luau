-- Rejected visual study, not part of the Draft 02 build sequence.
-- Broad spherical crowns lost the community tree's detailed silhouette.
local SS=game.ServerStorage
local old=workspace:FindFirstChild("SoftBlossomStudy");if old then old:Destroy() end
local t=Instance.new("Model");t.Name="SoftBlossomStudy";t.Parent=workspace
local trunk=SS.CozyDraftAssets.Reviewed.Blossom.Tree:Clone();trunk.TextureID="";trunk.Color=Color3.fromHex("#95674B");trunk.Material=Enum.Material.Wood;trunk:SetAttribute("PaletteToken","wood");trunk.Parent=t
local rng=Random.new(2409)
local clusters={{-8,20,-3,6.5},{0,26,0,7},{8,21,1,6.2},{-3,20,7,6.4},{3,20,-7,6.5}}
for ci,c in clusters do
 local petals={}
 for j=1,18 do
  local a=j*2.399963;local r=math.sqrt(j/18)*c[4]
  local p=Instance.new("Part");p.Name="BlossomPetal";p.Shape=Enum.PartType.Ball
  local s=3+rng:NextNumber()*2
  p.Size=Vector3.new(s,s*.65,s*.85)
  p.CFrame=CFrame.new(c[1]+math.cos(a)*r,c[2]+rng:NextNumber(-2,2)+3*(1-j/18),c[3]+math.sin(a)*r)*CFrame.Angles(0,a,rng:NextNumber(-.4,.4))
  p.Color=Color3.fromHex("#E8B7C6");p.Material=Enum.Material.SmoothPlastic;p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.Parent=t
  table.insert(petals,p)
 end
 local first=table.remove(petals,1)
 local u=first:UnionAsync(petals,Enum.CollisionFidelity.Hull,Enum.RenderFidelity.Automatic)
 u.Name="BlossomCrown"..ci;u.UsePartColor=true;u.Color=Color3.fromHex("#E8B7C6");u:SetAttribute("PaletteToken","blossom");u.Anchored=true;u.CanCollide=false;u.CanTouch=false;u.Parent=t
 first:Destroy();for _,p in petals do p:Destroy() end
end
t.WorldPivot=CFrame.new();t:PivotTo(CFrame.new(-72,0,160))
return "Five baked overlapping petal crowns built with original community trunk, no color textures."
