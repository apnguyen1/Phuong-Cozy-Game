-- Presentation data only. Nothing in this module grants a reward or permission.
local Guidance = {}

Guidance.Order = { "Q01", "Q02", "Q03", "Q04", "Q05", "Q06" }
Guidance.Activities = {
	Q01 = { title = "Everything Tucked In", short = "Make her room cozy", destination = "Phuong's bedroom", anchors = { "Q01Bed" }, hint = "Choose a bed or shelf task. Friends help; Phuong adds the finishing touch.", reward = "First completion adds 20 to the shared fund." },
	Q02 = { title = "Jasper's Favorite Things", short = "Play with Jasper", destination = "Bedroom, then Jasper's yard", anchors = { "JasperBedroomStart", "JasperFetchYard" }, hint = "Say hello to Jasper, find his rabbit in the yard, then play fetch.", reward = "First completion adds 20 to the shared fund." },
	Q03 = { title = "A Tiny World of Her Own", short = "Build a tiny keepsake", destination = "UDistrict craft booth", anchors = { "Q03FairCraft", "Q03BedroomDisplay" }, hint = "Choose a tiny piece, turn it if you like, then place it in the miniature.", reward = "First completion adds 20 to the shared fund." },
	Q04 = { title = "One More Chapter", short = "Share a quiet chapter", destination = "Quad blossoms or bedroom Kindle", anchors = { "Q04QuadReading", "Q04BedroomKindle" }, hint = "Read a page. Pick a highlight, a reaction and a bookmark, then save.", reward = "First completion adds 20 to the shared fund." },
	Q05 = { title = "A Labubu Wish", short = "Help Phuong get her Labubu", destination = "UDistrict Labubu booth", anchors = { "Q05UDistrictVending" }, hint = "Phuong chooses her wish. Each box uses 20 from the shared fund; her wish arrives by the fifth box.", reward = "Getting her wanted Labubu adds the sixth activity's petal." },
	Q06 = { title = "Something Delicious", short = "Make a meal together", destination = "FOB, Aladdins, then the serving table", anchors = { "Q06FOBCounter", "Q06AladdinsCounter", "Q06Serving" }, hint = "Build a bowl at FOB, add sauce at Aladdins, then set the serving table.", reward = "First completion adds 20 to the shared fund." },
	Cake = { title = "Happy Birthday, Phuong!", short = "Birthday table", destination = "Birthday patio", anchors = { "FinalePatio" }, hint = "Follow the marker to the birthday table and gather with your friends.", reward = "Enjoy the birthday moment together." },
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
	local payload = descriptor.payload or {}
	local step = descriptor.stepId
	if step == "roll" or payload.action == "roll" then
		return { title = "Open a Labubu box?", detail = "This uses 20 from the shared birthday fund. Everyone's progress stays shared.", label = "Spend 20 and open" }
	end
	if step == "select-wanted" then
		return { title = "Choose this wish?", detail = "The wanted figure stays selected until Phuong receives it.", label = "Choose this Labubu" }
	end
	if payload.action == "finish" or payload.action == "finalize" or payload.complete == true then
		return { title = "Finish this activity?", detail = "Save this choice for the shared birthday session.", label = "Finish together" }
	end
	return nil
end

return Guidance
