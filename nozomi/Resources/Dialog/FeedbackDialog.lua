FeedbackDialog = class()

function FeedbackDialog:onFeedback()
    display.closeDialog()
    CCNative:openURL("http://www.baidu.com")
end

function FeedbackDialog:ctor()
    local temp, bg = nil
    bg = UI.createButton(CCSizeMake(720, 526), doNothing, {image="images/dialogBgA.png", priority=display.DIALOG_PRI, nodeChangeHandler = doNothing})
    screen.autoSuitable(bg, {screenAnchor=General.anchorCenter, scaleType = screen.SCALE_CUT_EDGE})
    self.view = bg
    UI.setShowAnimate(bg)
    
    temp = UI.createSpriteWithFile("images/dialogItemBlood.png",CCSizeMake(292, 222))
    screen.autoSuitable(temp, {x=400, y=50})
    bg:addChild(temp)
    temp = UI.createSpriteWithFile("images/soldierFeature8.png",CCSizeMake(294, 398))
    screen.autoSuitable(temp, {x=-11, y=63})
    bg:addChild(temp)
    temp = UI.createButton(CCSizeMake(135, 61), self.onFeedback, {callbackParam=self, image="images/buttonGreen.png", text=StringManager.getString("buttonFeedback"), fontSize=20, fontName="fonts/font3.fnt"})
    screen.autoSuitable(temp, {x=388, y=126, nodeAnchor=General.anchorCenter})
    bg:addChild(temp)
    temp = UI.createButton(CCSizeMake(135, 61), display.closeDialog, {image="images/buttonOrange.png", text=StringManager.getString("buttonNotFeedback"), fontSize=20, fontName="fonts/font3.fnt"})
    screen.autoSuitable(temp, {x=575, y=126, nodeAnchor=General.anchorCenter})
    bg:addChild(temp)
    temp = UI.createLabel(StringManager.getString("labelFeedback"), "fonts/font3.fnt", 28, {colorR = 255, colorG = 255, colorB = 255, size=CCSizeMake(460, 100)})
    screen.autoSuitable(temp, {x=452, y=310, nodeAnchor=General.anchorCenter})
    bg:addChild(temp)
end