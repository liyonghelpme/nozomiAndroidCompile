require "Dialog.BattleResultDialog"

BattleMenuLayer = class()

local resourceTypes = {"oil", "food"}

local function cellSelect(item)
	item.delegate:selectItem(item)
end

local function updateBattleCell(bg, scrollView, item)
	bg:removeAllChildrenWithCleanup(true)
	if item.id>0 then
		simpleRegisterButton(bg, {callback=cellSelect, callbackParam=item, priority=display.MENU_BUTTON_PRI})
		item.view = bg
		local temp = UI.createSpriteWithFile("images/battleItemBg.png",CCSizeMake(81, 104))
		screen.autoSuitable(temp, {x=0, y=0})
		bg:addChild(temp)
		SoldierHelper.addSoldierHead(bg, item.id, 0.7)
		temp = UI.createLabel("x" .. item.num, "fonts/font3.fnt", 18, {colorR = 255, colorG = 255, colorB = 255, lineOffset=12})
		screen.autoSuitable(temp, {x=40, y=90, nodeAnchor=General.anchorCenter})
		bg:addChild(temp)
		
		item.numLabel = temp
		for i=1, UserData.researchLevel[item.id] do
			temp = UI.createSpriteWithFile("images/soldierStar.png",CCSizeMake(17, 17))
			screen.autoSuitable(temp, {x=14*i-11, y=6})
			bg:addChild(temp)
		end
	else
		local temp = UI.createSpriteWithFile("images/battleItemNone.png",CCSizeMake(81, 104))
		screen.autoSuitable(temp, {x=0, y=0})
		bg:addChild(temp)
	end
end

function BattleMenuLayer:ctor(scene, logic)
	self.scene = scene
	self.logic = logic
	self.beginTime = timer.getTime()
	self.view = CCNode:create()
	
	self:initBottom()
	self:initLeftTop()
	self:initRightTop()
	self:initTop()
	
	simpleRegisterEvent(self.view, {update={inteval=0.2, callback=self.update}}, self)
end

function BattleMenuLayer:initTips()

	local nextCost = NEXT_COST[UserData.level]
	local temp, bg = nil
	bg = CCNode:create()
	temp = UI.createButton(CCSizeMake(187, 84), self.nextBattleScene, {callbackParam=self, image="images/buttonOrange.png", priority=display.MENU_BUTTON_PRI})
	screen.autoSuitable(temp, {x=903, y=205, nodeAnchor=General.anchorCenter})
	bg:addChild(temp)
	
	local temp1 = UI.createLabel(StringManager.getString("buttonNext"), "fonts/font3.fnt", 25, {colorR = 255, colorG = 255, colorB = 255, lineOffset=12})
	screen.autoSuitable(temp1, {x=151, y=52, nodeAnchor=General.anchorRight})
	temp:addChild(temp1)
	temp1 = UI.createSpriteWithFile("images/oil.png",CCSizeMake(20, 24))
	screen.autoSuitable(temp1, {x=143, y=8})
	temp:addChild(temp1)
	temp1 = UI.createLabel(tostring(nextCost), "fonts/font3.fnt", 20, {colorR = 255, colorG = 255, colorB = 255, lineOffset=12})
	screen.autoSuitable(temp1, {x=137, y=19, nodeAnchor=General.anchorRight})
	temp:addChild(temp1)
	temp1 = UI.createSpriteWithFile("images/findEnemyIcon.png",CCSizeMake(76, 53))
	screen.autoSuitable(temp1, {x=8, y=12})
	temp:addChild(temp1)
	
	temp = UI.createLabel(StringManager.getString("battleTips"), "fonts/font3.fnt", 26, {colorR = 255, colorG = 255, colorB = 255, size=CCSizeMake(458, 0), lineOffset=-12})
	screen.autoSuitable(temp, {x=536, y=210, nodeAnchor=General.anchorCenter})
	bg:addChild(temp)
	self.time = 30
	self.count = 3
	self.tipsNode = bg
end

function BattleMenuLayer:initRightTop()
	local temp, bg = nil
	bg = CCNode:create()
	bg:setContentSize(CCSizeMake(256, 256))
	screen.autoSuitable(bg, {scaleType=screen.SCALE_NORMAL, screenAnchor=General.anchorRightTop})
	self.view:addChild(bg)
	
	temp = UI.createSpriteWithFile("images/operationBottom.png",CCSizeMake(156, 30))
	screen.autoSuitable(temp, {x=81, y=28})
	bg:addChild(temp)
	temp = UI.createSpriteWithFile("images/crystal.png",CCSizeMake(55, 54))
	screen.autoSuitable(temp, {x=186, y=11})
	bg:addChild(temp)
	temp = UI.createLabel(tostring(UserData.crystal), "fonts/font3.fnt", 20, {colorR = 255, colorG = 255, colorB = 255})
	screen.autoSuitable(temp, {x=182, y=41, nodeAnchor=General.anchorRight})
	bg:addChild(temp)
	self.crystal = {valueLabel=temp, value=UserData.crystal}
	
	local items = {{"person", 160, 30, 163, 172, 74}, {"oil", 219, 29, 225, 188, 134}, {"food", 219, 29, 225, 193, 191}}
	for i=1, 3 do
		local resourceType = items[i][1]
		local item = {}
		local filler = resourceType
		if resourceType=="person" then filler="special" end
		
		temp = UI.createSpriteWithFile("images/" .. filler .. "Filler.png",CCSizeMake(items[i][2], items[i][3]))
		local dis = (items[i][4]-items[i][2])/2
		screen.autoSuitable(temp, {x=237-dis, y=24+i*59+dis, nodeAnchor=General.anchorRightBottom})
		bg:addChild(temp)
		item.filler = temp
		item.size = temp:getContentSize()
		temp = UI.createSpriteWithFile("images/fillerBottom.png",CCSizeMake(items[i][4], 34))
		screen.autoSuitable(temp, {x=237-items[i][4], y=24+i*59})
		bg:addChild(temp)
		temp = UI.createSpriteWithFile("images/" .. resourceType .. ".png")
		screen.autoSuitable(temp, {x=items[i][5], y=items[i][6]})
		bg:addChild(temp)
		item.value = ResourceLogic.getResource(resourceType)
		item.max = ResourceLogic.getResourceMax(resourceType)
		temp = UI.createLabel(tostring(item.value), "fonts/font3.fnt", 20, {colorR = 255, colorG = 255, colorB = 255})
		screen.autoSuitable(temp, {x=182, y=39 + 59*i, nodeAnchor=General.anchorRight})
		bg:addChild(temp)
		item.valueLabel = temp
		temp = UI.createLabel(StringManager.getFormatString("resourceMax", {max=item.max}), "fonts/font2.fnt", 13, {colorR = 255, colorG = 255, colorB = 255})
		screen.autoSuitable(temp, {x=243-items[i][4], y=67 + 59*i, nodeAnchor=General.anchorLeft})
		bg:addChild(temp)
		item.maxLabel = temp
		local lmax = item.max
		if lmax==0 then lmax=1 end
		local cr = CCRectMake(item.size.width-item.size.width*item.value/lmax, 0, item.size.width*item.value/lmax, item.size.height)
		item.filler:setTextureRect(cr)
		self[resourceType] = item
	end
end

function BattleMenuLayer:initLeftTop()

	local enemyLevel, enemyName = 57, "TEST"

	local temp, bg = nil
	bg = CCNode:create()
	bg:setContentSize(CCSizeMake(256, 256))
	screen.autoSuitable(bg, {scaleType=screen.SCALE_NORMAL, screenAnchor=General.anchorLeftTop})
	self.view:addChild(bg)
	
	self.stolenResources = {}
	temp = UI.createLabel("0", "fonts/font3.fnt", 20, {colorR = 255, colorG = 255, colorB = 255, lineOffset=12})
	screen.autoSuitable(temp, {x=70, y=133, nodeAnchor=General.anchorLeft})
	bg:addChild(temp)
	self.stolenResources["oil"] = {resource=0, label=temp}
	temp = UI.createSpriteWithFile("images/oil.png",CCSizeMake(27, 31))
	screen.autoSuitable(temp, {x=35, y=117})
	bg:addChild(temp)
	temp = UI.createSpriteWithFile("images/food.png",CCSizeMake(26, 34))
	screen.autoSuitable(temp, {x=38, y=148})
	bg:addChild(temp)
	temp = UI.createSpriteWithFile("images/score.png",CCSizeMake(29, 35))
	screen.autoSuitable(temp, {x=35, y=80})
	bg:addChild(temp)
	temp = UI.createLabel(tostring(BattleLogic.scores[1]), "fonts/font3.fnt", 20, {colorR = 255, colorG = 255, colorB = 255, lineOffset=12})
	screen.autoSuitable(temp, {x=71, y=98, nodeAnchor=General.anchorLeft})
	bg:addChild(temp)
	temp = UI.createSpriteWithFile("images/exp.png",CCSizeMake(53, 51))
	screen.autoSuitable(temp, {x=16, y=193})
	bg:addChild(temp)
	temp = UI.createLabel(StringManager.getString("labelAvaliable"), "fonts/font2.fnt", 13, {colorR = 255, colorG = 255, colorB = 255})
	screen.autoSuitable(temp, {x=71, y=191, nodeAnchor=General.anchorLeft})
	bg:addChild(temp)
	temp = UI.createLabel(StringManager.getString("labelDefeat"), "fonts/font2.fnt", 13, {colorR = 255, colorG = 255, colorB = 255})
	screen.autoSuitable(temp, {x=71, y=64, nodeAnchor=General.anchorLeft})
	bg:addChild(temp)
	temp = UI.createLabel(tostring(enemyLevel), "fonts/font3.fnt", 22, {colorR = 255, colorG = 255, colorB = 255, lineOffset=12})
	screen.autoSuitable(temp, {x=43, y=220, nodeAnchor=General.anchorCenter})
	bg:addChild(temp)
	temp = UI.createLabel("0", "fonts/font3.fnt", 20, {colorR = 255, colorG = 255, colorB = 255, lineOffset=12})
	screen.autoSuitable(temp, {x=71, y=166, nodeAnchor=General.anchorLeft})
	bg:addChild(temp)
	self.stolenResources["food"] = {resource=0, label=temp}
	temp = UI.createLabel(tostring(BattleLogic.scores[2]), "fonts/font3.fnt", 20, {colorR = 255, colorG = 190, colorB = 189, lineOffset=12})
	screen.autoSuitable(temp, {x=71, y=42, nodeAnchor=General.anchorLeft})
	bg:addChild(temp)
	temp = UI.createSpriteWithFile("images/score.png",CCSizeMake(29, 35))
	screen.autoSuitable(temp, {x=36, y=24})
	bg:addChild(temp)
	temp = UI.createLabel(enemyName, "fonts/font3.fnt", 22, {colorR = 255, colorG = 255, colorB = 231, lineOffset=12})
	screen.autoSuitable(temp, {x=71, y=221, nodeAnchor=General.anchorLeft})
	bg:addChild(temp)
end

function BattleMenuLayer:initBottom()
	local temp, bg = nil
	bg = CCNode:create()
	screen.autoSuitable(bg, {screenAnchor=General.anchorLeftBottom, scaleType=screen.SCALE_WIDTH_FIRST})
	self.view:addChild(bg)
	
	self:initTips()
	bg:addChild(self.tipsNode)
	
	temp = UI.createSpriteWithFile("images/battleStarBg.png",CCSizeMake(183, 94))
	screen.autoSuitable(temp, {x=14, y=157})
	bg:addChild(temp)
	local stars = {}
	for i=1, 3 do
		temp = UI.createSpriteWithFile("images/battleStar1.png",CCSizeMake(29, 27))
		screen.autoSuitable(temp, {nodeAnchor=General.anchorCenter, x=46+i*30, y=212})
		bg:addChild(temp)
		stars[i] = temp
	end
	self.stars = stars
	self.starsNum = 0
	
	temp = UI.createLabel("0%", "fonts/font3.fnt", 30, {colorR = 255, colorG = 255, colorB = 255, lineOffset=12})
	screen.autoSuitable(temp, {x=106, y=181, nodeAnchor=General.anchorCenter})
	bg:addChild(temp)
	self.percent = 0
	self.percentLabel = temp
	
	temp = UI.createLabel(StringManager.getString("damagePercent"), "fonts/font3.fnt", 16, {colorR = 255, colorG = 255, colorB = 255, lineOffset=12})
	screen.autoSuitable(temp, {x=108, y=234, nodeAnchor=General.anchorCenter})
	bg:addChild(temp)
	
	temp = UI.createSpriteWithFile("images/battleListBg.png",CCSizeMake(995, 135))
	screen.autoSuitable(temp, {x=14, y=14})
	bg:addChild(temp)
	
	local items = {}
	local soldiers = {20, 20, 20, 20, 20, 20, 20, 20, 20, 20}
	--FightLogic.getSoldiers()
	for i=1, 10 do
		if soldiers[i]>0 then
			table.insert(items, {id=i, num=soldiers[i], type="soldier", delegate=self})
		end
	end
	local length = #items
	local movable = false
	if length<11 then
		for i=length+1, 11 do
			table.insert(items, {id=0})
		end
	elseif length>10 then
		movable = true
	end
	self.items = items
	local scrollView = UI.createScrollViewAuto(CCSizeMake(995, 135), true, {priority=display.MENU_PRI, size=CCSizeMake(81, 104), infos=items, offx=28, offy=17, disx=6, dismovable=not movable, cellUpdate=updateBattleCell})
	screen.autoSuitable(scrollView.view)
	temp:addChild(scrollView.view)
	if length>0 then
		self:selectItem(items[1])
	end
end

function BattleMenuLayer:initTop()
	local temp, bg = nil
	bg = CCNode:create()
	bg:setContentSize(CCSizeMake(256, 128))
	screen.autoSuitable(bg, {screenAnchor=General.anchorTop, scaleType=screen.SCALE_NORMAL})
	self.view:addChild(bg)
	temp = UI.createLabel(StringManager.getTimeString(30), "fonts/font3.fnt", 30, {colorR = 255, colorG = 255, colorB = 255})
	screen.autoSuitable(temp, {x=128, y=19, nodeAnchor=General.anchorCenter})
	bg:addChild(temp)
	self.timeLabel = temp
	temp = UI.createLabel(StringManager.getString("labelBattleStartIn"), "fonts/font2.fnt", 14, {colorR = 255, colorG = 215, colorB = 214})
	screen.autoSuitable(temp, {x=128, y=45, nodeAnchor=General.anchorCenter})
	bg:addChild(temp)
	self.timeTypeLabel = temp
	temp = UI.createButton(CCSizeMake(133, 48), self.endBattle, {callbackParam=self, image="images/buttonEnd.png", text=StringManager.getString("buttonEndBattle"), fontSize=18, fontName="fonts/font3.fnt", priority=display.MENU_BUTTON_PRI})
	screen.autoSuitable(temp, {x=128, y=82, nodeAnchor=General.anchorCenter})
	bg:addChild(temp)
end

function BattleMenuLayer:nextBattleScene()
	-- TODO
	Action.test(true)
	delayCallback(1, display.runScene, PreBattleScene)
end

function BattleMenuLayer:endBattle(forceEnd)
	if self.troopsCost then
		if forceEnd then
			BattleLogic.battleEnd = true
		else
			display.showDialog(AlertDialog.new(StringManager.getString("alertTitleEndBattle"), StringManager.getString("alertTextEndBattle"), {callback=self.endBattle, param=true}, self))
		end
	else
		UI.testChangeScene(true)
		delayCallback(1, display.popScene)
		delayCallback(1, UI.testChangeScene)
		--display.popScene()
		--UI.testChangeScene()
	end
	self.time = nil
end

function BattleMenuLayer:beginBattle()
	self.battleBegin = true
	if self.tipsNode then
		self.tipsNode:removeFromParentAndCleanup(true)
		self.tipsNode = nil
	end
	self.timeTypeLabel:setString(StringManager.getString("labelBattleEndIn"))
				
	local seed = os.time()
	math.randomseed(seed)
			
	self.replayFile = io.open(CCFileUtils:getWriteablePath() .. "replay.txt", "w")
	self.replayFile:write(json.encode(self.scene.initInfo) .. "\n")
	self.replayFile:write(seed .. "\n")
	
	self.time = 180
	self.count = nil
end

function BattleMenuLayer:executeSelectItem(touchPoint)
	local item = self.selectedItem
	if not BattleLogic.battleEnd and item then
		if item.num==0 then
			display.pushNotice(UI.createNotice(StringManager.getString("noticeSelectItemEmpty")))
			return false
		end
		item.num = item.num-1
		if item.num==0 then
			print("test")
			item.view:setSatOffset(-100)
		end
		if item.type=="soldier" then
			local p = self.scene.ground:convertToNodeSpace(CCPointMake(touchPoint[1], touchPoint[2]))
			local soldier = SoldierHelper.create(item.id, {isFighting=true})
			BattleLogic.id = (BattleLogic.id or 0)+1
			soldier.id = BattleLogic.id
			soldier:addToScene(self.scene, {p.x, p.y})
			table.insert(self.scene.soldiers, soldier)
			if not self.battleBegin then
				self:beginBattle()
			end
			self.troopsCost = true
			self.replayFile:write(json.encode({timer.getTime()-self.beginTime, "s", item.id, p.x, p.y}) .. "\n")
			item.numLabel:setString("x" .. item.num)
			return true
		end
	end
end

function BattleMenuLayer:selectItem(item)
	if self.selectedItem ~= item then
		if self.selectedItem then
			local r = self.selectedItem.view:getChildByTag(10)
			if r then
				r:removeFromParentAndCleanup(true)
			end
		end
		self.selectedItem = item
		local temp = UI.createSpriteWithFile("images/battleItemSelected.png")
		screen.autoSuitable(temp, {nodeAnchor=General.anchorLeftBottom, x=-3, y=-3})
		item.view:addChild(temp, 1, 10)
	end
end

function BattleMenuLayer:update(diff)
	if self.percent ~= BattleLogic.percent then
		self.percent = BattleLogic.percent
		self.percentLabel:setString(self.percent .. "%")
	end
	if self.time then
		self.time = self.time - diff
		self.timeLabel:setString(StringManager.getTimeString(self.time))
		if self.time < 0 then
			if self.battleBegin then
				self:endBattle(true)
			else
				self:beginBattle()
			end
		end
		if self.count and self.count>0 and self.time <= self.count+1 then
			local temp = UI.createSpriteWithFile("images/count" .. self.count .. ".png")
			temp:setScale(0.01)
			screen.autoSuitable(temp, {screenAnchor=General.anchorCenter})
			self.view:addChild(temp, 10)
			temp:runAction(CCScaleTo:create(0.25, 1, 1))
			delayRemove(1, temp)
			self.count = self.count - 1
		end
	end
	if self.starDelay then
		self.starDelay = self.starDelay-diff
		if self.starDelay<=0 then
			self.starDelay = nil
		end
	else
		if self.starsNum < BattleLogic.stars then
			self.starsNum = self.starsNum + 1
			local star = UI.createSpriteWithFile("images/battleStar0.png")
			local oldStar = self.stars[self.starsNum]
			local starBack = oldStar:getParent()
			local p = starBack:convertToNodeSpace(CCPointMake(512, 435))
			screen.autoSuitable(star, {nodeAnchor=General.anchorCenter, x=p.x, y=p.y})
			starBack:addChild(star)
			star:setScale(0)
			
			local array = CCArray:create()
			array:addObject(CCEaseBackOut:create(CCScaleTo:create(0.5, 1, 1)))
			array:addObject(CCDelayTime:create(0.5))
			
			local sarray = CCArray:create()
			local x, y = oldStar:getPosition()
			sarray:addObject(CCMoveTo:create(0.5, CCPointMake(x, y)))
			local sx, sy = oldStar:getScaleX(), oldStar:getScaleY()
			sarray:addObject(CCScaleTo:create(0.5, sx, sy))
			
			array:addObject(CCSpawn:create(sarray))
			array:addObject(CCScaleTo:create(0.1, 1.1*sx, 1.1*sy))
			array:addObject(CCScaleTo:create(0.1, sx, sy))
			
			star:runAction(CCSequence:create(array))
			
			local label = UI.createLabel(StringManager.getString("labelStar" .. self.starsNum), "fonts/font3.fnt", 33)
			screen.autoSuitable(label, {nodeAnchor=General.anchorTop, x=p.x, y=p.y-123})
			starBack:addChild(label)
			array = CCArray:create()
			array:addObject(CCDelayTime:create(1))
			array:addObject(CCFadeOut:create(0.5))
			label:runAction(CCSequence:create(array))
			delayRemove(1.5, label)
		end
		self:updateOthers()
	end
end

function BattleMenuLayer:updateOthers()
	for i=1, 2 do
		local resourceType = resourceTypes[i]
		local item = self[resourceType]
		local fillerUpdate = false
		if BattleLogic.getResource(resourceType) ~= item.value then
			fillerUpdate = true
			item.value = BattleLogic.getResource(resourceType)
			item.valueLabel:setString(tostring(item.value))
		end
		if fillerUpdate then
			local lmax = item.max
			if lmax==0 then lmax=1 end
			local cr = CCRectMake(item.size.width-item.size.width*item.value/lmax, 0, item.size.width*item.value/lmax, item.size.height)
			item.filler:setTextureRect(cr)
		end
		
		if BattleLogic.getLeftResource(resourceType) ~= self.stolenResources[resourceType].resource then
			self.stolenResources[resourceType].resource = BattleLogic.getLeftResource(resourceType)
			self.stolenResources[resourceType].label:setString(tostring(self.stolenResources[resourceType].resource))
		end
	end
	
	if BattleLogic.battleEnd and not self.battleEnd then
		self.battleEnd = true
		self.replayFile:write(json.encode({timer.getTime() - self.beginTime, "e"}) .. "\n")
		self.replayFile:close()
		display.showDialog(BattleResultDialog.new(BattleLogic.getBattleResult()))
	end
end

StageMenuLayer = class(BattleMenuLayer)

function StageMenuLayer:initOthers()
	self.person = {0, 0}
	local temp = UI.createLabel("person :0", General.defaultFont, 30)
	screen.autoSuitable(temp, {screenAnchor=General.anchorRightTop, x=-10, y=-40})
	self.view:addChild(temp)
	self.person[3] = temp
		
	temp = UI.createLabel("person:0", General.defaultFont, 30)
	screen.autoSuitable(temp, {screenAnchor=General.anchorLeftTop, x=10, y=-40})
	self.view:addChild(temp)
	self.person[4] = temp
end

function StageMenuLayer:updateOthers()
	if BattleLogic.getResource("person") ~= self.person[1] then
		self.person[1] = BattleLogic.getResource("person")
		self.person[3]:setString("person:" .. self.person[1])
	end
		
	if BattleLogic.getLeftResource("person") ~= self.person[2] then
		self.person[2] = BattleLogic.getLeftResource("person")
		self.person[4]:setString("person:" .. self.person[2])
	end
	
	if BattleLogic.battleEnd and not self.battleEnd then
		self.battleEnd = true
		display.showDialog(StageResultDialog.new(BattleLogic.getStageResult()))
	end
end