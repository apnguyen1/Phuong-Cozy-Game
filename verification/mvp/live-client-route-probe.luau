-- Test-only: execute in the local Studio Client after Play starts.
-- Sends the same server-offered envelopes as the generic UI. Does not grant rewards.
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local remote = game:GetService("ReplicatedStorage"):WaitForChild("PhuongMVP"):WaitForChild("Action")
if _G.CoordinatorRouteProbe and _G.CoordinatorRouteProbe.connection then _G.CoordinatorRouteProbe.connection:Disconnect() end
local probe = {responses={}, views={}, events={}, observed={}, sequence=0}
_G.CoordinatorRouteProbe = probe
probe.connection = remote.OnClientEvent:Connect(function(result)
    if result.actionId then probe.responses[result.actionId] = result end
    if result.view then probe.views[result.view.activityId] = result.view end
    if result.snapshot then probe.snapshot = result.snapshot end
    if result.actionId and result.code~="Snapshot" then
        table.insert(probe.observed,{actionId=result.actionId,activityId=result.activityId,stepId=result.stepId,
            code=result.code,ok=result.ok,errorText=result.errorText,state=result.view and result.view.state,
            fund=result.snapshot and result.snapshot.fundBalance})
    end
end)
function probe.send(packet)
    probe.sequence += 1
    packet.actionId = packet.actionId or "coordinator-live-" .. tostring(probe.sequence)
    packet.sessionId = player:GetAttribute("MVPSessionId")
    remote:FireServer(packet)
    local deadline = os.clock()+4
    while not probe.responses[packet.actionId] and os.clock()<deadline do task.wait(.05) end
    local result = assert(probe.responses[packet.actionId], "no response: " .. packet.actionId)
    local event = {activityId=packet.activityId, kind=packet.kind, stepId=packet.stepId, action=packet.action,
        actionId=packet.actionId, ok=result.ok, code=result.code, errorText=result.errorText,
        state=result.view and result.view.state, progress=result.view and result.view.progress,
        fund=result.snapshot and result.snapshot.fundBalance, petals=result.snapshot and result.snapshot.petals}
    table.insert(probe.events,event)
    return result
end
function probe.open(id, replay)
    local result=probe.send({kind="RequestView",activityId=id,replay=replay==true})
    assert(result.ok,result.errorText or result.code)
    return result.view
end
function probe.choose(id, predicate, allowRejected)
    local view=assert(probe.views[id],"open view first")
    for _,descriptor in ipairs(view.availableActions or {}) do
        if descriptor.enabled~=false and predicate(descriptor) then
            local result=probe.send({kind="ActivityAction",activityId=id,roundId=view.roundId,stepId=descriptor.stepId,payload=descriptor.payload})
            if not allowRejected then assert(result.ok,result.errorText or result.code) end
            return result
        end
    end
    error("no enabled matching offered action for "..id)
end
function probe.summary(id)
    local view=probe.views[id]
    return {activityId=id,state=view and view.state,progress=view and view.progress,
        fund=probe.snapshot and probe.snapshot.fundBalance,petals=probe.snapshot and probe.snapshot.petals,
        actionCount=#probe.events,last=probe.events[#probe.events]}
end
probe.send({kind="RequestSnapshot"})
return {ready=true,userId=player.UserId,username=player.Name,sessionId=player:GetAttribute("MVPSessionId")}
