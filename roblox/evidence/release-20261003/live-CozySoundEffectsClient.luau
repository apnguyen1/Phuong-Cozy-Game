local Players = game:GetService("Players")
local SoundService = game:GetService("SoundService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContentProvider = game:GetService("ContentProvider")
local player = Players.LocalPlayer
local gui = player:WaitForChild("PlayerGui")
local effects = SoundService:WaitForChild("CozySoundEffects")
local click = effects:WaitForChild("SoftClick")
local chime = effects:WaitForChild("SuccessChime")
local cooldown = -math.huge
local connected = setmetatable({}, {__mode = "k"})
local function bind(button)
    if not button:IsA("GuiButton") or connected[button] then return end
    connected[button] = true
    button.Activated:Connect(function()
        if not button.Active or not button.Interactable or os.clock() - cooldown < .08 then return end
        cooldown = os.clock()
        click.TimePosition = 0
        SoundService:PlayLocalSound(click)
    end)
end
gui.DescendantAdded:Connect(bind)
for _, button in gui:GetDescendants() do bind(button) end
local seen = {}
local lastChime = -math.huge
ReplicatedStorage:WaitForChild("PhuongMVP"):WaitForChild("Action").OnClientEvent:Connect(function(payload)
    if type(payload) ~= "table" or payload.kind ~= "Result" or payload.ok ~= true then return end
    local receipt = payload.receipt
    local complete = payload.code == "completed" or (type(receipt) == "table" and receipt.petalGranted == true)
    if not complete or not payload.actionId or seen[payload.actionId] then return end
    seen[payload.actionId] = true
    if os.clock() - lastChime < 1 then return end
    lastChime = os.clock()
    SoundService:PlayLocalSound(chime)
end)
task.spawn(function()
    local ok, err = pcall(function() ContentProvider:PreloadAsync(effects:GetChildren()) end)
    if not ok then warn("Cozy sound preload:", err) end
end)

