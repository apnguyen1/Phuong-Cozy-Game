-- Temporary Studio-only observation of two actual client cameras; never save in production.
local Test=game:GetService("StudioTestService")
if not game:GetService("RunService"):IsStudio() or Test:GetTestArgs()~="Draft02Camera" then return end
local Players=game:GetService("Players")
local rpc=Instance.new("RemoteFunction");rpc.Name="Draft02PartyRPC";rpc.Parent=game.ReplicatedStorage
local events=Instance.new("RemoteEvent");events.Name="Draft02PartyEvents";events.Parent=game.ReplicatedStorage
local ready={};events.OnServerEvent:Connect(function(p,v) if v.kind=="client-ready" then ready[p]=true end end)
local report={test="Draft02Camera",engine="Studio actual two-client multiplayer",observations={}}
task.delay(45,function() Test:EndTest({error="Camera test watchdog",partial=report}) end)
local ok,err=xpcall(function()
 local deadline=os.clock()+25
 repeat task.wait(.1) until (#Players:GetPlayers()==2 and (function() for _,p in Players:GetPlayers() do if not ready[p] or not p.Character or not p.Character:GetAttribute("BirthdayPlacementReady") then return false end end return true end)()) or os.clock()>deadline
 assert(#Players:GetPlayers()==2,"Two actual clients required")
 local people=Players:GetPlayers();table.sort(people,function(a,b) return a.UserId<b.UserId end)
 for _,p in people do assert(ready[p] and p.Character:GetAttribute("BirthdayPlacementReady"),"Client is not ready") end
 task.wait(3)
 local a,b=people[1],people[2]
 report.observations.beforeOrbits={rpc:InvokeClient(a,"snapshot"),rpc:InvokeClient(b,"snapshot")}
 report.observations.orbitA=rpc:InvokeClient(a,"orbit")
 report.observations.orbitB=rpc:InvokeClient(b,"orbit")
 report.passed=report.observations.orbitA.supported and report.observations.orbitB.supported
end,debug.traceback)
if not ok then report.passed=false;report.error=err end
Test:EndTest(report)
