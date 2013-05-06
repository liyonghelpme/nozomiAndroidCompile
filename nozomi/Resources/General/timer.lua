timer = nil
do
	local gameTime = 0
	local serverOff = 0
	
	local dayBaseTime = os.time({year=2013, month=1, day=1, hour=0})

	local function getTime(t)
		if t then
			return t-serverOff
		end
		return gameTime
	end
	
	local function setServerTime(t)
		serverOff = t-math.floor(gameTime) 
	end
	
	local function getServerTime(t)
		return math.floor(t+serverOff)
	end
	
	local function update(diff)
		gameTime = gameTime + diff
		--for i, t in pairs(actionUpdate) do
			
		--end
	end
	
	CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(update, 0, false)
	
	timer = {getTime = getTime, setServerTime=setServerTime, getServerTime=getServerTime}
	
	function timer.getDayTime()
		return (os.time()-dayBaseTime)%86400
	end
end