-- STUDIO-ONLY LOCAL PLAYTEST ADAPTER.
-- This deliberately does not simulate production teleport or reserve a server.
local LocalPartyTransferAdapter = {}
LocalPartyTransferAdapter.__index = LocalPartyTransferAdapter

function LocalPartyTransferAdapter.new(onPartyReady)
	return setmetatable({ onPartyReady = onPartyReady }, LocalPartyTransferAdapter)
end

function LocalPartyTransferAdapter:Transfer(players, roster)
	assert(type(self.onPartyReady) == "function", "local playtest callback is required")
	self.onPartyReady(players, roster)
	return true, "LocalPartyReady"
end

return LocalPartyTransferAdapter
