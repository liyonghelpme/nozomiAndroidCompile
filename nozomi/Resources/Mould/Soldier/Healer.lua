Healer = class(Soldier)

function Healer:ctor()
	local scale = getParam("soldierScale" .. self.info.sid, 100)/100
	self.viewInfo = {scale=scale, x=0, y=80*scale}
	self.coldTime = 0
end

function Healer:getFrameEspecially(i)
	if self.stateInfo.action ~= "pose" then
		return nil
	end
	if i>=5 then
		if i<12 then
			i = 4
		elseif i<15 then
			i = i-7
		else
			i = 0
		end
	end
	return i
end

function Healer:resetFreeState()
	self.displayState.duration = 1.5
	self.displayState.isRepeat = true
	self.displayState.num = 15
	self.displayState.prefix = "soldier" .. self.info.sid .. "_" .. self.data.level .. "_m"
end

-- to override
function Healer:resetOtherState()
	if self.stateInfo.action == "pose" then
		self.displayState.duration = getParam("soldierPoseTime" .. self.info.sid, 500)/1000
		self.displayState.isRepeat = false
		self.displayState.num = 5
		self.displayState.prefix = "soldier" .. self.info.sid .. "_" .. self.data.level .. "_a"
	elseif self.stateInfo.action == "attack" then
		self.displayState.duration = self.info.attackSpeed
		self.displayState.isRepeat = false
		self.displayState.num = 15
		self.displayState.prefix = "soldier" .. self.info.sid .. "_" .. self.data.level .. "_a"
	end
end

-- to override
function Healer:prepareAttack()
	self.stateInfo = {actionTime=self.info.attackSpeed}
	self.stateInfo.attackValue = self:getAttackValue()
	self.stateInfo.attackTime = self.info.attackSpeed*3/15
	self.stateInfo.action = "attack"
end

local SHOT_SETTING={{3,-7}, {9, -5}, {4, -1}, {-4, -1}, {-9,-5}, {-3,-7}}

-- to override
function Healer:executeAttack()
	local setting = SHOT_SETTING[self.direction]
	local p = {self.view:getPosition()}
	p[1] = p[1] + self.viewInfo.x + setting[1]
	p[2] = p[2] + self.viewInfo.y + setting[2]
	local tx, ty = self.attackTarget.view:getPosition()
	ty = ty+self.attackTarget.view:getContentSize().height/2
	local shot = HealthSplash.new(-self.stateInfo.attackValue, 90, p[1], p[2], tx, ty, 1, GroupTypes.Defense, 1)
	shot:addToScene(self.scene)
end

function Healer:addShadow()
	local temp = UI.createSpriteWithFile("images/personShadow.png")
	temp:setScale(0.3)
	temp:setOpacity(80)
	screen.autoSuitable(temp, {nodeAnchor=General.anchorCenter})
	self.view:addChild(temp)
end

function Healer:updateState(diff)
	if self.isFighting then
		if BattleLogic.battleEnd then
			self:setDeadView()
		elseif not self.attackTarget or self.attackTarget.deleted or self.attackTarget.hitpoints==self.attackTarget.data.hitpoints then
			if not self.attackTarget and self.coldTime>0 then
				self.coldTime = self.coldTime - diff
				return false
			end
			local target
			local min
			
			-- 获取起点，都相同
			local fx, fy = self.view:getPosition()
			min = 80
			
			for _, soldier in pairs(self.scene.soldiers) do
				if not soldier.deleted and soldier.info.unitType==1 and soldier.hitpoints < soldier.data.hitpoints then
					local tx, ty = soldier.view:getPosition()
					local dis = self.scene.mapGrid:getGridDistance(tx-fx, ty-fy)
					if dis < min then
						min = dis
						target = soldier
					end
				end
			end
			
			if target then
				self.coldTime = 0
				self.attackTarget = target
				if min<=self.info.range then
					self:setAttack()
					return true
				end
				
				local tx, ty = self.attackTarget.view:getPosition()
				self:moveDirect(tx, ty, true)
			else
				self.coldTime = 0.1
				self.state = PersonState.STATE_FREE
			end
		elseif self.state == PersonState.STATE_FREE or self.state == PersonState.STATE_MOVING then
			local tx, ty = self.attackTarget.view:getPosition()
			local fx, fy = self.view:getPosition()
			local dis = self.scene.mapGrid:getGridDistance(tx-fx, ty-fy)
			if dis < self.info.range then
				self:setAttack()
			else
				self:moveDirect(tx, ty, true)
			end
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
					local tx, ty = self.attackTarget.view:getPosition()
					local fx, fy = self.view:getPosition()
					local dis = self.scene.mapGrid:getGridDistance(tx-fx, ty-fy)
					if dis < self.info.range then
						self:setAttack()
					else
						self:moveDirect(tx, ty, true)
					end
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