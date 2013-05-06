BattleLogic = {resources = {}}

function BattleLogic.init()
	BattleLogic.percent = 0
	BattleLogic.stars = 0
	BattleLogic.buildMax = 0
	BattleLogic.buildDestroyed = 0
	BattleLogic.builds = {}
	BattleLogic.destroys = {}
	BattleLogic.battleEnd = false
	BattleLogic.resources["food"].left = 0
	BattleLogic.resources["oil"].left = 0
end

function BattleLogic.addBuild(gridId, buildData)
	BattleLogic.buildMax = BattleLogic.buildMax + 1
	BattleLogic.builds[gridId] = buildData
	local resources = buildData.resources
	if resources then
		for type, resource in pairs(resources) do
			if BattleLogic.resources[type] then
				BattleLogic.resources[type].left = BattleLogic.resources[type].left + resource
			end
		end
	end
end

function BattleLogic.setBuildHitpoints(gridId, hitpoints)
	local buildData = BattleLogic.builds[gridId]
	if not buildData then return end
	local resources = buildData.resources
	if resources then
		for type, resource in pairs(resources) do
			local stoleValue = math.floor(resource*buildData.hitpoints/buildData.max)-math.floor(resource*hitpoints/buildData.max)
			if BattleLogic.resources[type] then 
				BattleLogic.resources[type].left = BattleLogic.resources[type].left - stoleValue
				BattleLogic.resources[type].stolen = BattleLogic.resources[type].stolen + stoleValue
			end
		end
	end
	buildData.hitpoints = hitpoints
end

function BattleLogic.destroyBuild(bid)
	BattleLogic.destroys[bid] = (BattleLogic.destroys[bid] or 0) + 1
	if bid==TOWN_BID then
		BattleLogic.stars = BattleLogic.stars + 1
	end
	BattleLogic.buildDestroyed = BattleLogic.buildDestroyed + 1
	local percent = math.floor(BattleLogic.buildDestroyed*100/BattleLogic.buildMax)
	if percent>=50 and BattleLogic.percent<50 then
		BattleLogic.stars = BattleLogic.stars+1
	elseif percent==100 then
		BattleLogic.stars = BattleLogic.stars+1
		BattleLogic.battleEnd = true
	end
	BattleLogic.percent = percent
end

function BattleLogic.getResource(resourceType)
	local resource = BattleLogic.resources[resourceType].base + BattleLogic.resources[resourceType].stolen
	if resource > BattleLogic.resources[resourceType].max then
		resource = BattleLogic.resources[resourceType].max
	end
	return math.floor(resource)
end

function BattleLogic.getLeftResource(resourceType)
	return math.ceil(BattleLogic.resources[resourceType].left)
end

function BattleLogic.computeScore(enemyScore)
	local dis = enemyScore - UserData.userScore
	local isHigher = true
	if dis<0 then
		dis = -dis
		isHigher = false
	end
	local scores = nil
	if dis>=400 then
		scores = {60, 1}
	elseif dis>=250 then
		scores = {math.floor(50 + (dis-250)/(400-250)*(60-50)), math.floor(5+(dis-250)/(400-250)*(1-5))}
	elseif dis>=130 then
		scores = {math.floor(40 + (dis-130)/(250-130)*(50-40)), math.floor(10+(dis-130)/(250-130)*(5-10))}
	elseif dis>=10 then
		scores = {math.floor(30 + (dis-10)/(130-10)*(40-30)), math.floor(20+(dis-10)/(130-10)*(10-20))}
	else
		scores = {math.floor(25 + (dis-0)/(10-0)*(30-25)), math.floor(25+(dis-0)/(10-0)*(20-25))}
	end
	if isHigher then
		BattleLogic.scores = {scores[1], -scores[2]}
	else
		BattleLogic.scores = {scores[2], -scores[1]}
	end
end

function BattleLogic.getBattleResult()
	local result = {destroys = BattleLogic.destroys}
	local resourceTypes = {"oil", "food"}
	for i=1, 2 do
		local resourceType = resourceTypes[i]
		result[resourceType] = BattleLogic.resources[resourceType].stolen
	end
	result.stars = BattleLogic.stars
	result.percent = BattleLogic.percent
	if BattleLogic.stars==0 then
		result.score = BattleLogic.scores[2]
	else
		result.score = math.ceil(BattleLogic.scores[1]*BattleLogic.stars/3)
	end
	return result
end

function BattleLogic.getStageResult()
	local result = {person=BattleLogic.resources["person"].stolen}
	return result
end