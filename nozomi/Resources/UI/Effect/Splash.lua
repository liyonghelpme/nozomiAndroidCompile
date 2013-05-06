Splash = class()

function Splash:ctor(num, color)
	self.view = CCSpriteBatchNode:create("images/effects/newDrop.png", num)
	self.particle = {}
	for i=1, num do
		local sp = CCSprite:create("images/effects/newDrop.png")
		sp:setColor(color)
		sp:setScale(0.25*math.random()+0.25)
		local x, y = math.random()*10-5, math.random()*100
		local angle = -math.deg(math.atan2(y, x))
		sp:setRotation(angle)
		screen.autoSuitable(sp, {nodeAnchor=General.anchorCenter, x=x, y=y})
		self.view:addChild(sp)
		local lifeTime = 1+math.random()*0.5
		sp:runAction(CCFadeOut:create(lifeTime))
		table.insert(self.particle, {sp, lifeTime, math.random()*200-100, math.random()*100+300, angle, angle+90})
	end
	self.updateEntry = {callback=self.update, inteval=0}
	self.passTime = 0
	simpleRegisterEvent(self.view, {update=self.updateEntry}, self)
end

function Splash:update(diff)
	self.passTime = self.passTime + diff
	for _, item in ipairs(self.particle) do
	    local gravity = -200
	    item[4] = item[4] + gravity*diff
	    local x, y = item[1]:getPosition()
	    item[1]:setPosition(x+item[3]*diff, y+item[4]*diff)
	
	    item[5] = item[5]+diff*10*item[6]
	    item[1]:setRotation(item[5])
	
	    --if self.passTime > item[2] then
	    --    item[1]:removeFromParentAndCleanup(true)
	    --end
	end
end

FoodSplash = class()

function FoodSplash:ctor(prefix, typeNumber, aniNumber, number)
	local cache = CCSpriteFrameCache:sharedSpriteFrameCache()
	cache:addSpriteFramesWithFile("images/effects/" .. prefix .. ".plist")
	self.view = CCSpriteBatchNode:create("images/effects/" .. prefix .. ".png", number)
	self.particle = {}
	for i=1, number do
		local aniType = math.random(typeNumber)
		local aniFrames = CCArray:create()
		for j=1, aniNumber do
			aniFrames:addObject(cache:spriteFrameByName(prefix .. "_" .. aniType .. "_" .. (j-1) .. ".png"))
		end
		local animation = CCAnimation:createWithSpriteFrames(aniFrames, 0.1)
		local sp = CCSprite:createWithSpriteFrameName(prefix .. "_" .. aniType .. "_0.png")
		sp:setScale(0.25*math.random()+0.25)
		local x, y = math.random()*10-5, math.random()*100
		screen.autoSuitable(sp, {nodeAnchor=General.anchorCenter, x=x, y=y})
		self.view:addChild(sp)
		local lifeTime = 1+math.random()*0.5
		sp:runAction(CCRepeatForever:create(CCAnimate:create(animation)))
		local sarray = CCArray:create()
		sarray:addObject(CCDelayTime:create(0.5))
		sarray:addObject(CCFadeOut:create(lifeTime-0.5))
		sp:runAction(CCSequence:create(sarray))
		table.insert(self.particle, {sp, lifeTime, math.random()*200-100, math.random()*100+200})
	end
	self.updateEntry = {callback=self.update, inteval=0}
	self.passTime = 0
	simpleRegisterEvent(self.view, {update=self.updateEntry}, self)
end

function FoodSplash:update(diff)
	self.passTime = self.passTime + diff
	for _, item in ipairs(self.particle) do
	    local gravity = -200
	    item[4] = item[4] + gravity*diff
	    local x, y = item[1]:getPosition()
	    item[1]:setPosition(x+item[3]*diff, y+item[4]*diff)
	
	    --item[5] = item[5]+diff*10*item[6]
	    item[1]:setRotation(-math.deg(math.atan2(item[4], item[3])))
	
	    --if self.passTime > item[2] then
	    --    item[1]:removeFromParentAndCleanup(true)
	    --end
	end
end

function UI.createWaterSplashEffect(num, color)
	color = color or ccc3(50, 128, 255)
	return Splash.new(num, color)
end

function UI.createFoodSplashEffect(num)
	return FoodSplash.new("guantou", 2, 9, num)
end