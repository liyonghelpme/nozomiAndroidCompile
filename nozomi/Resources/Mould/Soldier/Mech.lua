Mech = class(Soldier)


function Mech:ctor()
	local scale = getParam("soldierScale" .. self.info.sid, 100)/100
	self.viewInfo = {scale=scale, x=0, y=30*scale}
end

-- to override
function Mech:resetOtherState()
	if self.stateInfo.action == "pose" then
		self.displayState.duration = getParam("soldierPoseTime" .. self.info.sid, 500)/1000
		self.displayState.isRepeat = false
		self.displayState.num = 5
		self.displayState.prefix = "soldier" .. self.info.sid .. "_" .. self.data.level .. "_p"
	elseif self.stateInfo.action == "attack1" or self.stateInfo.action == "attack2" then
		local atype = string.sub(self.stateInfo.action, -1)
		self.displayState.duration = 1.6
		self.displayState.isRepeat = false
		self.displayState.reverse = true
		self.displayState.num = 16
		self.displayState.prefix = "soldier" .. self.info.sid .. "_" .. self.data.level .. "_a" .. atype .. "_"
	end
end

-- to override
function Mech:prepareAttack()
	self.stateInfo = {actionTime=self.info.attackSpeed}
	self.stateInfo.attackValue = self:getAttackValue()
	local atype = math.random(2)
	self.stateInfo.attackTime = 1.6 * (8+atype)/16
	self.stateInfo.action = "attack" .. atype
end


function Mech:resetMoveState()
	self.displayState.duration = 0.35
	self.displayState.isRepeat = false
	self.displayState.num = 7
	self.displayState.reverse = false
	self.displayState.prefix = "soldier" .. self.info.sid .. "_" .. self.data.level .. "_m"
end

function Mech:addShadow()
	local temp = UI.createSpriteWithFile("images/personShadow.png")
	temp:setScale(0.6)
	screen.autoSuitable(temp, {nodeAnchor=General.anchorCenter})
	self.view:addChild(temp)
end
