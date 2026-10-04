-- Server-owned shared birthday queue. Pure state machine; Roblox wiring belongs to LobbyQueue.
local QueueService = {}
QueueService.__index = QueueService

QueueService.Config = {
	Capacity = 10,
	ShortenAt = 8,
	InitialSeconds = 60,
	ShortenedSeconds = 10,
}

local function copyIds(ids)
	local result = {}
	for index, userId in ipairs(ids) do
		result[index] = userId
	end
	return result
end

function QueueService.new(options)
	options = options or {}
	local self = setmetatable({}, QueueService)
	self.clock = options.clock or os.clock
	self.capacity = options.capacity or QueueService.Config.Capacity
	self.shortenAt = options.shortenAt or QueueService.Config.ShortenAt
	self.initialSeconds = options.initialSeconds or QueueService.Config.InitialSeconds
	self.shortenedSeconds = options.shortenedSeconds or QueueService.Config.ShortenedSeconds
	self.generation = 0
	self.state = "Empty"
	self.members = {}
	self.order = {}
	self.startedAt = nil
	self.deadlineAt = nil
	self.shortenedAt = nil
	self.rosterId = nil
	self.destinationReservationId = nil
	self.frozenRoster = nil
	return self
end

function QueueService:_reset()
	self.generation += 1
	self.state = "Empty"
	self.members = {}
	self.order = {}
	self.startedAt = nil
	self.deadlineAt = nil
	self.shortenedAt = nil
	self.rosterId = nil
	self.destinationReservationId = nil
	self.frozenRoster = nil
end

function QueueService:_snapshot(reason)
	return {
		state = self.state,
		generation = self.generation,
		count = #self.order,
		capacity = self.capacity,
		startedAt = self.startedAt,
		deadlineAt = self.deadlineAt,
		remaining = self.deadlineAt and math.max(0, self.deadlineAt - self.clock()) or nil,
		shortened = self.shortenedAt ~= nil,
		members = copyIds(self.order),
		reason = reason,
	}
end

function QueueService:Snapshot()
	return self:_snapshot()
end

function QueueService:Join(userId, now)
	now = now or self.clock()
	if self.state ~= "Empty" and self.state ~= "Open" and self.state ~= "Shortened" then
		return false, "QueueClosed", self:_snapshot()
	end
	if self.members[userId] then
		return true, "AlreadyJoined", self:_snapshot()
	end
	if #self.order >= self.capacity then
		return false, "QueueFull", self:_snapshot()
	end
	if self.state == "Empty" then
		self.generation += 1
		self.state = "Open"
		self.startedAt = now
		self.deadlineAt = now + self.initialSeconds
	end
	self.members[userId] = true
	table.insert(self.order, userId)
	if #self.order >= self.shortenAt and self.shortenedAt == nil then
		self.deadlineAt = math.min(self.deadlineAt, now + self.shortenedSeconds)
		self.shortenedAt = now
		self.state = "Shortened"
	end
	return true, "Joined", self:_snapshot()
end

function QueueService:Leave(userId)
	if self.state ~= "Empty" and self.state ~= "Open" and self.state ~= "Shortened" then
		return false, "QueueClosed", self:_snapshot()
	end
	if not self.members[userId] then
		return true, "AlreadyLeft", self:_snapshot()
	end
	self.members[userId] = nil
	for index, queuedId in ipairs(self.order) do
		if queuedId == userId then
			table.remove(self.order, index)
			break
		end
	end
	if #self.order == 0 then
		self:_reset()
		return true, "Reset", self:_snapshot()
	end
	return true, "Left", self:_snapshot()
end

function QueueService:Tick(now)
	now = now or self.clock()
	if (self.state == "Open" or self.state == "Shortened") and self.deadlineAt and now >= self.deadlineAt then
		return self:Freeze(now)
	end
	return false, "NotExpired", self:_snapshot()
end

function QueueService:Freeze(now)
	if self.state == "Frozen" or self.state == "Transferring" or self.state == "Completed" then
		return false, "AlreadyFrozen", self:_snapshot()
	end
	if #self.order == 0 then
		return false, "Empty", self:_snapshot()
	end
	if self.deadlineAt and now < self.deadlineAt then
		return false, "NotExpired", self:_snapshot()
	end
	self.state = "Frozen"
	self.frozenRoster = copyIds(self.order)
	self.rosterId = string.format("birthday-%d", self.generation)
	self.destinationReservationId = string.format("destination-%d", self.generation)
	return true, "Frozen", {
		generation = self.generation,
		rosterId = self.rosterId,
		destinationReservationId = self.destinationReservationId,
		members = copyIds(self.frozenRoster),
	}
end

function QueueService:BeginTransfer()
	if self.state ~= "Frozen" then
		return false, "NotFrozen"
	end
	self.state = "Transferring"
	return true, "Transferring"
end

function QueueService:CompleteTransfer()
	if self.state ~= "Transferring" then
		return false, "NotTransferring"
	end
	self.state = "Completed"
	return true, "Completed"
end

function QueueService:FailTransfer()
	if self.state ~= "Transferring" and self.state ~= "Frozen" then
		return false, "NotTransferable"
	end
	self.state = "Failed"
	return true, "Failed"
end

function QueueService:ResetAfterTransfer()
 if self.state ~= "Completed" and self.state ~= "Failed" then return false, "NotFinished" end
 self:_reset()
 return true, "Reset"
end

return QueueService
