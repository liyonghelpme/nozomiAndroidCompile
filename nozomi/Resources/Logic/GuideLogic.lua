-- 引导流程在程序中作为一种全屏式的对话框处理

GuideLogic = {}

function GuideLogic.init(guideStep, num, scene)
	GuideLogic.step = guideStep
	GuideLogic.num = num
	if scene then GuideLogic.scene = scene end
	if num then
		GuideLogic.checkGuide()
	else
	    GuideLogic.animateStep = 0
	    if guideStep==1 then
	        delayCallback(1, GuideLogic.showStory)
	    else
    		GuideLogic.nextAnimate()
    	end
	end
end

local GuideInfo = 
{{"BuildLevel", 3000, 1}, {"zombie", 1}, {"BuildLevel", 2003, 1}, {"BuildLevel", 2000, 1}, {"BuildLevel", 2001, 1}, {"BuildLevel", 0, 1}, {"BuildLevel", 1001, 1}, {"Soldier", 20}, {"battle", 1}, {"BuildLevel", 1, 2}}

local GuideShowTypes = {{{2, 1}, {3,2}, {1,3}}, {}, {{2,4},{2,5}}, {{2,6}}, {{2,7}}, {{2,8}}, {{2,9}}, {{2,10}}, {}, {{2,11}}, {{2,12}, {2,13}}}

function GuideLogic.checkBuild(bid, level)
    local info = GuideInfo[GuideLogic.step]
	if bid==info[2] and level>=info[3] then
		GuideLogic.num = 1
		GuideLogic.completeStep()
		return true
	end
end

function GuideLogic.completeStep()
    GuideLogic.guideBid = nil
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
    	if GuideLogic.view then
    	    GuideLogic.bnode:removeFromParentAndCleanup(true)
    	    GuideLogic.bnode = nil
    	    GuideLogic.view:removeFromParentAndCleanup(true)
    	    GuideLogic.view = nil
    	end
		return true
	end
	if not GuideLogic.num then
		GuideLogic.num = 0
	end
	if info[1]=="BuildLevel" then
		local scene = GuideLogic.scene
		for _, build in pairs(scene.builds) do
			local bid = build.buildData.bid
			local level = build.buildLevel
			if GuideLogic.checkBuild(bid, level) then
				return true
			end
		end
		GuideLogic.monitorId = EventManager.registerEventMonitor({"EVENT_BUILD_UPDATE"}, GuideLogic.eventHandler)
		if info[3]>1 then
		    EventManager.sendMessage("EVENT_GUIDE_STEP", {"build", info[2]})
		else
		    GuideLogic.guideBid = info[2]
    		EventManager.sendMessage("EVENT_GUIDE_STEP", {"menu", "shop", info[2]})
    	end
	elseif GuideLogic.num>=info[2] then
		GuideLogic.completeStep()
		return true
	end
	if info[1]=="Soldier" then
		GuideLogic.monitorId = EventManager.registerEventMonitor({"EVENT_BUY_SOLDIER"}, GuideLogic.eventHandler)
		EventManager.sendMessage("EVENT_GUIDE_STEP", {"build", 1001})
		GuideLogic.isTrainGuide = true
	elseif info[1]=="battle" then
		GuideLogic.monitorId = EventManager.registerEventMonitor({"EVENT_BATTLE_END"}, GuideLogic.eventHandler)
		EventManager.sendMessage("EVENT_GUIDE_STEP", {"menu", "attack"})
	elseif info[1]=="zombie" then
	    ZombieLogic.isGuide = true
	    display.showDialog(ZombieDialog.create())
		GuideLogic.monitorId = EventManager.registerEventMonitor({"EVENT_OTHER_OPERATION"}, GuideLogic.eventHandler)
	end
	if GuideLogic.view then
	    GuideLogic.bnode:removeFromParentAndCleanup(true)
	    GuideLogic.bnode = nil
	    GuideLogic.view:removeFromParentAndCleanup(true)
	    GuideLogic.view = nil
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

function GuideLogic.showStory()
    local bg = CCLayerColor:create(ccc4(0, 0, 0, General.darkAlpha), General.winSize.width, General.winSize.height)
	
	local action = UI.createSpriteWithFile("images/newspaper.png")
	GuideLogic.bnode = action
	action:setScale(0)
	local scale = screen.getScalePolicy()[screen.SCALE_NORMAL]
	local t=getParam("actionTimeNewspaper", 1000)/1000
	action:runAction(CCScaleTo:create(t, scale, scale))
	action:runAction(CCRotateBy:create(t, getParam("actionTimeRotation", 1080)))
	screen.autoSuitable(action, {screenAnchor=General.anchorCenter})
	bg:addChild(action)
	simpleRegisterEvent(bg, {touch={callback=GuideLogic.touch, multi=false, priority=display.DIALOG_BUTTON_PRI, swallow=true}})
	GuideLogic.view = bg
	GuideLogic.touchTime = timer.getTime()+t
    
	GuideLogic.scene.view:addChild(bg, 10)
	
    CCTextureCache:sharedTextureCache():removeTextureForKey("images/newspaper.png")
end

function GuideLogic.nextAnimate()
	if GuideLogic.pointer then
		GuideLogic.pointer:removeFromParentAndCleanup(true)
		GuideLogic.pointer = nil
	end
	local scene = display.getCurrentScene()
	if display.isDialogShow() or (scene~=GuideLogic.scene) then
		delayCallback(2, GuideLogic.nextAnimate)
		return
	end
	
    local aniStep = (GuideLogic.animateStep or 0)+1
    local showType = GuideShowTypes[GuideLogic.step][aniStep]
    if not showType then
        return GuideLogic.checkGuide()
    end
    GuideLogic.animateStep = aniStep
    if not GuideLogic.view then
	    local bg = CCLayerColor:create(ccc4(0, 0, 0, General.darkAlpha), General.winSize.width, General.winSize.height)
        simpleRegisterEvent(bg, {touch={callback=GuideLogic.touch, multi=false, priority=display.DIALOG_BUTTON_PRI, swallow=true}})
	    GuideLogic.scene.view:addChild(bg, 10)
        GuideLogic.view = bg
        GuideLogic.showType = nil
    end
    if GuideLogic.showType~=showType[1] then
        if GuideLogic.bnode then
            GuideLogic.bnode:removeFromParentAndCleanup(true)
        end
        local bnode = CCNode:create()
        local temp, label
        GuideLogic.view:addChild(bnode)
        GuideLogic.showType=showType[1]
        if showType[1]<3 then
    		screen.autoSuitable(bnode, {scaleType=screen.SCALE_NORMAL})
    		
    		temp = UI.createSpriteWithFile("images/guideNpcBack.png",CCSizeMake(557, 151))
    		screen.autoSuitable(temp, {x=-3, y=-8})
    		bnode:addChild(temp)
    		
    		if showType[1]==1 then
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
    		label = UI.createLabel("", "fonts/font1.fnt", 13, {colorR = 255, colorG = 255, colorB = 255, size=CCSizeMake(260, 114), align=kCCTextAlignmentLeft})
    		screen.autoSuitable(label, {x=58, y=73, nodeAnchor=General.anchorLeft})
    		temp:addChild(label)
    		temp:setScaleX(0)
    		local array = CCArray:create()
    		array:addObject(CCDelayTime:create(0.5))
    		array:addObject(CCScaleTo:create(0.25, 1, 1))
    		temp:runAction(CCSequence:create(array))
    	else
    		screen.autoSuitable(bnode, {scaleType=screen.SCALE_NORMAL, screenAnchor=General.anchorRightBottom})
    		
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
    		label = UI.createLabel("", "fonts/font1.fnt", 13, {colorR = 255, colorG = 255, colorB = 255, size=CCSizeMake(260, 114), align=kCCTextAlignmentLeft})
    		screen.autoSuitable(label, {x=18, y=78, nodeAnchor=General.anchorLeft})
    		temp:addChild(label)
    		temp:setScaleX(0)
    		local array = CCArray:create()
    		array:addObject(CCDelayTime:create(0.5))
    		array:addObject(CCScaleTo:create(0.25, 1, 1))
    		temp:runAction(CCSequence:create(array))
    	end
    	GuideLogic.bnode = bnode
    	GuideLogic.label = label
    end
    GuideLogic.label:setString(StringManager.getString("guideText" .. showType[2]))
	GuideLogic.touchTime = timer.getTime()+1
	return true
end

function GuideLogic.touch(eventType, x, y)
	-- TEST
	if GuideLogic.touchTime and GuideLogic.touchTime>timer.getTime() then
	    return true
	end
	if GuideLogic.step~=2 and GuideLogic.view then
	    return GuideLogic.nextAnimate()
	end
	return true
end

function GuideLogic.addPointer(angle)
	GuideLogic.clearPointer()
	GuideLogic.pointer = UI.createGuidePointer(angle)
	return GuideLogic.pointer
end

function GuideLogic.clearPointer()
	if GuideLogic.pointer then
		GuideLogic.pointer:removeFromParentAndCleanup(true)
		GuideLogic.pointer = nil
	end
end