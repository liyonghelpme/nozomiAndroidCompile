require "Mould.Person"


SoldierHelper = {}

SoldierHelper.headPos = {[1]={x=4, y=10}, [2]={x=1, y=10}, [3]={x=-19, y=9}, [4]={x=-2, y=9}, [5]={x=0,y=11}, 
						[6]={x=-3, y=18}, [7]={x=-17,y=10},[8]={x=26, y=10}, [9]={x=-7,y=13},[10]={x=6, y=9}}
SoldierHelper.featurePos = {[1]={x=-53, y=122}, [2]={x=0, y=124}, [3]={x=47, y=165}, [4]={x=-26, y=133}, [5]={x=45, y=168}, 
						[6]={x=28, y=141}, [7]={x=17, y=123},[8]={x=51, y=124}, [9]={x=30, y=128},[10]={x=-20, y=121}}	
						
SoldierHelper.moveAction = {[1]={t=1, m=10}, [2]={t=1, m=10}, [3]={t=0.3, m=3}, [4]={t=1.1, m=11}, [5]={t=0.7, m=7},
							[6]={t=1, m=1}, [7]={t=1, m=10}, [8]={t=1.5, m=15}, [9]={t=1, m=1}, [10]={t=1, m=10}}

function SoldierHelper.addSoldierHead(bg, sid, scale)
	local head = UI.createSpriteWithFile("images/soldierHead" .. sid .. ".png")
	local p=copyData(SoldierHelper.headPos[sid])
	p.scale = scale
	screen.autoSuitable(head, p)
	bg:addChild(head)
	return head
end

function SoldierHelper.addSoldierFeature(bg, sid)
	local temp = UI.createSpriteWithFile("images/soldierFeature" .. sid .. ".png")
	screen.autoSuitable(temp, SoldierHelper.featurePos[sid])
	bg:addChild(temp)
end

Soldier = class(Person)

function Soldier:ctor(sid, setting)
	local params = setting or {}
	local sinfo = StaticData.getSoldierInfo(sid)
	--sinfo.unitType=2
	self:initWithInfo(sinfo)
	local level = params.level or 1
	self.data = StaticData.getSoldierData(sid, level)
	self.hitpoints = self.data.hitpoints
	
	local scale = getParam("soldierScale" .. sid, 100)/100
	if sinfo.sid==1 then
		self.viewInfo = {scale=scale, x=0, y=17.5*scale}
	elseif sinfo.sid==2 then
		self.viewInfo = {scale=scale, x=0, y=17.5*scale}
	elseif sinfo.sid==3 then
		self.viewInfo = {scale=scale, x=0, y=17.5*scale}
	else
		self.viewInfo = {scale=scale, x=0, y=17.5*scale}
	end
	if params.arround then
		self.moveArround = params.arround
	end
	self.isFighting = params.isFighting
	self.plistFile = "animate/soldiers/soldier" .. self.info.sid .. "_" .. level .. ".plist"

    --当士兵距离军旗较远距离的时候
    --设定移动目标之后 等待移动时间 之后再次检测距离
    self.moveTime = 0
    self.moveYet = false
end
	
function Soldier:getInitPos()
	if self.moveArround then
		return {self:getMoveArroundPosition(self.moveArround)}
	end
end

function Soldier:damage(value)
	if self.deleted then return end
	self.hitpoints = self.hitpoints - value
	if self.hitpoints > self.data.hitpoints then
		self.hitpoints = self.data.hitpoints
	end
	if not self.blood and self.hitpoints > 0 then
		self.blood = UI.createBloodProcess(self.data.hitpoints, false)
		screen.autoSuitable(self.blood.view, {nodeAnchor=General.anchorBottom, x=self.view:getContentSize().width/2+self.viewInfo.x, y=self.viewInfo.y+50})
		self.view:addChild(self.blood.view, 100)
	end
	if self.blood then
		self.blood:changeValue(self.hitpoints)
	end
	if self.hitpoints <= 0 then
		self.hitpoints = 0
		if self.stateInfo.action~="dead" then
			self:setDeadView()
		end
	end
end

function Soldier:setDeadView()
	if self.blood then
		self.blood.view:removeFromParentAndCleanup(true)
		self.blood = nil
	end
	self.state = PersonState.STATE_OTHER
	self.stateInfo = {action="dead"}
	self.deleted = true
	local x, y = self.view:getPosition()
	y = y + self.viewInfo.y
	self.view:removeFromParentAndCleanup(true)
	local t = getParam("soldierDeadTime", 1000)/1000
	local bomb = UI.createAnimateWithSpritesheet(t, "dead_", 19, {plist="animate/dead.plist"})
	screen.autoSuitable(bomb, {nodeAnchor=General.anchorCenter, x=x, y=y})
	if self.info.unitType==2 then y = 0 end
	self.scene.ground:addChild(bomb, self.scene.SIZEY-y)
	delayRemove(t, bomb)
	
	local map = self.scene.mapGrid
	local grid = map:convertToGrid(x, y, 1)
	if map:checkGridEmpty(GridKeys.Build, grid.gridPosX, grid.gridPosY, grid.gridSize) then
		local tomb = Tomb.new(grid.gridPosX, grid.gridPosY)
		tomb:addToScene(self.scene)
	end
end
	
function Soldier:resetFreeState()
	self.displayState.duration = 1
	self.displayState.isRepeat = false
	self.displayState.num = 1
	self.displayState.prefix = "soldier" .. self.info.sid .. "_" .. self.data.level .. "_p"
end
	
function Soldier:resetMoveState()
	local moveAction = SoldierHelper.moveAction[self.info.sid]
	self.displayState.duration = moveAction.t
	self.displayState.isRepeat = true
	self.displayState.num = moveAction.m
	self.displayState.prefix = "soldier" .. self.info.sid .. "_" .. self.data.level .. "_m"
end

-- to override
function Soldier:resetOtherState()
	if self.stateInfo.action == "pose" then
		self.displayState.duration = getParam("soldierPoseTime" .. self.info.sid, 500)/1000
		self.displayState.isRepeat = false
		self.displayState.num = 5
		self.displayState.prefix = "soldier" .. self.info.sid .. "_" .. self.data.level .. "_p"
	elseif self.stateInfo.action == "attack1" or self.stateInfo.action == "attack2" then
		self.displayState.duration = self.info.attackSpeed
		self.displayState.isRepeat = false
		self.displayState.reverse = true
		self.displayState.num = 10
		self.displayState.prefix = "soldier" .. self.info.sid .. "_" .. self.data.level .. "_a" .. string.sub(self.stateInfo.action, -1) .. "_"
	end
end

function Soldier:getFrameEspecially(i)
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

--士兵四周闲逛
function Soldier:setMoveArround(build)
	if build == nil then
		build = self.moveArround
	else
		self.moveArround = build
	end
	-- TODO
	if build.buildView then
		if false then
			self.view:setPosition(self:getMoveArroundPosition(build))
		end

        local w = self.scene.mapWorld
        if not w.searchYet then
            self:setMoveTarget(self:getMoveArroundPosition(build))
            --print("setMoveArround ")
        end
	end
end
		
function Soldier:setPose()
	if self.state == PersonState.STATE_FREE then
		self.state = PersonState.STATE_OTHER
		self.direction = 1
		self.stateInfo = {action="pose", actionTime=getParam("soldierPoseTime", 1500)/1000}
		self.stateTime = 0
		self:resetPersonView()
	end
end

function Soldier:getAttackValue()
	local attackValue = self.data.dps*self.info.attackSpeed
	if self.info.favorite~=0 and self.attackTarget.buildMould.buildInfo.btype == self.info.favorite then
		attackValue = attackValue * self.info.favoriteRate
	end
	return attackValue
end

function Soldier:setAttack()
	if self.state==PersonState.STATE_OTHER and self.stateInfo.action=="dead" then
		return
	end
	self.state = PersonState.STATE_OTHER
	local fx, fy = self.view:getPosition()
	local tx, ty = self.attackTarget.view:getPositionX(), self.attackTarget.view:getPositionY() + self.attackTarget.view:getContentSize().height/2
	self:changeDirection(tx-fx, ty-fy)
	self:prepareAttack()
	self.stateTime = 0
	self:resetPersonView()
end

-- to override
function Soldier:prepareAttack()
	self.stateInfo = {actionTime=self.info.attackSpeed}
	self.stateInfo.attackValue = self:getAttackValue()
	self.stateInfo.attackTime = self.info.attackSpeed * 0.9
	self.stateInfo.action = "attack" .. math.random(2)
end

-- to override
function Soldier:executeAttack()
	self.attackTarget:damage(self.stateInfo.attackValue)
end
function Soldier:searchAttack()
    local target
    local w = self.scene.mapWorld
    if not w.searchYet then
        local truePath
        
        -- 获取起点，都相同
        local fx, fy = self.view:getPosition()
        local grid = self.scene.mapGrid:convertToGrid(fx, fy, 1, 2)
        local startPoint = {grid.gridPosX, grid.gridPosY}
    
        w:clearWorld()
        w:putStart(startPoint[1], startPoint[2])
        --print("test1")

        local path, target, lastPoint = w:searchAttack(self.info.range*2, grid.gridFloatX, grid.gridFloatY)
        if lastPoint then
            local position = self.scene.mapGrid:convertToPosition(lastPoint[1]/2, lastPoint[2]/2)
            local tx, ty = position[1] , position[2]
            truePath = self:getTruePath(path, w, self.scene.mapGrid, fx, fy, tx, ty)
        end	
        --print("test2")
            
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
    end
end
function Soldier:attackOther()
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
--一旦士兵距离军旗距离较远的话 士兵需要立即归队
--如何判定士兵距离建筑物很远呢？
--300*300 距离可以调整
--如果士兵正在近距离移动 则更新移动时间 
function Soldier:searchBusiness(dt)
    if self.state == PersonState.STATE_FREE then
	    local fx, fy = self.view:getPosition()
        local tx, ty = self:getMoveArroundPosition(self.moveArround)
        if self.moveYet then
            self.moveTime = self.moveTime + dt
            if self.moveTime >= 1.0 then
                self.moveYet = false
                self.moveTime = 0
            end
        end
        if (fx-tx)*(fx-tx)+(fy-ty)*(fy-ty) >= 300*300 then
            if not self.moveYet then
                local w = self.scene.mapWorld
                if not w.searchYet then
                    self.moveYet = true
                    self.moveTime = 0
                    self:setMoveArround()
                end
            end
        elseif self.stateTime > getParam("soldierFreeTime", 1500)/1000 then
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
function Soldier:updateState(diff)
	if self.isFighting then
		if BattleLogic.battleEnd then
			self:setDeadView()
		elseif not self.attackTarget or self.attackTarget.buildMould.buildState==BuildStates.STATE_DESTROY then
            self:searchAttack()
		elseif self.state == PersonState.STATE_FREE then
			self:setAttack()
			return true
		elseif self.state == PersonState.STATE_OTHER then
            self:attackOther()
		end
		if diff==0 then
			-- 入场后的掉落动画，先不实现
		end
	else
        self:searchBusiness(diff)
	end
end

require "Mould.Soldier.Archer"
require "Mould.Soldier.Bomb"
require "Mould.Soldier.Giant"
require "Mould.Soldier.Wizard"
require "Mould.Soldier.Healer"
require "Mould.Soldier.Balloon"
require "Mould.Soldier.UFO"
require "Mould.Soldier.Mech"

SoldierHelper.soldierClass = {[1]=Soldier, [2]=Archer, [3]=Soldier, [4]=Giant, [5]=Bomb, [6]=Balloon, [7]=Wizard,
	[8]=Healer, [9]=UFO, [10]=Mech}
function SoldierHelper.create(sid, setting)
	return SoldierHelper.soldierClass[sid].new(sid, setting)
end
