MyStrokeFont = {}

--直接给CCLabelTTF 字体 添加阴影 大小 和 颜色
function MyStrokeFont:createFont(label, shadowSize, shadowColor)
    local rt = MyStrokeFont:createShadow(label, shadowSize, shadowColor)
    label:addChild(rt, -1)
    return label
end

--CCLabelTTF  阴影大小size 阴影颜色ccc3
--返回CCRenderTexture 直接添加到Font 上 
function MyStrokeFont:createShadow(label, size, cor)
    local texture = label:getTexture()
    local cs = texture:getContentSize()
    local anchorPoint = label:getAnchorPoint()

    local rt = CCRenderTexture:create(cs.width+size*2, cs.height+size*2, kTexture2DPixelFormat_RGBA8888)
    local originalPos = label:getPosition()
    local originalColor = label:getColor()
    local originalScaleX = label:getScaleX()
    local originalScaleY = label:getScaleY()
    local originalVisibility = label:isVisible()
    local originalBlend = label:getBlendFunc()

    label:setColor(cor)
    label:setScale(1)
    label:setVisible(true)
    local blendFunc = ccBlendFunc:new()
    blendFunc.src = 0x0302
    blendFunc.dst = 1
    label:setBlendFunc(blendFunc)

    local bottomLeft = ccp(
                            cs.width*anchorPoint.x+size, 
                                cs.height*anchorPoint.y+size)
    local positionOffset = ccp(cs.width/2, cs.height/2)
    rt:begin()
    --根据字体大小 调整迭代的次数 22 号字体迭代8次
    for  i = 0, 360, 45 do
        label:setPosition(ccp(
                        bottomLeft.x+math.sin(i*0.0174533)*size, 
                        bottomLeft.y+math.cos(i*0.0174533)*size))
        label:visit()
    end
    rt:endToLua()

    label:setPosition(originalPos)
    label:setColor(originalColor)
    label:setBlendFunc(originalBlend)
    label:setVisible(originalVisibility)
    
    label:setScaleX(originalScaleX)
    label:setScaleY(originalScaleY)

    rt:setPosition(positionOffset)
    return rt
end

function MyStrokeFont:test()
    local label = CCLabelTTF:create("Hello World", "Arial", 22)
    label = MyStrokeFont:createFont(label, 2, ccc3(15, 15, 15))
    label:setPosition(ccp(200, 200))
    return label
end