-- Temporary Studio-only eight-client test. Remove server/client helpers before saving.
local Test=game:GetService("StudioTestService")
local testMode=Test:GetTestArgs()
if not game:GetService("RunService"):IsStudio() or (testMode~="Draft02Party" and testMode~="Draft02PartyCirculation" and testMode~="Draft02PartyPromptCirculation") then return end
local Players=game:GetService("Players")
local RS=game:GetService("ReplicatedStorage")
local Run=game:GetService("RunService")
local world=workspace:WaitForChild("CozyWorld_Draft01")
local rpc=Instance.new("RemoteFunction");rpc.Name="Draft02PartyRPC";rpc.Parent=RS
local event=Instance.new("RemoteEvent");event.Name="Draft02PartyEvents";event.Parent=RS
local readyClients={}
event.OnServerEvent:Connect(function(p,v) if v.kind=="client-ready" then readyClients[p]=true end end)
local report={schema_version=1,test="Draft02Party",engine="Studio actual eight-client multiplayer",checks={},events={},snapshots={},observations={},methods={setup="Test-only character placement for seating, prompt access and bedroom starts. Production scripts unchanged; countdown remains 60 seconds.",movement="Bedroom paths use client Humanoid MoveTo at WalkSpeed16 with unchanged collisions; no intermediate teleporting.",input="Programmatic engine prompt hold API; optional official VirtualInput mouse orbit. Physical touch and human usability are not claimed."}}
report.testMode=testMode
local function check(name,pass,detail) table.insert(report.checks,{name=name,passed=pass==true,details=detail}) end
local function await(predicate,seconds)
 local untilTime=os.clock()+seconds
 repeat local v=predicate();if v then return v end;task.wait(.1) until os.clock()>untilTime
 error("Party test condition timed out after "..seconds.."s")
end
local function ready(p) return p.Character and p.Character:GetAttribute("BirthdayPlacementReady")==true and p.Character:FindFirstChild("HumanoidRootPart") end
local function observe(p)
 p:GetAttributeChangedSignal("BirthdayLocation"):Connect(function() table.insert(report.events,{userId=p.UserId,at=workspace:GetServerTimeNow(),kind="location",location=p:GetAttribute("BirthdayLocation")}) end)
 p:GetAttributeChangedSignal("LobbyCountdownEnd"):Connect(function() table.insert(report.events,{userId=p.UserId,at=workspace:GetServerTimeNow(),kind="deadline",deadline=p:GetAttribute("LobbyCountdownEnd")}) end)
end
Players.PlayerAdded:Connect(observe);for _,p in Players:GetPlayers() do observe(p) end
world.BirthdayLobby.Portal.PortalPrompt.EnterWorld.Triggered:Connect(function(p) table.insert(report.events,{userId=p.UserId,at=workspace:GetServerTimeNow(),kind="engine-prompt-triggered"}) end)
local function vec(v) return {v.X,v.Y,v.Z} end
local function snapshot(label,people)
 local out={label=label,at=workspace:GetServerTimeNow(),players={}}
 for _,p in people do
  local h=p.Character and p.Character:FindFirstChildOfClass("Humanoid")
  table.insert(out.players,{userId=p.UserId,name=p.Name,slot=p:GetAttribute("BirthdaySpawnSlot"),location=p:GetAttribute("BirthdayLocation"),deadline=p:GetAttribute("LobbyCountdownEnd"),position=ready(p) and vec(p.Character.HumanoidRootPart.Position),seat=h and h.SeatPart and h.SeatPart:GetFullName(),health=h and h.Health})
 end
 table.insert(report.snapshots,out);return out
end
local function client(p,action,args)
 local done,result=false,nil
 task.spawn(function() local ok,value=pcall(function() return rpc:InvokeClient(p,action,args) end);result=ok and value or {error=tostring(value)};done=true end)
 await(function() return done end,90)
 assert(not result.error or (action=="orbit" and result.supported==false),result.error);return result
end
local function parallel(people,fn)
 local count=0;local results={}
 for i,p in people do task.spawn(function() local ok,value=pcall(fn,p,i);results[i]=ok and value or {error=tostring(value)};count+=1 end) end
 await(function() return count==#people end,95);return results
end
local function seatGroup(people,seats,label)
 table.sort(seats,function(a,b) return a:GetFullName()<b:GetFullName() end)
 assert(#seats==8,"Expected exactly eight seats")
 for i,p in people do
  local c=p.Character;local h=c.Humanoid
  h.Sit=false;local old=h.SeatPart;if old and old:FindFirstChild("SeatWeld") then old.SeatWeld:Destroy() end
  c.HumanoidRootPart:SetNetworkOwner(nil);c:PivotTo(seats[i].CFrame*CFrame.new(0,2,0));seats[i]:Sit(h)
 end
 task.wait(.6)
 local occupied={};local good=true
 for i,s in seats do local owner=s.Occupant and Players:GetPlayerFromCharacter(s.Occupant.Parent);table.insert(occupied,{seat=s:GetFullName(),userId=owner and owner.UserId});if owner~=people[i] then good=false end end
 check(label,good,occupied);snapshot(label,people)
 return seats
end
local function releaseAndPlace(p,position)
 local c=p.Character;local h=c.Humanoid;local root=c.HumanoidRootPart
 client(p,"release-seat")
 root:SetNetworkOwner(nil)
 local seat=h.SeatPart;h.Sit=false
 if seat and seat:FindFirstChild("SeatWeld") then seat.SeatWeld:Destroy() end
 h:ChangeState(Enum.HumanoidStateType.GettingUp)
 Run.Heartbeat:Wait();Run.Heartbeat:Wait()
 root.AssemblyLinearVelocity=Vector3.zero;root.AssemblyAngularVelocity=Vector3.zero
 c:PivotTo(CFrame.new(position))
 local setup={userId=p.UserId,target=vec(position),confirmed={},ownershipBefore="server"}
 for _=1,2 do
  local snap=await(function()
   local state=client(p,"snapshot")
   if not state.seat and h.SeatPart==nil and (Vector3.new(unpack(state.position))-position).Magnitude<2 and (root.Position-position).Magnitude<2 then return state end
  end,5)
  table.insert(setup.confirmed,{at=workspace:GetServerTimeNow(),serverPosition=vec(root.Position),clientPosition=snap.position,serverSeated=h.SeatPart~=nil,clientSeated=snap.seat~=nil})
  task.wait(.1)
 end
 root:SetNetworkOwner(p)
 task.wait(.25)
 setup.ownershipAfter=root:GetNetworkOwner() and root:GetNetworkOwner().UserId or "server"
 report.observations.placements=report.observations.placements or {};table.insert(report.observations.placements,setup)
end
task.delay(260,function() Test:EndTest({error="260-second watchdog",partial=report}) end)
local ok,err=xpcall(function()
 await(function() if #Players:GetPlayers()~=8 then return false end;for _,p in Players:GetPlayers() do if not ready(p) or not readyClients[p] then return false end end;return true end,65)
 local people=Players:GetPlayers();table.sort(people,function(a,b) return a.UserId<b.UserId end)
 for _,p in people do assert(p:GetAttribute("BirthdayLocation")=="Lobby","Test setup exhausted initial lobby time while launching eight clients; not a production reset defect") end
 local ids,slots={},{};local unique=true
 for _,p in people do if ids[p.UserId] or slots[p:GetAttribute("BirthdaySpawnSlot")] then unique=false end;ids[p.UserId]=true;slots[p:GetAttribute("BirthdaySpawnSlot")]=true end
 check("eight-distinct-players-and-spawn-slots",unique and #people==8,snapshot("initial-eight",people))
 local a,b=people[1],people[2]
 if testMode=="Draft02Party" then
 local resets=parallel(people,function(p) local old=p.Character;p:LoadCharacterAsync();await(function() return p.Character~=old and ready(p) and p:GetAttribute("BirthdayLocation")=="Lobby" end,35);return p:GetAttribute("LobbyCountdownEnd") end)
 report.observations.resetDeadlines=resets
 task.wait(.8)
 local seats={};for _,d in world.BirthdayLobby.EightGuestSeats:GetDescendants() do if d:IsA("Seat") then table.insert(seats,d) end end
 seatGroup(people,seats,"eight-lobby-seats-simultaneously-occupied")
 task.wait(2.5)
 local before=parallel(people,function(p) return client(p,"snapshot") end);report.observations.beforeEarly=before
 releaseAndPlace(a,Vector3.new(2000,4,-14));task.wait(.7)
 local started=workspace:GetServerTimeNow();local entry=client(a,"prompt");report.observations.earlyPrompt=entry
 await(function() return a:GetAttribute("BirthdayLocation")=="World" end,5)
 local after=parallel(people,function(p) return client(p,"snapshot") end);report.observations.afterEarly=after
 local unaffected=true
 for i=2,8 do
  local x,y=before[i],after[i]
  if x.error or y.error or y.location~="Lobby" or y.deadline~=x.deadline or y.hud~=true or not y.ownSubject or y.cameraType~="Custom" then unaffected=false end
  if not x.error and not y.error then
   local lookA,lookB=Vector3.new(unpack(x.cameraLook)),Vector3.new(unpack(y.cameraLook))
   if (lookA-lookB).Magnitude>.03 then unaffected=false end
  end
 end
 local earlyAt;local earlyPromptAt
 for _,v in report.events do if v.userId==a.UserId then
  if v.kind=="location" and v.location=="World" then earlyAt=v.at end
  if v.kind=="engine-prompt-triggered" then earlyPromptAt=v.at end
 end end
 check("early-prompt-enters-before-own-deadline",earlyAt~=nil and earlyPromptAt~=nil and earlyAt<before[1].deadline-2 and after[1].location=="World" and after[1].hud==false,{input=entry,enteredAt=earlyAt,promptAt=earlyPromptAt,originalDeadline=before[1].deadline})
 check("early-entry-leaves-seven-deadlines-hud-and-cameras-independent",unaffected)
 snapshot("one-early-seven-waiting",people)
 local deadline=b:GetAttribute("LobbyCountdownEnd")
 releaseAndPlace(b,Vector3.new(2000,4,-14));task.wait(.6)
 assert(deadline-workspace:GetServerTimeNow()>2,"Insufficient actual countdown remains for deadline test")
 local raced=client(b,"deadline-prompt",{at=deadline-.38});report.observations.deadlinePrompt=raced
 await(function() for _,p in people do if p:GetAttribute("BirthdayLocation")~="World" then return false end end;return true end,15)
 task.wait(.8)
 local transitions=0;local entryAt;local acceptedPromptAt;local deadlineSetAt
 for _,v in report.events do
  if v.userId==b.UserId then
   if v.kind=="location" and v.location=="World" then transitions+=1;entryAt=v.at end
   if v.kind=="engine-prompt-triggered" and math.abs(v.at-deadline)<.6 then acceptedPromptAt=v.at end
   if v.kind=="deadline" and v.deadline==deadline then deadlineSetAt=v.at end
  end
 end
 local timely=raced.attempts[1].beganAt<=deadline and raced.attempts[1].endedAt>=deadline-.2
 check("deadline-adjacent-prompt-burst-enters-once",transitions==1 and timely and acceptedPromptAt~=nil and entryAt>=deadline-.5 and entryAt<deadline+2,{userId=b.UserId,deadline=deadline,deadlineSetAt=deadlineSetAt,worldTransitions=transitions,enteredAt=entryAt,acceptedPromptAt=acceptedPromptAt,attempts=raced.attempts})
 check("party-test-keeps-full-sixty-second-deadline",deadlineSetAt~=nil and math.abs(deadline-deadlineSetAt-60)<.1,{deadline=deadline,setAt=deadlineSetAt})
 snapshot("all-eight-world",people)
 local courtyard={};for _,d in world.SurroundingContext.NeighborhoodDetails02.BirthdayCourtyard:GetDescendants() do if d:IsA("Seat") then table.insert(courtyard,d) end end
 seatGroup(people,courtyard,"eight-courtyard-seats-simultaneously-occupied")
 parallel(people,function(p,i) releaseAndPlace(p,Vector3.new(103+i*4,4,46));return true end)
 elseif testMode=="Draft02PartyPromptCirculation" then
  local entries=parallel(people,function(p,i)
   local a=(i-1)*math.pi/4
   releaseAndPlace(p,Vector3.new(2000+math.cos(a)*4.2,4,-17.5+math.sin(a)*4.2))
   return client(p,"prompt")
  end)
  report.observations.simultaneousPrompts=entries
  await(function() for _,p in people do if p:GetAttribute("BirthdayLocation")~="World" then return false end end;return true end,6)
  local allPrompted=true
  for _,e in entries do if e.error or e.after.location~="World" or e.after.hud~=false then allPrompted=false end end
  check("eight-simultaneous-pad-entries-complete",allPrompted,entries)
 else
  -- Leave default network ownership and spawn lifecycle untouched through expiry.
  await(function() for _,p in people do if p:GetAttribute("BirthdayLocation")~="World" then return false end end;return true end,70)
  task.wait(1.5)
  report.observations.defaultOwnershipArrival=parallel(people,function(p)
   local s=client(p,"snapshot");local owner=p.Character.HumanoidRootPart:GetNetworkOwner()
   s.serverNetworkOwner=owner and owner.UserId or "server";return s
  end)
  local allArrived=true;local destination=world.BirthdayLobby.WorldDestination.Position
  for _,s in report.observations.defaultOwnershipArrival do
   if s.error or s.location~="World" or s.hud~=false or not s.ownSubject or s.cameraType~="Custom" or s.health~=100 or (Vector3.new(unpack(s.position))-destination).Magnitude>25 then allArrived=false end
  end
  check("eight-default-ownership-clients-see-safe-world-arrival",allArrived,report.observations.defaultOwnershipArrival)
  snapshot("all-eight-world-default-ownership",people)
 end
 task.wait(.7)
 report.observations.beforeOrbits=parallel({a,b},function(p) return client(p,"snapshot") end)
 report.observations.orbitA=client(a,"orbit")
 report.observations.orbitB=client(b,"orbit")
 -- Six actual avatars enter the house through the original door and move around the shared room.
 releaseAndPlace(a,Vector3.new(-1,4,-118));task.wait(.6)
 report.observations.doorInput=client(a,"door");task.wait(.5)
 local six={unpack(people,1,6)}
 parallel(six,function(p,i) releaseAndPlace(p,Vector3.new(-1+(i%2)*5,4,-116+(math.floor((i-1)/2))*5));return true end)
 task.wait(.5)
 local paths=parallel(six,function(p,i)
  task.wait((i-1)*.7)
  return client(p,"walk",{points={{-1,4,-122},{-1,4,-131},{-1,4,-144},{5+(i%3)*4,4,-151+math.floor((i-1)/3)*5}}})
 end)
 report.observations.bedroomPaths=paths
 local allWalk=true;for _,path in paths do if path.error or not path.passed or path.after.health~=100 then allWalk=false end end
 check("six-visitors-enter-and-circulate-at-normal-speed",allWalk,paths)
 snapshot("six-in-bedroom",people)
 local exits=parallel(six,function(p,i)
  task.wait((i-1)*.6)
  return client(p,"walk",{points={{1,4,-139},{-1,4,-129},{-1,4,-120},{-4+i*4,4,-112}}})
 end)
 report.observations.bedroomExits=exits
 local allExit=true;for _,path in exits do if path.error or not path.passed or path.after.health~=100 then allExit=false end end
 check("six-visitors-exit-bedroom-without-traps",allExit,exits)
end,debug.traceback)
report.error=not ok and err or nil;report.passed=ok
for _,c in report.checks do if not c.passed then report.passed=false end end
Test:EndTest(report)
