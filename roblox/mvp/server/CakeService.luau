-- Session-only authority. No camera, animation or audio acknowledgement gates progress.
local CakeService = {}
CakeService.__index = CakeService
local DURATION = 12
local NORMAL = { Arm = true, Delay = true, Cut = true, TakeSlice = true, Eat = true, Bite = true }
local ALIASES = { Invite = "Arm", CancelInvite = "Delay" }
local RECOVERY = { RecoverStart = true, RecoverCut = true }

function CakeService.new(session, options)
    options = options or {}
    return setmetatable({
        session = session, clock = options.clock or function() return workspace:GetServerTimeNow() end,
        runtime = {}, phase = "LOCKED", generation = 0, revision = 0, delayed = false,
        participants = {}, receipts = {}, lastRequest = {},
    }, CakeService)
end

function CakeService:SetRuntime(runtime)
    self.runtime = runtime or {}
end

function CakeService:_present(actor)
    return self.session:IsPresent(actor) and self.runtime.isWorld and self.runtime.isWorld(actor) == true
end

function CakeService:_host(actor)
    return self:_present(actor) and (actor == self.session.phuongUserId or actor == self.session.hostUserId)
end

function CakeService:_begin(actor, recovered)
    if self.startedAt or not self.session:AllPetalsComplete() then return false end
    self.generation += 1
    self.startedAt = self.clock()
    self.endsAt = self.startedAt + DURATION
    self.startedBy = actor
    self.recoveredStart = recovered == true
    self.phase = "CELEBRATING"
    self.delayed = false
    self.revision += 1
    return true
end

function CakeService:Tick()
    local before = self.revision
    if self.phase == "LOCKED" and self.session:AllPetalsComplete() then
        self.unlockedAt = self.clock()
        self.phase = self.delayed and "READY" or "GATHERING"
        self.revision += 1
    end
    if self.phase == "GATHERING" and not self.startedAt and self.runtime.occupant then
        -- Also evaluates an already-seated Phuong on unlock and after a delay.
        local actor = self.runtime.occupant()
        if actor == self.session.phuongUserId and self:_present(actor) then self:_begin(actor, false) end
    end
    if self.phase == "CELEBRATING" and self.clock() >= self.endsAt then
        self.phase = "CAKE_READY"
        self.revision += 1
    end
    return before ~= self.revision
end

local function reject(code, message)
    return { ok = false, code = code, message = message }
end

function CakeService:_apply(request, recovery)
    if type(request) ~= "table" or request.sessionId ~= self.session.sessionId
        or type(request.actionId) ~= "string" or #request.actionId == 0 or #request.actionId > 128
        or type(request.actorUserId) ~= "number" or type(request.action) ~= "string"
        or type(request.generation) ~= "number" then
        return reject("BadCakeRequest", "Reopen the birthday table for its current choices.")
    end
    local actor, original = request.actorUserId, request.action
    local operation = ALIASES[original] or original
    if not self:_present(actor) then return reject("NotPresent", "Enter the birthday world first.") end
    if recovery then
        if not RECOVERY[operation] or not self:_host(actor) then return reject("CakePermission", "Only Phuong or Andrew can recover the celebration.") end
    elseif not NORMAL[operation] then
        return reject("UnsupportedCakeAction", "That birthday action is unavailable.")
    end
    local prior = self.receipts[request.actionId]
    if prior then
        if prior.actorUserId ~= actor or prior.action ~= original or prior.generation ~= request.generation or prior.recovery ~= recovery then
            return reject("CakeIdentityMismatch", "That request was already used for a different choice.")
        end
        return { ok = true, code = "DUPLICATE_ACTION", message = prior.message, receipt = prior }
    end
    if self.session.receipts[request.actionId] or self.session.acceptedSteps[request.actionId] then
        return reject("CakeIdentityMismatch", "That request was already used. Reopen the table.")
    end
    self:Tick()
    if request.generation ~= self.generation then return reject("CakeChanged", "The celebration has moved on. Please choose again.") end
    local now = self.clock()
    if self.lastRequest[actor] and now - self.lastRequest[actor] < .3 then return reject("CakeTooQuick", "Let your last choice settle for a moment.") end
    self.lastRequest[actor] = now
    local hostAction = operation == "Arm" or operation == "Delay"
    if hostAction and not self:_host(actor) then return reject("CakePermission", "Phuong and Andrew can change the gathering time.") end
    if not recovery and not hostAction and not (self.runtime.isAtPatio and self.runtime.isAtPatio(actor)) then
        return reject("TooFar", "Walk to the birthday table first; your cake stays saved.")
    end
    local person = self.participants[actor]
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
