local Q04 = {}
Q04.__index = Q04

Q04.ActivityId = "Q04"
Q04.PassageIds = { "small-worlds", "night-pages", "next-chapter" }
Q04.Highlights = { "small-detail", "comforting-moment", "shared-spark" }
Q04.Reactions = { "moved", "cozy", "curious", "smile" }
Q04.Bookmarks = { "ribbon", "pressed-flower", "star-tab" }

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
    local result = { highlights = {}, reaction = draft.reaction, bookmark = draft.bookmark, note = draft.note or "", passageId = draft.passageId, revision = draft.revision }
    for key, value in pairs(draft.highlights) do result.highlights[key] = value end
    return result
end

function Q04.new(options)
    assert(options and options.session and options.clock, "session and clock are required")
    return setmetatable({ session = options.session, clock = options.clock, context = options.context or {}, drafts = {}, activeRoundId = nil, roundComplete = false, usedActions = {}, contributors = {} }, Q04)
end

Q04.new = Q04.new
Q04.Module = Q04

function Q04:_draft(actorUserId, passageId)
    local key = tostring(actorUserId) .. ":" .. passageId
    self.drafts[key] = self.drafts[key] or { passageId = passageId, revision = 0, highlights = {}, reaction = nil, bookmark = nil, note = "" }
    return self.drafts[key], key
end

function Q04:CreateRound(request)
    assert(request.activityId == self.ActivityId and request.roundId and request.actorUserId, "invalid Q04 round")
    assert(self.activeRoundId == nil or self.roundComplete, "Q04 round is active")
    self.session:CreateRound(self.ActivityId, request.roundId, request.actorUserId, request.replay == true)
    self.activeRoundId, self.roundComplete = request.roundId, false
    return { activityId = self.ActivityId, roundId = request.roundId, state = "IN_PROGRESS" }
end

function Q04:Apply(request)
    assert(request and request.roundId == self.activeRoundId and request.actionId and request.actorUserId, "invalid Q04 action")
    if self.usedActions[request.actionId] then return self.usedActions[request.actionId] end
    local payload = request.payload or {}
    local passageId = payload.passageId
    assert(contains(self.PassageIds, passageId), "unknown passage")
    local draft = self:_draft(request.actorUserId, passageId)
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
    draft.revision += 1
    local accepted
    if not self.roundComplete then
        accepted = self.session:ApplyStep({ sessionId = self.session.sessionId, activityId = self.ActivityId, roundId = request.roundId, stepId = request.stepId or ("draft:" .. tostring(request.actorUserId) .. ":" .. passageId), actionId = request.actionId, actorUserId = request.actorUserId })
    else
        accepted = { activityId = self.ActivityId, roundId = request.roundId, stepId = "post-close-draft", actorUserId = request.actorUserId, acknowledgementOnly = true }
    end
    self.contributors[request.actorUserId] = true
    local receipt
    if payload.complete == true and not self.roundComplete then
        assert(next(draft.highlights) ~= nil and draft.reaction and draft.bookmark, "reading selections incomplete")
        receipt = self.session:CompleteRound({ sessionId = self.session.sessionId, activityId = self.ActivityId, roundId = request.roundId, actionId = request.actionId .. ":complete", actorUserId = request.actorUserId })
        self.roundComplete = true
    end
    local result = { ok = true, code = receipt and "COMPLETED" or (self.roundComplete and "ACKNOWLEDGED" or "SAVED"), receipt = receipt, draft = copyDraft(draft), view = self:GetView(request.actorUserId) }
    self.usedActions[request.actionId] = result
    return result
end

function Q04:GetView(actorUserId)
    local roundId = self.activeRoundId
    local passageId = "small-worlds"
    for key, draft in pairs(self.drafts) do
        if string.find(key, tostring(actorUserId) .. ":", 1, true) then passageId = draft.passageId; break end
    end
    local function choices(ids, labels, stepId, field)
        local result = {}
        for index, id in ipairs(ids) do
            local payload = { passageId = passageId, [field] = id }
            if field == "highlight" then payload.highlights = { id }; payload.highlight = nil end
            table.insert(result, { id = id, label = labels[index], stepId = stepId, payload = payload, enabled = not self.roundComplete })
        end
        return result
    end
    local actions = {}
    for _, action in ipairs(choices(self.Highlights, { "Small detail", "Comforting moment", "Shared spark" }, "highlight", "highlight")) do table.insert(actions, action) end
    for _, action in ipairs(choices(self.Reactions, { "Moved", "Cozy", "Curious", "Made me smile" }, "reaction", "reaction")) do table.insert(actions, action) end
    for _, action in ipairs(choices(self.Bookmarks, { "Ribbon", "Pressed flower", "Star tab" }, "bookmark", "bookmark")) do table.insert(actions, action) end
    local currentDraft = self:_draft(actorUserId, passageId)
    local ready = next(currentDraft.highlights) ~= nil and currentDraft.reaction ~= nil and currentDraft.bookmark ~= nil
    table.insert(actions, { id = "save", label = ready and "Save reading" or "Choose a highlight, reaction, and bookmark", stepId = "reading", payload = { passageId = passageId, complete = ready }, enabled = ready and not self.roundComplete, reason = ready and nil or "Reading choices are incomplete" })
    return { activityId = self.ActivityId, roundId = roundId, state = self.roundComplete and "ROUND_COMPLETE" or "IN_PROGRESS", title = "One More Chapter", instructions = "Choose a highlight, reaction, and bookmark; a note is optional.", reading = { title = "A quiet page", text = self.Passages[passageId], passageId = passageId }, progress = { done = self.roundComplete and 1 or 0, total = 1 }, availableActions = actions, acceptedStepIds = {}, contributors = self.contributors, busyReason = nil, errorText = nil, canReplay = self.roundComplete }
end

return Q04
