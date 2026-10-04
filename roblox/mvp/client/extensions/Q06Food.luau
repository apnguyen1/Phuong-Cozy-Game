-- PCW-18 extension. Preview selection is local; shared food is server-authored.
local FoodPresentation = require(script.Parent.Parent.Parent.shared.FoodPresentation)
local Guidance = require(script.Parent.Parent.Parent.shared.Guidance)
local Module = {}

local function preview(parent, view, UI)
	local viewport = Instance.new("ViewportFrame")
	viewport.Name, viewport.Size, viewport.LayoutOrder = "FoodPreview", UDim2.new(1, 0, 0, 140), 2
	viewport.BackgroundColor3, viewport.BorderSizePixel = UI.Palette.cream, 0
	viewport.Ambient, viewport.LightColor = UI.Palette.cream, UI.Palette.golden
	viewport.LightDirection = Vector3.new(-1, -1, -1)
	viewport.Parent = parent; UI.Corner(viewport, 10)
	local model = FoodPresentation.Build(view.foodDisplay or {}, view.held)
	model.Parent = viewport
	local camera = Instance.new("Camera")
	camera.FieldOfView = 34
	camera.CFrame = CFrame.lookAt(Vector3.new(1, 8, 10.5), Vector3.new(0, .3, 0))
	camera.Parent = viewport; viewport.CurrentCamera = camera
end

function Module.Init(getContext, registry)
	local panel = getContext().gui:FindFirstChild("ActivityPanel")
	registry.RegisterActivity("Q06", function(container, view, context)
		local UI = context.UI
		UI.List(container, 8)
		-- Keep the preview ahead of the explicit Add/Place button. The PCW-18
		-- activity mount owns no remote behavior; generic descriptors still submit.
		container.LayoutOrder = 6
		local main = container.Parent:FindFirstChild("MainAction")
		if main and (view.state == "COMPLETED" or not view.atCounter) then main.Visible = false end
		local track = container.Parent:FindFirstChild("TrackNextStep")
		if track and track:IsA("TextButton") then track.Text = "Track next counter" end
		local recipe = UI.Card(container, "RecipeRoute", "cream"); recipe.LayoutOrder = 1
		UI.Label(recipe, "RecipeTitle", "The recipe · three stops", 17, UI.Palette.forest).LayoutOrder = 1
		UI.Label(recipe, "RecipeText", view.recipe or "Build a bowl at FOB, add sauce at Aladdins, then set the serving table.", 14).LayoutOrder = 2
		UI.Label(recipe, "YourLocation", "You are at · " .. (view.currentVenue == "Serving" and "the serving table" or view.currentVenue or "the neighborhood"), 14).LayoutOrder = 3
		local food = UI.Card(container, "YourSharedMeal", view.held and "golden" or "sage"); food.LayoutOrder = 2
		UI.Label(food, "DishTitle", view.held and "Preview · " .. view.held.label .. " selected" or "Your shared meal", 17, UI.Palette.forest).LayoutOrder = 1
		preview(food, view, UI)
		if view.held then
			UI.Label(food, "PreviewStatus", "Not added yet · " .. view.held.destination, 14).LayoutOrder = 3
			UI.Label(food, "PreviewHelp", "Use Add or Place to save this exact choice. Cancel or Close puts the selection back; accepted ingredients stay.", 13).LayoutOrder = 4
		end
		local saved = {}
		for _, item in ipairs(view.dishSummary or {}) do
			if item.complete then table.insert(saved, "✓ " .. item.label .. " · " .. item.detail) end
		end
		UI.Label(food, "AcceptedIngredients", #saved > 0 and table.concat(saved, "\n") or "The shared bowl is empty. Choose rice, a protein or a topping to begin.", 14).LayoutOrder = 5
		if view.state == "COMPLETED" and view.nextActivity then
			local info = Guidance.Activities[view.nextActivity]
			if info then
				local nextCard = UI.Card(container, "NextActivity", "cream"); nextCard.LayoutOrder = 3
				UI.Label(nextCard, "Done", "Done! Everyone's meal is ready.", 17, UI.Palette.forest).LayoutOrder = 1
				UI.Button(nextCard, "TrackAnotherActivity", "Next · " .. info.title, function()
					local fresh = getContext(); fresh.track(view.nextActivity); fresh.close()
				end).LayoutOrder = 2
				UI.Label(nextCard, "OptionalReplay", "Your petal and shared reward are saved. Playing again is optional.", 13).LayoutOrder = 3
			end
		end
	end)
	registry.RegisterObserver("Q06Food", function(payload, context)
		if payload.activityId ~= "Q06" or type(payload.result) ~= "table" or type(payload.result.message) ~= "string" then return end
		-- Only a current visible Q06 response gets a toast. Late replies after
		-- close/reset/lobby must not interrupt exploration or another activity.
		if not panel or not panel.Visible or not panel:FindFirstChild("YourSharedMeal", true) then return end
		if context.player:GetAttribute("BirthdayLocation") ~= "World" then return end
		getContext().toast(payload.result.message, payload.ok == false)
	end)
end
return Module
