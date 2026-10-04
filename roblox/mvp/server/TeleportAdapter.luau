-- Production adapter for one reserved destination. Studio must inject a local adapter.
local TeleportService = game:GetService("TeleportService")

local TeleportAdapter = {}
TeleportAdapter.__index = TeleportAdapter

function TeleportAdapter.new(config, services)
	config = config or {}
	services = services or {}
	local self = setmetatable({}, TeleportAdapter)
	self.gameplayPlaceId = config.GameplayPlaceId
	self.maxRetries = config.MaxRetries or 2
	self.retryDelay = config.RetryDelay or 3
	self.teleportService = services.teleportService or TeleportService
	self.reserveServer = services.reserveServer or function(placeId)
		return self.teleportService:ReserveServerAsync(placeId)
	end
	self.wait = services.wait or task.wait
	self.isStudio = services.isStudio
	if self.isStudio == nil then
		self.isStudio = game:GetService("RunService"):IsStudio()
	end
	return self
end

function TeleportAdapter:Reserve(roster)
	assert(self.gameplayPlaceId, "GameplayPlaceId is required for production teleport")
	if self.isStudio then
		return false, "StudioTeleportUnsupported"
	end
	if roster.reservedServerAccessCode then
		return true, "AlreadyReserved", roster
	end
	local ok, accessCode, privateServerId = pcall(self.reserveServer, self.gameplayPlaceId)
	if not ok then
		return false, "ReserveFailed"
	end
	roster.reservedServerAccessCode = accessCode
	roster.privateServerId = privateServerId
	return true, "Reserved", roster
end

function TeleportAdapter:Transfer(players, roster)
	assert(self.gameplayPlaceId, "GameplayPlaceId is required for production teleport")
	if self.isStudio then
		return false, "StudioTeleportUnsupported"
	end
	if #players ~= #roster.members then
		return false, "RosterPlayerMismatch"
	end
	local reserved, reserveReason = self:Reserve(roster)
	if not reserved then
		return false, reserveReason
	end
	local teleportOptions = Instance.new("TeleportOptions")
	teleportOptions.ReservedServerAccessCode = roster.reservedServerAccessCode
	teleportOptions:SetTeleportData({
		rosterId = roster.rosterId,
		destinationReservationId = roster.destinationReservationId,
		members = roster.members,
	})
	local ok, result = pcall(function()
		return self.teleportService:TeleportAsync(self.gameplayPlaceId, players, teleportOptions)
	end)
	if ok then
		return true, "Dispatched", result, 1
	end
	return false, "DispatchFailed", nil, 1
end

function TeleportAdapter:RetryMember(player, roster, attempt)
	if self.isStudio then
		return false, "StudioTeleportUnsupported"
	end
	if not roster.reservedServerAccessCode then
		return false, "ReservationMissing"
	end
	if attempt > self.maxRetries then
		return false, "RetryLimit"
	end
	local teleportOptions = Instance.new("TeleportOptions")
	teleportOptions.ReservedServerAccessCode = roster.reservedServerAccessCode
	teleportOptions:SetTeleportData({
		rosterId = roster.rosterId,
		destinationReservationId = roster.destinationReservationId,
		members = roster.members,
		retry = true,
	})
	local ok = pcall(function()
		self.teleportService:TeleportAsync(self.gameplayPlaceId, { player }, teleportOptions)
	end)
	if ok then
		return true, "RetryDispatched"
	end
	return false, "RetryFailed"
end

return TeleportAdapter
