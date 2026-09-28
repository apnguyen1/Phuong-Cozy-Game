local Players = game:GetService("Players")
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
local arrivalFolder = mvp:WaitForChild("Anchors"):WaitForChild("BedroomArrivalSlots")
local activities, activityErrors = {}, {}
local arrivalSlots, arrivalByUser, currentRounds = {}, {}, {}
local arrivalCount = 0
local roundSerial = 0
local queueBroadcastKey = ""
local queueScanAt = 0
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
 request=type(request)=="table" and request or {}
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
-- Prompts are owned by this runtime so a saved place cannot retain stale handlers.
local promptLabels={Q01="Make the bed",Q02="Visit Jasper",Q03="Craft a keepsake",Q04="Read together",Q05="Make a Labubu wish",Q06="Share a food memory",Cake="Birthday cake"}
local promptObjects={Q01="Everything Tucked In",Q02="Jasper's Favorite Things",Q03="A Tiny World of Her Own",Q04="One More Chapter",Q05="A Labubu Wish",Q06="Something Delicious",Cake="Birthday cake"}
local function installPrompt(id, instance)
 if not instance then return end
 local host=instance:IsA("BasePart") and instance or instance:FindFirstChildWhichIsA("BasePart",true); if not host then return end
 local prompt=host:FindFirstChild("MVPProximityPrompt") or Instance.new("ProximityPrompt")
 prompt.Name="MVPProximityPrompt"; prompt.ActionText=promptLabels[id] or id; prompt.ObjectText=promptObjects[id] or id; prompt.KeyboardKeyCode=Enum.KeyCode.E
 prompt.HoldDuration=0; prompt.MaxActivationDistance=12; prompt.RequiresLineOfSight=false; prompt:SetAttribute("ActivityId",id); prompt.Parent=host
end
local world={isPresent=function(id) return session:IsPresent(id) end,presentUserIds=session.presence,anchors=anchors}
construct("Q01",require(script.Parent.activities.Q01),{session=session,clock=now,world=world})
construct("Q02",require(script.Parent.activities.Q02),{session=session,clock=now,world=world})
construct("Q03",require(script.Parent.activities.Q03),{session=session,clock=now,context=world})
construct("Q04",require(script.Parent.activities.Q04),{session=session,clock=now,context=world})
construct("Q05",require(script.Parent.activities.Q05),{session=session,clock=now,context=world,presentUserIds=session.presence})
construct("Q06",require(script.Parent.activities.Q06),{session=session,clock=now,actor=world.isPresent,context=world})
local transfer
if RunService:IsStudio() then
 transfer=LocalPartyTransferAdapter.new(function(players)
  local checked={}; for _,p in ipairs(players) do local e=arrivalByUser[p.UserId]; local c=character(p); if not e or not e.part or not c then error("arrival slot or character not ready") end; table.insert(checked,{player=p,entry=e,character=c}) end
  for _,item in ipairs(checked) do item.character:PivotTo(item.entry.part.CFrame+Vector3.new(0,3,0)); item.entry.transferred=true; item.player:SetAttribute("MVPArrivalStatus","Transferred") end
  broadcast(); return true
 end)
else
 local placeId=game:GetAttribute("GameplayPlaceId") or Config.GameplayPlaceId
 if placeId and placeId ~= 0 then transfer=TeleportAdapter.new({GameplayPlaceId=placeId},{}) else warn("GameplayPlaceId is unconfigured; production transfer is disabled") end
end
local function transferQueue(roster)
 if not roster then return end
 local players={}; for _,id in ipairs(roster.members) do local p=Players:GetPlayerByUserId(id); local e=arrivalByUser[id]; if not p or not e or not e.part or not e.ready or not character(p) then queue:FailTransfer(); return end; table.insert(players,p) end
 if not queue:BeginTransfer() then return end
 if not transfer then queue:FailTransfer(); return end
 local ok,result=pcall(transfer.Transfer,transfer,players,roster); if ok and result then queue:CompleteTransfer() else queue:FailTransfer() end
end
local station={Q01="Q01Bed",Q02="JasperBedroomStart",Q03="Q03FairCraft",Q04="Q04QuadReading",Q05="Q05UDistrictVending",Q06="Q06FOBCounter"}
local function nearActivity(p,r)
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
local function queueInside(p)
 local _,hrp=character(p); local floor=mvp:FindFirstChild("QueueFloor",true) or mvp:FindFirstChild("QueueFloor")
 if not hrp or not floor or not floor:IsA("BasePart") then return false end
 local localPos=floor.CFrame:PointToObjectSpace(hrp.Position); local half=floor.Size*.5
 return math.abs(localPos.X)<=half.X and math.abs(localPos.Z)<=half.Z and localPos.Y>=-4 and localPos.Y<=8
end
local function updateQueueSign(q)
 local sign=mvp:FindFirstChild("QueueSign",true); if not sign then return end
 local gui=sign:FindFirstChildWhichIsA("SurfaceGui",true) or Instance.new("SurfaceGui"); gui.Name="QueueSignSurface"; gui.Parent=sign
 local label=gui:FindFirstChild("QueueText") or Instance.new("TextLabel"); label.Name="QueueText"; label.Size=UDim2.fromScale(1,1); label.BackgroundTransparency=1; label.TextColor3=Color3.fromRGB(38,56,46); label.TextScaled=true; label.Parent=gui
 label.Text=string.format("Birthday group  %d/10\n%s",q.count,q.remaining and ("Shared wait: "..math.ceil(q.remaining).."s") or "Step inside to join")
end
local function canonical(p,r)
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
 if type(r.roundId)~="string" or type(r.stepId)~="string" then return false,"BadAction" end
 if not nearActivity(p,r) then return false,"TooFar" end
 local ok,result=pcall(activities[r.activityId].Apply,activities[r.activityId],req)
 if not ok then return false,"ActionRejected",{errorText=tostring(result),view=view(activities[r.activityId],p),failedResult=result} end
 if type(result)~="table" then return false,"ActionRejected",{errorText="Invalid activity result"} end
 return result.ok~=false,result.code or "Accepted",{receipt=result.receipt,view=result.view or view(activities[r.activityId],p),result=result}
end
action.OnServerEvent:Connect(function(p,r)
 if type(r)~="table" or type(r.kind)~="string" then return send(p,r,false,"BadPayload") end
 if r.actorUserId~=nil or r.player~=nil then return send(p,r,false,"ClientAuthorityRejected") end
 if r.kind=="ActivityAction" then local ok,c,e=apply(p,r); send(p,r,ok,c,e); if ok then broadcast() end; return end
 if r.kind=="RequestView" then local req,err=canonical(p,r); if not req then return send(p,r,false,err) end; if req.replay and (not currentRounds[req.activityId] or not view(activities[req.activityId],p).canReplay) then return send(p,req,false,"ReplayUnavailable") end; local ok,c,e=openRound(p,req); return send(p,req,ok,c,e) end
 if r.kind=="CloseActivity" then release(p,r.activityId,r.roundId); return send(p,r,true,"Released") end
 if r.kind=="RequestJournal" then return send(p,r,true,"Journal",{journal=snapshot()}) end
 if r.kind=="RequestSnapshot" then return send(p,r,true,"Snapshot") end
 if r.kind=="QueueJoin" then if not queueInside(p) then return send(p,r,false,"TooFar") end; local ok,c=queue:Join(uid(p),now()); send(p,r,ok,c); broadcast(); return end
 if r.kind=="QueueLeave" then local ok,c=queue:Leave(uid(p)); send(p,r,ok,c); broadcast(); return end
 if r.kind=="Cake" then if type(r.sessionId)~="string" or r.sessionId~=sessionId or type(r.actionId)~="string" or r.actionId=="" then return send(p,r,false,"BadCakeRequest") end; if not session:IsPresent(uid(p)) then return send(p,r,false,"NotPresent") end; if not near(p,"FinalePatio",28) then return send(p,r,false,"TooFar") end; local allowed={Invite=true,CancelInvite=true,Cut=true,Eat=true}; if not allowed[r.action] then return send(p,r,false,"UnsupportedCakeAction") end; local ok,result=pcall(cake[r.action],cake,uid(p)); send(p,r,ok,ok and (r.action.."Accepted") or "CakeRejected",{cake=cake:GetState(),result=result,errorText=ok and nil or tostring(result)}); if ok then broadcast() end; return end
 send(p,r,false,"UnsupportedAction")
end)
local function assign(p)
 if arrivalByUser[p.UserId] then return end; if arrivalCount>=10 then p:SetAttribute("MVPArrivalStatus","Full"); return end
 local folder=arrivalFolder; local target
 if folder then for _,v in ipairs(folder:GetChildren()) do if v:IsA("BasePart") and not arrivalSlots[v] then target=v; break end end end
 if not target then p:SetAttribute("MVPArrivalStatus","NotReady"); return end
 arrivalSlots[target]=p; arrivalByUser[p.UserId]={part=target,ready=false,transferred=false}; arrivalCount += 1; p:SetAttribute("MVPArrivalSlot",target.Name); p:SetAttribute("MVPArrivalStatus","ReadyPendingCharacter")
 local function ready() local e=arrivalByUser[p.UserId]; local c=character(p); if e and c then e.ready=true; if e.transferred then c:PivotTo(e.part.CFrame+Vector3.new(0,3,0)) end; p:SetAttribute("MVPArrivalStatus",e.transferred and "Transferred" or "Ready") end end
 p.CharacterAdded:Connect(function() task.spawn(function() for _=1,20 do if character(p) then ready(); return end; task.wait(.1) end end) end)
 p.CharacterRemoving:Connect(function() local e=arrivalByUser[p.UserId]; if e then e.ready=false end end); ready()
end
Players.PlayerAdded:Connect(function(p) session:SetPresence(p.UserId,true); p:SetAttribute("MVPSessionId",sessionId); assign(p); send(p,{kind="RequestSnapshot"},true,"Snapshot") end)
Players.PlayerRemoving:Connect(function(p) session:SetPresence(p.UserId,false); queue:Leave(p.UserId); local e=arrivalByUser[p.UserId]; if e then arrivalSlots[e.part]=nil; arrivalByUser[p.UserId]=nil; arrivalCount -= 1 end; for _,a in pairs(activities) do if a.ReleaseActor then pcall(a.ReleaseActor,a,p.UserId) end end; broadcast() end)
RunService.Heartbeat:Connect(function()
 if now()>=queueScanAt then queueScanAt=now()+.2; for _,p in ipairs(Players:GetPlayers()) do local e=arrivalByUser[p.UserId]; if not (e and e.transferred) then if queueInside(p) then queue:Join(p.UserId,now()) elseif queue.state=="Open" or queue.state=="Shortened" then queue:Leave(p.UserId) end end end end
 local q=queue:Snapshot(); local key=string.format("%s:%d:%d:%s",q.state,q.count,math.floor(q.remaining or -1),table.concat(q.members,",")); if key~=queueBroadcastKey then queueBroadcastKey=key; updateQueueSign(q); broadcast() end
 local expired,_,roster=queue:Tick(now()); if expired then transferQueue(roster) end
end)
for id,name in pairs(station) do installPrompt(id,anchor(name)) end
installPrompt("Q02",anchor("JasperFetchYard")); installPrompt("Q04",anchor("Q04BedroomKindle")); installPrompt("Q06",anchor("Q06AladdinsCounter")); installPrompt("Q06",anchor("Q06Serving")); installPrompt("Cake",anchor("FinalePatio"))
installPrompt("Q03",anchor("Q03BedroomDisplay"))
local legacyPortal=workspace:FindFirstChild("BirthdayLobby",true)
legacyPortal=legacyPortal and legacyPortal:FindFirstChild("Portal",true)
legacyPortal=legacyPortal and legacyPortal:FindFirstChild("PortalPrompt")
legacyPortal=legacyPortal and legacyPortal:FindFirstChild("EnterWorld")
if legacyPortal and legacyPortal:IsA("ProximityPrompt") then legacyPortal.Enabled=false end
for _,p in ipairs(Players:GetPlayers()) do session:SetPresence(p.UserId,true); p:SetAttribute("MVPSessionId",sessionId); assign(p); send(p,{kind="RequestSnapshot"},true,"Snapshot") end
print("Phuong MVP server integration active",sessionId,"missing anchors:",table.concat(missingAnchors,","))
for name,defect in pairs(activityErrors) do warn("Activity "..name.." unavailable: "..defect) end
