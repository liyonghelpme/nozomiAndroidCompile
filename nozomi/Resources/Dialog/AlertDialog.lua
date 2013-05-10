AlertDialog = class()

function AlertDialog:executeFunction()
	local callback = self.alertSetting.callback
	local param = self.alertSetting.param
	display.closeDialog()
	if self.delegate then
		callback(self.delegate, param)
	else
		callback(param)
	end
end

function AlertDialog:ctor(title, text, setting, delegate)
	local temp, bg = nil
	bg = UI.createButton(CCSizeMake(443, 279), doNothing, {image="images/dialogBgC.png", priority=display.DIALOG_PRI-2, nodeChangeHandler = doNothing})
	screen.autoSuitable(bg, {screenAnchor=General.anchorCenter, scaleType = screen.SCALE_CUT_EDGE})
	UI.setShowAnimate(bg)
	
	self.isAlert = true
	self.alertSetting = setting
	self.delegate = delegate
	
	local btext = setting.cancelText or StringManager.getString("buttonCancel")
	temp = UI.createButton(CCSizeMake(169, 76), display.closeDialog, {priority=display.DIALOG_BUTTON_PRI-2, callbackParam=true, image="images/buttonOrange.png", text=btext, fontSize=25, fontName="fonts/font3.fnt"})
	screen.autoSuitable(temp, {x=121, y=65, nodeAnchor=General.anchorCenter})
	bg:addChild(temp)
    if setting.crystal then
    	temp = UI.createButton(CCSizeMake(169, 76), self.executeFunction, {priority=display.DIALOG_BUTTON_PRI-2, callbackParam=self, image="images/buttonGreen.png"})
    	screen.autoSuitable(temp, {x=319, y=66, nodeAnchor=General.anchorCenter})
    	bg:addChild(temp)
    	
    	local colorSetting = {colorR=255, colorG=255, colorB=255, lineOffset=-12}
    	if setting.crystal>UserData.crystal then
    	    colorSetting.colorG=0
    	    colorSetting.colorB=0
    	end
    	local temp1 = UI.createLabel(tostring(setting.crystal), "fonts/font3.fnt", 25, colorSetting)
    	screen.autoSuitable(temp1, {nodeAnchor=General.anchorCenter, x=85, y=38})
    	temp:addChild(temp1)
    	local w = temp1:getContentSize().width/2 * temp1:getScaleX()
		temp1 = UI.createSpriteWithFile("images/crystal.png",CCSizeMake(49, 48))
		screen.autoSuitable(temp1, {x=88+w, y=12})
		temp:addChild(temp1)
    else
    	btext = setting.okText or StringManager.getString("buttonYes")
    	temp = UI.createButton(CCSizeMake(169, 76), self.executeFunction, {priority=display.DIALOG_BUTTON_PRI-2, callbackParam=self, image="images/buttonGreen.png", text=btext, fontSize=25, fontName="fonts/font3.fnt", lineOffset=setting.lineOffset})
    	screen.autoSuitable(temp, {x=319, y=66, nodeAnchor=General.anchorCenter})
    	bg:addChild(temp)
    end
	temp = UI.createLabel(title, "fonts/font3.fnt", 25, {colorR = 255, colorG = 255, colorB = 255})
	screen.autoSuitable(temp, {x=222, y=233, nodeAnchor=General.anchorCenter})
	bg:addChild(temp)
	
	if setting.img then
	    temp = UI.createScaleSprite(setting.img,CCSizeMake(77, 90))
        screen.autoSuitable(temp, {x=102, y=158, nodeAnchor=General.anchorCenter})
        bg:addChild(temp)
    	temp = UI.createLabel(text, "fonts/font1.fnt", 18, {colorR = 75, colorG = 66, colorB = 46, size=CCSizeMake(340, 60)})
    	screen.autoSuitable(temp, {x=268, y=167, nodeAnchor=General.anchorCenter})
    	bg:addChild(temp)
    else
    	temp = UI.createLabel(text, "fonts/font1.fnt", 18, {colorR = 75, colorG = 66, colorB = 46, size=CCSizeMake(386, 60)})
    	screen.autoSuitable(temp, {x=222, y=167, nodeAnchor=General.anchorCenter})
    	bg:addChild(temp)
	end
	
	self.view = bg
end