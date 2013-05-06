Flame = class()

function Flame:ctor(color)
	self.color = color
	self.view = CCSpriteBatchNode:create("images/effects/gun.png", 10)
    local f = ccBlendFunc:new()
	f.src = 1
	f.dst = 1
    self.view:setBlendFunc(f)
	self.lines = {}
	self.updateEntry = {callback=self.update, inteval=0}
	simpleRegisterEvent(self.view, {update=self.updateEntry}, self)
end

function Flame:update(diff)
	local curTime = timer.getTime()
	while #(self.lines)>0 do
		if self.lines[1].time<=curTime then
			self.lines[1].view:removeFromParentAndCleanup(true)
			table.remove(self.lines, 1)
		else
			break
		end
	end
	if #(self.lines) < 10 then
		local sp = CCSprite:create("images/effects/gun.png")
        self.view:addChild(sp)
        sp:setColor(self.color)
        local sx = math.random()*3+2
        sp:setScaleX(sx)
        local deg = math.random()*60-30
        sp:setRotation(deg)

        sp:setAnchorPoint(General.anchorLeft)

        sp:runAction(CCFadeOut:create(0.2))
        table.insert(self.lines, {view=sp, time=curTime+0.2})
	end
end

function UI.createFlameEffect(color)
	color = color or ccc3(254, 81, 0)
	return Flame.new(color)
end