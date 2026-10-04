local HttpService=game:GetService("HttpService")
assert(not game:GetService("RunService"):IsRunning(),"Edit mode required")
local entries={
{target=[=[ServerScriptService/PhuongMVP/server/activities/Q06]=],kind=[=[ModuleScript]=],sha=[=[8a864ac2746d842d832de4b94f527e8450c45e58a2444099c5feeff941c33bfe]=],source=[=[-- Q06 server activity: venue-inspired bowl/plate assembly near FOB and Aladdins.
-- Owns activity validation and visible round state; SessionService owns petals/fund.
local Q06 = {}
Q06.__index = Q06

local ACTIVITY_ID = "Q06"
local REQUIRED_STEPS = {
	base = "rice",
	toppings = "greens",
	protein = "tofu",
	sauce = "sauce",
	settingA = "plate",
	settingB = "cup",
}
local VALID_ITEMS = {
	base = { rice = true },
	toppings = { greens = true, cucumber = true, carrot = true },
	protein = { tofu = true, chicken = true, mushroom = true },
	sauce = { sauce = true, sesame = true },
	settingA = { plate = true, napkin = true },
	settingB = { cup = true, napkin = true },
}
local ROLE_FOR_SLOT = {
	base = "FOB",
	toppings = "FOB",
	protein = "FOB",
	sauce = "Aladdins",
	settingA = "Serving",
	settingB = "Serving",
}

local function clone(source)
	local result = {}
	for key, value in pairs(source) do
		if type(value) == "table" then result[key] = clone(value) else result[key] = value end
	end
	return result
end

local function requireRequest(request)
	assert(request and request.sessionId and type(request.sessionId) == "string", "Q06 sessionId is required")
	assert(request.activityId == ACTIVITY_ID and type(request.activityId) == "string", "Q06 activityId is required")
	assert(type(request.roundId) == "string" and type(request.actionId) == "string" and type(request.stepId) == "string", "Q06 round/action/step IDs are required")
	assert(type(request.actorUserId) == "number", "Q06 actorUserId must be numeric")
end

function Q06.new(options)
	assert(options and options.session and options.actor and options.clock and options.context, "Q06 dependencies are required")
	return setmetatable({
		session = options.session,
		actor = options.actor,
		clock = options.clock,
		context = options.context,
		rounds = {},
	}, Q06)
end

function Q06:CreateRound(request)
	requireRequest(request)
	assert(not self.rounds[request.roundId], "Q06 round already exists")
	local prior = self.session.rounds[request.roundId]
	assert(not prior, "Q06 round already exists")
	if request.replay then
		self.session:StartNextRound(ACTIVITY_ID, request.roundId, request.actorUserId)
	else
		self.session:CreateRound(ACTIVITY_ID, request.roundId, request.actorUserId, false)
	end
	self.rounds[request.roundId] = {
		roundId = request.roundId,
		state = "IN_PROGRESS",
		isReplay = request.replay == true,
		accepted = {},
		reservations = {},
		contributors = {},
	}
	return { activityId = ACTIVITY_ID, roundId = request.roundId, actorUserId = request.actorUserId, replay = request.replay == true }
end

function Q06:_round(roundId)
	local round = self.rounds[roundId]
	assert(round, "unknown Q06 round")
	assert(round.state == "IN_PROGRESS", "Q06 round is not active")
	return round
end

function Q06:_expireReservations(round)
	local now = self.clock()
	for slotId, reservation in pairs(round.reservations) do
		if reservation.expiresAt <= now then round.reservations[slotId] = nil end
	end
end

function Q06:Apply(request)
	requireRequest(request)
	local round = self:_round(request.roundId)
	self:_expireReservations(round)
	local payload = request.payload or {}
	assert(payload.slotId and payload.itemId, "Q06 slot and item are required")
	local slotId = payload.slotId
	local itemId = payload.itemId
	assert(REQUIRED_STEPS[slotId], "unknown Q06 slot")
	assert(VALID_ITEMS[slotId][itemId], "invalid item for Q06 slot")
	if round.accepted[slotId] then return { ok = true, code = "ALREADY_ACCEPTED", receipt = clone(round.accepted[slotId]), view = self:GetView(request.actorUserId) } end
	local reservation = round.reservations[slotId]
	if reservation and reservation.actorUserId ~= request.actorUserId then
		return { ok = false, code = "SLOT_BUSY", receipt = nil, view = self:GetView(request.actorUserId) }
	end
	local accepted = self.session:ApplyStep({
		sessionId = self.session.sessionId,
		activityId = ACTIVITY_ID,
		roundId = request.roundId,
		stepId = slotId,
		actionId = request.actionId,
		actorUserId = request.actorUserId,
	})
	local result = {
		roundId = request.roundId,
		stepId = slotId,
		actionId = request.actionId,
		actorUserId = request.actorUserId,
		itemId = itemId,
		roleId = ROLE_FOR_SLOT[slotId],
		accepted = true,
		acceptedStep = accepted,
	}
	round.accepted[slotId] = result
	round.reservations[slotId] = nil
	round.contributors[request.actorUserId] = true
	if self:_isComplete(round) then
		local completion = self.session:CompleteRound({ sessionId = self.session.sessionId, activityId = ACTIVITY_ID, roundId = request.roundId, actionId = "complete:" .. request.roundId, actorUserId = request.actorUserId })
		round.state = "COMPLETED"
		result.completion = completion
	end
	return { ok = true, code = result.completion and "ROUND_COMPLETED" or "STEP_ACCEPTED", receipt = clone(result), view = self:GetView(request.actorUserId) }
end

function Q06:Reserve(request)
	requireRequest(request)
	local round = self:_round(request.roundId)
	self:_expireReservations(round)
	local slotId = request.payload and request.payload.slotId
	assert(REQUIRED_STEPS[slotId], "unknown Q06 slot")
	assert(not round.accepted[slotId], "Q06 slot already accepted")
	local current = round.reservations[slotId]
	if current and current.actorUserId ~= request.actorUserId then return { accepted = false, busyReason = "slot-in-use" } end
	local reservation = { slotId = slotId, actorUserId = request.actorUserId, expiresAt = self.clock() + 15 }
	round.reservations[slotId] = reservation
	return clone(reservation)
end

function Q06:Cancel(request)
	requireRequest(request)
	local round = self:_round(request.roundId)
	local slotId = request.payload and request.payload.slotId
	local reservation = round.reservations[slotId]
	if reservation and reservation.actorUserId == request.actorUserId then round.reservations[slotId] = nil end
	return { roundId = request.roundId, slotId = slotId, cancelled = true }
end

function Q06:_isComplete(round)
	for slotId in pairs(REQUIRED_STEPS) do
		if not round.accepted[slotId] then return false end
	end
	return true
end

function Q06:GetView(actorUserId)
	local round
	for _, candidate in pairs(self.rounds) do round = candidate break end
	if not round then
		return { activityId = ACTIVITY_ID, roundId = nil, state = "NOT_STARTED", title = "Something Delicious", instructions = "Choose an ingredient, choose a slot, and confirm.", progress = { done = 0, total = 6 }, availableActions = {}, acceptedStepIds = {}, contributors = {}, busyReason = nil, errorText = nil, canReplay = false }
	end
	self:_expireReservations(round)
	local accepted, available = {}, {}
	for slotId in pairs(REQUIRED_STEPS) do
		if round.accepted[slotId] then table.insert(accepted, slotId) else table.insert(available, { id = "choose-" .. slotId, label = "Fill " .. slotId, stepId = slotId, payload = { slotId = slotId }, enabled = round.reservations[slotId] == nil, reason = round.reservations[slotId] and "Slot is being used" or nil }) end
	end
	return {
		activityId = ACTIVITY_ID,
		roundId = round.roundId,
		state = round.state,
		title = "Something Delicious",
		instructions = "Choose an ingredient, choose a slot, and confirm.",
		progress = { done = #accepted, total = 6 },
		availableActions = available,
		acceptedStepIds = accepted,
		contributors = clone(round.contributors),
		busyReason = nil,
		errorText = nil,
		canReplay = round.state == "COMPLETED",
		actorUserId = actorUserId,
		foodDisplay = clone(round.accepted),
	}
end

return Q06
]=]},
{target=[=[ServerScriptService/PhuongMVP/server/Main]=],kind=[=[Script]=],sha=[=[7810a2f8adc3b4ffdcaa5363d897fe6f5b0787dc12b372523fbb79d2e904ec3a]=],source=[=[local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local root = workspace:WaitForChild("CozyWorld_Draft01")
local mvp = root:WaitForChild("MVP")
local action = ReplicatedStorage:WaitForChild("PhuongMVP"):WaitForChild("Action")
local Anchors = require(script.Parent.Parent.shared.Anchors)
local Config = require(script.Parent.Parent.shared.Config)
local SessionService = require(script.Parent.SessionService)
local QueueService = require(script.Parent.QueueService)
local CakeService = require(script.Parent.CakeService)
local TeleportAdapter = require(script.Parent.TeleportAdapter)
local LocalPartyTransferAdapter = require(script.Parent.LocalPartyTransferAdapter)

local now = os.clock
local sessionId = "MVP-" .. tostring(math.floor(workspace:GetServerTimeNow()))
local session = SessionService.new({sessionId = sessionId})
local queue = QueueService.new({clock = now, capacity = 10})
local cake = CakeService.new(session)
local anchors, missingAnchors = Anchors.Resolve(mvp)
local activities, activityErrors = {}, {}
local arrivalSlots, arrivalByUser, currentRounds = {}, {}, {}
local arrivalCount = 0
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
local function snapshot()
 local s = session:GetSnapshot(); s.queue = queue:Snapshot(); s.cake = cake:GetState()
 s.arrival = {capacity=10, occupied=0, ready={}}
 for player, entry in pairs(arrivalByUser) do s.arrival.occupied += 1; s.arrival.ready[player] = entry.ready == true end
 return s
end
local function send(p, request, ok, code, extra)
 local r = {kind="Result", ok=ok, code=code, sessionId=sessionId, activityId=request and request.activityId, roundId=request and request.roundId, actionId=request and request.actionId, stepId=request and request.stepId, actorUserId=uid(p), snapshot=snapshot()}
 if extra then for k,v in pairs(extra) do r[k]=v end end; action:FireClient(p,r); return r
end
local function broadcast()
 for _, p in ipairs(Players:GetPlayers()) do send(p,{kind="RequestSnapshot"},true,"Snapshot") end
end
local function view(a,p)
 if not a then return {state="UNAVAILABLE",errorText="ActivityUnavailable"} end
 local ok, result = pcall(a.GetView,a,uid(p)); return ok and result or {state="UNAVAILABLE",errorText=tostring(result)}
end
local function construct(name,module,context)
 local ctor=module.new or module.New; if not ctor then activityErrors[name]="missing constructor"; return end
 local ok,value=pcall(ctor,context); if ok then activities[name]=value else activityErrors[name]=tostring(value) end
end
local world={isPresent=function(id) return session:IsPresent(id) end,presentUserIds=session.presence,anchors=anchors}
construct("Q01",require(script.Parent.activities.Q01),{session=session,clock=now,world=world})
construct("Q02",require(script.Parent.activities.Q02),{session=session,clock=now,world=world})
construct("Q03",require(script.Parent.activities.Q03),{session=session,clock=now,context=world})
construct("Q04",require(script.Parent.activities.Q04),{session=session,clock=now,context=world})
construct("Q05",require(script.Parent.activities.Q05),{session=session,clock=now,context=world,presentUserIds=session.presence})
construct("Q06",require(script.Parent.activities.Q06),{session=session,clock=now,context=world})
local transfer
if RunService:IsStudio() then
 transfer=LocalPartyTransferAdapter.new(function(players) for _,p in ipairs(players) do place(p,"GameplayBedroomArrival") end; broadcast() end)
else
 local placeId=game:GetAttribute("GameplayPlaceId") or Config.GameplayPlaceId
 if placeId and placeId ~= 0 then transfer=TeleportAdapter.new({GameplayPlaceId=placeId},{}) else warn("GameplayPlaceId is unconfigured; production transfer is disabled") end
end
local function transferQueue()
 local _,_,roster=queue:Freeze(now()); if not roster then return end
 local players={}; for _,id in ipairs(roster.members) do local p=Players:GetPlayerByUserId(id); if not p then queue:FailTransfer(); return end; table.insert(players,p) end
 if not queue:BeginTransfer() then return end
 local ok=transfer and transfer:Transfer(players,roster); if ok then queue:CompleteTransfer() else queue:FailTransfer() end
end
local station={Q01="Q01Bed",Q02="JasperBedroomStart",Q03="Q03FairCraft",Q04="Q04QuadReading",Q05="Q05UDistrictVending",Q06="Q06FOBCounter"}
local function canonical(p,r)
 if type(r.sessionId)~="string" or r.sessionId~=sessionId then return nil,"BadSessionId" end
 if type(r.activityId)~="string" or not activities[r.activityId] then return nil,"ActivityUnavailable" end
 if type(r.actionId)~="string" or r.actionId=="" then return nil,"BadActionId" end; r.actorUserId=uid(p); return r
end
local function openRound(p,r)
 if not near(p,station[r.activityId],24) then return false,"TooFar" end
 local a=activities[r.activityId]; if currentRounds[r.activityId] and not r.replay then r.roundId=currentRounds[r.activityId]; return true,"RoundExisting",{view=view(a,p)} end
 roundSerial+=1; r.roundId="round:"..r.activityId..":"..roundSerial
 local ok,result=pcall(a.CreateRound,a,r); if not ok then return false,"RoundRejected",{errorText=tostring(result)} end
 currentRounds[r.activityId]=r.roundId; return true,"RoundCreated",{round=result,view=view(a,p)}
end
local function apply(p,r)
 local req,err=canonical(p,r); if not req then return false,err end
 if type(r.roundId)~="string" or type(r.stepId)~="string" then return false,"BadAction" end
 if not near(p,station[r.activityId],24) then return false,"TooFar" end
 local ok,result=pcall(activities[r.activityId].Apply,activities[r.activityId],req)
 if not ok then return false,"ActionRejected",{errorText=tostring(result),view=view(activities[r.activityId],p),failedResult=result} end
 if type(result)~="table" then return false,"ActionRejected",{errorText="Invalid activity result"} end
 return result.ok~=false,result.code or "Accepted",{receipt=result.receipt,view=result.view or view(activities[r.activityId],p),result=result}
end
action.OnServerEvent:Connect(function(p,r)
 if type(r)~="table" or type(r.kind)~="string" then return send(p,r,false,"BadPayload") end
 if r.actorUserId~=nil or r.player~=nil then return send(p,r,false,"ClientAuthorityRejected") end
 if r.kind=="ActivityAction" then local ok,c,e=apply(p,r); return send(p,r,ok,c,e) end
 if r.kind=="RequestView" then local req,err=canonical(p,r); if not req then return send(p,r,false,err) end; local ok,c,e=openRound(p,req); return send(p,req,ok,c,e) end
 if r.kind=="RequestJournal" then return send(p,r,true,"Journal",{journal=snapshot()}) end
 if r.kind=="RequestSnapshot" then return send(p,r,true,"Snapshot") end
 if r.kind=="QueueJoin" then if not near(p,"BirthdayLobbyQueue",24) then return send(p,r,false,"TooFar") end; local ok,c=queue:Join(uid(p),now()); send(p,r,ok,c); broadcast(); return end
 if r.kind=="QueueLeave" then local ok,c=queue:Leave(uid(p)); send(p,r,ok,c); broadcast(); return end
 if r.kind=="Cake" then if not near(p,"FinalePatio",28) then return send(p,r,false,"TooFar") end; local ok,result=pcall(cake[r.action],cake,uid(p)); return send(p,r,ok,ok and (r.action.."Accepted") or "CakeRejected",{cake=ok and result or cake:GetState(),errorText=ok and nil or tostring(result)}) end
 send(p,r,false,"UnsupportedAction")
end)
local function assign(p)
 if arrivalByUser[p.UserId] then return end; if arrivalCount>=10 then p:SetAttribute("MVPArrivalStatus","Full"); return end
 local folder=anchors.BedroomArrivalSlots; local target
 if folder then for _,v in ipairs(folder:GetChildren()) do if v:IsA("BasePart") and not arrivalSlots[v] then target=v; break end end end
 if not target then p:SetAttribute("MVPArrivalStatus","NotReady"); return end
 arrivalSlots[target]=p; arrivalByUser[p.UserId]={part=target,ready=false}; arrivalCount += 1; p:SetAttribute("MVPArrivalSlot",target.Name); p:SetAttribute("MVPArrivalStatus","ReadyPendingCharacter")
 local function ready() local e=arrivalByUser[p.UserId]; if e and character(p) then e.ready=true; p:SetAttribute("MVPArrivalStatus","Ready") end end
 p.CharacterAdded:Connect(function() task.defer(ready) end); ready()
end
Players.PlayerAdded:Connect(function(p) session:SetPresence(p.UserId,true); p:SetAttribute("MVPSessionId",sessionId); assign(p); send(p,{kind="RequestSnapshot"},true,"Snapshot") end)
Players.PlayerRemoving:Connect(function(p) session:SetPresence(p.UserId,false); queue:Leave(p.UserId); local e=arrivalByUser[p.UserId]; if e then arrivalSlots[e.part]=nil; arrivalByUser[p.UserId]=nil; arrivalCount -= 1 end; for _,a in pairs(activities) do if a.ReleaseActor then pcall(a.ReleaseActor,a,p.UserId) end end; broadcast() end)
RunService.Heartbeat:Connect(function() if queue:Tick(now()) then transferQueue() end end)
print("Phuong MVP server integration active",sessionId,"missing anchors:",table.concat(missingAnchors,","))
for name,defect in pairs(activityErrors) do warn("Activity "..name.." unavailable: "..defect) end
]=]},
{target=[=[StarterPlayer/StarterPlayerScripts/PhuongMVPClient]=],kind=[=[LocalScript]=],sha=[=[2d1eb4f2a99a10a63a090c689ae958ad91c9085da51b6c0a35ff66b46f6a922c]=],source=[=[local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
local action = ReplicatedStorage:WaitForChild("PhuongMVP"):WaitForChild("Action")

local P = {forest=Color3.fromRGB(54,87,68), sage=Color3.fromRGB(168,185,149), cream=Color3.fromRGB(245,240,228), wood=Color3.fromRGB(149,103,75), blossom=Color3.fromRGB(232,183,198), brick=Color3.fromRGB(182,108,104), golden=Color3.fromRGB(232,199,121), ink=Color3.fromRGB(38,56,46)}
local gui=Instance.new("ScreenGui"); gui.Name="PhuongMVPHud"; gui.ResetOnSpawn=false; gui.Parent=player:WaitForChild("PlayerGui")
local function corner(x,r) local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(0,r or 12); c.Parent=x end
local function text(parent,name,value,size,color) local x=Instance.new("TextLabel"); x.Name=name; x.Text=value or ""; x.TextColor3=color or P.ink; x.BackgroundTransparency=1; x.Font=Enum.Font.GothamSemibold; x.TextSize=size or 16; x.TextWrapped=true; x.TextXAlignment=Enum.TextXAlignment.Left; x.Parent=parent; return x end
local function button(parent,name,value,callback) local x=Instance.new("TextButton"); x.Name=name; x.Text=value or ""; x.AutoButtonColor=true; x.Font=Enum.Font.GothamBold; x.TextSize=16; x.TextColor3=P.cream; x.BackgroundColor3=P.forest; x.Size=UDim2.new(1,0,0,52); x.Parent=parent; corner(x,10); x.Activated:Connect(callback); return x end

local hud=Instance.new("Frame"); hud.Name="ExploreHud"; hud.Position=UDim2.fromOffset(16,16); hud.Size=UDim2.fromOffset(310,132); hud.BackgroundColor3=P.cream; hud.BackgroundTransparency=.08; hud.Parent=gui; corner(hud,14)
local status=text(hud,"SessionStatus","Birthday session loading",16); status.Position=UDim2.fromOffset(14,10); status.Size=UDim2.new(1,-28,0,25)
local flower=text(hud,"FlowerProgress","✿ 0 / 6 petals",18,P.forest); flower.Position=UDim2.fromOffset(14,40); flower.Size=UDim2.new(1,-28,0,28)
local fund=text(hud,"FundBalance","Shared fund  •  0",14); fund.Position=UDim2.fromOffset(14,72); fund.Size=UDim2.new(1,-28,0,24)
local queueState=text(hud,"QueueState","Queue: not joined",13); queueState.Position=UDim2.fromOffset(14,98); queueState.Size=UDim2.new(1,-28,0,22)
local journal=button(gui,"JournalButton","Journal",function() end); journal.AnchorPoint=Vector2.new(1,0); journal.Position=UDim2.new(1,-20,0,20); journal.Size=UDim2.fromOffset(132,52)

local panel=Instance.new("Frame"); panel.Name="ActivityPanel"; panel.AnchorPoint=Vector2.new(.5,.5); panel.Position=UDim2.fromScale(.5,.5); panel.Size=UDim2.new(.86,0,.78,0); panel.BackgroundColor3=P.cream; panel.Visible=false; panel.Parent=gui; corner(panel,16)
local title=text(panel,"Title","",24,P.forest); title.Position=UDim2.fromOffset(22,18); title.Size=UDim2.new(1,-260,0,36)
local close=button(panel,"Close","Close",function() panel.Visible=false end); close.AnchorPoint=Vector2.new(1,0); close.Position=UDim2.new(1,-18,0,16); close.Size=UDim2.fromOffset(104,48); close.BackgroundColor3=P.brick
local back=button(panel,"Back","Back",function() panel.Visible=false end); back.AnchorPoint=Vector2.new(1,0); back.Position=UDim2.new(1,-132,0,16); back.Size=UDim2.fromOffset(104,48)
local instructions=text(panel,"Instructions","",16); instructions.Position=UDim2.fromOffset(22,62); instructions.Size=UDim2.new(1,-44,0,48)
local progress=text(panel,"Progress","",15,P.forest); progress.Position=UDim2.fromOffset(22,112); progress.Size=UDim2.new(1,-44,0,28)
local scroll=Instance.new("ScrollingFrame"); scroll.Name="ActionList"; scroll.Position=UDim2.fromOffset(22,148); scroll.Size=UDim2.new(1,-44,1,-170); scroll.BackgroundColor3=P.sage; scroll.BackgroundTransparency=.35; scroll.BorderSizePixel=0; scroll.ScrollBarThickness=10; scroll.AutomaticCanvasSize=Enum.AutomaticSize.Y; scroll.Parent=panel; corner(scroll,10)
local list=Instance.new("UIListLayout"); list.Padding=UDim.new(0,10); list.Parent=scroll
local pad=Instance.new("UIPadding"); pad.PaddingTop=UDim.new(0,12); pad.PaddingBottom=UDim.new(0,12); pad.PaddingLeft=UDim.new(0,12); pad.PaddingRight=UDim.new(0,12); pad.Parent=scroll

local currentView; local sequence=0; local sessionId=nil
local function freshId() sequence+=1; return string.format("client-%d-%d-%d",player.UserId,math.floor(os.clock()*1000),sequence) end
local function sendActivity(activityId,roundId,stepId,payload) if not sessionId then status.Text="Waiting for birthday session"; return end; action:FireServer({kind="ActivityAction",sessionId=sessionId,activityId=activityId,roundId=roundId or "",stepId=stepId or "",actionId=freshId(),payload=payload or {}}) end
local function clear() for _,x in ipairs(scroll:GetChildren()) do if x:IsA("TextButton") or x:IsA("TextLabel") then x:Destroy() end end end
local function render(view)
	if type(view)~="table" or not view.activityId then return end
	currentView=view; panel.Visible=true; title.Text=view.title or view.activityId; instructions.Text=view.instructions or "Choose an available action."
	local p=view.progress or {}; progress.Text=string.format("Progress  •  %s / %s   [%s]",tostring(p.done or 0),tostring(p.total or 0),tostring(view.state or "")); clear()
	for index,d in ipairs(view.availableActions or {}) do local b=button(scroll,"Action_"..tostring(d.id),d.label or d.id,function() if d.enabled~=false then sendActivity(view.activityId,view.roundId,d.stepId,d.payload) end end); b.LayoutOrder=index; if d.enabled==false then b.Active=false; b.AutoButtonColor=false; b.BackgroundColor3=P.wood; b.Text=(d.label or d.id).." — "..(d.reason or "Unavailable") end end
	if view.errorText then local e=text(scroll,"Error",view.errorText,14,P.brick); e.Size=UDim2.new(1,0,0,40) end
end
local function snapshot(s)
	if type(s)~="table" then return end
	if type(s.sessionId)=="string" and s.sessionId~="" then sessionId=s.sessionId end
	local petals=s.petals; local count=type(petals)=="number" and petals or 0; if type(petals)=="table" then for _,v in pairs(petals) do if v then count+=1 end end end
	flower.Text=string.format("✿ %d / 6 petals%s",count,count==6 and "  •  Cake ready" or ""); fund.Text=string.format("Shared fund  •  %s",tostring(s.fundBalance or s.fund or 0))
	local q=s.queue or {}; local members=q.count or (q.members and #q.members) or 0; queueState.Text=string.format("Queue: %s  •  %d",q.joined and "joined" or "not joined",members)
end
local function requestView(id) if not sessionId then status.Text="Waiting for birthday session"; return end; action:FireServer({kind="RequestView",sessionId=sessionId,activityId=id,actionId=freshId()}) end
journal.Activated:Connect(function() if sessionId then action:FireServer({kind="RequestJournal",sessionId=sessionId,actionId=freshId()}) else status.Text="Waiting for birthday session" end end)
action.OnClientEvent:Connect(function(payload)
	if type(payload)~="table" then return end
	if type(payload.sessionId)=="string" and payload.sessionId~="" then sessionId=payload.sessionId end
	if payload.view then render(payload.view) end; if payload.snapshot then snapshot(payload.snapshot) end; if payload.queue then snapshot({queue=payload.queue}) end
	if payload.journal then render(payload.journal) end; if payload.cake then render(payload.cake) end
	if payload.kind=="Result" then status.Text=payload.ok and "A cozy action was accepted" or (payload.errorText or payload.code or "Action unavailable") end
end)
local function bind(p)
	if not p:IsA("ProximityPrompt") or p:GetAttribute("MVPBound") then return end
	local id=p:GetAttribute("ActivityId") or p.Parent:GetAttribute("ActivityId"); if not id then return end
	p:SetAttribute("MVPBound",true); p.Triggered:Connect(function() requestView(id) end)
end
for _,x in ipairs(workspace:GetDescendants()) do bind(x) end; workspace.DescendantAdded:Connect(bind)
UserInputService.InputBegan:Connect(function(input,processed)
	if processed or not panel.Visible or not currentView then return end
	local step=input.KeyCode==Enum.KeyCode.Q and "rotate-left" or input.KeyCode==Enum.KeyCode.E and "rotate-right"
	if step then for _,d in ipairs(currentView.availableActions or {}) do if d.stepId==step or d.id==step then sendActivity(currentView.activityId,currentView.roundId,d.stepId,d.payload); break end end end
end)
local function refresh() status.Text=string.format("Birthday session  •  arrival %s",player:GetAttribute("MVPArrivalStatus") or "Loading") end
player.AttributeChanged:Connect(refresh); refresh(); action:FireServer({kind="RequestSnapshot",actionId=freshId()})
]=]},
{target=[=[ServerStorage/PhuongMVPTools/install]=],kind=[=[ModuleScript]=],sha=[=[5d47409c69e748ed4ec236735f49b799eae9f7fe2c5e21565c1b30d9978fe243]=],source=[=[-- Edit-mode integrator. Require this module and invoke the returned function with measured inputs.
local REQUIRED_ANCHORS = { "GameplayBedroomArrival", "Q01Bed", "JasperBedroomStart", "JasperFetchYard", "Q03FairCraft", "Q03BedroomDisplay", "Q04QuadReading", "Q05UDistrictVending", "Q06FOBCounter", "Q06AladdinsCounter", "Q06Serving", "FinalePatio", "BirthdayLobbyQueue" }
local STATIONS = { "Q01Station", "Q02Station", "Q03Station", "Q04Station", "Q05Station", "Q06Station", "LobbyQueue" }
local ENVIRONMENT = { "SeattleBoundary", "NightLighting", "GrassDecoration" }
local PALETTE = { forest=Color3.fromHex("365744"), sage=Color3.fromHex("A8B995"), cream=Color3.fromHex("F5F0E4"), wood=Color3.fromHex("95674B"), blossom=Color3.fromHex("E8B7C6"), brick=Color3.fromHex("B66C68"), golden=Color3.fromHex("E8C779"), ink=Color3.fromHex("26382E") }

return function(context)
    assert(context and context.Root, "installer requires measured context.Root")
    local root = context.Root
    local mvp = assert(context.MVP or root:FindFirstChild("MVP"), "MVP folder required")
    local anchors = assert(context.Anchors or mvp:FindFirstChild("Anchors"), "resolved measured Anchors required")
    local options = assert(context.Options, "measured Options are required")
    assert(options.OuterQuadBounds and options.Keepouts and options.WorldBounds, "Options require OuterQuadBounds, Keepouts, and WorldBounds provenance")
    local resolvedAnchors, missing = {}, {}
    for _, name in ipairs(REQUIRED_ANCHORS) do
        local anchor = anchors[name] or anchors:FindFirstChild(name, true)
        local status = anchor and anchor:GetAttribute("PlacementStatus")
        if not anchor or not anchor:IsA("BasePart") or type(status) ~= "string" or status == "" or status == "UNRESOLVED_LIVE_ANCHOR" or status == "UNRESOLVED" then table.insert(missing, "Anchor:" .. name) else resolvedAnchors[name] = anchor end
    end
    local builders = assert(context.Builders or script.Parent:FindFirstChild("builders"), "builders folder required")
    local function builder(name) return builders.FindFirstChild and builders:FindFirstChild(name) or builders[name] end
    for _, name in ipairs(STATIONS) do if not builder(name) then table.insert(missing, "Builder:" .. name) end end
    for _, name in ipairs(ENVIRONMENT) do if not builder(name) then table.insert(missing, "Builder:" .. name) end end
    if #missing > 0 then error("MVP preflight failed before scene change: " .. table.concat(missing, ", ")) end
    local stations = mvp:FindFirstChild("Stations") or Instance.new("Folder"); stations.Name = "Stations"
    local environment = mvp:FindFirstChild("Environment") or Instance.new("Folder"); environment.Name = "Environment"
    local original, staged, restores = {}, {}, {}
    local function safeReplace(ownedName, ownedParent, name, factory)
        assert(name == ownedName, "SafeReplace name outside caller ownership"); assert(ownedParent == stations or ownedParent == environment, "SafeReplace parent outside MVP ownership")
        local parent = ownedParent
        local made = factory(); assert(made and (made:IsA("Folder") or made:IsA("Model")) and not made.Parent, "factory must return detached Folder/Model")
        local old = parent:FindFirstChild(name); original[name] = { old=old, parent=parent }; if old then old.Parent = nil end
        made.Name = name; made.Parent = parent; staged[name] = made; return made
    end
    local shared = { Root=root, MVP=mvp, Anchors=resolvedAnchors, Palette=PALETTE, RequiredPalette=PALETTE, Options=options, Lighting=context.Lighting or game:GetService("Lighting") }
    function shared:ValidateAnchors(names) for _, name in ipairs(names) do local a = self.Anchors[name]; local s = a and a:GetAttribute("PlacementStatus"); assert(a and a:IsA("BasePart") and type(s)=="string" and s~="" and s~="UNRESOLVED_LIVE_ANCHOR" and s~="UNRESOLVED", "unresolved anchor: " .. name) end return true end
    local ok, result = pcall(function()
        stations.Parent = mvp; environment.Parent = mvp
        local out = {}
        for _, name in ipairs(STATIONS) do local c = table.clone(shared); c.SafeReplace=function(n,f) return safeReplace(name,stations,n,f) end; out[name] = require(builder(name))(c); if out[name].Restore then table.insert(restores,out[name].Restore) end end
        for _, name in ipairs(ENVIRONMENT) do local c = table.clone(shared); c.SafeReplace=function(n,f) return safeReplace(name,environment,n,f) end; out[name] = require(builder(name))(c); if out[name].Restore then table.insert(restores,out[name].Restore) end end
        return out
    end)
    if not ok then for i=#restores,1,-1 do pcall(restores[i]) end; for _, item in pairs(staged) do if item then item:Destroy() end end; for _, backup in pairs(original) do if backup.old then backup.old.Parent = backup.parent end end; error("MVP install rolled back owned outputs: " .. tostring(result)) end
    return { folders = result, manifest = { RequiredAnchors=REQUIRED_ANCHORS, Stations=STATIONS, Environment=ENVIRONMENT, Measurements="provided by Task01", PaletteTokens=PALETTE } }
end
]=]},
{target=[=[ServerStorage/PhuongMVPTools/build-world]=],kind=[=[Script]=],sha=[=[3d3c86bef7fbe4d6519e7ac7a8471d9e8ce91b657ccac253a69a392967cec250]=],source=[=[-- Edit-mode anchor builder. Creates/updates only MVP.Anchors; never destroys MVP or world content.
local root = assert(workspace:FindFirstChild("CozyWorld_Draft01"), "Existing CozyWorld_Draft01 is required")
local mvp = root:FindFirstChild("MVP") or Instance.new("Folder")
mvp.Name = "MVP"; mvp:SetAttribute("Source", "roblox/mvp/build-world.luau"); mvp.Parent = root
local anchors = mvp:FindFirstChild("Anchors") or Instance.new("Folder")
anchors.Name = "Anchors"; anchors.Parent = mvp
local names = {"GameplayBedroomArrival","Q01Bed","JasperBedroomStart","JasperFetchYard","Q03FairCraft","Q03BedroomDisplay","Q04QuadReading","Q04BedroomKindle","Q05UDistrictVending","Q06FOBCounter","Q06AladdinsCounter","Q06Serving","FinalePatio","BirthdayLobbyQueue"}
for _, name in names do
    local marker = anchors:FindFirstChild(name) or Instance.new("Part")
    marker.Name = name; marker.Size = marker.Size.Magnitude > 0 and marker.Size or Vector3.new(1,.15,1)
    marker.Anchored = true; marker.CanCollide = false; marker.CanTouch = false; marker.CanQuery = true; marker.Transparency = 1
    marker:SetAttribute("PlacementStatus", marker:GetAttribute("PlacementStatus") or "UNRESOLVED_LIVE_ANCHOR"); marker.Parent = anchors
end
print("MVP anchor subtree updated; unresolved anchors remain rejected by resolver")
]=]},
{target=[=[ServerStorage/PhuongMVPTools/builders/Q01Station]=],kind=[=[ModuleScript]=],sha=[=[506d116a500108d4f10393a72614adbe1858fcf50fb1ea16e41dcba02c3741ae]=],source=[=[-- Native, installable Q01 bed/station visuals. Task 01 owns actual Studio installation.
local Q01Station = {}

local COLORS = {
	Forest = Color3.fromRGB(54, 87, 68), Sage = Color3.fromRGB(168, 185, 149), Cream = Color3.fromRGB(245, 240, 228),
	Wood = Color3.fromRGB(149, 103, 75), Golden = Color3.fromRGB(232, 199, 121), Ink = Color3.fromRGB(38, 56, 46),
}

local function part(parent, name, size, cframe, color, canCollide)
	local p = Instance.new("Part")
	p.Name, p.Size, p.CFrame, p.Color, p.Anchored, p.CanCollide = name, size, cframe, color, true, canCollide ~= false
	p.Material = Enum.Material.SmoothPlastic
	p:SetAttribute("VerificationTicket", "PCW-07")
	p:SetAttribute("PaletteToken", color == COLORS.Sage and "sage" or color == COLORS.Wood and "wood" or color == COLORS.Cream and "cream" or color == COLORS.Forest and "forest" or color == COLORS.Golden and "golden" or "ink")
	p:SetAttribute("MVPBuilder", "Q01Station")
	p.Parent = parent
	return p
end

function Q01Station.Build(parent, anchorCFrame)
	assert(parent and anchorCFrame, "Q01Station.Build requires parent and Q01Bed CFrame")
	local model = Instance.new("Model")
	model.Name = "Q01EverythingTuckedIn"
	model:SetAttribute("ActivityId", "Q01")
	model:SetAttribute("VerificationTicket", "PCW-07")
	local base = anchorCFrame
	part(model, "BedFrame", Vector3.new(7, 1, 10), base * CFrame.new(0, 0.5, 0), COLORS.Wood)
	part(model, "SageBedding", Vector3.new(6.7, 0.55, 8.6), base * CFrame.new(0, 1.25, 0.2), COLORS.Sage)
	part(model, "Headboard", Vector3.new(7, 4, 0.5), base * CFrame.new(0, 2.5, -4.7), COLORS.Cream)
	local pillows = { { "PillowLeft", -1.7 }, { "PillowRight", 1.7 } }
	for _, data in ipairs(pillows) do part(model, data[1], Vector3.new(2.5, 0.45, 1.5), base * CFrame.new(data[2], 1.75, -3), COLORS.Cream, false) end
	part(model, "RoundBelliedDog", Vector3.new(1.7, 1.6, 1.7), base * CFrame.new(-2.1, 2, -0.6), COLORS.Golden, false)
	part(model, "DinosaurPlush", Vector3.new(1.5, 1.8, 2), base * CFrame.new(2.1, 2.1, -0.4), COLORS.Forest, false)
	local socketOffsets = { blanket_left = Vector3.new(-3.8, 1.5, 0), blanket_right = Vector3.new(3.8, 1.5, 0), blanket_foot = Vector3.new(0, 1.5, 5.1), pillow_left = Vector3.new(-1.7, 1.9, -3), pillow_right = Vector3.new(1.7, 1.9, -3), plush_dog = Vector3.new(-2.1, 2.2, -0.6), plush_dinosaur = Vector3.new(2.1, 2.2, -0.4) }
	for stepId, offset in pairs(socketOffsets) do
		local socket = part(model, "Socket_" .. stepId, Vector3.new(2.2, 0.15, 1.8), base * CFrame.new(offset), COLORS.Golden, false)
		socket.Transparency = 0.65
		socket:SetAttribute("StepId", stepId)
	end
	model.PrimaryPart = model:FindFirstChild("BedFrame")
	return model
end

return function(context)
	assert(context and context.Root and context.MVP and context.Anchors and context.SafeReplace, "Q01Station context is incomplete")
	local anchor = context.Anchors.Q01Bed
	assert(anchor, "Q01Station requires resolved Q01Bed anchor")
	local placementStatus = anchor:GetAttribute("PlacementStatus")
	assert(placementStatus and not string.find(placementStatus, "UNRESOLVED", 1, true), "Q01Bed anchor lacks valid live placement provenance")
	local anchorCFrame = anchor:IsA("BasePart") and anchor.CFrame or CFrame.new(anchor.Position)
	local manifest = {
		AnchorName = "Q01Bed",
		Footprint = "7x10 bed; sockets remain outside collision",
		ApproachClearance = "Measured by integrator from live anchor",
		Owner = "Task02",
		SourceBuilder = "roblox/mvp/builders/Q01Station.luau",
	}
	local installedFolder = context.SafeReplace("Q01", function()
		local model = Q01Station.Build(nil, anchorCFrame)
		model:SetAttribute("Owner", manifest.Owner)
		model:SetAttribute("MVPBuilder", "Q01Station")
		model:SetAttribute("AnchorName", manifest.AnchorName)
		model:SetAttribute("Footprint", manifest.Footprint)
		model:SetAttribute("ApproachClearance", manifest.ApproachClearance)
		model:SetAttribute("SourceBuilder", manifest.SourceBuilder)
		return model
	end)
	return { folder = installedFolder, manifest = manifest }
end
]=]},
{target=[=[ServerStorage/PhuongMVPTools/builders/Q02Station]=],kind=[=[ModuleScript]=],sha=[=[ab96d920805a6dc1b3f8c4a587fc31dd3f74f65179efba9d924a7130dcca21e8]=],source=[=[-- Q02 edit-mode builder. The integrator supplies the frozen builder context.
return function(context)
    assert(context and context.Root and context.MVP and context.Anchors and context.Palette, "Q02 builder context is required")
    assert(type(context.SafeReplace) == "function", "Q02 requires SafeReplace(name, factory)")
    local bedroom = context.Anchors.JasperBedroomStart
    local yard = context.Anchors.JasperFetchYard
    assert(bedroom and yard, "Q02 requires JasperBedroomStart and JasperFetchYard")
    assert(bedroom:GetAttribute("PlacementStatus") ~= "UNRESOLVED_LIVE_ANCHOR" and yard:GetAttribute("PlacementStatus") ~= "UNRESOLVED_LIVE_ANCHOR", "Q02 anchors cannot be unresolved")
    local requiredPalette = {"forest", "sage", "cream", "wood", "golden", "ink"}
    for _, token in ipairs(requiredPalette) do assert(context.Palette[token], "Q02 palette token is missing: " .. token) end

    local function factory()
        local folder = Instance.new("Folder")
        folder.Name = "Q02"
        folder:SetAttribute("VerificationTicket", "PCW-08")
        folder:SetAttribute("MVPBuilder", "Q02Station")
        folder:SetAttribute("Owner", "Q02")
        folder:SetAttribute("Status", "Source authored; Studio install and play verification pending")
        folder:SetAttribute("PalettePolicy", "Exact world palette until approved Jasper figure profile")
        local function marker(name, position, size, token, action, anchorName, footprint, clearance)
            local part = Instance.new("Part")
            part.Name, part.Size, part.CFrame = name, size, CFrame.new(position)
            part.Color, part.Anchored, part.CanCollide, part.CanTouch, part.CanQuery = context.Palette[token], true, false, false, true
            part.Transparency, part.Material = .45, Enum.Material.SmoothPlastic
            part:SetAttribute("VerificationTicket", "PCW-08")
            part:SetAttribute("PaletteToken", token)
            part:SetAttribute("MVPBuilder", "Q02Station")
            part:SetAttribute("Owner", "Q02")
            part:SetAttribute("AnchorName", anchorName)
            part:SetAttribute("Footprint", footprint)
            part:SetAttribute("ApproachClearance", clearance)
            part:SetAttribute("Q02Action", action)
            part.Parent = folder
        end
        local bedroomPosition, yardPosition = bedroom.Position, yard.Position
        marker("JasperBedroomGreeting", bedroomPosition, Vector3.new(5, 2, 5), "golden", "greet", "JasperBedroomStart", "5x2x5", "2 studs")
        marker("JasperFetchLane", yardPosition, Vector3.new(10, .3, 5), "forest", "throw", "JasperFetchYard", "10x0.3x5", "3 studs")
        for index = 1, 3 do marker("JasperRabbitBasket" .. string.char(64 + index), yardPosition + Vector3.new((index - 2) * 4, 1, 5), Vector3.new(2, 2, 2), "wood", "inspect", "JasperFetchYard", "2x2x2", "2 studs") end
        marker("JasperRabbitHandoff", yardPosition + Vector3.new(0, 1, -3), Vector3.new(3, 2, 3), "sage", "return_rabbit", "JasperFetchYard", "3x2x3", "2 studs")
        marker("JasperGreenie", yardPosition + Vector3.new(0, 1, -5), Vector3.new(3, 2, 2), "golden", "greenie", "JasperFetchYard", "3x2x2", "2 studs")
        folder:SetAttribute("PromptBindings", "JasperBedroomStart:greet; JasperFetchYard:inspect,throw,return_rabbit,greenie")
        folder:SetAttribute("SourceAnchorState", "validated")
        return folder
    end
    local installed = context.SafeReplace("Q02", factory)
    return {folder = installed, manifest = {ticket = "PCW-08", builder = "Q02Station", owner = "Q02", anchorNames = {"JasperBedroomStart", "JasperFetchYard"}, promptBindings = {"bedroom:greet", "yard:inspect", "yard:throw", "yard:return_rabbit", "yard:greenie"}, paletteTokens = requiredPalette, sourceReference = "Existing Jasper identity is preserved; this builder stages interaction markers only.", verification = "Studio install, navigation, figure identity, touch/desktop and group play remain pending."}}
end
]=]},
{target=[=[ServerStorage/PhuongMVPTools/builders/Q03Station]=],kind=[=[ModuleScript]=],sha=[=[d839c1e26ce806a226373f1c3a6f4fe8a0ec99330b292417f8b50825d79dec04]=],source=[=[return function(context)
    assert(context and context.Root and context.MVP and context.MVP.Stations, "Q03Station context is incomplete")
    assert(type(context.SafeReplace) == "function", "Q03Station requires SafeReplace")
    local anchors = assert(context.Anchors, "Q03Station Anchors required")
    local boothAnchor = assert(anchors.Q03FairCraft, "Q03FairCraft anchor required")
    local homeAnchor = assert(anchors.Q03BedroomDisplay, "Q03BedroomDisplay anchor required")
    assert(boothAnchor:GetAttribute("PlacementStatus") ~= "UNRESOLVED_LIVE_ANCHOR", "Q03FairCraft anchor unresolved")
    assert(homeAnchor:GetAttribute("PlacementStatus") ~= "UNRESOLVED_LIVE_ANCHOR", "Q03BedroomDisplay anchor unresolved")
    local palette = assert(context.Palette, "Q03Station palette required")
    for _, token in ipairs({"forest", "sage", "cream", "wood", "blossom", "golden", "ink"}) do assert(palette[token], "missing palette token: " .. token) end
    local manifest = {AnchorName="Q03FairCraft;Q03BedroomDisplay", Footprint="14x10 proposed; measured anchors required", ApproachClearance="3 front; 2 side proposed", Owner="Task04", SourceBuilder="roblox/mvp/builders/Q03Station.luau"}
    local function factory()
        local folder = Instance.new("Folder"); folder.Name = "Q03"; folder:SetAttribute("VerificationTicket", "PCW-09"); folder:SetAttribute("MVPBuilder", "Q03Station"); folder:SetAttribute("Owner", "Task04")
        local function part(name,size,cf,token,parent,collide)
            local p=Instance.new("Part"); p.Name=name; p.Size=size; p.CFrame=cf; p.Color=palette[token]; p.Anchored=true; p.CanCollide=collide==true
            for key,value in pairs({VerificationTicket="PCW-09",PaletteToken=token,MVPBuilder="Q03Station",AnchorName=manifest.AnchorName,Footprint=manifest.Footprint,ApproachClearance=manifest.ApproachClearance,Owner=manifest.Owner,SourceBuilder=manifest.SourceBuilder}) do p:SetAttribute(key,value) end
            p.Parent=parent; return p
        end
        local function piece(name,size,cf,token) local m=Instance.new("Model"); m.Name=name; m.Parent=folder; part("Body",size,cf,token,m,false); return m end
        local b,h=boothAnchor.CFrame,homeAnchor.CFrame
        part("CraftTable",Vector3.new(8,2,4),b*CFrame.new(0,1,0),"wood",folder,true)
        for i=1,6 do local x=((i-1)%3-1)*2.2; local z=(math.floor((i-1)/3)-.5)*1.5; part("Socket_"..i,Vector3.new(1.4,.08,1.1),b*CFrame.new(x,2.05,z),"golden",folder,false) end
        piece("Rug",Vector3.new(2.4,.08,1.8),b*CFrame.new(-2.2,2.12,-.75),"sage"); piece("Chair",Vector3.new(1.2,1.4,1.2),b*CFrame.new(0,2.8,-.75),"sage"); piece("Bookcase",Vector3.new(1.1,1.8,.45),b*CFrame.new(2.2,2.9,-.75),"wood"); piece("SideTable",Vector3.new(1,.8,1),b*CFrame.new(-2.2,2.55,.75),"wood"); piece("Plant",Vector3.new(.7,1.2,.7),b*CFrame.new(0,2.7,.75),"forest"); piece("Lamp",Vector3.new(.6,1.4,.6),b*CFrame.new(2.2,2.8,.75),"golden")
        local home=Instance.new("Model"); home.Name="HomeDisplay"; home.Parent=folder; part("DisplayBase",Vector3.new(7,.3,5),h*CFrame.new(0,.2,0),"wood",home,false); home:SetAttribute("SharedState","Q03 server miniature; booth and desk are one state"); home:SetAttribute("NoDuplicateReward",true)
        return folder
    end
    local installed=context.SafeReplace("Q03",factory)
    return {folder=installed,manifest=manifest}
end
]=]},
{target=[=[ServerStorage/PhuongMVPTools/builders/Q04Station]=],kind=[=[ModuleScript]=],sha=[=[747754d4330ebeec6661cc139401537d70a8adfbb7c01af5d55ded1ea22ee6d7]=],source=[=[return function(context)
    assert(context and context.Root and context.MVP and context.Anchors and context.Palette, "Q04 station context is required")
    assert(context.SafeReplace, "Q04Station requires SafeReplace")
    local required = { "Q04QuadReading", "Q04BedroomKindle" }
    for _, name in ipairs(required) do
        local anchor = context.Anchors[name]
        assert(anchor, "Required Q04 anchor missing: " .. name)
        assert(anchor:GetAttribute("PlacementStatus") ~= "UNRESOLVED_LIVE_ANCHOR", "Q04 anchor unresolved: " .. name)
    end
    for _, token in ipairs({ "forest", "sage", "cream", "wood", "blossom", "brick", "golden", "ink" }) do
        assert(context.Palette[token], "Required palette token missing: " .. token)
    end
    local function factory()
        local folder = Instance.new("Folder")
        folder.Name = "Q04"
        folder:SetAttribute("VerificationTicket", "PCW-10")
        folder:SetAttribute("MVPBuilder", "Q04Station")
        local function prop(name, anchorName, token, offset, footprint, clearance)
            local part = Instance.new("Part")
            part.Name = name
            part.Size = Vector3.new(.8, .18, .55)
            part.CFrame = context.Anchors[anchorName].CFrame * CFrame.new(offset)
            part.Color = context.Palette[token]
            part.Anchored = true
            part.CanCollide = false
            part.CanTouch = false
            part.CanQuery = false
            for key, value in { VerificationTicket = "PCW-10", PaletteToken = token, MVPBuilder = "Q04Station", AnchorName = anchorName, Footprint = footprint, ApproachClearance = clearance, Owner = "Task05", SourceBuilder = "roblox/mvp/builders/Q04Station.luau" } do
                part:SetAttribute(key, value)
            end
            part.Parent = folder
        end
        prop("QuadReadingBook", "Q04QuadReading", "wood", Vector3.new(0, 1.15, 0), "Existing bench only", "Measured by Task01")
        prop("QuadReadingPrompt", "Q04QuadReading", "golden", Vector3.new(0, 1.45, 0), "Existing bench only", "Measured by Task01")
        prop("BedroomKindlePrompt", "Q04BedroomKindle", "forest", Vector3.new(0, .25, 0), "Existing desk/display only", "Measured by Task01")
        return folder
    end
    local manifest = { VerificationTicket = "PCW-10", MVPBuilder = "Q04Station", Owner = "Task05", SourceBuilder = "roblox/mvp/builders/Q04Station.luau", RequiredAnchors = required, Preserves = { "Existing Quad benches", "QuadPlanting", "Quad paths", "Bedroom desk/Kindle" }, BasePartCount = 3 }
    local installed = context.SafeReplace("Q04", factory)
    return {
        folder = installed,
        manifest = manifest,
    }
end
]=]},
{target=[=[ServerStorage/PhuongMVPTools/builders/Q05Station]=],kind=[=[ModuleScript]=],sha=[=[162f269a50e639ff99d095fdac4bf223330ed6b466b30db6e79ac5308a5e0539]=],source=[=[-- Native, installable Q05 vending visuals. Task 01 owns Studio installation.
return function(context)
    assert(context and context.Root and context.MVP and context.Anchors and context.Palette and context.SafeReplace, "Q05Station context is incomplete")
    local anchor = context.Anchors.Q05UDistrictVending
    assert(anchor and anchor:IsA("BasePart"), "Q05Station requires Q05UDistrictVending BasePart")
    assert(anchor:GetAttribute("PlacementStatus") ~= "UNRESOLVED_LIVE_ANCHOR", "Q05 vending anchor is unresolved")
    local anchorCFrame = anchor.CFrame
    local manifest = {AnchorName = "Q05UDistrictVending", Footprint = "6.4 x 2.4 cabinet footprint", ApproachClearance = "Measured by integrator outside crossing and pedestrian route", Owner = "Task06", SourceBuilder = "roblox/mvp/builders/Q05Station.luau"}
    local installed = context.SafeReplace("Q05", function()
        local folder = Instance.new("Model"); folder.Name = "Q05LabubuVending"
        folder:SetAttribute("ActivityId", "Q05"); folder:SetAttribute("VerificationTicket", "PCW-11"); folder:SetAttribute("MVPBuilder", "Q05Station")
        for key, value in pairs(manifest) do folder:SetAttribute(key, value) end
        folder:SetAttribute("Interaction", "Inspect; select wanted; authorized shared-fund roll; skippable reveal")
        local function part(name, size, cf, token, material, collide)
            assert(context.Palette[token], "unknown palette token: " .. token)
            local item = Instance.new("Part"); item.Name = name; item.Size = size; item.CFrame = cf; item.Color = context.Palette[token]; item.Material = material or Enum.Material.SmoothPlastic; item.Anchored = true; item.CanCollide = collide == true; item.CanTouch = false; item.CanQuery = true
            item:SetAttribute("VerificationTicket", "PCW-11"); item:SetAttribute("PaletteToken", token); item:SetAttribute("MVPBuilder", "Q05Station"); item:SetAttribute("AnchorName", manifest.AnchorName); item:SetAttribute("Footprint", manifest.Footprint); item:SetAttribute("ApproachClearance", manifest.ApproachClearance); item:SetAttribute("Owner", manifest.Owner); item:SetAttribute("SourceBuilder", manifest.SourceBuilder); item.Parent = folder; return item
        end
        part("CabinetBody", Vector3.new(6, 7, 2), anchorCFrame * CFrame.new(0, 3.5, 0), "forest", Enum.Material.Wood, true)
        part("DisplayPanel", Vector3.new(5.2, 3.2, .18), anchorCFrame * CFrame.new(0, 5.05, -1.08), "cream", Enum.Material.Glass, false)
        part("GoldHeader", Vector3.new(5.4, .45, 2.15), anchorCFrame * CFrame.new(0, 7.2, 0), "golden", Enum.Material.Metal, false)
        part("Counter", Vector3.new(6.4, .35, 2.4), anchorCFrame * CFrame.new(0, 1.4, -.2), "wood", Enum.Material.Wood, true)
        for index = 1, 7 do part("FigureSlot" .. index, Vector3.new(.48, .72, .18), anchorCFrame * CFrame.new((index - 4) * .62, 5.05, -1.22), index == 7 and "blossom" or "sage", nil, false) end
        part("PromptPlate", Vector3.new(2.8, .5, .12), anchorCFrame * CFrame.new(0, 2.05, -1.22), "golden", Enum.Material.Neon, false)
        return folder
    end)
    return {folder = installed, manifest = manifest}
end
]=]},
{target=[=[ServerStorage/PhuongMVPTools/builders/Q06Station]=],kind=[=[ModuleScript]=],sha=[=[5dff5317cc0f8ed2902e367c14e67bd5988ce208d76ee7504903b222af38519f]=],source=[=[-- Q06 station builder. Geometry is derived from measured UDistrict anchors only.
return function(context)
    assert(context and context.Root and context.MVP and context.Anchors and context.Palette and context.SafeReplace, "Q06Station context is incomplete")
    local required = { "Q06FOBCounter", "Q06AladdinsCounter", "Q06Serving" }
    for _, name in ipairs(required) do
        local anchor = context.Anchors[name]
        assert(anchor and anchor:IsA("BasePart"), "Q06Station requires anchor BasePart: " .. name)
        assert(anchor:GetAttribute("Status") ~= "UNRESOLVED" and anchor:GetAttribute("PlacementStatus") ~= "UNRESOLVED_LIVE_ANCHOR", "Q06 anchor unresolved: " .. name)
    end
    for _, token in ipairs({ "forest", "sage", "cream", "wood", "blossom", "brick", "golden", "ink" }) do assert(context.Palette[token], "Required palette token missing: " .. token) end
    local manifests = {}
    for _, name in ipairs(required) do manifests[name] = { AnchorName=name, Footprint="10 x 4 station footprint", ApproachClearance="Measured UDistrict route clearance", Owner="Task07", SourceBuilder="roblox/mvp/builders/Q06Station.luau" } end
    local function factory()
        local folder = Instance.new("Folder"); folder.Name = "Q06"; folder:SetAttribute("ActivityId", "Q06"); folder:SetAttribute("VerificationTicket", "PCW-12"); folder:SetAttribute("MVPBuilder", "Q06Station")
        local function part(parent, name, size, cf, token, manifest, collide)
            local item = Instance.new("Part"); item.Name, item.Size, item.CFrame, item.Color = name, size, cf, context.Palette[token]; item.Anchored, item.CanCollide, item.CanTouch, item.CanQuery = true, collide == true, false, true
            for key, value in pairs({ VerificationTicket="PCW-12", PaletteToken=token, MVPBuilder="Q06Station", AnchorName=manifest.AnchorName, Footprint=manifest.Footprint, ApproachClearance=manifest.ApproachClearance, Owner=manifest.Owner, SourceBuilder=manifest.SourceBuilder }) do item:SetAttribute(key, value) end
            item.Parent = parent
        end
        for _, name in ipairs(required) do
            local station = Instance.new("Model"); station.Name = name; station.Parent = folder
            local anchor, manifest = context.Anchors[name], manifests[name]
            part(station, "Counter", Vector3.new(10,2,4), anchor.CFrame * CFrame.new(0,1,0), "wood", manifest, true)
            part(station, "ActionSurface", Vector3.new(8,.15,3), anchor.CFrame * CFrame.new(0,2.1,0), "cream", manifest, false)
            part(station, "StationLabel", Vector3.new(4,1,.15), anchor.CFrame * CFrame.new(0,3,-1.8), "forest", manifest, false)
        end
        return folder
    end
    local installedFolder = context.SafeReplace("Q06", factory)
    assert(installedFolder and installedFolder.IsA and (installedFolder:IsA("Folder") or installedFolder:IsA("Model")), "Q06 SafeReplace must return installed Folder or Model")
    return { folder=installedFolder, manifest={ VerificationTicket="PCW-12", MVPBuilder="Q06Station", Owner="Task07", SourceBuilder="roblox/mvp/builders/Q06Station.luau", RequiredAnchors=required, PatioPlacement="forbidden", Measurements="pending" } }
end
]=]},
{target=[=[ServerStorage/PhuongMVPTools/builders/LobbyQueue]=],kind=[=[ModuleScript]=],sha=[=[975ada6afa10e774d5022705ed83325b1d51f4f468e478cecf5d76416884db18]=],source=[=[-- Detached lobby queue builder. Task 01 supplies the prebound MVP SafeReplace helper.
local TICKET = "PCW-17"
local BUILDER = "LobbyQueue"

local function metadata(part, token, anchor, footprint, clearance)
	part:SetAttribute("VerificationTicket", TICKET)
	part:SetAttribute("PaletteToken", token)
	part:SetAttribute("MVPBuilder", BUILDER)
	part:SetAttribute("AnchorName", anchor)
	part:SetAttribute("Footprint", footprint)
	part:SetAttribute("ApproachClearance", clearance)
	part:SetAttribute("Owner", "Task08")
	part:SetAttribute("SourceBuilder", BUILDER)
end

local function part(parent, name, size, frame, token, footprint, clearance)
	local value = Instance.new("Part")
	value.Name = name
	value.Size = size
	value.CFrame = frame
	value.Anchored = true
	value.CanCollide = true
	metadata(value, token, "BirthdayLobbyQueue", footprint, clearance)
	value.Parent = parent
end

local function validate(context)
	assert(type(context) == "table", "LobbyQueue requires context")
	assert(type(context.SafeReplace) == "function", "LobbyQueue requires prebound SafeReplace")
	assert(type(context.ValidateAnchors) == "function", "LobbyQueue requires shared anchor validator")
	assert(context:ValidateAnchors({ "BirthdayLobbyQueue" }), "BirthdayLobbyQueue anchor validation failed")
	local anchor = context.Anchors and context.Anchors.BirthdayLobbyQueue
	assert(typeof(anchor) == "Instance" and anchor:IsA("BasePart"), "BirthdayLobbyQueue must be a measured BasePart")
	if context.RequiredPalette then
		assert(context.RequiredPalette.forest and context.RequiredPalette.cream, "queue palette unavailable")
	end
end

local function factory(anchorCFrame)
	local folder = Instance.new("Folder")
	folder.Name = "LobbyQueue"
	folder:SetAttribute("VerificationTicket", TICKET)
	folder:SetAttribute("MVPBuilder", BUILDER)
	folder:SetAttribute("Owner", "Task08")
	folder:SetAttribute("SourceBuilder", BUILDER)
	part(folder, "QueueFloor", Vector3.new(12, 0.2, 12), anchorCFrame, "forest", "12x12 opt-in square", "16 studs")
	part(folder, "QueueSign", Vector3.new(8, 4, 0.2), anchorCFrame * CFrame.new(0, 3, -6), "cream", "8x4 readable sign", "12 studs")
	return folder
end

return function(context)
	validate(context)
	local anchorCFrame = context.Anchors.BirthdayLobbyQueue.CFrame
	assert(typeof(anchorCFrame) == "CFrame", "BirthdayLobbyQueue requires measured CFrame")
	local installedFolder = context.SafeReplace("LobbyQueue", function()
		return factory(anchorCFrame)
	end)
	return {
		folder = installedFolder,
		manifest = { Ticket = TICKET, Builder = BUILDER, Owner = "Task08", AnchorName = "BirthdayLobbyQueue", Footprint = "12x12 square plus sign", ApproachClearance = "16 studs / 12 studs", QueueRule = "one opt-in queue, max 10, shared deadline" },
	}
end
]=]},
{target=[=[ServerStorage/PhuongMVPTools/builders/SeattleBoundary]=],kind=[=[ModuleScript]=],sha=[=[30b00752643d99c8dff8e5c41f0f40094eefd90ab8d052335692a375e436b715]=],source=[=[-- Task 10 Seattle perimeter builder.
-- Run in Studio Edit mode by the designated integrator after Task 01 resolves live anchors.
-- Owns only CozyWorld_Draft01.MVP.MvpSeattleBoundary; no lighting, scripts, interiors, or gameplay.

return function(context)
	assert(context and context.Root and context.MVP and context.Anchors, "SeattleBoundary context is incomplete")
	assert(type(context.SafeReplace) == "function", "SeattleBoundary requires context.SafeReplace")
	local RunService = game:GetService("RunService")
	assert(not RunService:IsRunning(), "SeattleBoundary must be authored in Edit mode")

	local root = context.Root
	local mvp = context.MVP
	local anchors = context.Anchors
local required = { "GameplayBedroomArrival", "Q05UDistrictVending", "Q04QuadReading", "FinalePatio" }
for _, name in required do
	local marker = anchors[name] or (anchors.FindFirstChild and anchors:FindFirstChild(name, true))
	assert(marker and marker:IsA("BasePart"), "Missing live anchor: " .. name)
	assert(marker:GetAttribute("PlacementStatus") ~= "UNRESOLVED_LIVE_ANCHOR", "Unresolved live anchor: " .. name)
end

local palette = context.Palette or {
	forest = Color3.fromHex("365744"), sage = Color3.fromHex("A8B995"),
	cream = Color3.fromHex("F5F0E4"), wood = Color3.fromHex("95674B"),
	blossom = Color3.fromHex("E8B7C6"), brick = Color3.fromHex("B66C68"),
	golden = Color3.fromHex("E8C779"), ink = Color3.fromHex("26382E"),
}

	local stage = Instance.new("Folder")
stage.Name = "SeattleBoundary"
stage:SetAttribute("VerificationTicket", "PCW-03/MAP-02/MAP-03")
stage:SetAttribute("BuilderSource", "roblox/mvp/builders/SeattleBoundary.luau")
stage:SetAttribute("Status", "Static perimeter; Studio/device/group verification pending")
stage:SetAttribute("CollisionPolicy", "Visual-only; integrator owns any invisible world boundary")
stage:SetAttribute("SkylinePolicy", "Open upper sky band; no roof")
	stage:SetAttribute("Owner", "Task10")
	stage:SetAttribute("SourceBuilder", "SeattleBoundary")
	stage:SetAttribute("AnchorName", "WorldBoundsFromTask01")
	stage:SetAttribute("Footprint", "Derived outer facade ring; no playable interior")
	stage:SetAttribute("ApproachClearance", "Validated by Task13 against live routes")

local count = 0
local function part(name, size, cf, token, parent, material)
	assert(palette[token], "Unknown palette token: " .. tostring(token))
	local object = Instance.new("Part")
	object.Name = name
	object.Size = size
	object.CFrame = cf
	object.Color = palette[token]
	object.Material = material or Enum.Material.SmoothPlastic
	object.Anchored = true
	object.CanCollide = false
	object.CanTouch = false
	object.CanQuery = false
	object.CastShadow = false
	object.TopSurface = Enum.SurfaceType.Smooth
	object.BottomSurface = Enum.SurfaceType.Smooth
	object:SetAttribute("PaletteToken", token)
	object:SetAttribute("BoundaryOwner", "Task10")
	object:SetAttribute("VerificationTicket", "PCW-03/MAP-02/MAP-03")
	object:SetAttribute("MVPBuilder", "SeattleBoundary")
	object.Parent = parent
	count += 1
	return object
end

local function model(name, parent)
	local object = Instance.new("Model")
	object.Name = name
	object.Parent = parent
	return object
end

-- Prefer Task 01's frozen bounds. Otherwise derive them from original scene parts,
-- explicitly excluding all generated MVP geometry so reruns cannot expand the ring.
local supplied = context.Options and context.Options.WorldBounds
local minX, maxX, minZ, maxZ, centerY
if supplied then
	minX, maxX, minZ, maxZ, centerY = supplied.minX, supplied.maxX, supplied.minZ, supplied.maxZ, supplied.centerY
else
	local minVector = Vector3.new(math.huge, math.huge, math.huge)
	local maxVector = Vector3.new(-math.huge, -math.huge, -math.huge)
	local found = false
	for _, object in root:GetDescendants() do
		if object:IsA("BasePart") and not object:IsDescendantOf(mvp) then
			local p = object.Position
			local half = object.Size / 2
			minVector = Vector3.new(math.min(minVector.X, p.X - half.X), math.min(minVector.Y, p.Y - half.Y), math.min(minVector.Z, p.Z - half.Z))
			maxVector = Vector3.new(math.max(maxVector.X, p.X + half.X), math.max(maxVector.Y, p.Y + half.Y), math.max(maxVector.Z, p.Z + half.Z))
			found = true
		end
	end
	assert(found, "No original world BaseParts found for stable Seattle boundary bounds")
	minX, maxX, minZ, maxZ, centerY = minVector.X, maxVector.X, minVector.Z, maxVector.Z, (minVector.Y + maxVector.Y) / 2
end
assert(minX and maxX and minZ and maxZ and centerY, "WorldBounds must provide minX/maxX/minZ/maxZ/centerY")
local pad = 12
local y = centerY + 8
local wallHeight = 18
stage:SetAttribute("WorldBounds", string.format("%.2f,%.2f,%.2f,%.2f", minX, maxX, minZ, maxZ))
stage:SetAttribute("FacadeSetback", pad)

local function facadeRow(name, x, z, length, yaw, parent, variant)
	local row = model(name, parent)
	local segment = 28
	local pieces = math.max(1, math.ceil(length / segment))
	for i = 1, pieces do
		local along = (i - (pieces + 1) / 2) * (length / pieces)
		local base = CFrame.new(x, y + 8 + ((i + variant) % 3) * 1.5, z) * CFrame.Angles(0, yaw, 0) * CFrame.new(along, 0, 0)
		local width = length / pieces - 1
		part("Shell" .. i, Vector3.new(width, 16 + ((i + variant) % 3) * 3, 2.4), base, i % 2 == 0 and "cream" or "brick", row, Enum.Material.SmoothPlastic)
		part("Roofline" .. i, Vector3.new(width + .7, .65, 3.1), base * CFrame.new(0, 9.1 + ((i + variant) % 3) * 1.5, 0), "wood", row, Enum.Material.Wood)
		for window = -1, 1, 2 do
			part("Window" .. i .. "_" .. window, Vector3.new(2.6, 3.2, .18), base * CFrame.new(window * width * .22, 1.2, -1.28), "golden", row, Enum.Material.Neon)
		end
	end
	return row
end

local west = model("WestUDistrictBackdrop", stage)
facadeRow("WestFacade", minX - pad, (minZ + maxZ) / 2, maxZ - minZ, math.pi / 2, west, 1)
local north = model("NorthHouseJasperBackdrop", stage)
facadeRow("NorthFacade", (minX + maxX) / 2, minZ - pad, maxX - minX, 0, north, 2)
local east = model("EastQuadBackdrop", stage)
facadeRow("EastFacade", maxX + pad, (minZ + maxZ) / 2, maxZ - minZ, math.pi / 2, east, 3)
local south = model("SouthArrivalPatioBackdrop", stage)
facadeRow("SouthFacade", (minX + maxX) / 2, maxZ + pad, maxX - minX, 0, south, 4)

-- Low natural terminators mark the existing play boundary without implying doors or interiors.
local terminators = model("NaturalStreetTerminators", stage)
local stops = {
	{ "WestStop", Vector3.new(minX + 7, y + 3, minZ + 42), 0 },
	{ "EastStop", Vector3.new(maxX - 7, y + 3, maxZ - 42), math.pi / 2 },
	{ "SouthStop", Vector3.new(minX + 42, y + 3, maxZ - 7), 0 },
	{ "NorthStop", Vector3.new(maxX - 42, y + 3, minZ + 7), math.pi / 2 },
}
for _, stop in stops do
	local name, position, yaw = stop[1], stop[2], stop[3]
	local stopModel = model(name, terminators)
	part("Wall", Vector3.new(14, 6, 2.2), CFrame.new(position) * CFrame.Angles(0, yaw, 0), "brick", stopModel)
	part("Cap", Vector3.new(15, .55, 2.8), CFrame.new(position + Vector3.new(0, 3.25, 0)) * CFrame.Angles(0, yaw, 0), "cream", stopModel)
	part("Marker", Vector3.new(1.2, 1.2, 1.2), CFrame.new(position + Vector3.new(0, 4.1, 0)), "golden", stopModel, Enum.Material.Neon)
end

-- Two compressed skyline cues; narrow, noninteractive, and lower contrast than landmarks.
local skyline = model("CompressedSeattleSkyline", stage)
for i, spec in { { "TowerWest", minX - 30, minZ - 30, 52, 8 }, { "TowerEast", maxX + 30, maxZ + 30, 44, 7 } } do
	local name, x, z, height, width = spec[1], spec[2], spec[3], spec[4], spec[5]
	local tower = model(name, skyline)
	part("Body", Vector3.new(width, height, width), CFrame.new(x, y + height / 2 - 2, z), "forest", tower)
	part("Crown", Vector3.new(width + 2, 1.2, width + 2), CFrame.new(x, y + height - 1.4, z), "brick", tower)
	for window = 1, 3 do
		part("Window" .. window, Vector3.new(1.2, 3, .15), CFrame.new(x - width / 2 - .08, y + height * (window / 4), z - 1), "golden", tower, Enum.Material.Neon)
	end
end

assert(count <= 250, "Seattle boundary exceeds proposed 250 BasePart budget: " .. count)
local tokenCounts = {}
for _, object in stage:GetDescendants() do
	assert(not object:IsA("LuaSourceContainer"), "Scripts are forbidden in Seattle boundary")
	if object:IsA("BasePart") then
		local token = object:GetAttribute("PaletteToken")
		assert(palette[token] and object.Color == palette[token], "Palette mismatch: " .. object:GetFullName())
		assert(object.Anchored and not object.CanCollide and not object.CanTouch and not object.CanQuery, "Boundary must be noninteractive: " .. object:GetFullName())
		tokenCounts[token] = (tokenCounts[token] or 0) + 1
	end
end
stage:SetAttribute("PartCount", count)
for token, total in tokenCounts do stage:SetAttribute("PaletteCount_" .. token, total) end
local installed = context.SafeReplace("SeattleBoundary", function()
		return stage
	end)
	if installed then stage = installed end
	game:GetService("ChangeHistoryService"):SetWaypoint("MVP Seattle boundary staged")
	return {
		folder = stage,
		manifest = {
			Owner = "Task10",
			SourceBuilder = "SeattleBoundary",
			AnchorName = "WorldBoundsFromTask01",
			Footprint = "Derived outer facade ring; no playable interior",
			ApproachClearance = "Validated by Task13 against live routes",
			PartCount = count,
			WorldBounds = string.format("%.2f,%.2f,%.2f,%.2f", minX, maxX, minZ, maxZ),
			Segments = { "WestUDistrictBackdrop", "NorthHouseJasperBackdrop", "EastQuadBackdrop", "SouthArrivalPatioBackdrop", "NaturalStreetTerminators", "CompressedSeattleSkyline" },
			Status = "Live camera and route checks pending",
		},
	}
end
]=]},
{target=[=[ServerStorage/PhuongMVPTools/builders/NightLighting]=],kind=[=[ModuleScript]=],sha=[=[6fef0bb78720d6f71f9f47baa8e71738ea5f474685a0216c7b1dbee21e84c286]=],source=[=[-- Edit-mode builder. Requiring this module has no live-world side effects.
-- Canonical integration shape: return function(context).
local COLORS={golden=Color3.fromRGB(232,199,121),cream=Color3.fromRGB(245,240,228),forest=Color3.fromRGB(54,87,68),ink=Color3.fromRGB(38,56,46)}
local DEFINITIONS={
 Bedroom={anchor="GameplayBedroomArrival",offset=CFrame.new(0,7,0),range=24,brightness=1.35,shadows=true}, BedroomBedside={anchor="Q01Bed",offset=CFrame.new(2,3,1),range=14,brightness=.8,shadows=false}, Lobby={anchor="BirthdayLobbyQueue",offset=CFrame.new(0,6,0),range=20,brightness=1.1,shadows=true}, Craft={anchor="Q03FairCraft",offset=CFrame.new(0,5,0),range=18,brightness=1,shadows=false}, Vending={anchor="Q05UDistrictVending",offset=CFrame.new(0,5,0),range=16,brightness=1,shadows=false}, Food={anchor="Q06Serving",offset=CFrame.new(0,5,0),range=20,brightness=1.1,shadows=true}, Quad={anchor="Q04QuadReading",offset=CFrame.new(0,7,0),range=22,brightness=.8,shadows=false}, Patio={anchor="FinalePatio",offset=CFrame.new(0,6,0),range=22,brightness=1.1,shadows=true}, RouteBedroom={anchor="GameplayBedroomArrival",offset=CFrame.new(0,2,-10),range=12,brightness=.45,shadows=false}, RouteDistrict={anchor="Q03FairCraft",offset=CFrame.new(0,2,-10),range=12,brightness=.45,shadows=false}, RouteQuad={anchor="Q04QuadReading",offset=CFrame.new(0,2,-10),range=12,brightness=.45,shadows=false}, RoutePatio={anchor="FinalePatio",offset=CFrame.new(0,2,-10),range=12,brightness=.45,shadows=false},
}
local REQUIRED={"GameplayBedroomArrival","Q01Bed","BirthdayLobbyQueue","Q03FairCraft","Q05UDistrictVending","Q06Serving","Q04QuadReading","FinalePatio"}
local GLOBAL_KEYS={"ClockTime","Brightness","ExposureCompensation","GlobalShadows","Ambient","OutdoorAmbient","EnvironmentDiffuseScale","EnvironmentSpecularScale","ShadowSoftness"}
local function findAnchor(context,name) return context.Anchors[name] or context.Root:FindFirstChild(name,true) end
local function preflight(context)
 assert(context and context.Root and context.MVP and context.Anchors and context.Palette,"NightLighting context is required")
 for _,name in REQUIRED do local anchor=findAnchor(context,name); assert(anchor and anchor:IsA("BasePart"),"NightLighting missing required anchor: "..name); assert(anchor:GetAttribute("PlacementStatus")~="UNRESOLVED_LIVE_ANCHOR","NightLighting unresolved anchor: "..name) end
 for _,token in {"forest","sage","cream","wood","blossom","brick","golden","ink"} do assert(context.Palette[token],"NightLighting missing palette token: "..token) end
end
local function captureLighting(lighting) local result={}; for _,key in GLOBAL_KEYS do result[key]=lighting[key] end; return result end
local function restoreLighting(lighting,values) for key,value in values do lighting[key]=value end end
local function buildDetached(context,options)
 local folder=Instance.new("Folder"); folder.Name="NightLighting"; folder:SetAttribute("Owner","Task11"); folder:SetAttribute("MVPBuilder","NightLighting"); folder:SetAttribute("Source","roblox/mvp/builders/NightLighting.luau"); folder:SetAttribute("Status","Implementation delivered; Studio/device verification pending"); folder:SetAttribute("HighShadowBudget",12); folder:SetAttribute("LowShadowBudget",6)
 local created,shadowCount={},0
 for name,definition in DEFINITIONS do
  local anchor=findAnchor(context,definition.anchor); assert(anchor and anchor:IsA("BasePart"),"NightLighting anchor changed during build: "..definition.anchor)
  local part=Instance.new("Part"); part.Name=name; part.Size=Vector3.new(.25,.25,.25); part.Transparency=1; part.Anchored=true; part.CanCollide=false; part.CanTouch=false; part.CanQuery=false; part.CFrame=anchor.CFrame*definition.offset; part:SetAttribute("VerificationTicket","PCW-01"); part:SetAttribute("PaletteToken","golden"); part:SetAttribute("MVPBuilder","NightLighting"); part:SetAttribute("AnchorName",definition.anchor); part:SetAttribute("Footprint","0.25x0.25x0.25 invisible fixture"); part:SetAttribute("ApproachClearance","No collision; does not alter route"); part:SetAttribute("Owner","Task11"); part:SetAttribute("SourceBuilder","roblox/mvp/builders/NightLighting.luau"); part.Parent=folder
  local light=Instance.new("PointLight"); light.Name="WarmFixture"; light.Color=COLORS.golden; light.Brightness=options.lowGraphics and math.min(definition.brightness,1) or definition.brightness; light.Range=definition.range; light.Shadows=options.lowGraphics and false or definition.shadows; light.Parent=part
  table.insert(created,name); if light.Shadows then shadowCount+=1 end
 end
 folder:SetAttribute("CreatedFixtureCount",#created); folder:SetAttribute("ShadowFixtureCount",shadowCount); return folder,created,shadowCount
end
local function applyGlobals(lighting)
 lighting.ClockTime=22; lighting.Brightness=2; lighting.ExposureCompensation=.1; lighting.GlobalShadows=true; lighting.Ambient=COLORS.forest; lighting.OutdoorAmbient=COLORS.ink; lighting.EnvironmentDiffuseScale=.45; lighting.EnvironmentSpecularScale=.15; lighting.ShadowSoftness=.85
 local atmosphere=lighting:FindFirstChild("MVPNightAtmosphere"); local created=false; if not atmosphere then atmosphere=Instance.new("Atmosphere"); atmosphere.Name="MVPNightAtmosphere"; atmosphere.Parent=lighting; created=true end
 local original={Density=atmosphere.Density,Haze=atmosphere.Haze,Glare=atmosphere.Glare,Color=atmosphere.Color,Decay=atmosphere.Decay}; atmosphere.Density=.07; atmosphere.Haze=.08; atmosphere.Glare=0; atmosphere.Color=COLORS.cream; atmosphere.Decay=COLORS.forest
 return atmosphere,created,original
end
return function(context)
 preflight(context)
 local lighting=context.Lighting or game:GetService("Lighting"); local options=context.Options or {}; local folder,created,shadowCount=buildDetached(context,options); local originalLighting=captureLighting(lighting); local atmosphere,atmosphereCreated,originalAtmosphere=applyGlobals(lighting)
 local restored=false
 local function restoreOwned() if restored then return end; restored=true; restoreLighting(lighting,originalLighting); if atmosphere and atmosphere.Parent then if atmosphereCreated then atmosphere:Destroy() else for key,value in originalAtmosphere do atmosphere[key]=value end end end end
 local ok,installed=pcall(function() return context.SafeReplace("NightLighting",function() return folder end) end)
 if not ok then restoreOwned(); error(installed) end
 return {folder=installed,manifest={Owner="Task11",SourceBuilder="roblox/mvp/builders/NightLighting.luau",VerificationTicket="PCW-01",RequiredAnchors=REQUIRED,Created=created,ShadowCount=shadowCount,HighShadowBudget=12,LowShadowBudget=6,GlobalLightingProperties=GLOBAL_KEYS},Restore=restoreOwned}
end
]=]},
{target=[=[ServerStorage/PhuongMVPTools/builders/GrassDecoration]=],kind=[=[ModuleScript]=],sha=[=[ace88714c084e1661b120ac448575831f24ccc633ab9c8cba9c5c38cb32182f9]=],source=[=[-- Grass and outer-Quad decoration builder.
-- Requiring this ModuleScript is side-effect free. The integrator invokes the
-- returned function with the shared context in Studio Edit mode.
-- This builder never edits Paths or the existing QuadPlanting tree set.

return function(context)
    assert(context and context.Root and context.MVP and context.Anchors and context.Palette,
        "GrassDecoration context requires Root, MVP, Anchors and Palette")
    assert(context.SafeReplace, "GrassDecoration requires SafeReplace")
    local options = assert(context.Options, "GrassDecoration Options are required")
    assert(options.OuterQuadBounds, "Task01 OuterQuadBounds anchor is required")
    assert(options.Keepouts, "Task01 activity/facade Keepouts are required")
    local root = context.Root
    local mvp = context.MVP
    local anchors = context.Anchors
    local palette = context.Palette
    for _, name in {"Q03FairCraft", "Q04QuadReading", "Q05UDistrictVending", "Q06FOBCounter", "Q06AladdinsCounter", "FinalePatio", "JasperFetchYard", "GameplayBedroomArrival"} do
        local anchor = anchors[name]
        assert(anchor, "Required station/route anchor missing: " .. name)
        assert(anchor:GetAttribute("PlacementStatus") ~= "UNRESOLVED_LIVE_ANCHOR", "Unresolved anchor: " .. name)
    end
    local RunService = game:GetService("RunService")
    assert(not RunService:IsRunning(), "GrassDecoration must run in Studio Edit mode")
    local paths = assert(root:FindFirstChild("Paths"), "Existing Quad Paths are required")
    local landscape = assert(root:FindFirstChild("Landscape"), "Existing Landscape is required")
    local lawn = assert(landscape:FindFirstChild("QuadGround"), "Existing QuadGround is required")
    assert(lawn:IsA("BasePart"), "QuadGround must be a BasePart")

    local V, CF = Vector3.new, CFrame.new
    local expectedPalette = {

    forest = Color3.fromHex("365744"),
    sage = Color3.fromHex("A8B995"),
    cream = Color3.fromHex("F5F0E4"),
    wood = Color3.fromHex("95674B"),
    blossom = Color3.fromHex("E8B7C6"),
    brick = Color3.fromHex("B66C68"),
    golden = Color3.fromHex("E8C779"),
    ink = Color3.fromHex("26382E"),
    }
    for token, color in expectedPalette do
        assert(palette[token] == color, "Shared palette mismatch for " .. token)
    end

local function sourcePartCount(instance)
    local count = 0
    for _, object in instance:GetDescendants() do
        if object:IsA("BasePart") then count += 1 end
    end
    return count
end

local function routeDefinitions()
    local metadata = paths:FindFirstChild("RouteDefinitions")
    assert(metadata, "RouteDefinitions are required; no guessed routes are allowed")
    local result = {}
    for _, definition in metadata:GetChildren() do
        local from = definition:GetAttribute("From")
        local to = definition:GetAttribute("To")
        local width = definition:GetAttribute("Width")
        if typeof(from) == "Vector3" and typeof(to) == "Vector3" and typeof(width) == "number" then
            table.insert(result, {from = from, to = to, width = width, name = definition.Name})
        end
    end
    assert(#result > 0, "No usable route definitions found")
    return result
end

local routes = routeDefinitions()
local baseline = {
    PathsParts = sourcePartCount(paths),
    QuadGroundCFrame = lawn.CFrame,
    QuadGroundSize = lawn.Size,
}

local folder = Instance.new("Folder")
folder.Name = "MVPGrassDecoration"
folder:SetAttribute("Source", "roblox/mvp/builders/GrassDecoration.luau")
folder:SetAttribute("VerificationTicket", "PCW-06/MAP-03")
folder:SetAttribute("Status", "Source authored; Studio install and visual verification pending")
folder:SetAttribute("Owns", "Grass edge clumps and outer Quad tree silhouettes only")
folder:SetAttribute("MaxBaseParts", 250)
folder:SetAttribute("TexturePolicy", "No external textures; no community-tree exception")

local partCount = 0
local function part(name, size, placement, token, parent, material)
    assert(palette[token], "Unknown palette token: " .. tostring(token))
    local object = Instance.new("Part")
    object.Name = name
    object.Size = size
    object.CFrame = placement
    object.Color = palette[token]
    object:SetAttribute("PaletteToken", token)
    object:SetAttribute("DecorationOwner", "GrassDecoration12")
    object:SetAttribute("VerificationTicket", "PCW-06/MAP-03")
    object:SetAttribute("MVPBuilder", "GrassDecoration")
    object:SetAttribute("AnchorName", "OuterQuadBounds")
    object:SetAttribute("Footprint", "Noninteractive grass/tree decoration")
    object:SetAttribute("ApproachClearance", "RouteDefinitions plus Task01 Keepouts")
    object:SetAttribute("Owner", "Task12")
    object:SetAttribute("SourceBuilder", "roblox/mvp/builders/GrassDecoration.luau")
    object.Material = material or Enum.Material.SmoothPlastic
    object.Anchored = true
    object.CanCollide = false
    object.CanTouch = false
    object.CanQuery = false
    object.CastShadow = false
    object.TopSurface = Enum.SurfaceType.Smooth
    object.BottomSurface = Enum.SurfaceType.Smooth
    object.Parent = parent
    partCount += 1
    return object
end

local function sphere(name, size, placement, token, parent)
    local object = part(name, size, placement, token, parent)
    local mesh = Instance.new("SpecialMesh")
    mesh.Name = "NativeSphere"
    mesh.MeshType = Enum.MeshType.Sphere
    mesh.Parent = object
    return object
end

local function distanceToRoute(point, route)
    local a = Vector2.new(route.from.X, route.from.Z)
    local b = Vector2.new(route.to.X, route.to.Z)
    local direction = b - a
    local t = math.clamp((point - a):Dot(direction) / direction:Dot(direction), 0, 1)
    return (point - (a + direction * t)).Magnitude
end

local function routeClear(position, radius, margin)
    for _, route in routes do
        if distanceToRoute(Vector2.new(position.X, position.Z), route) - radius < route.width / 2 + margin then
            return false
        end
    end
    return true
end

local function grassClump(name, position, scale, variant, parent)
    local model = Instance.new("Model")
    model.Name = name
    model:SetAttribute("DetailType", "GrassClump")
    model.Parent = parent
    local yaw = variant * .73
    for index = 1, 3 do
        local angle = yaw + (index - 2) * .42
        local height = (.28 + (index % 2) * .09) * scale
        sphere("Blade" .. index, V(.16 * scale, height, .34 * scale),
            CF(position + V(math.cos(angle) * .16 * scale, height / 2, math.sin(angle) * .16 * scale))
                * CFrame.Angles(math.sin(angle) * .20, angle, math.cos(angle) * .08),
            index == 2 and "forest" or "sage", model)
    end
    return model
end

local function outerTree(name, position, height, variant, parent)
    local tree = Instance.new("Model")
    tree.Name = name
    tree:SetAttribute("DetailType", "OuterQuadTree")
    tree:SetAttribute("AnchorRule", "Measured outside Quad perimeter; provisional until Task01 live anchors")
    tree.Parent = parent
    local trunkHeight = height * .58
    part("Trunk", V(height * .075, trunkHeight, height * .075),
        CF(position + V(0, trunkHeight / 2, 0)) * CFrame.Angles(0, variant * .3, .025), "wood", tree, Enum.Material.Wood)
    local crown = Instance.new("Model")
    crown.Name = "UntexturedCrown"
    crown.Parent = tree
    for index, offset in {{0, 0, 0}, {-.34, .05, .06}, {.34, .08, -.05}} do
        sphere("Canopy" .. index, V(height * .31, height * .24, height * .31),
            CF(position + V(offset[1] * height, trunkHeight + height * (.14 + offset[2]), offset[3] * height)),
            index == 2 and "blossom" or "blossom", crown)
    end
    tree:SetAttribute("TextureID", "")
    return tree
end

-- Candidate positions are deliberately relative to the current QuadGround bounds.
-- The integrator must replace/confirm them from Task01 anchors before installation.
local halfX, halfZ = lawn.Size.X / 2, lawn.Size.Z / 2
local edgeY = lawn.Position.Y + lawn.Size.Y / 2
local bounds = options.OuterQuadBounds
assert(bounds:IsA("BasePart"), "OuterQuadBounds must be a measured BasePart anchor")
local candidates = {
    {"NorthWest", bounds.Position + V(-bounds.Size.X / 2, 0, -bounds.Size.Z / 2), 15, 1},
    {"NorthEast", bounds.Position + V(bounds.Size.X / 2, 0, -bounds.Size.Z / 2), 14, 2},
    {"SouthWest", bounds.Position + V(-bounds.Size.X / 2, 0, bounds.Size.Z / 2), 16, 3},
    {"SouthEast", bounds.Position + V(bounds.Size.X / 2, 0, bounds.Size.Z / 2), 15, 4},
}

local trees = Instance.new("Folder")
trees.Name = "OuterQuadTrees"
trees.Parent = folder
for _, candidate in candidates do
    local name, position, height, variant = table.unpack(candidate)
    if routeClear(position, height * .22, 1.5) and not options.Keepouts[name] then
        outerTree("Tree_" .. name, V(position.X, edgeY, position.Z), height, variant, trees)
    end
end

local grass = Instance.new("Folder")
grass.Name = "GrassClumps"
grass.Parent = folder
local offsets = {{-.30, -.22}, {0, .16}, {.28, -.06}, {-.12, .31}}
for index, factor in ipairs(offsets) do
    local position = lawn.Position + V(factor[1] * halfX, lawn.Size.Y / 2, factor[2] * halfZ)
    if routeClear(position, .55, 1.5) and not options.Keepouts["Grass_" .. index] then
        grassClump("Grass_" .. index, V(position.X, edgeY, position.Z), .9 + (index % 2) * .15, index, grass)
    end
end

assert(partCount <= 250, "GrassDecoration exceeds 250 BaseParts: " .. partCount)
assert(sourcePartCount(paths) == baseline.PathsParts, "Existing route geometry changed during decoration build")
assert(lawn.CFrame == baseline.QuadGroundCFrame and lawn.Size == baseline.QuadGroundSize,
    "Existing QuadGround changed during decoration build")
folder:SetAttribute("PartCount", partCount)
folder:SetAttribute("RouteCountChecked", #routes)
folder:SetAttribute("BaselinePathsParts", baseline.PathsParts)
folder:SetAttribute("BaselineQuadGroundSize", tostring(baseline.QuadGroundSize))
folder:SetAttribute("BaselineQuadGroundCFrame", tostring(baseline.QuadGroundCFrame))

local installedFolder = context.SafeReplace("GrassDecoration", function()
    return folder
end)
return {
    folder = installedFolder,
    manifest = {
        name = "GrassDecoration",
        partCount = partCount,
        routeCount = #routes,
        baselinePathsParts = baseline.PathsParts,
        baselineQuadGroundSize = tostring(baseline.QuadGroundSize),
        baselineQuadGroundCFrame = tostring(baseline.QuadGroundCFrame),
        sourceBuilder = "roblox/mvp/builders/GrassDecoration.luau",
        preserved = {"Paths", "Landscape.QuadGround", "QuadPlanting"},
    },
}
end
]=]},
}
local ALLOWED={ServerScriptService="PhuongMVP",ReplicatedStorage="PhuongMVP",ServerStorage="PhuongMVPTools",StarterPlayer="StarterPlayerScripts/PhuongMVPClient"}
local function mount(e)
 local p={};for x in string.gmatch(e.target,"[^/]+") do table.insert(p,x) end;local service=ALLOWED[p[1]];assert(service,"disallowed root service");assert(string.sub(e.target,1,#p[1]+1+#service)==p[1].."/"..service,"disallowed mount prefix")
 local par=game:GetService(p[1]);table.remove(p,1);local first=p[1];if p[1]=="StarterPlayerScripts" then par=par:FindFirstChild("StarterPlayerScripts");assert(par,"StarterPlayerScripts missing");table.remove(p,1);assert(p[1]=="PhuongMVPClient","disallowed client mount") end
 for i=1,#p-1 do local n=par:FindFirstChild(p[i]);if n then assert(n:IsA("Folder") and n:GetAttribute("PhuongMVPImportOwned"),"unowned intermediate folder") else n=Instance.new("Folder");n.Name=p[i];n:SetAttribute("PhuongMVPImportOwned",true);n.Parent=par end;par=n end
 local o=par:FindFirstChild(p[#p]);if o then assert(o:IsA(e.kind) and o:GetAttribute("PhuongMVPImportOwned"),"unowned source collision") else o=Instance.new(e.kind);o.Name=p[#p];o:SetAttribute("PhuongMVPImportOwned",true);o.Parent=par end;o.Source=HttpService:JSONDecode(HttpService:JSONEncode(e.source));assert(o.Source==e.source,"Source readback mismatch");o:SetAttribute("PhuongMVPSourceSHA256",e.sha);if o:IsA("Script") or o:IsA("LocalScript") then o.Enabled=false end
end
for _,e in ipairs(entries) do mount(e) end
print("mounted exact import chunk")
