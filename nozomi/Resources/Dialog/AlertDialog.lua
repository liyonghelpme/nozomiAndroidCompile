AlertDialog = class()

function AlertDialog:executeFunction()
	local callback = self.alertSetting.callback
	local param = self.alertSetting.param
	if self.delegate then
		callback(self.delegate, param)
	else
		callback(param)
	end
	display.closeDialog()
end

function AlertDialog:ctor(title, text, setting, delegate)
	local temp, bg = nil
	bg = UI.createButton(CCSizeMake(443, 279), doNothing, {image="images/dialogBgC.png", priority=display.DIALOG_PRI, nodeChangeHandler = doNothing})
	screen.autoSuitable(bg, {screenAnchor=General.anchorCenter, scaleType = screen.SCALE_CUT_EDGE})
	UI.setShowAnimate(bg)
	
	self.alertSetting = setting
	self.delegate = delegate
	
	local btext = setting.cancelText or StringManager.getString("buttonCancel")
	temp = UI.createButton(CCSizeMake(169, 76), display.closeDialog, {image="images/buttonOrange.png", text=btext, fontSize=25, fontName="fonts/font3.fnt"})
	screen.autoSuitable(temp, {x=121, y=65, nodeAnchor=General.anchorCenter})
	bg:addChild(temp)
	btext = setting.cancelText or StringManager.getString("buttonYes")
	temp = UI.createButton(CCSizeMake(169, 76), self.executeFunction, {callbackParam=self, image="images/buttonGreen.png", text=btext, fontSize=25, fontName="fonts/font3.fnt"})
	screen.autoSuitable(temp, {x=319, y=66, nodeAnchor=General.anchorCenter})
	bg:addChild(temp)
	temp = UI.createLabel(title, "fonts/font3.fnt", 25, {colorR = 255, colorG = 255, colorB = 255})
	screen.autoSuitable(temp, {x=222, y=233, nodeAnchor=General.anchorCenter})
	bg:addChild(temp)
	temp = UI.createLabel(text, "fonts/font1.fnt", 18, {colorR = 75, colorG = 66, colorB = 46, size=CCSizeMake(386, 60)})
	screen.autoSuitable(temp, {x=222, y=167, nodeAnchor=General.anchorCenter})
	bg:addChild(temp)
	
	self.view = bg
end