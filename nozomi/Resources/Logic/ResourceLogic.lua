ResourceLogic = {}

do
	local function sortByResource(a, b)
		return a.resource < b.resource
	end
	
	local resourceTypes = {"oil", "food", "person", "special", "builder"}
	local resourceItems = {}
	for _, resouceType in pairs(resourceTypes) do
		resourceItems[resouceType] = {num=0, max=0, maxs={}, storages={}} 
	end
	
	function ResourceLogic.setResourceMax(resourceType, buildIndex, max)
		print(resourceType, buildIndex)
		resourceItems[resourceType].maxs[buildIndex] = max
		local num=0
		for i, mnum in pairs(resourceItems[resourceType].maxs) do
			num = num + mnum
		end
		resourceItems[resourceType].max = num
	end
	
	function ResourceLogic.setResourceStorage(resourceType, buildIndex, storage)
		resourceItems[resourceType].storages[buildIndex] = storage
		local num=0
		for i, storage in pairs(resourceItems[resourceType].storages) do
			num = num + storage.resource
		end
		resourceItems[resourceType].num = num
	end
	
	function ResourceLogic.getResource(resourceType)
		return resourceItems[resourceType].num
	end
	
	function ResourceLogic.getResourceMax(resourceType)
		return resourceItems[resourceType].max
	end
	
	function ResourceLogic.changeResource(resourceType, value)
		local item = resourceItems[resourceType]
		if not item then
			return UserData.changeValue(resourceType, value)
		end
		local p = {}
		local k=1
		if value>0 then
			if item.max-item.num<value then
				value = item.max - item.num
			end
		else
			k = -1
			value = -value
		end
		local retValue = value
		item.num = item.num + k*value
		for i, max in pairs(item.maxs) do
			local storage = item.storages[i]
			table.insert(p, {max=(k+1)/2*max-k*storage.resource, resource=k*storage.resource, storage=storage, toAdd=0})
		end
			
		local idx, tnum=1, #p
		table.sort(p, sortByResource)
		for i=1, tnum do
			if p[i].max > value then
				p[i].storage.resource = p[i].storage.resource + value*k
				break
			else
				value = value - p[i].max
				p[i].storage.resource = p[i].storage.resource + p[i].max*k
			end
		end
		return retValue
	end
	
	
	function ResourceLogic.checkAndCost(goods)
		local costType = goods.costType
		if costType == "money" then
			doNothing()
		elseif costType == "crystal" then
			if goods.costValue > UserData[costType] then
				display.pushNotice(UI.createNotice(StringManager.getString("No Money")))
				return false
			else
				UserData.changeValue(costType, -goods.costValue)
				return true
			end
		elseif goods.costValue > ResourceLogic.getResource(costType) then
			if costType == "oil" or costType=="food" then
				local num = goods.costValue - ResourceLogic.getResource(costType)
				display.pushNotice(UI.createNotice(StringManager.getString("No Resource")))
			end
			return false
		else
			ResourceLogic.changeResource(costType, -goods.costValue)
			return true
		end
	end
end