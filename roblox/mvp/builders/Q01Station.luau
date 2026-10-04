-- Compatibility station builder. PCW-19 uses the detailed Home.Bedroom.SageBed.
-- Runtime BedroomFeedback supplies task cues; never create another bed here.
return function(context)
	assert(context and context.Root and context.MVP and context.Anchors and context.SafeReplace, "Q01Station context is incomplete")
	local home = context.Root:FindFirstChild("Home")
	local room = home and home:FindFirstChild("Bedroom")
	assert(room and room:FindFirstChild("SageBed"), "Q01 requires the existing detailed SageBed")
	local manifest = {
		AnchorName = "Q01Bed", Footprint = "Existing Home.Bedroom.SageBed; no duplicate geometry",
		Owner = "PCW-19", SourceBuilder = "roblox/mvp/builders/Q01Station.luau",
		ApproachClearance = "Existing bedroom circulation; final integration review required",
	}
	local installed = context.SafeReplace("Q01Station", function()
		local model = Instance.new("Model"); model.Name = "Q01Station"
		model:SetAttribute("ActivityId", "Q01"); model:SetAttribute("VerificationTicket", "PCW-19")
		model:SetAttribute("MVPBuilder", "Q01Station"); model:SetAttribute("UsesDetailedBed", true)
		return model
	end)
	return { folder = installed, manifest = manifest }
end
