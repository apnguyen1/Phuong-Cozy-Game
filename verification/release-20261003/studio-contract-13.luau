_G.__PCW25ContractText..=[==[es[name]=frame*CF(name=="Q04BedroomKindle" and 1.1 or 1.3,name=="Q04BedroomKindle" and .23 or 1.3,0) end
	end
	self:RenderReading(nil)
	self.connection=RunService.Heartbeat:Connect(function(dt)
		self.elapsed+=dt; if self.elapsed<.05 then return end
		local elapsed=self.elapsed; self.elapsed=0
		local ok,err=pcall(self._tick,self,elapsed)
		if not ok then
			self.queue={}; self.active=nil
			-- Interrupted cosmetics cannot lock gameplay. Return to the authoritative location.
			pcall(function() self:_pose(self.jasperAtYard and self.yard or self.bedroom); self:_settleJasper() end)
			warn("PCW-22 Jasper presentation recovered",err)
		end
	end)
	return self
end
function WorldFeedback:_pose(frame)
	if not self.actor or not self.actor.Parent or not frame then return end
	self.actor:PivotTo(frame*self.footOffset:Inverse()); self.actorFrame=frame; self.cue.CFrame=frame
end
function WorldFeedback:_toyVisible(model,visible)
	if model:IsA("BasePart") then model.Transparency=visible and 0 or 1; return end
	for _, item in ipairs(model:GetDescendants()) do if item:IsA("BasePart") then item.Transparency=visible and 0 or 1 end end
end
function WorldFeedback:ResetJasper(roundId)
	self.queue={}; self.active=nil; self.jasperAtYard=false; self.rabbitState="hidden"; self.targetIndex=nil; self.treated=false
	self.jasper:SetAttribute("RoundId",roundId)
	if not self.actor then return end
	self:_pose(self.bedroom); self:_toyVisible(self.rabbit,false); self.ball.Transparency=1; self.target.Transparency=1; self.treat.Transparency=1
	self.targetText.Parent.Enabled=false; self.jasperText.Text="Jasper · say hello in the bedroom"
end
function WorldFeedback:_enqueue(kind,index)
	if not self.actor then return end
	-- Seven required presentations at most; repeated optional pets coalesce.
	if kind=="pet" then
		if self.active or #self.queue>0 then return end
	end
	if #self.queue<8 then table.insert(self.queue,{kind=kind,index=index,age=0}) end
end
function WorldFeedback:MoveJasperToYard() self.jasperAtYard=true; self:_enqueue("lead") end
function WorldFeedback:ShowRabbitPickup(index) self.rabbitState="found"; self:_enqueue("pickup",index) end
function WorldFeedback:ReturnRabbit() self.rabbitState="returned"; self:_enqueue("return") end
function WorldFeedback:PresentFetchTarget(index) self.targetIndex=index; if not self.active and #self.queue==0 then self:_settleJasper() end end
function WorldFeedback:FetchJasper(index) self:_enqueue("fetch",index) end
function WorldFeedback:GiveJasperTreat() self.treated=true; self.targetIndex=nil; self:_enqueue("treat") end
function WorldFeedback:PetJasper() self:_enqueue("pet") end
function WorldFeedback:_fetchPoint(index)
	return self.yard*CF((index-2)*3.2,.04,-(5+index*2))
end
function WorldFeedback:_settleJasper()
	if not self.actor then return end
	self:_pose(self.jasperAtYard and self.yard or self.bedroom)
	self:_toyVisible(self.rabbit,self.rabbitState~="hidden")
	self.rabbit:PivotTo(self.yard*CF(self.rabbitState=="found" and 2.3 or -2.3,.1,1.4))
	self.ball.Transparency=self.targetIndex and 0 or 1; self.ball.CFrame=self.yard*CF(1.8,.4,0)
	self.target.Transparency=self.targetIndex and .2 or 1; self.targetText.Parent.Enabled=self.targetIndex~=nil
	if self.targetIndex then self.target.CFrame=self:_fetchPoint(self.targetIndex); self.targetText.Text="Throw "..self.targetIndex.." of 3 · no aiming needed" end
	self.treat.Transparency=self.treated and 0 or 1; self.treat.CFrame=self.yard*CF(0,.35,-2.4)
	self.jasperText.Text=self.treated and "Jasper is happy · thank you!" or self.targetIndex and "Jasper · ready to fetch" or self.rabbitState=="found" and "Rabbit found · return it to Jasper" or self.jasperAtYard and "Jasper · find his rabbit in a basket" or "Jasper · say hello in the bedroom"
end
function WorldFeedback:_tick(dt)
	if not self.actor then return end
	if not self.active then self.active=table.remove(self.queue,1); if not self.active then return end end
	local action=self.active; action.age+=dt
	local age=action.age; local duration=1
	if action.kind=="lead" then
		duration=5
		local start,finish=self.bedroom.Position,self.yard.Position
		local route={start,self.doorPosition or start,self.porchPosition or finish,finish}
		local value=math.clamp(age/duration,0,.9999)*3; local index=math.floor(value)+1
		self:_pose(face(route[index]:Lerp(route[index+1],value%1),route[index+1]))
		self.jasperText.Text="Jasper is heading to his yard · follow the marker"
	elseif action.kind=="fetch" then
		duration=2.8
		local target=self:_fetchPoint(action.index); local base=self.yard
		self.target.CFrame=target; self.target.Transparency=.2; self.targetText.Parent.Enabled=true
		self.targetText.Text="Fetch "..action.index.." of 3"
		self.ball.Transparency=0
		if age<.55 then
			local alpha=age/.55
			self.ball.CFrame=base:Lerp(target,alpha)*CF(0,.45+math.sin(alpha*math.pi)*2.4,0)
			self:_pose(base)
		elseif age<1.6 then
			self.ball.CFrame=target*CF(0,.35,0)
			self:_pose(face(base.Position:Lerp(target.Position,(age-.55)/1.05),target.Position))
		else
			self:_pose(face(target.Position:Lerp(base.Position,math.clamp((age-1.6)/1.2,0,1)),base.Position))
			self.ball.CFrame=self.actorFrame*CF(0,1.35,-2.1)
		end
		self.jasperText.Text="Jasper · fetching toy "..action.index
	elseif action.kind=="pickup" then
		self:_pose(self.yard); self:_toyVisible(self.rabbit,true)
		local basket=self.baskets[action.index] or self.yard
		self.rabbit:PivotTo(basket:Lerp(self.yard*CF(2.3,1.2,1.4),math.clamp(age,0,1)))
		self.jasperText.Text="You found Jasper's rabbit!"
	elseif action.kind=="return" then
		self:_pose(self.yard); self:_toyVisible(self.rabbit,true)
		self.rabbit:PivotTo((self.yard*CF(2.3,1.2,1.4)):Lerp(self.yard*CF(0,1.3,-2.1),math.clamp(age,0,1)))
		self.jasperText.Text="Jasper has his rabbit · ready for toys"
	else
		self:_pose(self.yard*CF(0,math.sin(math.clamp(age,0,1)*math.pi)*.2,0)*CFrame.Angles(0,math.sin(age*8)*.08,0))
		self.jasperText.Text=action.kind=="treat" and "A Greenie for Jasper · thank you!" or "Jasper leans in for a gentle pet"
		if action.kind=="treat" then self.treat.Transparency=0; self.treat.CFrame=self.yard*CF(0,1.2,-2.3) end
	end
	if age>=duration then self.active=nil; if #self.queue==0 then self:_settleJasper() end end
end

function WorldFeedback:_setupCraft(root,mvp,anchors)
	self.craft=folder(self.root,"Craft"); self.craftFrames={}
	local stations=mvp:FindFirstChild("Stations"); local station=stations and stations:FindFirstChild("Q03Station")
	local tableTop=station and station:FindFirstChild("CraftTable",true)
	local booth=anchorFrame(anchors,"Q03FairCraft")
	if booth then self.craftFrames.Booth={frame=tableTop and tableTop:IsA("BasePart") and tableTop.CFrame*CF(0,tableTop.Size.Y/2+.05,0) or booth*CF(0,2.05,0),scale=1} end
	-- Replace only obsolete Q03 marker/piece visuals, never the original furniture.
	if station then for _, child in ipairs(station:GetChildren()) do if child.Name~="CraftTable" then self:_hide(child) end end end
	local home=root:FindFirstChild("Home"); local room=home and home:FindFirstChild("Bedroom")
	local bookcase=room and room:FindFirstChild("FilledBookcase")
	local plinth=bookcase and bookcase:FindFirstChild("DisplayPlinth")
	if plinth and plinth:IsA("BasePart") then
		self.craftFrames.Bedroom={frame=plinth.CFrame*CF(0,plinth.Size.Y/2+.015,0),scale=.38}
		for _, child in ipairs(bookcase:GetChildren()) do
			if child.Name=="MiniatureFacade" or child.Name=="MiniatureDoor" or string.match(child.Name,"^MiniatureWindow") then self:_hide(child) end
		end
		self.craft:SetAttribute("OwnedRegion","Existing lower DisplayPlinth; original plinth, desk miniature and all other shelf contents preserved")
	else warn("PCW-22 lower miniature plinth unavailable; booth and authoritative UI remain available") end
	self:RenderCraft(nil,{}, {},nil)
end
local function tinyPiece(parent,id,frame,scale,orientation,ghost,lit)
	local model=folder(parent,"Piece_"..id,"Model"); local base=frame*CFrame.Angles(0,math.rad((orientation or 0)*90),0)
	local function p(name,size,offset,token,soft)
		local item=part(model,name,size*scale,base*CF(offset*scale),token,soft)
		if ghost then item.Transparency=.6 end
		return item
	end
	if id=="rug" then p("WovenRug",V(1.55,.08,1.1),V(0,.07,0),"sage")
	elseif id=="chair" then
		p("Seat",V(.9,.3,.8),V(0,.55,0),"sage",true); p("Back",V(.9,.9,.2),V(0,.9,-.35),"sage",true)
		for _, x in ipairs({-.3,.3}) do for _, z in ipairs({-.24,.24}) do p("Leg",V(.12,.4,.12),V(x,.22,z),"wood") end end
	elseif id=="bookcase" then
		p("Back",V(1,1.5,.16),V(0,.78,-.2),"wood")
		for _, y in ipairs({.13,.77,1.48}) do p("Shelf",V(1,.12,.55),V(0,y,0),"wood") end
		for index,token in ipairs({"forest","cream","blossom"}) do p("Book",V(.18,.45,.32),V((index-2)*.22,1.04,0),token) end
	elseif id=="side_table" then p("Top",V(.95,.13,.8),V(0,.8,0),"wood"); p("Stem",V(.2,.7,.2),V(0,.38,0),"wood"); p("Foot",V(.65,.1,.6),V(0,.05,0),"wood")
	elseif id=="plant" then
		p("Pot",V(.5,.48,.5),V(0,.25,0),"cream"); p("Stem",V(.1,.7,.1),V(0,.7,0),"forest")
		for _, x in ipairs({-.23,0,.23}) do p("Leaf",V(.38,.5,.25),V(x,.94+math.abs(x),0),"sage",true) end
	elseif id=="lamp" then
		p("Base",V(.55,.1,.55),V(0,.08,0),"wood"); p("Stem",V(.1,1,.1),V(0,.6,0),"wood")
		p("Shade",V(.65,.4,.65),V(0,1.23,0),lit and "golden" or "cream",true)
	end
	model:SetAttribute("Orientation",orientation or 0); model:SetAttribute("PreviewOnly",ghost==true)
	return model
end
function WorldFeedback:RenderCraft(roundId,committed,reservations,presentation)
	self.craft:ClearAllChildren(); self.craft:SetAttribute("RoundId",roundId)
	for name,placement in pairs(self.craftFrames) do
		local model=folder(self.craft,name,"Model"); local cf,s=placement.frame,placement.scale
		model:SetAttribute("SharedRoundId",roundId); model:SetAttribute("Presentation",presentation)
		part(model,"Base",V(7.2,.1,3.8)*s,cf,"wood")
		local count=0
		for index,id in ipairs(PARTS) do
			local socket=SOCKETS[id]; local entry=committed[id]; local hold=reservations[socket]
			local frame=cf*CF((((index-1)%3)-1)*2.25*s,.085*s,(math.floor((index-1)/3)-.5)*1.65*s)
			local pad=part(model,socket,V(1.8,.06,1.4)*s,frame,entry and "sage" or hold and "golden" or "cream")
			pad:SetAttribute("SocketId",socket); pad:SetAttribute("PartId",id)
			if name=="Booth" then
				-- Flat, bounded labels; never six large world billboards at a time.
				local gui=Instance.new("SurfaceGui"); gui.Name="SocketLabel"; gui.Face=Enum.NormalId.Top; gui.CanvasSize=Vector2.new(240,130); gui.Parent=pad
				local text=Instance.new("TextLabel"); text.Size=UDim2.fromScale(1,1); text.BackgroundTransparency=1; text.TextColor3=P.ink
				text.Font=Enum.Font.GothamBold; text.TextSize=26; text.TextWrapped=true
				text.Text=(entry and "✓ " or hold and "○ " or "")..LABELS[id]; text.Parent=gui
			end
			if entry or hold then tinyPiece(model,id,frame,s,entry and entry.orientation or hold.orientation,entry==nil,presentation=="lamp_on") end
			if entry then count+=1 end
		end
		local cue=part(model,"ProgressCue",V(.1,.1,.1),cf*CF(0,2.3*s,-1.8*s),"forest"); cue.Transparency=1
		label(cue,(count==6 and (presentation and "Keepsake finished" or "Ready for Phuong's finishing touch") or "Shared miniature · "..count.." of 6").."\nBooth + bedroom share this keepsake",250,V(0,.5,0))
		model.WorldPivot=cf
	end
end
function WorldFeedback:RenderReading(summary)
	if self.reading then self.reading:Destroy() end
	self.reading=folder(self.root,"Reading")
	-- A new helper's first highlight must not erase the last shared bookmark.
	if summary and summary.bookmark then self.lastBookmark=summary end
	local saved=summary and summary.bookmark and summary or self.lastBookmark
	local bookmark=saved and saved.bookmark
	for name,frame in pairs(self.readingFrames) do
		local model=folder(self.reading,name,"Model")
		local base=part(model,"SharedBookmarkCard",V(1.1,.07,.8),frame,"cream")
		if summary then part(model,"SavedChoiceAccent",V(.8,.025,.08),frame*CF(0,.05,.3),"sage") end
		if bookmark=="ribbon" then part(model,"Ribbon",V(.2,.045,1.05),frame*CF(0,.055,.13),"blossom")
		elseif bookmark=="pressed-flower" then
			part(model,"Stem",V(.06,.04,.5),frame*CF(0,.055,.14),"forest")
			for index=1,5 do local a=index*math.pi*2/5; part(model,"Petal",V(.24,.04,.2),frame*CF(math.cos(a)*.16,.07,-.16+math.sin(a)*.16),"blossom",true) end
			part(model,"FlowerCenter",V(.12,.05,.12),frame*CF(0,.08,-.16),"golden",true)
		elseif bookmark=="star-tab" then
			for index=1,3 do part(model,"StarTab",V(.5,.04,.16),frame*CF(0,.06,-.4)*CFrame.Angles(0,index*math.pi/3,0),"golden") end
		end
		local text=summary and (summary.bookmark and "Bookmark saved · "..summary.bookmarkLabel.."\n"..summary.reactionLabel or summary.acknowledgement..(saved and "\nLatest bookmark · "..saved.bookmarkLabel or "")) or "Read a quiet page · save a bookmark"
		label(base,text,225,V(0,.85,0)); model:SetAttribute("Bookmark",bookmark)
	end
end
function WorldFeedback:Destroy()
	if self.connection then self.connection:Disconnect() end
	self.queue={}; self.active=nil
	for item,values in pairs(self.hidden) do if item.Parent then item.Transparency,item.CanCollide,item.CanTouch,item.CanQuery=values[1],values[2],values[3],values[4] end end
	if self.originalPivot and self.actor.Parent then self.actor:PivotTo(self.originalPivot) end
	for item,values in pairs(self.actorParts) do if item.Parent then item.Anchored,item.CanCollide,item.CanTouch,item.CanQuery=values[1],values[2],values[3],values[4] end end
	self.jasper:Destroy(); self.root:Destroy()
end
return WorldFeedback
]=],
["roblox/mvp/shared/Anchors.luau"] = [=[local Anchors = {}

Anchors.Names = {
    GameplayBedroomArrival = "GameplayBedroomArrival",
    Q01Bed = "Q01Bed",
    JasperBedroomStart = "JasperBedroomStart",
    JasperFetchYard = "JasperFetchYard",
    Q03FairCraft = "Q03FairCraft",
    Q03BedroomDisplay = "Q03BedroomDisplay",
    Q04QuadReading = "Q04QuadReading",
    Q04BedroomKindle = "Q04BedroomKindle",
    Q05UDistrictVending = "Q05UDistrictVending",
    Q06FOBCounter = "Q06FOBCounter",
    Q06AladdinsCounter = "Q06AladdinsCounter",
    Q06Serving = "Q06Serving",
    FinalePatio = "FinalePatio",
    BirthdayLobbyQueue = "BirthdayLobbyQueue",
}

local function find(root, name)
    local value = root and root:FindFirstChild(name, true) or nil
    if value and value:GetAttribute("PlacementStatus") == "UNRESOLVED_LIVE_ANCHOR" then return nil end
    return value
end

function Anchors.Resolve(root)
    local result = {}
    local missing = {}
    for key, name in Anchors.Names do
        local instance = find(root, name)
        result[key] = instance
        if not instance then table.insert(missing, name) end
    end
    return result, missing
end

function Anchors.ResolveSource(root)
    local home = root:FindFirstChild("Home")
    local arrival = root:FindFirstChild("Arrival")
    local party = root:FindFirstChild("BirthdayCourtyard") or root:FindFirstChild("Party")
    local bedroom = home and home:FindFirstChild("Bedroom")
    local source = {
        HomeFloor = home and home:FindFirstChild("Floor"),
        FrontDoor = home and home:FindFirstChild("FrontDoor"),
        ArrivalSpawn = arrival and arrival:FindFirstChild("ArrivalSpawn"),
        Bedroom = bedroom,
        Bed = bedroom and bedroom:FindFirstChild("Bed", true),
        QuadBenchWest = root:FindFirstChild("QuadBenchWest", true),
        QuadBenchEast = root:FindFirstChild("QuadBenchEast", true),
        Party = party,
    }
    return source
end

return Anchors
]=],
["roblox/mvp/shared/AudioConfig.luau"] = [=[-- PCW-26. Install this same source under both PhuongMVP.shared roots.
-- These are the selected IDs, not an assertion of permission or audition.
return {
    Music = {
        Birthday = { id = "87992648461099", title = "Birthday song", volume = .22 },
        World = { id = "139568344220252", title = "Slow Mornings · gentle acoustic guitar", volume = .18 },
    },
    Effects = {
        SoftClick = { id = "88442833509532", volume = .18 },
        SuccessChime = { id = "103516326607012", volume = .22 },
        JasperBark = { id = "135016436724006", volume = .25 },
        JasperPant = { id = "6463651038", volume = .10 },
    },
    DefaultMusicVolume = .5,
    VolumeStep = .25,
    CrossfadeSeconds = .65,
    LoadTimeoutSeconds = 8,
    ReceiptLimit = 4096,
}
]=],
["roblox/mvp/shared/Config.luau"] = [=[local Config = {
    FirstRoundReward = 20,
    ReplayReward = 10,
    RollCost = 20,
    ActivityIds = { "Q01", "Q02", "Q03", "Q04", "Q05", "Q06" },
    EarningActivityIds = { Q01 = true, Q02 = true, Q03 = true, Q04 = true, Q06 = true },
    RegularFigureIds = { "BigIntoEnergy01", "BigIntoEnergy02", "BigIntoEnergy03", "BigIntoEnergy04", "BigIntoEnergy05", "BigIntoEnergy06" },
    SecretFigureId = "BigIntoEnergySecret",
    RegularProbability = 0.165,
    SecretProbability = 0.01,
    WantedGuaranteeRoll = 5,
    PhuongUsername = "Phamlet707",
    PhuongUserId = 3971290001,
    HostUsername = "IamBannedrew",
    HostUserId = 1078077474,
}

return Config
]=],
["roblox/mvp/shared/FigureCatalog.luau"] = [=[-- Session IDs/probabilities stay in Config. These are palette-constrained toy
-- interpretations, not reference-approved Big into Energy colors or likenesses.
local Config = require(script.Parent.Config)
local Catalog = { Figures = {}, ById = {} }
local styles = {
	{ label = "Love", body = "blossom", accent = "golden", badge = "heart" },
	{ label = "Happiness", body = "golden", accent = "cream", badge = "sun" },
	{ label = "Loyalty", body = "forest", accent = "sage", badge = "pair" },
	{ label = "Serenity", body = "sage", accent = "cream", badge = "moon" },
	{ label = "Hope", body = "cream", accent = "blossom", badge = "bow" },
	{ label = "Luck", body = "wood", accent = "golden", badge = "clover" },
	{ label = "Secret · ID", body = "brick", accent = "ink", badge = "star" },
}
for index, style in ipairs(styles) do
	local entry = {
		id = Config.RegularFigureIds[index] or Config.SecretFigureId,
		label = style.label, body = style.body, accent = style.accent, badge = style.badge,
		secret = index == 7, probability = index == 7 and Config.SecretProbability or Config.RegularProbability,
		odds = index == 7 and "Secret · 1%" or "Regular · 16.5%",
	}
	table.insert(Catalog.Figures, entry); Catalog.ById[entry.id] = entry
end
function Catalog.Label(id) return Catalog.ById[id] and Catalog.ById[id].label or "Choose a figure" end
return Catalog
]=],
["roblox/mvp/shared/FigurePresentation.luau"] = [=[-- Bounded native geometry shared by world displays and client ViewportFrames.
-- All figures retain paired long ears, a cream face, eyes, a toothy smile,
-- rounded body and feet. Labels distinguish the seven simplified toy styles.
local Catalog = require(script.Parent.FigureCatalog)
local Presentation = {}
Presentation.Palette = {
	forest = Color3.fromRGB(54, 87, 68), sage = Color3.fromRGB(168, 185, 149),
	cream = Color3.fromRGB(245, 240, 228), wood = Color3.fromRGB(149, 103, 75),
	blossom = Color3.fromRGB(232, 183, 198), brick = Color3.fromRGB(182, 108, 104),
	golden = Color3.fromRGB(232, 199, 121), ink = Color3.fromRGB(38, 56, 46),
}
function Presentation.Part(parent, name, size, cf, token, shape)
	local value = Instance.new("Part")
	value.Name, value.Size, value.CFrame = name, size, cf
	value.Shape = shape or Enum.PartType.Block
	value.Color, value.Material, value.CastShadow = Presentation.Palette[token], Enum.Material.SmoothPlastic, false
	value.Anchored, value.CanCollide, value.CanTouch, value.CanQuery = true, false, false, false
	value:SetAttribute("PaletteToken", token); value:SetAttribute("VerificationTicket", "PCW-21")
	value.Parent = parent; return value
end
function Presentation.Build(id, scale)
	local entry = assert(Catalog.ById[id], "Unknown figure presentation")
	local model = Instance.new("Model"); model.Name = "Figure"; model.WorldPivot = CFrame.identity
	model:SetAttribute("FigureId", id); model:SetAttribute("FigureLabel", entry.label)
	model:SetAttribute("SimplifiedArt", true); model:SetAttribute("VerificationTicket", "PCW-21")
	scale = scale or 1
	local function shape(name, size, position, token, block, rotation)
		return Presentation.Part(model, name, size * scale, CFrame.new(position * scale) * (rotation or CFrame.identity), token, block and Enum.PartType.Block or Enum.PartType.Ball)
	end
	shape("Body", Vector3.new(1.04, 1.2, .72), Vector3.new(0, .88, 0), entry.body)
	shape("Head", Vector3.new(1.32, 1.08, .84), Vector3.new(0, 1.8, 0), entry.body)
	shape("Face", Vector3.new(1.05, .78, .23), Vector3.new(0, 1.76, -.4), "cream")
	for _, side in ipairs({ -1, 1 }) do
		local tilt = CFrame.Angles(0, 0, -side * .12)
		shape("LongEar", Vector3.new(.37, 1, .35), Vector3.new(side * .38, 2.58, .01), entry.body, false, tilt)
		shape("InnerEar", Vector3.new(.16, .67, .08), Vector3.new(side * .38, 2.58, -.17), entry.accent, false, tilt)
		shape("Eye", Vector3.new(.13, .17, .07), Vector3.new(side * .24, 1.89, -.53), "ink")
		shape("Arm", Vector3.new(.29, .65, .35), Vector3.new(side * .57, .99, -.01), entry.body, false, CFrame.Angles(0, 0, side * .18))
		shape("Foot", Vector3.new(.45, .27, .55), Vector3.new(side * .3, .16, -.12), entry.body)
	end
	shape("ToothySmile", Vector3.new(.55, .2, .06), Vector3.new(0, 1.57, -.53), "ink")
	for index = 1, 5 do shape("Tooth", Vector3.new(.065, .095, .035), Vector3.new((index - 3) * .09, 1.605, -.568), "cream", true) end
	-- Distinct small chest motifs, never a replacement for the paired-ear shape.
	local badge = Vector3.new(0, .98, -.37)
	if entry.badge == "heart" then
		for _, side in ipairs({ -1, 1 }) do shape("Heart", Vector3.new(.24, .34, .07), badge + Vector3.new(side * .085, 0, 0), entry.accent, false, CFrame.Angles(0, 0, side * -.55)) end
	elseif entry.badge == "pair" or entry.badge == "bow" then
		for _, side in ipairs({ -1, 1 }) do shape("PairedBadge", Vector3.new(.23, .22, .08), badge + Vector3.new(side * .13, 0, 0), entry.accent) end
	elseif entry.badge == "clover" then
		for index = 1, 4 do local angle = index * math.pi / 2; shape("Clover", Vector3.new(.2, .2, .07), badge + Vector3.new(math.cos(angle) * .11, math.sin(angle) * .11, 0), entry.accent) end
	elseif entry.badge == "star" then
		shape("SecretBadge", Vector3.new(.3, .3, .07), badge, entry.accent, true, CFrame.Angles(0, 0, math.pi / 4))
	else
		shape("RoundBadge", Vector3.new(.34, .34, .08), badge, entry.accent)
		if entry.badge == "moon" then shape("MoonCutout", Vector3.new(.26, .26, .04), badge + Vector3.new(.1, .05, -.05), entry.body) end
	end
	return model
end
function Presentation.Capsule(scale, opened)
	scale = scale or 1
	local model = Instance.new("Model"); model.Name = "Capsule"; model.WorldPivot = CFrame.identity
	model:SetAttribute("VerificationTicket", "PCW-21")
	Presentation.Part(model, "Lower", Vector3.new(1.5, .9, 1.5) * scale, CFrame.new(0, .45 * scale, 0), "golden", Enum.PartType.Ball)
	Presentation.Part(model, "Upper", Vector3.new(1.5, .9, 1.5) * scale, CFrame.new(0, (opened and 1.8 or 1.02) * scale, 0), "cream", Enum.PartType.Ball)
	Presentation.Part(model, "Seam", Vector3.new(.08, 1.49, 1.49) * scale, CFrame.new(0, .74 * scale, 0) * CFrame.Angles(0, 0, math.pi / 2), "forest", Enum.PartType.Cylinder)
	return model
end
return Presentation
]=],
["roblox/mvp/shared/FoodPresentation.luau"] = [=[-- Deterministic presentation only. Server and local preview use the same shapes.
-- No rewards, permissions, remote requests or user transforms belong here.
local FoodPresentation = {}
local P = {
	forest = Color3.fromRGB(54, 87, 68), sage = Color3.fromRGB(168, 185, 149),
	cream = Color3.fromRGB(245, 240, 228), wood = Color3.fromRGB(149, 103, 75),
	blossom = Color3.fromRGB(232, 183, 198), brick = Color3.fromRGB(182, 108, 104),
	golden = Color3.fromRGB(232, 199, 121), ink = Color3.fromRGB(38, 56, 46),
}
local LABELS = { rice = "Rice", tofu = "Tofu", chicken = "Chicken", mushroom = "Mushroom", greens = "Greens", cucumber = "Cucumber", carrot = "Carrot", sauce = "Sauce", sesame = "Sesame", plate = "Plate", cup = "Cup", napkin = "Napkin" }
local ORDER = { "base", "protein", "toppings", "sauce", "settingA", "settingB" }
local function part(parent, name, size, frame, token, shape)
	local value = Instance.new("Part")
	value.Name, value.Size, value.CFrame = name, size, frame
	value.Shape = shape or Enum.PartType.Block
	value.Anchored, value.CanCollide, value.CanTouch, value.CanQuery = true, false, false, false
	value.Color, value.Material, value.CastShadow = P[token], Enum.Material.SmoothPlastic, false
	value:SetAttribute("PaletteToken", token); value:SetAttribute("VerificationTicket", "PCW-20")
	value.Parent = parent; return value
end
local function disc(parent, name, diameter, height, frame, token)
	return part(parent, name, Vector3.new(height, diameter, diameter), frame * CFrame.Angles(0, 0, math.pi / 2), token, Enum.PartType.Cylinder)
end
local function round(parent, name, size, frame, token)
	return part(parent, name, size, frame, token, Enum.PartType.Ball)
end
local function ingredient(parent, slot, item)
	local model = Instance.new("Model"); model.Name = slot; model.Parent = parent
	model:SetAttribute("SlotId", slot); model:SetAttribute("ItemId", item); model:SetAttribute("ItemLabel", LABELS[item])
	local y = .65
	if item == "rice" then
		disc(model, "RiceBase", 2.05, .16, CFrame.new(0, .49, 0), "cream")
		for index = 1, 8 do
			local angle = index * math.pi / 4
			round(model, "RiceGrain", Vector3.new(.27, .1, .12), CFrame.new(math.cos(angle) * .7, .6, math.sin(angle) * .7) * CFrame.Angles(0, angle, 0), "cream")
		end
	elseif item == "tofu" or item == "chicken" then
		for index = 1, 4 do
			local frame = CFrame.new(-.55 + (index % 2) * .65, y + .08, -.62 + math.floor((index - 1) / 2) * .6) * CFrame.Angles(0, index * .35, 0)
			if item == "tofu" then part(model, "TofuCube", Vector3.new(.45, .34, .45), frame, "cream")
			else round(model, "ChickenPiece", Vector3.new(.58, .34, .42), frame, "golden") end
		end
	elseif item == "mushroom" then
		for index = 1, 3 do
			local frame = CFrame.new(-.72 + index * .38, y, -.45 + (index % 2) * .43)
			part(model, "MushroomStem", Vector3.new(.14, .3, .15), frame, "cream")
			round(model, "MushroomCap", Vector3.new(.52, .23, .43), frame * CFrame.new(0, .17, 0), "wood")
		end
	elseif item == "greens" then
		for index = 1, 5 do round(model, "Leaf", Vector3.new(.38, .12, .55), CFrame.new(-.8 + index * .29, y + .1, .53 + (index % 2) * .15) * CFrame.Angles(0, index * .75, .2), "sage") end
	elseif item == "cucumber" then
		for index = 1, 4 do
			local frame = CFrame.new(-.7 + (index - 1) * .45, y + .07, .5)
			disc(model, "CucumberSkin", .48, .1, frame, "forest")
			disc(model, "CucumberCenter", .36, .11, frame * CFrame.new(0, .01, 0), "sage")
		end
	elseif item == "carrot" then
		for index = 1, 5 do part(model, "CarrotStrip", Vector3.new(.12, .1, .65), CFrame.new(-.65 + index * .22, y + .12, .52) * CFrame.Angles(0, index * .17, 0), "golden") end
	elseif item == "sauce" then
		for index = 1, 3 do part(model, "SauceDrizzle", Vector3.new(1.6, .06, .09), CFrame.new(0, 1, -.5 + index * .32) * CFrame.Angles(0, -.25, 0), "wood") end
	elseif item == "sesame" then
		for index = 1, 9 do
			local angle = index * 2.4
			round(model, "SesameSeed", Vector3.new(.12, .06, .07), CFrame.new(math.cos(angle) * (.25 + index * .045), 1, math.sin(angle) * (.25 + index * .045)) * CFrame.Angles(0, angle, 0), "golden")
		end
	elseif item == "plate" then
		disc(model, "PlateRim", 1.9, .12, CFrame.new(-2.25, .14, 0), "cream")
		disc(model, "PlateWell", 1.5, .04, CFrame.new(-2.25, .21, 0), "sage")
	elseif item == "cup" then
		disc(model, "CupBody", .8, .85, CFrame.new(2.15, .49, 0), "cream")
		disc(model, "CupInside", .62, .04, CFrame.new(2.15, .925, 0), "wood")
		part(model, "CupHandle", Vector3.new(.26, .38, .17), CFrame.new(2.65, .54, 0), "cream")
	elseif item == "napkin" then
		local x = slot == "settingA" and -2.25 or 2.15
		part(model, "FoldedNapkin", Vector3.new(1.25, .09, .95), CFrame.new(x, .16, 0) * CFrame.Angles(0, .13, 0), "sage")
		part(model, "NapkinFold", Vector3.new(.6, .035, .95), CFrame.new(x + .25, .22, 0) * CFrame.Angles(0, .13, 0), "cream")
	end
	return model
end
function FoodPresentation.Build(accepted, held)
	local model = Instance.new("Model"); model.Name = "SharedDish"
	model:SetAttribute("VerificationTicket", "PCW-20"); model.WorldPivot = CFrame.identity
	part(model, "ServingMat", Vector3.new(6.5, .06, 2.8), CFrame.new(0, .03, 0), "wood")
	disc(model, "BowlFoot", 1.5, .12, CFrame.new(0, .13, 0), "cream")
	disc(model, "BowlBody", 2.5, .36, CFrame.new(0, .33, 0), "cream")
	disc(model, "BowlInside", 2.15, .025, CFrame.new(0, .52, 0), "sage")
	for _, slot in ipairs(ORDER) do
		local choice = accepted and accepted[slot]
		local item = type(choice) == "table" and choice.itemId or nil
		if item and LABELS[item] then ingredient(model, slot, item) end
	end
	-- Local-only preview. Server never passes a hold to shared world rendering.
	if held and LABELS[held.itemId] and not (accepted and accepted[held.slotId]) and table.find(ORDER, held.slotId) then
		local selection = ingredient(model, held.slotId, held.itemId)
		selection.Name = "SelectedPreview"; selection:SetAttribute("PreviewOnly", true)
	end
	return model
end
return FoodPresentation
]=],
["roblox/mvp/shared/Guidance.luau"] = [=[-- Presentation data only. Nothing in this module grants a reward or permission.
local Guidance = {}

Guidance.Order = { "Q01", "Q02", "Q03", "Q04", "Q05", "Q06" }
Guidance.Activities = {
	Q01 = { title = "Everything Tucked In", short = "Make her room cozy", destination = "Phuong's bedroom", anchors = { "Q01Bed" }, hint = "Choose a bed or shelf task. Friends help; Phuong adds the finishing touch.", reward = "First completion adds 20 to the shared fund." },
	Q02 = { title = "Jasper's Favorite Things", short = "Play with Jasper", destination = "Bedroom, then Jasper's yard", anchors = { "JasperBedroomStart", "JasperFetchYard" }, hint = "Say hello to Jasper, find his rabbit in the yard, then play fetch.", reward = "First completion adds 20 to the shared fund." },
	Q03 = { title = "A Tiny World of Her Own", short = "Build a tiny keepsake", destination = "UDistrict craft booth", anchors = { "Q03FairCraft", "Q03BedroomDisplay" }, hint = "Choose a tiny piece, turn it if you like, then place it in the miniature.", reward = "First completion adds 20 to the shared fund." },
	Q04 = { title = "One More Chapter", short = "Share a quiet chapter", destination = "Quad blossoms or bedroom Kindle", anchors = { "Q04QuadReading", "Q04BedroomKindle" }, hint = "Read a page. Pick a highlight, a reaction and a bookmark, then save.", reward = "First completion adds 20 to the shared fund." },
	Q05 = { title = "A Labubu Wish", short = "Help Phuong get her Labubu", destination = "UDistrict Labubu booth", anchors = { "Q05UDistrictVending" }, hint = "Phuong chooses her wish. Each box uses 20 from the shared fund; her wish arrives by the fifth box.", reward = "Getting her wanted Labubu adds the sixth activity's petal." },
	Q06 = { title = "Something Delicious", short = "Make a meal together", destination = "FOB, Aladdins, then the serving table", anchors = { "Q06FOBCounter", "Q06AladdinsCounter", "Q06Serving" }, hint = "Build a bowl at FOB, add sauce at Aladdins, then set the serving table.", reward = "First completion adds 20 to the shared fund." },
	Cake = { title = "Happy Birthday, Phuong!", short = "Gather for birthday cake", destination = "Birthday patio", anchors = { "FinalePatio" }, hint = "Follow the marker to the birthday table and gather with your friends.", reward = "Enjoy the birthday moment together." },
}

Guidance.Reasons = {
	TooFar = "Walk closer to the marked activity, then try again.",
	BadSessionId = "The birthday session refreshed. Please reopen this activity.",
	NotPresent = "Enter the birthday world first.",
	ActivityUnavailable = "This activity is not ready yet. Try another petal or ask a host for help.",
	RoundRejected = "This activity changed while you were joining. Please reopen it.",
	ActionRejected = "That step could not be completed. Check the next step and try again.",
	ReplayUnavailable = "Finish this shared round before starting another.",
	CakeRejected = "The birthday table is not ready for that yet. Follow the next step shown here.",
	SLOT_BUSY = "A friend is using this spot. Choose another or try again shortly.",
	empty_basket = "This basket is empty. Try another basket in Jasper's yard.",
	fetch_target_occupied = "Jasper is still fetching. Give him a moment.",
	["not authorized"] = "This choice belongs to Phuong. Andrew can help when the game allows it.",
}

function Guidance.PetalCount(petals)
	if type(petals) == "number" then return math.clamp(petals, 0, 6) end
	local count = 0
	if type(petals) == "table" then
		for _, id in ipairs(Guidance.Order) do if petals[id] == true then count += 1 end end
	end
	return count
end

function Guidance.Complete(snapshot, id)
	return type(snapshot.petals) == "table" and snapshot.petals[id] == true
end

function Guidance.Text(value, fallback)
	if type(value) ~= "string" or value == "" then return fallback or "" end
	-- Error tracebacks, Lua table addresses and machine enum tokens are never UI copy.
	if string.find(value, "table:", 1, true) or string.find(value, "Stack Begin", 1, true)
		or string.find(value, ".luau:", 1, true) or string.match(value, "^[%u%d_]+$") then
		return fallback or ""
	end
	return value
end

function Guidance.FriendlyError(code, detail)
	if type(code) == "string" and Guidance.Reasons[code] then return Guidance.Reasons[code] end
	if type(detail) == "string" and Guidance.Reasons[detail] then return Guidance.Reasons[detail] end
	-- Unstructured server exception strings may contain paths, IDs or object addresses.
	return "That step did not go through. Reopen the activity to see what is available."
end

function Guidance.AnchorNames(id, view)
	local info = Guidance.Activities[id]
	if not info then return {} end
	if view and type(view.guide) == "table" and type(view.guide.nextAnchor) == "string" then
		return { view.guide.nextAnchor }
	end
	if id == "Q02" then
		if view and view.state ~= "GREETING" and view.state ~= "IDLE" then return { "JasperFetchYard" } end
		return { "JasperBedroomStart" }
	end
	if id == "Q03" then
		return view and view.state == "COMPLETED" and { "Q03BedroomDisplay" } or { "Q03FairCraft" }
	end
	if id == "Q06" and view then
		for _, descriptor in ipairs(view.availableActions or {}) do
			if descriptor.enabled ~= false then
				local slot = descriptor.payload and descriptor.payload.slotId
				if slot == "sauce" then return { "Q06AladdinsCounter" } end
				if slot == "settingA" or slot == "settingB" then return { "Q06Serving" } end
				return { "Q06FOBCounter" }
			end
		end
	end
	if id == "Q06" then return { "Q06FOBCounter" } end
	return info.anchors
end

-- distances is supplied by Navigator; this module has no world/service dependency.
function Guidance.Recommend(snapshot, distances, views)
	if Guidance.PetalCount(snapshot.petals) == 6 then return "Cake" end
	local best, score = nil, math.huge
	for _, id in ipairs(Guidance.Order) do
		if not Guidance.Complete(snapshot, id) and id ~= "Q05" then
			local view = views[id]
			local available = not view or view.state ~= "UNAVAILABLE"
			if available then
				local distance = distances[id] or math.huge
				if distance < score then best, score = id, distance end
			end
		end
	end
	local funded = (tonumber(snapshot.fundBalance or snapshot.fund) or 0) >= 20
	if funded and not Guidance.Complete(snapshot, "Q05") and (not best or score > 32 or (distances.Q05 or math.huge) < score) then return "Q05" end
	if best then return best end
	for _, id in ipairs(Guidance.Order) do if not Guidance.Complete(snapshot, id) then return id end end
	return "Cake"
end

function Guidance.Confirmation(descriptor)
	if type(descriptor.confirm) == "table" then return descriptor.confirm end
	if descriptor.confirm == false then return nil end
	local payload = d]==]
return #_G.__PCW25ContractText