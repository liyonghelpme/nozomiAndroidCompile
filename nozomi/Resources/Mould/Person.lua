require "Util.Class"

Person = class()

PersonState = {STATE_FREE = 1, STATE_MOVING = 2, STATE_OTHER = 3}

function Person:ctor()
	self.state = PersonState.STATE_FREE
	self.stateInfo = {}
	self.stateTime = 0
	self.displayState = {direction=1}
	self.direction = 1
	self.viewInfo = {scale=1, x=0, y=0}
end

function Person:getMoveArroundPosition(build)
	local gsize = build.buildData.gridSize
	local sspace = build.buildData.soldierSpace
	local e1, e2 = sspace/2, gsize-sspace/2
	local gx, gy = math.random()*gsize, math.random()*gsize
	if gx>e1 and gx<e2 and gy>e1 and gy<e2 then
		if math.random()>0.5 then
			gx = (gx-e1)/(e2-e1)*sspace
			if gx>e1 then
				gx = gx-e1+e2
			end
		else
			gy = (gy-e1)/(e2-e1)*sspace
			if gy>e1 then
				gy = gy-e1+e2
			end
		end
	end
	local grid = build.buildView.state.backGrid
	if not grid then grid = build.buildView.state.grid end
	local position = build.buildView.scene.mapGrid:convertToPosition(grid.gridPosX + gx, grid.gridPosY + gy)
	return position[1], position[2]
end

function Person:initWithInfo(personInfo)
	self.info = personInfo
end

function Person:changeDirection(dirx, diry)
	local dir = 0
	local t1, t2 = math.abs(dirx), math.abs(diry)
	local t3 
	if t1==0 then
		t3 = 3 - math.ceil(self.direction/3)*2
	else
		t3 = dirx/t1
	end
	if t2<=t1*0.4 then
		dir = 3.5 - 1.5 * t3
	else
		dir = 3.5 + (diry/t2 - 1.5) * t3
	end
	self.direction = dir
end

function Person:moveDirect(tx, ty, isInterupt)
	self.state = PersonState.STATE_MOVING
	local stateInfo = self.stateInfo or {}
	self.stateInfo = stateInfo
	stateInfo.toPoint = {tx, ty}
	local fx, fy = self.view:getPosition()
	stateInfo.fromPoint = {fx, fy}
	local ox, oy = tx-fx, ty-fy
	if isInterupt then
		stateInfo.beginTime = (self.stateTime or 0)
	else
		stateInfo.beginTime = (stateInfo.beginTime or 0) + (stateInfo.moveTime or 0)
	end
	stateInfo.moveTime = self.scene.mapGrid:getGridDistance(ox, oy) * 10/self.info.moveSpeed
	self:changeDirection(ox, oy)
	self:resetPersonView()
end

function Person:getFrameEspecially(i)
	return nil
end

function Person:getFrameName(i, dir, displayState)
	if i<0 then
		i=0
	end
	local ni = self:getFrameEspecially(i)
	if ni then
		i = ni
	else
		if i>=displayState.num then
			if displayState.isRepeat then
				i = i % displayState.num
			elseif displayState.reverse then
				i = 0
			else
				i = displayState.num-1
			end
		end
	end
	if self.onChange and (self.direction ~= displayState.direction or i ~= displayState.frameNumber) then
		self:onChange(self.direction, i)
	end
	displayState.direction = self.direction
	displayState.frameNumber = i
	return displayState.prefix .. dir .. "_" .. i .. ".png"
end

function Person:resetPersonSpriteFrame()
	local flip = false
	local tempDir = self.direction
	if tempDir > 3 then
		tempDir = 7-tempDir
		flip = true
	end
	local displayState = self.displayState
	local t = self.stateTime
	local p = displayState.duration/displayState.num
	self.frameName = self:getFrameName(math.floor(t/p), tempDir, displayState)
	local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(self.frameName)
	if not frame then
		CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile(self.plistFile)
		frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(self.frameName)
	end
	if not frame then
		print(self.frameName)
		while true do
		
		end
	end
	if not self.personView then
		self.personView = CCSprite:createWithSpriteFrame(frame)
		self.personView:setScale(self.viewInfo.scale or 1)
		screen.autoSuitable(self.personView, {nodeAnchor=General.anchorCenter, x=self.viewInfo.x, y=self.viewInfo.y})
		self.view:addChild(self.personView)
	elseif self.frameName ~= self.displayState.frameName then
		self.personView:setDisplayFrame(frame)
	end
	self.displayState.frameName = self.frameName
	self.personView:setFlipX(flip)
end

function Person:resetPersonView()
	local displayState = self.displayState
	local needReset = false
	if self.state ~= displayState.state then
		needReset = true
		displayState.state = self.state
	elseif self.state==PersonState.STATE_OTHER and displayState.action~=self.stateInfo.action then
		needReset = true
		display.action = self.stateInfo.action
	end
	
	if needReset then
		if self.state == PersonState.STATE_FREE then
			self:resetFreeState()
		elseif self.state == PersonState.STATE_MOVING then
			self:resetMoveState()
		elseif self.state == PersonState.STATE_OTHER then
			self:resetOtherState()
		end
	end
end

--检测非相邻点之间是否存在障碍物
--将坐标从affine网格坐标转化成笛卡尔坐标
function Person:getTruePath(path, world, mapGrid, fx, fy, tx, ty)
	local i = 1
    local j = 3
	local tempPath = {path[1]}
    while j <= #path do
        local ray = Ray.new(path[i], path[j], world)
        local ret = ray:checkCollision()
        if not ret then
            j = j + 1
        else --该位置j发生碰撞 则前一个位置是可以到达的
            i = j-1
            j = i + 2
            table.insert(tempPath, path[i])
        end
    end
    table.insert(tempPath, path[#path])
    --设定world中网格属性用于调试
    path = tempPath
    for i=1, #path, 1 do
        world.cells[world:getKey(path[i][1], path[i][2])]['isReal'] = true
    end
	    
	local truePath = {}
	if #path==0 then
		return {{tx, ty}}
	end
	local curGrid = path[1]
	for i=2, #path-1 do
		local grid = path[i]
		local position = mapGrid:convertToPosition(grid[1]/2, grid[2]/2)
		table.insert(truePath, {position[1], position[2]+mapGrid.sizeY/4})
	end
	table.insert(truePath, {tx, ty})
	return truePath
end
		
function Person:setMoveTarget(tx, ty)
	local fx, fy = self.view:getPosition()
	local mapGrid = self.scene.mapGrid
	local grid = mapGrid:convertToGrid(fx, fy, nil, 2)
	local startPoint = {grid.gridPosX, grid.gridPosY}
	local agrid = mapGrid:convertToGrid(tx, ty, nil, 2)
	local endPoint = {agrid.gridPosX, agrid.gridPosY}
	if self.info.unitType==1 and (startPoint[1]~=endPoint[1] or startPoint[2]~=endPoint[2]) then
		local w = self.scene.mapWorld
		w:clearWorld()
		w:putStart(startPoint[1], startPoint[2])
		w:putEnd(endPoint[1], endPoint[2])
		local path = w:search(startPoint, endPoint)
        --local truePath = path
		local truePath = self:getTruePath(path, w, self.scene.mapGrid, fx, fy, tx, ty)
		local firstPoint = table.remove(truePath, 1)
		self.stateInfo = {movePath = truePath}
		self.state = PersonState.STATE_MOVING
		self:moveDirect(firstPoint[1], firstPoint[2], true)
	else
		self:moveDirect(tx, ty, true)
	end
end

function Person:update(diff)
	local stateInfo = self.stateInfo
	if stateInfo.state == "dead" then
	end
	if self.state == PersonState.STATE_MOVING then
		local moveEnd = true
		if stateInfo.toPoint then
			if not stateInfo.beginTime then
				print("moveStateError")
				while true do end
			end
			if self.stateTime-stateInfo.beginTime < stateInfo.moveTime then
				self.stateTime = self.stateTime + diff
				local delta = (self.stateTime-stateInfo.beginTime)/stateInfo.moveTime
				if delta>1 then delta = 1 end
				if delta<0 then
					print("delta", delta)
				end
				local tempY = stateInfo.fromPoint[2] + delta*(stateInfo.toPoint[2]-stateInfo.fromPoint[2])
				self.view:setPosition(stateInfo.fromPoint[1] + delta*(stateInfo.toPoint[1]-stateInfo.fromPoint[1]), tempY)
					
				self.updateEntry.pause = true
				self.view:retain()
				local parent = self.view:getParent()
				self.view:removeFromParentAndCleanup(false)
				parent:addChild(self.view,self.maxZorder - tempY)
				self.view:release()
				self.updateEntry.pause = false
				if delta<1 then moveEnd = false end
			end
		end
		if moveEnd then
			if stateInfo.movePath and #(stateInfo.movePath)>0 then
				local point = table.remove(stateInfo.movePath, 1)
				self:moveDirect(point[1], point[2])
			else
				self.state = PersonState.STATE_FREE
				self.backStateInfo = self.stateInfo
				self.backTime = self.stateTime
				self.stateInfo = {}
				self.direction = 1
				self.stateTime = 0
			end
		end
	else
		self.stateTime = self.stateTime + diff
	end
	if not self:updateState(diff) then
		self:resetPersonView()
	end
	-- TEST
	if not self.deleted then
		self:resetPersonSpriteFrame()
	end
end

function Person:addShadow()
	local temp = UI.createSpriteWithFile("images/personShadow.png")
	temp:setScale(0.4)
	screen.autoSuitable(temp, {nodeAnchor=General.anchorCenter})
	self.view:addChild(temp)
end

function Person:addToScene(scene, pos)
	self.scene = scene
	
	if not pos then
		pos = self:getInitPos()
	end
	
	self.view = CCNode:create()
	screen.autoSuitable(self.view, {x=pos[1], y=pos[2]})
	if self.info.unitType==1 then
		self.maxZorder = scene.SIZEY
		scene.ground:addChild(self.view, self.maxZorder-pos[2])
	else
		self.maxZorder = scene.SIZEY+self.viewInfo.y*100
		scene.sky:addChild(self.view, self.maxZorder-pos[2])
	end
	
	self:addShadow()
	
	self.updateEntry = {inteval=0, callback=self.update}
	
	self:resetPersonView()
	simpleRegisterEvent(self.view, {update = self.updateEntry}, self)
	self:updateState(0)
end
