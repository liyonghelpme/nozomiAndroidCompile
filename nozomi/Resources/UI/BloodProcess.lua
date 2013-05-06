BloodProcess = class()

function BloodProcess:ctor(max, isEnemy)
	self.isEnemy = isEnemy
	self.max = max
	self.value = max
	if isEnemy then
		self.view = UI.createSpriteWithFile("images/hitpointsEnemyBack.png")
		self:changeTexture("Enemy")
	else
		self.view = UI.createSpriteWithFile("images/hitpointsBack.png")
		self:changeTexture("Normal")
	end
	self.view:setOpacity(0)
	self.process:setOpacity(0)
end

function BloodProcess:changeTexture(textureName)
	if textureName~=self.textureName then
		self.textureName = textureName
		if self.process then
			self.process:removeFromParentAndCleanup(true)
		end
		if self.isEnemy then
			self.process = UI.createSpriteWithFile("images/hitpointsFiller" .. textureName .. ".png", CCSizeMake(95, 13))
			screen.autoSuitable(self.process, {nodeAnchor=General.anchorLeftBottom, x=3, y=3})
		else
			self.process = UI.createSpriteWithFile("images/hitpointsFiller" .. textureName .. ".png", CCSizeMake(55, 8))
			screen.autoSuitable(self.process, {nodeAnchor=General.anchorLeftBottom, x=2, y=2})
		end
		self.processSize = self.process:getContentSize()
		self.width = math.floor(self.processSize.width*self.value/self.max)
		self.process:setTextureRect(CCRectMake(0, 0, self.width, self.processSize.height))
		
		self.view:addChild(self.process)
	end
end

function BloodProcess:changeValue(value)
	if value<0 then value=0 end
	if value==self.value then return end
	self.value = value
	if not self.isEnemy then
		if value*2>self.max then
			self:changeTexture("Normal")
		elseif value*5>self.max then
			self:changeTexture("Half")
		else
			self:changeTexture("Little")
		end
	end
	local w = math.floor(self.processSize.width*self.value/self.max)
	if w~=self.width then
		self.width = w
		self.process:setTextureRect(CCRectMake(0, 0, w, self.processSize.height))
	end
	self.view:stopAllActions()
	
	local array = CCArray:create()
	array:addObject(CCAlphaTo:create(0.01, 255, 255))
	array:addObject(CCDelayTime:create(getParam("bloodVisibleTime", 2000)/1000))
	array:addObject(CCAlphaTo:create(getParam("bloodFadeOutTime", 500)/1000, 255, 0))
	self.view:runAction(CCSequence:create(array))
end

function UI.createBloodProcess(max, isEnemy)
	return BloodProcess.new(max, isEnemy)
end