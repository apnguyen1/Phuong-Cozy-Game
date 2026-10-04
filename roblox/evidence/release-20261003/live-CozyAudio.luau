local SoundService = game:GetService("SoundService")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local templates = SoundService:WaitForChild("CozySoundEffects")
local anchors = workspace:WaitForChild("CozyWorld_Draft01"):WaitForChild("MVP"):WaitForChild("Anchors")
local lastBark = -math.huge
local Audio = {}
local function emit(name, host, lifetime)
    if not host then return end
    local sound = templates:FindFirstChild(name)
    if not sound then return end
    local attachment = host:FindFirstChild("JasperAudioEmitter")
    if not attachment then attachment = Instance.new("Attachment"); attachment.Name = "JasperAudioEmitter"; attachment.Parent = host end
    local copy = sound:Clone()
    copy.Parent = attachment
    copy:Play()
    Debris:AddItem(copy, lifetime)
end
function Audio.Accepted(request, result)
    if request.activityId ~= "Q02" or result.ok == false or result.code == "duplicate" then return end
    local step = request.stepId
    if step ~= "greet" and step ~= "pet" and step ~= "greenie" and not string.match(step or "", "^fetch%d$") then return end
    if os.clock() - lastBark < 4 then return end
    lastBark = os.clock()
    emit("JasperBark", anchors:FindFirstChild(step == "greet" and "JasperBedroomStart" or "JasperFetchYard"), 5)
end
task.spawn(function()
    while script.Parent do
        task.wait(math.random(25, 45))
        if os.clock() - lastBark >= 8 then
            local target
            for _, player in Players:GetPlayers() do
                local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                if root and player:GetAttribute("BirthdayLocation") == "World" then
                    for _, name in {"JasperFetchYard", "JasperBedroomStart"} do
                        local host = anchors:FindFirstChild(name)
                        if host and (root.Position - host.Position).Magnitude < 30 then target = host; break end
                    end
                end
                if target then break end
            end
            if target then emit("JasperPant", target, 4) end
        end
    end
end)
return Audio

