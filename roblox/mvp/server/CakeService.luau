local Config = require(script.Parent.Parent.shared.Config)

local CakeService = {}
CakeService.__index = CakeService

function CakeService.new(session)
    return setmetatable({ session = session, finaleState = "LOCKED" }, CakeService)
end

function CakeService:_authorized(actorUserId)
    local present = self.session:IsPresent(actorUserId)
    return present and (actorUserId == self.session.phuongUserId or actorUserId == self.session.hostUserId)
end

function CakeService:Invite(actorUserId)
    assert(self:_authorized(actorUserId), "not authorized")
    assert(self.session:AllPetalsComplete(), "all petals are required")
    self.finaleState = "INVITED"
    return self:GetState()
end

function CakeService:CancelInvite(actorUserId)
    assert(self:_authorized(actorUserId), "not authorized")
    assert(self.finaleState == "INVITED", "invite is not open")
    self.finaleState = "READY"
    return self:GetState()
end

function CakeService:Cut(actorUserId)
    assert(self:_authorized(actorUserId), "not authorized")
    assert(self.finaleState == "INVITED", "cake is not invited")
    self.finaleState = "CUT"
    return self:GetState()
end

function CakeService:Eat(actorUserId)
    assert(self.finaleState == "CUT" or self.finaleState == "EATING", "cake is not cut")
    self.finaleState = "EATING"
    return { actorUserId = actorUserId, state = self.finaleState }
end

function CakeService:GetState()
    return { finaleState = self.finaleState }
end

return CakeService
