PreBattleScene = class()

function PreBattleScene:ctor()
	self.view = CCNode:create()
	local epz = {{530, 704}, {900, 386}, {800, 600}, {285, 840}, {1140, 280}}
	local batch = CCSpriteBatchNode:create("images/fog.png")
	batch:setContentSize(CCSizeMake(1024, 768))
	for i=1, 5 do
		local temp
		
		temp = CCSprite:create("images/fog.png")
		temp:setScale(4)
		screen.autoSuitable(temp, {nodeAnchor=General.anchorRightTop, x=epz[i][1], y=epz[i][2]})
		batch:addChild(temp)
		temp = CCSprite:create("images/fog.png")
		temp:setScale(4)
		screen.autoSuitable(temp, {nodeAnchor=General.anchorLeftBottom, x=1024-epz[i][1], y=768-epz[i][2]})
		batch:addChild(temp)
	end
	screen.autoSuitable(batch, {screenAnchor=General.anchorCenter, scaleType=screen.SCALE_NORMAL})
	self.view:addChild(batch)
	
	temp = UI.createMenuButton(CCSizeMake(111, 109), "images/buttonChildMenu.png", self.returnHome, self, "images/menuItemAchieve.png", StringManager.getString("buttonReturnHome"), 20)
	screen.autoSuitable(temp, {x=72, y=70, screenAnchor=General.anchorLeftBottom, nodeAnchor=General.anchorCenter, scaleType=screen.SCALE_NORMAL})
	self.view:addChild(temp)
	
	temp = UI.createSpriteWithFile("images/findEnemyIcon.png",CCSizeMake(163, 116))
	screen.autoSuitable(temp, {screenAnchor=General.anchorCenter, x=-30, y=0, scaleType=screen.SCALE_NORMAL})
	self.view:addChild(temp)
	
	local array = CCArray:create()
	array:addObject(CCEaseSineIn:create(CCMoveBy:create(1, CCPointMake(30, 0))))
	array:addObject(CCEaseSineOut:create(CCMoveBy:create(1, CCPointMake(30, 0))))
	array:addObject(CCEaseSineIn:create(CCMoveBy:create(1, CCPointMake(-30, 0))))
	array:addObject(CCEaseSineOut:create(CCMoveBy:create(1, CCPointMake(-30, 0))))
	temp:runAction(CCRepeatForever:create(CCSequence:create(array)))
	
	array = CCArray:create()
	array:addObject(CCEaseSineOut:create(CCMoveBy:create(1, CCPointMake(0, 20))))
	array:addObject(CCEaseSineIn:create(CCMoveBy:create(1, CCPointMake(0, -20))))
	array:addObject(CCEaseSineOut:create(CCMoveBy:create(1, CCPointMake(0, -20))))
	array:addObject(CCEaseSineIn:create(CCMoveBy:create(1, CCPointMake(0, 20))))
	temp:runAction(CCRepeatForever:create(CCSequence:create(array)))
	
	temp = UI.createLabel(StringManager.getString("labelFindEnemy"), "fonts/font3.fnt", 33, {colorR = 255, colorG = 255, colorB = 181})
	screen.autoSuitable(temp, {screenAnchor=General.anchorCenter, x=0, y=0, scaleType=screen.SCALE_NORMAL})
	self.view:addChild(temp)
	
	network.httpRequest("findEnemy", self.findOver, {params={baseScore=UserData.userScore}}, self)
end

function PreBattleScene:returnHome()
	self.returnOver = true
	display.popScene()
end

function PreBattleScene:findOver(suc, result)
	if suc and not self.returnOver then
		local data = json.decode(result)
		local scene = BattleScene.new()
		scene:initView()
		scene:initGround()
		scene:initData(result)
		scene:initMenu()
		display.runScene(scene, true)
	end
end