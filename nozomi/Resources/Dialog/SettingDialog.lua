require "Dialog.FeedbackDialog"

SettingDialog = {}

function SettingDialog.changeNightMode(state)
	if UserSetting.nightMode ~= state then
		if state then
			UserData.isNight = false
		end
		UserSetting.nightMode = state
	end
end

function SettingDialog.changeMusicOpen(state)
	
end

function SettingDialog.changeSoundOpen(state)
	
end

function SettingDialog.onAbout()
    display.showDialog(AboutDialog.new(), true)
end

function SettingDialog.onFeedback()
    display.showDialog(FeedbackDialog.new(), true)
end

function SettingDialog.create()
	local temp, bg = nil
    bg = UI.createButton(CCSizeMake(503, 368), doNothing, {image="images/dialogBgA.png", priority=display.DIALOG_PRI, nodeChangeHandler = doNothing})
    screen.autoSuitable(bg, {screenAnchor=General.anchorCenter, scaleType = screen.SCALE_CUT_EDGE})
	UI.setShowAnimate(bg)
    temp = UI.createSpriteWithFile("images/dialogItemSettingSeperator.png",CCSizeMake(447, 2))
    screen.autoSuitable(temp, {x=25, y=165})
    bg:addChild(temp)
    temp = UI.createButton(CCSizeMake(133, 48), SettingDialog.onAbout, {image="images/buttonGreenB.png", text=StringManager.getString("buttonAbout"), fontSize=20, fontName="fonts/font3.fnt"})
    screen.autoSuitable(temp, {x=157, y=117, nodeAnchor=General.anchorCenter})
    bg:addChild(temp)
    temp = UI.createButton(CCSizeMake(133, 48), SettingDialog.onFeedback, {image="images/buttonGreenB.png", text=StringManager.getString("Feedback"), fontSize=20, fontName="fonts/font3.fnt"})
    screen.autoSuitable(temp, {x=346, y=117, nodeAnchor=General.anchorCenter})
    bg:addChild(temp)
    temp = UI.createSwitch(CCSizeMake(133, 48), SettingDialog.changeSoundOpen, UserSetting.soundOn)
    screen.autoSuitable(temp, {x=342, y=218, nodeAnchor=General.anchorCenter})
    bg:addChild(temp)
    temp = UI.createLabel(StringManager.getString("labelSound"), "fonts/font3.fnt", 20, {colorR = 255, colorG = 255, colorB = 255, lineOffset=-12})
    screen.autoSuitable(temp, {x=97, y=213, nodeAnchor=General.anchorLeft})
    bg:addChild(temp)
    temp = UI.createSwitch(CCSizeMake(133, 48), SettingDialog.changeMusicOpen, UserSetting.musicOn)
    screen.autoSuitable(temp, {x=342, y=279, nodeAnchor=General.anchorCenter})
    bg:addChild(temp)
    
    temp = UI.createLabel(StringManager.getString("labelMusic"), "fonts/font3.fnt", 20, {colorR = 255, colorG = 255, colorB = 255, lineOffset=-12})
    screen.autoSuitable(temp, {x=97, y=274, nodeAnchor=General.anchorLeft})
    bg:addChild(temp)
    temp = UI.createLabel(StringManager.getString("titleSetting"), "fonts/font3.fnt", 28, {colorR = 255, colorG = 255, colorB = 255})
    screen.autoSuitable(temp, {x=260, y=340, nodeAnchor=General.anchorCenter})
    bg:addChild(temp)
    temp = UI.createButton(CCSizeMake(36, 34), display.closeDialog, {image="images/buttonClose.png"})
    screen.autoSuitable(temp, {x=474, y=343, nodeAnchor=General.anchorCenter})
    bg:addChild(temp)
    if General.useGameCenter then
        temp = UI.createSpriteWithFile("images/gamecenterIcon.png",CCSizeMake(56, 56))
        screen.autoSuitable(temp, {x=25, y=27})
        bg:addChild(temp)
        temp = UI.createLabel(StringManager.getString("labelGameCenter"), "fonts/font1.fnt", 13, {colorR = 0, colorG = 0, colorB = 0, size=CCSizeMake(390, 40)})
        screen.autoSuitable(temp, {x=98, y=51, nodeAnchor=General.anchorLeft})
        bg:addChild(temp)
	end
	return bg
end