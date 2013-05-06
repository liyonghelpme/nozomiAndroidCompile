Wizard = class(Soldier)

function Wizard:ctor()
	local scale = getParam("soldierScale" .. self.info.sid, 100)/100
	self.viewInfo = {scale=scale, x=0, y=20*scale}
end

function Wizard:getFrameEspecially(i)
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

-- to override
function Wizard:resetOtherState()
	if self.stateInfo.action == "pose" then
		self.displayState.duration = getParam("soldierPoseTime" .. self.info.sid, 500)/1000
		self.displayState.isRepeat = false
		self.displayState.num = 5
		self.displayState.prefix = "soldier" .. self.info.sid .. "_" .. self.data.level .. "_p"
	elseif self.stateInfo.action == "attack"  then
		self.displayState.duration = self.info.attackSpeed
		self.displayState.isRepeat = false
		self.displayState.num = 10
		self.displayState.prefix = "soldier" .. self.info.sid .. "_" .. self.data.level .. "_a"
	end
end

-- to override
function Wizard:prepareAttack()
	self.stateInfo = {actionTime=self.info.attackSpeed}
	self.stateInfo.attackValue = self:getAttackValue()
	self.stateInfo.attackTime = self.info.attackSpeed*5/10
	self.stateInfo.action = "attack"
end

local SHOT_SETTING = {{5,-7,1}, {16,2,-1}, {9,11,-1}, {-9,11,-1}, {-16,2,-1}, {-5,-7,1}}

-- to override
function Wizard:executeAttack()
	local setting = SHOT_SETTING[self.direction]
	local p = {self.view:getPosition()}
	p[3] = self.scene.SIZEY - p[2]+setting[3]
	p[1] = p[1] + self.viewInfo.x + setting[1]
	p[2] = p[2] + self.viewInfo.y + setting[2]
	local shot = MagicSplash.new(self.stateInfo.attackValue, 180, p[1], p[2], nil, nil, 0, GroupTypes.Attack, 1, self.attackTarget)
	shot:addToScene(self.scene)
end