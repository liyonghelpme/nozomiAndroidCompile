Achievements = {}

--成就模型={id=成就ID, level=成就等级, num=成就数值, max=成就要求数值, achieveType=成就类型, achieveKey=成就具体的索引}


-- 严格来说只有两种类型，增加两种特殊类型是为了避免可能的冲突
AchieveTypes={BuildLevel=1, BuildDestroy=2, Set=3, Add=4}
AchieveItems = {
					[1] = {type=AchieveTypes.BuildLevel, key=2001, [1]=2, [2]=5, [3]=10}, 
					[2] = {type=AchieveTypes.BuildLevel, key=1, [1]=3, [2]=5, [3]=8}, 
					[3] = {type=AchieveTypes.Add, key="obstacle", [1]=5, [2]=50, [3]=500}, 
					[4] = {type=AchieveTypes.BuildLevel, key=1001, [1]=2, [2]=5, [3]=9}, 
					[5] = {type=AchieveTypes.Add, key="oil", [1]=20000, [2]=1000000, [3]=100000000},
					[6] = {type=AchieveTypes.Add, key="food", [1]=20000, [2]=1000000, [3]=100000000},
					[7] = {type=AchieveTypes.Set, key="score", [1]=75, [2]=750, [3]=1250},
					[8]= {type=AchieveTypes.BuildDestroy, key=3006, [1]=10, [2]=100, [3]=200},
					[9]= {type=AchieveTypes.BuildDestroy, key=1, [1]=10, [2]=100, [3]=200},
					[10]= {type=AchieveTypes.BuildDestroy, key=2004, [1]=25, [2]=250, [3]=2500},
					[11]= {type=AchieveTypes.Add, key="battle", [1]=25, [2]=250, [3]=5000},
					[12]= {type=AchieveTypes.Add, key="defend", [1]=10, [2]=250, [3]=5000},
					[13]= {type=AchieveTypes.BuildDestroy, key=3002, [1]=25, [2]=500, [3]=5000},
					[14]= {type=AchieveTypes.Add, key="zombie", [1]=20000, [2]=250000, [3]=1000000}
				}
				
function Achievements.getAchieveItem(id, level)
	if AchieveItems[id] then
		local item = {id=id, level=level, num=0}
		item.type = AchieveItems[id].type
		item.key = AchieveItems[id].key
		if level<=3 then
			item.max = AchieveItems[id][level]
		end
		return item
	end
	return nil
end

function Achievements.init(achievements)
	Achievements.indexMap = {{isAdd=false}, {isAdd=true}, {isAdd=false}, {isAdd=true}}
	local items = {}
	for i, achieve in ipairs(achievements) do
		local item = Achievements.getAchieveItem(achieve[1], achieve[2])
		if item then
			item.num = achieve[3]
			if achieve[2]<=3 then
				Achievements.indexMap[item.type][item.key] = item
			end
			table.insert(items, item)
		end
	end
	Achievements.items = items
end

function Achievements.getAchievements()
	local items = {}
	for i, item in pairs(Achievements.items) do
		items[i] = {item.id, item.level, item.num}
	end
	return items
end

function Achievements.getAchievementsAllData()
	local items = {}
	for i, item in pairs(Achievements.items) do
		table.insert(items, {id=item.id, level=item.level, num=item.num, max=item.max, exp=item.exp or 10, crystal=item.crystal or 5, title=StringManager.getString("dataAchieveTitle" .. item.id), desc=StringManager.getString("dataAchieveDesc" .. item.id .. "_" .. squeeze(item.level, 1, 3))})
	end
	return items
end

function Achievements.completeAchievement(id)
    for i, item in pairs(Achievements.items) do
        if item.id==id then
            item.level = item.level+1
            break
        end
    end
end

function Achievements.updateAchieveData(type, key, value)
	local achieves = Achievements.indexMap[type]
	local a = achieves[key]
	if a and a.level<4 then
		local oldValue = a.num
		if achieves.isAdd then
			a.num = a.num + value
		elseif a.num<value then
			a.num = value
		end
		if a.num>= AchieveItems[a.id][3] then
		    a.num = AchieveItems[a.id][3]
		end
		if a.num>=a.max then
		    EventManager.sendMessage("EVENT_NOTICE_BUTTON", {name="achieve", isShow=true})
		end
	end
end

function Achievements.eventHandler(eventType, param)
	if eventType == EventManager.eventType.EVENT_BUILD_UPDATE then
		local bid = param.bid
		local level = param.level
		Achievements.updateAchieveData(AchieveTypes.BuildLevel, bid, level)
	elseif eventType == EventManager.eventType.EVENT_BATTLE_END then
		local result = param
		local resourceTypes = {"oil", "food"}
		for _, type in ipairs(resourceTypes) do
			Achievements.updateAchieveData(AchieveTypes.Add, type, result[type])
		end
		local destroys = result.destroys
		for bid, num in pairs(destroys) do
			Achievements.updateAchieveData(AchieveTypes.BuildDestroy, bid, num)
		end
		if result.score > 0 then
			Achievements.updateAchieveData(AchieveTypes.Add, "battle", 1)
		end
	elseif eventType == EventManager.eventType.EVENT_OTHER_OPERATION then
		Achievements.updateAchieveData(AchieveTypes[param.type], param.key, param.value or 1)
	end
end

EventManager.registerEventMonitor({"EVENT_BUILD_UPDATE", "EVENT_BATTLE_END", "EVENT_OTHER_OPERATION"}, Achievements.eventHandler)