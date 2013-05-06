EventManager = {}

do
	local eventType = {}
	local index = 1
	function Entry(key)
		eventType[key] = index
		index = index + 1
	end
	require "data.events"
	Entry = nil
	EventManager.eventType = eventType
	
	local monitorLists = {}
	local monitors = {}
	local monitorIdMax = 1
	local function registerEventMonitor(events, callback, delegate)
		local monitorId = monitorIdMax
		monitorIdMax = monitorIdMax+1
		monitors[monitorId] = {callback=callback, delegate=delegate}
		for i = 1, #events do
			local event = events[i]
			if type(event) == "string" then
				event = eventType[event]
			end
			if not monitorLists[event] then
				monitorLists[event] = {}
			end
			table.insert(monitorLists[event], monitorId)
		end
		return monitorId
	end
	EventManager.registerEventMonitor = registerEventMonitor
	
	local function removeEventMonitor(mid)
		monitors[mid] = nil
	end
	EventManager.removeEventMonitor = removeEventMonitor
	
	local function sendMessage(event, eventParam)
		if type(event) == "string" then
			event = eventType[event]
		end
		local lists = monitorLists[event]
		if lists then
			for i, v in pairs(lists) do
				if not monitors[v] then
					lists[i] = nil
				else
					local handler = monitors[v]
					if handler.delegate then
						handler.callback(handler.delegate, event, eventParam)
					else
						handler.callback(event, eventParam)
					end
				end
			end
		end
	end
	EventManager.sendMessage = sendMessage
	function EventManager.sendMessageCallback(param)
		sendMessage(param.event, param.eventParam)
	end
end