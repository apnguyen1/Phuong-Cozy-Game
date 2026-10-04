-- PCW-22: bounded server presentation. No rewards, physics, camera or map rebuild.
local RunService = game:GetService("RunService")
local WorldFeedback = {}; WorldFeedback.__index = WorldFeedback
local V, CF = Vector3.new, CFrame.new
local P = {
	forest=Color3.fromHex("365744"), sage=Color3.fromHex("A8B995"), cream=Color3.fromHex("F5F0E4"),
	wood=Color3.fromHex("95674B"), blossom=Color3.fromHex("E8B7C6"), brick=Color3.fromHex("B66C68"),
	golden=Color3.fromHex("E8C779"), ink=Color3.fromHex("26382E"),
}
local PARTS = {"rug", "chair", "bookcase", "side_table", "plant", "lamp"}
local LABELS = {rug="Rug", chair="Chair", bookcase="Bookcase", side_table="Side table", plant="Plant", lamp="Lamp"}
local SOCKETS = {rug="rugSocket", chair="chairSocket", bookcase="bookcaseSocket", side_table="sideTableSocket", plant="plantSocket", lamp="lampSocket"}
local function folder(parent, name, class)
	local item=Instance.new(class or "Folder"); item.Name=name; item.Parent=parent; return item
end
local function part(parent, name, size, frame, token, soft)
	local unique,index=name,1
	while parent:FindFirstChild(unique) do index+=1; unique=name.."_"..index end
	local item=Instance.new("Part"); item.Name=unique; item.Size=size; item.CFrame=frame; item.Color=P[token]
	item.Anchored, item.CanCollide, item.CanTouch, item.CanQuery = true, false, false, false
	item.Material=Enum.Material.SmoothPlastic; item.TopSurface=Enum.SurfaceType.Smooth; item.BottomSurface=Enum.SurfaceType.Smooth
	item:SetAttribute("PaletteToken",token); item:SetAttribute("VerificationTicket","PCW-22"); item.Parent=parent
	if soft then local mesh=Instance.new("SpecialMesh"); mesh.MeshType=Enum.MeshType.Sphere; mesh.Parent=item end
	return item
end
local function label(target, text, width, offset)
	local gui=Instance.new("BillboardGui"); gui.Name="ActivityCaption"; gui.Adornee=target
	gui.Size=UDim2.fromOffset(width or 210,50); gui.StudsOffsetWorldSpace=offset or V(0,1,0)
	gui.MaxDistance=30; gui.AlwaysOnTop=false; gui.Parent=target
	local value=Instance.new("TextLabel"); value.Name="Caption"; value.Size=UDim2.fromScale(1,1)
	value.BackgroundColor3=P.cream; value.TextColor3=P.ink; value.BorderSizePixel=0; value.TextWrapped=true
	value.Font=Enum.Font.GothamMedium; value.TextSize=14; value.Text=text; value.Parent=gui
	return value
end
local function anchorFrame(anchors, name)
	local item=anchors[name]; return item and item:IsA("BasePart") and item.CFrame or nil
end
local function face(a, b)
	local direction=V(b.X-a.X,0,b.Z-a.Z)
	return direction.Magnitude>.01 and CFrame.lookAt(a,a+direction) or CF(a)
end
function WorldFeedback:_hide(item)
	if not item then return end
	local items=item:IsA("BasePart") and {item} or item:GetDescendants()
	for _, value in ipairs(items) do
		if value:IsA("BasePart") then
			self.hidden[value]={value.Transparency,value.CanCollide,value.CanTouch,value.CanQuery}
			value.Transparency, value.CanCollide, value.CanTouch, value.CanQuery=1,false,false,false
		end
	end
end

local function makeDog(parent)
	local model=folder(parent,"Actor","Model")
	model:SetAttribute("JasperActor",true); model:SetAttribute("SimplifiedGeometry",true)
	model:SetAttribute("ArtStatus","Palette-native simplified Pomeranian; independent visual review pending")
	local function p(name,size,position,token) return part(model,name,size,CF(position),token,true) end
	p("FluffyBody",V(2.25,1.75,2.65),V(0,1.45,.3),"wood")
	p("CreamRuff",V(2.6,2.15,1.7),V(0,1.95,-.6),"cream")
	p("Chest",V(1.6,1.6,1.6),V(0,1.3,-.75),"cream")
	p("Head",V(1.95,1.75,1.8),V(0,2.65,-1.05),"wood")
	p("Muzzle",V(1.1,.7,.75),V(0,2.33,-1.97),"cream")
	p("Nose",V(.29,.25,.2),V(0,2.43,-2.36),"ink")
	for _, side in ipairs({-1,1}) do
		p("Eye",V(.22,.26,.14),V(side*.46,2.78,-1.9),"ink")
		local ear=Instance.new("WedgePart"); ear.Name=side<0 and "PointedEarLeft" or "PointedEarRight"; ear.Size=V(.68,1.05,.6)
		ear.CFrame=CF(side*.7,3.43,-1.01)*CFrame.Angles(0,math.pi,side*-.15)
		ear.Color=P.wood; ear.Anchored=true; ear.CanCollide=false; ear.CanTouch=false; ear.CanQuery=false
		ear:SetAttribute("PaletteToken","wood"); ear:SetAttribute("VerificationTicket","PCW-22"); ear.Parent=model
		for _, z in ipairs({-.55,1.03}) do p("ShortLeg",V(.57,.88,.65),V(side*.72,.45,z),"wood") end
	end
	for index=1,5 do
		local angle=(index-1)*math.pi/4
		p("CurledTail",V(.85,.9,.88),V(0,1.85+math.sin(angle)*.82,1.48+math.cos(angle)*.65),"cream")
	end
	for index=1,6 do
		local angle=index*math.pi/3
		p("RuffTuft",V(.75,.8,.85),V(math.cos(angle)*1.02,1.95+math.sin(angle)*.82,-.6),"cream")
	end
	model.WorldPivot=CF(); return model -- 25 anchored/noncolliding parts; pivot is at feet.
end
local function findDog(root, runtime)
	for _, item in ipairs(root:GetDescendants()) do
		if item:IsA("Model") and not item:IsDescendantOf(runtime) and (item.Name=="Jasper" or item:GetAttribute("JasperActor")==true) then
			local parent, plush=item.Parent,false
			while parent and parent~=root do
				if string.find(string.lower(parent.Name),"plush",1,true) then plush=true end
				parent=parent.Parent
			end
			if not plush and not string.find(string.lower(item.Name),"plush",1,true) and item:FindFirstChildWhichIsA("BasePart",true) then return item end
		end
	end
end
function WorldFeedback.new(root, mvp, anchors)
	local runtime=mvp:FindFirstChild("RuntimePresentation") or folder(mvp,"RuntimePresentation")
	assert(not runtime:FindFirstChild("WorldFeedback") and not runtime:FindFirstChild("Jasper"),"WorldFeedback is already running")
	local self=setmetatable({root=folder(runtime,"WorldFeedback"),jasper=folder(runtime,"Jasper"),hidden={},queue={},elapsed=0,actorParts={}},WorldFeedback)
	self.root:SetAttribute("VerificationTicket","PCW-22"); self.jasper:SetAttribute("VerificationTicket","PCW-22")
	self.bedroom=anchorFrame(anchors,"JasperBedroomStart")
	self.yard=anchorFrame(anchors,"JasperFetchYard")
	if self.bedroom then self.bedroom+=V(0,.1,0) end
	if self.yard then self.yard+=V(0,.1,0) end
	local home=root:FindFirstChild("Home"); local door=home and home:FindFirstChild("DoorInteraction")
	local porch=home and home:FindFirstChild("PorchDeck")
	if door and door:IsA("BasePart") and self.yard then
		self.doorPosition=V(door.Position.X,self.yard.Y,door.Position.Z)
		if porch and porch:IsA("BasePart") then
			local outward=V(porch.Position.X-door.Position.X,0,porch.Position.Z-door.Position.Z)
			if outward.Magnitude>.1 then self.porchPosition=self.doorPosition+outward.Unit*12 end
		end
	end
	if self.bedroom and self.yard then
		self.actor=findDog(root,runtime)
		if self.actor then
			self.originalPivot=self.actor:GetPivot()
			local box,size=self.actor:GetBoundingBox()
			self.footOffset=self.originalPivot:ToObjectSpace(CF(box.Position-V(0,size.Y/2,0)))
			for _, item in ipairs(self.actor:GetDescendants()) do
				if item:IsA("BasePart") then
					self.actorParts[item]={item.Anchored,item.CanCollide,item.CanTouch,item.CanQuery}
					item.Anchored,item.CanCollide,item.CanTouch,item.CanQuery=true,false,false,false
				end
			end
		else self.actor=makeDog(self.jasper); self.footOffset=CF() end
		self.cue=part(self.jasper,"JasperCue",V(.1,.1,.1),self.bedroom,"forest"); self.cue.Transparency=1
		self.jasperText=label(self.cue,"Jasper · say hello in the bedroom",240,V(0,4.4,0))
		self.rabbit=folder(self.jasper,"RabbitToy","Model")
		part(self.rabbit,"Body",V(.65,.65,.9),CF(0,.35,0),"cream",true)
		part(self.rabbit,"Head",V(.55,.55,.5),CF(0,.8,-.2),"cream",true)
		for _, x in ipairs({-.17,.17}) do
			part(self.rabbit,"LongEar",V(.18,.65,.18),CF(x,1.3,-.18),"cream",true)
			part(self.rabbit,"Eye",V(.06,.06,.05),CF(x,.85,-.46),"ink",true)
		end
		self.rabbit.WorldPivot=CF()
		self.ball=part(self.jasper,"FetchToy",V(.6,.6,.6),self.yard,"blossom",true)
		self.target=part(self.jasper,"FetchTarget",V(3,.05,3),self.yard,"golden")
		self.targetText=label(self.target,"Gentle throw · no aiming needed",210,V(0,.7,0))
		self.treat=part(self.jasper,"Greenie",V(.32,.25,1.1),self.yard,"forest")
		local stations=mvp:FindFirstChild("Stations"); local q02=stations and stations:FindFirstChild("Q02Station")
		for _, name in ipairs({"JasperBedroomGreeting","JasperFetchLane","JasperRabbitHandoff","JasperGreenie"}) do self:_hide(q02 and q02:FindFirstChild(name,true)) end
		self.baskets={}
		for index=1,3 do
			local original=q02 and q02:FindFirstChild("JasperRabbitBasket"..string.char(64+index),true)
			local frame=original and original:IsA("BasePart") and original.CFrame or self.yard*CF((index-2)*4,1,5)
			local cue=part(self.jasper,"BasketLabel"..index,V(.1,.1,.1),frame,"wood"); cue.Transparency=1
			self.baskets[index]=frame; label(cue,"Basket "..index,120,V(0,1.7,0))
		end
		self:ResetJasper()
	end
	self:_setupCraft(root,mvp,anchors)
	self.readingFrames={}
	for _, name in ipairs({"Q04QuadReading","Q04BedroomKindle"}) do
		local frame=anchorFrame(anchors,name)
		if frame then self.readingFrames[name]=frame*CF(name=="Q04BedroomKindle" and 1.1 or 1.3,name=="Q04BedroomKindle" and .23 or 1.3,0) end
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
