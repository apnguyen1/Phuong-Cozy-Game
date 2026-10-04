_G.__PCW25ContractText..=[==[the bed, craft and food have recoverable holds/rounds." end
        if not state.round or state.round.state~="IN_PROGRESS" then return nil,"Open an incomplete round first. Completed work is preserved." end
        effect=operation=="ReleaseReservations" and "Release every held choice for this activity. Keep all placed work, petals and funds."
            or "Discard only this incomplete round's placed work and holds, then open a fresh round. Keep all earned petals, shared funds and bedroom shelf placements. No reward is granted."
    elseif operation=="CompleteQuest" or operation=="FulfillWish" then
        if activityId=="Q05" then
            local wish=state.localState
            if not wish or not Catalog.ById[wish.wanted] then return nil,"Phuong must first confirm a wish at the Labubu booth; Andrew can choose normally while she is away." end
            if wish.recovered then return nil,"The one Labubu recovery for this server session was already used." end
            if wish.fulfilled or wish.purchasing then return nil,"The current wish is already fulfilled or a box is being saved." end
            effect="Add exactly one "..Catalog.Label(wish.wanted).." to the collection; fulfill the selected wish. "
                ..(state.petals.Q05 and "Keep the existing Q05 petal." or "Grant the missing Q05 petal once.")
                .." Spend 0 and grant 0 funds. Preserve paid rolls and misses. One wish recovery per server session."
        else
            if state.petals[activityId] and state.missingReward==0 then return nil,"This quest's initial petal and reward are already saved." end
            effect="Complete "..TITLES[activityId].." and its visible activity state. "..(state.petals[activityId] and "Keep its saved petal. " or "Grant its missing petal once. ")
                .."Add only the missing initial reward: "..state.missingReward..". No replay reward."
            if activityId=="Q01" then effect..=" Fill all bed tasks and use Soft and snug if no final style is saved. Keep the optional shelf." end
            if activityId=="Q02" then effect..=" Jasper finishes happy in the yard." end
            if activityId=="Q03" then effect..=" Keep placed orientations; fill missing pieces at zero turns. Phuong can still choose the finishing lamp." end
            if activityId=="Q04" then effect..=" Preserve every person's choices and private notes; no reading response is invented." end
            if activityId=="Q06" then effect..=" Keep accepted choices; fill only missing slots with Rice, Tofu, Greens, Sauce, Plate and Cup respectively." end
        end
    elseif operation=="TopUp" then
        if self.topUps>=5 then return nil,"All five +20 emergency top-ups have been used in this session." end
        local remaining=self.lastTopUp and math.ceil(30-(self.clock()-self.lastTopUp)) or 0
        if remaining>0 then return nil,"Wait "..remaining.." seconds before another top-up." end
        effect="Add exactly 20 to the shared fund: "..state.fund.." → "..(state.fund+20)..". Top-up "..(self.topUps+1).." of 5 this session; wait 30 seconds between top-ups. No petal changes."
    elseif operation=="InviteCake" or operation=="StartCake" then
        if not self.session:AllPetalsComplete() then return nil,"All six petals are required before cake recovery." end
        if self.cake.startedAt then return nil,"The celebration has already started and cannot restart." end
        effect=operation=="InviteCake" and "Arm the normal invitation and Phuong's seat. If Phuong is already seated, the celebration begins now. Nobody is moved."
            or "Start the single birthday celebration now, bypassing the normal Phuong seat trigger. Keep seats and optional personal camera/Skip controls. No rewards."
    elseif operation=="AdvanceCake" then
        if self.cake.cutAt or (self.cake.phase~="CELEBRATING" and self.cake.phase~="CAKE_READY") then return nil,"Start the celebration first; an already-cut cake cannot be cut twice." end
        effect="End any remaining birthday presentation and make the first cut once. Everyone can take a slice; optional cameras return and saved slice/eating state remains. No rewards."
    else
        effect="Release only your activity holds, leave your seat safely and move only you to the "..(operation=="ReturnBedroom" and "bedroom arrival." or "patio arrival.").." No progress or funds change."
    end
    return {operation=operation,activityId=activityId,label=LABELS[operation],state=state,current=self:_summary(state,activityId),effect=effect}
end
function HostService:GetView(actor)
    if not self:IsHost(actor) then return nil end
    local actions={}
    local function add(operation,id)
        local plan,reason=self:_plan(operation,id)
        table.insert(actions,{operation=operation,activityId=id,label=LABELS[operation],enabled=plan~=nil,reason=reason})
    end
    for _,id in ipairs(Config.ActivityIds) do
        if RESETTABLE[id] then add("ReleaseReservations",id); add("RestartRound",id) end
        add("CompleteQuest",id)
    end
    for _,op in ipairs({"TopUp","FulfillWish","InviteCake","StartCake","AdvanceCake","ReturnBedroom","ReturnPatio"}) do add(op) end
    local active={}; for _,id in ipairs({Config.PhuongUserId,Config.HostUserId}) do if self.overrides[id] then table.insert(active,hostName(id)) end end
    local quote=self.quotes[actor]
    if quote and quote.expiresAt<=self.clock() then self.quotes[actor]=nil; quote=nil end
    return {authorized=true,actor=hostName(actor),override=self.overrides[actor]==true,activeOverrides=active,revision=self.revision,
        fundBalance=self.session.fundBalance,petals=copy(self.session.petals),actions=actions,audit=copy(self.audit),
        topUpsUsed=self.topUps,topUpLimit=5,topUpAmount=20,topUpCooldown=30,requestCount=self.requestCount,requestLimit=512,
        confirmation=quote and {token=quote.token,label=quote.label,current=quote.current,effect=quote.effect,expiresAt=quote.expiresAt},
        inWorld=self:_present(actor),hint="Normal choices stay Phuong-first. Override is for deliberate recovery by Phuong or Andrew."}
end
function HostService:_execute(plan,request)
    local operation,id=plan.operation,plan.activityId
    if operation=="TopUp" then
        self.session:AddFund(20); self.topUps+=1; self.lastTopUp=self.clock()
    elseif QUEST_ACTIONS[operation] or operation=="FulfillWish" then
        local activity=self.activities[id]
        local roundId=activity:RecoveryState().roundId
        if not roundId then
            roundId=self.runtime.newRoundId(id)
            activity:CreateRound({sessionId=request.sessionId,actionId=request.actionId,activityId=id,roundId=roundId,actorUserId=request.actorUserId})
            self.runtime.setRoundId(id,roundId)
        end
        local recovery={sessionId=request.sessionId,actionId=request.actionId,actorUserId=request.actorUserId,activityId=id,roundId=roundId}
        if operation=="ReleaseReservations" then activity:RecoverRelease(recovery)
        elseif operation=="RestartRound" then
            roundId=activity:RecoverRestart(recovery,self.runtime.newRoundId(id)); self.runtime.setRoundId(id,roundId)
        else
            local receipt=activity:RecoverComplete(recovery); self.runtime.setRoundId(id,roundId)
            return {ok=true,receipt=receipt}
        end
    elseif operation=="InviteCake" or operation=="StartCake" or operation=="AdvanceCake" then
        local cakeRequest={sessionId=request.sessionId,actionId="host-cake:"..request.actionId,actorUserId=request.actorUserId,
            generation=self.cake.generation,action=operation=="InviteCake" and "Arm" or operation=="StartCake" and "RecoverStart" or "RecoverCut"}
        if operation=="InviteCake" then return self.cake:Apply(cakeRequest) end
        return self.cake:Recover(cakeRequest)
    else
        local destination=operation=="ReturnBedroom" and "Bedroom" or "Patio"
        if not self.runtime.travel(request.actorUserId,destination) then return reject("HostTravelUnavailable","Your character or destination is unavailable. Try again after respawning.") end
        return {ok=true,destination=destination}
    end
    return {ok=true}
end

local FIELDS={kind=true,sessionId=true,actionId=true,actorUserId=true,action=true,enabled=true,operation=true,activityId=true,token=true}
function HostService:Apply(request)
    if type(request)~="table" or not self:_present(request.actorUserId) then return reject("HostPermission","Only Phuong and Andrew in the birthday world can use host controls.") end
    if request.sessionId~=self.session.sessionId or type(request.actionId)~="string" or #request.actionId<1 or #request.actionId>96 then return reject("HostIdentity","Reopen host controls for this session.") end
    for field in pairs(request) do if not FIELDS[field] then return reject("HostMalformed","Use one of the listed host controls.") end end
    local command=request.action
    if command~="Prepare" and command~="Confirm" and command~="Cancel" and command~="SetOverride" then return reject("HostMalformed","Use one of the listed host controls.") end
    if command=="SetOverride" then
        if type(request.enabled)~="boolean" or request.operation~=nil or request.activityId~=nil or request.token~=nil then return reject("HostMalformed","Choose whether Override is enabled.") end
    elseif command=="Prepare" then
        if type(request.operation)~="string" or request.token~=nil or request.enabled~=nil or (request.activityId~=nil and type(request.activityId)~="string") then return reject("HostMalformed","Choose a listed recovery action.") end
    elseif type(request.token)~="string" or #request.token>128 or request.operation~=nil or request.activityId~=nil or request.enabled~=nil then return reject("HostMalformed","Review the confirmation before continuing.") end
    local identity={actor=request.actorUserId,action=command,enabled=request.enabled,operation=request.operation,activityId=request.activityId,token=request.token}
    local previous=self.results[request.actionId]
    if previous then
        if not equal(previous.identity,identity) then return reject("HostIdentityChanged","That request already represents another choice.") end
        return copy(previous.result)
    end
    if self.session.receipts[request.actionId] or self.session.acceptedSteps[request.actionId] or self.session.receipts["host-cake:"..request.actionId] then return reject("HostActionUsed","That request was already used. Choose again.") end
    if self.requestCount>=512 then return reject("HostLimit","This session reached its host request limit. Ordinary play remains available.") end
    local actor,at=request.actorUserId,self.clock()
    if self.lastRequest[actor] and at-self.lastRequest[actor]<.5 then return reject("HostTooQuick","Wait a moment for your last host choice to settle.") end
    self.lastRequest[actor]=at
    local result
    if command=="SetOverride" then
        local before=self.overrides[actor]==true
        self.overrides[actor]=request.enabled; self.quotes[actor]=nil
        if before~=request.enabled then self:_record(actor,"Override "..(request.enabled and "enabled" or "ended"),nil,before and "Override active" or "Normal choices",request.enabled and "Override active" or "Normal choices") end
        result={ok=true,code="HostOverride",message=request.enabled and "Override active. Every recovery still needs a current-state confirmation." or "Override ended. Normal choices remain active."}
    elseif command=="Cancel" then
        if self.quotes[actor] and self.quotes[actor].token==request.token then self.quotes[actor]=nil end
        result={ok=true,code="HostCancelled",message="Recovery cancelled. Nothing changed."}
    elseif not self.overrides[actor] then return reject("HostOverrideRequired","Enable Override explicitly before preparing a recovery.")
    elseif command=="Prepare" then
        local plan,reason=self:_plan(request.operation,request.activityId)
        if not plan then return reject("HostUnavailable",reason) end
        self.serial+=1; plan.token="host:"..self.serial..":"..actor; plan.expiresAt=at+30
        self.quotes[actor]=copy(plan)
        result={ok=true,code="HostPrepared",message="Review the current state and exact effect, then Confirm or Cancel.",confirmation={token=plan.token,label=plan.label,current=plan.current,effect=plan.effect,expiresAt=plan.expiresAt}}
    else
        local plan=self.quotes[actor]
        if not plan or plan.token~=request.token or plan.expiresAt<=at then self.quotes[actor]=nil; return reject("HostQuoteExpired","That confirmation expired or belongs to another host. Review a fresh preview.") end
        local fresh,reason=self:_plan(plan.operation,plan.activityId)
        if not fresh or not equal(plan.state,fresh.state) then self.quotes[actor]=nil; return reject("HostStateChanged",reason or "The shared state changed. Review a fresh preview before confirming.") end
        self.quotes[actor]=nil
        local called,outcome=pcall(self._execute,self,plan,request)
        if not called then
            local activity=plan.activityId and self.activities[plan.activityId]
            local current=activity and activity:RecoveryState().roundId
            if current then self.runtime.setRoundId(plan.activityId,current) end
            warn("PCW-24 recovery needs attention",outcome)
            self:_record(actor,plan.operation.." needs review",plan.activityId,plan.current,self:_summary(self:_state(plan.activityId,plan.operation),plan.activityId))
            result=reject("HostRecoveryFailed","Recovery could not fully finish. Current state is refreshed; review it before trying again.")
        elseif not outcome.ok then result=outcome
        else
            self:_record(actor,plan.operation,plan.activityId,plan.current,self:_summary(self:_state(plan.activityId,plan.operation),plan.activityId))
            result={ok=true,code="HostRecovered",message=plan.label.." saved.",operation=plan.operation,activityId=plan.activityId,receipt=outcome.receipt,destination=outcome.destination}
        end
    end
    self.requestCount+=1
    self.results[request.actionId]={identity=identity,result=copy(result)}
    self.session.receipts[request.actionId]={actorUserId=actor,actionId=request.actionId,hostRecovery=true}
    return result
end
return HostService
]=],
["roblox/mvp/server/LabubuFeedback.luau"] = [=[-- Owns only runtime previews/result/collection. It never invokes a world builder.
local Catalog = require(script.Parent.Parent.shared.FigureCatalog)
local Presentation = require(script.Parent.Parent.shared.FigurePresentation)
local LabubuFeedback = {}; LabubuFeedback.__index = LabubuFeedback
local function folder(parent, name)
	local value = Instance.new("Folder"); value.Name = name; value.Parent = parent; return value
end
local function caption(parent, name, cf, width, text, back)
	local plate = Presentation.Part(parent, name, Vector3.new(width, .23, .035), cf, "cream")
	local gui = Instance.new("SurfaceGui")
	gui.Name, gui.Face, gui.CanvasSize = "FigureLabel", back and Enum.NormalId.Back or Enum.NormalId.Front, Vector2.new(260, 70)
	gui.Parent = plate
	local label = Instance.new("TextLabel")
	label.Name, label.Size, label.BackgroundTransparency = "Caption", UDim2.fromScale(1, 1), 1
	label.Font, label.TextScaled, label.TextWrapped = Enum.Font.GothamBold, true, true
	label.TextColor3, label.Text, label.Parent = Presentation.Palette.ink, text, gui
	return label
end
function LabubuFeedback.new(root, mvp, anchors)
	local runtime = mvp:FindFirstChild("RuntimePresentation") or folder(mvp, "RuntimePresentation")
	assert(not runtime:FindFirstChild("LabubuFeedback"), "LabubuFeedback is already running")
	local owned = folder(runtime, "LabubuFeedback"); owned:SetAttribute("VerificationTicket", "PCW-21")
	local self = setmetatable({ root = owned, hidden = {}, previews = {}, collectionLabels = {} }, LabubuFeedback)
	self.machine = folder(owned, "Machine"); self.resultRoot = folder(owned, "LatestResult")
	self.collectionRoot = folder(owned, "BedroomCollection"); self.ownedFigures = folder(self.collectionRoot, "OwnedFigures")
	local machine = anchors.Q05UDistrictVending
	if machine and machine:IsA("BasePart") then
		self.machineFrame = machine.CFrame
		local stations = mvp:FindFirstChild("Stations")
		local cabinet = stations and stations:FindFirstChild("Q05Station")
		for index, entry in ipairs(Catalog.Figures) do
			-- The saved FigureSlot markers are rectangles. Hide only those exact
			-- placeholders at runtime, retaining restorable authored properties.
			local marker = cabinet and cabinet:FindFirstChild("FigureSlot" .. index, true)
			if marker and marker:IsA("BasePart") then self.hidden[marker] = marker.Transparency; marker.Transparency = 1 end
			local x = (index - 4) * .62
			local toy = Presentation.Build(entry.id, .4)
			toy.Name = "Preview" .. index; toy.Parent = self.machine
			toy:PivotTo(machine.CFrame * CFrame.new(x, 4.35, -1.46))
			self.previews[entry.id] = caption(self.machine, "Label" .. index, machine.CFrame * CFrame.new(x, 4.14, -1.67), .6, entry.label)
		end
		local cue = Presentation.Part(self.machine, "ResultCue", Vector3.new(.1, .1, .1), machine.CFrame * CFrame.new(0, 8, -.1), "forest")
		cue.Transparency = 1
		local board = Instance.new("BillboardGui")
		board.Name, board.Size, board.MaxDistance, board.AlwaysOnTop = "SharedWish", UDim2.fromOffset(300, 104), 32, false
		board.Adornee, board.Parent = cue, cue
		local text = Instance.new("TextLabel")
		text.Name, text.Size, text.BorderSizePixel, text.Font, text.TextSize = "WishAndResult", UDim2.fromScale(1, 1), 0, Enum.Font.GothamMedium, 14
		text.BackgroundColor3, text.TextColor3, text.TextWrapped, text.Parent = Presentation.Palette.cream, Presentation.Palette.ink, true, board
		self.machineText = text
	else warn("PCW-21 vending anchor unavailable; shared figure state remains available in the UI") end
	local home = root:FindFirstChild("Home")
	local bedroom = home and home:FindFirstChild("Bedroom")
	local bookcase = bedroom and bedroom:FindFirstChild("FilledBookcase")
	local shelves = {}
	if bookcase then
		for _, item in ipairs(bookcase:GetChildren()) do
			if item:IsA("BasePart") and (item.Name == "Shelf" or string.match(item.Name, "^Shelf_%d+$")) then table.insert(shelves, item) end
		end
	end
	table.sort(shelves, function(a, b) return a.Position.Y < b.Position.Y end)
	-- The fourth shelf carries craft jars behind its front edge. Our shallow
	-- exterior ledge projects .675 studs beyond that edge, below the fifth shelf.
	-- Q01 owns the very top; Q03/miniature owns the lower shelf. Neither is moved.
	local shelf = #shelves >= 6 and shelves[4] or nil
	if shelf then
		self.shelfFrame = shelf.CFrame * CFrame.new(0, shelf.Size.Y / 2 + .04, shelf.Size.Z / 2 + .35)
		Presentation.Part(self.collectionRoot, "CollectionLedge", Vector3.new(7.2, .1, .65), self.shelfFrame, "wood")
		self.collectionRoot:SetAttribute("OwnedRegion", "Fourth shelf front extension; Q01 top and Q03 lower shelf untouched")
		for index, entry in ipairs(Catalog.Figures) do
			self.collectionLabels[entry.id] = caption(self.collectionRoot, "CollectionLabel" .. index,
				self.shelfFrame * CFrame.new((index - 4) * 1, -.08, .35), .94, entry.label .. " ×0", true)
		end
	else warn("PCW-21 bedroom shelf unavailable; collection remains saved and visible in the UI") end
	self:Render(nil, false, {}, nil, false)
	return self
end
function LabubuFeedback:Render(wanted, fulfilled, collection, latest, storyComplete)
	self.root:SetAttribute("WantedFigureId", wanted); self.root:SetAttribute("WishFulfilled", fulfilled)
	self.root:SetAttribute("StoryComplete", storyComplete)
	if self.machineText then
		self.machineText.Text = (storyComplete and "Wish complete · more collecting is optional" or "Friends earn together · Phuong chooses")
			.. "\nWish · " .. Catalog.Label(wanted)
			.. "\n" .. (latest and "Latest · " .. Catalog.Label(latest.awardFigureId) .. " · saved to the bedroom collection" or "20 per box · selected wish by box five")
	end
	for _, entry in ipairs(Catalog.Figures) do
		local label = self.previews[entry.id]
		if label then label.Text = (wanted == entry.id and "✓ " or "") .. entry.label end
		local shelfLabel = self.collectionLabels[entry.id]
		if shelfLabel then shelfLabel.Text = entry.label .. " ×" .. tostring(collection[entry.id] or 0) end
	end
	local receiptId = latest and latest.receiptId
	-- Selection changes only captions; an awarded box rebuilds bounded models.
	if receiptId == self.lastReceipt then return end
	self.lastReceipt = receiptId
	self.resultRoot:ClearAllChildren(); self.ownedFigures:ClearAllChildren()
	if latest and self.machineFrame then
		local figure = Presentation.Build(latest.awardFigureId, .72)
		figure.Name = "AwardedFigure"; figure:SetAttribute("ReceiptId", receiptId); figure.Parent = self.resultRoot
		figure:PivotTo(self.machineFrame * CFrame.new(.7, 1.63, -1.37))
		local capsule = Presentation.Capsule(.53, true); capsule.Parent = self.resultRoot
		capsule:PivotTo(self.machineFrame * CFrame.new(-1.2, 1.63, -1.3))
		caption(self.resultRoot, "ResultLabel", self.machineFrame * CFrame.new(0, 1.38, -1.7), 3.4, "Latest · " .. Catalog.Label(latest.awardFigureId))
	end
	if self.shelfFrame then
		for index, entry in ipairs(Catalog.Figures) do
			if (collection[entry.id] or 0) > 0 then
				local figure = Presentation.Build(entry.id, .4)
				figure.Name = "Collected" .. index; figure:SetAttribute("Copies", collection[entry.id]); figure.Parent = self.ownedFigures
				figure:PivotTo(self.shelfFrame * CFrame.new((index - 4) * 1, .055, 0) * CFrame.Angles(0, math.pi, 0))
			end
		end
	end
end
function LabubuFeedback:Destroy()
	for part, transparency in pairs(self.hidden) do if part.Parent then part.Transparency = transparency end end
	self.root:Destroy()
end
return LabubuFeedback
]=],
["roblox/mvp/server/LocalPartyTransferAdapter.luau"] = [=[-- STUDIO-ONLY LOCAL PLAYTEST ADAPTER.
-- This deliberately does not simulate production teleport or reserve a server.
local LocalPartyTransferAdapter = {}
LocalPartyTransferAdapter.__index = LocalPartyTransferAdapter

function LocalPartyTransferAdapter.new(onPartyReady)
	return setmetatable({ onPartyReady = onPartyReady }, LocalPartyTransferAdapter)
end

function LocalPartyTransferAdapter:Transfer(players, roster)
	assert(type(self.onPartyReady) == "function", "local playtest callback is required")
	self.onPartyReady(players, roster)
	return true, "LocalPartyReady"
end

return LocalPartyTransferAdapter
]=],
["roblox/mvp/server/Main.server.luau"] = [=[local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local root = workspace:WaitForChild("CozyWorld_Draft01")
local mvp = root:WaitForChild("MVP")
local action = ReplicatedStorage:WaitForChild("PhuongMVP"):WaitForChild("Action")
local Anchors = require(script.Parent.Parent.shared.Anchors)
local Config = require(script.Parent.Parent.shared.Config)
local SessionService = require(script.Parent.SessionService)
local CakeService = require(script.Parent.CakeService)
-- Preserve the live audio integration when installing this source baseline.
local CozyAudio = require(script.Parent.CozyAudio)
local BedroomFeedback = require(script.Parent.BedroomFeedback)
local FoodFeedback = require(script.Parent.FoodFeedback)
local LabubuFeedback = require(script.Parent.LabubuFeedback)
local WorldFeedback = require(script.Parent.WorldFeedback)
local FinalePresentation = require(script.Parent.FinalePresentation)
local HostService = require(script.Parent.HostService)

local now = function() return workspace:GetServerTimeNow() end
local sessionId = "MVP-" .. tostring(math.floor(workspace:GetServerTimeNow()))
local session = SessionService.new({sessionId = sessionId})
local cake = CakeService.new(session, {clock=now})
local hostService
local finaleFeedback, seenFinaleRevision, broadcastFinaleRevision
local anchors, missingAnchors = Anchors.Resolve(mvp)
local activities, activityErrors = {}, {}
local currentRounds = {}
local openedActivities = {}
local playerConnections = {}
local roundSerial = 0
local function uid(p) return p and p.UserId end
local function anchor(name)
 local v = anchors[name]; return v and (v:IsA("BasePart") and v or v:FindFirstChildWhichIsA("BasePart", true))
end
local function character(p)
 local c = p and p.Character; local h = c and c:FindFirstChildOfClass("Humanoid"); local r = c and c:FindFirstChild("HumanoidRootPart")
 if not c or not h or h.Health <= 0 or not r then return nil end; return c, r
end
local function near(p, name, radius)
 local _, r = character(p); local a = anchor(name); return r and a and (r.Position-a.Position).Magnitude <= radius
end
local function place(p, name)
 local c, a = character(p), anchor(name); if not c or not a then return false end; c:PivotTo(a.CFrame+Vector3.new(0,3,0)); return true
end

-- Remote views contain presentation data only. Never share one actor's view
-- with another recipient, or replicate Instances/functions from server state.
local function uiCopy(value, seen, depth)
 local kind = type(value)
 if kind == "string" or kind == "number" or kind == "boolean" then return value end
 if kind ~= "table" or (depth or 0) >= 14 then return nil end
 seen = seen or {}; if seen[value] then return nil end; seen[value] = true
 local copy = {}
 for key, child in pairs(value) do
  if type(key) == "string" or type(key) == "number" then copy[key] = uiCopy(child, seen, (depth or 0) + 1) end
 end
 seen[value] = nil; return copy
end
local function view(a,p)
 if not a then return {state="UNAVAILABLE",errorText="ActivityUnavailable"} end
 local ok, result = pcall(a.GetView,a,uid(p))
 return ok and uiCopy(result) or {state="UNAVAILABLE",errorText="ActivityUnavailable"}
end
local function advanceCake()
 local changed=cake:Tick()
 if finaleFeedback and seenFinaleRevision~=cake.revision then
  seenFinaleRevision=cake.revision
  local ok,err=pcall(finaleFeedback.Render,finaleFeedback,cake:GetState(),cake.participants)
  if not ok then warn("PCW-23 finale presentation unavailable",err) end
 end
 return changed
end
local function snapshot(p)
 advanceCake()
 local s = session:GetSnapshot(); s.cake = cake:GetState(uid(p)); s.activityViews = {}
 if p then for id, activity in pairs(activities) do s.activityViews[id] = view(activity, p) end end
 if hostService and p then s.host = hostService:GetView(uid(p)) end
 return uiCopy(s)
end
local function send(p, request, ok, code, extra)
 request=type(request)=="table" and request or {}
 local r = {kind="Result", ok=ok, code=code, sessionId=sessionId, activityId=request and request.activityId, roundId=request and request.roundId, actionId=request and request.actionId, stepId=request and request.stepId, actorUserId=uid(p), snapshot=snapshot(p)}
 if extra then for k,v in pairs(extra) do r[k]=uiCopy(v) end end; action:FireClient(p,r); return r
end
local function broadcast()
 for _, p in ipairs(Players:GetPlayers()) do
  local id = openedActivities[p.UserId]
  local extra = id and p:GetAttribute("BirthdayLocation") == "World" and {view=view(activities[id],p)} or nil
  -- No actionId: clients refresh only this same already-open activity.
  send(p,{kind="RequestSnapshot"},true,"Snapshot",extra)
 end
 broadcastFinaleRevision=cake.revision
end
local function construct(name,module,context)
 local ctor=module.new or module.New; if not ctor then activityErrors[name]="missing constructor"; return end
 local ok,value=pcall(ctor,context); if ok then activities[name]=value else activityErrors[name]=tostring(value) end
end

-- Prompts are owned by this runtime so a saved place cannot retain stale handlers.
local promptLabels={Q01="Make the bed",Q02="Visit Jasper",Q03="Craft a keepsake",Q04="Read together",Q05="Make a Labubu wish",Q06="Build a shared meal",Cake="Birthday cake"}
local promptObjects={Q01="Everything Tucked In",Q02="Jasper's Favorite Things",Q03="A Tiny World of Her Own",Q04="One More Chapter",Q05="A Labubu Wish",Q06="Something Delicious",Cake="Birthday cake"}
local function installPrompt(id, instance)
 if not instance then return end
 local host=instance:IsA("BasePart") and instance or instance:FindFirstChildWhichIsA("BasePart",true); if not host then return end
 local prompt=host:FindFirstChild("MVPProximityPrompt") or Instance.new("ProximityPrompt")
 prompt.Name="MVPProximityPrompt"; prompt.ActionText=promptLabels[id] or id; prompt.ObjectText=promptObjects[id] or id; prompt.KeyboardKeyCode=Enum.KeyCode.E
 prompt.HoldDuration=0; prompt.MaxActivationDistance=12; prompt.RequiresLineOfSight=false; prompt:SetAttribute("ActivityId",id); prompt.Parent=host
end
local world={isPresent=function(id) return session:IsPresent(id) end,presentUserIds=session.presence,anchors=anchors}
-- Nearby FOB and serving radii overlap. Resolve to the closest actual counter,
-- so each recipient sees only their current venue's valid recipe cards.
local foodCounters = { {id="FOB",name="Q06FOBCounter"}, {id="Aladdins",name="Q06AladdinsCounter"}, {id="Serving",name="Q06Serving"} }
world.foodVenue = function(actor)
 local p = Players:GetPlayerByUserId(actor)
 if not p or p:GetAttribute("BirthdayLocation")~="World" then return nil end
 local _, r = character(p); if not r then return nil end
 local closest, distance = nil, 24
 for _, counter in ipairs(foodCounters) do
  local target=anchor(counter.name)
  local d=target and (r.Position-target.Position).Magnitude
  if d and d<=distance then closest,distance=counter.id,d end
 end
 return closest
end
local bedroomFeedback = BedroomFeedback.new(root, mvp)
if bedroomFeedback.shelfAnchor then anchors.Q01Shelf = bedroomFeedback.shelfAnchor end
local foodFeedback = FoodFeedback.new(mvp, anchors)
local labubuFeedback = LabubuFeedback.new(root, mvp, anchors)
local feedbackOk, worldFeedback = pcall(WorldFeedback.new, root, mvp, anchors)
if not feedbackOk then warn("PCW-22 world presentation unavailable", worldFeedback); worldFeedback=nil end
local finaleOk, finaleResult=pcall(FinalePresentation.new,root,mvp)
if finaleOk then finaleFeedback=finaleResult else warn("PCW-23 finale scene unavailable",finaleResult) end
cake:SetRuntime({
 isWorld=function(actor)
  local p=Players:GetPlayerByUserId(actor)
  return p~=nil and p:GetAttribute("BirthdayLocation")=="World"
 end,
 isAtPatio=function(actor) return near(Players:GetPlayerByUserId(actor),"FinalePatio",28)==true end,
 occupant=function() return finaleFeedback and finaleFeedback:GetOccupant() or nil end,
 scene=function() return finaleFeedback and finaleFeedback:GetScene() or nil end,
})
-- Every hook exists in the real context. Activity modules protect accepted state
-- from cosmetic failures; WorldFeedback never yields or owns rewards.
local function worldEffect(method, ...)
 if worldFeedback then return worldFeedback[method](worldFeedback, ...) end
end
world.resetJasper=function(roundId) worldEffect("ResetJasper",roundId) end
world.moveJasperToYard=function() worldEffect("MoveJasperToYard") end
world.showRabbitPickup=function(index) worldEffect("ShowRabbitPickup",index) end
world.returnRabbit=function() worldEffect("ReturnRabbit") end
world.presentFetchTarget=function(index) worldEffect("PresentFetchTarget",index) end
world.fetchJasper=function(index) worldEffect("FetchJasper",index) end
world.giveJasperTreat=function() worldEffect("GiveJasperTreat") end
world.petJasper=function() worldEffect("PetJasper") end
world.renderCraft=function(roundId,committed,reservations,presentation) worldEffect("RenderCraft",roundId,committed,reservations,presentation) end
world.renderReading=function(summary) worldEffect("RenderReading",summary) end
world.jasperVenue=function(actor)
 local p=Players:GetPlayerByUserId(actor)
 if not p or p:GetAttribute("BirthdayLocation")~="World" then return nil end
 if near(p,"JasperBedroomStart",24) then return "Bedroom" end
 if near(p,"JasperFetchYard",24) then return "Yard" end
 return nil
end
construct("Q01",require(script.Parent.activities.Q01),{session=session,clock=now,world=world,feedback=bedroomFeedback})
construct("Q02",require(script.Parent.activities.Q02),{session=session,clock=now,world=world})
construct("Q03",require(script.Parent.activities.Q03),{session=session,clock=now,context=world})
construct("Q04",require(script.Parent.activities.Q04),{session=session,clock=now,context=world})
construct("Q05",require(script.Parent.activities.Q05),{session=session,clock=now,context=world,presentUserIds=session.presence,feedback=labubuFeedback})
construct("Q06",require(script.Parent.activities.Q06),{session=session,clock=now,actor=world.isPresent,context=world,feedback=foodFeedback})
local station={Q01="Q01Bed",Q02="JasperBedroomStart",Q03="Q03FairCraft",Q04="Q04QuadReading",Q05="Q05UDistrictVending",Q06="Q06FOBCounter"}
local function nearActivity(p,r)
 if r.activityId=="Q01" then
  if r.stepId=="shelf" then return near(p,"Q01Shelf",18) end
  if not r.stepId then return near(p,"Q01Bed",24) or near(p,"Q01Shelf",18) end
  return near(p,"Q01Bed",24)
 end
 if r.activityId=="Q02" then if r.stepId=="greet" then return near(p,"JasperBedroomStart",24) end; if r.stepId then return near(p,"JasperFetchYard",24) end; return near(p,"JasperBedroomStart",24) or near(p,"JasperFetchYard",24) end
 if r.activityId=="Q04" then return near(p,"Q04QuadReading",24) or near(p,"Q04BedroomKindle",24) end
 if r.activityId=="Q03" then return near(p,"Q03FairCraft",24) or near(p,"Q03BedroomDisplay",24) end
 if r.activityId=="Q06" then
  local slot=r.payload and r.payload.slotId
  if slot=="sauce" then return near(p,"Q06AladdinsCounter",24) end
  if slot=="settingA" or slot=="settingB" then return near(p,"Q06Serving",24) end
  if not slot then return near(p,"Q06FOBCounter",24) or near(p,"Q06AladdinsCounter",24) or near(p,"Q06Serving",24) end
 end
 return near(p,station[r.activityId],24)
end
local function canonical(p,r)
 if not session:IsPresent(uid(p)) or p:GetAttribute("BirthdayLocation") ~= "World" then return nil,"NotPresent" end
 if type(r.sessionId)~="string" or r.sessionId~=sessionId then return nil,"BadSessionId" end
 if type(r.activityId)~="string" or not activities[r.activityId] then return nil,"ActivityUnavailable" end
 if type(r.actionId)~="string" or r.actionId=="" then return nil,"BadActionId" end; r.actorUserId=uid(p); return r
end
local function release(p, activityId, roundId)
 local a=activityId and activities[activityId]; if a and a.ReleaseActor then pcall(a.ReleaseActor,a,uid(p),roundId) end
end
local function openRound(p,r)
 if not nearActivity(p,r) then return false,"TooFar" end
 local a=activities[r.activityId]; if currentRounds[r.activityId] and not r.replay then r.roundId=currentRounds[r.activityId]; return true,"RoundExisting",{view=view(a,p)} end
 roundSerial+=1; r.roundId="round:"..r.activityId..":"..roundSerial
 if r.activityId=="Q06" then r.stepId="base" end
 local ok,result=pcall(a.CreateRound,a,r); if not ok then return false,"RoundRejected",{errorText=tostring(result)} end
 currentRounds[r.activityId]=r.roundId; return true,"RoundCreated",{round=result,view=view(a,p)}
end
local function apply(p,r)
 local req,err=canonical(p,r); if not req then return false,err end
 if type(r.roundId)~="string" or type(r.stepId)~="string" or type(r.payload)~="table" then return false,"BadAction" end
 if not nearActivity(p,r) then
  if r.activityId=="Q06" then
   local message="Walk to the next food counter, then open its prompt. Use Track next counter; your shared dish stays saved."
   return false,"NEXT_COUNTER",{view=view(activities.Q06,p),errorText=message,result={ok=false,message=message}}
  end
  return false,"TooFar"
 end
 local ok,result=pcall(activities[r.activityId].Apply,activities[r.activityId],req)
 if not ok then return false,"ActionRejected",{errorText=tostring(result),view=view(activities[r.activityId],p),failedResult=result} end
 if type(result)~="table" then return false,"ActionRejected",{errorText="Invalid activity result"} end
 if result.o]==]
return #_G.__PCW25ContractText