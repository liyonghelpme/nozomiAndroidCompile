ReplayMenuLayer = class()

function ReplayMenuLayer:onPlay()
	if not self.replayOver then
		self.replayView:removeFromParentAndCleanup(true)
		self.replayView = nil
		self.scene.pause = false
		
		self:addReplayMenu()
	else
		self.scene:reloadScene("play")
	end
end

function ReplayMenuLayer:onDownload()
	if not self.replayOver then
		self:addDownloadView()
		self:onPlay()
	else
		self.scene:reloadScene("download")
	end
end

function ReplayMenuLayer:addReplayView(isReplayOver)
	local temp, bg = nil
	bg = CCNode:create()
	self.view:addChild(bg)
	if self.replayView then
		self.replayView:removeFromParentAndCleanup(true)
	end
	self.replayView = bg
	self.replayOver = isReplayOver
	
    if self.camera then
        self.camera:endRecord()
        self.camera:removeFromParentAndCleanup(true)
        self.camera = nil
    end

	temp = CCLayerColor:create(ccc4(0, 0, 0, General.darkAlpha), General.winSize.width, General.winSize.height)
	screen.autoSuitable(temp)
	bg:addChild(temp)
	
	temp = UI.createMenuButton(CCSizeMake(111, 109), "images/buttonChildMenu.png", display.popScene, self, "images/menuItemAchieve.png", StringManager.getString("buttonReturnHome"), 20)
	screen.autoSuitable(temp, {x=72, y=70, screenAnchor=General.anchorLeftBottom, nodeAnchor=General.anchorCenter, scaleType=screen.SCALE_NORMAL})
	bg:addChild(temp)
	
	temp = UI.createMenuButton(CCSizeMake(111, 109), "images/buttonMenu.png", self.onDownload, self, "images/menuItemDownload.png", StringManager.getString("buttonDownload"), 18)
	screen.autoSuitable(temp, {x=-70, y=70, screenAnchor=General.anchorRightBottom, nodeAnchor=General.anchorCenter, scaleType=screen.SCALE_NORMAL})
	bg:addChild(temp)
	
	temp = UI.createLabel(StringManager.getString("labelPlay"), "fonts/font3.fnt", 35, {colorR = 255, colorG = 255, colorB = 255})
	screen.autoSuitable(temp, {x=0, y=-83, nodeAnchor=General.anchorCenter, scaleType=screen.SCALE_NORMAL})
	bg:addChild(temp)
	
	temp = UI.createButton(CCSizeMake(126, 143), self.onPlay, {callbackParam=self, image="images/buttonReplay.png"})
	screen.autoSuitable(temp, {x=15, y=12, screenAnchor=General.anchorCenter, scaleType=screen.SCALE_NORMAL})
	bg:addChild(temp)
end

function ReplayMenuLayer:addReplayMenu()
	local bg, temp
	bg = CCNode:create()
	self.replayView = bg
	
	temp = UI.createMenuButton(CCSizeMake(111, 109), "images/buttonChildMenu.png", display.popScene, self, "images/menuItemAchieve.png", StringManager.getString("buttonReturnHome"), 20)
	screen.autoSuitable(temp, {x=72, y=70, screenAnchor=General.anchorLeftBottom, nodeAnchor=General.anchorCenter, scaleType=screen.SCALE_NORMAL})
	bg:addChild(temp)
	
	temp = UI.createButton(CCSizeMake(169, 76), self.changeTimeScale, {callbackParam=self, image="images/buttonGreen.png", priority=display.MENU_BUTTON_PRI})
	screen.autoSuitable(temp, {x=0, y=97, nodeAnchor=General.anchorCenter, screenAnchor=General.anchorBottom, scaleType=screen.SCALE_NORMAL})
	bg:addChild(temp)
	
	local label = UI.createLabel("x1", "fonts/font3.fnt", 30)
	screen.autoSuitable(label, {nodeAnchor=General.anchorCenter, x=85, y=38})
	temp:addChild(label)
	self.timeScale = {valueLabel=label, value=1}
	CCDirector:sharedDirector():getScheduler():setTimeScale(1)
	
	self:initBattleResultView()
	
	temp = UI.createLabel(StringManager.getString("labelReplay"), "fonts/font3.fnt", 20, {colorR = 255, colorG = 0, colorB = 0})
	screen.autoSuitable(temp, {x=-119, y=-43, nodeAnchor=General.anchorLeft, screenAnchor=General.anchorRightTop, scaleType=screen.SCALE_NORMAL})
	bg:addChild(temp)

	temp = UI.createSpriteWithFile("images/replayIcon.png",CCSizeMake(28, 27))
	screen.autoSuitable(temp, {nodeAnchor=General.anchorLeftBottom, screenAnchor=General.anchorRightTop, x=-162, y=-54, scaleType=screen.SCALE_NORMAL})
	bg:addChild(temp)
	local array = CCArray:create()
	array:addObject(CCFadeOut:create(0.5))
	array:addObject(CCFadeIn:create(0.5))
	temp:runAction(CCRepeatForever:create(CCSequence:create(array)))
	
	simpleRegisterEvent(bg, {update={inteval=0.5, callback=self.update}}, self)
	self.view:addChild(bg)
end

function ReplayMenuLayer:update(diff)
	if self.percent ~= BattleLogic.percent then
		self.percent = BattleLogic.percent
		self.percentLabel:setString(self.percent .. "%")
	end
	if self.starsNum ~= BattleLogic.stars then
		self.starsNum = self.starsNum + 1
		local star = UI.createSpriteWithFile("images/battleStar0.png")
		local oldStar = self.stars[self.starsNum]
		local starBack = oldStar:getParent()
		star:setScale(0)
		screen.autoSuitable(star, {nodeAnchor=General.anchorCenter, x=oldStar:getPositionX(), y=oldStar:getPositionY()})
		starBack:addChild(star)
		star:runAction(CCEaseBackOut:create(CCScaleTo:create(0.5, oldStar:getScaleX(), oldStar:getScaleY())))
	end
end

function ReplayMenuLayer:initBattleResultView()
	local bg = CCNode:create()
	bg:setContentSize(CCSizeMake(256,256))
	screen.autoSuitable(bg, {screenAnchor=General.anchorLeftTop, scaleType=screen.SCALE_NORMAL, x=4, y=-10})
	self.replayView:addChild(bg)
	
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
end

function ReplayMenuLayer:changeTimeScale()
	self.timeScale.value = self.timeScale.value%3+1
	local tvalue = TIME_SCALE[self.timeScale.value]
	self.timeScale.valueLabel:setString("x" .. tvalue)
	CCDirector:sharedDirector():getScheduler():setTimeScale(tvalue)
end

function ReplayMenuLayer:addDownloadView()
    self.camera = VideoCamera:create()
    self.view:addChild(self.camera)
    self.camera:startRecord()
end

function ReplayMenuLayer:ctor(scene, menuParam)
	self.scene = scene
	self.view = CCNode:create()
	self.view:setContentSize(General.winSize)
	if menuParam then
		self.scene.pause = false
		if menuParam == "download" then
			self:addDownloadView()
		end
	else
		self:addReplayView()
	end
end