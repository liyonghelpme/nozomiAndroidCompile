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
    	if self.replayView then
    		self.replayView:removeFromParentAndCleanup(true)
    		self.replayView = nil
    	end
		self:addDownloadView()
	else
		self.scene:reloadScene("download")
	end
end

function ReplayMenuLayer:readyToDownload(force)
    if force then
        if CrystalLogic.changeCrystal(-100) then
            self:onDownload()
        end
    else
        display.showDialog(AlertDialog.new(StringManager.getString("alertTitleDownload"), StringManager.getString("alertTextDownload"), {callback=self.readyToDownload, param=true, crystal=100}, self))
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

	temp = CCLayerColor:create(ccc4(0, 0, 0, General.darkAlpha), General.winSize.width, General.winSize.height)
	screen.autoSuitable(temp)
	bg:addChild(temp)
	
	temp = UI.createMenuButton(CCSizeMake(111, 109), "images/buttonChildMenu.png", display.popScene, self, "images/menuItemAchieve.png", StringManager.getString("buttonReturnHome"), 18)
	screen.autoSuitable(temp, {x=72, y=70, screenAnchor=General.anchorLeftBottom, nodeAnchor=General.anchorCenter, scaleType=screen.SCALE_NORMAL})
	bg:addChild(temp)
	
	temp = UI.createMenuButton(CCSizeMake(111, 109), "images/buttonMenu.png", self.readyToDownload, self, "images/menuItemDownload.png", StringManager.getString("buttonDownload"), 18)
	screen.autoSuitable(temp, {x=-70, y=70, screenAnchor=General.anchorRightBottom, nodeAnchor=General.anchorCenter, scaleType=screen.SCALE_NORMAL})
	bg:addChild(temp)
	
	temp = UI.createLabel(StringManager.getString("labelPlay"), "fonts/font3.fnt", 35, {colorR = 255, colorG = 255, colorB = 255})
	screen.autoSuitable(temp, {x=0, y=-83, screenAnchor=General.anchorCenter, scaleType=screen.SCALE_NORMAL})
	bg:addChild(temp)
	
	temp = UI.createButton(CCSizeMake(126, 143), self.onPlay, {callbackParam=self, image="images/buttonReplay.png"})
	screen.autoSuitable(temp, {x=0, y=12, screenAnchor=General.anchorCenter, scaleType=screen.SCALE_NORMAL})
	bg:addChild(temp)
end

function ReplayMenuLayer:addReplayMenu()
	local bg, temp
	bg = CCNode:create()
	self.replayView = bg
	
	temp = UI.createMenuButton(CCSizeMake(111, 109), "images/buttonChildMenu.png", display.popScene, self, "images/menuItemAchieve.png", StringManager.getString("buttonReturnHome"), 18)
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
	
	temp = UI.createLabel("0%", "fonts/font3.fnt", 30, {colorR = 255, colorG = 255, colorB = 255, lineOffset=-12})
	screen.autoSuitable(temp, {x=106, y=181, nodeAnchor=General.anchorCenter})
	bg:addChild(temp)
	self.percent = 0
	self.percentLabel = temp
	
	temp = UI.createLabel(StringManager.getString("damagePercent"), "fonts/font3.fnt", 16, {colorR = 255, colorG = 255, colorB = 255, lineOffset=-12})
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
    local scene = self.scene
    scene.view:addChild(self.camera)
    
    local temp, bg = nil
    bg = UI.createButton(General.winSize, doNothing, {image="images/downloadBack.png", priority=display.MENU_PRI, nodeChangeHandler = doNothing})
	screen.autoSuitable(bg)
	
    temp = UI.createSpriteWithFile("images/videoProcessBack.png",CCSizeMake(466, 40))
    screen.autoSuitable(temp, {x=0, y=-26, screenAnchor=General.anchorCenter, scaleType=screen.SCALE_NORMAL})
    bg:addChild(temp)
    local temp1 = UI.createSpriteWithFile("images/videoProcessFiller.png",CCSizeMake(454, 28))
    screen.autoSuitable(temp1, {x=6, y=6})
    temp:addChild(temp1)
    self.replayProcess = {node=temp1, size=temp1:getContentSize(), percent=0, width=0}
    temp1:setTextureRect(CCRectMake(0,0,0,self.replayProcess.size.height))
    temp1 = UI.createLabel(StringManager.getString("labelDownloading"), "fonts/font3.fnt", 25, {colorR = 255, colorG = 255, colorB = 255})
    screen.autoSuitable(temp1, {x=233, y=66, nodeAnchor=General.anchorCenter})
    temp:addChild(temp1)
    
    temp = CCNode:create()
    temp:setContentSize(CCSizeMake(256, 256))
    screen.autoSuitable(temp, {screenAnchor=General.anchorLeftTop, scaleType=screen.SCALE_NORMAL})
    bg:addChild(temp)
    
    temp1 = UI.createLabel(StringManager.getString("labelDownloadTips"), "fonts/font1.fnt", 18, {colorR = 255, colorG = 255, colorB = 255})
    screen.autoSuitable(temp1, {x=272, y=136, nodeAnchor=General.anchorLeft})
    temp:addChild(temp1)
    temp1 = UI.createLabel(StringManager.getString("labelFreeCrystals"), "fonts/font3.fnt", 30, {colorR = 255, colorG = 255, colorB = 255})
    screen.autoSuitable(temp1, {x=273, y=202, nodeAnchor=General.anchorLeft})
    temp:addChild(temp1)
    temp1 = UI.createSpriteWithFile("images/storeItemCrystal5.png",CCSizeMake(208, 143))
    screen.autoSuitable(temp1, {x=31, y=80})
    temp:addChild(temp1)
    
	temp = UI.createMenuButton(CCSizeMake(111, 109), "images/buttonChildMenu.png", self.cancelRecord, self, "images/menuItemAchieve.png", StringManager.getString("buttonCancel"), 18, {247,47,47})
	screen.autoSuitable(temp, {x=72, y=70, screenAnchor=General.anchorLeftBottom, nodeAnchor=General.anchorCenter, scaleType=screen.SCALE_NORMAL})
	bg:addChild(temp)
    self.showScene = bg
    
    self.downloadTime = 0
    self.totalTime = 5 + self.scene.battleTime
	simpleRegisterEvent(bg, {update={inteval=0.5, callback=self.updateDownload}}, self)
    scene.scene:addChild(bg, 1)
    self.camera:startRecord(bg)
    
    scene:scaleTo(scene.scMin, scene.SIZEX/2, 1644)
    
    --add first frame
    local frame = CCLayerColor:create(ccc4(0,0,0,255),General.winSize.width,General.winSize.height)
    local logo = UI.createSpriteWithFile("images/logo.png")
    screen.autoSuitable(logo, {screenAnchor=General.anchorCenter, scaleType=screen.SCALE_NORMAL})
    frame:addChild(logo)
    logo:setScale(0)
    local t1 = 0.2
    local t2 = 1.3
    logo:runAction(CCScaleTo:create(t1, 1, 1))
    screen.autoSuitable(frame)
    scene.view:addChild(frame)
    self.frame = frame
    CCTextureCache:sharedTextureCache():removeTextureForKey("images/logo.png")
    
    delayCallback(t1+t2, self.beginLoadingFrame, self)
end

function ReplayMenuLayer:updateDownload(diff)
    self.downloadTime = self.downloadTime + diff
    local p = squeeze(self.downloadTime/self.totalTime, 0, 1)
    local w = math.floor(p*self.replayProcess.size.width)
    if w~=self.replayProcess.width then
        self.replayProcess.width = w
        self.replayProcess.node:setTextureRect(CCRectMake(0, 0, w, self.replayProcess.size.height))
    end
end

function ReplayMenuLayer:beginReplay()
    self.frame:removeFromParentAndCleanup(true)
    self.frame = nil
    self.scene.pause = false
end

function ReplayMenuLayer:beginLoadingFrame()
    local bg = CCNode:create()
	local temp = nil
    temp = UI.createSpriteWithFile("images/loadingBack.png")
    screen.autoSuitable(temp, {screenAnchor=General.anchorCenter, scaleType=screen.SCALE_NORMAL})
    bg:addChild(temp)
    
    CCTextureCache:sharedTextureCache():removeTextureForKey("images/loadingBack.png")
    
    temp = UI.createSpriteWithFile("images/loadingTitle.png")
    screen.autoSuitable(temp, {screenAnchor=General.anchorTop, scaleType=screen.SCALE_NORMAL, x=-17})
    bg:addChild(temp)
    
    CCTextureCache:sharedTextureCache():removeTextureForKey("images/loadingTitle.png")
    
    temp = UI.createSpriteWithFile("images/tipsBg.png",CCSizeMake(518, 67))
    screen.autoSuitable(temp, {screenAnchor=General.anchorBottom, scaleType=screen.SCALE_NORMAL, x=0, y=12})
    bg:addChild(temp)
    local temp1 = UI.createLabel(StringManager.getString("dataTips1"), "fonts/font3.fnt", 14, {colorR = 255, colorG = 255, colorB = 255, size=CCSizeMake(506, 50)})
    screen.autoSuitable(temp1, {x=259, y=34, nodeAnchor=General.anchorCenter})
    temp:addChild(temp1)
    CCTextureCache:sharedTextureCache():removeTextureForKey("images/tipsBg.png")
    
    temp = UI.createSpriteWithFile("images/loadingProcessBack.png",CCSizeMake(283, 25))
    screen.autoSuitable(temp, {screenAnchor=General.anchorBottom, scaleType=screen.SCALE_NORMAL, x=0, y=66})
    bg:addChild(temp)
    local filler = UI.createSpriteWithFile("images/loadingProcessFiller.png",CCSizeMake(279, 20))
    screen.autoSuitable(filler, {x=2, y=3})
    temp:addChild(filler)
    local fillerSize = filler:getContentSize()
    
    CCTextureCache:sharedTextureCache():removeTextureForKey("images/loadingProcessBack.png")
    CCTextureCache:sharedTextureCache():removeTextureForKey("images/loadingProcessFiller.png")
    
    local infoLabel = UI.createLabel(StringManager.getString("labelLoading"), "fonts/font3.fnt", 16, {colorR = 255, colorG = 255, colorB = 255})
    screen.autoSuitable(infoLabel, {x=132, y=29, nodeAnchor=General.anchorTop})
    temp:addChild(infoLabel)
    
    local function setPercent(percent)
    	filler:setTextureRect(CCRectMake(0, 0, fillerSize.width*squeeze(percent/100,0,1), fillerSize.height))
    end
    setPercent(0)
    local cp = 0
    local loadData = nil
    local function update(diff)
    	cp = cp+diff
    	setPercent(math.floor(100*cp/1.5))
    	if cp>=1.5 then
    	    self:beginReplay()
    	    cp=1.5
    	end
    end
    temp = UI.createSpriteWithFile("images/downloadNoticeIcon.png",CCSizeMake(234, 171))
    screen.autoSuitable(temp, {screenAnchor=General.anchorLeftTop, x=23, y=-13})
    bg:addChild(temp)
    simpleRegisterEvent(bg, {update={callback = update, inteval=0}})
    
    self.frame:addChild(bg)
end

function ReplayMenuLayer:cancelRecord()
    local dialog = AlertDialog.new(StringManager.getString("alertTitleCancelRecord"), StringManager.getString("alertTextCancelRecord"), {callback=self.endRecord, param=self})
    dialog.scene = self.showScene
    display.showDialog(dialog)
end

function ReplayMenuLayer:endReplay()
    if self.camera then
        --add last frame
        local frame = CCNode:create()
        local temp = UI.createSpriteWithFile("images/downloadLastframeBg.png",CCSizeMake(1024, 768))
        screen.autoSuitable(temp, {screenAnchor=General.anchorCenter, scaleType=screen.SCALE_NORMAL})
        frame:addChild(temp)
        CCTextureCache:sharedTextureCache():removeTextureForKey("images/downloadLastframeBg.png")
        temp = UI.createSpriteWithFile("images/downloadNoticeIcon.png",CCSizeMake(317, 233))
        screen.autoSuitable(temp, {screenAnchor=General.anchorRightBottom, x=-67, y=9, scaleType=screen.SCALE_NORMAL})
        frame:addChild(temp)
        CCTextureCache:sharedTextureCache():removeTextureForKey("images/downloadNoticeIcon.png")
        temp = UI.createSpriteWithFile("images/downloadLastframeZombie.png",CCSizeMake(507, 536))
        screen.autoSuitable(temp, {screenAnchor=General.anchorLeft, x=0, y=7, scaleType=screen.SCALE_NORMAL})
        frame:addChild(temp)
        CCTextureCache:sharedTextureCache():removeTextureForKey("images/downloadLastframeZombie.png")
        
        self.scene.view:addChild(frame)
        self.lastFrame = frame
        delayCallback(2, self.endRecord, self)
    else
        self:addReplayView(true)
    end
end

function ReplayMenuLayer:endRecord()
    self.camera:endRecord()
    --self.camera:removeFromParentAndCleanup(true)
    --self.camera = nil
    --if display.isDialogShow() then
    --    display.closeDialog()
    --end
    --self.showScene:removeFromParentAndCleanup(true)
    --self.showScene = nil
    --if self.lastFrame then
    --    self.lastFrame:removeFromParentAndCleanup(true)
    --    self.lastFrame = nil
    --end
    display.popScene(true)
    display.pushNotice(UI.createNotice(StringManager.getString("noticeDownloadOver"), 255))
end

function ReplayMenuLayer:ctor(scene, menuParam)
	self.scene = scene
	self.view = CCNode:create()
	self.view:setContentSize(General.winSize)
	if menuParam then
		if menuParam == "download" then
			self:addDownloadView()
        else
		    self.scene.pause = false
            self:addReplayMenu()
		end
	else
		self:addReplayView()
	end
end