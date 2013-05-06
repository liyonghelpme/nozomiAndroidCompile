BattleDialog = {lock=false}

local function enterBattleScene()
	if BattleDialog.lock then return end
	display.getCurrentScene():updateLogic(300)
	local resourceTypes = {"oil", "food", "special", "person"}
	for i=1, 4 do
		local resourceType = resourceTypes[i]
		BattleLogic.resources[resourceType] = {left=0, stolen=0, base=ResourceLogic.getResource(resourceType), max=ResourceLogic.getResourceMax(resourceType)}
	end
	-- local scene = PreBattleScene.new()
	-- TODO
	UI.testChangeScene(true)
	delayCallback(1, display.pushScene, PreBattleScene)
	--display.pushScene(scene)
end

local function enterReplayScene()
	local resourceTypes = {"oil", "food", "special", "person"}
	for i=1, 4 do
		local resourceType = resourceTypes[i]
		BattleLogic.resources[resourceType] = {left=0, stolen=0, base=ResourceLogic.getResource(resourceType), max=ResourceLogic.getResourceMax(resourceType)}
	end
	BattleLogic.init()
	local scene = ReplayScene.new()
	display.pushScene(scene)
end

function BattleDialog.create()
	local bg, temp
	BattleDialog.lock = false
	bg = UI.createButton(General.winSize, doNothing, {image="images/dialogBgStore.png", priority=display.DIALOG_PRI, nodeChangeHandler = doNothing})
	temp = UI.createButton(CCSizeMake(50, 51), display.closeDialog, {image="images/buttonClose.png"})
	screen.autoSuitable(temp, {scaleType=screen.SCALE_NORMAL, screenAnchor=General.anchorRightTop, nodeAnchor=General.anchorCenter, x=-47, y=-49})
	bg:addChild(temp)
	
	temp = UI.createButton(CCSizeMake(200, 100), enterBattleScene, {image="images/buttonTest.png", text="find match", fontSize=25, fontName=General.defaultFont})
	screen.autoSuitable(temp, {nodeAnchor=General.anchorCenter, x=200, y=100})
	bg:addChild(temp)
	
	temp = UI.createButton(CCSizeMake(200, 100), enterReplayScene, {image="images/buttonTest.png", text="replay", fontSize=25, fontName=General.defaultFont})
	screen.autoSuitable(temp, {nodeAnchor=General.anchorCenter, x=800, y=100})
	bg:addChild(temp)
	
	return bg
end

BattleDialog.enterBattleScene = enterBattleScene