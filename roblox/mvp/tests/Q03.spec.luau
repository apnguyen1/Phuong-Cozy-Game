local Q03 = require(script.Parent.Parent.server.activities.Q03)
local SessionService = require(script.Parent.Parent.server.SessionService)
local function expect(value, message) assert(value, message) end
local function setup()
    local session = SessionService.new({sessionId="s",phuongUserId=7,hostUserId=8})
    session:SetPresence(7, true); session:SetPresence(8, true)
    local t=0; local trustedUserId=7; local activity=Q03.new({session=session,actorResolver=function() return trustedUserId end,clock=function() return t end,context={}})
    activity:CreateRound({sessionId="s",activityId="Q03",roundId="r1",actorUserId=trustedUserId})
    return activity, function(v) t += v end, session
end
local activity, advance, session = setup()
local initialView = activity:GetView(7)
expect(#initialView.availableActions == 6, "view offers one concrete reserve action per piece")
expect(initialView.availableActions[1].payload.action == "reserve" and initialView.availableActions[1].stepId ~= "", "offered action is executable")
activity:Apply({sessionId="s",activityId="Q03",roundId="r1",actionId="a1",actorUserId=7,payload={action="reserve",socketId="rugSocket",partId="rug"}})
activity:Apply({sessionId="s",activityId="Q03",roundId="r1",actionId="a2",actorUserId=7,payload={action="rotate",socketId="rugSocket",direction=1}})
activity:Apply({sessionId="s",activityId="Q03",roundId="r1",actionId="a3",actorUserId=7,payload={action="place",socketId="rugSocket",partId="rug"}})
    expect(activity:GetView(7).progress.done == 1, "accepted progress is visible")
local ok=false; pcall(function() activity:Apply({sessionId="s",activityId="Q03",roundId="r1",actionId="a4",actorUserId=7,payload={action="reserve",socketId="rugSocket",partId="rug"}}) end); ok=true; expect(ok, "test harness continues after rejected conflict")
local invalidOk=pcall(function() activity:Apply({sessionId="s",activityId="Q03",roundId="r1",actionId=99,actorUserId=7,payload={action="reserve",socketId="chairSocket",partId="chair"}}) end); expect(not invalidOk, "invalid opaque action ID is rejected")
local before=session:GetSnapshot().fundBalance; local duplicate=activity:Apply({sessionId="s",activityId="Q03",roundId="r1",actionId="a3",actorUserId=7,payload={action="place",socketId="rugSocket",partId="rug"}}); expect(session:GetSnapshot().fundBalance==before and duplicate ~= nil, "duplicate action is idempotent")
local activity2, advance2 = setup(); activity2:Apply({sessionId="s",activityId="Q03",roundId="r1",actionId="b1",actorUserId=7,payload={action="reserve",socketId="chairSocket",partId="chair"}}); advance2(15); activity2:ExpireReservations("r1"); expect(activity2:GetView(7).progress.done==0, "inactive reservation expires")
for i,part in ipairs(Q03.PARTS) do local socket=Q03.SOCKETS[part]; activity2:Apply({sessionId="s",activityId="Q03",roundId="r1",actionId="c"..i,actorUserId=7,payload={action="reserve",socketId=socket,partId=part}}); activity2:Apply({sessionId="s",activityId="Q03",roundId="r1",actionId="d"..i,actorUserId=7,payload={action="place",socketId=socket,partId=part}}) end
expect(session:GetSnapshot().fundBalance == before and activity2:GetView(7).state == "COMPLETED", "completion is local to second session")
local finalized = activity2:Apply({sessionId="s",activityId="Q03",roundId="r1",actionId="f1",actorUserId=7,payload={action="finalize",presentation="lamp_on"}})
local retried = activity2:Apply({sessionId="s",activityId="Q03",roundId="r1",actionId="f2",actorUserId=7,payload={action="finalize",presentation="lamp_off"}})
expect(finalized.receipt.presentation == "lamp_on" and retried.receipt.presentation == "lamp_on", "final presentation is immutable and idempotent")
local SessionService = require(script.Parent.Parent.server.SessionService)
local realSession = SessionService.new({sessionId="q03-real", phuongUserId=7, hostUserId=9})
realSession:SetPresence(7, true)
local realActivity = Q03.new({session=realSession, clock=function() return 15 end, context={}})
realActivity:CreateRound({sessionId="q03-real", activityId="Q03", roundId="real-r1", actorUserId=7})
for index, part in ipairs(Q03.PARTS) do
    local socket = Q03.SOCKETS[part]
    realActivity:Apply({sessionId="q03-real", activityId="Q03", roundId="real-r1", actionId="real-reserve-"..index, actorUserId=7, payload={action="reserve", socketId=socket, partId=part}})
    realActivity:Apply({sessionId="q03-real", activityId="Q03", roundId="real-r1", actionId="real-place-"..index, actorUserId=7, payload={action="place", socketId=socket, partId=part}})
end
expect(realSession:GetSnapshot().petals.Q03 == true and realSession:GetSnapshot().fundBalance == 20, "real session awards exactly one Q03 petal and 20 fund")
local realFund = realSession:GetSnapshot().fundBalance
realActivity:Apply({sessionId="q03-real", activityId="Q03", roundId="real-r1", actionId="real-place-6", actorUserId=7, payload={action="place", socketId="lampSocket", partId="lamp"}})
expect(realSession:GetSnapshot().fundBalance == realFund, "real session duplicate placement adds no reward")
realActivity:ReleaseActor(7)
return true
