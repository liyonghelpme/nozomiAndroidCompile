ResearchDialog = {}

do
	local showMainTab
	
	local function upgradeResearch(param)
			-- test
			UserData.soldier1Level = UserData.soldier1Level+1
			display.closeDialog()
	end
	
	local function showSoldierUpgradeTab(param)
		local bg, temp = param.bg, nil
		local lid = param.id
		if UserData.soldier1Level==2 then
			display.pushNotice(UI.createNotice("Level " .. 3 .. " Laboratory required"))
		else
			bg:removeAllChildrenWithCleanup(true)
			temp = UI.createLabel(StringManager.getFormatString("titleUpgrade", {level=UserData.soldier1Level+1}), General.specialFont, 24)
			screen.autoSuitable(temp, {nodeAnchor=General.anchorCenter, x=341, y=483})
			bg:addChild(temp)
			
			temp = UI.createButton(CCSizeMake(175, 77), upgradeResearch, {callbackParam={bg=bg, id=lid}, image="images/buttonTest.png"})
			screen.autoSuitable(temp, {nodeAnchor=General.anchorCenter, x=341, y=72})
			bg:addChild(temp)
			local temp1 = UI.createLabel("50000 food", General.defaultFont, 24)
			screen.autoSuitable(temp1, {nodeAnchor=General.anchorCenter, x=87, y=38})
			temp:addChild(temp1)
			temp = UI.createLabel("",General.defaultFont, 20)
			screen.autoSuitable(temp, {x=28, y=97})
			bg:addChild(temp)
			temp = UI.createButton(CCSizeMake(124, 48), showMainTab, {callbackParam=bg, image="images/buttonTest.png", text=StringManager.getString("buttonBack"), fontSize=30, fontName=General.specialFont})
			screen.autoSuitable(temp, {nodeAnchor=General.anchorCenter, x=88, y=477})
			bg:addChild(temp)
		end
	end
	
	showMainTab = function(bg)
		local temp = nil
		bg:removeAllChildrenWithCleanup(true)
		
		temp = UI.createLabel(StringManager.getString("titleResearch"), General.specialFont, 24)
		screen.autoSuitable(temp, {x=359, y=481, nodeAnchor=General.anchorCenter})
		bg:addChild(temp)
		
		local barrackLevel = display.getCurrentScene():getMaxLevel(1001)
		local nozomiLevel = display.getCurrentScene():getMaxLevel(1)
		local labLevel = display.getCurrentScene():getMaxLevel(1002)
		
		for i=1, 15 do
			local item
			if i<=10 then
				if i>barrackLevel then
					item = UI.createSpriteWithFile("images/dialogItemUnlock.png", CCSizeMake(117, 114))
				else
					item = UI.createButton(CCSizeMake(117, 114), showSoldierUpgradeTab, {callbackParam={bg=bg, id=i}, image="images/dialogItemTrainButton.png", useExtendNode=true})
					SoldierHelper.addSoldierHead(item, i, 1)
					
					local sinfo = StaticData.getSoldierInfo(i)
					local slevel = UserData.researchLevel[i]
					local rinfo = StaticData.getResearchInfo(i, slevel+1)
					
					for i=1, slevel do
						temp = UI.createSpriteWithFile("images/soldierStar.png",CCSizeMake(17, 17))
						screen.autoSuitable(temp, {x=18*i-10, y=88})
						item:addChild(temp)
					end
					
					temp = UI.createSpriteWithFile("images/dialogItemPriceBg.png",CCSizeMake(101, 27))
					screen.autoSuitable(temp, {x=7, y=7})
					item:addChild(temp)
					if not rinfo then
						temp =  UI.createLabel(StringManager.getString("maxLevel"), "fonts/font1.fnt", 11, {size=CCSizeMake(57, 49)})
						screen.autoSuitable(temp, {x=59, y=36, nodeAnchor=General.anchorCenter})
						item:addChild(temp)
					elseif rinfo.requireLevel>labLevel then
						temp:setScaleY(1.5)
						temp =  UI.createLabel(StringManager.getFormatString("needLevel", {level=rinfo.requireLevel, name=StringManager.getString("dataBuildName1002")}), "fonts/font1.fnt", 11, {size=CCSizeMake(57, 49)})
						screen.autoSuitable(temp, {x=59, y=36, nodeAnchor=General.anchorCenter})
						item:addChild(temp)
						item:setSatOffset(-100)
					else
						local food = rinfo.cost
						temp = UI.createResourceNode("food", food, 23, {fontOffY=-2})
						screen.autoSuitable(temp, {nodeAnchor=General.anchorRight, x=107, y=22})
						item:addChild(temp)
					end
				end
			else
				item = UI.createSpriteWithFile("images/dialogItemUnlock.png", CCSizeMake(117, 114))
			end
			screen.autoSuitable(item, {nodeAnchor=General.anchorCenter, x=104+(i-1)%5*127, y=489-math.ceil(i/5)*128})
			bg:addChild(item)
		end
	end
	
	function ResearchDialog.create()
		local temp, bg = nil
		bg = UI.createButton(CCSizeMake(720, 523), doNothing, {image="images/dialogBgA.png", priority=display.DIALOG_PRI, nodeChangeHandler = doNothing})
		screen.autoSuitable(bg, {screenAnchor=General.anchorCenter, scaleType = screen.SCALE_CUT_EDGE})
		
		UI.setShowAnimate(bg)
		temp = UI.createButton(CCSizeMake(47, 46), display.closeDialog, {image="images/buttonClose.png"})
		screen.autoSuitable(temp, {x=674, y=484, nodeAnchor=General.anchorCenter})
		bg:addChild(temp)
		
		local tabView = CCNode:create()
		bg:addChild(tabView)
		
		showMainTab(tabView)
		
		return bg
	end

end