-- PCW-26: one local controller, independent of activity panels and actions.
local SoundService = game:GetService("SoundService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContentProvider = game:GetService("ContentProvider")
local RunService = game:GetService("RunService")
local Module = {}
local instance

function Module.Init(getContext, registry)
    if instance then return instance end
    local initial = getContext()
    local player, UI = initial.player, initial.UI
    local playerGui = player:FindFirstChildOfClass("PlayerGui")
    if not playerGui or SoundService:FindFirstChild("CozyMusicLocal") then return end
    local config = {
        Music={Birthday={id="87992648461099",title="Birthday song",volume=.22},World={id="139568344220252",title="Slow Mornings · gentle acoustic guitar",volume=.18}},
        DefaultMusicVolume=.5,VolumeStep=.25,CrossfadeSeconds=.65,LoadTimeoutSeconds=8,
    }
    local configuration = "Exact-ID fallback"
    local root=ReplicatedStorage:FindFirstChild("PhuongMVP")
    local shared=root and root:FindFirstChild("shared")
    local source=shared and shared:FindFirstChild("AudioConfig")
    if source and source:IsA("ModuleScript") then
        local ok,value=pcall(require,source)
        if ok and type(value)=="table" and type(value.Music)=="table" then config=value; configuration="AudioConfig" end
    end
    if type(player:GetAttribute("CozyMusicMuted"))~="boolean" then player:SetAttribute("CozyMusicMuted",false) end
    if type(player:GetAttribute("CozyMusicVolume"))~="number" then player:SetAttribute("CozyMusicVolume",config.DefaultMusicVolume) end
    if type(player:GetAttribute("CozyEffectsEnabled"))~="boolean" then player:SetAttribute("CozyEffectsEnabled",true) end
    local folder=Instance.new("Folder")
    folder.Name,folder.Parent="CozyMusicLocal",SoundService
    folder:SetAttribute("Configuration",configuration)
    local overlay=Instance.new("ScreenGui")
    overlay.Name,overlay.ResetOnSpawn,overlay.IgnoreGuiInset="CozyAudioControls",false,false
    overlay.DisplayOrder,overlay.ZIndexBehavior=24,Enum.ZIndexBehavior.Sibling
    overlay.ScreenInsets=Enum.ScreenInsets.CoreUISafeInsets
    overlay.Parent=playerGui
    local bar=Instance.new("Frame")
    bar.Name,bar.AnchorPoint,bar.Position="AudioBar",Vector2.new(.5,0),UDim2.new(.5,0,0,8)
    bar.BackgroundColor3,bar.BorderSizePixel=UI.Palette.cream,0
    bar.Parent=overlay; UI.Corner(bar)
    -- Main and the optional camera reserve this band, including on phones.
    initial.gui:SetAttribute("AudioControlsInset",64)
    local destroyed,latest,currentSession,mode,modeKey=false,initial.snapshot.cake,nil,"Quiet",nil
    local tracks,connections,runs={}, {}, {}
    local mute,lower,raise,sfx,launcher
    local expanded=false
    local refresh,chooseMode
    local function volume() return math.clamp(player:GetAttribute("CozyMusicVolume") or config.DefaultMusicVolume,0,1) end
    local function muted() return player:GetAttribute("CozyMusicMuted")==true end
    local function cancelThread(thread)
        if thread and coroutine.status(thread)~="dead" then pcall(task.cancel,thread) end
    end
    local function status(track,value)
        track.status=value
        track.sound:SetAttribute("LoadStatus",value)
        folder:SetAttribute(track.name.."Status",value)
    end
    local function setTarget(track,target)
        if track.target==target then return end
        track.from,track.target,track.fadeAt=track.sound.Volume,target,os.clock()
    end
    local function pause(track)
        if track.sound.IsPlaying then pcall(function() track.sound:Pause() end) end
    end
    local function createTrack(name,spec)
        local sound=Instance.new("Sound")
        sound.Name,sound.SoundId,sound.Volume=name,"rbxassetid://"..spec.id,0
        sound.Looped=name=="World"
        sound.Parent=folder
        local track={name=name,spec=spec,sound=sound,status="Loading",target=0,from=0,fadeAt=os.clock(),wanted=false}
        tracks[name]=track; status(track,"Loading")
        local function finish(value)
            if destroyed or track.status~="Loading" then return end
            status(track,value)
            if track.loaded then track.loaded:Disconnect(); track.loaded=nil end
            if refresh then refresh() end
        end
        track.loaded=sound.Loaded:Connect(function() if sound.IsLoaded then finish("Loaded") end end)
        track.worker=task.defer(function()
            local ok=pcall(function()
                ContentProvider:PreloadAsync({sound},function(_,fetchStatus)
                    if fetchStatus~=Enum.AssetFetchStatus.Success then finish("Unavailable") end
                end)
            end)
            if destroyed then return end
            if sound.IsLoaded then finish("Loaded") elseif not ok then finish("Unavailable") end
        end)
        track.timeout=task.delay(config.LoadTimeoutSeconds,function()
            if destroyed or track.status~="Loading" then return end
            finish(sound.IsLoaded and "Loaded" or "Timed out")
            cancelThread(track.worker)
        end)
        table.insert(connections,sound.Ended:Connect(function()
            if destroyed or name~="Birthday" or mode~="Finale" then return end
            local run=runs[modeKey]
            if run then run.finished=true end
            if refresh then refresh() end
        end))
    end
    createTrack("Birthday",config.Music.Birthday)
    createTrack("World",config.Music.World)
    local function finaleKey(state,session)
        return tostring(session)..":"..tostring(state.generation)
    end
    local function skipMatches(state,session)
        return initial.gui:GetAttribute("FinaleSkippedSessionId")==session
            and initial.gui:GetAttribute("FinaleSkippedGeneration")==state.generation
    end
    chooseMode=function()
        local context=getContext()
        local session=context.sessionId
        if session~=currentSession then
            currentSession=session; table.clear(runs)
        end
        local location=player:GetAttribute("BirthdayLocation")
        if location=="Lobby" then return "Lobby","Lobby" end
        if location~="World" then return "Quiet","Quiet" end
        local state=latest
        if type(session)=="string" and type(state)=="table" and (state.phase or state.finaleState)=="CELEBRATING"
            and type(state.generation)=="number" and state.generation>0
            and type(state.startedAt)=="number" and type(state.endsAt)=="number"
            and workspace:GetServerTimeNow()>=state.startedAt and workspace:GetServerTimeNow()<state.endsAt then
            local key=finaleKey(state,session)
            local run=runs[key]
            if not run then run={started=false}; runs[key]=run end
            if skipMatches(state,session) then run.skipped=true end
            if not run.skipped and not run.finished then return "Finale",key end
        end
        return "World","World"
    end
    local function start(track)
        if track.status~="Loaded" or not track.wanted then return end
        if track.sound.IsPlaying then return end
        local ok=pcall(function()
            if track.name=="Birthday" and mode=="Finale" then
                local run=runs[modeKey]
                if not run or run.started or run.skipped or run.finished then return end
                -- Seek only after loading, including when that finishes late.
                local elapsed=math.max(0,workspace:GetServerTimeNow()-latest.startedAt)
                if workspace:GetServerTimeNow()>=latest.endsAt or track.sound.TimeLength>0 and elapsed>=track.sound.TimeLength then
                    run.finished=true; return
                end
                track.sound.Looped=false
                track.sound.TimePosition=elapsed
                run.started=true
                folder:SetAttribute("FinaleStartedKey",modeKey)
                track.sound:Play()
            else
                track.sound.Looped=true
                -- Resume paused ambient tracks instead of restarting on snapshots.
                if track.ambientStarted then track.sound:Resume()
                else track.ambientStarted=true; track.sound:Play() end
            end
        end)
        if not ok then status(track,"Playback unavailable") end
    end
    local function drawControls()
        local level=math.floor(volume()*100+.5)
        local selected=mode=="World" and tracks.World or (mode=="Lobby" or mode=="Finale") and tracks.Birthday or nil
        local state=selected and selected.status
        if muted() or level==0 then mute.Text="Music off\nUnmute"
        elseif state and state~="Loaded" then mute.Text=state=="Loading" and "Music loading\nMute" or "Music unavailable\nMute"
        else mute.Text="Music "..level.."%\nMute" end
        sfx.Text=player:GetAttribute("CozyEffectsEnabled")==false and "SFX off" or "SFX on"
        if launcher then
            local label=(muted() or level==0) and "Music off" or state and state~="Loaded" and (state=="Loading" and "Loading" or "Unavailable") or "Music on"
            launcher.Text=expanded and "Close audio" or "Audio\n"..label
        end
        UI.SetEnabled(lower,level>0,true); UI.SetEnabled(raise,level<100,true)
        folder:SetAttribute("MusicMuted",muted()); folder:SetAttribute("MusicVolume",volume())
        folder:SetAttribute("EffectsEnabled",player:GetAttribute("CozyEffectsEnabled")~=false)
    end
    refresh=function()
        if destroyed then return end
        local nextMode,nextKey=chooseMode()
        if nextMode~=mode or nextKey~=modeKey then
            local previous=mode
            mode,modeKey=nextMode,nextKey
            folder:SetAttribute("Mode",mode); folder:SetAttribute("TimelineKey",modeKey)
            -- Only one Birthday sound is used for lobby and finale, never two players.
            if mode=="Finale" or previous=="Finale" and mode=="Lobby" then
                tracks.Birthday.sound:Stop(); tracks.Birthday.sound.Volume=0
                tracks.Birthday.target,tracks.Birthday.from=0,0
                tracks.Birthday.ambientStarted=false
            end
        end
        tracks.World.wanted=mode=="World"
        tracks.Birthday.wanted=mode=="Lobby" or mode=="Finale"
        for _,track in pairs(tracks) do
            start(track)
            local target=track.wanted and track.status=="Loaded" and not muted() and volume()*track.spec.volume or 0
            setTarget(track,target)
        end
        drawControls()
    end
    mute=UI.Button(bar,"MusicMute","Music",function()
        local turnOn=muted() or volume()==0
        player:SetAttribute("CozyMusicMuted",not turnOn)
        if turnOn and volume()==0 then player:SetAttribute("CozyMusicVolume",config.DefaultMusicVolume) end
    end)
    lower=UI.Button(bar,"VolumeDown","Vol −",function() player:SetAttribute("CozyMusicVolume",math.max(0,volume()-config.VolumeStep)) end,true)
    raise=UI.Button(bar,"VolumeUp","Vol +",function()
        player:SetAttribute("CozyMusicVolume",math.min(1,volume()+config.VolumeStep)); player:SetAttribute("CozyMusicMuted",false)
    end,true)
    sfx=UI.Button(bar,"EffectsToggle","SFX on",function() player:SetAttribute("CozyEffectsEnabled",player:GetAttribute("CozyEffectsEnabled")==false) end,true)
    for _,button in ipairs({mute,lower,raise,sfx}) do button.TextSize=14 end
    local layout
    launcher=UI.Button(overlay,"AudioOptions","Audio",function() expanded=not expanded; layout(); drawControls() end,true)
    launcher.Position,launcher.Size=UDim2.fromOffset(8,8),UDim2.fromOffset(84,48)
    launcher.TextSize=14
    local activityPanel=initial.gui:FindFirstChild("ActivityPanel")
    layout=function()
        local size=overlay.AbsoluteSize
        -- Landscape uses the clear left gutter beside the centered panel. The
        -- collapsed control keeps activity content height; expand only on demand.
        local compact=size.X>=650 or size.X>size.Y and activityPanel and activityPanel.Visible
        launcher.Visible=compact==true
        bar.Visible=not compact or expanded
        local inset=bar.Visible and 64 or 0
        if initial.gui:GetAttribute("AudioControlsInset")~=inset then initial.gui:SetAttribute("AudioControlsInset",inset) end
        local width=math.min(390,math.max(274,overlay.AbsoluteSize.X-24))
        bar.Size=UDim2.fromOffset(width,56)
        local musicWidth=width-186
        mute.Position,mute.Size=UDim2.fromOffset(4,4),UDim2.fromOffset(musicWidth,48)
        lower.Position,lower.Size=UDim2.fromOffset(musicWidth+10,4),UDim2.fromOffset(48,48)
        raise.Position,raise.Size=UDim2.fromOffset(musicWidth+64,4),UDim2.fromOffset(48,48)
        sfx.Position,sfx.Size=UDim2.fromOffset(musicWidth+118,4),UDim2.fromOffset(64,48)
    end
    table.insert(connections,overlay:GetPropertyChangedSignal("AbsoluteSize"):Connect(layout))
    if activityPanel then table.insert(connections,activityPanel:GetPropertyChangedSignal("Visible"):Connect(function() expanded=false; layout(); drawControls() end)) end
    for _,attribute in ipairs({"CozyMusicMuted","CozyMusicVolume","CozyEffectsEnabled"}) do
        table.insert(connections,player:GetAttributeChangedSignal(attribute):Connect(refresh))
    end
    table.insert(connections,player:GetAttributeChangedSignal("BirthdayLocation"):Connect(refresh))
    table.insert(connections,initial.gui:GetAttributeChangedSignal("FinaleSkippedSessionId"):Connect(refresh))
    table.insert(connections,initial.gui:GetAttributeChangedSignal("FinaleSkippedGeneration"):Connect(refresh))
    registry.RegisterObserver("MusicController",function(payload,context)
        if destroyed then return end
        local state=payload.cake or payload.snapshot and payload.snapshot.cake or context.snapshot.cake
        if type(state)=="table" then latest=state end
        if payload.kind=="FinaleCameraSkipped" and payload.sessionId==context.sessionId and type(payload.generation)=="number" and payload.generation>0 then
            local key=finaleKey(payload,payload.sessionId)
            runs[key]=runs[key] or {}; runs[key].skipped=true
        end
        refresh()
    end)
    registry.RegisterPanel("AudioStatus",{
        title="Audio status",label="Audio status",
        visible=function(context) return context.snapshot.host and context.snapshot.host.authorized==true end,
        render=function(container)
            UI.Label(container,"AudioStatusTitle","Music and sound effects · this listener",20,UI.Palette.forest).LayoutOrder=1
            UI.Label(container,"AudioMode","Current music: "..mode.." · "..configuration,16).LayoutOrder=2
            for index,name in ipairs({"Birthday","World"}) do
                local track=tracks[name]
                UI.Label(container,name.."Load",track.spec.title.." · "..track.spec.id.." · "..track.status,16).LayoutOrder=index+2
            end
            local effects=SoundService:FindFirstChild("CozySoundEffectsLocal")
            for index,name in ipairs({"SoftClick","SuccessChime","JasperBark","JasperPant"}) do
                UI.Label(container,name.."Load",name..": "..tostring(effects and effects:GetAttribute(name.."Status") or "Client unavailable"),15).LayoutOrder=index+4
            end
            UI.Label(container,"AudioLimit","Unavailable or timed out audio stays quiet for this session. Asset access must be checked in the published experience. Loading is not an audition.",15).LayoutOrder=10
        end,
    })
    local tick=0
    table.insert(connections,RunService.Heartbeat:Connect(function(dt)
        if destroyed then return end
        for _,track in pairs(tracks) do
            local progress=math.clamp((os.clock()-track.fadeAt)/config.CrossfadeSeconds,0,1)
            local eased=progress*progress*(3-2*progress)
            track.sound.Volume=track.from+(track.target-track.from)*eased
            if track.name=="Birthday" and mode=="Finale" and latest and type(latest.endsAt)=="number" then
                local remaining=math.clamp((latest.endsAt-workspace:GetServerTimeNow())/config.CrossfadeSeconds,0,1)
                track.sound.Volume*=remaining -- Land softly at the shared end, not an abrupt twelve-second cut.
            end
            if progress==1 and not track.wanted then pause(track) end
        end
        tick+=dt
        if tick>=.1 then tick=0; refresh() end -- Ends on shared time even without another snapshot.
    end))
    local function destroy()
        if destroyed then return end
        destroyed=true
        for _,connection in ipairs(connections) do connection:Disconnect() end
        for _,track in pairs(tracks) do
            if track.loaded then track.loaded:Disconnect() end
            cancelThread(track.worker); cancelThread(track.timeout)
            track.sound:Stop()
        end
        registry.observers.MusicController=nil; registry.panels.AudioStatus=nil
        if initial.gui.Parent then initial.gui:SetAttribute("AudioControlsInset",nil) end
        folder:Destroy(); overlay:Destroy(); instance=nil
    end
    table.insert(connections,initial.gui.Destroying:Connect(destroy))
    table.insert(connections,overlay.Destroying:Connect(destroy))
    table.insert(connections,folder.Destroying:Connect(destroy))
    table.insert(connections,script.Destroying:Connect(destroy))
    instance={Destroy=destroy}
    layout(); refresh()
    return instance
end
return Module
