StoreDialog = {}

do
	local function buyBuild(info)
		if info.bid then
			EventManager.sendMessage("EVENT_BUY_BUILD", info.bid)
		else
			display.closeDialog()
			UserData.shieldTime = timer.getTime() + info.time
		end
	end
	
	local showMainTab, updateFlipCell, updateFlip = nil
	
	local function updateStoreCell(cell, scrollView, info)
		local bg, temp = cell
		bg:removeAllChildrenWithCleanup(true)
		
		temp = UI.createSpriteWithFile("images/dialogItemButtonStore.png",CCSizeMake(286, 236), true)
		screen.autoSuitable(temp, {x=0, y=0})
		bg:addChild(temp)
		local tp1 = temp
		temp = UI.createSpriteWithFile("images/dialogItemStoreLight.png",CCSizeMake(297, 326))
		screen.autoSuitable(temp, {x=148, y=132, nodeAnchor=General.anchorCenter})
		cell:addChild(temp)
		if info.bid then
			if not GuideLogic.complete then
				local setting = GuideLogic.pointerSetting
				if setting and setting[2]=="shop" and setting[4][info.bid] then
					local pt = UI.createGuidePointer(-45)
					pt:setPosition(70, 165)
					pt:setScale(0.5)
					tp1:addChild(pt)
				end
			end
			
			local b = Build.create(info.bid, nil, {level=1})
			temp = b:getBuildView()
			local sc = squeeze(2/b.buildData.gridSize, 0, 1)
			temp:setScale(sc)
			screen.autoSuitable(temp, {nodeAnchor=General.anchorBottom, x=143, y=65})
			bg:addChild(temp)
			if info.levelLimit==0 then
				temp = UI.createLabel(StringManager.getFormatString("needLevel", {level=info.nextLevel, name=StringManager.getString("dataBuildName" .. TOWN_BID)}), General.defaultFont, 20, {colorR = 255, colorG = 255, colorB = 255})
				screen.autoSuitable(temp, {nodeAnchor=General.anchorCenter, x=143, y=79})
				bg:addChild(temp)
			else
				temp = UI.createSpriteWithFile("images/dialogItemTime.png",CCSizeMake(26, 37))
				screen.autoSuitable(temp, {x=14, y=58})
				bg:addChild(temp)
				temp = UI.createLabel(StringManager.getTimeString(info.time), "fonts/font3.fnt", 20, {colorR = 255, colorG = 255, colorB = 204})
				screen.autoSuitable(temp, {x=45, y=75, nodeAnchor=General.anchorLeft})
				bg:addChild(temp)
				temp = UI.createLabel(StringManager.getString("labelBuilt"), "fonts/font1.fnt", 13, {colorR = 255, colorG = 255, colorB = 255})
				screen.autoSuitable(temp, {x=264, y=92, nodeAnchor=General.anchorRight})
				bg:addChild(temp)
				temp = UI.createLabel(info.buildsNum .. "/" .. info.levelLimit, "fonts/font3.fnt", 20, {colorR = 179, colorG = 248, colorB = 255})
				screen.autoSuitable(temp, {x=262, y=74, nodeAnchor=General.anchorRight})
				bg:addChild(temp)
			end
		else
			temp = UI.createSpriteWithFile("images/storeItemShield" .. info.id .. ".png")
			screen.autoSuitable(temp, {x=142, y=64, nodeAnchor=General.anchorBottom})
			bg:addChild(temp)
			temp = UI.createLabel(StringManager.getString("labelColddown"), "fonts/font2.fnt", 15, {colorR = 255, colorG = 255, colorB = 255})
			screen.autoSuitable(temp, {x=14, y=93, nodeAnchor=General.anchorLeft})
			bg:addChild(temp)
			temp = UI.createLabel(StringManager.getTimeString(info.time), "fonts/font3.fnt", 21, {colorR = 255, colorG = 204, colorB = 0})
			screen.autoSuitable(temp, {x=16, y=72, nodeAnchor=General.anchorLeft})
			bg:addChild(temp)
		end
		temp = UI.createLabel(info.name, "fonts/font3.fnt", 20, {colorR = 255, colorG = 255, colorB = 204})
		screen.autoSuitable(temp, {x=142, y=209, nodeAnchor=General.anchorCenter})
		bg:addChild(temp)
		temp = UI.createSpriteWithFile("images/dialogItemBgCost.png",CCSizeMake(264, 46))
		screen.autoSuitable(temp, {x=10, y=10})
		bg:addChild(temp)
		temp = UI.createLabel(tostring(info.costValue), "fonts/font3.fnt", 20, {colorR = 255, colorG = 255, colorB = 255})
		screen.autoSuitable(temp, {x=142, y=33, nodeAnchor=General.anchorCenter})
		bg:addChild(temp)
		local w = temp:getContentSize().width/2 * temp:getScaleX()
		temp = UI.createScaleSprite("images/" .. info.costType .. ".png",CCSizeMake(34, 34))
		screen.autoSuitable(temp, {x=145+w, y=16})
		bg:addChild(temp)
		scrollView:addChildTouchNode(bg, buyBuild, info)
		if info.info then
			temp = UI.createSpriteWithFile("images/dialogItemButtonInfo.png",CCSizeMake(38, 40))
			screen.autoSuitable(temp, {nodeAnchor=General.anchorCenter, x=248, y=205})
			bg:addChild(temp)
			scrollView:addChildTouchNode(temp, updateFlip, {bg=bg, scrollView=scrollView, info=info, cellUpdate=updateFlipCell})
		end
		if info.buildsNum and info.buildsNum >= info.levelLimit then
			bg:setSatOffset(-100)
		end
	end
	
	updateFlipCell = function (cell, scrollView, info)
		local bg, temp = cell
		bg:removeAllChildrenWithCleanup(true)
		
		temp = UI.createSpriteWithFile("images/dialogItemButtonStore.png",CCSizeMake(286, 236))
		screen.autoSuitable(temp, {x=0, y=0})
		bg:addChild(temp)
		
		temp = UI.createLabel(info.name, General.defaultFont, 25, {colorR = 255, colorG = 255, colorB = 255})
		screen.autoSuitable(temp, {nodeAnchor=General.anchorLeft, x=55, y=207})
		bg:addChild(temp)
		
		temp = UI.createLabel(info.info, General.defaultFont, 20, {colorR = 255, colorG = 255, colorB = 255, size=CCSizeMake(270, 170), align=kCCTextAlignmentLeft, valign=kCCVerticalTextAlignmentTop})
		screen.autoSuitable(temp, {nodeAnchor=General.anchorCenter, x=143, y=93})
		bg:addChild(temp)
		
		scrollView:addChildTouchNode(bg, updateFlip, {bg=bg, scrollView=scrollView, info=info, cellUpdate=updateStoreCell})
	end
	
	local function flipCallback(param)
		param.cellUpdate(param.bg, param.scrollView, param.info)
	end
	
	updateFlip = function(param)
		local bg, scrollView, info = param.bg, param.scrollView, param.info
		local flips = CCArray:create()
		local flipTime = getParam("flipTime", 100)/1000
		flips:addObject(CCScaleTo:create(flipTime, 0, 1))
		flips:addObject(CCScaleTo:create(flipTime, 1, 1))
		bg:runAction(CCSequence:create(flips))
		delayCallback(flipTime, flipCallback, param)
	end
	
	local function showStoreTab(param)
		local bg, temp = param.bg
		bg:removeAllChildrenWithCleanup(true)
		
		local infos = param.infos
		local scrollView = UI.createScrollViewAuto(CCSizeMake(1024/(General.winSize.height/768), 512), true, {size=CCSizeMake(286, 236), offx=55, offy=11, disx=28, disy=18, rowmax=2, infos=infos, cellUpdate=param.updateStoreCell or updateStoreCell})
		screen.autoSuitable(scrollView.view, {scaleType=screen.SCALE_HEIGHT_FIRST, screenAnchor=General.anchorLeft})
		bg:addChild(scrollView.view)
		
		if param.needBack then
			temp = UI.createButton(CCSizeMake(107, 51), showMainTab, {callbackParam=bg, image="images/buttonBack.png"})
			screen.autoSuitable(temp, {scaleType=screen.SCALE_HEIGHT_FIRST, screenAnchor=General.anchorLeftTop, x=79, y=-47, nodeAnchor=General.anchorCenter})
			bg:addChild(temp)
		end
        temp = UI.createLabel(param.title, "fonts/font3.fnt", 40, {colorR = 255, colorG = 255, colorB = 255})
        screen.autoSuitable(temp, {scaleType=screen.SCALE_HEIGHT_FIRST, screenAnchor=General.anchorTop, x=0, y=-32, nodeAnchor=General.anchorTop})
        bg:addChild(temp)
	end
	
	local function updateTreasureCell(cell, scrollView, info)
		local bg, temp = cell
		bg:removeAllChildrenWithCleanup(true)
		
		temp = UI.createSpriteWithFile("images/dialogItemButtonStore.png", CCSizeMake(283, 235))
		screen.autoSuitable(temp, {x=0, y=0})
		bg:addChild(temp)
		temp = UI.createSpriteWithFile("images/dialogItemStoreLight.png",CCSizeMake(297, 326))
		screen.autoSuitable(temp, {x=148, y=132, nodeAnchor=General.anchorCenter})
		bg:addChild(temp)
		
		if info.img then
			temp = UI.createSpriteWithFile(info.img)
			screen.autoSuitable(temp, {nodeAnchor=General.anchorCenter, x=142, y=118})
			bg:addChild(temp)
		end
		
		temp = UI.createSpriteWithFile("images/dialogItemBgCost.png",CCSizeMake(264, 46))
		screen.autoSuitable(temp, {x=10, y=10})
		bg:addChild(temp)
		
		if info.resource=="crystal" then
			temp = UI.createLabel(tostring(info.cost), "fonts/font3.fnt", 20, {colorR = 255, colorG = 255, colorB = 255})
			screen.autoSuitable(temp, {x=142, y=31, nodeAnchor=General.anchorCenter})
			bg:addChild(temp)
			temp = UI.createLabel(info.text, "fonts/font3.fnt", 20, {colorR = 252, colorG = 186, colorB = 255})
			screen.autoSuitable(temp, {x=142, y=213, nodeAnchor=General.anchorCenter})
			bg:addChild(temp)
			
			temp = UI.createLabel(tostring(info.get), "fonts/font3.fnt", 20, {colorR = 255, colorG = 255, colorB = 255})
			screen.autoSuitable(temp, {x=134, y=186, nodeAnchor=General.anchorLeft})
			bg:addChild(temp)
			temp = UI.createSpriteWithFile("images/crystal.png",CCSizeMake(34, 33))
			screen.autoSuitable(temp, {x=100, y=171})
			bg:addChild(temp)
			
			scrollView:addChildTouchNode(bg, CrystalLogic.buyCrystal, info)
		else
			temp = UI.createLabel(tostring(info.cost), "fonts/font3.fnt", 20, {colorR = 255, colorG = 255, colorB = 255})
			screen.autoSuitable(temp, {x=142, y=31, nodeAnchor=General.anchorCenter})
			bg:addChild(temp)
			local w = temp:getContentSize().width/2 * temp:getScaleX()
			temp = UI.createSpriteWithFile("images/crystal.png",CCSizeMake(34, 33))
			screen.autoSuitable(temp, {x=145+w, y=16})
			bg:addChild(temp)
			
			temp = UI.createLabel(info.text, "fonts/font3.fnt", 20, {colorR = 255, colorG = 255, colorB = 204})
			screen.autoSuitable(temp, {x=142, y=213, nodeAnchor=General.anchorCenter})
			bg:addChild(temp)
			temp = UI.createLabel(info.get .. " " .. StringManager.getString(info.resource), "fonts/font3.fnt", 20, {colorR = 255, colorG = 255, colorB = 255})
			screen.autoSuitable(temp, {x=142, y=186, nodeAnchor=General.anchorCenter})
			bg:addChild(temp)
			scrollView:addChildTouchNode(bg, CrystalLogic.buyResource, info)
		end
	end
	
	local function showTreasureTab(param)
		local infos = {}
		local crystals = {500, 1200, 2500, 6500, 14000}
		local TEST_INFO = {4.99, 9.99, 19.99, 49.99, 99.99}
		for i=1, 5 do
			-- in app pay
			local info = {resource="crystal", cost=TEST_INFO[i], get=crystals[i], text=StringManager.getString("storeItemCrystal" .. i), img="images/storeItemCrystal" .. i .. ".png"}
			if i==1 then info.img = nil end
			table.insert(infos, info)
		end
		
		local types = {"food", "oil"}
		local tmap = {food="Food", oil="Oil"}
		for i=1, #types do	
			local resourceType = types[i]
			local num = ResourceLogic.getResource(resourceType)
			local max = ResourceLogic.getResourceMax(resourceType)
			
			local prefix = "images/storeItem" .. tmap[resourceType]
			if num*10/9<max then
				local info = {resource=resourceType, get=max/10, text=StringManager.getString("storeItemResource1"), img=prefix .. "1.png"}
				info.cost = CrystalLogic.computeCostByResource(resourceType, info.get)
				table.insert(infos, info)
			end
			if num*2<max then
				local info = {resource=resourceType, get=max/2, text=StringManager.getString("storeItemResource2"), img=prefix .. "2.png"}
				info.cost = CrystalLogic.computeCostByResource(resourceType, info.get)
				table.insert(infos, info)
			end
			if num<max then
				local info = {resource=resourceType, get=max-num, text=StringManager.getFormatString("storeItemResource3", {name=StringManager.getString(resourceType)}), img=prefix .. "3.png"}
				info.cost = CrystalLogic.computeCostByResource(resourceType, info.get)
				table.insert(infos, info)
			end
		end
		
		param.infos = infos
		param.updateStoreCell=updateTreasureCell
		showStoreTab(param)
	end
	
	local function showBuildTab(param)
		param.infos = Build.getBuildStoreInfo(param.bids)
		showStoreTab(param)
	end
	
	local function showShieldTab(param)
		param.infos = {{id=1, name="1 day", time=86400, info="1 day shield", costType="crystal", costValue=100}, {id=2, name="2 day", time=172800, info="2 day shield", costType="crystal", costValue=150}, {id=3, name="1 week", time=604800, info="1 week shield", costType="crystal", costValue=250}}
		showStoreTab(param)
	end
	
	-- 注意：1-6的ID实际对应1\4\2\5\3\6
	local function updateMainTabCell(cell, scrollView, info)
		cell:removeAllChildrenWithCleanup(true)
		local temp
		temp = UI.createSpriteWithFile("images/dialogItemButtonStore.png", CCSizeMake(283, 235))
		screen.autoSuitable(temp, {x=0, y=0})
		cell:addChild(temp)
		
		local tid = math.ceil(info.id/2)+(info.id-1)%2*3
		info.tid = tid
		
		if not GuideLogic.complete then
			local setting = GuideLogic.pointerSetting
			if setting and setting[2]=="shop" and tid==setting[3] then
				local pt = UI.createGuidePointer(-45)
				pt:setPosition(70, 165)
				pt:setScale(0.5)
				temp:addChild(pt)
			end
		end
		
		temp = UI.createSpriteWithFile("images/dialogItemStoreLight.png",CCSizeMake(297, 326))
		screen.autoSuitable(temp, {x=148, y=132, nodeAnchor=General.anchorCenter})
		cell:addChild(temp)
		
		local cellImg = "images/storeItem" .. tid .. ".png"
		if tid==6 then
			cellImg = "images/storeItemShield1.png"
		end
		temp = UI.createSpriteWithFile(cellImg)
		screen.autoSuitable(temp, {x=142, y=128, nodeAnchor=General.anchorCenter})
		cell:addChild(temp)
		
		temp = UI.createSpriteWithFile("images/dialogItemStoreRibbon.png",CCSizeMake(297, 93))
		screen.autoSuitable(temp, {x=-5, y=-4})
		cell:addChild(temp)
		
		info.title = StringManager.getString("titleStoreItem" .. tid)
		temp = UI.createLabel(info.title, "fonts/font3.fnt", 25, {colorR = 255, colorG = 255, colorB = 255})
		screen.autoSuitable(temp, {x=142, y=47, nodeAnchor=General.anchorCenter})
		cell:addChild(temp)
		
		callback = nil
		
		if info.tid==6 then
			callback = showShieldTab
		elseif info.tid==1 then
			callback = showTreasureTab
		else
			if info.tid==2 then
				info.bids = {2000, 2001, 2002, 2006, 2004, 2005}
			elseif info.tid==4 then
				info.bids = {1000, 1001, 1002}
			elseif info.tid==5 then
				info.bids = {3000, 3001, 3002, 3003, 3004, 3005, 3006, 3007, 5000, 5001, 5002}
			else
				info.bids = {}
			end
			callback = showBuildTab
		end
		scrollView:addChildTouchNode(cell, callback, info)
	end
	
	showMainTab = function (tabView)
		local bg, temp = tabView, nil
		bg:removeAllChildrenWithCleanup(true)
		
		local infos = {}
		for i = 1, 6 do
			infos[i] = {id=i, bg=bg, needBack=true}
		end
		local scrollView = UI.createScrollViewAuto(CCSizeMake(1024, 518), true, {size=CCSizeMake(283, 235), offx=56, offy=5, disx=32, disy=30, rowmax=2, infos=infos, cellUpdate=updateMainTabCell})

		screen.autoSuitable(scrollView.view, {scaleType=screen.SCALE_CUT_EDGE, screenAnchor=General.anchorCenter})
		bg:addChild(scrollView.view)
		
		temp = UI.createLabel(StringManager.getString("titleStore"), "fonts/font3.fnt", 40, {colorR = 255, colorG = 255, colorB = 255})
		screen.autoSuitable(temp, {scaleType=screen.SCALE_HEIGHT_FIRST, screenAnchor=General.anchorTop, x=0, y=-47, nodeAnchor=General.anchorCenter})
		bg:addChild(temp)
		return bg
	end
	
	function StoreDialog.getBottomView()
		local bg, temp
		bg = CCNode:create()
		bg:setContentSize(CCSizeMake(1024,64))
		screen.autoSuitable(bg, {scaleType=screen.SCALE_HEIGHT_FIRST, screenAnchor=General.anchorBottom})
		
		temp = UI.createSpriteWithFile("images/dialogItemBgResource2.png",CCSizeMake(167, 36))
		screen.autoSuitable(temp, {x=719, y=30})
		bg:addChild(temp)
        temp = UI.createSpriteWithFile("images/crystal.png",CCSizeMake(55, 54))
        screen.autoSuitable(temp, {x=844, y=19})
        bg:addChild(temp)
		temp = UI.createLabel(tostring(UserData.crystal), "fonts/font3.fnt", 20, {colorR = 255, colorG = 255, colorB = 255})
		screen.autoSuitable(temp, {x=840, y=47, nodeAnchor=General.anchorRight})
		bg:addChild(temp)
        temp = UI.createSpriteWithFile("images/dialogItemBgResource1.png",CCSizeMake(167, 36))
        screen.autoSuitable(temp, {x=530, y=30})
        bg:addChild(temp)
		temp = UI.createLabel(tostring(ResourceLogic.getResource("person")), "fonts/font3.fnt", 20, {colorR = 255, colorG = 255, colorB = 255})
		screen.autoSuitable(temp, {x=657, y=45, nodeAnchor=General.anchorRight})
		bg:addChild(temp)
        temp = UI.createSpriteWithFile("images/person.png",CCSizeMake(67, 52))
        screen.autoSuitable(temp, {x=649, y=22})
        bg:addChild(temp)
		temp = UI.createSpriteWithFile("images/dialogItemBgResource1.png",CCSizeMake(167, 36))
		screen.autoSuitable(temp, {x=344, y=31})
		bg:addChild(temp)
        temp = UI.createSpriteWithFile("images/oil.png",CCSizeMake(46, 52))
        screen.autoSuitable(temp, {x=477, y=24})
        bg:addChild(temp)
		temp = UI.createLabel(tostring(ResourceLogic.getResource("oil")), "fonts/font3.fnt", 20, {colorR = 255, colorG = 255, colorB = 255})
		screen.autoSuitable(temp, {x=472, y=47, nodeAnchor=General.anchorRight})
		bg:addChild(temp)
		temp = UI.createSpriteWithFile("images/dialogItemBgResource1.png",CCSizeMake(167, 36))
		screen.autoSuitable(temp, {x=155, y=30})
		bg:addChild(temp)
        temp = UI.createSpriteWithFile("images/food.png",CCSizeMake(43, 58))
        screen.autoSuitable(temp, {x=286, y=21})
        bg:addChild(temp)
		temp = UI.createLabel(tostring(ResourceLogic.getResource("food")), "fonts/font3.fnt", 20, {colorR = 255, colorG = 255, colorB = 255})
		screen.autoSuitable(temp, {x=276, y=47, nodeAnchor=General.anchorRight})
		bg:addChild(temp)
		return bg
	end
	
	function StoreDialog.show(param)
		local temp, bg = nil
		bg = UI.createButton(General.winSize, doNothing, {image="images/dialogBgStore.png", priority=display.DIALOG_PRI, nodeChangeHandler = doNothing})

        temp = UI.createButton(CCSizeMake(57, 56), display.closeDialog, {image="images/buttonClose.png"})
        screen.autoSuitable(temp, {scaleType=screen.SCALE_HEIGHT_FIRST, screenAnchor=General.anchorRightTop, x=-47, y=-45, nodeAnchor=General.anchorCenter})
        bg:addChild(temp)
		bg:addChild(StoreDialog.getBottomView())
		
		local tabView = CCNode:create()
		tabView:setContentSize(General.winSize)
		
		if not param then
			showMainTab(tabView)
		elseif param=="builders" then
			local tabParam = {bg=tabView, title=StringManager.getString("titleBuilders"), bids={2004}}
			showBuildTab(tabParam)
		elseif param=="shield" then
			local tabParam = {bg=tabView, title=StringManager.getString("titleStoreItem6")}
			showShieldTab(tabParam)
		elseif param=="treasure" then
			local tabParam = {bg=tabView, title=StringManager.getString("titleStoreItem1")}
			showTreasureTab(tabParam)
		end
		bg:addChild(tabView)
		display.showDialog({view=bg})
	end
end