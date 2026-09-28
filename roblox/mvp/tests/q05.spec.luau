local SessionService = require(script.Parent.Parent.server.SessionService)
local Q05 = require(script.Parent.Parent.server.activities.Q05)
local function expect(value, message) assert(value, message) end
local phuong = 3971290001; local outcomes = {"BigIntoEnergy02", "BigIntoEnergy03", "BigIntoEnergy04", "BigIntoEnergy05", "BigIntoEnergy06", "BigIntoEnergy02"}; local index = 0
local session = SessionService.new({sessionId = "q05-test", phuongUserId = phuong, hostUserId = 0}); session:AddFund(120)
session:SetPresence(phuong, true)
local activity = Q05.new({session = session, outcome = function() index += 1; return outcomes[index] end})
activity:CreateRound({activityId = "Q05", roundId = "q05-r1", actorUserId = phuong}); activity:Apply({roundId = "q05-r1", stepId = "select-wanted", actionId = "wanted", actorUserId = phuong, payload = {figureId = "BigIntoEnergy01"}})
local initialView = activity:GetView(phuong); local foundSelection = false; expect(string.find(initialView.instructions, "Collection copies: 0") ~= nil, "initial collection display must be zero"); for _, action in ipairs(initialView.availableActions) do if action.payload and action.payload.figureId == "BigIntoEnergySecret" and action.label == "Want Secret figure" then foundSelection = true end end; expect(foundSelection, "view must expose readable figure-specific wanted payload")
for i = 1, 4 do activity:Apply({roundId = "q05-r1", stepId = "roll", actionId = "miss" .. i, actorUserId = phuong}) end
local guaranteed = activity:Apply({roundId = "q05-r1", stepId = "roll", actionId = "guaranteed", actorUserId = phuong}); expect(guaranteed.receipt.awardFigureId == "BigIntoEnergy01", "fifth roll must guarantee target"); expect(guaranteed.receipt.petalGranted, "target grants petal"); expect(session.fundBalance == 20, "five rolls cost 100"); expect(string.find(activity:GetView(phuong).instructions, "Collection copies: 5") ~= nil, "collection display must show awarded copies")
expect(activity:Apply({roundId = "q05-r1", stepId = "roll", actionId = "guaranteed", actorUserId = phuong}).code == "DUPLICATE", "duplicate is idempotent")
activity:Apply({roundId = "q05-r1", stepId = "select-wanted", actionId = "new-wish", actorUserId = phuong, payload = {figureId = "BigIntoEnergy02"}})
activity:Apply({roundId = "q05-r1", stepId = "roll", actionId = "new-wish-roll", actorUserId = phuong})
local owned = activity:Apply({roundId = "q05-r1", stepId = "select-wanted", actionId = "owned-wish", actorUserId = phuong, payload = {figureId = "BigIntoEnergy01"}})
expect(owned.code == "WANTED_ALREADY_OWNED" and owned.receipt.petalGranted == false, "owned figure fulfills new wish without a second petal")
local idSession = SessionService.new({sessionId = "q05-id-test", phuongUserId = phuong, hostUserId = 0}); idSession:AddFund(100)
idSession:SetPresence(phuong, true)
local idIndex = 0; local idActivity = Q05.new({session = idSession, outcome = function() idIndex += 1; return "BigIntoEnergy01" end})
idActivity:CreateRound({activityId = "Q05", roundId = "q05-id", actorUserId = phuong}); idActivity:Apply({roundId = "q05-id", stepId = "select-wanted", actionId = "id-wanted", actorUserId = phuong, payload = {figureId = "BigIntoEnergySecret"}})
for i = 1, 4 do idActivity:Apply({roundId = "q05-id", stepId = "roll", actionId = "id-miss" .. i, actorUserId = phuong}) end
local idGuaranteed = idActivity:Apply({roundId = "q05-id", stepId = "roll", actionId = "id-guaranteed", actorUserId = phuong})
expect(idGuaranteed.receipt.awardFigureId == "BigIntoEnergySecret", "fifth roll must guarantee selected secret ID")
local weightedSession = SessionService.new({sessionId = "q05-weighted", phuongUserId = phuong, hostUserId = 0}); weightedSession:SetPresence(phuong, true)
local weighted = Q05.new({session = weightedSession, random = function() return 0.999 end}); weighted:CreateRound({activityId = "Q05", roundId = "q05-weighted", actorUserId = phuong}); expect(weighted:_draw() == "BigIntoEnergySecret", "weighted default must reach secret boundary")
return true
