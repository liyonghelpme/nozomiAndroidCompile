require "Dialog.AboutDialog"
require "Dialog.SettingDialog"
require "Dialog.StoreDialog"
require "Dialog.InfoDialog"
require "Dialog.UpgradeDialog"
require "Dialog.TrainDialog"
require "Dialog.ResearchDialog"
require "Dialog.ClanDialog"
require "Dialog.HistoryDialog"
require "Dialog.AchievementDialog"
require "Dialog.ZombieDialog"
require "Dialog.RankDialog"
require "Dialog.ZombieResultDialog"

MenuLayer = class()

local function createChildMenuButton(buttonImage, buttonText, callback, callbackParam, setting)
	local params = setting or {}
	local buttonBg = params.background or "images/buttonChildMenu.png"
	local but = UI.createButton(CCSizeMake(93, 91), callback, {callbackParam=callbackParam, image=buttonBg, priority=display.MENU_BUTTON_PRI})
	local temp
	
	if buttonImage then
		temp = UI.createSpriteWithFile(buttonImage)
		if params.imgScale then
			temp:setScale(params.imgScale)
		end
		screen.autoSuitable(temp, {nodeAnchor=General.anchorCenter, x=47+getParam("xoff" .. buttonText, 0), y=46+getParam("yoff" .. buttonText, 0)})
		but:addChild(temp)
	end
	
	temp = UI.createLabel(buttonText, "fonts/font3.fnt", 14, {size=CCSizeMake(85, 40), lineOffset=-12})
	screen.autoSuitable(temp, {nodeAnchor=General.anchorCenter, x=47, y=16})
	but:addChild(temp)
	
	if params.cost then
		local cost = params.cost
		if cost.costMid then
			temp = UI.createLabel(tostring(cost.costValue), "fonts/font3.fnt", 20, {colorR = 255, colorG = 255, colorB = 255})
			screen.autoSuitable(temp, {x=47, y=72, nodeAnchor=General.anchorCenter})
			but:addChild(temp)
		else
			temp = UI.createResourceNode(cost.costType, cost.costValue, 21)
			screen.autoSuitable(temp, {nodeAnchor=General.anchorRightTop, x=89, y=87})
			but:addChild(temp)
		end
	end
	return but
end

function MenuLayer:ctor(scene)
    local layer = CCLayer:create()
		
	self.view=layer
	self.scene = scene
	
	self:initRightTop()
	self:initTop()
	self:initLeftTop()
	self:initRightBottom()
	
	simpleRegisterEvent(layer, {enterOrExit = {callback = self.enterOrExit}, update={inteval=0.2, callback=self.update}}, self)
end

function MenuLayer:enterBattleScene(forceEnter)
    if SoldierLogic.getCurSpace()==0 then
        display.pushNotice(UI.createNotice(StringManager.getString("noticeErrorNoSoldier")))
        return
    end
	if forceEnter then
		UserData.shieldTime = 0
	end
	if UserData.shieldTime<=timer.getTime() then
		self.scene:updateLogic(300)
		local resourceTypes = {"oil", "food"}
		for i=1, 2 do
			local resourceType = resourceTypes[i]
			BattleLogic.resources[resourceType] = {left=0, stolen=0, base=ResourceLogic.getResource(resourceType), max=ResourceLogic.getResourceMax(resourceType)}
		end
		-- local scene = PreBattleScene.new()
		-- TODO
		UI.testChangeScene(true)
		delayCallback(getParam("actionTimeChangeScene", 600)/1000, display.pushScene, PreBattleScene)
		--display.pushScene(scene)
	else
		display.showDialog(AlertDialog.new(StringManager.getString("alertTitleShield"), StringManager.getString("alertTextShield"), {callback=self.enterBattleScene, param=true}, self))
	end
end

function MenuLayer:initRightBottom()
	local bg = CCNode:create()
	bg:setContentSize(CCSizeMake(256, 256))
	screen.autoSuitable(bg, {scaleType=screen.SCALE_NORMAL, screenAnchor=General.anchorRightBottom})
	self.view:addChild(bg)
	
	self.buts = {}
	self.butNotices = {}
	local temp = UI.createButton(CCSizeMake(115, 111), self.enterBattleScene, {callbackParam=self, image="images/buttonMenu.png", priority=display.MENU_BUTTON_PRI})
	screen.autoSuitable(temp, {nodeAnchor=General.anchorCenter, x=192, y=64})
	bg:addChild(temp)
	self.buts["attack"] = temp
	if not GuideLogic.complete and GuideLogic.step<9 then
		temp:setVisible(false)
	end
	local img = UI.createScaleSprite("images/menuItemAttack.png", CCSizeMake(111, 108))
	screen.autoSuitable(img, {nodeAnchor=General.anchorCenter, x=58, y=56})
	temp:addChild(img)
	local label = UI.createLabel(StringManager.getString("buttonAttack"), "fonts/font3.fnt", 20, {colorR = 255, colorG = 255, colorB = 255})
	screen.autoSuitable(label, {x=58, y=22, nodeAnchor=General.anchorCenter})
	temp:addChild(label)
	
	temp = UI.createButton(CCSizeMake(73, 72), StoreDialog.show, {image="images/buttonMenu.png", priority=display.MENU_BUTTON_PRI})
	screen.autoSuitable(temp, {nodeAnchor=General.anchorCenter, x=88, y=49})
	bg:addChild(temp)
	self.buts["shop"] = temp
	if not GuideLogic.complete and GuideLogic.step<1 then
		temp:setVisible(false)
	end
	img = UI.createScaleSprite("images/menuItemStore.png", CCSizeMake(73, 72))
	screen.autoSuitable(img, {nodeAnchor=General.anchorCenter, x=37, y=36})
	temp:addChild(img)
	
	temp = UI.createButton(CCSizeMake(73, 72), AchievementDialog.show, {image="images/buttonMenu.png", priority=display.MENU_BUTTON_PRI})
	screen.autoSuitable(temp, {nodeAnchor=General.anchorCenter, x=5, y=49})
	bg:addChild(temp)
	self.buts["achieve"] = temp
	if not GuideLogic.complete then
		temp:setVisible(false)
	end
	img = UI.createScaleSprite("images/menuItemAchieve.png", CCSizeMake(59, 59))
	screen.autoSuitable(img, {nodeAnchor=General.anchorCenter, x=37, y=36})
	temp:addChild(img)
    temp = UI.createSpriteWithFile("images/numIcon.png",CCSizeMake(29, 29))
    screen.autoSuitable(temp, {nodeAnchor=General.anchorCenter, x=6, y=66})
    self.buts["achieve"]:addChild(temp, 0, ACTION_TAG)
    self.butNotices["achieve"] = temp
    temp:setVisible(false)
	
	temp = UI.createButton(CCSizeMake(73, 72), HistoryDialog.show, {image="images/buttonMenu.png", priority=display.MENU_BUTTON_PRI})
	screen.autoSuitable(temp, {nodeAnchor=General.anchorCenter, x=206, y=164})
	bg:addChild(temp)
	self.buts["mail"] = temp
	if not GuideLogic.complete then
		temp:setVisible(false)
	end
	img = UI.createScaleSprite("images/menuItemMail.png", CCSizeMake(73, 72))
	screen.autoSuitable(img, {nodeAnchor=General.anchorCenter, x=37, y=36})
	temp:addChild(img)
    temp = UI.createSpriteWithFile("images/numIcon.png",CCSizeMake(29, 29))
    screen.autoSuitable(temp, {nodeAnchor=General.anchorCenter, x=6, y=66})
    self.buts["mail"]:addChild(temp, 0, ACTION_TAG)
    self.butNotices["mail"] = temp
    temp:setVisible(false)
	
	temp = UI.createButton(CCSizeMake(73, 72), display.showDialog, {callbackParam=SettingDialog, image="images/buttonMenu.png", priority=display.MENU_BUTTON_PRI})
	screen.autoSuitable(temp, {nodeAnchor=General.anchorCenter, x=206, y=245})
	bg:addChild(temp)
	self.buts["setting"] = temp
	if not GuideLogic.complete and GuideLogic.step<7 then
		temp:setVisible(false)
	end
	img = UI.createScaleSprite("images/menuItemSetting.png", CCSizeMake(73, 72))
	screen.autoSuitable(img, {nodeAnchor=General.anchorCenter, x=37, y=36})
	temp:addChild(img)
end

function MenuLayer:initRightTop()
	local temp, bg = nil
	bg = CCNode:create()
	bg:setContentSize(CCSizeMake(256, 256))
	screen.autoSuitable(bg, {scaleType=screen.SCALE_NORMAL, screenAnchor=General.anchorRightTop})
	self.view:addChild(bg)
	
	temp = UI.createSpriteWithFile("images/operationBottom.png",CCSizeMake(156, 30))
	screen.autoSuitable(temp, {x=81, y=28})
	bg:addChild(temp)
	temp = UI.createButton(CCSizeMake(33, 37), StoreDialog.show, {priority=display.MENU_BUTTON_PRI, callbackParam="treasure", image="images/buttonAdd.png"})
	screen.autoSuitable(temp, {x=96, y=42, nodeAnchor=General.anchorCenter})
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

function MenuLayer:initTop()
	local temp, bg = nil
	bg = CCNode:create()
	bg:setContentSize(CCSizeMake(384, 128))
	screen.autoSuitable(bg, {scaleType=screen.SCALE_NORMAL, screenAnchor=General.anchorTop})
	self.view:addChild(bg)
	
	temp = UI.createSpriteWithFile("images/operationBottom.png",CCSizeMake(156, 30))
	screen.autoSuitable(temp, {x=202, y=75})
	bg:addChild(temp)
	temp = UI.createLabel(StringManager.getTimeString(0), "fonts/font3.fnt", 20, {colorR = 255, colorG = 255, colorB = 255})
	screen.autoSuitable(temp, {x=301, y=88, nodeAnchor=General.anchorCenter})
	bg:addChild(temp)
	self.shieldLabel = temp
	temp = UI.createButton(CCSizeMake(33, 37), StoreDialog.show, {priority=display.MENU_BUTTON_PRI, image="images/buttonAdd.png", callbackParam="shield"})
	screen.autoSuitable(temp, {nodeAnchor=General.anchorCenter, x=366, y=90})
	bg:addChild(temp)
	temp = UI.createSpriteWithFile("images/shield.png",CCSizeMake(51, 59))
	screen.autoSuitable(temp, {x=202, y=61})
	bg:addChild(temp)
	temp = UI.createLabel(StringManager.getString("labelShieldTime"), "fonts/font2.fnt", 13, {colorR = 255, colorG = 255, colorB = 255})
	screen.autoSuitable(temp, {x=297, y=116, nodeAnchor=General.anchorCenter})
	bg:addChild(temp)
	temp = UI.createSpriteWithFile("images/operationBottom.png",CCSizeMake(156, 30))
	screen.autoSuitable(temp, {x=-3, y=75})
	bg:addChild(temp)
	temp = UI.createLabel(StringManager.getTimeString(0), "fonts/font3.fnt", 20, {colorR = 255, colorG = 255, colorB = 255})
	screen.autoSuitable(temp, {x=95, y=88, nodeAnchor=General.anchorCenter})
	bg:addChild(temp)
	self.zombieShieldLabel = temp
	temp = UI.createButton(CCSizeMake(33, 37), self.dalayZombieAttack, {priority=display.MENU_BUTTON_PRI, callbackParam=self, image="images/buttonAdd.png"})
	screen.autoSuitable(temp, {nodeAnchor=General.anchorCenter, x=160, y=90})
	bg:addChild(temp)
	temp = UI.createSpriteWithFile("images/zombie.png",CCSizeMake(46, 58))
	screen.autoSuitable(temp, {x=1, y=62})
	bg:addChild(temp)
	temp = UI.createLabel(StringManager.getString("labelZombieShield"), "fonts/font2.fnt", 13, {colorR = 255, colorG = 255, colorB = 255})
	screen.autoSuitable(temp, {x=94, y=115, nodeAnchor=General.anchorCenter})
	bg:addChild(temp)
end

function MenuLayer:initLeftTop()
	local temp, bg = nil
	bg = CCNode:create()
	bg:setContentSize(CCSizeMake(256, 256))
	screen.autoSuitable(bg, {scaleType=screen.SCALE_NORMAL, screenAnchor=General.anchorLeftTop})
	self.view:addChild(bg)
	
	local item = {value=UserData.exp or 0, max=UserData.nextExp or 30}

	temp = UI.createSpriteWithFile("images/expFiller.png",CCSizeMake(219, 28))
	screen.autoSuitable(temp, {x=13, y=205})
	bg:addChild(temp)
	item.filler = temp
	item.size = temp:getContentSize()
	temp = UI.createSpriteWithFile("images/fillerBottom.png",CCSizeMake(225, 34))
	screen.autoSuitable(temp, {x=10, y=202})
	bg:addChild(temp)
	temp = UI.createSpriteWithFile("images/exp.png",CCSizeMake(53, 51))
	screen.autoSuitable(temp, {x=14, y=194})
	bg:addChild(temp)
	temp = UI.createLabel(tostring(item.value), "fonts/font3.fnt", 20, {colorR = 255, colorG = 255, colorB = 255})
	screen.autoSuitable(temp, {x=76, y=218, nodeAnchor=General.anchorLeft})
	bg:addChild(temp)
	item.valueLabel = temp
	self.exp = item
	local cr = CCRectMake(0, 0, item.size.width*item.value/item.max, item.size.height)
	item.filler:setTextureRect(cr)
	
	item = {value=UserData.ulevel}
	temp = UI.createLabel(tostring(item.value), "fonts/font3.fnt", 22, {colorR = 255, colorG = 255, colorB = 255})
	screen.autoSuitable(temp, {x=40, y=218, nodeAnchor=General.anchorCenter})
	bg:addChild(temp)
	item.valueLabel = temp
	self.level = item
	
	temp = UI.createLabel(UserData.userName, "fonts/font2.fnt", 13, {colorR = 255, colorG = 255, colorB = 255})
	screen.autoSuitable(temp, {x=69, y=246, nodeAnchor=General.anchorLeft})
	bg:addChild(temp)
	
	temp = UI.createSpriteWithFile("images/operationBottom.png",CCSizeMake(156, 30))
	screen.autoSuitable(temp, {x=13, y=142})
	bg:addChild(temp)
	temp = UI.createLabel("0/0", "fonts/font3.fnt", 20, {colorR = 255, colorG = 255, colorB = 255})
	screen.autoSuitable(temp, {x=76, y=156, nodeAnchor=General.anchorLeft})
	bg:addChild(temp)
	self.builder = {max=0, value=0, valueLabel = temp}
	temp = UI.createButton(CCSizeMake(33, 37), StoreDialog.show, {callbackParam="builders", image="images/buttonAdd.png", priority=display.MENU_BUTTON_PRI})
	screen.autoSuitable(temp, {x=153, y=156, nodeAnchor=General.anchorCenter})
	bg:addChild(temp)
	temp = UI.createSpriteWithFile("images/builder.png",CCSizeMake(54, 59))
	screen.autoSuitable(temp, {x=14, y=128})
	bg:addChild(temp)
	temp = UI.createLabel(StringManager.getString("labelBuilderNum"), "fonts/font2.fnt", 13, {colorR = 255, colorG = 255, colorB = 255})
	screen.autoSuitable(temp, {x=69, y=183, nodeAnchor=General.anchorLeft})
	bg:addChild(temp)
	
	temp = UI.createSpriteWithFile("images/operationBottom.png",CCSizeMake(156, 30))
	screen.autoSuitable(temp, {x=13, y=83})
	bg:addChild(temp)
	
	item = {value=UserData.userScore}
	temp = UI.createLabel(tostring(item.value), "fonts/font3.fnt", 20, {colorR = 255, colorG = 255, colorB = 255})
	screen.autoSuitable(temp, {x=75, y=96, nodeAnchor=General.anchorLeft})
	bg:addChild(temp)
	item.valueLabel = temp
	self.score = item
	temp = UI.createSpriteWithFile("images/score.png",CCSizeMake(46, 54))
	screen.autoSuitable(temp, {x=14, y=68})
	bg:addChild(temp)
	temp = UI.createButton(CCSizeMake(33, 37), display.showDialog, {callbackParam=RankDialog, image="images/rankIcon.png", priority=display.MENU_BUTTON_PRI})
	screen.autoSuitable(temp, {x=154, y=98, nodeAnchor=General.anchorCenter})
	bg:addChild(temp)
end

function MenuLayer:closeChildMenu()
	local n = self.childMenu
	if n then
		local ttime = getParam("actionTimeChildMenu", 200)/1000
		for i, temp in pairs(self.childNodes) do
			temp:runAction(CCAlphaTo:create(ttime, 255, 0))
			if i>0 then
				temp:runAction(CCEaseBackIn:create(CCMoveBy:create(ttime, CCPointMake(0, -120))))
			end
		end
		delayRemove(ttime, self.childMenu)
		self.childMenu = nil
	end
end

function MenuLayer:showChildMenu(buildView)
	self:closeChildMenu()
	local build = buildView.buildMould
	local binfo = build.buildInfo
	local bdata = build.buildData
	
	local bg = CCNode:create()
	bg:setContentSize(CCSizeMake(512,256))
	screen.autoSuitable(bg, {screenAnchor=General.anchorLeftBottom, scaleType=screen.SCALE_NORMAL})
		
	local buts = build:getChildMenuButs()
	local childNodes = {}
	buttonNum = #buts
	local xoff = 183-(buttonNum-1)/2*105
	for i=1, buttonNum do
		temp = createChildMenuButton(buts[i].image, buts[i].text, buts[i].callback, buts[i].callbackParam, buts[i].extend)
		screen.autoSuitable(temp, {nodeAnchor=General.anchorCenter, x=i*105+xoff, y=-60})
		bg:addChild(temp)
		childNodes[i] = temp
		temp:runAction(CCAlphaTo:create(getParam("actionTimeChildMenu", 200)/1000, 0, 255))
		temp:runAction(CCEaseBackOut:create(CCMoveBy:create(getParam("actionTimeChildMenu", 200)/1000, CCPointMake(0, 120))))
		if i==buttonNum and self.guideBid and self.guideBid==build.buildData.bid then
		    GuideLogic.clearPointer()
		    local pt = UI.createGuidePointer(90)
		    pt:setPosition(i*105+xoff+50, 60)
		    bg:addChild(pt)
		    self.guideBid=nil
		end
	end
	-- etc
	local titleKey = "titleInfo"
	if binfo.levelMax==1 then
		titleKey = "titleInfoNoLevel"
	end
	temp = UI.createLabel(StringManager.getFormatString(titleKey, {name=binfo.name, level=bdata.level}), General.specialFont, 33, {colorR = 255, colorG = 255, colorB = 181})
	screen.autoSuitable(temp, {x=288, y=132, nodeAnchor=General.anchorCenter})
	bg:addChild(temp)
	temp:setOpacity(0)
	temp:runAction(CCAlphaTo:create(getParam("actionTimeChildMenu", 200)/1000, 0, 255))
	childNodes[0] = temp
		
	self.view:addChild(bg, 1)
	self.childMenu = bg
	self.childNodes = childNodes
end

function MenuLayer:eventHandler(eventType, param)
	if eventType == EventManager.eventType.EVENT_DIALOG_OPEN then
		self.dialogShow = true
		self:closeChildMenu()
	elseif eventType == EventManager.eventType.EVENT_DIALOG_CLOSE then
		self.dialogShow = false
		if self.childMenuBuild then
			self:showChildMenu(self.childMenuBuild)
		end
	elseif eventType == EventManager.eventType.EVENT_BUILD_FOCUS then
		self.childMenuBuild = param
		if not self.dialogShow then
			self:showChildMenu(param)
		end
	elseif eventType == EventManager.eventType.EVENT_BUILD_UNFOCUS then
		self:closeChildMenu()
		self.childMenuBuild = nil
	elseif eventType == EventManager.eventType.EVENT_GUIDE_STEP then
		if param[1] == "menu" then
			local pname = param[2]
			self.buts[pname]:setVisible(true)
			local pt = GuideLogic.addPointer(0)
			local parent = self.buts[pname]:getParent()
			local x, y = self.buts[pname]:getPosition()
			pt:setPosition(x, y+60)
			parent:addChild(pt)
			if pname=="achieve" then
				self.buts["setting"]:setVisible(true)
				self.buts["mail"]:setVisible(true)
				GuideLogic.pointer = nil
				delayRemove(5, pt)
			end
			if pname=="shop" then
			    self.guideBid = param[3]
			end
		elseif param[1]=="build" then
		    self.guideBid = param[2]
		end
	elseif eventType == EventManager.eventType.EVENT_NOTICE_BUTTON then
	    local temp = self.butNotices[param.name]
	    if param.isShow then
	        temp:setVisible(true)
	        local array = CCArray:create()
	        array:addObject(CCEaseSineOut:create(CCScaleTo:create(0.2, 1.2, 1.2)))
	        array:addObject(CCEaseSineIn:create(CCScaleTo:create(0.2, 1, 1)))
	        temp:runAction(CCSequence:create(array))
	    else
	        temp:setVisible(false)
	    end
	end
end
		 
function MenuLayer:enterOrExit(isEnter)
	if isEnter then
		self.monitorId = EventManager.registerEventMonitor({"EVENT_DIALOG_CLOSE", "EVENT_DIALOG_OPEN", "EVENT_BUILD_FOCUS", "EVENT_BUILD_UNFOCUS", "EVENT_GUIDE_STEP", "EVENT_NOTICE_BUTTON"}, self.eventHandler, self)
	else
		EventManager.removeEventMonitor(self.monitorId)
	end
end

function MenuLayer:update(diff)
	local resourceTypes = {"oil", "food", "person"}
	for i=1, 3 do
		local resourceType = resourceTypes[i]
		local item = self[resourceType]
		local fillerUpdate = false
		if ResourceLogic.getResource(resourceType) ~= item.value then
			fillerUpdate = true
			item.value = ResourceLogic.getResource(resourceType)
			item.valueLabel:setString(tostring(item.value))
		end
		if ResourceLogic.getResourceMax(resourceType) ~= item.max then
			fillerUpdate = true
			item.max = ResourceLogic.getResourceMax(resourceType)
			item.maxLabel:setString(StringManager.getFormatString("resourceMax", {max=item.max}))
		end
		if fillerUpdate then
			local lmax = item.max
			if lmax==0 then lmax=1 end
			local cr = CCRectMake(item.size.width-item.size.width*item.value/lmax, 0, item.size.width*item.value/lmax, item.size.height)
			item.filler:setTextureRect(cr)
		end
	end
	
	local item = self.builder
	if ResourceLogic.getResourceMax("builder") ~= item.max or ResourceLogic.getResource("builder") ~= item.value then
		item.max = ResourceLogic.getResourceMax("builder") 
		item.value = ResourceLogic.getResource("builder")
		item.valueLabel:setString(item.value .. "/" .. item.max)
	end
	
	if UserData.crystal~=self.crystal.value then
		self.crystal.value = UserData.crystal
		self.crystal.valueLabel:setString(tostring(self.crystal.value))
	end
	
	local tstr = StringManager.getTimeString(math.floor((UserData.shieldTime or 0) - timer.getTime()))
	if tstr~=self.shieldString then
		self.shieldString = tstr
		self.shieldLabel:setString(tstr)
	end
	
	local zombieShield = (UserData.zombieShieldTime or 60)-timer.getTime()
	tstr = StringManager.getTimeString(zombieShield)
	if tstr ~= self.zombieShieldString then
		self.zombieShieldString = tstr
		self.zombieShieldLabel:setString(tstr)
	end
	if zombieShield<0 and not display.isDialogShow() and GuideLogic.complete then
		display.showDialog(ZombieDialog)
	end
	
	if self.score.value ~= UserData.userScore then
		self.score.value = UserData.userScore
		self.score.valueLabel:setString(tostring(self.score.value))
	end
	
	if self.level.value ~= UserData.ulevel then
		self.level.value = UserData.ulevel
        local target = self.level.valueLabel
		target:setString(tostring(self.level.value))
		
	    local temp = UI.createSpriteWithFile("images/expUpgrade.png")
	    
        local temp1 = UI.createLabel(tostring(UserData.ulevel), "fonts/font3.fnt", 40, {colorR = 255, colorG = 255, colorB = 255, lineOffset=-12})
        screen.autoSuitable(temp1, {x=104, y=94, nodeAnchor=General.anchorCenter})
        temp:addChild(temp1)
        temp1 = UI.createLabel(StringManager.getString("labelLevelUp"), "fonts/font3.fnt", 28, {colorR = 255, colorG = 255, colorB = 255})
        screen.autoSuitable(temp1, {x=104, y=131, nodeAnchor=General.anchorCenter})
        temp:addChild(temp1)
        
        local bg = target:getParent()
        local p = bg:convertToNodeSpace(CCPointMake(General.winSize.width/2, General.winSize.height/2))
        print("test1")
        screen.autoSuitable(temp, {nodeAnchor=General.anchorCenter, x=p.x, y=p.y})
        bg:addChild(temp)
        temp:setScale(0)
        local array = CCArray:create()
        array:addObject(CCEaseBackOut:create(CCScaleTo:create(0.4, 1, 1)))
        array:addObject(CCDelayTime:create(2))
        
        local sarray = CCArray:create()
        local x, y = target:getPosition()
        sarray:addObject(CCMoveTo:create(0.5, CCPointMake(x, y)))
        sarray:addObject(CCScaleTo:create(0.5, 0, 0))
        array:addObject(CCSpawn:create(sarray))
        array:addObject(CCCallFuncN:create(removeSelf))
        
        temp:runAction(CCSequence:create(array))
	end
	
	if self.exp.value ~= UserData.exp or self.exp.max ~= UserData.nextExp then
	    self.exp.value = UserData.exp
	    self.exp.max = UserData.nextExp
	    self.exp.valueLabel:setString(tostring(self.exp.value))
	    local cr = CCRectMake(0, 0, self.exp.size.width*self.exp.value/self.exp.max, self.exp.size.height)
	    self.exp.filler:setTextureRect(cr)
	end
end

function MenuLayer:dalayZombieAttack(force)
    if force then
        if CrystalLogic.changeCrystal(-100) then
            local t = UserData.zombieShieldTime
            if (t or 0)<=timer.getTime() then
                UserData.zombieShieldTime = timer.getTime() + 28800
            else
                UserData.zombieShieldTime = UserData.zombieShieldTime + 28800
            end
        end
    else
        display.showDialog(AlertDialog.new(StringManager.getString("titleBuyZombieShield"), StringManager.getString("textBuyZombieShield"), {callback=self.dalayZombieAttack, param=true, crystal=100}, self))
    end
end

ZombieMenuLayer = class(MenuLayer)

function ZombieMenuLayer:ctor(scene)
    self.count=3
    self.time=5
end

function ZombieMenuLayer:initRightTop()
end
function ZombieMenuLayer:initTop()
	local temp, bg = nil
	bg = CCNode:create()
	bg:setContentSize(CCSizeMake(256, 128))
	screen.autoSuitable(bg, {screenAnchor=General.anchorTop, scaleType=screen.SCALE_NORMAL})
	self.view:addChild(bg)
	temp = UI.createButton(CCSizeMake(133, 48), self.endBattle, {callbackParam=self, image="images/buttonEnd.png", text=StringManager.getString("buttonEndBattle"), fontSize=18, fontName="fonts/font3.fnt", priority=display.MENU_BUTTON_PRI})
	screen.autoSuitable(temp, {x=128, y=79, nodeAnchor=General.anchorCenter})
	bg:addChild(temp)
    self.topView = bg
    self.topView:setVisible(false)
end
function ZombieMenuLayer:initLeftTop()
	local temp, bg = nil
	bg = CCNode:create()
	bg:setContentSize(CCSizeMake(256, 192))
	screen.autoSuitable(bg, {scaleType=screen.SCALE_NORMAL, screenAnchor=General.anchorLeftTop})
	self.view:addChild(bg)
	
	temp = UI.createSpriteWithFile("images/expFiller.png",CCSizeMake(219, 28))
    screen.autoSuitable(temp, {x=21, y=133})
    bg:addChild(temp)
    temp = UI.createSpriteWithFile("images/fillerBottom.png",CCSizeMake(225, 34))
    screen.autoSuitable(temp, {x=18, y=129})
    bg:addChild(temp)
    temp = UI.createLabel("0", "fonts/font3.fnt", 17, {colorR = 255, colorG = 255, colorB = 255})
    screen.autoSuitable(temp, {x=85, y=146, nodeAnchor=General.anchorLeft})
    bg:addChild(temp)
	self.zombie = {value=0, valueLabel=temp}
    temp = UI.createSpriteWithFile("images/zombie.png",CCSizeMake(46, 58))
    screen.autoSuitable(temp, {x=23, y=119})
    bg:addChild(temp)
    temp = UI.createLabel(StringManager.getString("labelZombies"), "fonts/font2.fnt", 13, {colorR = 255, colorG = 255, colorB = 255})
    screen.autoSuitable(temp, {x=81, y=173, nodeAnchor=General.anchorLeft})
    bg:addChild(temp)
    
    temp = UI.createLabel(StringManager.getString("labelBuilderNum"), "fonts/font2.fnt", 13, {colorR = 255, colorG = 255, colorB = 255})
    screen.autoSuitable(temp, {x=82, y=52, nodeAnchor=General.anchorLeft})
    bg:addChild(temp)
    temp = UI.createSpriteWithFile("images/operationBottom.png",CCSizeMake(156, 30))
    screen.autoSuitable(temp, {x=21, y=11})
    bg:addChild(temp)
    temp = UI.createSpriteWithFile("images/builder.png",CCSizeMake(54, 59))
    screen.autoSuitable(temp, {x=22, y=-3})
    bg:addChild(temp)
    temp = UI.createLabel(StringManager.getString("0/0"), "fonts/font3.fnt", 20, {colorR = 255, colorG = 255, colorB = 255})
    screen.autoSuitable(temp, {x=85, y=27, nodeAnchor=General.anchorLeft})
    bg:addChild(temp)
    self.builder = {max=0, value=0, valueLabel=temp}
    
    temp = UI.createLabel(StringManager.getString("labelPopulation"), "fonts/font2.fnt", 13, {colorR = 255, colorG = 255, colorB = 255})
    screen.autoSuitable(temp, {x=81, y=111, nodeAnchor=General.anchorLeft})
    bg:addChild(temp)
    temp = UI.createSpriteWithFile("images/specialFiller.png",CCSizeMake(153, 30))
    screen.autoSuitable(temp, {x=22, y=70})
    bg:addChild(temp)
    temp = UI.createSpriteWithFile("images/fillerBottom.png",CCSizeMake(157, 34))
    screen.autoSuitable(temp, {x=20, y=68})
    bg:addChild(temp)
    temp = UI.createLabel("0", "fonts/font3.fnt", 20, {colorR = 255, colorG = 255, colorB = 255})
    screen.autoSuitable(temp, {x=85, y=83, nodeAnchor=General.anchorLeft})
    bg:addChild(temp)
	self.person = {value=0, valueLabel=temp}
    temp = UI.createSpriteWithFile("images/person.png",CCSizeMake(67, 52))
    screen.autoSuitable(temp, {x=5, y=58})
    bg:addChild(temp)
end

function ZombieMenuLayer:initRightBottom()
    local temp, bg = nil
    bg = CCNode:create()
    bg:setContentSize(General.winSize)
    self.bottomView = bg
    self.view:addChild(bg)
    
    temp = UI.createLabel(StringManager.getString("tipsZombieDefense2"), "fonts/font3.fnt", 26, {colorR = 255, colorG = 255, colorB = 255})
    screen.autoSuitable(temp, {screenAnchor=General.anchorBottom, x=0, y=135, nodeAnchor=General.anchorCenter})
    bg:addChild(temp)
end

function ZombieMenuLayer:changeTimeScale()
	self.timeScale.value = self.timeScale.value%3+1
	local tvalue = TIME_SCALE[self.timeScale.value]
	self.timeScale.valueLabel:setString("x" .. tvalue)
	CCDirector:sharedDirector():getScheduler():setTimeScale(tvalue)
end
local zombieArea = {{640, 936}, {764, 2400}, {3240, 2366}, {2880, 220}, {3272, 468}, {3784, 860}}

function ZombieMenuLayer:beginDefend()
    self.topView:setVisible(true)
    local bg = self.bottomView
    bg:removeAllChildrenWithCleanup(true)
    
	local temp = UI.createButton(CCSizeMake(169, 76), self.changeTimeScale, {callbackParam=self, image="images/buttonGreen.png", priority=display.MENU_BUTTON_PRI})
	screen.autoSuitable(temp, {x=0, y=80, nodeAnchor=General.anchorCenter, screenAnchor=General.anchorBottom, scaleType=screen.SCALE_NORMAL})
	bg:addChild(temp)
	
	local label = UI.createLabel("x1", "fonts/font3.fnt", 30)
	screen.autoSuitable(label, {nodeAnchor=General.anchorCenter, x=85, y=38})
	temp:addChild(label)
	self.timeScale = {valueLabel=label, value=1}
	CCDirector:sharedDirector():getScheduler():setTimeScale(1)

    local cnode = CCNode:create()
    screen.autoSuitable(cnode, {screenAnchor=General.anchorLeftBottom, scaleType=screen.SCALE_NORMAL})
    bg:addChild(cnode)
    temp = UI.createSpriteWithFile("images/battleStarBg.png",CCSizeMake(183, 94))
    screen.autoSuitable(temp, {x=19, y=23})
    cnode:addChild(temp)
    self.stars = {}
    for i=1, 3 do
        temp = UI.createSpriteWithFile("images/battleStar1.png",CCSizeMake(29, 27))
        screen.autoSuitable(temp, {x=36 + i*30, y=64})
        cnode:addChild(temp)
        temp = UI.createSpriteWithFile("images/battleStar0.png",CCSizeMake(29, 28))
        screen.autoSuitable(temp, {nodeAnchor=General.anchorCenter, x=51 + i*30, y=78})
        cnode:addChild(temp)
        self.stars[i] = temp
    end
    self.starsNum = 3
    temp = UI.createLabel("100%", "fonts/font3.fnt", 30, {colorR = 255, colorG = 255, colorB = 255})
    screen.autoSuitable(temp, {x=111, y=47, nodeAnchor=General.anchorCenter})
    cnode:addChild(temp)
	self.percent = 100
	self.percentLabel = temp
    temp = UI.createLabel(StringManager.getString("damagePercent"), "fonts/font3.fnt", 16, {colorR = 255, colorG = 255, colorB = 255})
    screen.autoSuitable(temp, {x=113, y=100, nodeAnchor=General.anchorCenter})
    cnode:addChild(temp)
    
    for i, build in pairs(self.scene.builds) do
        if build.npcViews then
            for _, npc in ipairs(build.npcViews) do
                if not npc.deleted then
                    npc:runBackHome()
                end
            end
        end
    end
end

function ZombieMenuLayer:update(diff)
	if self.battleEnd then return end
	if ZombieLogic.getPerson()~=self.person.value then
		self.person.value = ZombieLogic.getPerson()
		self.person.valueLabel:setString(tostring(self.person.value))
	end
	if ZombieLogic.getBuilderMax()~=self.builder.max or ZombieLogic.getBuilder()~=self.builder.value then
	    self.builder.max = ZombieLogic.getBuilderMax()
	    self.builder.value = ZombieLogic.getBuilder()
	    self.builder.valueLabel:setString(self.builder.value .. "/" .. self.builder.max)
	end
	if self.time then
	    self.time = self.time - diff
		if self.count and self.count>0 and self.time < self.count+1 then
			local temp = UI.createSpriteWithFile("images/count" .. self.count .. ".png")
			temp:setScale(0.01)
			screen.autoSuitable(temp, {screenAnchor=General.anchorCenter})
			self.view:addChild(temp, 10)
			temp:runAction(CCScaleTo:create(0.25, 1, 1))
			delayRemove(1, temp)
			self.count = self.count - 1
		end
		if self.time<0 then
		    self.time = nil
		    self.count = nil
		    self:beginDefend()
		end
		return
	end
	if ZombieLogic.getZombie()>0 then
		local cd = 1
		local zid = ZombieLogic.getOneZombie()
		local soldier = Zombie.new(zid+10, {isFighting=true})
		
		local areaId = ZombieLogic.getOneZombieArea()
		local p = zombieArea[areaId]
		local x, y = p[1] + math.random(220)-110, p[2] + math.random(165)
		soldier:addToScene(self.scene, {x, y})
		table.insert(self.scene.soldiers, soldier)
	end
	self.coldTime = (self.coldTime or 0) - diff
	if self.coldTime<0 then
	    self.coldTime = 0.5
	    local zombieNum = 0
		local toDel = {}
		for i, zombie in pairs(self.scene.soldiers) do
			if zombie.deleted then
				table.insert(toDel, i)
			else
				zombieNum = zombieNum+1
			end
		end
        if zombieNum~=self.zombie.value then
        	self.zombie.value = zombieNum
        	self.zombie.valueLabel:setString(tostring(self.zombie.value))
        end
		for i=1, #toDel do
			self.scene.soldiers[toDel[i]] = nil
		end
		if zombieNum==0 then
		    if ZombieLogic.wave>1 then
    		    local wave = ZombieLogic.wave-1
    		    ZombieLogic.wave = wave
    		    ZombieLogic.initZombies()
    		    local text
    		    if wave==1 then
    		        text = StringManager.getString("labelFinalWave")
    		    else
    		        text = StringManager.getString("labelZombieDefense")
    		    end
    		    local label = UI.createLabel(text, "fonts/font3.fnt", 40, {colorR=253, colorG=8, colorB=8})
    		    screen.autoSuitable(label, {screenAnchor=General.anchorCenter})
    		    self.bottomView:addChild(label)
    		    
    		    label:setScale(0)
    		    label:runAction(CCScaleTo:create(0.25, 1, 1))
    		    delayRemove(2, label)
    		else
    			self:endBattle(false)
    		end
    	end
	end
	if ZombieLogic.percent~=self.percent then
	    self.percent = ZombieLogic.percent
	    self.percentLabel:setString(ZombieLogic.percent .. "%")
	end
	if ZombieLogic.stars < self.starsNum then
	    local star = self.stars[self.starsNum]
	    local array = CCArray:create()
	    array:addObject(CCEaseBackIn:create(CCScaleTo:create(0.5, 0, 0)))
	    array:addObject(CCCallFuncN:create(removeSelf))
	    star:runAction(CCSequence:create(array))
	    self.starsNum = self.starsNum-1
	end
	if ZombieLogic.battleEnd then
	    self.battleEnd = true
		--self.replayFile:write(json.encode({timer.getTime() - self.beginTime, "e"}) .. "\n")
		--self.replayFile:close()
		self.view:removeFromParentAndCleanup(true)
		display.showDialog(ZombieResultDialog.new(ZombieLogic.getBattleResult()))
	end
end

function ZombieMenuLayer:endBattle(force)
    if force~=nil then
        if force then
            local losePerson = math.floor(ResourceLogic.getResource("person")*LOST_PERCENT/100)
            if losePerson>-ZombieLogic.losePerson then
                ZombieLogic.losePerson = -losePerson
            end
            ZombieLogic.stars=0
        end
    	ZombieLogic.battleEnd = true
    	ZombieLogic.isGuide = false
    	CCDirector:sharedDirector():getScheduler():setTimeScale(1)
    	
    	--Action.test(true)
    	--delayCallback(1, display.popScene)
    	--ResourceLogic.changeResource("person", ZombieLogic.losePerson)
    	--EventManager.sendMessage("EVENT_OTHER_OPERATION", {type="Add", key="zombie", value=1})
    else
        display.showDialog(AlertDialog.new(StringManager.getString("alertTitleEndBattle"), StringManager.getFormatString("alertTextEndZombie", {percent=LOST_PERCENT}), {callback=self.endBattle, param=true}, self))
    end
end