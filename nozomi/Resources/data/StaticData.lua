StaticData = {}

do
	local build_info_cache = {}
	local build_data_cache = {}
	local build_defense_cache = {}

	Entry = function (bid, btype, levelMax, totalMax, ...)
		local info = {bid=bid, btype=btype, levelMax=levelMax, totalMax=totalMax}
		info.name = StringManager.getString("dataBuildName" .. bid)
		local ikey = "dataBuildInfo" .. bid
		local binfo = StringManager.getString(ikey)
		if binfo~=ikey then
			info.info = binfo
		end
		local levelLimits = {}
		for i=1, 9 do
			levelLimits[i] = arg[i]
		end
		info.levelLimits = levelLimits
		
		build_info_cache[bid] = info
	end
	require "data.buildInfos"
	Entry = nil
	
	Entry = function (bid, level, time, costType, costValue, needLevel, hitPoints, extendValue1, extendValue2, gridSize, soldierSpace)
		local dataArray = build_data_cache[bid]
		if not dataArray then
			dataArray = {}
			build_data_cache[bid] = dataArray
		end
		local data = {bid=bid, level=level, time=time, costType=costType, costValue=costValue, needLevel=needLevel, hitPoints=hitPoints, extendValue1=extendValue1, extendValue2=extendValue2, gridSize=gridSize, soldierSpace=soldierSpace}
		dataArray[level] = data 
	end
	require "data.buildDatas"
	Entry = nil
	
	Entry = function (bid,range,extendRange,attackSpeed,damageRange,attackUnitType,favorite,favoriteRate)
		build_defense_cache[bid] = {bid=bid, range=range/10, extendRange=extendRange/10, attackSpeed=attackSpeed/1000, damageRange=damageRange/10, attackUnitType=attackUnitType, favorite=favorite, favoriteRate=favoriteRate}
	end
	require "data.buildDefences"
	Entry = nil
	
	function StaticData.getBuildInfo(bid)
		return build_info_cache[bid]
	end
	
	function StaticData.getBuildData(bid, level)
		return build_data_cache[bid][level]
	end
	
	function StaticData.getDefenseData(bid)
		return build_defense_cache[bid]
	end
	
	function StaticData.getMaxLevelData(bid)
		local binfo = StaticData.getBuildInfo(bid)
		local bdata = StaticData.getBuildData(bid, binfo.levelMax)
		return bdata
	end
	
	
	local soldier_info_cache = {}
	local soldier_data_cache = {}
	
	Entry = function (sid, space, time, attackType, moveSpeed, attackSpeed, range, damageRange, favorite, favoriteRate, unitType)
		soldier_info_cache[sid] = {sid=sid, space=space, time=time, attackType=attackType, moveSpeed=moveSpeed, attackSpeed=attackSpeed/1000, range=range/10, damageRange=damageRange/10, favorite=favorite, favoriteRate=favoriteRate, unitType=unitType}
		soldier_info_cache[sid].name = StringManager.getString("dataSoldierName" .. sid)
	end
	require "data.soldierInfos"
	Entry = nil
	
	Entry = function (sid, level, dps, hitpoints, cost)
		local dataArray = soldier_data_cache[sid]
		if dataArray==nil then
			dataArray = {}
			soldier_data_cache[sid] = dataArray
		end
		dataArray[level] = {sid=sid, level=level, dps=dps, hitpoints=hitpoints, cost=cost}
		if level > (soldier_info_cache[sid].levelMax or 0) then
			soldier_info_cache[sid].levelMax = level
		end
	end
	require "data.soldierDatas"
	Entry = nil
	
	function StaticData.getSoldierInfo(sid)
		return soldier_info_cache[sid]
	end
	
	function StaticData.getSoldierData(sid, level)
		return soldier_data_cache[sid][level]
	end
	
	function StaticData.getMaxSoldierData(sid)
		local sinfo = StaticData.getSoldierInfo(sid)
		local sdata = StaticData.getSoldierData(sid, sinfo.levelMax)
		return sdata
	end
	
	local research_info_cache = {}
	Entry = function (rid, level, cost, time, requireLevel)
		local item = {id=rid, level=level, cost=cost, time=time, requireLevel=requireLevel}
		local dataArray = research_info_cache[rid]
		if not dataArray then
			dataArray = {}
			research_info_cache[rid] = dataArray
		end
		dataArray[level] = item
	end
	require "data.researchInfos"
	Entry = nil
	
	function StaticData.getResearchInfo(lid, level)
		return research_info_cache[lid][level]
	end
end