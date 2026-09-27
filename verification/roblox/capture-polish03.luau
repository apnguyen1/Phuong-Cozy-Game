-- Independent read-only Edit capture. Set page indices when collecting large output.
local FIRST_INDEX = 1
local LAST_INDEX = 150
local root = workspace:FindFirstChild("CozyWorld_Draft01")
assert(root, "Missing world root")
root = root:FindFirstChild("VisualPolish03")
assert(root and root:GetAttribute("VerificationTicket") == "MAP-03", "Missing or incorrect revision folder")
local instances = root:GetDescendants()
table.insert(instances, root)
table.sort(instances, function(a,b) return a:GetFullName() < b:GetFullName() end)
local parts, others, textures = {}, {}, {}
local function texture(item, property, value)
    if value ~= "" then
        table.insert(textures, {path=item:GetFullName(), property=property, content_id=value})
    end
end
for index = FIRST_INDEX, math.min(LAST_INDEX, #instances) do
    local item = instances[index]
    if item:IsA("BasePart") then
        table.insert(parts, {
            path=item:GetFullName(), class=item.ClassName,
            token=item:GetAttribute("PaletteToken") or "", hex="#"..item.Color:ToHex():upper(),
            material=item.Material.Name, material_variant=item.MaterialVariant,
            anchored=item.Anchored, can_collide=item.CanCollide, can_touch=item.CanTouch, can_query=item.CanQuery,
            size={item.Size.X,item.Size.Y,item.Size.Z}, cframe={item.CFrame:GetComponents()},
        })
    else
        local record = {path=item:GetFullName(), class=item.ClassName}
        if item:IsA("SpecialMesh") then
            record.mesh_type=item.MeshType.Name
            record.mesh_id=item.MeshId
            record.texture_id=item.TextureId
            record.scale={item.Scale.X,item.Scale.Y,item.Scale.Z}
        end
        table.insert(others, record)
    end
    if item:IsA("MeshPart") then texture(item,"TextureID",item.TextureID)
    elseif item:IsA("SpecialMesh") then texture(item,"TextureId",item.TextureId)
    elseif item:IsA("Decal") then texture(item,"Texture",item.Texture)
    elseif item:IsA("SurfaceAppearance") then texture(item,"ColorMap",item.ColorMap) end
end
return game:GetService("HttpService"):JSONEncode({
    schema_version=1, ticket_id="MAP-03", root=root:GetFullName(),
    captured_at=DateTime.now():ToIsoDate(), place_id=game.PlaceId,
    instances_total=#instances, page_first=FIRST_INDEX, page_last=math.min(LAST_INDEX,#instances),
    parts=parts, non_part_instances=others, textures=textures,
})
