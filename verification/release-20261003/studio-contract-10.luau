_G.__PCW25ContractText..=[==[ocal person = self.participants[actor]
    local message
    if hostAction then
        if self.startedAt then return reject("CakeAlreadyStarted", "The celebration is already underway. It cannot be restarted or cancelled.") end
        self.delayed = operation == "Delay"
        if self.session:AllPetalsComplete() then self.phase = self.delayed and "READY" or "GATHERING" end
        message = self.delayed and "Gathering paused. A host can arm Phuong's seat when everyone is ready." or "Phuong's seat is armed for the birthday celebration."
    elseif operation == "RecoverStart" then
        if not self.session:AllPetalsComplete() then return reject("CakeLocked", "Finish all six petals before recovering the celebration.") end
        if not self:_begin(actor, true) then return reject("CakeAlreadyStarted", "The celebration already started; use Advance cake only if needed.") end
        message = "Host recovery started the birthday celebration."
    elseif operation == "Cut" or operation == "RecoverCut" then
        if operation == "Cut" and actor ~= self.session.phuongUserId then return reject("CakePermission", "Phuong makes the first cut. Andrew can use explicit host recovery if needed.") end
        if self.cutAt then return reject("CakeAlreadyCut", "The cake is already cut. Everyone may take a slice.") end
        if operation == "RecoverCut" and self.phase == "CELEBRATING" then
            self.endsAt = now
            self.phase = "CAKE_READY"
        end
        if self.phase ~= "CAKE_READY" then return reject("CakeNotReady", "The birthday celebration comes before the first cut.") end
        self.cutAt, self.cutBy = now, actor
        self.recoveredCut = operation == "RecoverCut"
        message = "Phuong's birthday cake is cut! Everyone may take a slice."
    elseif operation == "TakeSlice" then
        if not self.cutAt then return reject("CakeNotCut", "Wait for Phuong's first cut, then take a slice.") end
        if person then return reject("CakeSliceSaved", "Your slice is already saved. Enjoy a bite.") end
        self.participants[actor] = { takenAt = now, biteCount = 0 }
        message = "Your slice is ready. Enjoy a bite, then stay for photos or explore."
    elseif operation == "Eat" or operation == "Bite" then
        if not self.cutAt or not person then return reject("CakeNoSlice", "Take your slice before enjoying a bite.") end
        if operation == "Eat" and person.eatenAt then return reject("CakeAlreadyEaten", "Your cake moment is saved. Another bite is just for fun.") end
        if operation == "Bite" and not person.eatenAt then return reject("CakeFirstBite", "Choose Enjoy my cake for your first bite.") end
        if person.lastBiteAt and now - person.lastBiteAt < 1.6 then return reject("CakeBiteBusy", "Enjoy that bite first.") end
        person.eatenAt = person.eatenAt or now
        person.lastBiteAt = now
        person.biteCount += 1
        self.phase = "EATING"
        message = operation == "Bite" and "Another little birthday bite." or "Cake enjoyed! Stay for photos, or keep exploring together."
    end
    self.revision += 1
    local receipt = { sessionId = self.session.sessionId, activityId = "Cake", actionId = request.actionId,
        actorUserId = actor, action = original, generation = request.generation, recovery = recovery,
        acceptedAt = now, message = message }
    self.receipts[request.actionId] = receipt
    self.session.receipts[request.actionId] = receipt
    self:Tick()
    return { ok = true, code = "CakeAccepted", message = message, receipt = receipt }
end

function CakeService:Apply(request)
    return self:_apply(request, false)
end

-- PCW-24 only: after HostService authenticates explicit Override + confirmation.
-- Still authenticates the configured host, current generation and six petals.
-- Both operations advance monotonically; neither can reset this session.
function CakeService:Recover(request)
    return self:_apply(request, true)
end

function CakeService:GetState(actor)
    local person = self.participants[actor]
    local state = {
        phase = self.phase, finaleState = self.phase, generation = self.generation, revision = self.revision,
        unlockedAt = self.unlockedAt, startedAt = self.startedAt, endsAt = self.endsAt,
        duration = DURATION, cutAt = self.cutAt, delayed = self.delayed, armed = self.phase == "GATHERING",
        invitation = self.phase ~= "LOCKED", availableActions = {},
        sliceTaken = person ~= nil, hasEaten = person ~= nil and person.eatenAt ~= nil,
        biteCount = person and person.biteCount or 0,
        scene = self.runtime.scene and self.runtime.scene() or nil,
        guide = { nextAnchor = "FinalePatio" },
    }
    local details = {
        LOCKED = "Complete all six petals to gather for Phuong's birthday cake.",
        READY = "The patio is ready. A host has paused the gathering so friends can find their seats.",
        GATHERING = "Friends, choose a guest seat first. Phuong, sit in the marked west end seat when you are ready; your celebration starts automatically.",
        CELEBRATING = "Happy Birthday, Phuong! Enjoy the moment together. The optional camera view has its own Skip / Return.",
        CAKE_READY = self.cutAt and "The first cut is made! Everyone can take their own slice." or "Phuong, make the first cut whenever you are ready.",
        EATING = "Enjoy your cake together. Another bite is just for fun; photos and exploring stay open.",
    }
    state.guide.detail = details[self.phase]
    local present = actor and self:_present(actor)
    local atPatio = present and self.runtime.isAtPatio and self.runtime.isAtPatio(actor) == true
    state.atPatio = atPatio == true
    local function add(action, label, enabled, confirm)
        table.insert(state.availableActions, { id = action, action = action, label = label, generation = self.generation,
            enabled = enabled == true, reason = not enabled and "Walk to the birthday table first." or nil, confirm = confirm })
    end
    if present and self:_host(actor) and not self.startedAt then
        if self.delayed then add("Arm", "Arm Phuong's seat", true, { title = "Ready to gather?", detail = "If Phuong is already in her seat and six petals are complete, the celebration starts now.", label = "Arm the seat" })
        else add("Delay", "Give friends more time", true, { title = "Pause the gathering?", detail = "This pauses the seat trigger until a host arms it again.", label = "Pause gathering" }) end
    end
    if self.phase == "CAKE_READY" and not self.cutAt and actor == self.session.phuongUserId and present then
        add("Cut", "Make the first cut", atPatio, { title = "Cut your birthday cake?", detail = "Everyone will be able to take a slice.", label = "Cut the cake" })
    end
    if self.cutAt and present then
        if not person then add("TakeSlice", "Take my slice", atPatio)
        elseif not person.eatenAt then add("Eat", "Enjoy my cake", atPatio)
        else add("Bite", "Another little bite", atPatio) end
    end
    return state
end

return CakeService
]=],
["roblox/mvp/server/CozyAudio.luau"] = [=[-- Permanent export of live CozyAudio, with nonblocking dependencies and dedupe.
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
]=],
["roblox/mvp/server/FinalePresentation.luau"] = [=[-- Bounded native presentation around the existing table. Never creates seats,
-- edits the saved cake, plays music, moves avatars or changes avatar joints.
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local FinalePresentation = {}
FinalePresentation.__index = FinalePresentation
local P = {
    forest = Color3.fromRGB(54,87,68), sage = Color3.fromRGB(168,185,149),
    cream = Color3.fromRGB(245,240,228), wood = Color3.fromRGB(149,103,75),
    blossom = Color3.fromRGB(232,183,198), brick = Color3.fromRGB(182,108,104),
    golden = Color3.fromRGB(232,199,121), ink = Color3.fromRGB(38,56,46),
}
local V, CF = Vector3.new, CFrame.new
local function folder(parent, name)
    local value = Instance.new("Folder"); value.Name = name; value.Parent = parent; return value
end
local function part(parent, name, size, frame, token, shape)
    local value = Instance.new("Part")
    value.Name, value.Size, value.CFrame = name, size, frame
    value.Color, value.Material = P[token], Enum.Material.SmoothPlastic
    value.Anchored, value.CanCollide, value.CanTouch, value.CanQuery = true, false, false, false
    value.CastShadow = false
    if shape then value.Shape = shape end
    value:SetAttribute("PaletteToken", token); value:SetAttribute("VerificationTicket", "PCW-23")
    value.Parent = parent
    return value
end
local function label(parent, name, frame, text, width)
    local cue = part(parent, name, V(.1,.1,.1), frame, "cream"); cue.Transparency = 1
    local gui = Instance.new("BillboardGui")
    gui.Name, gui.Size, gui.MaxDistance, gui.AlwaysOnTop = "Caption", UDim2.fromOffset(width or 190, 66), 65, false
    gui.Adornee, gui.Parent = cue, cue
    local caption = Instance.new("TextLabel")
    caption.Name, caption.Size, caption.Text, caption.TextSize = "Text", UDim2.fromScale(1,1), text, 15
    caption.Font, caption.TextWrapped = Enum.Font.GothamMedium, true
    caption.BackgroundColor3, caption.TextColor3, caption.BorderSizePixel = P.cream, P.ink, 0
    caption.Parent = gui
    return gui, caption
end
local function position(value) return { x = value.X, y = value.Y, z = value.Z } end

function FinalePresentation.new(root, mvp)
    local context = root:FindFirstChild("SurroundingContext")
    local details = context and context:FindFirstChild("NeighborhoodDetails02")
    local courtyard = assert(details and details:FindFirstChild("BirthdayCourtyard"), "PCW-23 BirthdayCourtyard missing")
    local tablePart = assert(courtyard:FindFirstChild("GatheringTable"), "PCW-23 GatheringTable missing")
    local cake = assert(courtyard:FindFirstChild("BirthdayCake"), "PCW-23 saved cake missing")
    assert(tablePart:IsA("BasePart"), "PCW-23 table must be a BasePart")
    local stations = mvp:FindFirstChild("Stations")
    local ends = stations and stations:FindFirstChild("CakeFinale")
    local west = ends and ends:FindFirstChild("EndSeatWest")
    local east = ends and ends:FindFirstChild("EndSeatEast")
    west, east = west and west:FindFirstChild("Seat"), east and east:FindFirstChild("Seat")
    assert(west and west:IsA("Seat") and east and east:IsA("Seat"), "PCW-23 saved end seats missing; do not duplicate them")
    local seats = {}
    for _, item in ipairs(courtyard:GetDescendants()) do
        if item:IsA("Seat") then table.insert(seats, item) end
    end
    assert(#seats == 8, "PCW-23 expected eight courtyard side seats")
    table.sort(seats, function(a,b) return a:GetFullName() < b:GetFullName() end)
    table.insert(seats, west); table.insert(seats, east)
    local runtime = mvp:FindFirstChild("RuntimePresentation") or folder(mvp, "RuntimePresentation")
    assert(not runtime:FindFirstChild("FinalePresentation"), "PCW-23 presentation already running")
    local owned = folder(runtime, "FinalePresentation"); owned:SetAttribute("VerificationTicket", "PCW-23")
    local self = setmetatable({ root = owned, seats = seats, phuongSeat = west, tablePart = tablePart,
        seatCues = {}, confetti = {}, sliceModels = {}, participants = {}, elapsed = 0, state = {} }, FinalePresentation)
    self.scene = { center = position(tablePart.Position), tablePath = tablePart:GetFullName(),
        phuongSeatPath = west:GetFullName(), phuongSeatPosition = position(west.Position), seatCount = #seats }
    local cues = folder(owned, "SeatCues")
    for index, seat in ipairs(seats) do
        local designated = seat == west
        local gui = label(cues, "SeatCue" .. index, CF(seat.Position + V(0, 3.7, 0)),
            designated and "Phuong's seat\nSit here when ready" or "Guest seat\nGather here first")
        gui.Enabled = false
        table.insert(self.seatCues, { gui = gui, seat = seat, designated = designated })
    end
    self.banner, self.bannerText = label(owned, "BirthdayCaption", CF(tablePart.Position + V(0, 8.5, 0)), "", 310)
    self.banner.Enabled = false
    local celebration = folder(owned, "Celebration")
    for index = 1, 18 do
        local token = index % 3 == 0 and "golden" or index % 3 == 1 and "blossom" or "cream"
        local piece = part(celebration, "Confetti" .. index, V(.25,.07,.45), tablePart.CFrame, token)
        piece.Transparency = 1
        table.insert(self.confetti, piece)
    end
    -- The existing cake already owns its candles/topper. Add a small halo of
    -- native golden beads rather than duplicate the cake or its light sources.
    self.halo = {}
    local upper = cake:FindFirstChild("CakeUpperTier", true)
    self.cakeFrame = upper and upper.CFrame or tablePart.CFrame * CF(0,2.7,0)
    for index = 1, 6 do
        local angle = index * math.pi / 3
        local bead = part(celebration, "CandleGlow" .. index, V(.15,.15,.15), self.cakeFrame * CF(math.cos(angle)*2.5,1.65,math.sin(angle)*2.5), "golden", Enum.PartType.Ball)
        bead.Transparency = 1; table.insert(self.halo, bead)
    end
    local serving = folder(owned, "Serving")
    self.blade = part(serving, "CakeServerBlade", V(.15,.25,2.4), self.cakeFrame, "golden")
    self.handle = part(serving, "CakeServerHandle", V(.24,.26,1), self.cakeFrame, "wood")
    self.blade.Transparency, self.handle.Transparency = 1, 1
    local tray = tablePart.CFrame * CF(4,tablePart.Size.Y/2+.4,0)
    self.served = {
        part(serving, "SharedSlicePlate", V(.12,2.2,2.2), tray * CFrame.Angles(0,0,math.pi/2), "cream", Enum.PartType.Cylinder),
        part(serving, "SharedSliceCake", V(1.05,.65,1.25), tray * CF(0,.38,0), "golden"),
        part(serving, "SharedSliceIcing", V(1.07,.15,1.27), tray * CF(0,.79,0), "blossom"),
    }
    for _, piece in ipairs(self.served) do piece.Transparency = 1 end
    self.slices = folder(owned, "PersonalSlices")
    self.connection = RunService.Heartbeat:Connect(function(dt)
        self.elapsed += dt
        if self.elapsed < .05 then return end
        self.elapsed = 0
        local ok, err = pcall(self._step, self, workspace:GetServerTimeNow())
        if not ok and not self.warned then self.warned = true; warn("PCW-23 cosmetic presentation failed", err) end
    end)
    return self
end

function FinalePresentation:GetOccupant()
    local seat = self.phuongSeat
    local humanoid = seat and seat.Parent and seat.Occupant
    if not humanoid or humanoid.Health <= 0 or humanoid.SeatPart ~= seat then return nil end
    local actor = Players:GetPlayerFromCharacter(humanoid.Parent)
    if actor and actor.Character == humanoid.Parent and actor:GetAttribute("BirthdayLocation") == "World" then return actor.UserId end
    return nil
end

function FinalePresentation:GetScene() return self.scene end

function FinalePresentation:Render(state, participants)
    self.state, self.participants = state, participants or {}
    self.banner.Enabled = state.phase ~= "LOCKED"
    self.bannerText.Text = state.phase == "CELEBRATING" and "Happy Birthday, Phuong!"
        or state.cutAt and "Cake for everyone!\nTake a slice · stay for photos"
        or state.phase == "CAKE_READY" and "Phuong's first cut\nOpen Birthday cake when ready"
        or state.delayed and "Birthday gathering paused\nFriends, find your seats"
        or "Birthday gathering\nFriends first · then Phuong's seat"
    for _, cue in ipairs(self.seatCues) do
        cue.gui.Enabled = state.phase == "READY" or state.phase == "GATHERING"
    end
    for _, piece in ipairs(self.served) do piece.Transparency = state.cutAt and 0 or 1 end
end

function FinalePresentation:_slice(actor)
    if self.sliceModels[actor] then return self.sliceModels[actor] end
    local model = folder(self.slices, "Participant" .. tostring(actor))
    local result = { root = model }
    result.plate = part(model, "Plate", V(.1,1.5,1.5), CF(), "cream", Enum.PartType.Cylinder)
    result.cake = part(model, "Slice", V(.8,.4,.8), CF(), "golden")
    result.icing = part(model, "Icing", V(.82,.1,.82), CF(), "blossom")
    result.fork = part(model, "UtensilHandle", V(.09,.09,.65), CF(), "wood")
    result.spoon = part(model, "UtensilTip", V(.25,.1,.32), CF(), "golden", Enum.PartType.Ball)
    result.bite = part(model, "LittleBite", V(.19,.16,.2), CF(), "blossom")
    self.sliceModels[actor] = result
    return result
end

function FinalePresentation:_step(now)
    if not self.root.Parent then self:Destroy(); return end
    local state = self.state
    local celebrating = state.phase == "CELEBRATING" and state.startedAt and state.endsAt and now < state.endsAt
    for index, piece in ipairs(self.confetti) do
        piece.Transparency = celebrating and .12 or 1
        if celebrating then
            local t = (now - state.startedAt + index*.21) % 3 / 3
            local angle = index * 2.399 + t*.4
            piece.CFrame = self.tablePart.CFrame * CF(math.cos(angle)*(4+index%5),9-t*6,math.sin(angle)*(3+index%4)) * CFrame.Angles(t*math.pi,index,t*2)
        end
    end
    for _, bead in ipairs(self.halo) do bead.Transparency = celebrating and .15 or 1 end
    local cutting = state.cutAt and now - state.cutAt < 2.4
    self.blade.Transparency, self.handle.Transparency = cutting and 0 or 1, cutting and 0 or 1
    if cutting then
        local t = math.clamp((now-state.cutAt)/2.4,0,1)
        local frame = self.cakeFrame * CF(.6,2-math.sin(t*math.pi)*2.1,0) * CFrame.Angles(0,0,-.25)
        self.blade.CFrame, self.handle.CFrame = frame, frame * CF(0,0,1.7)
    end
    local active = {}
    for _, player in ipairs(Players:GetPlayers()) do
        local person = self.participants[player.UserId]
        local character = player.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        local base = character and character:FindFirstChild("HumanoidRootPart")
        local head = character and character:FindFirstChild("Head")
        if person and player:GetAttribute("BirthdayLocation") == "World" and base and head and humanoid and humanoid.Health > 0 then
            active[player.UserId] = true
            local slice = self:_slice(player.UserId)
            -- R6/R15 fallback: a small plate held beside the body and an animated
            -- utensil from right hand to mouth. No uploaded animation or joints.
            local left = character:FindFirstChild("LeftHand") or character:FindFirstChild("Left Arm")
            local right = character:FindFirstChild("RightHand") or character:FindFirstChild("Right Arm")
            local platePosition = left and left.Position or (base.CFrame * CF(-1.1,0,-.6)).Position
            platePosition += base.CFrame.LookVector * .65 + V(0,.1,0)
            local frame = CF(platePosition) * base.CFrame.Rotation
            local eaten = person.eatenAt ~= nil
            slice.plate.CFrame = frame * CFrame.Angles(0,0,math.pi/2)
            slice.cake.Size = eaten and V(.45,.4,.8) or V(.8,.4,.8)
            slice.icing.Size = eaten and V(.47,.1,.82) or V(.82,.1,.82)
            slice.cake.CFrame, slice.icing.CFrame = frame * CF(0,.25,0), frame * CF(0,.5,0)
            local t = person.lastBiteAt and math.clamp((now-person.lastBiteAt)/1.5,0,1) or 1
            local lift = math.sin(t*math.pi)
            local rest = right and right.Position + base.CFrame.LookVector * .7 or (base.CFrame * CF(1,0,-.8)).Position
            local mouth = head.Position + base.CFrame.LookVector * .65 - V(0,.15,0)
            local tip = rest:Lerp(mouth, lift)
            local forkFrame = CF(tip) * base.CFrame.Rotation
            slice.fork.CFrame, slice.spoon.CFrame = forkFrame * CF(0,0,.25), forkFrame * CF(0,0,-.2)
            slice.bite.CFrame = forkFrame * CF(0,.13,-.2)
            slice.bite.Transparency = t > 0 and t < .55 and 0 or 1
        end
    end
    for actor, slice in pairs(self.sliceModels) do
        if not active[actor] then slice.root:Destroy(); self.sliceModels[actor] = nil end
    end
end

function FinalePresentation:Destroy()
    if self.connection then self.connection:Disconnect(); self.connection = nil end
    if self.root then self.root:Destroy() end
    self.sliceModels = {}
end

return FinalePresentation
]=],
["roblox/mvp/server/FoodFeedback.luau"] = [=[-- One bounded runtime dish, plus route labels on the existing three counters.
local FoodPresentation = require(script.Parent.Parent.shared.FoodPresentation)
local FoodFeedback = {}
FoodFeedback.__index = FoodFeedback
local VENUES = {
	{ id = "FOB", anchor = "Q06FOBCounter", label = "1 · FOB", task = "Rice + protein + fresh topping", next = "Next · Aladdins" },
	{ id = "Aladdins", anchor = "Q06AladdinsCounter", label = "2 · Aladdins", task = "Sauce or sesame", next = "Next · serving table" },
	{ id = "Serving", anchor = "Q06Serving", label = "3 · Serving table", task = "Left + right table settings", next = "Share your meal" },
}
local function folder(parent, name)
	local value = Instance.new("Folder"); value.Name = name; value.Parent = parent; return value
end
local function surface(mvp, anchor)
	local stations = mvp:FindFirstChild("Stations")
	local station = stations and stations:FindFirstChild("Q06Station")
	local counter = station and station:FindFirstChild(anchor.Name, true)
	local top = counter and counter:FindFirstChild("ActionSurface")
	if top and top:IsA("BasePart") then return top.CFrame * CFrame.new(0, top.Size.Y / 2 + .03, 0) end
	-- Matches the existing Q06Station counter contract. No builder is invoked.
	return anchor.CFrame * CFrame.new(0, 2.205, 0)
end
function FoodFeedback.new(mvp, anchors)
	local runtime = mvp:FindFirstChild("RuntimePresentation") or folder(mvp, "RuntimePresentation")
	assert(not runtime:FindFirstChild("FoodFeedback"), "FoodFeedback is already running")
	local root = folder(runtime, "FoodFeedback"); root:SetAttribute("VerificationTicket", "PCW-20")
	local self = setmetatable({ root = root, frames = {}, labels = {} }, FoodFeedback)
	for _, venue in ipairs(VENUES) do
		local anchor = anchors[venue.anchor]
		if anchor and anchor:IsA("BasePart") then
			self.frames[venue.id] = surface(mvp, anchor)
			local cue = Instance.new("Part")
			cue.Name, cue.Size, cue.CFrame = venue.anchor .. "Cue", Vector3.new(.1, .1, .1), self.frames[venue.id] * CFrame.new(0, 1.9, -1)
			cue.Anchored, cue.CanCollide, cue.CanTouch, cue.CanQuery, cue.Transparency = true, false, false, false, 1
			cue.Color = Color3.fromRGB(54, 87, 68); cue:SetAttribute("PaletteToken", "forest"); cue:SetAttribute("VerificationTicket", "PCW-20"); cue.Parent = root
			local gui = Instance.new("BillboardGui")
			gui.Name, gui.Size, gui.AlwaysOnTop, gui.MaxDistance = "FoodRoute", UDim2.fromOffset(250, 92), false, 38
			gui.Adornee, gui.Parent = cue, cue
			local text = Instance.new("TextLabel")
			text.Name, text.Size, text.Font, text.TextSize = "RouteText", UDim2.fromScale(1, 1), Enum.Font.GothamMedium, 14
			text.BackgroundColor3, text.TextColor3, text.BorderSizePixel = Color3.fromRGB(245, 240, 228), Color3.fromRGB(38, 56, 46), 0
			text.TextWrapped, text.Parent = true, gui
			self.labels[venue.id] = text
		else warn("PCW-20 food counter anchor is unavailable", venue.anchor) end
	end
	self:Render(nil, {}, "FOB", false)
	return self
end
function FoodFeedback:Render(roundId, accepted, venueId, complete)
	-- Rebuild only on accepted progress or a new round, never on selections or views.
	-- At most one six-ingredient dish exists, including across repeated replays.
	if self.dish then self.dish:Destroy(); self.dish = nil end
	local frame = self.frames[venueId]
	if frame then
		local model = FoodPresentation.Build(accepted)
		model:SetAttribute("RoundId", roundId); model:SetAttribute("VenueId", venueId); model:SetAttribute("Completed", complete)
		model.Parent = self.root; model:PivotTo(frame); self.dish = model
	end
	self.root:SetAttribute("RoundId", roundId); self.root:SetAttribute("VenueId", venueId)
	for _, venue in ipairs(VENUES) do
		local label = self.labels[venue.id]
		if label then
			local state = complete and "Done · meal ready at serving" or venue.id == venueId and "Build the shared meal here" or "Current step · " .. (venueId == "Serving" and "serving table" or venueId)
			label.Text = venue.label .. "\n" .. venue.task .. "\n" .. state .. "\n" .. venue.next
		end
	end
end
function FoodFeedback:Destroy() self.root:Destroy() end
return FoodFeedback
]=],
["roblox/mvp/server/HostService.luau"] = [=[-- Bounded, session-only recovery. Only Main supplies the authenticated actor.
local Config = require(script.Parent.Parent.shared.Config)
local Catalog = require(script.Parent.Parent.shared.FigureCatalog)
local HostService = {}; HostService.__index = HostService
local RESETTABLE = { Q01=true, Q03=true, Q06=true }
local QUEST_ACTIONS = { ReleaseReservations=true, RestartRound=true, CompleteQuest=true }
local OPERATIONS = { ReleaseReservations=true, RestartRound=true, CompleteQuest=true, TopUp=true, FulfillWish=true,
    InviteCake=true, StartCake=true, AdvanceCake=true, ReturnBedroom=true, ReturnPatio=true }
local TITLES = { Q01="Bed",Q02="Jasper",Q03="Craft",Q04="Reading",Q05="Labubu wish",Q06="Food" }
local LABELS = { ReleaseReservations="Release held choices",RestartRound="Restart incomplete round",CompleteQuest="Complete quest",
    TopUp="Add 20 to shared fund",FulfillWish="Fulfill selected Labubu wish",InviteCake="Invite everyone to cake",
    StartCake="Start birthday celebration",AdvanceCake="Advance to cut cake",ReturnBedroom="Return me to bedroom",ReturnPatio="Return me to patio" }
local function copy(value)
    if type(value)~="table" then return value end
    local out={}; for k,v in pairs(value) do out[k]=copy(v) end; return out
end
local function equal(a,b)
    if type(a)~=type(b) then return false end
    if type(a)~="table" then return a==b end
    for k,v in pairs(a) do if not equal(v,b[k]) then return false end end
    for k in pairs(b) do if a[k]==nil then return false end end
    return true
end
local function count(map) local n=0; for _ in pairs(map or {}) do n+=1 end; return n end
local function reject(code,message) return {ok=false,code=code,message=message} end
local function hostName(actor) return actor==Config.PhuongUserId and "Phuong" or "Andrew" end

function HostService.new(session,options)
    assert(session and options and options.activities and options.cake,"host dependencies required")
    return setmetatable({session=session,activities=options.activities,cake=options.cake,clock=options.clock or os.clock,
        runtime=options.runtime or {},overrides={},quotes={},results={},audit={},lastRequest={},serial=0,revision=0,
        requestCount=0,topUps=0,lastTopUp=nil},HostService)
end
function HostService:IsHost(actor)
    return actor==Config.PhuongUserId or actor==Config.HostUserId
end
function HostService:_present(actor)
    return self:IsHost(actor) and self.session:IsPresent(actor) and self.runtime.isWorld and self.runtime.isWorld(actor)==true
end
function HostService:_record(actor,operation,activityId,prior,new)
    self.revision+=1
    table.insert(self.audit,1,{actorUserId=actor,actor=hostName(actor),action=operation,activityId=activityId,
        prior=prior,new=new,timestamp=self.clock()})
    while #self.audit>32 do table.remove(self.audit) end
end
function HostService:ReleaseActor(actor)
    self.quotes[actor]=nil
    if self.overrides[actor] then
        self.overrides[actor]=nil
        self:_record(actor,"Override ended",nil,"Override active","Normal choices")
    end
end
function HostService:_state(activityId,operation)
    local activity=activityId and self.activities[activityId]
    local localState=activity and activity:RecoveryState() or nil
    local round=localState and localState.roundId and self.session.rounds[localState.roundId]
    local state={revision=self.revision,fund=self.session.fundBalance,petals=copy(self.session.petals),localState=copy(localState),
        round=round and {roundId=round.roundId,state=round.state,steps=copy(round.steps),isReplay=round.isReplay},
        missingReward=activityId and self.session:MissingInitialReward(activityId) or 0,topUps=self.topUps}
    if operation=="InviteCake" or operation=="StartCake" or operation=="AdvanceCake" then
        state.cake={phase=self.cake.phase,generation=self.cake.generation,revision=self.cake.revision,cutAt=self.cake.cutAt,startedAt=self.cake.startedAt}
    end
    return state
end
function HostService:_summary(state,activityId)
    local petals=0; for _,done in pairs(state.petals) do if done then petals+=1 end end
    local text="Shared fund "..state.fund.." · "..petals.."/6 petals"
    if activityId then
        text..=" · "..TITLES[activityId]..": "..(state.petals[activityId] and "petal saved" or "petal missing")
        if state.round then text..=" · "..count(state.round.steps).." saved steps ("..state.round.state..")" else text..=" · not started" end
        local localState=state.localState
        if localState and RESETTABLE[activityId] then
            local held=activityId=="Q01" and count(localState.reserved)+count(localState.shelfHolds)
                or activityId=="Q03" and count(localState.state and localState.state.reservations) or count(localState.reservations)
            text..=" · "..held.." held choices"
        end
    end
    if state.localState and state.localState.wanted then
        text..=" · wish: "..Catalog.Label(state.localState.wanted).." · "..(state.localState.collection[state.localState.wanted] or 0).." copies owned"
    end
    if state.cake then text..=" · cake "..state.cake.phase end
    return text
end
function HostService:_plan(operation,activityId)
    if not OPERATIONS[operation] then return nil,"Choose a listed recovery action." end
    if QUEST_ACTIONS[operation] then
        if not TITLES[activityId] or not self.activities[activityId] then return nil,"Choose one of the six available quests." end
    elseif activityId~=nil and not (operation=="FulfillWish" and activityId=="Q05") then return nil,"This action has no activity target." end
    if operation=="FulfillWish" then activityId="Q05" end
    local state=self:_state(activityId,operation)
    local effect
    if operation=="ReleaseReservations" or operation=="RestartRound" then
        if not RESETTABLE[activityId] then return nil,"Only ]==]
return #_G.__PCW25ContractText