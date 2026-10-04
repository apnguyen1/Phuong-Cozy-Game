-- Optional extension surface, shared by Main and activity/finale/host modules.
-- Registration functions only change client presentation. All mutations still
-- travel through context.send() and are validated by the existing server.
local Extensions = { activities = {}, panels = {}, observers = {} }

function Extensions.RegisterActivity(activityId, renderer)
	assert(type(activityId) == "string" and type(renderer) == "function", "activity renderer required")
	Extensions.activities[activityId] = renderer
end

function Extensions.RegisterPanel(id, descriptor)
	assert(type(id) == "string" and type(descriptor) == "table" and type(descriptor.render) == "function", "panel renderer required")
	Extensions.panels[id] = descriptor
end

function Extensions.RegisterObserver(id, callback)
	assert(type(id) == "string" and type(callback) == "function", "observer required")
	Extensions.observers[id] = callback
end

function Extensions.Notify(payload, context)
	local ids = {}
	for id in pairs(Extensions.observers) do table.insert(ids, id) end
	table.sort(ids)
	for _, id in ipairs(ids) do
		local callback = Extensions.observers[id]
		local ok, err = pcall(callback, payload, context)
		if not ok then warn("Birthday client observer failed", id, err) end
	end
end

return Extensions
