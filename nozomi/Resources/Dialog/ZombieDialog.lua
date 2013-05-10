ZombieDialog = {}

local function onDefense()
	local scene = display.getCurrentScene()
	scene:updateLogic(300)
	UserData.baseScene = scene
	UI.testChangeScene(true)
	UserData.zombieShieldTime = timer.getTime() + 28800
	delayCallback(getParam("actionTimeChangeScene", 600)/1000, display.pushScene, ZombieScene)
end

local function onSkip()
	ResourceLogic.changeResource("person", -math.floor(ResourceLogic.getResource("person")*LOST_PERCENT/100))
	UserData.zombieShieldTime = timer.getTime() + 28800
	display.closeDialog()
end

function ZombieDialog.create()
	local temp, bg = nil
	bg = UI.createButton(CCSizeMake(720, 526), doNothing, {image="images/dialogBgA.png", priority=display.DIALOG_PRI, nodeChangeHandler = doNothing})
    screen.autoSuitable(bg, {screenAnchor=General.anchorCenter, scaleType = screen.SCALE_CUT_EDGE})
	UI.setShowAnimate(bg)
    temp = UI.createSpriteWithFile("images/dialogItemBlood.png",CCSizeMake(292, 222))
    screen.autoSuitable(temp, {x=400, y=50})
    bg:addChild(temp)
    temp = UI.createSpriteWithFile("images/featureShadow.png",CCSizeMake(192, 74))
    screen.autoSuitable(temp, {x=34, y=70})
    bg:addChild(temp)
    temp = UI.createSpriteWithFile("images/zombieFeature.png",CCSizeMake(273, 318))
    screen.autoSuitable(temp, {x=-10, y=99})
    bg:addChild(temp)
    if ZombieLogic.isGuide then
        temp = UI.createButton(CCSizeMake(135, 61), onDefense, {image="images/buttonGreen.png", text=StringManager.getString("buttonDefense"), fontSize=25, fontName="fonts/font3.fnt"})
        screen.autoSuitable(temp, {x=456, y=121, nodeAnchor=General.anchorCenter})
        bg:addChild(temp)
        temp = UI.createGuidePointer(90)
        temp:setPosition(526, 121)
        bg:addChild(temp)
    else
        temp = UI.createButton(CCSizeMake(135, 61), onDefense, {image="images/buttonGreen.png", text=StringManager.getString("buttonDefense"), fontSize=25, fontName="fonts/font3.fnt"})
        screen.autoSuitable(temp, {x=544, y=121, nodeAnchor=General.anchorCenter})
        bg:addChild(temp)
        temp = UI.createButton(CCSizeMake(135, 61), onSkip, {image="images/buttonOrange.png", text=StringManager.getString("buttonSkip"), fontSize=25, fontName="fonts/font3.fnt"})
        screen.autoSuitable(temp, {x=367, y=121, nodeAnchor=General.anchorCenter})
        bg:addChild(temp)
        temp = UI.createLabel(StringManager.getFormatString("tipsZombieDefense", {percent=LOST_PERCENT}), "fonts/font1.fnt", 20, {colorR = 75, colorG = 66, colorB = 46})
        screen.autoSuitable(temp, {x=459, y=65, nodeAnchor=General.anchorCenter})
        bg:addChild(temp)
    end
    temp = UI.createLabel(StringManager.getString("labelZombieDefense"), "fonts/font3.fnt", 28, {colorR = 255, colorG = 255, colorB = 255, size=CCSizeMake(380, 200)})
    screen.autoSuitable(temp, {x=466, y=289, nodeAnchor=General.anchorCenter})
    bg:addChild(temp)
    temp = UI.createLabel(StringManager.getString("titleWarning"), "fonts/font3.fnt", 28, {colorR = 255, colorG = 255, colorB = 255})
    screen.autoSuitable(temp, {x=363, y=486, nodeAnchor=General.anchorCenter})
    bg:addChild(temp)
	return {view=bg}
end