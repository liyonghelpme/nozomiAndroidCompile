UpgradeDialog = {}

do	
	function UpgradeDialog.create(build)
		local temp, bg = nil
		bg = UI.createButton(CCSizeMake(720, 526), doNothing, {image="images/dialogBgA.png", priority=display.DIALOG_PRI, nodeChangeHandler = doNothing})
		screen.autoSuitable(bg, {screenAnchor=General.anchorCenter, scaleType = screen.SCALE_CUT_EDGE})
		UI.setShowAnimate(bg)
		temp = UI.createSpriteWithFile("images/dialogBgB.png",CCSizeMake(670, 234))
		screen.autoSuitable(temp, {x=25, y=25})
		bg:addChild(temp)
		temp = UI.createSpriteWithFile("images/dialogItemBlood.png",CCSizeMake(292, 222))
		screen.autoSuitable(temp, {x=39, y=25})
		bg:addChild(temp)
		temp = UI.createSpriteWithFile("images/dialogItemStoreLight.png",CCSizeMake(335, 368))
		screen.autoSuitable(temp, {x=-4, y=169})
		bg:addChild(temp)
		temp = UI.createButton(CCSizeMake(47, 46), display.closeDialog, {image="images/buttonClose.png"})
		screen.autoSuitable(temp, {x=683, y=492, nodeAnchor=General.anchorCenter})
		bg:addChild(temp)
		temp = UI.createLabel(StringManager.getFormatString("titleUpgrade", {level=build.buildLevel+1}), "fonts/font3.fnt", 25)
		screen.autoSuitable(temp, {nodeAnchor=General.anchorTop, x=360, y=506})
		bg:addChild(temp)
		
		local bdata = build.buildData
		local maxData = StaticData.getMaxLevelData(bdata.bid)
		local nextLevel = StaticData.getBuildData(bdata.bid, bdata.level+1)
		
		temp = Build.create(nextLevel.bid, nil, {level=nextLevel.level}):getBuildView()
		local bid = build.buildData.bid
		if bid==3006 then
			screen.autoSuitable(temp, {nodeAnchor=General.anchorBottom, x=152, y=324})
			bg:addChild(temp)
		elseif bid==3005 then
			temp:setScale(1.5/build.buildData.gridSize)
			screen.autoSuitable(temp, {nodeAnchor=General.anchorBottom, x=152, y=277})
			bg:addChild(temp)
		else
			temp:setScale(2/build.buildData.gridSize)
			screen.autoSuitable(temp, {nodeAnchor=General.anchorBottom, x=152, y=277})
			bg:addChild(temp)
		end
		
		temp = UI.createSpriteWithFile("images/dialogItemUpgradeTimeBg.png",CCSizeMake(112, 50))
        screen.autoSuitable(temp, {x=25, y=266})
        bg:addChild(temp)
        temp = UI.createLabel(StringManager.getTimeString(nextLevel.time), "fonts/font3.fnt", 20, {colorR = 255, colorG = 255, colorB = 255})
        screen.autoSuitable(temp, {x=81, y=281, nodeAnchor=General.anchorCenter})
        bg:addChild(temp)
        temp = UI.createLabel(StringManager.getString("labelUpgradeTime"), "fonts/font1.fnt", 11, {colorR = 107, colorG = 92, colorB = 39})
        screen.autoSuitable(temp, {x=81, y=302, nodeAnchor=General.anchorCenter})
        bg:addChild(temp)
		
		local itemIndex=1
		if build.addBuildUpgrade then
			local itemNum
			itemNum = build:addBuildUpgrade(bg, UI.addInfoItem2)
			if itemNum then
				itemIndex = itemIndex + itemNum
			end
		end
		UI.addInfoItem2(bg, itemIndex, bdata.hitPoints, nextLevel.hitPoints, maxData.hitPoints, "Hitpoints", nil)
		
		temp = UI.createButton(CCSizeMake(169, 76), build.beginUpgrade, {image="images/buttonGreen.png", callbackParam=build})
		screen.autoSuitable(temp, {nodeAnchor=General.anchorCenter, x=360, y=79})
		bg:addChild(temp)
		local colorSetting = {colorR=255, colorG=255, colorB=255, lineOffset=-12}
		if ResourceLogic.getResource(nextLevel.costType)<nextLevel.costValue then
		    colorSetting.colorG=0
		    colorSetting.colorB=0
		end
		local temp1 = UI.createScaleSprite("images/" .. nextLevel.costType .. ".png",CCSizeMake(50, 38))
        screen.autoSuitable(temp1, {nodeAnchor=General.anchorCenter, x=143, y=38})
        temp:addChild(temp1)
		temp1 = UI.createLabel(tostring(nextLevel.costValue), "fonts/font3.fnt", 22, colorSetting)
		screen.autoSuitable(temp1, {nodeAnchor=General.anchorRight, x=118, y=38})
		temp:addChild(temp1)
		return bg
	end

	function UpgradeDialog.show(build)
		display.showDialog(UpgradeDialog.create(build))
	end
end