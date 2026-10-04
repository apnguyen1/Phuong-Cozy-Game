local Q04 = {}
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
                description=selected and "Saved for you in this session" or "Tap to save this choice and continue." })
        end
        return result
    end
    local actions = {}
    for _, action in ipairs(choices(self.Highlights, { "Small detail", "Comforting moment", "Shared spark" }, "highlight", "highlight")) do table.insert(actions, action) end
    for _, action in ipairs(choices(self.Reactions, { "Moved", "Cozy", "Curious", "Made me smile" }, "reaction", "reaction")) do table.insert(actions, action) end
    for _, action in ipairs(choices(self.Bookmarks, { "Ribbon", "Pressed flower", "Star tab" }, "bookmark", "bookmark")) do table.insert(actions, action) end
    local ready = next(currentDraft.highlights) ~= nil and currentDraft.reaction ~= nil and currentDraft.bookmark ~= nil
    local choicesSaved = (next(currentDraft.highlights) and 1 or 0) + (currentDraft.reaction and 1 or 0) + (currentDraft.bookmark and 1 or 0)
    table.insert(actions, { id = "save", label = ready and (self.roundComplete and "Save my reading choices" or "Save reading + shared petal") or "Choose a highlight, reaction, and bookmark", stepId = "reading", payload = { passageId = passageId, complete = true, revision=currentDraft.revision }, enabled = ready, primary=ready and not self.roundComplete, groupId="save", reason = ready and nil or "Reading choices are incomplete" })
    local highlighted={}; for _,id in ipairs(self.Highlights) do if currentDraft.highlights[id] then table.insert(highlighted,HIGHLIGHT_LABELS[id]) end end
    return { activityId = self.ActivityId, roundId = roundId, state = self.roundComplete and "ROUND_COMPLETE" or "IN_PROGRESS", title = "One More Chapter", instructions = "Read at your own pace. Choose a highlight, a reaction, and a bookmark. A private reading note is optional.",
        reading = { title = "A quiet page", text = self.Passages[passageId], passageId = passageId }, draft=copyDraft(currentDraft),
        readingSummary={highlights=highlighted,reaction=REACTION_LABELS[currentDraft.reaction],bookmark=BOOKMARK_LABELS[currentDraft.bookmark]},
        noteAction={id="save-note",label="Save my private reading note",stepId="note",payload={passageId=passageId,revision=currentDraft.revision},enabled=true,confirm=false},
        guide={headline=self.roundComplete and "Shared reading petal saved" or "A quiet page together",stepLabel=tostring(choicesSaved).." of 3 reading choices saved"..(self.roundComplete and " · shared petal complete" or ready and " · ready to finish" or ""),detail=self.roundComplete and "Your choices are still yours. Friends can save their own reading without another reward; replay is optional." or "Read the passage, then save one highlight, reaction and bookmark. Choices stay saved when you close.",
            groups={{id="highlight",title="1 · What stood out?"},{id="reaction",title="2 · How did it feel?"},{id="bookmark",title="3 · Choose your bookmark"},{id="save",title="Save the shared reading"}}},
        progress = { done = self.roundComplete and 1 or 0, total = 1 }, availableActions = actions, acceptedStepIds = {}, contributors = self.contributors, busyReason = nil, errorText = nil, canReplay = self.roundComplete }
end

return Q04
