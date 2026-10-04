-- Permanent export of live CozyAudio, with nonblocking dependencies and dedupe.
-- Cosmetic only: Accepted never throws into Main's authoritative action path.
local SoundService = game:GetService("SoundService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")
local Audio = {}
local effects = {
    SoftClick = {id="88442833509532",volume=.18}, SuccessChime = {id="103516326607012",volume=.22},
    JasperBark = {id="135016436724006",volume=.25}, JasperPant = {id="6463651038",volume=.10},
}
local shared = script.Parent.Parent:FindFirstChild("shared")
local configModule = shared and shared:FindFirstChild("AudioConfig")
if configModule and configModule:IsA("ModuleScript") then
    local ok, config = pcall(require, configModule)
    if ok and type(config) == "table" and type(config.Effects) == "table" then effects = config.Effects end
end
local destroyed, lastBark, elapsed, nextPant = false, -math.huge, 0, math.random(25,45)
local seen, seenCount, live, ownedAttachments, connections = {}, 0, {}, {}, {}
local function anchors()
    local world = workspace:FindFirstChild("CozyWorld_Draft01")
    local mvp = world and world:FindFirstChild("MVP")
    return mvp and mvp:FindFirstChild("Anchors")
end
local function template(name)
    local spec = effects[name]
    if not spec then return nil end
    local folder = SoundService:FindFirstChild("CozySoundEffects")
    if not folder then
        folder = Instance.new("Folder"); folder.Name = "CozySoundEffects"; folder.Parent = SoundService
    end
    local sound = folder:FindFirstChild(name)
    if sound and not sound:IsA("Sound") then return nil end
    if not sound then
        sound = Instance.new("Sound"); sound.Name = name; sound.Parent = folder
    end
    sound.SoundId, sound.Volume = "rbxassetid://"..spec.id, spec.volume
    sound.Looped, sound.RollOffMinDistance, sound.RollOffMaxDistance = false, 6, 45
    sound.PlayOnRemove = false
    sound:SetAttribute("CozySoundEffect", true)
    return sound
end
local function emit(name, host, lifetime)
    if destroyed or not host or not host:IsA("BasePart") then return end
    local sound = template(name)
    if not sound then return end
    local attachment = host:FindFirstChild("JasperAudioEmitter")
    if attachment and not attachment:IsA("Attachment") then return end
    if not attachment then
        attachment = Instance.new("Attachment"); attachment.Name = "JasperAudioEmitter"; attachment.Parent = host
        ownedAttachments[attachment] = true
    end
    local copy = sound:Clone()
    copy:SetAttribute("CozySoundEffect", true)
    copy:SetAttribute("CozyAutoPlay", true)
    copy:SetAttribute("CozyEmittedAt", workspace:GetServerTimeNow())
    copy:SetAttribute("CozyLifetime", lifetime)
    copy.Parent = attachment
    live[copy] = true
    -- Each listener plays this one short-lived emission only after its bounded
    -- preload succeeds. Failed asset access never causes repeated server Play.
    Debris:AddItem(copy, lifetime)
end
function Audio.Accepted(request, result)
    if destroyed or type(request) ~= "table" or type(result) ~= "table" then return end
    if request.activityId ~= "Q02" or result.ok == false or string.lower(tostring(result.code)) == "duplicate" then return end
    if type(request.actionId) ~= "string" or request.actionId == "" then return end
    local step = request.stepId
    if type(step) ~= "string" then return end
    if step ~= "greet" and step ~= "pet" and step ~= "greenie" and not string.match(step or "", "^fetch%d$") then return end
    local id = tostring(request.sessionId)..":"..request.actionId
    if seen[id] or seenCount >= 4096 then return end
    seen[id], seenCount = true, seenCount + 1 -- Remember even when cooldown suppresses the sound.
    if os.clock()-lastBark < 4 then return end
    lastBark = os.clock()
    pcall(function()
        local root = anchors()
        emit("JasperBark", root and root:FindFirstChild(step == "greet" and "JasperBedroomStart" or "JasperFetchYard"), 5)
    end)
end
function Audio.Destroy()
    if destroyed then return end
    destroyed = true
    for _, connection in ipairs(connections) do connection:Disconnect() end
    for sound in pairs(live) do if sound.Parent then sound:Destroy() end end
    for attachment in pairs(ownedAttachments) do if attachment.Parent then attachment:Destroy() end end
    table.clear(live); table.clear(ownedAttachments); table.clear(seen)
end
-- Missing containers/anchors are looked up when needed, never waited on.
pcall(function() for name in pairs(effects) do template(name) end end)
table.insert(connections, RunService.Heartbeat:Connect(function(dt)
    if destroyed then return end
    elapsed += dt
    if elapsed < nextPant then return end
    elapsed, nextPant = 0, math.random(25,45)
    for sound in pairs(live) do if not sound.Parent then live[sound] = nil end end
    if os.clock()-lastBark < 8 then return end
    pcall(function()
        local root = anchors()
        if not root then return end
        for _, player in ipairs(Players:GetPlayers()) do
            local body = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            if body and player:GetAttribute("BirthdayLocation") == "World" then
                for _, name in ipairs({"JasperFetchYard", "JasperBedroomStart"}) do
                    local host = root:FindFirstChild(name)
                    if host and host:IsA("BasePart") and (body.Position-host.Position).Magnitude < 30 then
                        emit("JasperPant", host, 4); return
                    end
                end
            end
        end
    end)
end))
table.insert(connections, script.Destroying:Connect(Audio.Destroy))
return Audio
