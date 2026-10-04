local Players = game:GetService("Players")
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
 if result.ok~=false then CozyAudio.Accepted(r,result) end
 return result.ok~=false,result.code or "Accepted",{receipt=result.receipt,view=result.view or view(activities[r.activityId],p),result=result,errorText=result.ok==false and result.message or nil}
end

hostService=HostService.new(session,{activities=activities,cake=cake,clock=now,runtime={
 isWorld=function(actor)
  local p=Players:GetPlayerByUserId(actor)
  return p~=nil and p:GetAttribute("BirthdayLocation")=="World"
 end,
 newRoundId=function(id) roundSerial+=1; return "round:"..id..":"..roundSerial end,
 setRoundId=function(id,roundId) currentRounds[id]=roundId end,
 travel=function(actor,destination)
  local p=Players:GetPlayerByUserId(actor)
  local c=character(p)
  local target=destination=="Bedroom" and "GameplayBedroomArrival" or destination=="Patio" and "FinalePatio" or nil
  if not c or not target or not anchor(target) then return false end
  for _,a in pairs(activities) do if a.ReleaseActor then pcall(a.ReleaseActor,a,actor) end end
  openedActivities[actor]=nil
  local humanoid=c:FindFirstChildOfClass("Humanoid")
  if humanoid then humanoid.Sit=false; humanoid:ChangeState(Enum.HumanoidStateType.GettingUp) end
  return place(p,target)
 end,
}})

action.OnServerEvent:Connect(function(p,r)
 if type(r)~="table" or type(r.kind)~="string" then return send(p,r,false,"BadPayload") end
 if r.actorUserId~=nil or r.player~=nil then return send(p,r,false,"ClientAuthorityRejected") end
 if r.kind~="Host" and r.kind~="RequestSnapshot" and r.kind~="RequestJournal" and type(r.actionId)=="string" and hostService.results[r.actionId] then
  return send(p,r,false,"HostActionUsed",{errorText="That request was already used by host controls. Choose a fresh action."})
 end
 if r.kind=="Host" then
  r.actorUserId=uid(p)
  advanceCake()
  local called,result=pcall(hostService.Apply,hostService,r)
  if not called then
   warn("PCW-24 host request failed",result)
   return send(p,r,false,"HostUnavailable",{errorText="Host controls could not refresh. Reopen them to review the current state."})
  end
  advanceCake()
  local extra={hostResult=result}
  if not result.ok then extra.errorText=result.message end
  send(p,r,result.ok==true,result.code,extra)
  -- Failure may include a safely committed partial recovery; refresh all
  -- recipients so their current round, world state and cake remain coherent.
  if result.ok or result.code=="HostRecoveryFailed" or broadcastFinaleRevision~=cake.revision then broadcast() end
  return
 end
 if r.kind=="ActivityAction" then local ok,c,e=apply(p,r); send(p,r,ok,c,e); if ok then broadcast() end; return end
 if r.kind=="RequestView" then
  local req,err=canonical(p,r); if not req then return send(p,r,false,err) end
  if req.replay~=nil and type(req.replay)~="boolean" then return send(p,req,false,"BadAction") end
  if req.replay and (not currentRounds[req.activityId] or not view(activities[req.activityId],p).canReplay) then return send(p,req,false,"ReplayUnavailable") end
  local ok,c,e=openRound(p,req)
  if ok then
   local previous = openedActivities[p.UserId]
   if previous and previous~=req.activityId then release(p,previous) end
   openedActivities[p.UserId]=req.activityId
  end
  send(p,req,ok,c,e); if ok then broadcast() end; return
 end
 if r.kind=="CloseActivity" then
  if r.sessionId~=sessionId or type(r.activityId)~="string" or type(r.actionId)~="string" then return send(p,r,false,"BadAction") end
  release(p,r.activityId,r.roundId)
  if openedActivities[p.UserId]==r.activityId and (r.roundId==nil or r.roundId==currentRounds[r.activityId]) then openedActivities[p.UserId]=nil end
  send(p,r,true,"Released"); broadcast(); return
 end
 if r.kind=="RequestJournal" then return send(p,r,true,"Journal",{journal=snapshot(p)}) end
 if r.kind=="RequestSnapshot" then return send(p,r,true,"Snapshot") end
 if r.kind=="Cake" then
  -- RecoverStart/RecoverCut are deliberately absent: PCW-24 owns explicit
  -- authenticated host override. All normal actions use one canonical path.
  r.actorUserId=uid(p)
  local called,result=pcall(cake.Apply,cake,r)
  if not called then
   warn("PCW-23 cake request failed",result)
   return send(p,r,false,"CakeRejected",{errorText="The cake choice could not be saved. Reopen the table and try again."})
  end
  advanceCake()
  local extra={cake=cake:GetState(uid(p)),result=result,receipt=result.receipt}
  if not result.ok then extra.errorText=result.message end
  send(p,r,result.ok==true,result.code,extra)
  if result.ok then broadcast() end
  return
 end
 send(p,r,false,"UnsupportedAction")
end)

local function releaseAll(p)
 openedActivities[p.UserId]=nil
 if hostService then hostService:ReleaseActor(p.UserId) end
 for _,a in pairs(activities) do if a.ReleaseActor then pcall(a.ReleaseActor,a,p.UserId) end end
end
local function bindPlayer(p)
 session:SetPresence(p.UserId,true); p:SetAttribute("MVPSessionId",sessionId)
 playerConnections[p.UserId]={
  p:GetAttributeChangedSignal("BirthdayLocation"):Connect(function()
   if p:GetAttribute("BirthdayLocation")~="World" then releaseAll(p) end
   broadcast()
  end),
  p.CharacterRemoving:Connect(function() releaseAll(p); broadcast() end),
 }
 send(p,{kind="RequestSnapshot"},true,"Snapshot")
end
Players.PlayerAdded:Connect(bindPlayer)
Players.PlayerRemoving:Connect(function(p)
 session:SetPresence(p.UserId,false); releaseAll(p)
 for _,connection in ipairs(playerConnections[p.UserId] or {}) do connection:Disconnect() end
 playerConnections[p.UserId]=nil; broadcast()
end)

local expiryElapsed=0
local seenQ01Expiry=0
local seenQ03Expiry=0
local seenQ06Expiry=0
local seenFoodVenues={}
local seenJasperVenues={}
RunService.Heartbeat:Connect(function(dt)
 expiryElapsed+=dt; if expiryElapsed<1 then return end; expiryElapsed=0
 local changed=advanceCake()
 -- A private snapshot may have advanced the seat/timer between heartbeats.
 -- Its new phase still has to reach every other participant.
 if broadcastFinaleRevision~=cake.revision then changed=true end
 local q01=activities.Q01
 if q01 then
  q01:ExpireReservations(now())
  -- GetView can expire a hold before this tick; its revision still reaches
  -- every open recipient instead of leaving another helper seeing In use.
  if q01.expiryRevision~=seenQ01Expiry then seenQ01Expiry=q01.expiryRevision; changed=true end
 end
 local q03=activities.Q03
 if q03 then
  q03:ExpireReservations()
  if q03.expiryRevision~=seenQ03Expiry then seenQ03Expiry=q03.expiryRevision; changed=true end
 end
 for _,p in ipairs(Players:GetPlayers()) do
  local venue=openedActivities[p.UserId]=="Q02" and (world.jasperVenue(p.UserId) or "away") or nil
  if venue~=seenJasperVenues[p.UserId] then seenJasperVenues[p.UserId]=venue; changed=true end
 end
 for actor in pairs(seenJasperVenues) do if not Players:GetPlayerByUserId(actor) then seenJasperVenues[actor]=nil end end
 local q06=activities.Q06
 if q06 then
  q06:ExpireReservations(now())
  if q06.expiryRevision~=seenQ06Expiry then seenQ06Expiry=q06.expiryRevision; changed=true end
  for _,p in ipairs(Players:GetPlayers()) do
   local venue=openedActivities[p.UserId]=="Q06" and (q06:GetVenue(p.UserId) or "away") or nil
   if venue~=seenFoodVenues[p.UserId] then seenFoodVenues[p.UserId]=venue; changed=true end
  end
  for actor in pairs(seenFoodVenues) do if not Players:GetPlayerByUserId(actor) then seenFoodVenues[actor]=nil end end
 end
 if changed then broadcast() end
end)
for id,name in pairs(station) do installPrompt(id,anchor(name)) end
installPrompt("Q02",anchor("JasperFetchYard")); installPrompt("Q04",anchor("Q04BedroomKindle")); installPrompt("Q06",anchor("Q06AladdinsCounter")); installPrompt("Q06",anchor("Q06Serving")); installPrompt("Cake",anchor("FinalePatio"))
installPrompt("Q03",anchor("Q03BedroomDisplay"))
for _,p in ipairs(Players:GetPlayers()) do bindPlayer(p) end
print("Phuong MVP server integration active",sessionId,"missing anchors:",table.concat(missingAnchors,","))
for name,defect in pairs(activityErrors) do warn("Activity "..name.." unavailable: "..defect) end
script.Destroying:Connect(function() if finaleFeedback then finaleFeedback:Destroy() end end)
