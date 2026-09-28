local Players = game:GetService("Players")
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
local cakeButton=button(gui,"CakeButton","Cake finale",function() end); cakeButton.AnchorPoint=Vector2.new(1,0); cakeButton.Position=UDim2.new(1,-20,0,80); cakeButton.Size=UDim2.fromOffset(132,44); cakeButton.Visible=false

local panel=Instance.new("Frame"); panel.Name="ActivityPanel"; panel.AnchorPoint=Vector2.new(.5,.5); panel.Position=UDim2.fromScale(.5,.5); panel.Size=UDim2.new(.86,0,.78,0); panel.BackgroundColor3=P.cream; panel.Visible=false; panel.Parent=gui; corner(panel,16)
local title=text(panel,"Title","",24,P.forest); title.Position=UDim2.fromOffset(22,18); title.Size=UDim2.new(1,-260,0,36)
local close=button(panel,"Close","Close",function() panel.Visible=false end); close.AnchorPoint=Vector2.new(1,0); close.Position=UDim2.new(1,-18,0,16); close.Size=UDim2.fromOffset(104,48); close.BackgroundColor3=P.brick
local back=button(panel,"Back","Back",function() panel.Visible=false end); back.AnchorPoint=Vector2.new(1,0); back.Position=UDim2.new(1,-132,0,16); back.Size=UDim2.fromOffset(104,48)
local instructions=text(panel,"Instructions","",16); instructions.Position=UDim2.fromOffset(22,62); instructions.Size=UDim2.new(1,-44,0,48)
local progress=text(panel,"Progress","",15,P.forest); progress.Position=UDim2.fromOffset(22,112); progress.Size=UDim2.new(1,-44,0,28)
local scroll=Instance.new("ScrollingFrame"); scroll.Name="ActionList"; scroll.Position=UDim2.fromOffset(22,148); scroll.Size=UDim2.new(1,-44,1,-170); scroll.BackgroundColor3=P.sage; scroll.BackgroundTransparency=.35; scroll.BorderSizePixel=0; scroll.ScrollBarThickness=10; scroll.AutomaticCanvasSize=Enum.AutomaticSize.Y; scroll.Parent=panel; corner(scroll,10)
local list=Instance.new("UIListLayout"); list.Padding=UDim.new(0,10); list.Parent=scroll
local pad=Instance.new("UIPadding"); pad.PaddingTop=UDim.new(0,12); pad.PaddingBottom=UDim.new(0,12); pad.PaddingLeft=UDim.new(0,12); pad.PaddingRight=UDim.new(0,12); pad.Parent=scroll

local currentView; local sequence=0; local sessionId=nil; local lastSnapshot={}; local cakeState={finaleState="LOCKED"}; local panelMode="closed"
local function freshId() sequence+=1; return string.format("client-%d-%d-%d",player.UserId,math.floor(os.clock()*1000),sequence) end
cakeButton.Activated:Connect(function() renderCake(cakeState) end)
local function sendActivity(activityId,roundId,stepId,payload) if not sessionId then status.Text="Waiting for birthday session"; return end; action:FireServer({kind="ActivityAction",sessionId=sessionId,activityId=activityId,roundId=roundId or "",stepId=stepId or "",actionId=freshId(),payload=payload or {}}) end
local function clear() for _,x in ipairs(scroll:GetChildren()) do if x:IsA("TextButton") or x:IsA("TextLabel") then x:Destroy() end end end
local function petalCount(p) if type(p)=="number" then return p end; local n=0; if type(p)=="table" then for _,v in pairs(p) do if v then n+=1 end end end; return n end
local function closeActivity() if currentView and sessionId then action:FireServer({kind="CloseActivity",sessionId=sessionId,activityId=currentView.activityId,roundId=currentView.roundId,actionId=freshId()}) end; currentView=nil; panelMode="closed"; panel.Visible=false end
close.Activated:Connect(closeActivity); back.Activated:Connect(closeActivity)
local function render(view)
	if type(view)~="table" then return end
	if not view.activityId then
		renderJournal(view); return
	end
	currentView=view; panelMode="activity"; panel.Visible=true; title.Text=view.title or view.activityId; instructions.Text=view.instructions or "Choose an available action."
	local p=view.progress or {}; progress.Text=string.format("Progress  •  %s / %s   [%s]",tostring(p.done or 0),tostring(p.total or 0),tostring(view.state or "")); clear()
	local order=1
	local reading=view.reading
	if type(reading)=="table" and (type(reading.title)=="string" or type(reading.text)=="string") then
		local readingTitle=text(scroll,"ReadingTitle",reading.title or "Reading",18,P.forest); readingTitle.LayoutOrder=order; readingTitle.AutomaticSize=Enum.AutomaticSize.Y; readingTitle.Size=UDim2.new(1,0,0,0); order+=1
		local readingText=text(scroll,"ReadingText",reading.text or "",16,P.ink); readingText.LayoutOrder=order; readingText.AutomaticSize=Enum.AutomaticSize.Y; readingText.Size=UDim2.new(1,0,0,0); order+=1
	end
	for _,d in ipairs(view.availableActions or {}) do local b=button(scroll,"Action_"..tostring(d.id),d.label or d.id,function() if d.enabled~=false then sendActivity(view.activityId,view.roundId,d.stepId,d.payload) end end); b.LayoutOrder=order; order+=1; if d.enabled==false then b.Active=false; b.AutoButtonColor=false; b.BackgroundColor3=P.wood; b.Text=(d.label or d.id).." — "..(d.reason or "Unavailable") end end
	if view.canReplay then local b=button(scroll,"Replay","Replay this activity",function() requestView(view.activityId,true) end); b.LayoutOrder=order end
	if view.errorText then local e=text(scroll,"Error",view.errorText,14,P.brick); e.Size=UDim2.new(1,0,0,40) end
end
function renderJournal(s)
 currentView=nil; panelMode="journal"; clear(); panel.Visible=true; title.Text="Birthday journal"; instructions.Text="Explore together and help complete each petal."; local petals=s.petals or {}; local rounds=s.rounds or {}; local names={Q01="Everything Tucked In • Bedroom",Q02="Jasper's Favorite Things • Bedroom / Jasper yard",Q03="A Tiny World of Her Own • U District booth / bedroom display",Q04="One More Chapter • Quad / bedroom",Q05="A Labubu Wish • U District",Q06="Something Delicious • Three food counters"}; local order=1
 for _,id in ipairs({"Q01","Q02","Q03","Q04","Q05","Q06"}) do local r=rounds[id] or {}; local done=petals[id] or r.completed or false; local e=text(scroll,"Journal_"..id,string.format("%s • %s",names[id],done and "Petal complete" or "Explore"),16,done and P.forest or P.ink); e.LayoutOrder=order; e.Size=UDim2.new(1,0,0,34); order+=1 end
 local f=text(scroll,"JournalFund",string.format("Shared fund • %s",tostring(s.fundBalance or 0)),17,P.golden); f.LayoutOrder=order; f.Size=UDim2.new(1,0,0,34)
end
function renderCake(state)
 currentView=nil; panelMode="cake"; cakeState=state or cakeState; clear(); panel.Visible=true; title.Text="Birthday cake"; instructions.Text="Gather voluntarily, then choose a celebration action."; progress.Text="Finale • "..tostring(cakeState.finaleState or "LOCKED"); local order=1; local phase=cakeState.finaleState
 local methods={}; local host=player.UserId==lastSnapshot.phuongUserId or player.UserId==lastSnapshot.hostUserId; if phase=="INVITED" then if host then methods={"CancelInvite","Cut"} end elseif phase=="CUT" or phase=="EATING" then methods={"Eat"} elseif host and petalCount(lastSnapshot.petals)>=6 then methods={"Invite"} end
 for _,method in ipairs(methods) do local b=button(scroll,"Cake_"..method,method,function() if sessionId then action:FireServer({kind="Cake",action=method,sessionId=sessionId,actionId=freshId()}) end end); b.LayoutOrder=order; order+=1 end
end
local function snapshot(s)
	if type(s)~="table" then return end
	for k,v in pairs(s) do lastSnapshot[k]=v end; s=lastSnapshot; if s.cake then cakeState=s.cake; if panelMode=="cake" and panel.Visible then renderCake(cakeState) end end
	if type(s.sessionId)=="string" and s.sessionId~="" then sessionId=s.sessionId end
	local petals=s.petals; local petalCountValue=petalCount(petals); flower.Text=string.format("✿ %d / 6 petals%s",petalCountValue,petalCountValue==6 and "  •  Cake ready" or ""); fund.Text=string.format("Shared fund  •  %s",tostring(s.fundBalance or s.fund or 0))
	local q=s.queue or {}; local members=q.members or {}; local queueCount=q.count or #members; local joined=table.find(members,player.UserId)~=nil; local remaining=q.remaining and math.ceil(q.remaining) or 0; queueState.Text=string.format("Queue: %s • %d/%d • %ds • %s",joined and "joined" or "waiting",queueCount,q.capacity or 10,remaining,q.state or "Empty")
	cakeButton.Visible=(petalCountValue>=6)
end
function requestView(id,replay) if not sessionId then status.Text="Waiting for birthday session"; return end; action:FireServer({kind="RequestView",sessionId=sessionId,activityId=id,actionId=freshId(),replay=replay==true}) end
journal.Activated:Connect(function() if sessionId then action:FireServer({kind="RequestJournal",sessionId=sessionId,actionId=freshId()}) else status.Text="Waiting for birthday session" end end)
action.OnClientEvent:Connect(function(payload)
	if type(payload)~="table" then return end
	if type(payload.sessionId)=="string" and payload.sessionId~="" then sessionId=payload.sessionId end
	if payload.snapshot then snapshot(payload.snapshot) end; if payload.queue then snapshot({queue=payload.queue}) end
	if payload.view then render(payload.view) end; if payload.journal then renderJournal(payload.journal) end; if payload.cake then cakeState=payload.cake; renderCake(payload.cake) end
	if payload.kind=="Result" then status.Text=payload.ok and "A cozy action was accepted" or (payload.errorText or payload.code or "Action unavailable") end
end)
local function bind(p)
	if not p:IsA("ProximityPrompt") or p:GetAttribute("MVPBound") then return end
	local id=p:GetAttribute("ActivityId") or p.Parent:GetAttribute("ActivityId"); if not id then return end
	p:SetAttribute("MVPBound",true); p.Triggered:Connect(function() if id=="Cake" then renderCake(cakeState) else requestView(id) end end)
end
for _,x in ipairs(workspace:GetDescendants()) do bind(x) end; workspace.DescendantAdded:Connect(bind)
UserInputService.InputBegan:Connect(function(input,processed)
	if processed or not panel.Visible or not currentView then return end
	local step=input.KeyCode==Enum.KeyCode.Q and "rotate-left" or input.KeyCode==Enum.KeyCode.E and "rotate-right"
	if step then for _,d in ipairs(currentView.availableActions or {}) do local rotates=d.payload and d.payload.action=="rotate" and ((step=="rotate-left" and d.payload.direction==-1) or (step=="rotate-right" and d.payload.direction==1)); if d.enabled~=false and (d.stepId==step or d.id==step or rotates) then sendActivity(currentView.activityId,currentView.roundId,d.stepId,d.payload); break end end end
end)
local function refresh() status.Text=string.format("Birthday session  •  arrival %s",player:GetAttribute("MVPArrivalStatus") or "Loading") end
player.AttributeChanged:Connect(refresh); refresh(); action:FireServer({kind="RequestSnapshot",actionId=freshId()})
