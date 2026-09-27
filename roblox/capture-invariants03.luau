-- Read-only capture. Chunk _G.Polish03Current after execution to export evidence.
local root = assert(workspace:FindFirstChild("CozyWorld_Draft01"))
local polish = root:FindFirstChild("VisualPolish03")
local rows = {}
for _, o in root:GetDescendants() do
	if o ~= polish and (not polish or not o:IsDescendantOf(polish)) then
		local r = {path=o:GetFullName(), class=o.ClassName}
		if o:IsA("BasePart") then
			r.cframe={o.CFrame:GetComponents()}; r.size={o.Size.X,o.Size.Y,o.Size.Z}; r.color={o.Color.R,o.Color.G,o.Color.B}
			r.material=o.Material.Name; r.variant=o.MaterialVariant; r.anchored=o.Anchored; r.collide=o.CanCollide; r.touch=o.CanTouch; r.query=o.CanQuery; r.transparency=o.Transparency
		end
		if o:IsA("SpecialMesh") then r.meshType=o.MeshType.Name; r.meshId=o.MeshId; r.textureId=o.TextureId; r.scale={o.Scale.X,o.Scale.Y,o.Scale.Z}; r.offset={o.Offset.X,o.Offset.Y,o.Offset.Z} end
		if o:IsA("MeshPart") then r.meshId=o.MeshId; r.textureId=o.TextureID end
		if o:IsA("Texture") or o:IsA("Decal") then r.texture=o.Texture end
		if o:IsA("SurfaceAppearance") then r.colorMap=o.ColorMap; r.normalMap=o.NormalMap; r.roughnessMap=o.RoughnessMap; r.metalnessMap=o.MetalnessMap end
		if o:IsA("TextLabel") then r.text=o.Text end
		if o:IsA("ProximityPrompt") then r.action=o.ActionText; r.object=o.ObjectText; r.enabled=o.Enabled; r.hold=o.HoldDuration; r.distance=o.MaxActivationDistance end
		table.insert(rows,r)
	end
end
table.sort(rows,function(a,b) return a.path<b.path end)
_G.Polish03Current=rows
local scripts={}
for _,o in game:GetDescendants() do
	if o:IsA("LuaSourceContainer") then
		local ok,src=pcall(function() return o.Source end)
		if ok then table.insert(scripts,{path=o:GetFullName(),class=o.ClassName,source=src,disabled=o:IsA("BaseScript") and o.Disabled or false}) end
	end
end
table.sort(scripts,function(a,b) return a.path<b.path end)
_G.Polish03CurrentScripts=scripts
return {objects=#rows,scripts=#scripts}
