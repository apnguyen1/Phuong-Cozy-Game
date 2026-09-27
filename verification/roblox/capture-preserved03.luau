-- Independent read-only capture of the same original-scene fields as scene-baseline.json.
-- Root metadata and the new VisualPolish03 subtree are deliberately outside the comparison.
local FIRST_INDEX = 1
local LAST_INDEX = 150
local root = workspace:FindFirstChild("CozyWorld_Draft01")
assert(root, "Missing original world")
local added = root:FindFirstChild("VisualPolish03")
local objects = {}
for _, item in root:GetDescendants() do
    if item ~= added and not (added and item:IsDescendantOf(added)) then table.insert(objects,item) end
end
table.sort(objects,function(a,b) return a:GetFullName()<b:GetFullName() end)
local records = {}
local function vector(v) return {v.X,v.Y,v.Z} end
for index = FIRST_INDEX, math.min(LAST_INDEX,#objects) do
    local item=objects[index]
    local r={path=item:GetFullName(),class=item.ClassName}
    if item:IsA("BasePart") then
        r.cframe={item.CFrame:GetComponents()};r.size=vector(item.Size)
        r.color={item.Color.R,item.Color.G,item.Color.B};r.material=item.Material.Name
        r.variant=item.MaterialVariant;r.anchored=item.Anchored
        r.collide=item.CanCollide;r.touch=item.CanTouch;r.query=item.CanQuery;r.transparency=item.Transparency
    end
    if item:IsA("MeshPart") then r.meshId=item.MeshId;r.textureId=item.TextureID end
    if item:IsA("SpecialMesh") then
        r.meshId=item.MeshId;r.textureId=item.TextureId;r.meshType=item.MeshType.Name
        r.scale=vector(item.Scale);r.offset=vector(item.Offset)
    end
    if item:IsA("SurfaceAppearance") then
        r.colorMap=item.ColorMap;r.normalMap=item.NormalMap
        r.roughnessMap=item.RoughnessMap;r.metalnessMap=item.MetalnessMap
    end
    if item:IsA("TextLabel") then r.text=item.Text end
    if item:IsA("ProximityPrompt") then
        r.enabled=item.Enabled;r.action=item.ActionText;r.object=item.ObjectText
        r.distance=item.MaxActivationDistance;r.hold=item.HoldDuration
    end
    table.insert(records,r)
end
return game:GetService("HttpService"):JSONEncode({
    captured_at=DateTime.now():ToIsoDate(),objects_total=#objects,
    page_first=FIRST_INDEX,page_last=math.min(LAST_INDEX,#objects),objects=records,
})
