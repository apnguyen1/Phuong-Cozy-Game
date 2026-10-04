local SessionService = require(script.Parent.Parent.server.SessionService)
local Q01 = require(script.Parent.Parent.server.activities.Q01)

return function()
	local clock = 100
	local session = SessionService.new({ sessionId = "test-session", phuongUserId = 7, hostUserId = 9 })
	session:SetPresence(7, true)
	local activity = Q01.new({ session = session, clock = function() return clock end })
	activity:CreateRound({ actorUserId = 7, roundId = "q01-r1", isReplay = false })
	local invalid = activity:Reserve({ roundId = "q01-r1", stepId = "not-a-step", actorUserId = 8 })
	assert(not invalid.ok)
	for index, stepId in ipairs(Q01.StepIds) do
		local actor = index == 1 and 7 or 8
		local offered = activity:GetView(actor)
		local reserveAction
		for _, candidate in ipairs(offered.availableActions) do if candidate.stepId == stepId and candidate.payload.action == "reserve" then reserveAction = candidate break end end
		assert(reserveAction and activity:Apply({ sessionId = session.sessionId, activityId = "Q01", roundId = "q01-r1", actionId = "reserve-a" .. index, actorUserId = actor, payload = reserveAction.payload }).ok)
		local placed = activity:GetView(actor)
		local placeAction
		for _, candidate in ipairs(placed.availableActions) do if candidate.stepId == stepId and candidate.payload.action == "place" then placeAction = candidate break end end
		assert(placeAction and activity:Apply({ sessionId = session.sessionId, activityId = "Q01", roundId = "q01-r1", actionId = "a" .. index, actorUserId = actor, payload = placeAction.payload }).ok)
	end
	local readyView = activity:GetView(7)
	local choices = {}
	for _, action in ipairs(readyView.availableActions) do if action.stepId == "finish" then choices[action.payload.choiceId] = action.enabled end end
	assert(choices.soft_snug == true and choices.neat_layered == true)
	local result = activity:Finish({ roundId = "q01-r1", actionId = "finish-1", actorUserId = 7, payload = { choiceId = "soft_snug" } })
	assert(result.ok and result.receipt.petalGranted and result.receipt.fundRewardGranted == 20)
	assert(activity:Finish({ roundId = "q01-r1", actionId = "finish-1", actorUserId = 7, payload = { choiceId = "soft_snug" } }).ok)
	assert(session.fundBalance == 20)

	-- Host cannot finish while Phuong is present; after Phuong leaves, present host may finish.
	activity:CreateRound({ actorUserId = 8, roundId = "q01-r2", isReplay = true })
	for index, stepId in ipairs(Q01.StepIds) do
		assert(activity:Reserve({ roundId = "q01-r2", stepId = stepId, actorUserId = 8 }).ok)
		assert(activity:Apply({ roundId = "q01-r2", stepId = stepId, actionId = "b" .. index, actorUserId = 8 }).ok)
	end
	session:SetPresence(9, true)
	local hostRejectedOk = pcall(function()
		activity:Finish({ roundId = "q01-r2", actionId = "finish-host-rejected", actorUserId = 9, payload = { choiceId = "neat_layered" } })
	end)
	assert(not hostRejectedOk)
	session:SetPresence(7, false)
	local hostView = activity:GetView(9)
	local hostChoices = {}
	for _, action in ipairs(hostView.availableActions) do if action.stepId == "finish" then hostChoices[action.payload.choiceId] = action.enabled end end
	assert(hostChoices.soft_snug == true and hostChoices.neat_layered == true)
	local hostFinished = activity:Finish({ roundId = "q01-r2", actionId = "finish-host-accepted", actorUserId = 9, payload = { choiceId = "neat_layered" } })
	assert(hostFinished.ok and hostFinished.preview.choiceId == "neat_layered")

	activity:CreateRound({ actorUserId = 8, roundId = "q01-r3", isReplay = true })
	assert(activity:Reserve({ roundId = "q01-r3", stepId = "pillow_left", actorUserId = 8 }).ok)
	local race = activity:Reserve({ roundId = "q01-r3", stepId = "pillow_left", actorUserId = 9 })
	assert(not race.ok and race.code == "IN_USE")
	clock += 16
	assert(activity:Reserve({ roundId = "q01-r3", stepId = "pillow_left", actorUserId = 9 }).ok)
	assert(activity:Cancel({ roundId = "q01-r3", stepId = "pillow_left", actorUserId = 9 }))
	return true
end
