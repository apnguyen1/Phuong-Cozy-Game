-- Bounded native presentation around the existing table. Never creates seats,
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
