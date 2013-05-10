SoldierLogic = {}
do
	local maxs={}
	local camps={}
	local barracks = {}
	local spaceMax = 0
	
	local snumber = {}
	
	function SoldierLogic.setCampMax(buildIndex, max)
		maxs[buildIndex] = max
		local num=0
		for i, mnum in pairs(maxs) do
			num = num + mnum
		end
		spaceMax = num
	end
	
	function SoldierLogic.setCamp(buildIndex, camp)
		camps[buildIndex] = camp
	end
	
	function SoldierLogic.setBarrack(buildIndex, barrack)
		barracks[buildIndex] = barrack
	end
	
	function SoldierLogic.getSpaceMax()
		return spaceMax
	end
	
	function SoldierLogic.getSoldierNumber(sid)
		return snumber[sid]
	end
	
	function SoldierLogic.getCurSpace()
		local ret = 0
		for i=1, #camps do
			ret = ret + camps[i]:getCurSpace()
		end
		return ret
	end
	
	function SoldierLogic.getTrainingSpace()
		local ret = 0
		for i=1, #barracks do
			ret = ret + barracks[i].totalSpace
		end
		return ret
	end
	
	local function sortByBeginTime(a, b)
		return a.beginTime<b.beginTime
	end
	
	function SoldierLogic.addSoldierToCamp(sid, barrack, camp)
		snumber[sid] = (snumber[sid] or 0) + 1
		if SoldierLogic.isInit then
		    barrack = nil
		end
		EventManager.sendMessage("EVENT_BUY_SOLDIER", {sid=sid, from=barrack, to=camp})
	end
	
	function SoldierLogic.deploySoldier(costTroops)
	    for i=1, #camps do
	        local camp = camps[i]
	        local minusSpace = 0
	        local toDel = {}
	        for j, soldier in pairs(camp.soldiers) do
                local sid = soldier.info.sid
                if costTroops[sid]>0 then
                    costTroops[sid] = costTroops[sid]-1
                    minusSpace = minusSpace + soldier.info.space
                    table.insert(toDel, j)
                    soldier.view:removeFromParentAndCleanup(true)
                    snumber[sid] = snumber[sid] - 1
                end
            end
            for j=1, #toDel do
                camp.soldiers[toDel[j]] = nil
            end
            camp.curSpace = camp.curSpace - minusSpace
	    end
	end
	
	function SoldierLogic.getTrainEndTime()
	    if SoldierLogic.getTrainingSpace()+SoldierLogic.getCurSpace()<SoldierLogic.getSpaceMax() then
	        return 0
	    end
	    
		--local updateList = {}
		--for i=1, #barracks do
		--    local barrack = barracks[i]
		--	updateList[i] = {beginTime=barrack.beginTime}
		--	local callList = {}
		--	updateList[i].
		--end
		--local endTime = timer.getTime()
		return 0
	end
	
	function SoldierLogic.updateSoldierList()
		local updateList = {}
		for i=1, #barracks do
			updateList[i] = barracks[i]
		end
		local curTime = timer.getTime()
		while #updateList>0 do
			table.sort(updateList, sortByBeginTime)
			local barrack = updateList[1]
			local over = true
			local callList, isFull = barrack.callList, false
			if #callList>0 then
				isFull = SoldierLogic.getSpaceMax() < SoldierLogic.getCurSpace()+callList[1].space
			end
			if barrack.pause and not isFull then
				barrack.pause = false
			end
			if #callList > 0 and curTime - barrack.beginTime >= callList[1].perTime then
				if isFull then
					barrack.pause = true
				else
					over = false
					callList[1].num = callList[1].num-1
					local sid = callList[1].sid
					local camp = camps[1]
					for i=1, #camps do
						if camps[i]:getCurSpace() < camp:getCurSpace() then
							camp = camps[i]
						end
					end
					barrack.beginTime = barrack.beginTime+callList[1].perTime
					barrack.totalSpace = barrack.totalSpace - callList[1].space
					camp.curSpace = camp.curSpace + callList[1].space
					if callList[1].num == 0 then
						table.remove(callList,1)
					end
					SoldierLogic.addSoldierToCamp(sid, barrack, camp)
				end
			end
			if over then
				table.remove(updateList, 1)
			end
		end
		SoldierLogic.isInit = false
	end
	
	function SoldierLogic.init(isVisit)
		maxs={}
		camps={}
		barracks = {}
		spaceMax = 0
		snumber = {}
	end
	--CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(SoldierLogic.updateSoldierList, 0.1, false)
end