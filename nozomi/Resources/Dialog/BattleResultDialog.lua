BattleResultDialog = class()

function BattleResultDialog:enterReplayScene()
	local resourceTypes = {"oil", "food"}
	for i=1, 2 do
		local resourceType = resourceTypes[i]
		BattleLogic.resources[resourceType] = {left=0, stolen=0, base=ResourceLogic.getResource(resourceType), max=ResourceLogic.getResourceMax(resourceType)}
	end
	BattleLogic.init()
	UI.testChangeScene(true)
	delayCallback(1, display.runScene, ReplayScene)
end

function BattleResultDialog:ctor(result)
	self.view = CCNode:create()
	self.view:setContentSize(General.winSize)
	screen.autoSuitable(self.view, {screenAnchor=General.anchorCenter})
	local temp
	local array
	
	temp = UI.createSpriteWithFile("images/dialogItemBattleResultBg.png",CCSizeMake(1104, 498))
	screen.autoSuitable(temp, {screenAnchor=General.anchorLeftBottom, x=-13, y=-2, scaleType=screen.SCALE_WIDTH_FIRST})
	self.view:addChild(temp)
	temp = UI.createButton(CCSizeMake(62, 42), self.enterReplayScene, {callbackParam=self, image="images/battleEndVideo.png"})
	screen.autoSuitable(temp, {screenAnchor=General.anchorRightBottom, nodeAnchor=General.anchorCenter, x=-80, y=58, scaleType=screen.SCALE_NORMAL})
	self.view:addChild(temp)
	temp = UI.createLabel(StringManager.getString("labelBattleEndVideo"), "fonts/font1.fnt", 13, {colorR = 255, colorG = 255, colorB = 255})
	screen.autoSuitable(temp, {screenAnchor=General.anchorRightBottom, x=-10, y=21, nodeAnchor=General.anchorRight, scaleType=screen.SCALE_NORMAL})
	self.view:addChild(temp)

	local bg = nil
	bg = CCNode:create()
	bg:setContentSize(CCSizeMake(1024, 768))
	screen.autoSuitable(bg, {screenAnchor=General.anchorCenter, scaleType=screen.SCALE_CUT_EDGE})
	self.view:addChild(bg)
	
	bg:setScale(0.75)
	bg:runAction(CCEaseBackOut:create(CCScaleTo:create(0.1, 1, 1)))
	
	local numberToTime = getParam("actionTimeNumberTo", 1000)/1000
	
	temp = UI.createButton(CCSizeMake(169, 65), self.endBattle, {callbackParam=self, image="images/buttonGreen.png", text=StringManager.getString("buttonReturnHome"), fontSize=22, fontName="fonts/font3.fnt", lineOffset=-12})
	screen.autoSuitable(temp, {x=512, y=133, nodeAnchor=General.anchorCenter})
	bg:addChild(temp)
	temp = UI.createLabel(StringManager.getString("labelGot"), "fonts/font2.fnt", 13, {colorR = 255, colorG = 255, colorB = 255})
	screen.autoSuitable(temp, {x=512, y=439, nodeAnchor=General.anchorCenter})
	bg:addChild(temp)
	temp = UI.createLabel(StringManager.getString("labelLost"), "fonts/font2.fnt", 13, {colorR = 255, colorG = 255, colorB = 255})
	screen.autoSuitable(temp, {x=512, y=260, nodeAnchor=General.anchorCenter})
	bg:addChild(temp)
	
	local keys = {"food", "oil", "score"}
	for i=1, 3 do
		local key = keys[i]
		
		temp = UI.createLabel("0", "fonts/font3.fnt", 30, {colorR = 255, colorG = 255, colorB = 255})
		screen.autoSuitable(temp, {x=524, y=458-53*i, nodeAnchor=General.anchorRight})
		bg:addChild(temp)
		temp:runAction(CCNumberTo:create(numberToTime, 0, result[key], "", ""))
		temp = UI.createScaleSprite("images/" .. key .. ".png",CCSizeMake(60, 36))
		screen.autoSuitable(temp, {nodeAnchor=General.anchorBottom, x=554, y=443-53*i})
		bg:addChild(temp)
		temp = UI.createSpriteWithFile("images/dialogItemBattleResultSeperator.png",CCSizeMake(665, 2))
		screen.autoSuitable(temp, {nodeAnchor=General.anchorBottom, x=512, y=433-53*i})
		bg:addChild(temp)
		if i<4 then
			ResourceLogic.changeResource(key, result[key])
		else
			UserData.userScore = UserData.userScore + result[key]
			EventManager.sendMessage("EVENT_OTHER_OPERATION", {type="Set", key="score", value=UserData.userScore})
		end
	end
	
	local items = {{id=1,num=10}}
	for i=1, 12 do
		local cell = CCNode:create()
		cell:setContentSize(CCSizeMake(48, 63))
		screen.autoSuitable(cell, {x=142+52*i, y=179})
		bg:addChild(cell)
		if items[i] then
			temp = UI.createSpriteWithFile("images/dialogItemBattleResultItemA.png",CCSizeMake(48, 63))
			screen.autoSuitable(temp, {x=0, y=0})
			cell:addChild(temp)
			SoldierHelper.addSoldierHead(cell, items[i].id, 0.42)
			for j=1, UserData.researchLevel[items[i].id] do
				temp = UI.createSpriteWithFile("images/soldierStar.png",CCSizeMake(10, 11))
				screen.autoSuitable(temp, {x=9*j-7, y=3})
				cell:addChild(temp)
			end
			temp = UI.createLabel("x" .. items[i].num, "fonts/font3.fnt", 15, {colorR = 255, colorG = 121, colorB = 123})
			screen.autoSuitable(temp, {x=6, y=55, nodeAnchor=General.anchorLeft})
			cell:addChild(temp)
		else
			temp = UI.createSpriteWithFile("images/dialogItemBattleResultItemB.png",CCSizeMake(48, 63))
			screen.autoSuitable(temp, {x=0, y=0})
			cell:addChild(temp)
		end
	end

	temp = UI.createSpriteWithFile("images/battleEndLight.png")
	temp:setScale(7.5)
	temp:setOpacity(128)
	screen.autoSuitable(temp, {nodeAnchor=General.anchorCenter, x=512, y=545})
	bg:addChild(temp)
	temp:runAction(CCRepeatForever:create(CCRotateBy:create(1, 20)))
	temp = UI.createSpriteWithFile("images/battleEndRibbon.png",CCSizeMake(605, 197))
	screen.autoSuitable(temp, {x=207, y=410})
	bg:addChild(temp)
	if result.stars>0 then
		temp = UI.createLabel(StringManager.getString("labelVictory"), "fonts/font3.fnt", 35, {colorR = 97, colorG = 255, colorB = 49})
		screen.autoSuitable(temp, {x=512, y=516, nodeAnchor=General.anchorCenter})
		bg:addChild(temp)
	else
		temp = UI.createLabel(StringManager.getString("labelDefeat"), "fonts/font3.fnt", 35, {colorR = 255, colorG = 97, colorB = 49})
		screen.autoSuitable(temp, {x=512, y=516, nodeAnchor=General.anchorCenter})
		bg:addChild(temp)
	end
	temp = UI.createSpriteWithFile("images/battleStar1.png",CCSizeMake(139, 131))
	screen.autoSuitable(temp, {x=317, y=515})
	bg:addChild(temp)
	temp = UI.createSpriteWithFile("images/battleStar1.png",CCSizeMake(193, 183))
	screen.autoSuitable(temp, {x=413, y=534})
	bg:addChild(temp)
	temp = UI.createSpriteWithFile("images/battleStar1.png",CCSizeMake(139, 131))
	screen.autoSuitable(temp, {x=566, y=517})
	bg:addChild(temp)
	if result.stars>=1 then
		temp = UI.createSpriteWithFile("images/battleStar0.png",CCSizeMake(142, 133))
		screen.autoSuitable(temp, {nodeAnchor=General.anchorCenter, x=388, y=581})
		bg:addChild(temp)
		local sx, sy = temp:getScaleX(), temp:getScaleY()
		temp:setScale(0)
		array=CCArray:create()
		array:addObject(CCDelayTime:create(0.1))
		array:addObject(CCEaseBackOut:create(CCScaleTo:create(0.3, sx, sy)))
		temp:runAction(CCSequence:create(array))
		if result.stars>=2 then
			temp = UI.createSpriteWithFile("images/battleStar0.png",CCSizeMake(196, 185))
			screen.autoSuitable(temp, {nodeAnchor=General.anchorCenter, x=512, y=625})
			bg:addChild(temp,1)
			temp:setScale(0)
			array=CCArray:create()
			array:addObject(CCDelayTime:create(0.4))
			array:addObject(CCEaseBackOut:create(CCScaleTo:create(0.3, 1, 1)))
			temp:runAction(CCSequence:create(array))
			if result.stars==3 then
				temp = UI.createSpriteWithFile("images/battleStar0.png",CCSizeMake(142, 133))
				screen.autoSuitable(temp, {nodeAnchor=General.anchorCenter, x=637, y=581})
				bg:addChild(temp)
				temp:setScale(0)
				array=CCArray:create()
				array:addObject(CCDelayTime:create(0.7))
				array:addObject(CCEaseBackOut:create(CCScaleTo:create(0.3, sx, sy)))
				temp:runAction(CCSequence:create(array))
			end
		end
	end
	temp = UI.createLabel(StringManager.getString("damagePercent"), "fonts/font2.fnt", 13, {colorR = 255, colorG = 255, colorB = 255})
	screen.autoSuitable(temp, {x=512, y=630, nodeAnchor=General.anchorCenter})
	bg:addChild(temp, 2)
	temp = UI.createLabel("0%", "fonts/font3.fnt", 25, {colorR = 255, colorG = 255, colorB = 255})
	screen.autoSuitable(temp, {x=512, y=600, nodeAnchor=General.anchorCenter})
	bg:addChild(temp, 2)
	temp:runAction(CCNumberTo:create(numberToTime, 0, result.percent, "", "%"))

	EventManager.sendMessage("EVENT_BATTLE_END", result)
end

function BattleResultDialog:endBattle()
	Action.test(true)
	delayCallback(1, display.popScene)
end

StageResultDialog = class()

function StageResultDialog:ctor(result)
	self.view = CCNode:create()
	self.view:setContentSize(CCSizeMake(800, 400))
	screen.autoSuitable(self.view, {screenAnchor=General.anchorCenter, scaleType=screen.SCALE_CUT_EDGE})
	local temp
	local keys = {"person", "food", "special", "score"}
	for i=1, 1 do
		local key = keys[i]
		temp = UI.createLabel(key .. ":" .. result[key], General.specialFont, 30)
		screen.autoSuitable(temp, {nodeAnchor=General.anchorCenter, x=400, y=320-40*i})
		self.view:addChild(temp)
		if i<4 then
			ResourceLogic.changeResource(key, result[key])
		else
			UserData.userScore = UserData.userScore + result[key]
		end
	end
	temp = UI.createButton(CCSizeMake(120, 40), self.endBattle, {callbackParam=self, image="images/buttonTest.png", text="back", fontName=General.defaultFont, fontSize=35})
	screen.autoSuitable(temp, {nodeAnchor=General.anchorCenter, x=400, y=40})
	self.view:addChild(temp)
end

function StageResultDialog:endBattle()
	display.popScene()
end