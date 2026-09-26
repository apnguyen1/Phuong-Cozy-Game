-- Read-only Studio capture. Change these two values for the assigned ticket.
-- Run through Studio's command bar or execute_luau in the selected EDIT datamodel.
-- The builder sets VerificationTicket on the authored root, and PaletteToken on
-- each authored BasePart. Keep player avatars, terrain and sky outside this root.
local TICKET_ID = "PCW-04"
local ROOT_PATH = { "Workspace", "PCW04Bedroom" }

local root: Instance = game
for _, name in ROOT_PATH do
    local child = root:FindFirstChild(name)
    assert(child, "Missing verification root component: " .. name)
    root = child
end
assert(root:GetAttribute("VerificationTicket") == TICKET_ID, "Wrong ticket root")

local parts = {}
local textures = {}
local instances = root:GetDescendants()
table.insert(instances, 1, root)
local function texture(instance: Instance, property: string, contentId: string)
    if contentId ~= "" then
        table.insert(textures, {
            path = instance:GetFullName(),
            property = property,
            content_id = contentId,
        })
    end
end
for _, instance in instances do
    if instance:IsA("BasePart") then
        table.insert(parts, {
            path = instance:GetFullName(),
            class = instance.ClassName,
            token = instance:GetAttribute("PaletteToken") or "",
            hex = "#" .. instance.Color:ToHex():upper(),
            material = instance.Material.Name,
            material_variant = instance.MaterialVariant,
            anchored = instance.Anchored,
            can_collide = instance.CanCollide,
            size = { instance.Size.X, instance.Size.Y, instance.Size.Z },
        })
    end
    if instance:IsA("MeshPart") then
        texture(instance, "TextureID", instance.TextureID)
    elseif instance:IsA("SpecialMesh") then
        texture(instance, "TextureId", instance.TextureId)
    elseif instance:IsA("Decal") then
        texture(instance, "Texture", instance.Texture)
    elseif instance:IsA("SurfaceAppearance") then
        texture(instance, "ColorMap", instance.ColorMap)
    end
end
table.sort(parts, function(a, b) return a.path < b.path end)
return game:GetService("HttpService"):JSONEncode({
    schema_version = 1,
    ticket_id = TICKET_ID,
    root = root:GetFullName(),
    captured_at = DateTime.now():ToIsoDate(),
    place_id = game.PlaceId,
    parts = parts,
    textures = textures,
})
