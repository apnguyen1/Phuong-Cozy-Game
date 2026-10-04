local Config = require(script.Parent.Parent.Parent.shared.Config)
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
		or "Phuong chooses her wish and opens the boxes. Friends help earn the shared fund; Andrew can help while Phuong is away."
	return { activityId = "Q05", roundId = self.roundId, state = storyComplete and "FULFILLED" or "READY", title = "A Labubu Wish",
		instructions = "Friends earn together. Phuong confirms her wish. Each box costs 20; the wish arrives by box five. Collection copies: " .. tostring(total),
		progress = { done = storyComplete and 1 or 0, total = 1 }, availableActions = actions, acceptedStepIds = storyComplete and { "wanted-fulfilled" } or {}, contributors = {},
		busyReason = controlMessage, errorText = nil, canReplay = false, sharedFundBalance = snapshot.fundBalance,
		wantedFigureId = self.wanted, wantedLabel = self.wanted and Catalog.Label(self.wanted) or "No wish confirmed yet", wishVersion = self.wishVersion,
		unsuccessfulRollCount = self.misses, rollCount = self.rolls, attemptsRemaining = remaining, wishFulfilled = self.fulfilled,
		q05Petal = storyComplete, collection = clone(self.collection), collectionCount = total, figures = figures,
		canControl = controller, canChooseWish = selectable, controlMessage = controlMessage,
		latestResult = self.latestResult and clone(self.latestResult) or nil, nextActivity = nextActivity,
		guide = { headline = storyComplete and "Phuong's Labubu wish is complete!" or self.wanted and "Your wish is confirmed · " .. Catalog.Label(self.wanted) or "Choose Phuong's birthday wish",
			detail = storyComplete and "Your petal is saved. Continue the birthday story; any more collecting is optional and cannot relock cake." or controlMessage,
			stepLabel = self.fulfilled and "Wish received · petal saved" or self.wanted and tostring(remaining) .. " boxes or fewer until your wish" or "Preview a card → Confirm wish → Get a Labubu",
			groups = { { id = "wish", title = "Choose a wish", kind = "choices" }, { id = "open", title = "Open a box", kind = "actions" } } } }
end
Q05.Figures = Figures
return Q05
