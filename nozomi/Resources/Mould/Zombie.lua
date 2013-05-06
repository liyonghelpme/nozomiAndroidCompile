Zombie = class(Soldier)

local ZombieSetting = {[1]={0.75, 15}, [2]={0.55, 11}, [3]={0.5, 15, 0.5}, [4]={0.5, 10, 0.5}, [5]={0.55, 11, 0.5}, [6]={0.7, 10, 0.7}, [7]={0.77,11,0.7}, [8]={0.8, 10, 0.7}}
local ZombieViewInfo = {[1]={0, 16}, [2]={0, 20}, [3]={0, 8}, [4]={0, 40}, [5]={0, 20}, [6]={0,25}, [7]={0,20}, [8]={0, 20}}
local ZombieAttack = {[1]={13, 10}, [2]={13, 10}, [3]={10, 6}, [4]={10, 7}, [5]={13 , 9}, [6]={9, 9}, [7]={13,8}, [8]={11, 5}}

-- 经营页面的僵尸
function Zombie:ctor(sid, setting, settingScale)
	settingScale = settingScale or 1
	self.scaleSetting = settingScale
	local info = copyData(StaticData.getSoldierInfo(sid))
	info.moveSpeed = info.moveSpeed * self.scaleSetting
	self:initWithInfo(info)
	self.sid = sid-10
	self.mapGrid = setting.mapGrid
	local scale = getParam("zombieScale" .. sid, 100)/100 * settingScale
	self.viewInfo = {scale=scale, x=ZombieViewInfo[self.sid][1], y=ZombieViewInfo[self.sid][2]*scale}
	self.plistFile = "animate/zombie/zombie" .. self.sid .. ".plist"
end

function Zombie:getInitPos()
	local x, y = nil
	while not (x and y) do
		local gx, gy = math.random(23), math.random(23)
		if not self.mapGrid:checkGridEmpty(GridKeys.Build, gx, gy, 1) then
			local position = self.mapGrid:convertToPosition(gx+math.random(), gy+math.random())
			x, y = position[1], position[2]
		end
	end
	return {x, y}
end

function Zombie:resetFreeState()
	if self.info.unitType==2 then
		local setting = ZombieSetting[self.sid]
		self.displayState.duration = setting[1]
		self.displayState.isRepeat = true
		self.displayState.num = setting[2]
		self.displayState.prefix = "zombie" .. self.sid .. "_m"
	else
		self.displayState.duration = 1
		self.displayState.isRepeat = false
		self.displayState.num = 1
		self.displayState.prefix = "zombie" .. self.sid .. "_a"
	end
end
	
function Zombie:resetMoveState()
	local setting = ZombieSetting[self.sid]
	self.displayState.duration = setting[1]
	self.displayState.isRepeat = true
	self.displayState.num = setting[2]
	self.displayState.prefix = "zombie" .. self.sid .. "_m"
end

function Zombie:getFrameEspecially(i)
	if self.special and self.stateInfo.action == "attack" then
		return 8
	end
end

function Zombie:resetOtherState()
	self.displayState.isRepeat = false
	self.displayState.reverse = true
	local times = ZombieAttack[self.sid]
	local ttime = times[1]
	if ttime>self.info.attackSpeed*10 then
		ttime = self.info.attackSpeed*10
	end
	self.displayState.num = times[1]
	self.displayState.duration = ttime/10
	self.displayState.prefix = "zombie" .. self.sid .. "_a"
end
	
function Zombie:randomMove()
	local x, y = self.view:getPosition()
	if self.off then
		local tx, ty = x+self.off[1], y+self.off[2]
		local tgrid = self.mapGrid:convertToGrid(tx, ty, 1)
		if self.moveTimes>5 or self.mapGrid:checkGridEmpty(GridKeys.Build, tgrid.gridPosX, tgrid.gridPosY, 1) then
			self.off = nil
		else
			self.moveTimes = self.moveTimes + 1
			self.stateTime = self.backTime
			self.stateInfo = self.backStateInfo
			self:moveDirect(tx, ty)
			return true
		end
	end
	self.moveTimes = 1
	local grid = self.mapGrid:convertToGrid(x, y, 1)
	local dir = math.random(8)
	local dirs = {{0, 1}, {1, 1}, {1, 0}, {1, -1}, {0, -1}, {-1, -1}, {-1, 0}, {-1, 1}}
	for i=1, 8 do
		local tdir = dirs[(i+dir-2)%8+1]
		if not self.mapGrid:checkGridEmpty(GridKeys.Build, grid.gridPosX+tdir[1], grid.gridPosY+tdir[2], 1) then
			local position = self.mapGrid:convertToPosition(grid.gridPosX+tdir[1]+math.random(), grid.gridPosY+tdir[2]+math.random())
			self.off = {position[1]-x, position[2]-y}
			self:moveDirect(position[1], position[2])
			return true
		end
	end
end

-- to override
function Zombie:prepareAttack()
	self.stateInfo = {actionTime=self.info.attackSpeed}
	self.stateInfo.attackValue = self:getAttackValue()
	if self.sid==6 then
		self.stateInfo.attackValue = self.stateInfo.attackValue/9
		if self.special or self.specialFlag then
			self.special = true
			self.specialFlag = nil
			self.stateInfo.actionTime = self.stateInfo.actionTime/9
			self.stateInfo.attackTime = self.info.attackSpeed/9
			self.stateInfo.action = "attack"
			return
		end
		self.special = nil
		self.specialFlag = true
	end
	local times = ZombieAttack[self.sid]
	local ttime = times[1]
	if ttime>self.info.attackSpeed*10 then
		ttime = self.info.attackSpeed*10
	end
	self.stateInfo.attackTime = ttime/10*times[2]/times[1]
	self.stateInfo.action = "attack"
end

	
function Zombie:updateState(diff)
	if self.scene.sceneType==SceneTypes.Operation then
		if self.state == PersonState.STATE_FREE then
			self:randomMove()
		end
	else
		if ZombieLogic.battleEnd then
			self:setDeadView()
		elseif self.state ~= PersonState.STATE_OTHER or self.stateInfo.actionTime < self.stateTime then
			if not self.attackTarget or self.attackTarget.buildMould.buildState==BuildStates.STATE_DESTROY then
				local target
				local w = self.scene.mapWorld
				local truePath
				
				-- 获取起点，都相同
				local fx, fy = self.view:getPosition()
				local grid = self.scene.mapGrid:convertToGrid(fx, fy, 1, 2)
				local startPoint = {grid.gridPosX, grid.gridPosY}
			
				w:clearWorld()
				w:putStart(startPoint[1], startPoint[2])
				local path, target, lastPoint = w:searchAttack(self.info.range*2, grid.gridFloatX, grid.gridFloatY)
				if lastPoint then
					local position = self.scene.mapGrid:convertToPosition(lastPoint[1]/2, lastPoint[2]/2)
					local tx, ty = position[1] , position[2]
					truePath = self:getTruePath(path, w, self.scene.mapGrid, fx, fy, tx, ty)
				end	
					
				if target then
					self.attackTarget = target
					if truePath then
						local firstPoint = table.remove(truePath, 1)
						self.stateInfo = {movePath = truePath}
						if self.state~=PersonState.STATE_MOVING then
							self.stateTime = 0
						end
						self:moveDirect(firstPoint[1], firstPoint[2], true)
					else
						self:setAttack()
						return true
					end
				else
					self:setDeadView()
				end
			elseif self.state == PersonState.STATE_FREE then
				self:setAttack()
				return true
			elseif self.state == PersonState.STATE_OTHER then
			 	if self.stateInfo.attackTime and self.stateInfo.attackTime<self.stateTime then
			 		self.stateInfo.attackTime = nil
			 		self:executeAttack()
			 	end
				self:setAttack()
				return true
			end
		elseif self.state == PersonState.STATE_OTHER then
		 	local action = self.stateInfo.action
		 	if not action then
		 		print("zombie error")
		 		while true do end
		 	end
		 	local pb = string.find(action, "attack")
		 	if pb==1 then
			 	if self.stateInfo.attackTime and self.stateInfo.attackTime<self.stateTime then
			 		self.stateInfo.attackTime = nil
			 		self:executeAttack()
			 	end
		 		--if self.stateInfo.actionTime < self.stateTime then
			 	--	self:setAttack()
			 	--	return true
			 	--end
			 end
		end
		if diff==0 then
			-- 入场后的掉落动画，先不实现
		end
	end
end

function Zombie:addShadow()
	local temp = UI.createSpriteWithFile("images/personShadow.png")
	temp:setScale((ZombieSetting[self.sid][3] or 0.25)*self.scaleSetting)
	if self.info.unitType==2 then
		temp:setOpacity(100)
	end
	screen.autoSuitable(temp, {nodeAnchor=General.anchorCenter})
	self.view:addChild(temp)
end

BIRD_SETTING={[1]={17, -29}, [2]={35, -5}, [3]={13,15}, [4]={-13,15}, [5]={-35, -5}, [6]={-17,-29}}
GUN_SETTING={[1]={36,-8, 0, -30}, [2]={38,22, 0, 0}, [3]={7,33,-1,30}, [4]={-7,33,-1,150}, [5]={-38,22, 0, 180}, [6]={-36,-8,0,-150}}
MISSILE_SETTING={[1]={16, -35}, [2]={43, -9}, [3]={24,15}, [4]={-24,15}, [5]={-43, -9}, [6]={-16,-35}}

function Zombie:executeAttack()
	if self.info.attackType==2 then
	
		local p = {self.view:getPosition()}
		p[3] = self.scene.SIZEY - p[2]
		p[1] = p[1] + self.viewInfo.x
		p[2] = p[2] + self.viewInfo.y
		local shot
		if self.sid==4 then
			local setting = BIRD_SETTING[self.direction]
			shot = PoisonShot.new(self.stateInfo.attackValue, 60, p[1] + setting[1], p[2] + setting[2], p[3], self.attackTarget)
			shot:addToScene(self.scene)
		elseif self.sid==6 then
			local setting = GUN_SETTING[self.direction]
			self.atype = (self.atype or 0)%2+1
			shot = GunShot.new(self.stateInfo.attackValue, 60, p[1] + setting[1], p[2] + setting[2], p[3]+setting[3], self.attackTarget, self.atype, setting[4])
			shot:addToScene(self.scene)
		elseif self.sid==8 then
			local setting = MISSILE_SETTING[self.direction]
			shot = MissileShot.new(self.stateInfo.attackValue, 60, p[1] + setting[1], p[2] + setting[2], p[3], self.attackTarget)
			shot:addToScene(self.scene)
		end
	else
		self.attackTarget:damage(self.stateInfo.attackValue)
	end
end