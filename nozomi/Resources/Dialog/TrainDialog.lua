TrainDialog = {}

do
	local showMainTab
	
	local function showSoldierTab(param)
		local bg, temp = param.bg, nil
		local sid = param.sid
		local build = param.build
		
		local sinfo = StaticData.getSoldierInfo(sid)
		local slevel = UserData.researchLevel[sid]
		local sdata = StaticData.getSoldierData(sid, slevel)
		local mdata = StaticData.getSoldierData(sid, sinfo.levelMax)
		bg:removeAllChildrenWithCleanup(true)
		temp = UI.createSpriteWithFile("images/dialogItemBlood.png",CCSizeMake(292, 222))
		screen.autoSuitable(temp, {x=36, y=22})
		bg:addChild(temp)
		
		temp = UI.createLabel(StringManager.getString("dataSoldierInfo" .. sid), "fonts/font1.fnt", 15, {colorR = 33, colorG = 93, colorB = 165})
		screen.autoSuitable(temp, {x=361, y=78, nodeAnchor=General.anchorCenter})
		bg:addChild(temp)
		
		temp = UI.createLabel(StringManager.getFormatString("titleInfo", {name=sinfo.name, level=(UserData.researchLevel[sid] or 1)}), "fonts/font3.fnt", 25, {colorR = 255, colorG = 255, colorB = 255})
		screen.autoSuitable(temp, {x=361, y=489, nodeAnchor=General.anchorCenter})
		bg:addChild(temp)
		temp = UI.createButton(CCSizeMake(96, 49), showMainTab, {callbackParam={bg=bg, build=build}, image="images/buttonBack.png"})
		screen.autoSuitable(temp, {nodeAnchor=General.anchorCenter, x=62, y=485})
		bg:addChild(temp)
		
		SoldierHelper.addSoldierFeature(bg, sid)
		
		UI.addInfoItem(bg, 1, sdata.dps, sdata.dps, mdata.dps, "Dps")
		UI.addInfoItem(bg, 2, sdata.hitpoints,sdata.hitpoints, mdata.hitpoints, "Hitpoints")
		UI.addInfoItem(bg, 3, sdata.cost, sdata.cost, mdata.cost, "TrainFood", "images/food.png")
		
		for i=1, 6 do
			temp = UI.createSpriteWithFile("images/dialogItemInfoSeperator.png",CCSizeMake(300, 2))
			screen.autoSuitable(temp, {x=371, y=307-i*29})
			bg:addChild(temp)
		end
		
		local colorProperty = {colorR = 33, colorG = 93, colorB = 165}
		temp = UI.createLabel(StringManager.getString("propertyFavorite"), "fonts/font1.fnt", 15, colorProperty)
		screen.autoSuitable(temp, {nodeAnchor=General.anchorRightBottom, x=516, y=280})
		bg:addChild(temp)
		temp = UI.createLabel(StringManager.getString("propertyDamageType"), "fonts/font1.fnt", 15, colorProperty)
		screen.autoSuitable(temp, {nodeAnchor=General.anchorRightBottom, x=516, y=251})
		bg:addChild(temp)
		temp = UI.createLabel(StringManager.getString("propertyTargets"), "fonts/font1.fnt", 15, colorProperty)
		screen.autoSuitable(temp, {nodeAnchor=General.anchorRightBottom, x=516, y=222})
		bg:addChild(temp)
		temp = UI.createLabel(StringManager.getString("propertyHouseSpace"), "fonts/font1.fnt", 15, colorProperty)
		screen.autoSuitable(temp, {nodeAnchor=General.anchorRightBottom, x=516, y=193})
		bg:addChild(temp)
		temp = UI.createLabel(StringManager.getString("propertyTrainTime"), "fonts/font1.fnt", 15, colorProperty)
		screen.autoSuitable(temp, {nodeAnchor=General.anchorRightBottom, x=516, y=164})
		bg:addChild(temp)
		temp = UI.createLabel(StringManager.getString("propertyMoveSpeed"), "fonts/font1.fnt", 15, colorProperty)
		screen.autoSuitable(temp, {nodeAnchor=General.anchorRightBottom, x=516, y=135})
		bg:addChild(temp)
		
		colorProperty = {colorR = 0, colorG = 0, colorB = 0}
		
		local tempStr
		
		tempStr = StringManager.getString("dataBuildType" .. sinfo.favorite)
		if sinfo.favoriteRate > 1 then
			tempStr = tempStr .. StringManager.getFormatString("favoriteRate", {rate=sinfo.favoriteRate})
		end
		temp = UI.createLabel(tempStr, "fonts/font1.fnt", 15, colorProperty)
		screen.autoSuitable(temp, {nodeAnchor=General.anchorLeftBottom, x=526, y=280})
		bg:addChild(temp)
		
		if sinfo.damageRange>0 then
			tempStr = StringManager.getString("typeDamageTypeArea")
		else
			tempStr = StringManager.getString("typeDamageTypeSingle")
		end
		temp = UI.createLabel(tempStr, "fonts/font1.fnt", 15, colorProperty)
		screen.autoSuitable(temp, {nodeAnchor=General.anchorLeftBottom, x=526, y=251})
		bg:addChild(temp)
		
		if sinfo.attackType==2 then
			tempStr = StringManager.getString("typeTargets3")
		else
			tempStr = StringManager.getString("typeTargets1")
		end
		temp = UI.createLabel(tempStr, "fonts/font1.fnt", 15, colorProperty)
		screen.autoSuitable(temp, {nodeAnchor=General.anchorLeftBottom, x=526, y=222})
		bg:addChild(temp)
		
		temp = UI.createLabel(tostring(sinfo.space), "fonts/font1.fnt", 15, colorProperty)
		screen.autoSuitable(temp, {nodeAnchor=General.anchorLeftBottom, x=526, y=193})
		bg:addChild(temp)
		temp = UI.createLabel(StringManager.getTimeString(sinfo.time), "fonts/font1.fnt", 15, colorProperty)
		screen.autoSuitable(temp, {nodeAnchor=General.anchorLeftBottom, x=526, y=164})
		bg:addChild(temp)
		temp = UI.createLabel(tostring(sinfo.moveSpeed), "fonts/font1.fnt", 15, colorProperty)
		screen.autoSuitable(temp, {nodeAnchor=General.anchorLeftBottom, x=526, y=135})
		bg:addChild(temp)
	end
	
	local function addAccButton(barrack, callTable)
		local bg = callTable.view
		callTable.accNode = {}
		
		temp = UI.createLabel(StringManager.getFormatString("trainingTroop", {num=SoldierLogic.getTrainingSpace()+SoldierLogic.getCurSpace(), max=SoldierLogic.getSpaceMax()}), "fonts/font1.fnt", 12, {colorR = 0, colorG = 0, colorB = 0})
		screen.autoSuitable(temp, {x=527, y=343, nodeAnchor=General.anchorRight})
		bg:addChild(temp)
		
		callTable.accNode[1] = temp
		
		temp = UI.createButton(CCSizeMake(109, 42), barrack.accCall, {callbackParam=barrack, useExtendNode=true, image="images/buttonGreen.png"})
		screen.autoSuitable(temp, {nodeAnchor=General.anchorCenter, x=613, y=354})
		bg:addChild(temp)
		callTable.accNode[2] = temp
		callTable.accEnable = true
		
		if callTable.pt then
			callTable.pt:setRotation(-90)
			callTable.pt:setPosition(550, 357)
			--GuideLogic.pt:retain()
			--GuideLogic.pt:removeFromParentAndCleanup(false)
			--bg:addChild(
		end
		
		temp = UI.createSpriteWithFile("images/crystal.png",CCSizeMake(34, 33))
		screen.autoSuitable(temp, {x=70, y=5})
		callTable.accNode[2]:addChild(temp)
		temp = UI.createLabel("5", "fonts/font3.fnt", 25, {colorR = 255, colorG = 255, colorB = 255})
		screen.autoSuitable(temp, {x=44, y=20, nodeAnchor=General.anchorCenter})
		callTable.accNode[2]:addChild(temp)
		callTable.accNode[7] = temp
		
		if barrack.totalSpace+SoldierLogic.getCurSpace()>SoldierLogic.getSpaceMax() then
			callTable.accNode[2]:setSatOffset(-100)
			callTable.accEnable = false
		end
		
		temp = UI.createLabel(StringManager.getTimeString(math.ceil(barrack:getTotalTime())), "fonts/font3.fnt", 19, {colorR = 255, colorG = 255, colorB = 255})
		screen.autoSuitable(temp, {x=608, y=413, nodeAnchor=General.anchorCenter})
		bg:addChild(temp)
		callTable.accNode[3] = temp
		
		temp = UI.createLabel(StringManager.getString("labelTotalTime"), "fonts/font1.fnt", 12, {colorR = 0, colorG = 0, colorB = 0})
		screen.autoSuitable(temp, {x=608, y=438, nodeAnchor=General.anchorCenter})
		bg:addChild(temp)
		callTable.accNode[8] = temp
		temp = UI.createLabel(StringManager.getString("labelFinishTrain"), "fonts/font1.fnt", 12, {colorR = 0, colorG = 0, colorB = 0})
		screen.autoSuitable(temp, {x=612, y=387, nodeAnchor=General.anchorCenter})
		bg:addChild(temp)
		callTable.accNode[9] = temp
		
		temp = UI.createSpriteWithFile("images/dialogItemProcessBack.png",CCSizeMake(67, 16))
		screen.autoSuitable(temp, {x=399, y=363})
		bg:addChild(temp, 1)
		callTable.accNode[4] = temp
		temp = UI.createSpriteWithFile("images/dialogItemProcessFiller.png",CCSizeMake(65, 15))
		screen.autoSuitable(temp, {x=1, y=0})
		callTable.accNode[4]:addChild(temp)
		callTable.processSize = temp:getContentSize()
		temp:setTextureRect(CCRectMake(0, 0, 0, callTable.processSize.height))
		callTable.accNode[5] = temp
		temp = UI.createLabel(StringManager.getTimeString(math.ceil(barrack:getSingleTime())), "fonts/font3.fnt", 12, {colorR = 255, colorG = 255, colorB = 255})
		screen.autoSuitable(temp, {x=34, y=7, nodeAnchor=General.anchorCenter})
		callTable.accNode[4]:addChild(temp)
		callTable.accNode[6] = temp
	end
	
	local function callSoldier(param)
		local sid = param.sid
		local barrack = param.barrack
		if sid>barrack.buildData.level then
			display.pushNotice(UI.createNotice(StringManager.getFormatString("needLevel", {level=sid, name=StringManager.getString("dataBuildName1001")})))
		else
			local food = StaticData.getSoldierData(sid, UserData.researchLevel[sid] or 1).cost
			if ResourceLogic.checkAndCost({costType="food", costValue=food}) then
				param.barrack:callSoldier(sid)
			end
		end
	end
	
	local function cancelCallSoldier(param)
		local barrack = param.barrack
		local sid = param.sid
		barrack:cancelCallSoldier(sid)
		local food = StaticData.getSoldierData(sid, UserData.researchLevel[sid] or 1).cost
		ResourceLogic.changeResource("food", food)
	end
	
	local function resetTipsNode(bg, build)
		local tag = 101
		local tip = bg:getChildByTag(tag)
		if tip then
			tip:removeFromParentAndCleanup(true)
		end
		if build.pause then
			tip = UI.createSpriteWithFile("images/dialogItemTipsBgB.png",CCSizeMake(647, 45))
			screen.autoSuitable(tip, {x=34, y=26})
			bg:addChild(tip)
			local temp = UI.createLabel(StringManager.getString("labelCampFull"), "fonts/font3.fnt", 22, {colorR = 255, colorG = 255, colorB = 255})
			screen.autoSuitable(temp, {x=49, y=21, nodeAnchor=General.anchorLeft})
			tip:addChild(temp)
			temp = UI.createLabel(StringManager.getString("tipsTrainDialog2"), "fonts/font1.fnt", 13, {colorR = 255, colorG = 255, colorB = 255, size=CCSizeMake(344, 0)})
			screen.autoSuitable(temp, {x=466, y=22, nodeAnchor=General.anchorCenter})
			tip:addChild(temp)
		else
			tip = UI.createSpriteWithFile("images/dialogItemTipsBg.png",CCSizeMake(647, 45))
			screen.autoSuitable(tip, {x=33, y=26})
			bg:addChild(tip)
			local temp = UI.createLabel(StringManager.getString("tipsTrainDialog"), "fonts/font2.fnt", 15, {colorR = 255, colorG = 255, colorB = 255})
			screen.autoSuitable(temp, {x=335, y=22, nodeAnchor=General.anchorCenter})
			tip:addChild(temp)
		end
	end
	
	showMainTab = function(param)
		local bg, temp = param.bg, nil
		local build = param.build
		bg:removeAllChildrenWithCleanup(true)
		resetTipsNode(bg, build)
		local tipPause = build.pause
		local title = UI.createLabel("", "fonts/font3.fnt", 27, {colorR = 255, colorG = 255, colorB = 255})
		screen.autoSuitable(title, {x=365, y=491, nodeAnchor=General.anchorCenter})
		bg:addChild(title)
		temp = UI.createSpriteWithFile("images/dialogItemTrainQueue.png",CCSizeMake(280, 96))
		screen.autoSuitable(temp, {x=251, y=351})
		bg:addChild(temp)
		
		local soldierButtons = {}
		local costItems = {}
		local barrack = build
		local callTable = {}
		
		local function updateCallList()
			title:setString(StringManager.getFormatString("titleBarrack", {num=barrack.totalSpace, max=build.buildData.extendValue1}))
			local leftFood = ResourceLogic.getResource("food")
			local leftSpace = build.buildData.extendValue1-barrack.totalSpace
			for i=1, #costItems do
				local item = costItems[i]
				local foodOk = item.foodValue<=leftFood
				if foodOk~=item.foodOk then
					item.foodOk = foodOk
					if foodOk then
						item.foodNode:setColor(ccc3(255, 255, 255))
					else
						item.foodNode:setColor(ccc3(255, 0, 0))
					end
				end
				local spaceOk = item.spaceValue<=leftSpace
				if spaceOk~=item.spaceOk then
					item.spaceOk = spaceOk
					if spaceOk then
						item.spaceNode:setSatOffset(0)
					else
						item.spaceNode:setSatOffset(-100)
					end
				end
			end
			local callList = barrack.callList
			if tipPause ~= barrack.pause then
				tipPause = barrack.pause
				resetTipsNode(bg, barrack)
			end
			if barrack.totalSpace>0 then
				if not callTable.view then
					callTable.view = CCNode:create()
					bg:addChild(callTable.view)
					callTable.accNode = nil
					callTable.queue={}
					callTable.pause = true
				end
				if callTable.pause ~= barrack.pause then
					callTable.pause = barrack.pause
					if not barrack.pause then
						addAccButton(barrack, callTable)
					elseif callTable.accNode then
						for i=1, 4 do
							callTable.accNode[i]:removeFromParentAndCleanup(true)
						end
						for i=8, 9 do
							callTable.accNode[i]:removeFromParentAndCleanup(true)
						end
						callTable.accNode = nil
					end
				elseif not callTable.pause and callTable.accNode then
					callTable.accNode[1]:setString(StringManager.getFormatString("trainingTroop", {num=SoldierLogic.getTrainingSpace()+SoldierLogic.getCurSpace(), max=SoldierLogic.getSpaceMax()}))
					callTable.accNode[3]:setString(StringManager.getTimeString(math.ceil(barrack:getTotalTime())))
					
					local singleTime = barrack:getSingleTime()
					local singleTotalTime = callList[1].perTime
					callTable.accNode[5]:setTextureRect(CCRectMake(0, 0, callTable.processSize.width*(singleTotalTime-singleTime)/singleTotalTime, callTable.processSize.height))
					callTable.accNode[6]:setString(StringManager.getTimeString(math.ceil(singleTime)))
						
					if barrack.totalSpace+SoldierLogic.getCurSpace()>SoldierLogic.getSpaceMax() == callTable.accEnable then
						if callTable.accEnable then
							callTable.accNode[2]:setSatOffset(-100)
						else
							callTable.accNode[2]:setSatOffset(0)
						end
						callTable.accEnable = not callTable.accEnable
					end
				end
				local tempDict = {}
				for i=1, #callList do
					tempDict[callList[i].sid] = i
				end
				for i=1, 10 do
					local qIndex = tempDict[i] or 0
					if qIndex>0 and qIndex<=5 then
						local queueItem = callTable.queue[i]
						if not queueItem then
							queueItem = {qIndex=qIndex}
							callTable.queue[i] = queueItem
							temp = CCNode:create()
							temp:setContentSize(CCSizeMake(71, 68))
							screen.autoSuitable(temp, {x=481-qIndex*83, y=368})
							callTable.view:addChild(temp)
							queueItem.view = temp
							SoldierHelper.addSoldierHead(queueItem.view, i, 0.6)
							temp = UI.createSpecialButton(CCSizeMake(27, 30), cancelCallSoldier, {callbackParam={sid=i, barrack=barrack}, image="images/dialogItemCancel.png", parentTouch=true})
							screen.autoSuitable(temp, {nodeAnchor=General.anchorCenter, x=57, y=61})
							queueItem.view:addChild(temp)
							
							temp = UI.createLabel("","fonts/font3.fnt",18)
							screen.autoSuitable(temp, {x=-1, y=64, nodeAnchor=General.anchorLeft})
							queueItem.view:addChild(temp)
							queueItem.num1 = temp
							temp = UI.createLabel("","fonts/font3.fnt",18)
							screen.autoSuitable(temp, {x=12, y=88})
							soldierButtons[i]:addChild(temp)
							queueItem.num2 = temp
						elseif queueItem.qIndex ~= qIndex then
							queueItem.qIndex = qIndex
							screen.autoSuitable(queueItem.view, {x=478-qIndex*87, y=370})
						end
						
						if queueItem.num ~= callList[qIndex].num then
							queueItem.num = callList[qIndex].num
							queueItem.num1:setString(queueItem.num .. "x")
							queueItem.num2:setString(queueItem.num .. "x")
						end
					elseif callTable.queue[i] then
						callTable.queue[i].view:removeFromParentAndCleanup(true)
						callTable.queue[i].num2:removeFromParentAndCleanup(true)
						callTable.queue[i] = nil
					end
				end
			elseif callTable.view then
				callTable.view:removeFromParentAndCleanup(true)
				callTable.view = nil
				for i=1, 10 do
					if callTable.queue[i] and callTable.queue[i].num2 then
						callTable.queue[i].num2:removeFromParentAndCleanup(true)
						callTable.queue[i] = nil
					end
				end
			end
		end
		
		local updateView = CCNode:create()
		simpleRegisterEvent(updateView, {update={callback=updateCallList, inteval=0.1}})
		bg:addChild(updateView)
		
		for i=1, 10 do
			local img = "images/dialogItemTrainButton.png"
			if i>build.buildLevel then
				img = "images/dialogItemUnlock.png"
			end
			soldierButton = UI.createSpecialButton(CCSizeMake(118, 114), callSoldier, {callbackParam={barrack=barrack, sid=i}, image=img})
			screen.autoSuitable(soldierButton, {nodeAnchor=General.anchorCenter, x=99 + (i-1)%5*127, y=397 - math.ceil(i/5)*128})
			bg:addChild(soldierButton)
			soldierButtons[i] = soldierButton
			
			local head = SoldierHelper.addSoldierHead(soldierButton, i, 1)
			
			temp = UI.createButton(CCSizeMake(9, 24), showSoldierTab, {image="images/dialogItemInfo.png", callbackParam={bg=bg, sid=i,build=build}}) --, useExtendNode=true
			screen.autoSuitable(temp, {nodeAnchor=General.anchorCenter, x=101, y=95})
			soldierButton:addChild(temp)
			
			if i>build.buildLevel then
				temp =  UI.createLabel(StringManager.getFormatString("needLevel", {level=i, name=StringManager.getString("dataBuildName" .. build.buildData.bid)}), "fonts/font2.fnt", 11, {size=CCSizeMake(57, 49)})
				screen.autoSuitable(temp, {x=59, y=37, nodeAnchor=General.anchorCenter})
				soldierButton:addChild(temp)
				
				soldierButton:setSatOffset(-100)
				head:setOpacity(204)
			else
				temp = UI.createSpriteWithFile("images/dialogItemPriceBg.png",CCSizeMake(101, 27))
				screen.autoSuitable(temp, {x=7, y=7})
				soldierButton:addChild(temp)
				
				local slevel = UserData.researchLevel[i]
				for i=1, slevel do
					temp = UI.createSpriteWithFile("images/soldierStar.png",CCSizeMake(17, 17))
					screen.autoSuitable(temp, {x=14*i-6, y=33})
					soldierButton:addChild(temp)
				end
				
				local food = StaticData.getSoldierData(i, slevel).cost
				
				temp = UI.createSpriteWithFile("images/food.png",CCSizeMake(18, 24))
				screen.autoSuitable(temp, {x=88, y=9})
				soldierButton:addChild(temp)
				temp = UI.createLabel(tostring(food), "fonts/font3.fnt", 17, {colorR = 255, colorG = 255, colorB = 255})
				screen.autoSuitable(temp, {x=80, y=21, nodeAnchor=General.anchorRight})
				soldierButton:addChild(temp)
				local item = {foodValue=food, foodOk=true, foodNode=temp, spaceValue=StaticData.getSoldierInfo(i).space, spaceOk=true, spaceNode = soldierButton}
				costItems[i] = item
			end
		end
		if not GuideLogic.complete then
			local setting = GuideLogic.pointerSetting
			if setting and setting[1]=="build" and setting[2]==1001 then
				local pt = UI.createGuidePointer(0)
				local x, y = soldierButtons[1]:getPosition()
				pt:setScale(0.5)
				pt:setPosition(x, y+60)
				bg:addChild(pt)
				callTable.pt = pt
			end
		end
		updateCallList()
	end
	
	function TrainDialog.show(build)
		local temp, bg = nil
		bg = UI.createButton(CCSizeMake(720, 526), doNothing, {image="images/dialogBgA.png", priority=display.DIALOG_PRI, nodeChangeHandler = doNothing})
		screen.autoSuitable(bg, {screenAnchor=General.anchorCenter, scaleType = screen.SCALE_CUT_EDGE})
		
		UI.setShowAnimate(bg)
		
		temp = UI.createButton(CCSizeMake(47, 46), display.closeDialog, {image="images/buttonClose.png"})
		screen.autoSuitable(temp, {x=682, y=489, nodeAnchor=General.anchorCenter})
		bg:addChild(temp)
		
		local tabView = CCNode:create()
		bg:addChild(tabView)
		
		showMainTab({bg=tabView, build=build})
		display.showDialog(bg)
	end
end