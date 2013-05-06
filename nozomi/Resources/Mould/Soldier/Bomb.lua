Bomb = class(Soldier)

function Bomb:ctor()
	local scale = getParam("soldierScale" .. self.info.sid, 100)/100
	self.viewInfo = {scale=scale, x=0, y=20*scale}
end

-- to override
function Bomb:resetOtherState()
	if self.stateInfo.action == "pose" then
		self.displayState.duration = getParam("soldierPoseTime" .. self.info.sid, 500)/1000
		self.displayState.isRepeat = false
		self.displayState.num = 5
		self.displayState.prefix = "soldier" .. self.info.sid .. "_" .. self.data.level .. "_p"
	elseif self.stateInfo.action == "attack"  then
		self.displayState.duration = 0.9
		self.displayState.isRepeat = false
		self.displayState.num = 9
		self.displayState.prefix = "soldier" .. self.info.sid .. "_" .. self.data.level .. "_a"
	end
end

-- to override
function Bomb:prepareAttack()
	self.stateInfo = {actionTime=self.info.attackSpeed}
	self.stateInfo.attackValue = self:getAttackValue()
	self.stateInfo.attackTime = self.info.attackSpeed
	self.stateInfo.action = "attack"
end

-- to override
function Bomb:executeAttack()
	self.attackTarget:damage(self.stateInfo.attackValue)
	
	local x, y = self.view:getPosition()
	y = self.viewInfo.y + y
	
	local t=0.9
	local bomb = UI.createAnimateWithSpritesheet(t, "bombRobot_", 8, {plist="animate/soldiers/5/bombRobot.plist"})
	screen.autoSuitable(bomb, {nodeAnchor=General.anchorCenter, x=x, y=y})
	self.scene.ground:addChild(bomb, self.scene.SIZEY-y+1)
	delayRemove(t, bomb)
	
	t=1.4
	bomb = UI.createAnimateWithSpritesheet(t, "bombNormal_", 13, {plist="animate/bombNormal.plist"})
	screen.autoSuitable(bomb, {nodeAnchor=General.anchorCenter, x=x, y=y})
	self.scene.ground:addChild(bomb, self.scene.SIZEY-y)
	delayRemove(t, bomb)
	
	self:damage(self.hitpoints)
end

function Bomb:updateState(diff)
	if self.isFighting then
		if BattleLogic.battleEnd then
			self:setDeadView()
		elseif not self.attackTarget or self.attackTarget.buildMould.buildState==BuildStates.STATE_DESTROY then
			local target
			local truePath
			local min
			
			-- 获取起点，都相同
			local fx, fy = self.view:getPosition()
			local grid = self.scene.mapGrid:convertToGrid(fx, fy, 1)
			min = 80
			
			for gkey, build in pairs(self.scene.walls) do
				if not build.deleted then
					local gx, gy = math.floor(gkey/10000), gkey%10000
					local dis = math.abs(gx-grid.gridPosX)+math.abs(gy-grid.gridPosY)
					if dis < min then
						min = dis
						target = build.buildView
					end
				end
			end
			
			if target then
				local tx, ty = target.view:getPosition()
				ty = ty+target.view:getContentSize().height/2
				local ox, oy = fx-tx, fy-ty
				local angle = math.atan2(oy/self.scene.mapGrid.sizeY, ox/self.scene.mapGrid.sizeX)
				tx = tx+math.cos(angle)*self.scene.mapGrid.sizeX
				ty = ty+math.cos(angle)*self.scene.mapGrid.sizeY
				
				self.attackTarget = target
				self:setMoveTarget(tx, ty)
			else
				self:setDeadView()
			end
		elseif self.state == PersonState.STATE_FREE then
			self:setAttack()
			return true
		elseif self.state == PersonState.STATE_OTHER then
		 	local action = self.stateInfo.action
		 	if not action then
		 		print("error")
		 	end
		 	local pb = string.find(action, "attack")
		 	if pb==1 then
			 	if self.stateInfo.attackTime and self.stateInfo.attackTime<self.stateTime then
			 		self.stateInfo.attackTime = nil
			 		self:executeAttack()
			 	end
		 		if not self.deleted and self.stateInfo.actionTime < self.stateTime then
			 		self:setAttack()
			 		return true
			 	end
			 end
		end
		if diff==0 then
			-- 入场后的掉落动画，先不实现
		end
	else
		if self.state == PersonState.STATE_FREE then
			if self.stateTime > getParam("soldierFreeTime", 1500)/1000 then
				self.stateTime = 0
				if math.random()>0.5 then
					self:setMoveArround()
					return true
				end
			end
		elseif self.state == PersonState.STATE_OTHER and self.stateTime > self.stateInfo.actionTime then
			if self.stateInfo.action=="pose" then
				self.stateTime = 0
				self.state = PersonState.STATE_FREE
				self.stateInfo.action = "free"
				self.direction = 1
			end
			self:resetPersonView()
			return true
		end
	end
end