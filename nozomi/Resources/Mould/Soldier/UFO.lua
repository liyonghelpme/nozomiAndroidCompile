UFO = class(Soldier)

function UFO:ctor()
	local scale = getParam("soldierScale" .. self.info.sid, 100)/100
	self.viewInfo = {scale=scale, x=0, y=130*scale}
end

function UFO:resetFreeState()
	self.displayState.duration = 1.5
	self.displayState.isRepeat = false
	self.displayState.num = 1
	self.displayState.prefix = "soldier" .. self.info.sid .. "_" .. self.data.level .. "_m"
end

function UFO:getFrameEspecially(i)
	return nil
end

-- to override
function UFO:resetOtherState()
	self.displayState.duration = getParam("soldierPoseTime" .. self.info.sid, 500)/1000
	self.displayState.isRepeat = false
	self.displayState.num = 1
	self.displayState.prefix = "soldier" .. self.info.sid .. "_" .. self.data.level .. "_m"
end

-- to override
function UFO:prepareAttack()
	self.stateInfo = {actionTime=self.info.attackSpeed}
	self.stateInfo.attackValue = self:getAttackValue()
	self.stateInfo.attackTime = 0.2
	self.stateInfo.action = "attack"
end

local SHOT_SETTING = {[1]={-58, 6, 28, 40}, [2]={-20, 47, -23, -21}, [3]={-56, 23, 30, -12}, [4]={56,23,-30,-12}, [5]={20, 47, 23, -21}, [6]={58, 6, -28, 40}}

-- to override
function UFO:executeAttack()
	local setting = SHOT_SETTING[self.direction]
	local p = {self.view:getPosition()}
	p[3] = self.scene.SIZEY - p[2]
	p[1] = p[1] + self.viewInfo.x
	p[2] = p[2] + self.viewInfo.y
	local shot = LaserShot2.new(self.stateInfo.attackValue/2, 180, p[1]+setting[1], p[2]+setting[2], p[3], self.attackTarget, math.ceil(self.data.level/2))
	shot:addToScene(self.scene)
	shot = LaserShot2.new(self.stateInfo.attackValue/2, 180, p[1]+setting[3], p[2]+setting[4], p[3], self.attackTarget, math.ceil(self.data.level/2))
	shot:addToScene(self.scene)
	--self.attackTarget:damage(self.stateInfo.attackValue)
end