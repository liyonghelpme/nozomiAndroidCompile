-- 引导流程在程序中作为一种全屏式的对话框处理

GuideLogic = {}

function GuideLogic.init(guideStep, num, scene)
	print("test", guideStep)
	GuideLogic.step = guideStep
	GuideLogic.num = num
	if scene then GuideLogic.scene = scene end
	if num then
		GuideLogic.checkGuide()
	else
		GuideLogic.showGuide()
	end
end

local GuideInfo = 
{{"BuildLevel", {3000}, 1}, {"zombie", 1}, {"Soldier", 20}, {"battle", 1}, {"BuildLevel", {2000, 2001, 2002, 2006}, 1}, {"BuildLevel", {1}, 2}}

local GuidePointerSetting = 
{[1]={"menu", "shop", 5, {[3000]=1}}, [3]={"build", 1001}, [4]={"menu", "attack"}, [5]={"menu", "shop", 2, {[2000]=1, [2001]=1, [2002]=1, [2006]=1}}, [6]={"build", 0}, [7]={"menu", "achieve"}}

function GuideLogic.checkBuild(bid, level)
	if GuideLogic.builds[bid] and level>=GuideInfo[GuideLogic.step][3] then
		GuideLogic.builds.num = GuideLogic.builds.num-1
		GuideLogic.builds[bid] = nil
		
		if GuideLogic.builds.num==0 then
			GuideLogic.num = 1
			GuideLogic.completeStep()
			return true
		end
	end
end

function GuideLogic.completeStep()
	if GuideLogic.monitorId then
		EventManager.removeEventMonitor(GuideLogic.monitorId)
		GuideLogic.monitorId = nil
	end
	GuideLogic.init(GuideLogic.step+1)
end

function GuideLogic.checkGuide()
	local info = GuideInfo[GuideLogic.step]
	if not info then
		GuideLogic.complete = true
		return true
	end
	if not GuideLogic.num then
		GuideLogic.num = 0
	end
	if info[1]=="BuildLevel" then
		GuideLogic.builds = {num=#info[2]}
		for i=1, #info[2] do
			GuideLogic.builds[info[2][i]] = 1
		end
		local scene = GuideLogic.scene
		for _, build in pairs(scene.builds) do
			local bid = build.buildData.bid
			local level = build.buildLevel
			if GuideLogic.checkBuild(bid, level) then
				return true
			end
		end
		GuideLogic.monitorId = EventManager.registerEventMonitor({"EVENT_BUILD_UPDATE"}, GuideLogic.eventHandler)
	elseif GuideLogic.num>=info[2] then
		GuideLogic.completeStep()
	end
	if info[1]=="Soldier" then
		GuideLogic.monitorId = EventManager.registerEventMonitor({"EVENT_BUY_SOLDIER"}, GuideLogic.eventHandler)
	elseif info[1]=="battle" then
		GuideLogic.monitorId = EventManager.registerEventMonitor({"EVENT_BATTLE_END"}, GuideLogic.eventHandler)
	end
end

function GuideLogic.eventHandler(eventType, param)
	if eventType == EventManager.eventType.EVENT_BUILD_UPDATE then
		local bid=param.bid 
		local level = param.level
		GuideLogic.checkBuild(bid, level)
	elseif eventType == EventManager.eventType.EVENT_OTHER_OPERATION then
		local key = param.key
		if key==GuideInfo[GuideLogic.step][1] then
			GuideLogic.completeStep()
		end
	elseif eventType == EventManager.eventType.EVENT_BUY_SOLDIER then
		GuideLogic.num = GuideLogic.num + 1
		if GuideLogic.num>=GuideInfo[GuideLogic.step][2] then
			GuideLogic.completeStep()
		end
	elseif eventType == EventManager.eventType.EVENT_BATTLE_END then
		print("test")
		GuideLogic.completeStep()
	end
end

local SHOW_SETTING={[1]=1, [2]=3}

function GuideLogic.showGuide()
	if GuideLogic.pointer then
		GuideLogic.pointer:removeFromParentAndCleanup(true)
		GuideLogic.pointer = nil
	end
	local scene = display.getCurrentScene()
	if display.isDialogShow() or (GuideLogic.scene and scene~=GuideLogic.scene) then
		delayCallback(1, GuideLogic.showGuide)
		return
	end
	GuideLogic.scene = scene
	local bg = CCLayerColor:create(ccc4(0, 0, 0, General.darkAlpha), General.winSize.width, General.winSize.height)
	local bnode, temp
	local showType = SHOW_SETTING[GuideLogic.step] or 2
	if showType<3 then
		bnode = CCNode:create()
		screen.autoSuitable(bnode, {scaleType=screen.SCALE_NORMAL})
		bg:addChild(bnode)
		
		temp = UI.createSpriteWithFile("images/guideNpcBack.png",CCSizeMake(557, 151))
		screen.autoSuitable(temp, {x=-3, y=-8})
		bnode:addChild(temp)
		
		if showType==1 then
			temp = UI.createSpriteWithFile("images/guideNpc1.png",CCSizeMake(249, 371))
			screen.autoSuitable(temp, {x=1024, y=35})
			bnode:addChild(temp)
			temp:runAction(CCEaseBackOut:create(CCMoveTo:create(0.5, CCPointMake(68, 35))))
		else
			temp = UI.createSpriteWithFile("images/guideNpc2.png",CCSizeMake(229, 393))
			screen.autoSuitable(temp, {nodeAnchor=General.anchorBottom, x=203, y=22})
			bnode:addChild(temp)
			temp:setScaleY(0)
			temp:runAction(CCEaseBackOut:create(CCScaleTo:create(0.5, 1, 1)))
		end
		temp = UI.createSpriteWithFile("images/guideChatBackA.png",CCSizeMake(336, 114))
		screen.autoSuitable(temp, {x=274, y=235, nodeAnchor=General.anchorLeft})
		bnode:addChild(temp)
		local label = UI.createLabel(StringManager.getString("guideText" .. GuideLogic.step), "fonts/font1.fnt", 13, {colorR = 255, colorG = 255, colorB = 255, size=CCSizeMake(260, 114)})
		screen.autoSuitable(label, {x=58, y=73, nodeAnchor=General.anchorLeft})
		temp:addChild(label)
		temp:setScaleX(0)
		local array = CCArray:create()
		array:addObject(CCDelayTime:create(0.5))
		array:addObject(CCScaleTo:create(0.25, 1, 1))
		temp:runAction(CCSequence:create(array))
		
		local gpSetting = GuidePointerSetting[GuideLogic.step]
		if gpSetting then
			EventManager.sendMessage("EVENT_GUIDE_STEP", gpSetting)
			GuideLogic.pointerSetting = gpSetting
		end
	else
		bnode = CCNode:create()
		screen.autoSuitable(bnode, {scaleType=screen.SCALE_NORMAL, screenAnchor=General.anchorRightBottom})
		bg:addChild(bnode)
		
		temp = UI.createSpriteWithFile("images/guideZombieBack.png",CCSizeMake(565, 379))
		screen.autoSuitable(temp, {x=-538, y=-15})
		bnode:addChild(temp)
		temp = UI.createSpriteWithFile("images/zombieFeature.png",CCSizeMake(346, 403))
		screen.autoSuitable(temp, {x=0, y=19})
		bnode:addChild(temp)
		temp:runAction(CCEaseBackOut:create(CCMoveTo:create(0.5, CCPointMake(-481, 19))))
		temp = UI.createSpriteWithFile("images/guideChatBackB.png",CCSizeMake(344, 163))
		screen.autoSuitable(temp, {x=-448, y=182, nodeAnchor=General.anchorRight})
		bnode:addChild(temp)
		local label = UI.createLabel(StringManager.getString("guideText" .. GuideLogic.step), "fonts/font1.fnt", 13, {colorR = 255, colorG = 255, colorB = 255, size=CCSizeMake(260, 114)})
		screen.autoSuitable(label, {x=18, y=73, nodeAnchor=General.anchorLeft})
		temp:addChild(label)
		local but = UI.createButton(CCSizeMake(108, 45), GuideLogic.enterZombieScene, {image="images/buttonGreen.png", text=StringManager.getString("buttonDefense"), fontSize=20, fontName="fonts/font3.fnt"})
		screen.autoSuitable(but, {x=154, y=36, nodeAnchor=General.anchorCenter})
		temp:addChild(but)
		temp:setScaleX(0)
		local array = CCArray:create()
		array:addObject(CCDelayTime:create(0.5))
		array:addObject(CCScaleTo:create(0.25, 1, 1))
		temp:runAction(CCSequence:create(array))
	end
	GuideLogic.view = bg
	simpleRegisterEvent(bg, {touch={callback=GuideLogic.touch, multi=false, priority=display.DIALOG_BUTTON_PRI, swallow=true}})
	scene.view:addChild(bg, 10)
end

function GuideLogic.touch(eventType, x, y)
	-- TEST
	if GuideLogic.step~=2 and GuideLogic.view then
		GuideLogic.view:removeFromParentAndCleanup(true)
		GuideLogic.view = nil
		
		return GuideLogic.checkGuide()
	end
	return true
end

function GuideLogic.enterZombieScene()
	GuideLogic.view:removeFromParentAndCleanup(true)
	GuideLogic.view = nil
	GuideLogic.num = 0
	ZombieLogic.isGuide = true
	local scene = GuideLogic.scene
	scene:updateLogic(300)
	UserData.baseScene = scene
	UI.testChangeScene(true)
	UserData.zombieShieldTime = timer.getTime() + 86400
	delayCallback(1, display.pushScene, ZombieScene)
	GuideLogic.monitorId = EventManager.registerEventMonitor({"EVENT_OTHER_OPERATION"}, GuideLogic.eventHandler)
end

function GuideLogic.addPointer(angle)
	if GuideLogic.pointer then
		GuideLogic.pointer:removeFromParentAndCleanup(true)
		GuideLogic.pointer = nil
	end
	GuideLogic.pointer = UI.createGuidePointer(angle)
	return GuideLogic.pointer
end