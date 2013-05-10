WaitAttackDialog = class()

function WaitAttackDialog:ctor(leftSeconds)
    local temp, bg = nil
    bg = UI.createButton(CCSizeMake(720, 526), doNothing, {image="images/dialogBgA.png", priority=display.DIALOG_PRI, nodeChangeHandler = doNothing})
    screen.autoSuitable(bg, {screenAnchor=General.anchorCenter, scaleType = screen.SCALE_CUT_EDGE})
    self.view = bg
    UI.setShowAnimate(bg)
    temp = UI.createSpriteWithFile("images/dialogItemBlood.png",CCSizeMake(292, 222))
    screen.autoSuitable(temp, {x=400, y=50})
    bg:addChild(temp)
    temp = UI.createSpriteWithFile("images/featureShadow.png",CCSizeMake(192, 74))
    screen.autoSuitable(temp, {x=88, y=70})
    bg:addChild(temp)
    temp = UI.createSpriteWithFile("images/guideNpc1.png",CCSizeMake(195, 291))
    screen.autoSuitable(temp, {x=72, y=100})
    bg:addChild(temp)
    temp = UI.createLabel(StringManager.getString("labelWarning"), "fonts/font3.fnt", 28, {colorR = 255, colorG = 255, colorB = 255})
    screen.autoSuitable(temp, {x=313, y=355, nodeAnchor=General.anchorLeft})
    bg:addChild(temp)
    temp = UI.createLabel(StringManager.getString("labelTimeLeft"), "fonts/font3.fnt", 25, {colorR = 255, colorG = 255, colorB = 255})
    screen.autoSuitable(temp, {x=311, y=206, nodeAnchor=General.anchorLeft})
    bg:addChild(temp)
    temp = UI.createLabel(StringManager.getString("labelUnderAttack"), "fonts/font1.fnt", 20, {colorR = 0, colorG = 0, colorB = 0, size=CCSizeMake(340, 0), align=kCCTextAlignmentLeft})
    screen.autoSuitable(temp, {x=307, y=331, nodeAnchor=General.anchorLeftTop})
    bg:addChild(temp)
    self.time = leftSeconds
    temp = UI.createLabel(StringManager.getTimeString(leftSeconds), "fonts/font1.fnt", 20, {colorR = 0, colorG = 0, colorB = 0})
    screen.autoSuitable(temp, {x=310, y=173, nodeAnchor=General.anchorLeft})
    bg:addChild(temp)
    self.label = temp
    simpleRegisterEvent(self.view, {update={callback=self.update, inteval=0.5}}, self)
end

function WaitAttackDialog:update(diff)
    self.time = self.time - diff
    self.label:setString(StringManager.getTimeString(math.ceil(self.time)))
end