_G.__PCW25ContractText..=[==[ority")
    activityAction(f,"Q01",G,function(d) return d.payload.action=="reserve" end)
    assert(f.session.fundBalance==0,"Ordinary guest activity remains usable after host request cap")
    print("CONTRACT host bounds: audit32, request512, cached retries, departure reset, ordinary play unaffected")
end
return true
]=],
["roblox/mvp/tests/release_social_activity_contracts.spec.luau"] = [=[-- Pure module behavior only. World movement and two real clients need Studio.
local Session = require(script.Parent.Parent.server.SessionService)
local Q02 = require(script.Parent.Parent.server.activities.Q02)
local Q03 = require(script.Parent.Parent.server.activities.Q03)
local Q04 = require(script.Parent.Parent.server.activities.Q04)
local P,A,G,H = 3971290001,1078077474,201,202
local serial=0
local function fresh(id)
    local session=Session.new({sessionId=id,phuongUserId=P,hostUserId=A})
    for _, actor in ipairs({P,A,G,H}) do session:SetPresence(actor,true) end
    return session
end
local function request(session, activity, actor, filter)
    local view=activity:GetView(actor)
    for _, action in ipairs(view.availableActions or {}) do
        if action.enabled~=false and filter(action) then
            serial+=1
            local payload={}; for k,v in pairs(action.payload or {}) do payload[k]=v end
            return {sessionId=session.sessionId,activityId=view.activityId,roundId=view.roundId,
                actorUserId=actor,actionId=session.sessionId..":"..serial,stepId=action.stepId,payload=payload}
        end
    end
    error("Required current descriptor missing")
end
local function send(session,activity,actor,filter)
    local r=request(session,activity,actor,filter)
    local result=activity:Apply(r)
    assert(type(result)=="table" and result.ok~=false,"Current descriptor rejected")
    return result,r
end
local function rejects(callback)
    local ok,result=pcall(callback)
    assert(not ok or type(result)=="table" and result.ok==false,"Invalid mutation should reject")
end
do
    local session=fresh("jasper"); local calls={}
    local function track(name) return function(...) calls[name]=(calls[name] or 0)+1 end end
    local world={isPresent=function(actor) return session:IsPresent(actor) end,
        chooseRabbitBasket=function() return 2 end,
        resetJasper=track("reset"),moveJasperToYard=track("lead"),showRabbitPickup=track("rabbit"),
        returnRabbit=track("return"),presentFetchTarget=track("target"),fetchJasper=track("fetch"),
        giveJasperTreat=track("treat"),petJasper=track("pet")}
    local activity=Q02.new({session=session,clock=function() return 0 end,world=world})
    activity:CreateRound({sessionId=session.sessionId,activityId="Q02",roundId="jasper:1",actorUserId=P})
    send(session,activity,G,function(a) return a.stepId=="greet" end)
    assert(calls.lead==1,"Accepted greeting reaches world hook")
    local empty=request(session,activity,H,function(a) return a.stepId=="rabbitFound" and a.payload.basketIndex==1 end)
    assert(activity:Apply(empty).ok==false and session.fundBalance==0,"Empty basket is forgiving with no reward")
    send(session,activity,H,function(a) return a.stepId=="rabbitFound" and a.payload.basketIndex==2 end)
    activity:ReleaseActor(H)
    send(session,activity,G,function(a) return a.stepId=="rabbitReturned" end)
    for index=1,3 do
        local _,r=send(session,activity,index%2==0 and G or H,function(a) return a.stepId=="fetch"..index end)
        activity:Apply(r)
    end
    assert(calls.fetch==3,"One world fetch per accepted throw despite duplicates")
    local _,finished=send(session,activity,G,function(a) return a.stepId=="greenie" end)
    activity:Apply(finished)
    assert(calls.rabbit==1 and calls["return"]==1 and calls.treat==1,"Required dog feedback hooks reached once")
    assert(session.petals.Q02 and session.fundBalance==20,"Jasper shared reward once")
    send(session,activity,H,function(a) return a.stepId=="pet" end)
    assert(session.fundBalance==20,"Cosmetic pet grants no money")
    activity:CreateRound({sessionId=session.sessionId,activityId="Q02",roundId="jasper:2",actorUserId=P,replay=true})
    assert(activity:GetView(G).progress.done==0 and calls.reset==2,"Explicit replay resets actor and shared progress")
    print("CONTRACT Jasper: sequence, forgiving basket, helper handoff, world hooks, duplicate reward, replay")
end
do
    local session,tick=fresh("craft"),0
    local activity=Q03.new({session=session,clock=function() return tick end,context={}})
    activity:CreateRound({sessionId=session.sessionId,activityId="Q03",roundId="craft:1",actorUserId=P})
    local function action(operation,part)
        return function(a) return a.payload.action==operation and (not part or a.payload.partId==part or a.payload.socketId==Q03.SOCKETS[part]) end
    end
    local _,held=send(session,activity,G,action("reserve","chair"))
    local conflict={};for k,v in pairs(held) do conflict[k]=v end; conflict.actorUserId=H; conflict.actionId="craft:conflict"
    rejects(function() return activity:Apply(conflict) end)
    send(session,activity,G,action("rotate","chair"))
    send(session,activity,G,action("cancel","chair"))
    send(session,activity,G,action("reserve","chair"))
    local expired=request(session,activity,G,action("place","chair"))
    tick=16;activity:ExpireReservations()
    rejects(function() return activity:Apply(expired) end)
    for _, part in ipairs(Q03.PARTS) do
        send(session,activity,G,action("reserve",part))
        local _,placed=send(session,activity,G,action("place",part));activity:Apply(placed)
    end
    assert(session.petals.Q03 and session.fundBalance==20,"Craft six shared pieces earn once")
    local final=request(session,activity,P,action("finalize"))
    local fake={};for k,v in pairs(final) do fake[k]=v end;fake.actorUserId=G;fake.actionId="craft:guest-finish"
    rejects(function() return activity:Apply(fake) end)
    activity:Apply(final)
    assert(session.fundBalance==20,"Phuong craft presentation does not earn twice")
    print("CONTRACT craft: holds, rotation, cancellation, shared pieces, Phuong finish, no duplicate reward")
end
do
    local session=fresh("reading");local lastWorldSummary
    local activity=Q04.new({session=session,clock=function() return 0 end,
        context={renderReading=function(summary) lastWorldSummary=summary end}})
    activity:CreateRound({sessionId=session.sessionId,activityId="Q04",roundId="reading:1",actorUserId=P})
    send(session,activity,G,function(a) return a.stepId=="highlight" end)
    send(session,activity,G,function(a) return a.stepId=="reaction" end)
    send(session,activity,G,function(a) return a.stepId=="bookmark" end)
    local before=activity:GetView(G)
    assert(before.reading and #before.reading.text>100,"Actual reading passage is available")
    if activity.ReleaseActor then activity:ReleaseActor(G) end
    local after=activity:GetView(G)
    assert(after.reading.text==before.reading.text,"Reopen retains reading passage")
    local _,saved=send(session,activity,G,function(a) return a.payload.complete==true end)
    activity:Apply(saved)
    assert(session.fundBalance==20 and session.petals.Q04,"No typing required and save grants once")
    assert(activity:GetView(H).canReplay,"Other participant sees shared completion")
    -- This is only a private reading-field test marker, never birthday-note copy.
    local note=activity:GetView(G).noteAction
    local noteRequest={sessionId=session.sessionId,activityId="Q04",roundId="reading:1",actorUserId=G,
        actionId="reading:private-fixture",stepId=note.stepId,payload={passageId=note.payload.passageId,
            revision=note.payload.revision,note="PRIVATE_FIELD_TEST_MARKER"}}
    assert(activity:Apply(noteRequest).ok,"Optional private note remains usable after shared completion")
    assert(activity:GetView(G).draft.note=="PRIVATE_FIELD_TEST_MARKER","Owner sees own saved note")
    assert(activity:GetView(H).draft.note=="","Other participant cannot see private note")
    for _,value in pairs(lastWorldSummary) do assert(value~="PRIVATE_FIELD_TEST_MARKER","World feedback excludes private note") end
    assert(session.fundBalance==20,"Post-completion personal choices never add shared money")
    local changed={};for k,v in pairs(noteRequest) do changed[k]=v end;changed.actorUserId=H
    rejects(function() return activity:Apply(changed) end)
    print("CONTRACT reading: passage, close, no required note, single shared reward, private draft isolation")
end
return true
]=]
}
local specs = {"roblox/mvp/tests/release_activity_contracts.spec.luau","roblox/mvp/tests/release_cake_contracts.spec.luau","roblox/mvp/tests/release_host_contracts.spec.luau","roblox/mvp/tests/release_social_activity_contracts.spec.luau"}

local function node(name, parent, path)
    local value = {Name=name, Parent=parent, _path=path, _children={}}
    setmetatable(value, {__index=function(self, key) return self._children[key] end})
    function value:FindFirstChild(child) return self._children[child] end
    if parent then parent._children[name] = value end
    return value
end
local root, nodes = node("root", nil, ""), {}
for path in pairs(sources) do
    local parent, built = root, ""
    for segment in string.gmatch(path, "[^/]+") do
        built = built == "" and segment or built .. "/" .. segment
        parent = nodes[built] or node(segment, parent, built)
        nodes[built] = parent
        if string.sub(segment, -5) == ".luau" then
            parent.Parent._children[string.sub(segment, 1, -6)] = parent
        end
    end
end
local function loadModule(target)
    assert(type(target) == "table" and target._path, "Expected a synthetic ModuleScript node")
    if target._loaded then return target._value end
    local chunk, failure = loadstring(assert(sources[target._path]), "@" .. target._path)
    assert(chunk, failure)
    local env = setmetatable({script=target, warn=function(...) print("EXPECTED_OR_REVIEW_WARNING", ...) end}, {__index=getfenv()})
    env.require = loadModule
    setfenv(chunk, env)
    target._value, target._loaded = chunk(), true
    return target._value
end
local passed, failed = 0, 0
for _, path in ipairs(specs) do
    local ok, result = xpcall(function() return loadModule(nodes[path]) end, debug.traceback)
    if ok and type(result) == "function" then ok, result = pcall(result) end
    if ok and result == true then
        passed += 1; print("PASS", path)
    else
        failed += 1; print("FAIL", path, result)
    end
end
print("RELEASE_CONTRACT_SUMMARY", passed, failed)
assert(failed == 0, "Release contracts failed")

end,debug.traceback)
return game:GetService('HttpService'):JSONEncode({ok=ok,error=not ok and tostring(failure) or nil,messages=messages})
]==]
return #_G.__PCW25ContractText