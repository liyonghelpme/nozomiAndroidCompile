AboutDialog = class()

function AboutDialog:ctor()
    local bg = CCLayerColor:create(ccc4(0, 0, 0, 255), General.winSize.width, General.winSize.height)
    self.view = bg
    
    local node = CCNode:create()
    screen.autoSuitable(node, {screenAnchor=General.anchorBottom, scaleType=screen.SCALE_NORMAL})
    self.view:addChild(node)
    
    local temp = UI.createLabel(StringManager.getString("labelCredits"), "fonts/font3.fnt", 50)
    screen.autoSuitable(temp, {nodeAnchor=General.anchorTop, x=0, y=0})
    node:addChild(temp)
    
    local nameList = {"Stc", "Lion", "Ricky", "Fred", "Kyo", "Jack", "FanFan", "Wang Pei"}
    for i, name in ipairs(nameList) do
        temp = UI.createLabel(name, "fonts/font3.fnt", 40)
        screen.autoSuitable(temp, {nodeAnchor=General.anchorTop, x=0, y=-40-60*i})
        node:addChild(temp)
    end
    
    local h = 80+60*(#nameList)
    if h<768 then h = 384+h/2 end
    node:runAction(CCMoveBy:create(h/60, CCPointMake(0, h*node:getScaleY())))
end