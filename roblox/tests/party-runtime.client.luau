-- Temporary Studio test client; never install in the saved production place.
if not game:GetService("RunService"):IsStudio() then return end
local Players=game:GetService("Players")
local Run=game:GetService("RunService")
local RS=game:GetService("ReplicatedStorage")
local player=Players.LocalPlayer
local rpc=RS:WaitForChild("Draft02PartyRPC",60)
local events=RS:WaitForChild("Draft02PartyEvents",60)
if not rpc or not events then return end
local function vec(v) return {v.X,v.Y,v.Z} end
local function snapshot()
 local c=player.Character;local h=c and c:FindFirstChildOfClass("Humanoid")
 local root=c and c:FindFirstChild("HumanoidRootPart")
 local camera=workspace.CurrentCamera
 local hud=player.PlayerGui:FindFirstChild("BirthdayLobbyHUD")
 return {userId=player.UserId,name=player.Name,at=workspace:GetServerTimeNow(),location=player:GetAttribute("BirthdayLocation"),deadline=player:GetAttribute("LobbyCountdownEnd"),hud=hud and hud.Enabled,cameraType=camera.CameraType.Name,ownSubject=camera.CameraSubject==h,cameraPosition=vec(camera.CFrame.Position),cameraLook=vec(camera.CFrame.LookVector),position=root and vec(root.Position),health=h and h.Health,seat=h and h.SeatPart and h.SeatPart:GetFullName()}
end
local function promptInput(prompt,at)
 if at then while workspace:GetServerTimeNow()<at do Run.Heartbeat:Wait() end end
 local beginAt=workspace:GetServerTimeNow()
 prompt:InputHoldBegin()
 task.wait(prompt.HoldDuration+.07)
 prompt:InputHoldEnd()
 return {beganAt=beginAt,endedAt=workspace:GetServerTimeNow(),holdDuration=prompt.HoldDuration}
end
rpc.OnClientInvoke=function(action,args)
 if action=="snapshot" then return snapshot() end
 if action=="release-seat" then
  local h=player.Character:FindFirstChildOfClass("Humanoid")
  h.Sit=false;h.Jump=true
  h:ChangeState(Enum.HumanoidStateType.GettingUp)
  task.wait(.2)
  return snapshot()
 end
 if action=="prompt" or action=="deadline-prompt" then
  local prompt=workspace.CozyWorld_Draft01.BirthdayLobby.Portal.PortalPrompt.EnterWorld
  local attempts={}
  table.insert(attempts,promptInput(prompt,args and args.at))
  if action=="deadline-prompt" then
   for _=1,2 do task.wait(.05);table.insert(attempts,promptInput(prompt)) end
  end
  task.wait(.35)
  return {attempts=attempts,after=snapshot(),inputMethod="ProximityPrompt InputHoldBegin/End, engine path; no physical keyboard or touch claim"}
 end
 if action=="door" then
  local p=workspace.CozyWorld_Draft01.Home.DoorInteraction.DoorPrompt
  return promptInput(p)
 end
 if action=="orbit" then
  local before=snapshot()
  local userInput=game:GetService("UserInputService")
  local observedInput
  local input;local middle=workspace.CurrentCamera.ViewportSize*.5
  local ok,err=pcall(function()
   input=game:GetService("UserInputService"):CreateVirtualInput()
   assert(input,"CreateVirtualInput returned nil")
   input:SendMousePosition(middle)
   input:SendMouseButton(middle,Enum.UserInputType.MouseButton2,true)
   local untilTime=os.clock()+1
   repeat Run.RenderStepped:Wait() until userInput.MouseBehavior~=Enum.MouseBehavior.Default or os.clock()>=untilTime
   observedInput={mouseBehavior=userInput.MouseBehavior.Name,rightButtonDown=userInput:IsMouseButtonPressed(Enum.UserInputType.MouseButton2),touch=userInput.TouchEnabled,preferred=userInput.PreferredInput.Name}
   for _=1,12 do input:SendMouseDelta(Vector2.new(12,0));Run.RenderStepped:Wait() end
   input:SendMouseButton(middle,Enum.UserInputType.MouseButton2,false)
   task.wait(.3)
  end)
  if input then pcall(function() input:SendMouseButton(middle,Enum.UserInputType.MouseButton2,false) end) end
  return {before=before,after=snapshot(),inputMethod="Studio VirtualInput mouse delta",observedInput=observedInput,supported=ok,error=not ok and tostring(err) or nil}
 end
 if action=="walk" then
  local h=player.Character:FindFirstChildOfClass("Humanoid")
  local root=player.Character.HumanoidRootPart
  h.Sit=false;h.WalkSpeed=16
  local result={userId=player.UserId,startedAt=workspace:GetServerTimeNow(),steps={},before=snapshot(),passed=true}
  for _,v in args.points do
   local target=Vector3.new(v[1],v[2],v[3])
   local start=root.Position;local finish=os.clock()+10
   h:MoveTo(target)
   repeat Run.Heartbeat:Wait() until (Vector2.new(root.Position.X-target.X,root.Position.Z-target.Z).Magnitude<2 and math.abs(root.Position.Y-target.Y)<=3 and h.FloorMaterial~=Enum.Material.Air) or os.clock()>finish or h.Health<=0
   local distance=Vector2.new(root.Position.X-target.X,root.Position.Z-target.Z).Magnitude
   local floorError=math.abs(root.Position.Y-target.Y)
   table.insert(result.steps,{target=v,start=vec(start),finish=vec(root.Position),distance=distance,floorError=floorError,floorMaterial=h.FloorMaterial.Name,at=workspace:GetServerTimeNow(),health=h.Health})
   if distance~=distance or distance>=2 or floorError~=floorError or floorError>3 or h.FloorMaterial==Enum.Material.Air or h.Health<=0 then result.passed=false;break end
  end
  h:MoveTo(root.Position);result.after=snapshot();result.finishedAt=workspace:GetServerTimeNow()
  return result
 end
 error("Unknown party test action: "..tostring(action))
end
events:FireServer({kind="client-ready",at=workspace:GetServerTimeNow()})
