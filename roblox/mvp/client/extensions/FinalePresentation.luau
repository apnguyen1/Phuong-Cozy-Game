-- One optional local camera. Music belongs exclusively to PCW-26.
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Module = {}

function Module.Init(getContext, registry)
    local initial = getContext()
    local player, UI = initial.player, initial.UI
    local latest, active, confirmation, destroyed
    local skipped, connections = {}, {}
    local offeredKey, invitationKey
    local P = UI.Palette
    local overlay = Instance.new("ScreenGui")
    overlay.Name, overlay.ResetOnSpawn, overlay.IgnoreGuiInset = "BirthdayMoment", false, false
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
    local watch, skip, layout
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
        if layout then layout() end
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
    layout = function()
        local compact = active and overlay.AbsoluteSize.Y < 500 and overlay.AbsoluteSize.X > overlay.AbsoluteSize.Y
        banner.Size = UDim2.fromOffset(math.min(432,math.max(256,overlay.AbsoluteSize.X-24)),compact and 84 or 148)
        banner.Position = UDim2.new(.5,0,0,8+(initial.gui:GetAttribute("AudioControlsInset") or 0))
        headline.Size = UDim2.new(1,compact and -128 or -24,0,32)
        headline.TextSize = compact and 17 or 21
        subtitle.Size = UDim2.new(1,compact and -128 or -24,0,38)
        if compact then
            skip.Position, skip.Size = UDim2.new(1,-108,0,12), UDim2.fromOffset(96,52)
        else
            skip.Position = active and UDim2.fromOffset(12,84) or UDim2.new(.5,4,0,84)
            skip.Size = active and UDim2.new(1,-24,0,52) or UDim2.new(.5,-16,0,52)
        end
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
            if current.send({kind="Cake",action=descriptor.action,generation=descriptor.generation}) then
                if descriptor.action == "Eat" or descriptor.action == "Bite" then current.close()
                else current.refresh() end
            end
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
