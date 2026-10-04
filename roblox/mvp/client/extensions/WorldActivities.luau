-- Q02/Q03/Q04 presentation using PCW-18's function-based extension context.
-- The world and descriptors remain server-authored; no camera/avatar control.
local Module = {}
local function runtime()
	local world=workspace:FindFirstChild("CozyWorld_Draft01")
	local mvp=world and world:FindFirstChild("MVP")
	return mvp and mvp:FindFirstChild("RuntimePresentation")
end
local function craftRoot()
	local root=runtime(); local feedback=root and root:FindFirstChild("WorldFeedback")
	return feedback and feedback:FindFirstChild("Craft")
end
local function preview(parent, source, UI)
	if not source or not source:IsA("Model") then return end
	local viewport=Instance.new("ViewportFrame"); viewport.Name="MiniaturePreview"
	viewport.Size=UDim2.new(1,0,0,155); viewport.BackgroundColor3=UI.Palette.cream; viewport.BorderSizePixel=0
	viewport.Ambient,viewport.LightColor=UI.Palette.cream,UI.Palette.golden
	viewport.LightDirection=Vector3.new(-1,-1,-1); viewport.LayoutOrder=2; viewport.Parent=parent; UI.Corner(viewport,10)
	local clone=source:Clone(); if not clone then viewport:Destroy(); return end
	for _, child in ipairs(clone:GetDescendants()) do
		if child:IsA("BasePart") then child.Anchored,child.CanCollide,child.CanTouch,child.CanQuery=true,false,false,false
		elseif not child:IsA("SpecialMesh") and not child:IsA("Model") and not child:IsA("Folder") then child:Destroy() end
	end
	clone.Parent=viewport
	local frame,size=clone:GetBoundingBox(); local camera=Instance.new("Camera"); camera.FieldOfView=34
	local distance=math.max(size.X,size.Y,size.Z)*1.8
	camera.CFrame=CFrame.lookAt(frame.Position+source:GetPivot():VectorToWorldSpace(Vector3.new(0,4,7)).Unit*distance,frame.Position)
	camera.Parent=viewport; viewport.CurrentCamera=camera
end
function Module.Init(getContext, registry)
	local panel=getContext().gui:FindFirstChild("ActivityPanel")
	local activeCue, noteBuffer
	local function clearCue()
		if activeCue then activeCue:Destroy(); activeCue=nil end
	end
	if panel then panel:GetPropertyChangedSignal("Visible"):Connect(function()
		if not panel.Visible then clearCue(); noteBuffer=nil end
	end) end
	registry.RegisterActivity("Q02",function(container,view,context)
		local UI=context.UI; UI.List(container,8); container.LayoutOrder=60
		local main=container.Parent:FindFirstChild("MainAction")
		if main and not view.atStation then main.Visible=false end
		local card=UI.Card(container,"JasperProgress","cream")
		UI.Label(card,"JasperStep","Jasper's day together",17,UI.Palette.forest).LayoutOrder=1
		local steps={{"greet","Bedroom hello"},{"rabbitFound","Rabbit found in a numbered basket"},{"rabbitReturned","Rabbit returned to Jasper"},{"fetch1","First toy returned"},{"fetch2","Second toy returned"},{"fetch3","Third toy returned"},{"greenie","Greenie + shared petal saved"}}
		local lines={}
		for _,step in ipairs(steps) do table.insert(lines,(view.acceptedStepIds and view.acceptedStepIds[step[1]] and "✓ " or "○ ")..step[2]) end
		UI.Label(card,"SavedSteps",table.concat(lines,"\n"),14).LayoutOrder=2
		UI.Label(card,"SharedPlay","Everyone nearby sees Jasper move and fetch. Friends can take turns; accepted steps stay saved if anyone closes or leaves.",14).LayoutOrder=3
		if view.state=="FETCH" then UI.Label(card,"GentleThrow","Tap Pick up toy + gentle throw. The marked target is forgiving; no dragging, aim or timing is required.",14).LayoutOrder=4 end
	end)
	registry.RegisterActivity("Q03",function(container,view,context)
		clearCue()
		local UI=context.UI; UI.List(container,8); container.LayoutOrder=10
		local craft=view.craft or {}; local held=craft.held
		local card=UI.Card(container,"SharedMiniature",held and "golden" or "cream")
		UI.Label(card,"MiniatureTitle",held and ("Selected · "..held.label.." · "..tostring(held.orientation*90).."°") or "One shared miniature",17,UI.Palette.forest).LayoutOrder=1
		local function refreshPreview()
			if not card.Parent then return end
			local root=craftRoot(); local source=root and (root:FindFirstChild("Booth") or root:FindFirstChild("Bedroom"))
			local old=card:FindFirstChild("MiniaturePreview"); if old then old:Destroy() end
			preview(card,source,UI)
		end
		refreshPreview()
		-- A remote view can precede world replication. One bounded refresh handles
		-- that arrival; no render loop, delayed request or authority is introduced.
		task.delay(.2,refreshPreview)
		local lines={}
		for _,piece in ipairs(craft.pieces or {}) do table.insert(lines,(piece.complete and "✓ " or piece.busy and "○ " or "· ")..piece.label..(piece.complete and " placed" or piece.busy and " selected" or " ready")) end
		UI.Label(card,"Assembly",table.concat(lines,"\n"),14).LayoutOrder=3
		UI.Label(card,"SharedState","The booth and bedroom show the same accepted pieces. Translucent pieces are selections; use Place to keep one.",14).LayoutOrder=4
		if held then
			local rotate={}
			for _,descriptor in ipairs(view.availableActions or {}) do if descriptor.payload and descriptor.payload.action=="rotate" then table.insert(rotate,descriptor) end end
			for index,descriptor in ipairs(rotate) do
				local button=UI.Button(card,"Turn"..index,descriptor.label,function() getContext().runAction(descriptor,false) end,true)
				button.LayoutOrder=4+index; UI.SetEnabled(button,not context.pending,true)
			end
			local root=craftRoot(); local cue,watcher; local alive=true
			local function refreshCue()
				if not alive or not container.Parent or not panel or not panel.Visible then return end
				local best,distance
				local character=context.player.Character; local playerRoot=character and character:FindFirstChild("HumanoidRootPart")
				for _,name in ipairs({"Booth","Bedroom"}) do
					local model=root and root:FindFirstChild(name); local target=model and model:FindFirstChild(held.socketId)
					if target and target:IsA("BasePart") then
						local d=playerRoot and (target.Position-playerRoot.Position).Magnitude or 0
						if not best or d<distance then best,distance=target,d end
					end
				end
				if cue then cue:Destroy(); if activeCue==cue then activeCue=nil end; cue=nil end
				if best then
					cue=Instance.new("BoxHandleAdornment"); cue.Name="CraftMatchingSocket"; cue.Adornee=best
					cue.Size=best.Size+Vector3.new(.12,.12,.12); cue.Color3=UI.Palette.golden; cue.Transparency=.3
					cue.AlwaysOnTop=true; cue.ZIndex=4; cue.Parent=context.gui; activeCue=cue
				end
			end
			refreshCue(); task.delay(.2,refreshCue)
			if root then watcher=root.DescendantAdded:Connect(function(item) if item.Name==held.socketId then task.defer(refreshCue) end end) end
			container.Destroying:Connect(function()
				alive=false; if watcher then watcher:Disconnect() end
				if cue then cue:Destroy(); if activeCue==cue then activeCue=nil end end
			end)
			UI.Label(card,"ReservationHelp","Close, Put back, or leaving releases this selection. If it returns to its tray, simply pick it up again.",13).LayoutOrder=8
		elseif craft.needsFinishing then
			UI.Label(card,"PhuongFinish","Ready for Phuong · choose the lamp's final look at the bedroom keepsake. The petal is already saved.",16,UI.Palette.forest).LayoutOrder=5
		end
	end)
	registry.RegisterActivity("Q04",function(container,view,context)
		local UI=context.UI; UI.List(container,8); container.LayoutOrder=12
		local summary=view.readingSummary or {}; local draft=view.draft or {}
		local card=UI.Card(container,"ReadingSavedChoices","cream")
		UI.Label(card,"SavedTitle","Your saved reading choices",17,UI.Palette.forest).LayoutOrder=1
		UI.Label(card,"SavedSummary",((summary.highlights and #summary.highlights>0) and "✓ "..table.concat(summary.highlights,", ") or "○ Choose a highlight")
			.."\n"..(summary.reaction and "✓ "..summary.reaction or "○ Choose a reaction")
			.."\n"..(summary.bookmark and "✓ "..summary.bookmark or "○ Choose a bookmark"),15).LayoutOrder=2
		UI.Label(card,"SaveHelp","Each choice stays saved when you close. Save reading completes the shared activity when all three are chosen. Your reading note is private to you for this session.",13).LayoutOrder=3
		local key=tostring(context.sessionId)..":"..tostring(view.roundId)..":"..tostring(draft.passageId)
		if not noteBuffer or noteBuffer.key~=key then noteBuffer={key=key,text=draft.note or "",dirty=false,open=false} end
		if not noteBuffer.dirty or noteBuffer.text==draft.note then noteBuffer.text=draft.note or ""; noteBuffer.dirty=false end
		local buffer=noteBuffer
		local note=UI.Card(container,"OptionalReadingNote","sage"); note.LayoutOrder=2
		local content=Instance.new("Frame"); content.Name="NoteEditor"; content.BackgroundTransparency=1
		content.Size=UDim2.new(1,0,0,0); content.AutomaticSize=Enum.AutomaticSize.Y; content.Visible=buffer.open; content.LayoutOrder=2; content.Parent=note; UI.List(content,8)
		local toggle=UI.Button(note,"ToggleNote","Optional · my private reading note",function() buffer.open=not buffer.open; content.Visible=buffer.open end,true); toggle.LayoutOrder=1
		local box=Instance.new("TextBox"); box.Name="ReadingNote"; box.Size=UDim2.new(1,0,0,105); box.LayoutOrder=1
		box.Text=buffer.text; box.PlaceholderText="An optional thought about this reading"; box.ClearTextOnFocus=false; box.MultiLine=true
		box.TextWrapped=true; box.TextXAlignment=Enum.TextXAlignment.Left; box.TextYAlignment=Enum.TextYAlignment.Top
		box.Font=Enum.Font.GothamMedium; box.TextSize=17; box.TextColor3=UI.Palette.ink; box.PlaceholderColor3=UI.Palette.forest
		box.BackgroundColor3=UI.Palette.cream; box.BorderSizePixel=0; box.Parent=content; UI.Padding(box,8); UI.Corner(box,8)
		local save
		local function validNote() return #box.Text<=500 end
		local function update()
			buffer.text=box.Text; buffer.dirty=box.Text~=(draft.note or "")
			if save then UI.SetEnabled(save,buffer.dirty and validNote() and not getContext().pending) end
		end
		save=UI.Button(content,"SaveNote","Save my reading note",function()
			if not validNote() then getContext().toast("Please shorten this reading note a little.",true); return end
			local descriptor=view.noteAction; if not descriptor then return end
			local payload={}; for k,v in pairs(descriptor.payload) do payload[k]=v end; payload.note=box.Text
			getContext().runAction({id=descriptor.id,label=descriptor.label,stepId=descriptor.stepId,payload=payload,enabled=true,confirm=false},false)
		end); save.LayoutOrder=2
		local hint=UI.Label(content,"PrivateNoteHelp","Save note keeps your words. Unsaved text is cleared on Close. This never appears in a shared world label.",13); hint.LayoutOrder=3
		box:GetPropertyChangedSignal("Text"):Connect(function() update(); hint.Text=validNote() and "Save note keeps your words. Unsaved text is cleared on Close. This never appears in a shared world label." or "Please shorten this reading note a little before saving." end)
		update()
	end)
	registry.RegisterObserver("WorldActivities",function(payload,context)
		if payload.kind=="LocationChanged" or payload.kind=="CharacterRemoving" then clearCue(); noteBuffer=nil; return end
		if not panel or not panel.Visible or context.player:GetAttribute("BirthdayLocation")~="World" then return end
		if payload.activityId=="Q04" and payload.ok and payload.result and payload.result.draft and panel:FindFirstChild("ReadingSavedChoices",true) then
			local draft=payload.result.draft
			if noteBuffer and noteBuffer.text==draft.note then noteBuffer.dirty=false end
			getContext().toast(payload.stepId=="note" and "Your private reading note is saved." or "Your reading choice is saved.")
		end
	end)
end
return Module
