AchievementDialog = {}

local function updateAchievementCell(bg, scrollView, info)
	-- 31 327
	local temp
	temp = UI.createSpriteWithFile("images/dialogItemAchieveCell.png",CCSizeMake(671, 116))
	screen.autoSuitable(temp, {x=0, y=0})
	bg:addChild(temp)
	
	temp = UI.createSpriteWithFile("images/dialogItemInfoProcessBack.png",CCSizeMake(242, 24))
	screen.autoSuitable(temp, {x=205, y=14})
	bg:addChild(temp)
	
	local num = info.num
	if num>info.max then num = info.max end
	temp = UI.createSpriteWithFile("images/dialogItemInfoProcessFiller.png",CCSizeMake(240, 20))
	screen.autoSuitable(temp, {x=206, y=16})
	bg:addChild(temp)
	local size = temp:getContentSize()
	temp:setTextureRect(CCRectMake(0, 0, size.width*num/info.max, size.height))
	temp = UI.createLabel(num .. "/" .. info.max, "fonts/font3.fnt", 15, {colorR = 255, colorG = 255, colorB = 255, lineOffset=12})
	screen.autoSuitable(temp, {x=326, y=26, nodeAnchor=General.anchorCenter})
	bg:addChild(temp)
	
	temp = UI.createLabel(info.desc, "fonts/font1.fnt", 13, {colorR = 0, colorG = 0, colorB = 0, size=CCSizeMake(245, 0)})
	screen.autoSuitable(temp, {x=207, y=85, nodeAnchor=General.anchorLeftTop})
	bg:addChild(temp)
	temp = UI.createLabel(info.title, "fonts/font3.fnt", 18, {colorR = 255, colorG = 255, colorB = 222})
	screen.autoSuitable(temp, {x=209, y=101, nodeAnchor=General.anchorLeft})
	bg:addChild(temp)
	
	temp = UI.createLabel(StringManager.getString("labelReward"), "fonts/font1.fnt", 13, {colorR = 87, colorG = 83, colorB = 83})
	screen.autoSuitable(temp, {x=650, y=62, nodeAnchor=General.anchorRight})
	bg:addChild(temp)
	temp = UI.createLabel(info.exp .. "x", "fonts/font3.fnt", 22, {colorR = 255, colorG = 255, colorB = 255, lineOffset=12})
	screen.autoSuitable(temp, {x=514, y=34, nodeAnchor=General.anchorRight})
	bg:addChild(temp)
	temp = UI.createSpriteWithFile("images/exp.png",CCSizeMake(43, 41))
	screen.autoSuitable(temp, {x=517, y=12})
	bg:addChild(temp)
	temp = UI.createLabel(info.crystal .. "x", "fonts/font3.fnt", 22, {colorR = 255, colorG = 255, colorB = 255, lineOffset=12})
	screen.autoSuitable(temp, {x=615, y=34, nodeAnchor=General.anchorRight})
	bg:addChild(temp)
	temp = UI.createSpriteWithFile("images/crystal.png",CCSizeMake(38, 37))
	screen.autoSuitable(temp, {x=620, y=12})
	bg:addChild(temp)
	
	temp = UI.createSpriteWithFile("images/dialogItemStoreLight.png",CCSizeMake(160, 180))
	screen.autoSuitable(temp, {x=15, y=-19})
	bg:addChild(temp)
	temp = UI.createSpriteWithFile("images/battleEndRibbon.png",CCSizeMake(169, 55))
	screen.autoSuitable(temp, {x=17, y=17})
	bg:addChild(temp)

	temp = UI.createSpriteWithFile("images/battleStar1.png",CCSizeMake(59, 57))
	screen.autoSuitable(temp, {x=67, y=46})
	bg:addChild(temp)
	temp = UI.createSpriteWithFile("images/battleStar1.png",CCSizeMake(43, 40))
	screen.autoSuitable(temp, {x=37, y=41})
	bg:addChild(temp)
	temp = UI.createSpriteWithFile("images/battleStar1.png",CCSizeMake(43, 41))
	screen.autoSuitable(temp, {x=114, y=41})
	bg:addChild(temp)
	local stars = {}
	temp = UI.createSpriteWithFile("images/battleStar0.png",CCSizeMake(44, 41))
	screen.autoSuitable(temp, {x=37, y=41})
	bg:addChild(temp)
	stars[1] = temp
	temp = UI.createSpriteWithFile("images/battleStar0.png",CCSizeMake(61, 57))
	screen.autoSuitable(temp, {x=67, y=46})
	bg:addChild(temp)
	stars[2] = temp
	temp = UI.createSpriteWithFile("images/battleStar0.png",CCSizeMake(44, 41))
	screen.autoSuitable(temp, {x=114, y=41})
	bg:addChild(temp)
	stars[3] = temp
	for i=info.level, 3 do
		stars[i]:setVisible(false)
	end
	info.stars = stars
end

function AchievementDialog.show()
	local temp, bg = nil
	bg = UI.createButton(CCSizeMake(720, 526), doNothing, {image="images/dialogBgA.png", priority=display.DIALOG_PRI, nodeChangeHandler = doNothing})
	screen.autoSuitable(bg, {screenAnchor=General.anchorCenter, scaleType = screen.SCALE_CUT_EDGE})
	UI.setShowAnimate(bg)
	temp = UI.createSpriteWithFile("images/dialogItemBlood.png",CCSizeMake(292, 222))
	screen.autoSuitable(temp, {x=422, y=134})
	bg:addChild(temp)
	
	local stars, starMax=0, 51
	local items = Achievements.getAchievementsAllData()
	starMax = 3* (#items)
	for i=1, #items do
		stars = stars + (items[i].level-1)
	end
	local scrollView = UI.createScrollViewAuto(CCSizeMake(720, 340), false, {offx=23, offy=1, disy=9, size=CCSizeMake(671, 116), infos=items, cellUpdate=updateAchievementCell})
	screen.autoSuitable(scrollView.view, {nodeAnchor=General.anchorLeftTop, x=0, y=445})
	bg:addChild(scrollView.view)
	
	temp = UI.createSpriteWithFile("images/dialogItemAchieveBg.png",CCSizeMake(661, 60))
	screen.autoSuitable(temp, {x=29, y=28})
	bg:addChild(temp)
	temp = UI.createLabel(StringManager.getString("labelComplete"), "fonts/font1.fnt", 13, {colorR = 255, colorG = 255, colorB = 255})
	screen.autoSuitable(temp, {x=161, y=70, nodeAnchor=General.anchorLeft})
	bg:addChild(temp)
	temp = UI.createLabel(stars .. "/" .. starMax, "fonts/font3.fnt", 21, {colorR = 255, colorG = 255, colorB = 255, lineOffset=12})
	screen.autoSuitable(temp, {x=192, y=46, nodeAnchor=General.anchorCenter})
	bg:addChild(temp)
	temp = UI.createSpriteWithFile("images/achieveNpcFeature.png",CCSizeMake(97, 125))
	screen.autoSuitable(temp, {x=33, y=18})
	bg:addChild(temp)
	
	temp = UI.createLabel(StringManager.getString("titleAchievement"), "fonts/font3.fnt", 28, {colorR = 255, colorG = 255, colorB = 255})
	screen.autoSuitable(temp, {x=376, y=487, nodeAnchor=General.anchorCenter})
	bg:addChild(temp)
	temp = UI.createButton(CCSizeMake(47, 46), display.closeDialog, {image="images/buttonClose.png"})
	screen.autoSuitable(temp, {x=680, y=488, nodeAnchor=General.anchorCenter})
	bg:addChild(temp)
	
	display.showDialog({view=bg}, true)
end