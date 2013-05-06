require "Util.Class"

local BUILDING_ACTION = {[1]={16, -30, 1}, [2]={45, -7, 0}, [3]={30, 23, -1}, [4]={-30, 23, -1}, [5]={-45, -7, 0}, [6]={-16, -30, 1}}

local FLAME_ACTION = {[1]={{0, -18, 170}, {1, -19, 135}, {3, -21, 100}, {5, -23, 90}},
	[2]={{-5, -17, 150}, {-1, -19, 120}, {3, -19, 100}, {5, -21, 90}},
	[3]={{0, -18, 105}, {1, -20, 100}, {2, -20, 95}, {5, -18, 90}},
	[4]={{0, -18, 75}, {-1, -20, 80}, {-2, -20, 85}, {-5, -18, 90}},
	[5]={{5, -17, 30}, {1, -19, 60}, {-3, -19, 80}, {-5, -21, 90}},
	[6]={{0, -18, 10}, {-1, -19, 45}, {-3, -21, 80}, {-5, -23, 90}}}

local YOFF=5

Builder = class(Person)

function Builder:ctor()
	local sinfo = {moveSpeed=20, unitType=2}
	self:initWithInfo(sinfo)
	
	self.viewInfo = {scale=1, x=0, y=35}
	self.plistFile = "animate/builder/builder.plist"
end

function Builder:updateState()
	if self.state==PersonState.STATE_FREE then
		if self.target then
			self:setBuildAction()
		else
			self.direction = 6
		end
		self.stateTime = 0
	elseif self.state==PersonState.STATE_OTHER and self.stateInfo.action=="build" then
		if self.stateInfo.actionTime<self.stateTime then
			self:randomBuild()
		elseif self.stateTime>=0.6 and not self.action then
			local ainfo = BUILDING_ACTION[self.direction]
			local psize = self.personView:getContentSize()
			self.action = UI.createAnimateWithSpritesheet(1.6, "builderAction_", 15, {plist="animate/builder/builderAction.plist"})
			screen.autoSuitable(self.action, {nodeAnchor=General.anchorCenter, x=self.viewInfo.x+ainfo[1], y=self.viewInfo.y+ainfo[2]+YOFF})
			self.view:addChild(self.action, ainfo[3])
		end
	end
end

function Builder:randomBuild()
	if self.target then
		self.stateTime = 0
		local x, y = self:getMoveArroundPosition(self.target)
		self:moveDirect(x, y, true)
	else
	
	end
end

function Builder:returnHome()
	if self.home then
		local x, y = self.home.buildView.view:getPosition()
		y = y + getParam("builderOffy", 70)
		self:moveDirect(x, y, true)
	else
		self.deleted = true
		local t = getParam("actionTimeBuildChip", 1500)/1000
		local x, y = self.view:getPosition()
		y = y + self.viewInfo.y
		local bomb = UI.createAnimateSprite(t, "animate/build/bombChip_", 29, {isRepeat=false})
		bomb:setScale(0.4)
		screen.autoSuitable(bomb, {nodeAnchor=General.anchorCenter, x=x, y=y})
		self.scene.ground:addChild(bomb, self.scene.SIZEY-y)
		delayRemove(t, bomb)
		self.view:removeFromParentAndCleanup(true)
	end
end

function Builder:getFrameEspecially(i)
	if self.state==PersonState.STATE_MOVING then
		if i>3 then i=3 end
		return 3-i
	elseif self.state == PersonState.STATE_FREE then
		return 3
	else
		if i>4 then i=4 end
		return 3+i
	end
	return nil
end

function Builder:onChange(dir, i)
	if self.state == PersonState.STATE_FREE then
		if self.flame then
			self.flame:removeFromParentAndCleanup(true)
			self.flame = nil
		end
	else
		if not self.flame then
			self.flame = UI.createAnimateWithSpritesheet(getParam("flameActionTime", 1000)/1000, "flame_", 19, {plist="animate/builder/flame.plist"})
			screen.autoSuitable(self.flame, {nodeAnchor=General.anchorTop})
			self.flame:setScaleX(0.5)
			self.flame:setScaleY(0.4)
			self.view:addChild(self.flame, -1)
		end
		if i>3 then i=3 end
		local setting = FLAME_ACTION[dir][i+1]
		self.flame:setPosition(setting[1]+self.viewInfo.x, setting[2]+self.viewInfo.y+YOFF)
		self.flame:setRotation(setting[3]-90)
	end
end

function Builder:setBuildAction()
	self.state = PersonState.STATE_OTHER
	local fx, fy = self.view:getPosition()
	local tx, ty = self.target.buildView.view:getPositionX(), self.target.buildView.view:getPositionY() + self.target.buildView.view:getContentSize().height/2
	self:changeDirection(tx-fx, ty-fy)
	self.stateInfo = {actionTime=1+math.random(4)}
	self.stateInfo.action = "build"
end

function Builder:resetFreeState()

			if self.action then
				self.action:removeFromParentAndCleanup(true)
				self.action = nil
			end
	self.displayState.duration = 0.1
	self.displayState.isRepeat = false
	self.displayState.num = 1
	self.displayState.prefix = "builder_a"
end

function Builder:resetMoveState()

			if self.action then
				self.action:removeFromParentAndCleanup(true)
				self.action = nil
			end
	self.displayState.duration = 0.4
	self.displayState.isRepeat = false
	self.displayState.num = 4
	self.displayState.prefix = "builder_a"
	
end

function Builder:resetOtherState()
	if self.stateInfo.action == "build" then
		self.displayState.duration = 0.5
		self.displayState.isRepeat = false
		self.displayState.num = 5
		self.displayState.prefix = "builder_a"
	end
end

function Builder:addShadow()
	local temp = UI.createSpriteWithFile("images/personShadow.png")
	temp:setScale(0.4)
	temp:setOpacity(160)
	screen.autoSuitable(temp, {nodeAnchor=General.anchorCenter})
	self.view:addChild(temp, -2)
end