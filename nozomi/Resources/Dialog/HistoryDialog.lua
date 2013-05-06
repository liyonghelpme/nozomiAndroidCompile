HistoryDialog = {}

local function onVideo()
	local resourceTypes = {"oil", "food"}
	for i=1, 2 do
		local resourceType = resourceTypes[i]
		BattleLogic.resources[resourceType] = {left=0, stolen=0, base=ResourceLogic.getResource(resourceType), max=ResourceLogic.getResourceMax(resourceType)}
	end
	BattleLogic.init()
	UI.testChangeScene(true)
	delayCallback(1, display.pushScene, ReplayScene)
end

local function updateHistoryCell(bg, scrollView, info)
	local temp, temp1
	temp1 = {}
	if info.score>0 then
		temp1[1] = UI.createSpriteWithFile("images/dialogItemHistoryCellA.png",CCSizeMake(827, 171))
		temp1[2] = UI.createSpriteWithFile("images/dialogItemHistoryWin.png",CCSizeMake(237, 32))
		temp1[3] = UI.createLabel(StringManager.getString("defenseWin"), "fonts/font1.fnt", 15, {colorR = 0, colorG = 0, colorB = 0})
	else
		temp1[1] = UI.createSpriteWithFile("images/dialogItemHistoryCellB.png",CCSizeMake(827, 171))
		temp1[2] = UI.createSpriteWithFile("images/dialogItemHistoryLose.png",CCSizeMake(237, 32))
		temp1[3] = UI.createLabel(StringManager.getString("defenseLose"), "fonts/font1.fnt", 15, {colorR = 0, colorG = 0, colorB = 0})
	end
	screen.autoSuitable(temp1[1], {x=0, y=0})
	bg:addChild(temp1[1])
	screen.autoSuitable(temp1[2], {x=582, y=130})
	bg:addChild(temp1[2])
	screen.autoSuitable(temp1[3], {x=701, y=146, nodeAnchor=General.anchorCenter})
	bg:addChild(temp1[3])
	
	temp = UI.createSpriteWithFile("images/dialogItemStoreLight.png",CCSizeMake(93, 104))
	screen.autoSuitable(temp, {x=592, y=-14})
	bg:addChild(temp)
	
	info.clan = "Caesars"
	if info.clan then
		temp = UI.createLabel(info.clan, "fonts/font1.fnt", 15, {colorR = 90, colorG = 81, colorB = 74})
		screen.autoSuitable(temp, {x=31, y=123, nodeAnchor=General.anchorLeft})
		bg:addChild(temp)
		temp = UI.createSpriteWithFile("images/leagueIconB.png",CCSizeMake(20, 22))
		screen.autoSuitable(temp, {x=10, y=112})
		bg:addChild(temp)
	end
	--time
	temp = UI.createLabel(StringManager.getFormatString("timeAgo", {time=StringManager.getTimeString(timer.getServerTime(timer.getTime())-info.time)}), "fonts/font1.fnt", 13, {colorR = 42, colorG = 40, colorB = 39})
	screen.autoSuitable(temp, {x=563, y=19, nodeAnchor=General.anchorRight})
	bg:addChild(temp)
	-- percent
	temp = UI.createLabel(info.percent .. "%", "fonts/font1.fnt", 15, {colorR = 0, colorG = 0, colorB = 0})
	screen.autoSuitable(temp, {x=618, y=113, nodeAnchor=General.anchorCenter})
	bg:addChild(temp)
	if info.stars>0 then
		for i=1, 3 do
			local t=0
			if i>info.stars then t=1 end
			temp = UI.createSpriteWithFile("images/battleStar" .. t .. ".png",CCSizeMake(20, 20))
			screen.autoSuitable(temp, {x=566+i*21, y=86})
			bg:addChild(temp)
		end
	end
	
	temp = UI.createSpriteWithFile("images/dialogItemHistorySeperator.png",CCSizeMake(2, 154))
	screen.autoSuitable(temp, {x=575, y=9})
	bg:addChild(temp)
	
	-- name
	temp = UI.createLabel(info.name, "fonts/font3.fnt", 18, {colorR = 255, colorG = 255, colorB = 255})
	screen.autoSuitable(temp, {x=10, y=146, nodeAnchor=General.anchorLeft})
	bg:addChild(temp)
	local w = temp:getContentSize().width * temp:getScaleX()
	temp = UI.createSpriteWithFile("images/chatRoomItemVisit.png",CCSizeMake(30, 31))
	screen.autoSuitable(temp, {nodeAnchor=General.anchorLeft, x=10+w, y=146})
	bg:addChild(temp)
	
	-- resources
	temp = UI.createSpriteWithFile("images/food.png",CCSizeMake(19, 26))
	screen.autoSuitable(temp, {x=13, y=10})
	bg:addChild(temp)
	temp = UI.createSpriteWithFile("images/oil.png",CCSizeMake(20, 22))
	screen.autoSuitable(temp, {x=156, y=10})
	bg:addChild(temp)
	temp = UI.createSpriteWithFile("images/special.png",CCSizeMake(30, 29))
	screen.autoSuitable(temp, {x=291, y=4})
	bg:addChild(temp)
	temp = UI.createLabel(tostring(info.food), "fonts/font3.fnt", 18, {colorR = 255, colorG = 255, colorB = 255, lineOffset=12})
	screen.autoSuitable(temp, {x=35, y=22, nodeAnchor=General.anchorLeft})
	bg:addChild(temp)
	temp = UI.createLabel(tostring(info.oil), "fonts/font3.fnt", 18, {colorR = 255, colorG = 255, colorB = 255, lineOffset=12})
	screen.autoSuitable(temp, {x=180, y=22, nodeAnchor=General.anchorLeft})
	bg:addChild(temp)
	temp = UI.createLabel(tostring(info.special), "fonts/font3.fnt", 18, {colorR = 255, colorG = 255, colorB = 255, lineOffset=12})
	screen.autoSuitable(temp, {x=325, y=22, nodeAnchor=General.anchorLeft})
	bg:addChild(temp)
	
	-- score
	temp = UI.createLabel(info.score, "fonts/font3.fnt", 25, {colorR = 255, colorG = 255, colorB = 255, lineOffset=12})
	screen.autoSuitable(temp, {x=623, y=38, nodeAnchor=General.anchorRight})
	bg:addChild(temp)
	temp = UI.createSpriteWithFile("images/score.png",CCSizeMake(25, 29))
	screen.autoSuitable(temp, {x=628, y=23})
	bg:addChild(temp)
	
	temp = UI.createLabel(info.uscore, "fonts/font3.fnt", 17, {colorR = 255, colorG = 255, colorB = 255, lineOffset=12})
	screen.autoSuitable(temp, {x=533, y=147, nodeAnchor=General.anchorRight})
	bg:addChild(temp)
	temp = UI.createSpriteWithFile("images/score.png",CCSizeMake(20, 23))
	screen.autoSuitable(temp, {x=542, y=134})
	bg:addChild(temp)
	
	temp = UI.createButton(CCSizeMake(150, 50), onVideo, {callbackParam=info, image="images/buttonGreenB.png", text=StringManager.getString("buttonVideo"), fontSize=15, fontName="fonts/font3.fnt"})
	screen.autoSuitable(temp, {x=740, y=96, nodeAnchor=General.anchorCenter})
	bg:addChild(temp)
	if info.revenged then
		temp = UI.createLabel(StringManager.getString("labelRevergeOver"), "fonts/font1.fnt", 11, {colorR = 115, colorG = 113, colorB = 115})
		screen.autoSuitable(temp, {x=685, y=38, nodeAnchor=General.anchorLeft})
		bg:addChild(temp)
	else
		temp = UI.createButton(CCSizeMake(150, 50), onReverge, {callbackParam=info, image="images/buttonEnd.png", text=StringManager.getString("buttonReverge"), fontSize=15, fontName="fonts/font3.fnt"})
		screen.autoSuitable(temp, {x=740, y=40, nodeAnchor=General.anchorCenter})
		bg:addChild(temp)
	end
	
	local items = info.items
	for i=1, #items do
		local item = items[i]
		local cell = CCNode:create()
		cell:setContentSize(CCSizeMake(48, 63))
		screen.autoSuitable(cell, {x=51*i-39, y=41})
		bg:addChild(cell)
		
		temp = UI.createSpriteWithFile("images/dialogItemBattleResultItemA.png",CCSizeMake(48, 63))
		screen.autoSuitable(temp, {x=0, y=0})
		cell:addChild(temp)
		
		SoldierHelper.addSoldierHead(cell, item.id, 0.42)
		
		temp = UI.createLabel("x" .. item.num, "fonts/font3.fnt", 15, {colorR = 255, colorG = 255, colorB = 255})
		screen.autoSuitable(temp, {x=4, y=56, nodeAnchor=General.anchorLeft})
		cell:addChild(temp)
		for j=1, item.level do
			temp = UI.createSpriteWithFile("images/soldierStar.png",CCSizeMake(10, 10))
			screen.autoSuitable(temp, {x=8*j-6, y=4})
			cell:addChild(temp)
		end
	end
	
end

function HistoryDialog.show()
	--
	UserData.historys = {
		{id=1, score=21, stars=0, percent=40, time=1362642124, uscore=1460, food=2635, oil=8890, special=0, clan="Flesh", name="Boice", items={{id=2,num=53,level=5}, {id=5,num=10,level=3}, {id=3, num=54, level=4}, {id=1, num=53, level=4}}},
		{id=1, score=-5, stars=1, percent=70, time=1362642124, uscore=1460, food=2635, oil=8890, special=0, clan="stc", name="wjzzhtgp", items={{id=2,num=53,level=5}, {id=5,num=10,level=3}, {id=3, num=54, level=4}}, revenged=true},
		{id=1, score=-10, stars=2, percent=80, time=1362642124, uscore=1460, food=2635, oil=8890, special=0, clan="stc", name="wjzzhtgp", items={{id=2,num=53,level=5}, {id=5,num=10,level=3}, {id=1, num=53, level=4}}},
		{id=1, score=-15, stars=3, percent=100, time=1362642124, uscore=1460, food=2635, oil=8890, special=0, clan="stc", name="wjzzhtgp", items={{id=2,num=53,level=5}, {id=3, num=54, level=4}, {id=1, num=53, level=4}}, revenged=true}
	}
	if UserData.historys == nil then
		print("no history")
		return
	end
	
	local temp, bg = nil
	bg = UI.createButton(CCSizeMake(890, 650), doNothing, {image="images/dialogBgA.png", priority=display.DIALOG_PRI, nodeChangeHandler = doNothing})
	screen.autoSuitable(bg, {screenAnchor=General.anchorCenter, scaleType = screen.SCALE_CUT_EDGE})
	
	UI.setShowAnimate(bg)
	-- 30 25 175
	
	local scrollView = UI.createScrollViewAuto(CCSizeMake(891, 525), false, {offx=30, offy=1, disy=4, size=CCSizeMake(827, 171), infos=UserData.historys, cellUpdate=updateHistoryCell})
	screen.autoSuitable(scrollView.view, {nodeAnchor=General.anchorLeftTop, x=0, y=547})
	bg:addChild(scrollView.view)
	
	temp = UI.createLabel(StringManager.getString("labelEnemys"), "fonts/font2.fnt", 13, {colorR = 255, colorG = 255, colorB = 255})
	screen.autoSuitable(temp, {x=77, y=554, nodeAnchor=General.anchorLeft})
	bg:addChild(temp)
	temp = UI.createLabel(StringManager.getString("labelBattleResult"), "fonts/font2.fnt", 13, {colorR = 255, colorG = 255, colorB = 255})
	screen.autoSuitable(temp, {x=690, y=554, nodeAnchor=General.anchorLeft})
	bg:addChild(temp)
	temp = UI.createLabel(StringManager.getString("titleBattleLog"), "fonts/font3.fnt", 30, {colorR = 255, colorG = 255, colorB = 255})
	screen.autoSuitable(temp, {x=445, y=598, nodeAnchor=General.anchorCenter})
	bg:addChild(temp)
	temp = UI.createButton(CCSizeMake(54, 53), display.closeDialog, {image="images/buttonClose.png"})
	screen.autoSuitable(temp, {x=845, y=606, nodeAnchor=General.anchorCenter})
	bg:addChild(temp)
	
	display.showDialog({view=bg}, true)
end