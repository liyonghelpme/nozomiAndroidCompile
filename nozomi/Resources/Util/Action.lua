Action = nil
do
	local PI = 3.14159265358979323846
	-- 用于创建一个移来移去的动画
	local function createVibration(duration, x, y)
		local sactions = CCArray:create()
		sactions:addObject(CCMoveBy:create(duration, CCPointMake(x, y)))
		sactions:addObject(CCMoveBy:create(duration, CCPointMake(-x, -y)))
		return CCRepeatForever:create(CCSequence:create(sactions))
	end
	
	-- 用于创建一个不停缩放的动画
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
	
	-- 直接runAction是因为需要设置旋转角度
	function Action.runGravityMove(node, t, fx, fy, tx, ty, fh, th)
		
		local g = 500
		local t1 = t/2+(th-fh)/(g*t)
		-- 避免数值不符合逻辑
		if t1<0 then
		    t1=0
		    g=-2*(th-fh)/t/t
		elseif t1>t then
		    t1=t
		    g=2*(th-fh)/t/t
		end
		local ox, oy = tx-fx, ty-fy+fh-th
		local H = t1*t1*g/2+fh
		local mx, my = fx+t1/t*ox, fy+t1/t*oy+H-fh
		local array = CCArray:create()
		array:addObject(CCEaseSineOut:create(CCMoveBy:create(t1, CCPointMake(0, H-fh))))
		array:addObject(CCEaseIn:create(CCMoveBy:create(t-t1, CCPointMake(0, th-H)), 2))
		print(H-fh, th-H)
		
	    local sarray = CCArray:create()
		sarray:addObject(CCSequence:create(array))
		
		sarray:addObject(CCMoveBy:create(t, CCPointMake(ox, oy)))
		
		local mx, my = fx+t1/t*ox, fy+t1/t*oy+H-fh
		local baseAngle = node:getRotation()
		local angle1 = 360-math.deg(math.atan2(my-fy, (mx-fx)/2))
		local angle2 = 360-math.deg(math.atan2(ty-my, (tx-mx)/2))
		--local angle1 = 270 - math.deg(math.atan2(H-h, (mx-self.initPos[1])/2))
		--local angle2 = 270 - math.deg(math.atan2(-H, (self.targetPos[1]-mx)/2))
		node:setRotation(angle1+baseAngle)
		sarray:addObject(CCRotateTo:create(t, angle2+baseAngle))
		
		node:runAction(CCSpawn:create(sarray))
	end
end