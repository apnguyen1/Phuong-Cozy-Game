_G.__PCW25ContractText..=[==[,
        guide={headline=finishing and "Ready for Phuong's finishing touch" or state and state.finalizationReceipt and "Keepsake finished!" or "Build one tiny world together",detail=detail,nextAnchor=done==6 and "Q03BedroomDisplay" or "Q03FairCraft",
            groups={{id="placement",title="Turn and place your piece",detail="Each turn is a quarter turn. Any orientation fits its matching socket."},{id="parts",title="Choose a tiny part",detail="Accepted parts stay saved at both locations."},{id="finish",title="Phuong's finishing touch"}}}}
end
function Q03:CreateRound(request)
    assert(request and request.sessionId==self.session.sessionId and request.activityId=="Q03" and validId(request.roundId) and validActorId(request.actorUserId) and self:_actor(request),"invalid Q03 round")
    local previous=self.currentRoundId and self.stateByRound[self.currentRoundId]
    assert(not previous or (previous.status=="COMPLETED" and request.replay==true),"finish the shared round before an explicit replay")
    assert(not self.rounds[request.roundId],"round already exists")
    self.session:CreateRound("Q03",request.roundId,request.actorUserId,request.replay==true)
    local sockets={}; for _,socket in pairs(SOCKETS) do sockets[socket]={status="AVAILABLE"} end
    self.rounds[request.roundId]=true; self.currentRoundId=request.roundId
    local state={status="IN_PROGRESS",sockets=sockets,committed={},accepted={},contributors={},reservations={}}
    self.stateByRound[request.roundId]=state; self:_render(state)
    return self:GetView(request.actorUserId)
end
function Q03:Apply(request)
    assert(request and request.sessionId==self.session.sessionId and request.activityId=="Q03" and request.roundId==self.currentRoundId and validId(request.actionId) and validId(request.stepId) and validActorId(request.actorUserId),"invalid Q03 request")
    assert(self:_actor(request),"unauthenticated actor")
    if self.actions[request.actionId] then
        assert(self.actionIdentities[request.actionId]==identity(request),"action identity changed")
        local result=copy(self.actions[request.actionId]); result.view=self:GetView(request.actorUserId); return result
    end
    assert(not (self.session.receipts and self.session.receipts[request.actionId]) and not (self.session.acceptedSteps and self.session.acceptedSteps[request.actionId]),"action belongs to another receipt")
    local state=assert(self:_round(request),"unknown Q03 round")
    self:ExpireReservations(request.roundId)
    local p=request.payload or {}; local action=p.action; local result
    if action=="finalize" then
        assert(request.stepId=="finalize:"..tostring(p.presentation),"step does not match finishing choice")
        assert(state.status=="COMPLETED" and self:_canFinalize(request.actorUserId),"Phuong or available host must finalize the completed keepsake")
        assert(p.presentation=="lamp_on" or p.presentation=="lamp_off","invalid presentation")
        if state.finalizationReceipt then result=state.finalizationReceipt
        else
            state.finalPresentation=p.presentation
            result={ok=true,code="FINALIZED",receipt={receiptId="q03-final:"..request.roundId,roundId=request.roundId,presentation=p.presentation,actorUserId=request.actorUserId}}
            state.finalizationReceipt=result
        end
    else
        assert(state.status=="IN_PROGRESS","Q03 round is not active")
        if action=="reserve" then
            assert(SOCKETS[p.partId]==p.socketId and request.stepId=="reserve:"..tostring(p.partId),"part does not fit socket")
            local entry=assert(state.sockets[p.socketId],"unknown socket"); assert(entry.status=="AVAILABLE","socket is busy or placed")
            -- One selected piece per helper; changing cards releases the old preview.
            for socket,old in pairs(state.reservations) do if old.ownerUserId==request.actorUserId then free(old); state.reservations[socket]=nil end end
            entry.status="RESERVED"; entry.ownerUserId=request.actorUserId; entry.partId=p.partId; entry.orientation=0; entry.lastActivity=self.clock()
            state.reservations[p.socketId]=entry; result={ok=true,code="SELECTED",socketId=p.socketId,partId=p.partId,orientation=0}
        elseif action=="rotate" or action=="place" or action=="cancel" then
            local entry=assert(state.reservations[p.socketId],"choose that piece again; the selection was released")
            assert(entry.ownerUserId==request.actorUserId,"not reservation owner")
            if action=="rotate" then
                assert(p.direction==1 or p.direction==-1,"quarter-turn direction required")
                assert(request.stepId=="rotate-"..(p.direction<0 and "left" or "right")..":"..entry.partId,"step does not match rotation")
                entry.orientation=(entry.orientation+p.direction)%4; entry.lastActivity=self.clock(); result={ok=true,code="ROTATED",orientation=entry.orientation}
            elseif action=="place" then
                assert(entry.partId==p.partId and request.stepId=="place:"..entry.partId,"piece mismatch")
                local accepted=self.session:ApplyStep({sessionId=request.sessionId,activityId="Q03",roundId=request.roundId,stepId=entry.partId,actionId=request.actionId,actorUserId=request.actorUserId})
                state.committed[entry.partId]={socketId=p.socketId,orientation=entry.orientation,ownerUserId=request.actorUserId}
                state.accepted[entry.partId]=true; state.contributors[request.actorUserId]=true; entry.status="PLACED"; state.reservations[p.socketId]=nil
                result={ok=true,code="PLACED",step=accepted}
                if #self:_committedParts(state)==#PARTS then
                    result.completion=self.session:CompleteRound({sessionId=request.sessionId,activityId="Q03",roundId=request.roundId,actionId="complete:"..request.actionId,actorUserId=request.actorUserId})
                    result.receipt=result.completion; state.status="COMPLETED"
                end
            else
                assert(request.stepId=="cancel:"..entry.partId,"step does not match selection")
                free(entry); state.reservations[p.socketId]=nil; result={ok=true,code="RELEASED",released=true}
            end
        else error("unknown Q03 action") end
    end
    self.actions[request.actionId]=result; self.actionIdentities[request.actionId]=identity(request)
    self:_render(state)
    local reply=copy(result); reply.view=self:GetView(request.actorUserId); return reply
end
function Q03:ExpireReservations(roundId)
    local state=self.stateByRound[roundId or self.currentRoundId]
    if not state or state.status~="IN_PROGRESS" then return false end
    local changed=false; local current=self.clock()
    for socket,entry in pairs(state.reservations) do
        if current-entry.lastActivity>=15 then free(entry); state.reservations[socket]=nil; changed=true end
    end
    if changed then self.expiryRevision+=1; self:_render(state) end
    return changed
end
function Q03:ReleaseActor(actor,roundId)
    if roundId and roundId~=self.currentRoundId then return false end
    local state=self.stateByRound[self.currentRoundId]; if not state then return false end
    local changed=false
    for socket,entry in pairs(state.reservations) do if entry.ownerUserId==actor then free(entry); state.reservations[socket]=nil; changed=true end end
    if changed then self:_render(state) end
    return changed
end
function Q03:RecoveryState()
    return { roundId=self.currentRoundId, state=self.stateByRound[self.currentRoundId] }
end
function Q03:RecoverRelease(request)
    self.session:AssertRecovery(request)
    local state=self.stateByRound[self.currentRoundId]
    if state then
        for socket,entry in pairs(state.reservations) do free(entry); state.reservations[socket]=nil end
        self.expiryRevision+=1; self:_render(state)
    end
end
function Q03:RecoverRestart(request,newRoundId)
    self.session:RecoverCancel(request); self:RecoverRelease(request)
    self.currentRoundId=nil
    self:CreateRound({sessionId=request.sessionId,activityId="Q03",roundId=newRoundId,actorUserId=request.actorUserId})
    return newRoundId
end
function Q03:RecoverComplete(request)
    self.session:AssertRecovery(request); self:RecoverRelease(request)
    local state=assert(self.stateByRound[self.currentRoundId],"missing craft round")
    for _,part in ipairs(PARTS) do
        self.session:RecoverStep(request,part)
        state.committed[part]=state.committed[part] or {socketId=SOCKETS[part],orientation=0,ownerUserId=request.actorUserId}
        state.accepted[part]=true; state.sockets[SOCKETS[part]].status="PLACED"
    end
    state.contributors[request.actorUserId]=true
    local receipt=self.session:RecoverCompleteRound(request)
    state.status="COMPLETED"; self:_render(state)
    return receipt
end
function Q03:GetView(actor)
    self:ExpireReservations(self.currentRoundId)
    return self:_view(self.currentRoundId,actor)
end
Q03.PARTS=PARTS; Q03.SOCKETS=SOCKETS
return Q03
]=],
["roblox/mvp/server/activities/Q04.luau"] = [=[local Q04 = {}
Q04.__index = Q04

Q04.ActivityId = "Q04"
Q04.PassageIds = { "small-worlds", "night-pages", "next-chapter" }
Q04.Highlights = { "small-detail", "comforting-moment", "shared-spark" }
Q04.Reactions = { "moved", "cozy", "curious", "smile" }
Q04.Bookmarks = { "ribbon", "pressed-flower", "star-tab" }
local HIGHLIGHT_LABELS = { ["small-detail"]="Small detail", ["comforting-moment"]="Comforting moment", ["shared-spark"]="Shared spark" }
local REACTION_LABELS = {moved="Moved",cozy="Cozy",curious="Curious",smile="Made me smile"}
local BOOKMARK_LABELS = {ribbon="Ribbon",["pressed-flower"]="Pressed flower",["star-tab"]="Star tab"}

Q04.Passages = {
    ["small-worlds"] = "A tiny place can hold more than its walls suggest. A folded corner, a favorite cup, or a little handmade scene may keep a whole afternoon safe inside it. Reading gives those small worlds room to open. You can linger over one detail, carry its feeling with you, or close the page knowing it will still be there later.",
    ["night-pages"] = "At night, one quiet page can make the room feel kinder. The light may be low, the day may be finished, and still a sentence can offer somewhere gentle to rest your attention. You do not have to reach the ending. Mark the place, notice what comforted you, and return whenever the next page feels right.",
    ["next-chapter"] = "Friends can share a chapter without turning every page together. One person notices a bright line, another pauses at a quiet thought, and someone else simply enjoys being nearby. The story keeps its welcome for all of them. A good next chapter leaves space for different rhythms, small discoveries, and the choice to come back tomorrow."
}

local function contains(list, value)
    for _, item in ipairs(list) do if item == value then return true end end
    return false
end

local function copyDraft(draft)
    local result = { highlights = {}, reaction = draft.reaction, bookmark = draft.bookmark, note = draft.note or "", passageId = draft.passageId, revision = draft.revision, savedAt = draft.savedAt }
    for key, value in pairs(draft.highlights) do result.highlights[key] = value end
    return result
end

function Q04.new(options)
    assert(options and options.session and options.clock, "session and clock are required")
    return setmetatable({ session = options.session, clock = options.clock, context = options.context or {}, drafts = {}, lastPassage = {}, activeRoundId = nil, roundComplete = false, usedActions = {}, actionIdentities = {}, contributors = {} }, Q04)
end

Q04.new = Q04.new
Q04.Module = Q04

function Q04:_draft(actorUserId, passageId)
    local key = tostring(actorUserId) .. ":" .. passageId
    self.drafts[key] = self.drafts[key] or { passageId = passageId, revision = 0, highlights = {}, reaction = nil, bookmark = nil, note = "" }
    return self.drafts[key], key
end

function Q04:CreateRound(request)
    assert(request.sessionId == self.session.sessionId and request.activityId == self.ActivityId and request.roundId and request.actorUserId and self.session:IsPresent(request.actorUserId), "invalid Q04 round")
    assert(self.activeRoundId == nil or self.roundComplete, "Q04 round is active")
    assert(self.activeRoundId == nil or request.replay == true, "replay must be explicit")
    self.session:CreateRound(self.ActivityId, request.roundId, request.actorUserId, request.replay == true)
    self.activeRoundId, self.roundComplete = request.roundId, false
    return { activityId = self.ActivityId, roundId = request.roundId, state = "IN_PROGRESS" }
end

local function identity(request)
    local p=request.payload or {}
    -- Compare field values directly, including private text, with no delimiter ambiguity.
    return {actor=request.actorUserId,round=request.roundId,step=request.stepId,passage=p.passageId,revision=p.revision,
        reaction=p.reaction,bookmark=p.bookmark,note=p.note,complete=p.complete,highlights=p.highlights and table.concat(p.highlights,"|")}
end
local function same(a,b)
    for k,v in pairs(a) do if b[k]~=v then return false end end
    for k,v in pairs(b) do if a[k]~=v then return false end end
    return true
end
function Q04:_render(draft)
    local hook=self.context.renderReading
    if not hook then return end
    local highlight
    for _,id in ipairs(self.Highlights) do if draft.highlights[id] then highlight=HIGHLIGHT_LABELS[id]; break end end
    local summary={bookmark=draft.bookmark,bookmarkLabel=BOOKMARK_LABELS[draft.bookmark],reactionLabel=REACTION_LABELS[draft.reaction] or "A quiet page",highlightLabel=highlight,
        acknowledgement=draft.reaction and "Reaction saved · "..REACTION_LABELS[draft.reaction] or highlight and "Highlight saved · "..highlight or "Reading choice saved"}
    -- Deliberately omit actor ID, private note and all user-authored text.
    local ok,err=pcall(hook,summary); if not ok then warn("PCW-22 reading presentation",err) end
end

function Q04:Apply(request)
    assert(request and request.sessionId == self.session.sessionId and request.activityId == self.ActivityId and request.roundId == self.activeRoundId and type(request.actionId)=="string" and request.actionId~="" and self.session:IsPresent(request.actorUserId), "invalid Q04 action")
    if self.usedActions[request.actionId] then
        assert(same(self.actionIdentities[request.actionId],identity(request)),"action identity changed")
        local old=self.usedActions[request.actionId]
        return {ok=true,code=old.code,receipt=old.receipt,draft=copyDraft(self:_draft(request.actorUserId,request.payload.passageId)),view=self:GetView(request.actorUserId)}
    end
    assert(not (self.session.receipts and self.session.receipts[request.actionId]) and not (self.session.acceptedSteps and self.session.acceptedSteps[request.actionId]), "action belongs to another receipt")
    local payload = request.payload or {}
    local passageId = payload.passageId
    assert(contains(self.PassageIds, passageId), "unknown passage")
    local previous,key = self:_draft(request.actorUserId, passageId)
    local draft = copyDraft(previous)
    if payload.revision ~= nil then assert(payload.revision == draft.revision, "stale draft revision") end
    if payload.highlights then
        assert(#payload.highlights <= 3, "too many highlights")
        for _, value in ipairs(payload.highlights) do assert(contains(self.Highlights, value), "unknown highlight") end
        draft.highlights = {}
        for _, value in ipairs(payload.highlights) do draft.highlights[value] = true end
    end
    if payload.reaction ~= nil then assert(contains(self.Reactions, payload.reaction), "unknown reaction"); draft.reaction = payload.reaction end
    if payload.bookmark ~= nil then assert(contains(self.Bookmarks, payload.bookmark), "unknown bookmark"); draft.bookmark = payload.bookmark end
    if payload.note ~= nil then assert(type(payload.note) == "string" and #payload.note <= 500, "invalid note"); draft.note = payload.note end
    assert(payload.highlights or payload.reaction or payload.bookmark or payload.note~=nil or payload.complete==true,"reading choice required")
    if payload.complete == true then assert(next(draft.highlights) ~= nil and draft.reaction and draft.bookmark, "reading selections incomplete") end
    draft.revision += 1
    local accepted
    if not self.roundComplete then
        accepted = self.session:ApplyStep({ sessionId = self.session.sessionId, activityId = self.ActivityId, roundId = request.roundId, stepId = (request.stepId or "draft") .. ":" .. tostring(request.actorUserId) .. ":" .. passageId, actionId = request.actionId, actorUserId = request.actorUserId })
    else
        accepted = { activityId = self.ActivityId, roundId = request.roundId, stepId = "post-close-draft", actorUserId = request.actorUserId, acknowledgementOnly = true }
    end
    self.contributors[request.actorUserId] = true
    local receipt
    if payload.complete == true and not self.roundComplete then
        receipt = self.session:CompleteRound({ sessionId = self.session.sessionId, activityId = self.ActivityId, roundId = request.roundId, actionId = request.actionId .. ":complete", actorUserId = request.actorUserId })
        self.roundComplete = true
    end
    if payload.complete == true then draft.savedAt=self.clock() end
    self.drafts[key]=draft; self.lastPassage[request.actorUserId]=passageId
    self:_render(draft)
    local result = { ok = true, code = receipt and "COMPLETED" or (self.roundComplete and "ACKNOWLEDGED" or "SAVED"), receipt = receipt, draft = copyDraft(draft), view = self:GetView(request.actorUserId) }
    self.usedActions[request.actionId] = result
    self.actionIdentities[request.actionId] = identity(request)
    return result
end

function Q04:RecoveryState()
    return { roundId=self.activeRoundId, complete=self.roundComplete }
end
function Q04:RecoverComplete(request)
    self.session:AssertRecovery(request)
    self.session:RecoverStep(request,"host-recovery")
    local receipt=self.session:RecoverCompleteRound(request)
    self.roundComplete=true
    -- Shared recovery never invents anyone's reading choices or private note.
    local hook=self.context.renderReading
    if hook then
        local ok,err=pcall(hook,{acknowledgement="Shared reading petal restored by a host",reactionLabel="Reading together"})
        if not ok then warn("PCW-24 reading recovery presentation",err) end
    end
    return receipt
end

function Q04:GetView(actorUserId)
    local roundId = self.activeRoundId
    local passageId = self.lastPassage[actorUserId] or "small-worlds"
    local currentDraft = self:_draft(actorUserId, passageId)
    local function choices(ids, labels, stepId, field)
        local result = {}
        for index, id in ipairs(ids) do
            local payload = { passageId = passageId, [field] = id, revision=currentDraft.revision }
            if field == "highlight" then payload.highlights = { id }; payload.highlight = nil end
            local selected=field=="highlight" and currentDraft.highlights[id]==true or currentDraft[field]==id
            table.insert(result, { id = id, label = labels[index], stepId = stepId, payload = payload, enabled = true, selected=selected, groupId=stepId, confirm=false,
                description=selected and "Saved for you in this session" or "Tap this choice, then use the action above to save it." })
        end
        return result
    end
    local actions = {}
    for _, action in ipairs(choices(self.Highlights, { "Small detail", "Comforting moment", "Shared spark" }, "highlight", "highlight")) do table.insert(actions, action) end
    for _, action in ipairs(choices(self.Reactions, { "Moved", "Cozy", "Curious", "Made me smile" }, "reaction", "reaction")) do table.insert(actions, action) end
    for _, action in ipairs(choices(self.Bookmarks, { "Ribbon", "Pressed flower", "Star tab" }, "bookmark", "bookmark")) do table.insert(actions, action) end
    local ready = next(currentDraft.highlights) ~= nil and currentDraft.reaction ~= nil and currentDraft.bookmark ~= nil
    table.insert(actions, { id = "save", label = ready and (self.roundComplete and "Save my reading choices" or "Save reading + shared petal") or "Choose a highlight, reaction, and bookmark", stepId = "reading", payload = { passageId = passageId, complete = true, revision=currentDraft.revision }, enabled = ready, primary=ready and not self.roundComplete, groupId="save", reason = ready and nil or "Reading choices are incomplete" })
    local highlighted={}; for _,id in ipairs(self.Highlights) do if currentDraft.highlights[id] then table.insert(highlighted,HIGHLIGHT_LABELS[id]) end end
    return { activityId = self.ActivityId, roundId = roundId, state = self.roundComplete and "ROUND_COMPLETE" or "IN_PROGRESS", title = "One More Chapter", instructions = "Read at your own pace. Choose a highlight, a reaction, and a bookmark. A private reading note is optional.",
        reading = { title = "A quiet page", text = self.Passages[passageId], passageId = passageId }, draft=copyDraft(currentDraft),
        readingSummary={highlights=highlighted,reaction=REACTION_LABELS[currentDraft.reaction],bookmark=BOOKMARK_LABELS[currentDraft.bookmark]},
        noteAction={id="save-note",label="Save my private reading note",stepId="note",payload={passageId=passageId,revision=currentDraft.revision},enabled=true,confirm=false},
        guide={headline=self.roundComplete and "Shared reading petal saved" or "A quiet page together",detail=self.roundComplete and "Your choices are still yours. Friends can save their own reading without another reward; replay is optional." or "Read the passage, then save one highlight, reaction and bookmark. Choices stay saved when you close.",
            groups={{id="highlight",title="1 · What stood out?"},{id="reaction",title="2 · How did it feel?"},{id="bookmark",title="3 · Choose your bookmark"},{id="save",title="Save the shared reading"}}},
        progress = { done = self.roundComplete and 1 or 0, total = 1 }, availableActions = actions, acceptedStepIds = {}, contributors = self.contributors, busyReason = nil, errorText = nil, canReplay = self.roundComplete }
end

return Q04
]=],
["roblox/mvp/server/activities/Q05.luau"] = [=[local Config = require(script.Parent.Parent.Parent.shared.Config)
local Catalog = require(script.Parent.Parent.Parent.shared.FigureCatalog)
local Q05 = {}; Q05.__index = Q05
local Figures = {}; for _, entry in ipairs(Catalog.Figures) do table.insert(Figures, entry.id) end
local function clone(map) local out = {}; for k, v in pairs(map) do out[k] = v end; return out end
local function identity(request)
	local payload = request.payload
	return { actor = request.actorUserId, round = request.roundId, step = request.stepId,
		figure = payload.figureId, wish = payload.wishVersion, roll = payload.rollNumber }
end
local function same(a, b)
	return a.actor == b.actor and a.round == b.round and a.step == b.step and a.figure == b.figure and a.wish == b.wish and a.roll == b.roll
end
function Q05.new(ctx)
	assert(ctx and ctx.session, "Q05 requires session")
	local random = ctx.random or math.random
	local weighted = function()
		local value, cursor = random(), 0
		for _, entry in ipairs(Catalog.Figures) do cursor += entry.probability; if value < cursor then return entry.id end end
		return Config.SecretFigureId
	end
	return setmetatable({ ctx = ctx, session = ctx.session, clock = ctx.clock or os.clock,
		outcome = ctx.outcome or weighted, roundId = nil, wanted = nil, misses = 0, rolls = 0,
		wishVersion = 0, fulfilled = false, petalAwarded = false, collection = {}, receipts = {},
		latestResult = nil, purchasing = false }, Q05)
end
function Q05:_canSpend(actor)
	return self.session:IsPresent(actor) and self.session:CanSpend(actor, self.session.presence)
end
function Q05:_fail(actor, code, message)
	return { ok = false, code = code, message = message, view = self:GetView(actor) }
end
function Q05:_render()
	-- A display failure cannot roll back or repeat an authoritative purchase.
	if self.ctx.feedback then
		local ok, err = pcall(self.ctx.feedback.Render, self.ctx.feedback, self.wanted, self.fulfilled, self.collection, self.latestResult, self.petalAwarded)
		if not ok then warn("PCW-21 Labubu display needs attention", err) end
	end
end
function Q05:CreateRound(request)
	assert(request and request.activityId == "Q05" and request.roundId and not self.roundId, "invalid Q05 round")
	self.session:CreateRound("Q05", request.roundId, request.actorUserId)
	self.roundId = request.roundId; self:_render()
	return { activityId = "Q05", roundId = self.roundId, state = "READY" }
end
function Q05:_draw()
	-- The selected secret has the same fifth-roll guarantee as a regular.
	if self.misses >= Config.WantedGuaranteeRoll - 1 then return self.wanted end
	local figure = self.outcome({ figures = Figures, wantedFigureId = self.wanted, misses = self.misses })
	assert(Catalog.ById[figure], "Outcome provider returned an unknown figure")
	return figure
end
function Q05:_completeWanted(actor, actionId)
	if self.petalAwarded or self.session.petals.Q05 then self.petalAwarded = true; return false end
	self.session:ApplyStep({ sessionId = self.session.sessionId, activityId = "Q05", roundId = self.roundId,
		stepId = "wanted-fulfilled", actionId = "q05-step:" .. actionId, actorUserId = actor })
	local receipt = self.session:CompleteRound({ sessionId = self.session.sessionId, activityId = "Q05",
		roundId = self.roundId, actionId = "q05-complete:" .. actionId, actorUserId = actor })
	self.petalAwarded = true; return receipt.petalGranted == true
end
function Q05:Apply(request)
	local actor = type(request) == "table" and request.actorUserId or nil
	if type(request) ~= "table" or request.sessionId ~= self.session.sessionId or request.activityId ~= "Q05"
		or not self.roundId or request.roundId ~= self.roundId or type(request.actionId) ~= "string" or request.actionId == ""
		or type(request.payload) ~= "table" or not actor then
		return self:_fail(actor, "STALE_WISH", "Reopen the Labubu booth to see the current wish and balance.")
	end
	local key = identity(request)
	local previous = self.receipts[request.actionId]
	if previous then
		if not same(previous.identity, key) then return self:_fail(actor, "ACTION_CHANGED", "That request already saved a different choice. Reopen the booth.") end
		return { ok = true, code = "DUPLICATE", receipt = clone(previous.receipt), view = self:GetView(actor) }
	end
	if not self:_canSpend(actor) then
		return self:_fail(actor, "PHUONGS_CHOICE", "Phuong chooses her wish and opens the boxes. Andrew can help only while she is away; friends can earn the shared fund together.")
	end
	if self.purchasing then return self:_fail(actor, "ROLL_PENDING", "Your last box is being saved. Wait for its result before opening another.") end
	if request.stepId ~= "select-wanted" and request.stepId ~= "roll" then return self:_fail(actor, "BAD_CHOICE", "Choose a figure card, confirm the wish, then use Get a Labubu.") end
	if request.payload.wishVersion ~= self.wishVersion then return self:_fail(actor, "WISH_CHANGED", "The wish changed. Review the current wish before confirming anything else.") end
	-- SessionService uses a shared action namespace. Never reuse a purchase,
	-- completion or another activity's accepted action as a fresh Q05 mutation.
	for _, actionId in ipairs({ request.actionId, "purchase:" .. request.actionId, "q05-step:" .. request.actionId, "q05-complete:" .. request.actionId }) do
		if self.session.receipts[actionId] or self.session.acceptedSteps[actionId] then
			return self:_fail(actor, "ACTION_USED", "That choice was already saved. Reopen the booth to continue safely.")
		end
	end
	local round = self.session.rounds[self.roundId]
	if not round or round.activityId ~= "Q05" or (round.state ~= "IN_PROGRESS" and not self.petalAwarded) then
		return self:_fail(actor, "ROUND_CHANGED", "The booth is refreshing. Reopen it before using the shared fund.")
	end
	if request.stepId == "select-wanted" then
		if self.wanted and not self.fulfilled then return self:_fail(actor, "WISH_LOCKED", "Your confirmed wish stays selected until you receive it. Every box brings the guarantee closer.") end
		if not Catalog.ById[request.payload.figureId] then return self:_fail(actor, "UNKNOWN_FIGURE", "Choose one of the seven labeled figure cards.") end
		self.wanted = request.payload.figureId; self.wishVersion += 1; self.misses = 0; self.rolls = 0
		self.fulfilled = (self.collection[self.wanted] or 0) > 0
		local petal = self.fulfilled and self:_completeWanted(actor, request.actionId) or false
		local receipt = { actionId = request.actionId, wantedFigureId = self.wanted, wantedLabel = Catalog.Label(self.wanted),
			wishVersion = self.wishVersion, ownedFulfillment = self.fulfilled, petalGranted = petal }
		self.receipts[request.actionId] = { identity = key, receipt = receipt }; self:_render()
		return { ok = true, code = self.fulfilled and "WANTED_ALREADY_OWNED" or "WANTED_LOCKED", receipt = clone(receipt), view = self:GetView(actor) }
	end
	if not self.wanted then return self:_fail(actor, "WISH_REQUIRED", "Choose a figure card and Confirm wish before spending the shared fund.") end
	if self.fulfilled then return self:_fail(actor, "WISH_FULFILLED", "Your wish is already in the collection. The birthday goal is complete; another wish is optional.") end
	if request.payload.rollNumber ~= self.rolls + 1 then return self:_fail(actor, "ROLL_CHANGED", "That box was already handled. Review the saved result before choosing another box.") end
	if self.session.fundBalance < Config.RollCost then return self:_fail(actor, "INSUFFICIENT_FUND", "A box needs 20 from the shared fund. Help with another activity, then come back together.") end
	local drew, figure = pcall(self._draw, self)
	if not drew or not Catalog.ById[figure] then return self:_fail(actor, "BOX_UNAVAILABLE", "This box could not be prepared. Your shared fund has not been spent.") end
	local awardedAt = self.clock()
	-- No yields/external presentation calls within this transaction. Expected
	-- wish/roll guards also reject distinct request IDs from one stale UI state.
	self.purchasing = true
	local purchase = self.session:CommitPurchase({ actionId = request.actionId, actorUserId = actor, cost = Config.RollCost, awardFigureId = figure })
	self.collection[figure] = (self.collection[figure] or 0) + 1; self.rolls += 1
	local wanted = figure == self.wanted
	if wanted then self.fulfilled = true else self.misses += 1 end
	local petal = wanted and self:_completeWanted(actor, request.actionId) or false
	local receipt = { sessionId = purchase.sessionId, activityId = "Q05", roundId = self.roundId, actionId = request.actionId,
		receiptId = purchase.receiptId, debitApplied = true, cost = Config.RollCost,
		awardFigureId = figure, awardLabel = Catalog.Label(figure), wantedFigureId = self.wanted, wantedLabel = Catalog.Label(self.wanted),
		wantedFulfilled = wanted, petalGranted = petal, revealSkippable = true, awardedAt = awardedAt,
		wishVersion = self.wishVersion, rollNumber = self.rolls, copies = self.collection[figure] }
	self.receipts[request.actionId] = { identity = key, receipt = receipt }
	self.latestResult = receipt; self.pendingReveal = receipt -- Compatibility; no reveal acknowledgement changes awards.
	self.purchasing = false; self:_render()
	return { ok = true, code = "AWARDED", receipt = clone(receipt), view = self:GetView(actor) }
end
function Q05:RecoveryState()
	return { roundId=self.roundId,wanted=self.wanted,fulfilled=self.fulfilled,wishVersion=self.wishVersion,
		rolls=self.rolls,misses=self.misses,collection=clone(self.collection),purchasing=self.purchasing,recovered=self.recoveryReceipt~=nil }
end
function Q05:RecoverComplete(request)
	self.session:AssertRecovery(request)
	if self.recoveryReceipt then return clone(self.recoveryReceipt) end
	assert(request.roundId==self.roundId and Catalog.ById[self.wanted] and not self.fulfilled and not self.purchasing,"select an unfulfilled wish normally first")
	if not self.session.petals.Q05 then self.session:RecoverStep(request,"wanted-fulfilled") end
	local completion=self.session:RecoverCompleteRound(request)
	self.collection[self.wanted]=(self.collection[self.wanted] or 0)+1
	self.fulfilled,self.petalAwarded=true,true
	-- Recovery does not consume a paid roll, a miss, or the fifth-box guarantee.
	local receipt={sessionId=self.session.sessionId,activityId="Q05",roundId=self.roundId,actionId=request.actionId,
		receiptId="host-wish:"..self.session.sessionId,recovery=true,debitApplied=false,cost=0,
		awardFigureId=self.wanted,awardLabel=Catalog.Label(self.wanted),wantedFigureId=self.wanted,wantedLabel=Catalog.Label(self.wanted),
		wantedFulfilled=true,petalGranted=completion.petalGranted,fundRewardGranted=0,revealSkippable=true,awardedAt=self.clock(),
		wishVersion=self.wishVersion,rollNumber=self.rolls,copies=self.collection[self.wanted]}
	self.recoveryReceipt=receipt; self.latestResult=receipt; self.pendingReveal=receipt; self:_render()
	return clone(receipt)
end
function Q05:ReleaseActor(_actor, _roundId)
	-- Preview/reveal progress is local only. Committed wishes, collection,
	-- receipts and debits survive Close/reset/lobby/rejoin for this server.
end
function Q05:GetView(actor)
	local snapshot = self.session:GetSnapshot()
	local controller = self:_canSpend(actor)
	local storyComplete = snapshot.petals.Q05 == true
	local selectable = controller and (not self.wanted or self.fulfilled) and not self.purchasing
	local actions, figures, total = {}, {}, 0
	for _, entry in ipairs(Catalog.Figures) do
		local count = self.collection[entry.id] or 0; total += count
		table.insert(figures, { id = entry.id, label = entry.label, secret = entry.secret, odds = entry.odds, copies = count, selected = self.wanted == entry.id })
		if selectable then
			table.insert(actions, { id = "select-" .. entry.id, label = "Confirm wish · " .. entry.label, stepId = "select-wanted",
				payload = { figureId = entry.id, wishVersion = self.wishVersion }, enabled = true, groupId = "wish",
				description = "Previewing is free. Confirming locks this wish until it is in the collection.",
				confirm = { title = "Confirm " .. entry.label .. " as your wish?", detail = storyComplete
					and "This is optional collecting. Your petal and cake progress stay saved. This wish locks until received; each box costs 20."
					or "This wish locks until you receive it. Each box costs 20 from the shared fund; your wish is guaranteed by box five, including the secret.", label = "Confirm wish" } })
		end
	end
	if controller and self.wanted and not self.fulfilled then
		table.insert(actions, { id = "roll", label = "Get a Labubu - 20", stepId = "roll", primary = true, groupId = "open",
			payload = { wishVersion = self.wishVersion, rollNumber = self.rolls + 1 }, enabled = snapshot.fundBalance >= Config.RollCost and not self.purchasing,
			reason = self.purchasing and "Your last box is being saved." or "Help with another activity to reach 20 in the shared fund.",
			description = "Spend 20 together. Your figure is saved before its skippable reveal.",
			confirm = { title = "Open a box for " .. Catalog.Label(self.wanted) .. "?", detail = "Use 20 from the shared fund of " .. tostring(snapshot.fundBalance) .. ". The figure is saved immediately, even if you close or skip.", label = "Spend 20 and open" } })
	end
	local nextActivity
	for _, id in ipairs(Config.ActivityIds) do if id ~= "Q05" and snapshot.petals[id] ~= true then nextActivity = id; break end end
	if not nextActivity then nextActivity = storyComplete and "Cake" or nil end
	local remaining = self.fulfilled and 0 or math.max(0, Config.WantedGuaranteeRoll - self.misses)
	local controlMessage = controller and (actor == self.session.phuongUserId and "Your wish, with help from your friends." or "Andrew can help choose and open while Phuong is away.")
		or "Phuong chooses her ]==]
return #_G.__PCW25ContractText