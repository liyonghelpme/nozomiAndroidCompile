InfoDialog = {}

do
	function InfoDialog.create(build)
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
		
		local bdata = build.buildData
		local binfo = StaticData.getBuildInfo(bdata.bid)
		local titleKey = "titleInfo"
		if binfo.levelMax==1 then
			titleKey = "titleInfoNoLevel"
		end
		temp = UI.createLabel(StringManager.getFormatString(titleKey, {name=binfo.name, level=build.buildLevel}), "fonts/font3.fnt", 25, {colorR = 255, colorG = 255, colorB = 255})
		screen.autoSuitable(temp, {x=360, y=506, nodeAnchor=General.anchorTop})
		bg:addChild(temp)
	
		temp = build:getBuildView()
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
		
		local infoOffset, itemIndex = 238, 1
		if build.addBuildInfo then
			local itemNum, offset
			itemNum, offset = build:addBuildInfo(bg, UI.addInfoItem2)
			if offset and offset>0 then
				infoOffset = offset
			end
			if itemNum then
				itemIndex = itemIndex + itemNum
			end
		end
		UI.addInfoItem2(bg, itemIndex, build.getHitPoints or bdata.hitPoints, nil, bdata.hitPoints, "Hitpoints", nil, build)
		if binfo.info then
			--238
			temp = UI.createLabel(binfo.info, "fonts/font1.fnt", 15, {colorR = 33, colorG = 93, colorB = 165, size=CCSizeMake(650, 0)})
			screen.autoSuitable(temp, {x=360, y=infoOffset, nodeAnchor=General.anchorTop})
			bg:addChild(temp)
		end
		return bg
	end
	
	function InfoDialog.show(build)
		display.showDialog(InfoDialog.create(build))
	end
end