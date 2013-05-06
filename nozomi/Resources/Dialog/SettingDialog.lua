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

function SettingDialog.create()
	local temp, bg = nil
	bg = UI.createButton(CCSizeMake(447, 559), doNothing, {image="images/dialogBgTrain.png", priority=display.DIALOG_PRI, nodeChangeHandler = doNothing})
	screen.autoSuitable(bg, {screenAnchor=General.anchorCenter, scaleType = screen.SCALE_CUT_EDGE})
	temp = UI.createButton(CCSizeMake(45, 45), display.closeDialog, {image="images/buttonClose.png"})
	screen.autoSuitable(temp, {x=416, y=524, nodeAnchor=General.anchorCenter})
	bg:addChild(temp)
	UI.setShowAnimate(bg)
	
	temp = UI.createSwitch(CCSizeMake(117, 48), SettingDialog.changeNightMode, UserSetting.nightMode)
	screen.autoSuitable(temp, {x=323, y=426, nodeAnchor=General.anchorCenter})
	bg:addChild(temp)
	temp = UI.createLabel(StringManager.getString("Night mode"), General.defaultFont, 30, {colorR = 230, colorG = 30, colorB = 30})
	screen.autoSuitable(temp, {x=89, y=424, nodeAnchor=General.anchorLeft})
	bg:addChild(temp)
	
	temp = UI.createSwitch(CCSizeMake(117, 48), SettingDialog.changeMusicOpen, UserSetting.musicOn)
	screen.autoSuitable(temp, {x=328, y=336, nodeAnchor=General.anchorCenter})
	bg:addChild(temp)
	temp = UI.createLabel(StringManager.getString("Music"), General.defaultFont, 30, {colorR = 230, colorG = 30, colorB = 30})
	screen.autoSuitable(temp, {x=161, y=336, nodeAnchor=General.anchorLeft})
	bg:addChild(temp)
	
	return bg
end