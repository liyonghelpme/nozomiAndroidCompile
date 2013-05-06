local InfoProcessItem = class()
    
function InfoProcessItem:ctor(number1, number2, max, infoType, infoIcon)
    self.infoType=infoType
    self.max=max
    self.number=number1
    
    self.bg = CCNode:create()
    
    local temp
    
    temp = UI.createSpriteWithFile("images/dialogItemInfoProcessBack.png",CCSizeMake(344, 26))
    screen.autoSuitable(temp, {x=0, y=0})
    self.bg:addChild(temp)
    temp = UI.createSpriteWithFile("images/dialogItemInfoProcessFiller.png",CCSizeMake(340, 22))
    screen.autoSuitable(temp, {x=2, y=2})
    self.bg:addChild(temp,1)
    self.process = temp
    self.processSize = temp:getContentSize()
    self.process:setTextureRect(CCRectMake(0,0,self.processSize.width*self.number/self.max,self.processSize.height))
    
    local numberText = number1
    self.isUpgradeType = number2
    local typeText = "infoType"
    if self.isUpgradeType then
        typeText = "upgradeType"
        if number2>number1 then
            numberText = number1 .. "+" .. (number2-number1)
            temp = UI.createSpriteWithFile("images/dialogItemInfoProcessFiller.png",CCSizeMake(340, 22), true)
            screen.autoSuitable(temp, {x=2, y=2})
            self.bg:addChild(temp)
            temp:setValOffset(20)
            temp:setTextureRect(CCRectMake(0,0,self.processSize.width*number2/self.max,self.processSize.height))
        end
    end
    self.text = UI.createLabel(StringManager.getFormatString(typeText .. infoType, {num=numberText, max=max}), "fonts/font3.fnt", 18)
    screen.autoSuitable(self.text, {nodeAnchor=General.anchorLeft, x=11, y=24})
    self.bg:addChild(self.text,2)
    
    if infoIcon then
        temp = UI.createScaleSprite(infoIcon, CCSizeMake(54, 44))
        screen.autoSuitable(temp, {nodeAnchor=General.anchorRight, x=-7, y=10})
    else
        temp = UI.createSpriteWithFile("images/dialogItemInfo" .. infoType .. ".png")
        screen.autoSuitable(temp, {nodeAnchor=General.anchorRight, x=-7, y=10})
    end
    self.bg:addChild(temp,2)
end
    
function InfoProcessItem:setNumber(number)
    if number~=self.number then
        self.number = number
        local typeText = "infoType"
        if self.isUpgradeType then
            typeText = "upgradeType"
        end
        self.text:setString(StringManager.getFormatString(typeText .. self.infoType, {num=self.number, max=self.max}))
        self.process:setTextureRect(CCRectMake(0,0,self.processSize.width*self.number/self.max,self.processSize.height))
    end
end
    
function UI.addInfoItem(bg, index, number1, number2, max, infoType, infoIcon, delegate)
    local intNumber, needUpdate = number1, false
    if type(number1) == "function" then
        intNumber = number1(delegate)
        needUpdate = true
    end
    local item = InfoProcessItem.new(intNumber, number2, max, infoType, infoIcon)
    screen.autoSuitable(item.bg, {x=349, y=442-index*42})
    bg:addChild(item.bg)
    if needUpdate then
        local updateEntry = {inteval=0.4}
        function updateEntry.callback(diff)
            item:setNumber(number1(delegate))
        end
        simpleRegisterEvent(item.bg, {update=updateEntry})
    end
    return item
end

function UI.addInfoItem2(bg, index, number1, number2, max, infoType, infoIcon, delegate)
    local item = UI.addInfoItem(bg, index, number1, number2, max, infoType, infoIcon, delegate)
    screen.autoSuitable(item.bg, {x=343, y=444-index*47})
    return item
end

function UI.createMenuButton(size, buttonBg, callback, callbackParam, buttonImage, buttonText, fontSize)
    local but = UI.createButton(size, callback, {callbackParam=callbackParam, image=buttonBg, priority=display.MENU_BUTTON_PRI})
    local temp
    
    if buttonImage then
        temp = UI.createSpriteWithFile(buttonImage)
        screen.autoSuitable(temp, {nodeAnchor=General.anchorCenter, x=size.width/2+getParam("xoff" .. buttonText, 0), y=size.height*11/20+getParam("yoff" .. buttonText, 0)})
        but:addChild(temp)
    end
    
    if buttonText then
        temp = UI.createLabel(buttonText, "fonts/font3.fnt", fontSize or 14, {size=CCSizeMake(size.width*0.8, size.height/2), lineOffset=-12})
        screen.autoSuitable(temp, {nodeAnchor=General.anchorCenter, x=size.width/2, y=size.height*1/5})
        but:addChild(temp)
    end
    
    return but
end

function UI.createGuidePointer(angle)
    --local bg = CCNode:create()
    local pt = UI.createSpriteWithFile("images/guidePointer.png")
    pt:setAnchorPoint(General.anchorBottom)
    
    pt:setRotation(angle)
    return pt
end

function UI.setShowAnimate(bg)
    local sx, sy = bg:getScaleX(), bg:getScaleY()
    bg:setScaleX(0.5 * sx)
    bg:setScaleY(0.5 * sy)
    bg:runAction(CCEaseBackOut:create(CCScaleTo:create(0.25, sx, sy)))
end