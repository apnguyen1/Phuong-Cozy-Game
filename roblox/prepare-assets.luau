-- Draft 01: derive static reusable templates from inspected Creator Store models.
local storage = game:GetService("ServerStorage")
local library = storage:WaitForChild("CozyDraftAssets")
assert(not library:FindFirstChild("Reviewed"), "Reviewed templates already exist")
local clean = Instance.new("Folder")
clean.Name = "Reviewed"
clean.Parent = library
local raw = library.Incoming
local function strip(model)
	for _,v in model:GetDescendants() do
		if v:IsA("LuaSourceContainer") or v:IsA("Humanoid") or v:IsA("Animator") or v:IsA("Animation") or v:IsA("KeyframeSequence") or v:IsA("ParticleEmitter") or v:IsA("BillboardGui") or v:IsA("JointInstance") or v:IsA("Constraint") or v:IsA("PackageLink") then
			v:Destroy()
		elseif v:IsA("BasePart") then
			v.Anchored = true
			v.CanTouch = false
			v.CastShadow = true
		end
	end
end
local function normalize(model)
	local cf,size = model:GetBoundingBox()
	local shift = CFrame.new(-cf.X, -(cf.Y-size.Y/2), -cf.Z)
	for _,p in model:GetDescendants() do
		if p:IsA("BasePart") then p.CFrame=shift*p.CFrame end
	end
	model.WorldPivot = CFrame.new()
end
local tree=Instance.new("Model")
tree.Name="Blossom"
tree.Parent=clean
tree:SetAttribute("AssetId","12800074855")
for _,p in raw.BlossomSource:GetDescendants() do
	if p:IsA("MeshPart") then local c=p:Clone();c.Parent=tree;c.CanCollide=false end
end
strip(tree)
normalize(tree)
local _,ts=tree:GetBoundingBox()
tree:ScaleTo(32/ts.Y)
local lamp=raw.LanternSource:Clone()
lamp.Name="Lantern"
lamp.Parent=clean
lamp:SetAttribute("AssetId","14212653287")
strip(lamp)
for _,v in lamp:GetDescendants() do
	if v:IsA("Light") then v:Destroy()
	elseif v:IsA("BasePart") then
		v.CanCollide=false
		if v.Name=="Lamp Glass" then
			v.Material=Enum.Material.Neon
			v.Color=Color3.fromRGB(255,224,165)
			local l=Instance.new("PointLight")
			l.Color=Color3.fromRGB(255,217,161)
			l.Brightness=.4
			l.Range=14
			l.Shadows=false
			l.Parent=v
		else
			v.Material=Enum.Material.SmoothPlastic
			v.Color=Color3.fromRGB(50,74,59)
		end
	end
end
normalize(lamp)
local bench=raw.BenchSource:Clone()
bench.Name="Bench"
bench.Parent=clean
bench:SetAttribute("AssetId","741384218")
strip(bench)
for _,p in bench:GetDescendants() do
	if p:IsA("BasePart") then
		if p:IsA("Seat") then p.CanCollide=true;p.CanTouch=true
		elseif p.Material==Enum.Material.Wood then p.Color=Color3.fromRGB(146,101,66)
		else p.Material=Enum.Material.SmoothPlastic;p.Color=Color3.fromRGB(48,68,55) end
	end
end
normalize(bench)
local petals=Instance.new("Model")
petals.Name="Petals"
petals.Parent=clean
petals:SetAttribute("AssetId","12071076692")
for _,p in raw.PetalsSource:GetDescendants() do
	if p:IsA("BasePart") and p:FindFirstChildOfClass("SpecialMesh") then
		local c=p:Clone();c.Parent=petals;c.Material=Enum.Material.SmoothPlastic;c.CanCollide=false
		break
	end
end
strip(petals)
for _,v in petals:GetDescendants() do if v:IsA("Light") then v:Destroy() end end
normalize(petals)
local sky=raw.SkySource:Clone()
sky.Name="CozySky"
sky.Parent=clean
local out={}
for _,v in clean:GetChildren() do
	if v:IsA("Model") then local _,s=v:GetBoundingBox();table.insert(out,v.Name.." "..tostring(s)) end
end
return table.concat(out,"\n")
