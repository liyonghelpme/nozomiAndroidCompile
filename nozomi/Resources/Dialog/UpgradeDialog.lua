UpgradeDialog = {}

do
	UpgradeItem = {}
	UpgradeItem.__index = UpgradeItem
	
	function UpgradeItem:new(o)
		o = o or {}
		setmetatable(o, self)
		return o
	end
	
	function UpgradeItem:create(number1, number2, max, upgradeType)
		local bg, temp = CCNode:create()
		local numStr = number1
		if number1<number2 then
			numStr = numStr .. "+" .. (number2-number1)
		end
		local text = UI.createLabel(StringManager.getFormatString("upgradeType" .. upgradeType, {num=numStr}), General.specialFont, 20)
		screen.autoSuitable(text, {nodeAnchor=General.anchorLeft, x=0, y=20})
		bg:addChild(text)
		local o = self:new({bg=bg, text=text, upgradeType=upgradeType, max=max, number=number})
		return o
	end
	
	function UpgradeDialog.addUpgradeItem(bg, index, number1, number2, max, upgradeType)
		local item = UpgradeItem:create(number1, number2, max, upgradeType)
		screen.autoSuitable(item.bg, {x=300, y=440-index*40})
		bg:addChild(item.bg)
		return item
	end
	
	function UpgradeDialog.create(build)
		local temp, bg = nil
		bg = UI.createButton(CCSizeMake(682, 513), doNothing, {image="images/dialogBgTrain.png", priority=display.DIALOG_PRI, nodeChangeHandler = doNothing})
		screen.autoSuitable(bg, {screenAnchor=General.anchorCenter, scaleType = screen.SCALE_CUT_EDGE})
		UI.setShowAnimate(bg)
		temp = UI.createButton(CCSizeMake(45, 45), display.closeDialog, {image="images/buttonClose.png"})
		screen.autoSuitable(temp, {x=646, y=480, nodeAnchor=General.anchorCenter})
		bg:addChild(temp)
		temp = UI.createLabel(StringManager.getFormatString("titleUpgrade", {level=build.buildLevel+1}), General.specialFont, 24)
		screen.autoSuitable(temp, {nodeAnchor=General.anchorBottom, x=341, y=465})
		bg:addChild(temp)
		
		local bdata = build.buildData
		local maxData = StaticData.getMaxLevelData(bdata.bid)
		local nextLevel = StaticData.getBuildData(bdata.bid, bdata.level+1)
		
		temp = Build.create(nextLevel.bid, nil, {level=nextLevel.level}):getBuildView()
		screen.autoSuitable(temp, {nodeAnchor=General.anchorBottom, x=150, y=315})
		bg:addChild(temp)
		temp = UI.createLabel(StringManager.getTimeString(nextLevel.time), General.specialFont, 30)
		screen.autoSuitable(temp, {nodeAnchor=General.anchorCenter, x=75, y=300})
		bg:addChild(temp)
		
		local itemIndex=1
		if build.addBuildUpgrade then
			local itemNum
			itemNum = build:addBuildUpgrade(bg, UpgradeDialog.addUpgradeItem)
			if itemNum then
				itemIndex = itemIndex + itemNum
			end
		end
		UpgradeDialog.addUpgradeItem(bg, itemIndex, bdata.hitPoints, nextLevel.hitPoints, maxData.hitPoints, "Hitpoints")
		
		temp = UI.createButton(CCSizeMake(175, 77), build.beginUpgrade, {image="images/buttonTest.png", callbackParam=build})
		screen.autoSuitable(temp, {nodeAnchor=General.anchorCenter, x=341, y=72})
		bg:addChild(temp)
		local temp1 = UI.createLabel(nextLevel.costValue .. " " .. nextLevel.costType, General.defaultFont, 24)
		screen.autoSuitable(temp1, {nodeAnchor=General.anchorCenter, x=87, y=38})
		temp:addChild(temp1)
		return bg
	end

	function UpgradeDialog.show(build)
		display.showDialog(UpgradeDialog.create(build))
	end
end