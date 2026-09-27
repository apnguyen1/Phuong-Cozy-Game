-- Temporary Studio-only ServerScript. Install for an automated local multiplayer
-- test, then REMOVE before saving the deliverable. Exercises the installed server
-- and client scripts in the real Roblox engine; does not replace production logic.
local Test=game:GetService("StudioTestService")
if not game:GetService("RunService"):IsStudio() or Test:GetTestArgs()~="Draft02Lobby" then return end
local Players=game:GetService("Players")
local Http=game:GetService("HttpService")
local report={schema_version=1,test="Draft02Lobby",engine="Studio actual multiplayer",checks={},snapshots={},events={}}
local function check(name,value,details)
 table.insert(report.checks,{name=name,passed=value==true,details=details})
end
local function await(predicate,seconds)
 local finish=os.clock()+seconds
 repeat local value=predicate();if value then return value end;task.wait(.1) until os.clock()>finish
 error("Timed out waiting for test condition")
end
local function ready(p)
 return p and p.Character and p.Character:GetAttribute("BirthdayPlacementReady")==true and p.Character:FindFirstChild("HumanoidRootPart") and p:GetAttribute("BirthdayLocation")=="Lobby" and p:GetAttribute("LobbyCountdownEnd")
end
local function observePlayer(p)
 p:GetAttributeChangedSignal("LobbyCountdownEnd"):Connect(function()
  local deadline=p:GetAttribute("LobbyCountdownEnd")
  table.insert(report.events,{name=p.Name,event="deadline-change",at=workspace:GetServerTimeNow(),deadline=deadline})
 end)
 p:GetAttributeChangedSignal("BirthdayLocation"):Connect(function()
  table.insert(report.events,{name=p.Name,event="location-change",at=workspace:GetServerTimeNow(),location=p:GetAttribute("BirthdayLocation")})
 end)
 p.CharacterAdded:Connect(function(character)
  task.spawn(function()
   local humanoid=character:WaitForChild("Humanoid",20)
   local root=character:WaitForChild("HumanoidRootPart",20)
   if humanoid then humanoid.WalkSpeed=0;humanoid.JumpPower=0;humanoid.JumpHeight=0 end
   if root then root:SetNetworkOwner(nil) end
  end)
 end)
end
Players.PlayerAdded:Connect(observePlayer)
for _,p in Players:GetPlayers() do observePlayer(p) end
local function snapshot(label)
 local players={}
 for _,p in Players:GetPlayers() do
  local r=p.Character and p.Character:FindFirstChild("HumanoidRootPart")
  table.insert(players,{name=p.Name,id=p.UserId,slot=p:GetAttribute("BirthdaySpawnSlot"),location=p:GetAttribute("BirthdayLocation"),joined=p:GetAttribute("BirthdayJoinedWorld"),remaining=p:GetAttribute("LobbyCountdownEnd") and p:GetAttribute("LobbyCountdownEnd")-workspace:GetServerTimeNow(),position=r and {r.Position.X,r.Position.Y,r.Position.Z}})
 end
 table.insert(report.snapshots,{label=label,at=workspace:GetServerTimeNow(),players=players})
end
task.delay(180,function() Test:EndTest({error="180-second watchdog",partial=report}) end)
local ok,err=xpcall(function()
 await(function() return #Players:GetPlayers()>=2 end,45)
 local people=Players:GetPlayers();table.sort(people,function(a,b) return a.UserId<b.UserId end)
 local a,b=people[1],people[2]
 await(function() return ready(a) and ready(b) end,20)
 snapshot("initial-two-players")
 local initialB=b:GetAttribute("LobbyCountdownEnd")
 local remainingA=a:GetAttribute("LobbyCountdownEnd")-workspace:GetServerTimeNow()
 check("initial-countdown-at-most-60",remainingA>55 and remainingA<=60,remainingA)
 check("two-distinct-spawn-positions",(a.Character.HumanoidRootPart.Position-b.Character.HumanoidRootPart.Position).Magnitude>3)
 check("lobby-is-default-spawn",a.RespawnLocation==workspace.CozyWorld_Draft01.BirthdayLobby.LobbySpawn)
 task.wait(5)
 local oldCharacter=a.Character
 a:LoadCharacterAsync()
 await(function() return a.Character~=oldCharacter and ready(a) end,20)
 check("reset-before-entry-restarts-only-own-countdown",a:GetAttribute("LobbyCountdownEnd")>initialB+3 and b:GetAttribute("LobbyCountdownEnd")==initialB,{a=a:GetAttribute("LobbyCountdownEnd"),b=b:GetAttribute("LobbyCountdownEnd"),originalB=initialB})
 local deadlineA=a:GetAttribute("LobbyCountdownEnd")
 Test:AddPlayers(1)
 local late=await(function() for _,p in Players:GetPlayers() do if p~=a and p~=b and ready(p) then return p end end end,30)
 check("late-join-has-own-countdown",late:GetAttribute("LobbyCountdownEnd")>initialB+3 and b:GetAttribute("LobbyCountdownEnd")==initialB)
 local seat=workspace.CozyWorld_Draft01.BirthdayLobby.EightGuestSeats:FindFirstChildWhichIsA("Seat",true)
 assert(seat,"Missing working lobby seat")
 b.Character:PivotTo(seat.CFrame*CFrame.new(0,2,0));seat:Sit(b.Character.Humanoid)
 task.wait(.4)
 check("guest-can-sit-during-countdown",b.Character.Humanoid.SeatPart==seat)
 snapshot("reset-late-join-and-seated-guest")
 await(function() return b:GetAttribute("BirthdayLocation")=="World" end,65)
 local arrivalTime=workspace:GetServerTimeNow()
 check("full-timer-auto-enters-without-early-trigger",arrivalTime>=initialB and arrivalTime-initialB<2,{deadline=initialB,arrivedAt=arrivalTime})
 check("seated-player-detaches-on-entry",not b.Character.Humanoid.Sit and b.Character.Humanoid.SeatPart==nil)
 check("timer-does-not-pull-friends-early",a:GetAttribute("BirthdayLocation")=="Lobby" and late:GetAttribute("BirthdayLocation")=="Lobby")
 local destination=workspace.CozyWorld_Draft01.BirthdayLobby.WorldDestination.Position
 check("timer-arrives-in-outdoor-arrival",(b.Character.HumanoidRootPart.Position-destination).Magnitude<20)
 snapshot("first-timer-expired-friends-still-in-lobby")
 await(function() return a:GetAttribute("BirthdayLocation")=="World" and late:GetAttribute("BirthdayLocation")=="World" end,35)
 check("reset-player-full-countdown-completes",workspace:GetServerTimeNow()>=deadlineA)
 for iteration=1,3 do
  local previous=b.Character;b:LoadCharacterAsync()
  await(function() return b.Character~=previous and b.Character:GetAttribute("BirthdayPlacementReady")==true and b:GetAttribute("BirthdayLocation")=="World" and b.Character:FindFirstChild("HumanoidRootPart") end,20)
  task.wait(.5)
  check("world-respawn-repeat-"..iteration,b:GetAttribute("LobbyCountdownEnd")==nil and b:GetAttribute("BirthdayJoinedWorld")==true and (b.Character.HumanoidRootPart.Position-destination).Magnitude<20)
 end
 snapshot("all-in-world-after-repeated-reset")
 local releasedSlot=late:GetAttribute("BirthdaySpawnSlot")
 late:Kick("Local automated verification: disconnect and slot release")
 await(function() return not late.Parent end,10)
 Test:AddPlayers(1)
 local replacement=await(function() for _,p in Players:GetPlayers() do if p~=a and p~=b and ready(p) then return p end end end,30)
 check("disconnect-allows-fresh-guest",replacement:GetAttribute("BirthdayJoinedWorld")==false and replacement:GetAttribute("LobbyCountdownEnd")>workspace:GetServerTimeNow() and replacement:GetAttribute("BirthdaySpawnSlot")==releasedSlot,{releasedSlot=releasedSlot,newSlot=replacement:GetAttribute("BirthdaySpawnSlot")})
 snapshot("replacement-guest-independent")
end,debug.traceback)
report.error=not ok and err or nil
report.passed=ok
for _,c in report.checks do if not c.passed then report.passed=false end end
print("DRAFT02_RUNTIME_RESULT "..Http:JSONEncode(report))
Test:EndTest(report)
