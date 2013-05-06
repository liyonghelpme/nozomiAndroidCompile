Archer = class(Soldier)

-- to override
function Archer:resetOtherState()
	if self.stateInfo.action == "pose" then
		self.displayState.duration = getParam("soldierPoseTime" .. self.info.sid, 500)/1000
		self.displayState.isRepeat = false
		self.displayState.num = 5
		self.displayState.prefix = "soldier" .. self.info.sid .. "_" .. self.data.level .. "_p"
	elseif self.stateInfo.action == "attack" then
		self.displayState.duration = self.info.attackSpeed
		self.displayState.isRepeat = false
		--self.displayState.reverse = true
		self.displayState.num = 15
		self.displayState.prefix = "soldier" .. self.info.sid .. "_" .. self.data.level .. "_a"
	end
end

-- to override
function Archer:prepareAttack()
	self.stateInfo = {actionTime=self.info.attackSpeed}
	self.stateInfo.attackValue = self:getAttackValue()
	self.stateInfo.attackTime = self.info.attackSpeed*3/15
	self.stateInfo.action = "attack"
end

local SHOT_SETTING={[1]={13, -28, 1}, [2]={30, -7, -1}, [3]={12, 10, -1}, [4]={-12, 10, -1}, [5]={-30, -7, -1}, [6]={-13, -28, 1}}

-- to override
function Archer:executeAttack()
	local setting = SHOT_SETTING[self.direction]
	local p = {self.view:getPosition()}
	p[3] = self.scene.SIZEY - p[2]+setting[3]
	p[1] = p[1] + self.viewInfo.x + setting[1]
	p[2] = p[2] + self.viewInfo.y + setting[2]
	local shot = LaserShot.new(self.stateInfo.attackValue, 180, p[1], p[2], p[3], self.attackTarget, math.ceil(self.data.level/2), 0.4)
	shot:addToScene(self.scene)
end