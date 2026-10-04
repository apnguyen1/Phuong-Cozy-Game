-- Read-only release capture, run against the actual Server play model after
-- presentation has been exercised. Runtime geometry is intentionally not saved
-- into the Edit place. The independent verifier must re-obtain this capture.
local root = assert(workspace:FindFirstChild("CozyWorld_Draft01"), "Expected world missing")
local mvp = assert(root:FindFirstChild("MVP"), "Expected MVP missing")
local runtime = assert(mvp:FindFirstChild("RuntimePresentation"), "Runtime presentation missing")
local parts, textures, roots = {}, {}, {}
-- Roblox permits siblings with identical names. Preserve the native full name
-- for inspection, but identify each captured instance by its sibling indices.
-- This is read-only; production names, geometry and palette checks stay intact.
local paths = {[runtime] = runtime:GetFullName()}
local function indexChildren(parent)
    for index, child in ipairs(parent:GetChildren()) do
        paths[child] = paths[parent] .. ".[" .. tostring(index) .. "]" .. child.Name
        indexChildren(child)
    end
end
indexChildren(runtime)
local function texture(instance, property, contentId)
    if contentId ~= "" then
        table.insert(textures, {path=paths[instance],original_full_name=instance:GetFullName(),property=property,content_id=contentId})
    end
end
for _, child in ipairs(runtime:GetChildren()) do
    table.insert(roots,{path=paths[child],original_full_name=child:GetFullName(),ticket=child:GetAttribute("VerificationTicket")})
end
for _, instance in ipairs(runtime:GetDescendants()) do
    if instance:IsA("BasePart") then
        table.insert(parts, {path=paths[instance],original_full_name=instance:GetFullName(),class=instance.ClassName,
            token=instance:GetAttribute("PaletteToken") or "",hex="#"..instance.Color:ToHex():upper(),
            material=instance.Material.Name,material_variant=instance.MaterialVariant,
            anchored=instance.Anchored,can_collide=instance.CanCollide,
            size={instance.Size.X,instance.Size.Y,instance.Size.Z}})
    end
    if instance:IsA("MeshPart") then texture(instance,"TextureID",instance.TextureID)
    elseif instance:IsA("SpecialMesh") then texture(instance,"TextureId",instance.TextureId)
    elseif instance:IsA("Decal") then texture(instance,"Texture",instance.Texture)
    elseif instance:IsA("SurfaceAppearance") then texture(instance,"ColorMap",instance.ColorMap) end
end
table.sort(parts,function(a,b) return a.path<b.path end)
table.sort(roots,function(a,b) return a.path<b.path end)
return game:GetService("HttpService"):JSONEncode({schema_version=1,ticket_id="PCW-25",
    root=runtime:GetFullName(),captured_at=DateTime.now():ToIsoDate(),place_id=game.PlaceId,
    capture_context="Server runtime; owned release presentation only",owned_roots=roots,
    parts=parts,textures=textures})
