ZombieDialog = {}

local function onDefense()
	local scene = display.getCurrentScene()
	scene:updateLogic(300)
	UserData.baseScene = scene
	UI.testChangeScene(true)
	UserData.zombieShieldTime = timer.getTime() + 86400
	delayCallback(1, display.pushScene, ZombieScene)
end

local function onSkip()
	ResourceLogic.changeResource("person", -math.floor(ResourceLogic.getResource("person")/10))
	UserData.zombieShieldTime = timer.getTime() + 86400
	display.closeDialog()
end

local function onDelay()
	ResourceLogic.changeResource("crystal", -100)
	UserData.zombieShieldTime = timer.getTime() + 86400
	display.closeDialog()
end

function ZombieDialog.create()
	local temp, bg = nil
	bg = UI.createButton(CCSizeMake(720, 523), doNothing, {image="images/dialogBgA.png", priority=display.DIALOG_PRI, nodeChangeHandler = doNothing})
	screen.autoSuitable(bg, {screenAnchor=General.anchorCenter, scaleType = screen.SCALE_CUT_EDGE})
	UI.setShowAnimate(bg)
	temp = UI.createSpriteWithFile("images/zombieFeature.png",CCSizeMake(273, 318))
	screen.autoSuitable(temp, {x=-7, y=101})
	bg:addChild(temp)
	temp = UI.createButton(CCSizeMake(157, 66), onDefense, {image="images/buttonGreen.png", text=StringManager.getString("buttonDefense"), fontSize=25, fontName="fonts/font3.fnt"})
	screen.autoSuitable(temp, {x=468, y=185, nodeAnchor=General.anchorCenter})
	bg:addChild(temp)
	temp = UI.createButton(CCSizeMake(157, 66), onSkip, {image="images/buttonGreen.png", text=StringManager.getString("buttonSkip"), fontSize=25, fontName="fonts/font3.fnt"})
	screen.autoSuitable(temp, {x=468, y=346, nodeAnchor=General.anchorCenter})
	bg:addChild(temp)
	temp = UI.createButton(CCSizeMake(157, 66), onDelay, {image="images/buttonGreen.png", text=StringManager.getString("buttonDelay"), fontSize=25, fontName="fonts/font3.fnt"})
	screen.autoSuitable(temp, {x=470, y=267, nodeAnchor=General.anchorCenter})
	bg:addChild(temp)
	return {view=bg}
end