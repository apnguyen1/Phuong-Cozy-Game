_G.__PCW25ContractText..=[==[erlay.IgnoreGuiInset = "BirthdayMoment", false, false
    overlay.DisplayOrder, overlay.ZIndexBehavior = 18, Enum.ZIndexBehavior.Sibling
    overlay.ScreenInsets = Enum.ScreenInsets.CoreUISafeInsets
    overlay.Parent = player:WaitForChild("PlayerGui")
    local banner = Instance.new("Frame")
    banner.Name, banner.AnchorPoint, banner.Position = "BirthdayChoice", Vector2.new(.5,0), UDim2.new(.5,0,0,8)
    banner.BackgroundColor3, banner.BorderSizePixel, banner.Visible = P.cream, 0, false
    banner.Parent = overlay; UI.Corner(banner)
    local headline = UI.Label(banner, "HappyBirthday", "Happy Birthday, Phuong!", 21, P.forest)
    headline.Font, headline.AutomaticSize = Enum.Font.GothamBold, Enum.AutomaticSize.None
    headline.Position, headline.Size = UDim2.fromOffset(12,9), UDim2.new(1,-24,0,32)
    local subtitle = UI.Label(banner, "CameraHint", "An optional birthday view · keep exploring freely", 14)
    subtitle.AutomaticSize, subtitle.Position, subtitle.Size = Enum.AutomaticSize.None, UDim2.fromOffset(12,43), UDim2.new(1,-24,0,38)
    local watch, skip
    local function key(state)
        return tostring(getContext().sessionId) .. ":" .. tostring(state and state.generation or 0)
    end
    local function inWorld() return player:GetAttribute("BirthdayLocation") == "World" end
    local function human()
        local character = player.Character
        return character and character:FindFirstChildOfClass("Humanoid")
    end
    local function isLive(state)
        return state and state.phase == "CELEBRATING" and type(state.startedAt) == "number"
            and type(state.endsAt) == "number" and workspace:GetServerTimeNow() < state.endsAt
    end
    local function notify(kind, reason, state)
        local context = getContext()
        registry.Notify({ kind = kind, reason = reason, generation = state and state.generation,
            sessionId = context.sessionId, startedAt = state and state.startedAt, endsAt = state and state.endsAt }, context)
    end
    local function restore(reason, markSkipped)
        local state = active and active.state or latest
        if markSkipped and state then
            skipped[key(state)] = true
            -- Stable late-subscriber hook for MusicController. Client-only.
            initial.gui:SetAttribute("FinaleSkippedSessionId", getContext().sessionId)
            initial.gui:SetAttribute("FinaleSkippedGeneration", state.generation)
        end
        local saved = active
        active = nil
        if saved then
            if saved.render then saved.render:Disconnect() end
            if saved.death then saved.death:Disconnect() end
            local humanoid = human()
            local sameSubject = saved.subject and saved.subject.Parent and humanoid == saved.humanoid and humanoid.Health > 0
            if saved.camera.Parent then
                pcall(function()
                    saved.camera.CameraType = sameSubject and saved.cameraType or Enum.CameraType.Custom
                    saved.camera.CameraSubject = sameSubject and saved.subject or humanoid
                    saved.camera.FieldOfView = saved.fov
                    saved.camera.CFrame = saved.frame
                end)
            end
            local current = workspace.CurrentCamera
            if current and current ~= saved.camera and inWorld() then
                current.CameraType = Enum.CameraType.Custom
                current.CameraSubject = humanoid
            end
            if initial.gui.Parent then initial.gui.Enabled = saved.guiEnabled end
            notify("FinaleCameraReturned", reason, saved.state)
        end
        if markSkipped then notify("FinaleCameraSkipped", reason, state) end
        banner.Visible = false
    end
    local function showOffer()
        if destroyed then return end
        local allowed = inWorld() and isLive(latest) and not skipped[key(latest)]
        banner.Visible = allowed == true
        if not allowed then return end
        offeredKey = key(latest)
        watch.Visible = active == nil
        skip.Position = active and UDim2.fromOffset(12,84) or UDim2.new(.5,4,0,84)
        skip.Size = active and UDim2.new(1,-24,0,52) or UDim2.new(.5,-16,0,52)
        subtitle.Text = active and "Your camera only · Skip / Return at any time" or "An optional birthday view · keep exploring freely"
    end
    local function startCamera()
        if active or not inWorld() or not isLive(latest) then return end
        local center = latest.scene and latest.scene.center
        local camera, humanoid = workspace.CurrentCamera, human()
        if not center or not camera or not humanoid or humanoid.Health <= 0 then
            getContext().toast("The birthday view is unavailable. Enjoy the celebration with your usual camera.")
            return
        end
        local focus = Vector3.new(center.x, center.y+3, center.z)
        local body = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if not body or (body.Position-focus).Magnitude > 65 then
            getContext().toast("Walk closer to the birthday table to watch the optional view.")
            return
        end
        local context = getContext()
        context.close()
        local saved = { camera = camera, cameraType = camera.CameraType, subject = camera.CameraSubject,
            frame = camera.CFrame, fov = camera.FieldOfView, humanoid = humanoid, seat = humanoid.SeatPart,
            state = latest, focus = focus, guiEnabled = initial.gui.Enabled }
        active = saved
        initial.gui.Enabled = false
        camera.CameraType = Enum.CameraType.Scriptable
        camera.FieldOfView = 60
        saved.death = humanoid.Died:Connect(function() restore("death", true) end)
        saved.render = RunService.RenderStepped:Connect(function()
            if active ~= saved then return end
            if not inWorld() or player.Character ~= humanoid.Parent or humanoid.Health <= 0 or camera ~= workspace.CurrentCamera then
                restore("camera-or-character-changed", true); return
            end
            if humanoid.MoveDirection.Magnitude > .1 or (saved.seat and humanoid.SeatPart ~= saved.seat) then
                restore("returned-to-exploring", true); return
            end
            if not isLive(latest) or key(latest) ~= key(saved.state) then restore("complete", false); return end
            local progress = math.clamp((workspace:GetServerTimeNow()-saved.state.startedAt)/saved.state.duration,0,1)
            local angle = -.6 + progress*1.2
            local eye = focus + Vector3.new(math.sin(angle)*31,10+math.sin(progress*math.pi)*2,math.cos(angle)*28)
            camera.CFrame = CFrame.lookAt(eye,focus)
        end)
        showOffer()
        notify("FinaleCameraStarted", "opted-in", latest)
    end
    watch = UI.Button(banner, "WatchBirthday", "Watch birthday view", startCamera)
    watch.Position, watch.Size = UDim2.fromOffset(12,84), UDim2.new(.5,-16,0,52)
    skip = UI.Button(banner, "SkipBirthday", "Skip / Return", function() restore("skip", true) end, true)
    local function layout()
        banner.Size = UDim2.fromOffset(math.min(432,math.max(256,overlay.AbsoluteSize.X-24)),148)
        banner.Position = UDim2.new(.5,0,0,8+(initial.gui:GetAttribute("AudioControlsInset") or 0))
    end
    table.insert(connections, overlay:GetPropertyChangedSignal("AbsoluteSize"):Connect(layout))
    table.insert(connections, initial.gui:GetAttributeChangedSignal("AudioControlsInset"):Connect(layout))
    table.insert(connections, UserInputService.InputBegan:Connect(function(input, processed)
        if not processed and input.KeyCode == Enum.KeyCode.Escape and (active or banner.Visible) then restore("skip", true) end
    end))
    table.insert(connections, workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
        if active then restore("camera-replaced", true) end
    end))
    table.insert(connections, player.CharacterAdded:Connect(function(character)
        confirmation = nil
        task.spawn(function()
            local humanoid = character:WaitForChild("Humanoid",10)
            if destroyed or player.Character ~= character then return end
            -- Default camera scripts choose the new live character; repair only
            -- an orphaned subject from our own prior optional view.
            local camera = workspace.CurrentCamera
            if humanoid and camera and inWorld() and (not camera.CameraSubject or not camera.CameraSubject.Parent) then
                camera.CameraType, camera.CameraSubject = Enum.CameraType.Custom, humanoid
            end
        end)
    end))
    local elapsed = 0
    table.insert(connections, RunService.Heartbeat:Connect(function(dt)
        elapsed += dt; if elapsed < .2 then return end; elapsed = 0
        if active and not isLive(latest) then restore("complete",false) end
        if banner.Visible and not isLive(latest) then banner.Visible = false end
    end))

    registry.RegisterActivity("Cake", function(container, state, context)
        local card = UI.Card(container, "CakeChoices", "blossom"); card.LayoutOrder = 3
        UI.Label(card, "SeatHelp", "Ten real seats · Phuong's marked seat is at the west end. Guests can use the other nine.",16).LayoutOrder = 1
        if state.hasEaten then UI.Label(card,"SavedCake","✓ Your cake moment is saved. Another bite is cosmetic.",16,P.forest).LayoutOrder=2
        elseif state.sliceTaken then UI.Label(card,"SavedSlice","✓ Your slice is ready to enjoy.",16,P.forest).LayoutOrder=2 end
        local fresh
        for _, descriptor in ipairs(state.availableActions or {}) do
            if confirmation and descriptor.id == confirmation.id and descriptor.generation == confirmation.generation and descriptor.enabled ~= false then fresh=descriptor end
        end
        if not fresh then confirmation=nil end
        local function sendChoice(descriptor)
            local current=getContext()
            if current.pending then return end
            confirmation=nil
            if current.send({kind="Cake",action=descriptor.action,generation=descriptor.generation}) then current.refresh() end
        end
        if fresh then
            UI.Label(card,"ConfirmTitle",fresh.confirm.title,18,P.forest).LayoutOrder=3
            UI.Label(card,"ConfirmDetail",fresh.confirm.detail,16).LayoutOrder=4
            local confirm=UI.Button(card,"ConfirmCake",fresh.confirm.label,function() sendChoice(fresh) end)
            confirm.LayoutOrder=5; UI.SetEnabled(confirm,not context.pending)
            UI.Button(card,"CancelCake","Keep gathering",function() confirmation=nil; getContext().refresh() end,true).LayoutOrder=6
        else
            for index,descriptor in ipairs(state.availableActions or {}) do
                local button=UI.Button(card,"CakeAction"..index,context.pending and "Saving..." or descriptor.label,function()
                    if descriptor.confirm then confirmation={id=descriptor.id,generation=descriptor.generation}; getContext().refresh()
                    else sendChoice(descriptor) end
                end)
                button.LayoutOrder=index*2+2; UI.SetEnabled(button,not context.pending and descriptor.enabled~=false)
                if descriptor.enabled==false then UI.Label(card,"Unavailable"..index,descriptor.reason,14).LayoutOrder=index*2+3 end
            end
        end
        UI.Label(card,"FreePlay","Close to explore or sit with your friends. Leaving the view does not undo the celebration or your slice.",14).LayoutOrder=80
    end)

    registry.RegisterObserver("FinalePresentation", function(payload, context)
        if destroyed then return end
        if payload.kind == "FinaleCameraSkipped" or payload.kind == "FinaleCameraReturned" or payload.kind == "FinaleCameraStarted" then return end
        if payload.kind == "HostTravel" or payload.kind == "CharacterRemoving" or payload.kind == "LocationChanged" and not payload.inWorld then
            confirmation=nil; restore(payload.kind,true); return
        end
        if payload.kind == "PanelClosed" then confirmation=nil end
        local state=payload.cake or payload.snapshot and payload.snapshot.cake or context.snapshot.cake
        if state then latest=state end
        if inWorld() and latest and latest.invitation then
            local invitation=tostring(context.sessionId)..":"..tostring(latest.unlockedAt)
            if invitationKey~=invitation then
                invitationKey=invitation
                context.track("Cake","FinalePatio")
                context.toast(latest.cutAt and "Birthday cake is ready! Come to the patio for your slice and photos."
                    or latest.phase=="CELEBRATING" and "Happy Birthday, Phuong! Join the celebration at the patio."
                    or latest.phase=="CAKE_READY" and "The birthday table is ready for Phuong's first cut."
                    or "All six petals! Gather at the birthday table. Guests sit first, then Phuong's marked seat.")
            end
        end
        if active and not isLive(latest) then restore("complete",false) end
        if isLive(latest) and (offeredKey~=key(latest) or payload.kind=="LocationChanged") then showOffer() end
        if payload.kind=="Result" and payload.result and payload.result.message and payload.result.receipt and payload.result.receipt.activityId=="Cake" then
            confirmation=nil; context.toast(payload.result.message,payload.ok==false)
        end
    end)
    local function destroy()
        if destroyed then return end
        restore("destroyed",true); destroyed=true
        for _,connection in ipairs(connections) do connection:Disconnect() end
        registry.activities.Cake=nil; registry.observers.FinalePresentation=nil
        overlay:Destroy()
    end
    table.insert(connections, initial.gui.Destroying:Connect(destroy))
    table.insert(connections, script.Destroying:Connect(destroy))
    table.insert(connections, overlay.Destroying:Connect(function() if not destroyed then destroy() end end))
    layout()
end

return Module
]=],
["roblox/mvp/client/extensions/HostControls.luau"] = [=[-- Presentation only. Every recovery is prepared and confirmed on the server.
local Module = {}
local QUESTS = { {"Q01","Bed"},{"Q02","Jasper"},{"Q03","Craft"},{"Q04","Reading"},{"Q05","Labubu wish"},{"Q06","Food"} }
function Module.Init(getContext, registry)
    local selectedQuest, expanded, dismissedToken = "Q01", "quest", nil
    local lastSession, lastResult
    local showAllAudit = false
    local function request(value)
        local context=getContext()
        if context.pending then context.toast("Wait for your last choice to finish."); return end
        value.kind="Host"
        if context.send(value) then context.refresh() end
    end
    local function isHost(context)
        return context.snapshot.host and context.snapshot.host.authorized==true and context.player:GetAttribute("BirthdayLocation")=="World"
    end
    registry.RegisterPanel("HostControls",{
        label="Host controls",title="Host controls",visible=isHost,
        render=function(container,context)
            local host=context.snapshot.host
            if not isHost(context) then context.UI.Label(container,"HostUnavailable","Host controls are available to Phuong and Andrew in the world.",16); return end
            if lastSession~=context.sessionId then lastSession=context.sessionId; dismissedToken=nil end
            local UI=context.UI
            local banner=UI.Card(container,"HostState",#host.activeOverrides>0 and "golden" or "sage"); banner.LayoutOrder=1
            UI.Label(banner,"Mode",#host.activeOverrides>0 and "HOST OVERRIDE · "..table.concat(host.activeOverrides,", ") or "Normal choices",18).LayoutOrder=1
            UI.Label(banner,"Authority",host.hint,14).LayoutOrder=2
            local petals=0; for _,done in pairs(host.petals) do if done then petals+=1 end end
            UI.Label(banner,"CurrentSharedState","Shared fund "..host.fundBalance.." · "..petals.."/6 petals",16).LayoutOrder=3
            local toggle=UI.Button(banner,"ToggleHostOverride",host.override and "End my Override" or "Enable my Override",function()
                dismissedToken=nil; request({action="SetOverride",enabled=not getContext().snapshot.host.override})
            end,host.override)
            toggle.LayoutOrder=4; UI.SetEnabled(toggle,not context.pending,host.override)
            if not host.override then
                UI.Label(container,"OverrideHelp","Enable Override to preview a recovery. Every change shows its current state and exact effect before Confirm. Either host may recover while Phuong is present.",16).LayoutOrder=2
            end
            local quote=host.confirmation
            if quote and quote.token~=dismissedToken and host.override then
                local card=UI.Card(container,"HostConfirmation","cream"); card.LayoutOrder=2
                UI.Label(card,"ConfirmTitle",quote.label.."?",18,UI.Palette.forest).LayoutOrder=1
                UI.Label(card,"Before",quote.current,15).LayoutOrder=2
                UI.Label(card,"ExactEffect",quote.effect,16).LayoutOrder=3
                UI.Label(card,"Freshness","If anything relevant changes or 30 seconds pass, review a fresh preview. Cancel leaves everything as it is.",13).LayoutOrder=4
                local confirm=UI.Button(card,"ConfirmHostRecovery",context.pending and "Saving…" or "Confirm recovery",function()
                    request({action="Confirm",token=quote.token})
                end)
                confirm.LayoutOrder=5; UI.SetEnabled(confirm,not context.pending and workspace:GetServerTimeNow()<quote.expiresAt)
                local cancel=UI.Button(card,"CancelHostRecovery","Cancel",function()
                    if getContext().pending then return end
                    dismissedToken=quote.token; request({action="Cancel",token=quote.token})
                end,true)
                cancel.LayoutOrder=6; UI.SetEnabled(cancel,not context.pending,true)
                UI.Button(card,"FreshPreview","Review current state again",function()
                    dismissedToken=quote.token; request({action="Cancel",token=quote.token})
                end,true).LayoutOrder=7
            elseif host.override then
                local function operation(parent,descriptor,order)
                    local button=UI.Button(parent,"Host"..descriptor.operation,descriptor.label,function()
                        dismissedToken=nil
                        request({action="Prepare",operation=descriptor.operation,activityId=descriptor.activityId})
                    end,true)
                    button.LayoutOrder=order; UI.SetEnabled(button,descriptor.enabled and not context.pending,true)
                    if not descriptor.enabled then UI.Label(parent,"Reason"..descriptor.operation,descriptor.reason,14).LayoutOrder=order+1 end
                end
                local quests=UI.Card(container,"HostQuestRecovery","cream"); quests.LayoutOrder=3
                UI.Button(quests,"ShowQuestRecovery",(expanded=="quest" and "▾ " or "▸ ").."Quest recovery",function() expanded=expanded=="quest" and nil or "quest"; getContext().refresh() end,true).LayoutOrder=1
                if expanded=="quest" then
                    UI.Label(quests,"ChooseQuest","Choose one activity. Held work and completed progress are listed in the confirmation.",14).LayoutOrder=2
                    for index,entry in ipairs(QUESTS) do
                        local button=UI.Button(quests,"Choose"..entry[1],(selectedQuest==entry[1] and "✓ " or "")..entry[2]..(host.petals[entry[1]] and " · petal saved" or " · incomplete"),function() selectedQuest=entry[1]; getContext().refresh() end,selectedQuest~=entry[1])
                        button.LayoutOrder=index+20; UI.SetEnabled(button,not context.pending,selectedQuest~=entry[1])
                    end
                    UI.Label(quests,"SelectedQuest","Selected activity · "..selectedQuest,16,UI.Palette.forest).LayoutOrder=3
                    local order=4
                    for _,descriptor in ipairs(host.actions) do if descriptor.activityId==selectedQuest then operation(quests,descriptor,order); order+=2 end end
                end
                local other=UI.Card(container,"HostOtherRecovery","cream"); other.LayoutOrder=4
                UI.Button(other,"ShowOtherRecovery",(expanded=="other" and "▾ " or "▸ ").."Fund, wish, cake and return",function() expanded=expanded=="other" and nil or "other"; getContext().refresh() end,true).LayoutOrder=1
                UI.Label(other,"TopUpBounds","Emergency fund: +20, up to 5 times this session, 30 seconds apart. Used "..host.topUpsUsed.."/5. Wish fulfillment: once, for the normally selected wish.",14).LayoutOrder=2
                if expanded=="other" then
                    local order=3
                    for _,descriptor in ipairs(host.actions) do if not descriptor.activityId then operation(other,descriptor,order); order+=2 end end
                end
            end
            local audit=UI.Card(container,"HostAudit","sage"); audit.LayoutOrder=8
            UI.Label(audit,"AuditTitle","Recent host recoveries · visible only to hosts",16).LayoutOrder=1
            if #host.audit==0 then UI.Label(audit,"NoRecovery","No recovery changes in this session.",14).LayoutOrder=2 end
            for index,entry in ipairs(host.audit) do
                if index>6 and not showAllAudit then break end
                UI.Label(audit,"HostAudit"..index,entry.actor.." · "..entry.action..(entry.activityId and " · "..entry.activityId or "").." · "..os.date("%H:%M:%S",math.floor(entry.timestamp)).."\n"..entry.prior.." → "..entry.new,13).LayoutOrder=index+1
            end
            if #host.audit>6 then UI.Button(audit,"ShowHostAudit",showAllAudit and "Show latest six" or "Show all recent audit entries",function() showAllAudit=not showAllAudit; getContext().refresh() end,true).LayoutOrder=40 end
            UI.Label(audit,"AuditLimit","The server keeps the latest 32 audit entries and at most 512 host requests this session ("..host.requestCount.." used). Close or Back leaves ordinary play available.",12).LayoutOrder=41
        end,
    })
    registry.RegisterObserver("HostControls",function(payload,context)
        if payload.kind=="PanelClosed" or payload.kind=="CharacterRemoving" or payload.kind=="LocationChanged" and not payload.inWorld then
            local quote=context.snapshot.host and context.snapshot.host.confirmation
            dismissedToken=quote and quote.token or dismissedToken
            return
        end
        if payload.hostResult then
            local result=payload.hostResult
            if payload.actionId~=lastResult then
                lastResult=payload.actionId
                context.toast(result.message,payload.ok==false)
                if result.ok and result.destination then
                    registry.Notify({kind="HostTravel",destination=result.destination},getContext())
                    context.close()
                end
            end
        end
        if context.activePanel=="HostControls" and (payload.snapshot or payload.hostResult) then getContext().refresh() end
    end)
end
return Module
]=],
["roblox/mvp/client/extensions/MusicController.luau"] = [=[-- PCW-26: one local controller, independent of activity panels and actions.
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
        raise.Position,raise.Size=UDim2.fromOffset(musicWidth+64,4),UDim2.fromOffset(48,48)]==]
return #_G.__PCW25ContractText