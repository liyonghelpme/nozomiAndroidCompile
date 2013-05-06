Action = nil
do
	local PI = 3.14159265358979323846
	-- ���ڴ���һ��������ȥ�Ķ���
	local function createVibration(duration, x, y)
		local sactions = CCArray:create()
		sactions:addObject(CCMoveBy:create(duration, CCPointMake(x, y)))
		sactions:addObject(CCMoveBy:create(duration, CCPointMake(-x, -y)))
		return CCRepeatForever:create(CCSequence:create(sactions))
	end
	
	-- ���ڴ���һ����ͣ���ŵĶ���
	local function createScaleVibration(duration, scale)
		local sactions = CCArray:create()
		sactions:addObject(CCScaleTo:create(duration, 1 + scale))
		sactions:addObject(CCScaleTo:create(duration, 1))
		return CCRepeatForever:create(CCSequence:create(sactions))
	end
	
	local function sineout(t)
		if t >= 1 then return 1 end
		return math.sin(t*PI/2)
	end
	
	local function sinein(t)
		if t >= 1 then return 1 end
		return 1-math.cos(t*PI/2)
	end
	
	Action = {createScaleVibration = createScaleVibration, createVibration = createVibration; sineout = sineout, sinein = sinein}
end