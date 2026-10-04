-- Permanent export of live SFX client. Replace the old LocalScript, do not add a second copy.
local Players = game:GetService("Players")
local SoundService = game:GetService("SoundService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContentProvider = game:GetService("ContentProvider")
local player = Players.LocalPlayer
if SoundService:FindFirstChild("CozySoundEffectsLocal") then return end
local specs = {
    SoftClick={id="88442833509532",volume=.18}, SuccessChime={id="103516326607012",volume=.22},
    JasperBark={id="135016436724006",volume=.25}, JasperPant={id="6463651038",volume=.10},
}
local root = ReplicatedStorage:FindFirstChild("PhuongMVP")
local shared = root and root:FindFirstChild("shared")
local configModule = shared and shared:FindFirstChild("AudioConfig")
if configModule and configModule:IsA("ModuleScript") then
    local ok, config = pcall(require,configModule)
    if ok and type(config)=="table" and type(config.Effects)=="table" then specs=config.Effects end
end
if type(player:GetAttribute("CozyEffectsEnabled")) ~= "boolean" then player:SetAttribute("CozyEffectsEnabled",true) end
local folder = Instance.new("Folder")
folder.Name, folder.Parent = "CozySoundEffectsLocal", SoundService
local group = Instance.new("SoundGroup")
group.Name, group.Parent = "EffectsVolume", folder
local destroyed, cooldown, lastChime, seenCount = false, -math.huge, -math.huge, 0
local connections, buttons, seen, loads, previousGroups, pendingSpatial = {}, {}, {}, {}, {}, {}
local trySpatial
local function enabled() return player:GetAttribute("CozyEffectsEnabled") ~= false end
local function setVolume() group.Volume = enabled() and 1 or 0 end
setVolume()
table.insert(connections, player:GetAttributeChangedSignal("CozyEffectsEnabled"):Connect(setVolume))
local function cancelThread(thread)
    if thread and coroutine.status(thread) ~= "dead" then pcall(task.cancel,thread) end
end
local function makeSound(name)
    local spec = specs[name]
    local templates = SoundService:FindFirstChild("CozySoundEffects")
    local original = templates and templates:FindFirstChild(name)
    local sound = original and original:IsA("Sound") and original:Clone() or Instance.new("Sound")
    sound.Name, sound.SoundId, sound.Volume = name, "rbxassetid://"..spec.id, spec.volume
    sound.Looped, sound.SoundGroup, sound.Parent = false, group, folder
    sound.PlayOnRemove = false
    local entry = {sound=sound,status="Loading"}
    loads[name] = entry
    folder:SetAttribute(name.."Status",entry.status)
    local function finish(status)
        if destroyed or entry.status ~= "Loading" then return end
        entry.status = status; folder:SetAttribute(name.."Status",status)
        if entry.loaded then entry.loaded:Disconnect(); entry.loaded=nil end
        if trySpatial then
            for pending in pairs(pendingSpatial) do if pending.Name==name then trySpatial(pending) end end
        end
    end
    entry.loaded = sound.Loaded:Connect(function() if sound.IsLoaded then finish("Loaded") end end)
    entry.worker = task.defer(function()
        local ok = pcall(function()
            ContentProvider:PreloadAsync({sound},function(_,status)
                if status ~= Enum.AssetFetchStatus.Success then finish("Unavailable") end
            end)
        end)
        if destroyed then return end
        if sound.IsLoaded then finish("Loaded") elseif not ok then finish("Unavailable") end
    end)
    entry.timeout = task.delay(8,function()
        if destroyed or entry.status ~= "Loading" then return end
        finish(sound.IsLoaded and "Loaded" or "Timed out")
        cancelThread(entry.worker)
    end)
    return entry
end
local click, chime = makeSound("SoftClick"), makeSound("SuccessChime")
makeSound("JasperBark"); makeSound("JasperPant")
local function play(entry)
    if destroyed or not enabled() or entry.status ~= "Loaded" then return end
    pcall(function() entry.sound.TimePosition=0; entry.sound:Play() end)
end
local function bindButton(button)
    if not button:IsA("GuiButton") or buttons[button] then return end
    local record = {}
    buttons[button] = record
    record.activated = button.Activated:Connect(function()
        if not button.Active or not button.Interactable or os.clock()-cooldown < .08 then return end
        cooldown = os.clock(); play(click)
    end)
    record.destroying = button.Destroying:Connect(function()
        record.activated:Disconnect(); record.destroying:Disconnect(); buttons[button]=nil
    end)
end
local boundGui, boundRoots, boundRemotes = {}, {}, {}
local function bindGui(gui)
    if not gui:IsA("PlayerGui") or boundGui[gui] then return end
    boundGui[gui]=true
    table.insert(connections,gui.DescendantAdded:Connect(bindButton))
    for _,child in ipairs(gui:GetDescendants()) do bindButton(child) end
end
local function bindRemote(remote)
    if remote.Name~="Action" or not remote:IsA("RemoteEvent") or boundRemotes[remote] then return end
    boundRemotes[remote]=true
    table.insert(connections,remote.OnClientEvent:Connect(function(payload)
        if type(payload)~="table" or payload.kind~="Result" or payload.ok~=true then return end
        if string.lower(tostring(payload.code))=="duplicate" or type(payload.result)=="table" and string.lower(tostring(payload.result.code))=="duplicate" then return end
        local receipt=payload.receipt
        local completion=type(receipt)=="table" and (type(receipt.completion)=="table" and receipt.completion or receipt) or nil
        local code=string.lower(tostring(payload.code))
        local complete=code=="completed" or code=="round_completed" or completion and completion.petalGranted==true
        local identity=completion and (completion.receiptId or completion.actionId) or payload.actionId
        if not complete or type(identity)~="string" then return end
        local key=tostring(payload.sessionId)..":"..identity
        if seen[key] or seenCount>=4096 then return end
        seen[key],seenCount=true,seenCount+1
        if os.clock()-lastChime<1 then return end
        lastChime=os.clock(); play(chime)
    end))
end
local function bindRoot(candidate)
    if candidate.Name~="PhuongMVP" or boundRoots[candidate] then return end
    boundRoots[candidate]=true
    table.insert(connections,candidate.ChildAdded:Connect(bindRemote))
    for _,child in ipairs(candidate:GetChildren()) do bindRemote(child) end
end
trySpatial=function(sound)
    if destroyed or not sound.Parent then pendingSpatial[sound]=nil; return end
    local entry=loads[sound.Name]
    if not entry or entry.status=="Loading" then return end
    pendingSpatial[sound]=nil
    if entry.status~="Loaded" or not enabled() then return end
    local emitted=sound:GetAttribute("CozyEmittedAt")
    local lifetime=sound:GetAttribute("CozyLifetime")
    if type(emitted)~="number" or type(lifetime)~="number" then return end
    local elapsed=math.max(0,workspace:GetServerTimeNow()-emitted)
    if elapsed>=lifetime or entry.sound.TimeLength>0 and elapsed>=entry.sound.TimeLength then return end
    pcall(function() sound.TimePosition=elapsed; sound:Play() end)
end
-- A local SoundGroup also silences replicated Jasper sounds for this listener.
local function bindSpatial(sound)
    if not sound:IsA("Sound") or sound:IsDescendantOf(folder) or previousGroups[sound] then return end
    local spec=specs[sound.Name]
    if not spec or sound.SoundId~="rbxassetid://"..spec.id then return end
    if sound:GetAttribute("CozySoundEffect")~=true and not (sound.Parent and sound.Parent.Name=="JasperAudioEmitter") then return end
    previousGroups[sound]={group=sound.SoundGroup}
    sound.SoundGroup=group
    local connection
    connection=sound.Destroying:Connect(function()
        previousGroups[sound]=nil
        pendingSpatial[sound]=nil
        connection:Disconnect()
    end)
    previousGroups[sound].connection=connection
    if sound:GetAttribute("CozyAutoPlay")==true then pendingSpatial[sound]=true; trySpatial(sound) end
end
table.insert(connections,workspace.DescendantAdded:Connect(bindSpatial))
for _,child in ipairs(workspace:GetDescendants()) do bindSpatial(child) end
table.insert(connections,player.ChildAdded:Connect(bindGui))
for _,child in ipairs(player:GetChildren()) do bindGui(child) end
table.insert(connections,ReplicatedStorage.ChildAdded:Connect(bindRoot))
for _,child in ipairs(ReplicatedStorage:GetChildren()) do bindRoot(child) end
local function destroy()
    if destroyed then return end
    destroyed=true
    for _,connection in ipairs(connections) do connection:Disconnect() end
    for _,record in pairs(buttons) do record.activated:Disconnect(); record.destroying:Disconnect() end
    for sound,record in pairs(previousGroups) do
        record.connection:Disconnect()
        if sound.Parent and sound:GetAttribute("CozyAutoPlay")==true then sound:Stop() end
        if sound.Parent and sound.SoundGroup==group then sound.SoundGroup=record.group end
    end
    for _,entry in pairs(loads) do
        if entry.loaded then entry.loaded:Disconnect() end
        cancelThread(entry.worker); cancelThread(entry.timeout)
    end
    folder:Destroy()
    table.clear(buttons); table.clear(previousGroups); table.clear(seen); table.clear(pendingSpatial)
end
table.insert(connections,script.Destroying:Connect(destroy))
table.insert(connections,folder.Destroying:Connect(destroy))
