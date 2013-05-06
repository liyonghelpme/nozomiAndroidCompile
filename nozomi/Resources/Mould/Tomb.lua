Tomb = class()
	
function Tomb:movePosition(position)
	self.view:retain()
	local parent = self.view:getParent()
	if parent then
		parent:removeChild(self.view, false)
	end
	self.view:setPosition(position[1], position[2])
	local zOrder 
	if not self.state.moveOk then 
		zOrder = self.scene.SIZEY+1
	else
		zOrder = self.scene.SIZEY - position[2] - self.scene.mapGrid.sizeY/2
	end
	if self.eventEntries.touch then
		self.eventEntries.touch.priority = display.SCENE_PRI - zOrder
	end
	simpleRegisterEvent(self.layer, self.eventEntries, self)
	self.scene.ground:addChild(self.view, zOrder)
	self.view:release()
end

function Tomb:resetGridUse(backGrid, newGrid)
	local mapGrid = self.scene.mapGrid
	if backGrid then
		mapGrid:clearGridUse(GridKeys.Build, backGrid.gridPosX, backGrid.gridPosY, backGrid.gridSize)
	end
	if newGrid then
		mapGrid:setGridUse(GridKeys.Build, newGrid.gridPosX, newGrid.gridPosY, newGrid.gridSize)
	end
end

function Tomb:resetGrid()
	local state = self.state
	local scene = self.scene
	
	local grid = state.grid
	local position = scene.mapGrid:convertToPosition(grid.gridPosX, grid.gridPosY)
	if not state.moveOk then
		state.moveOk = true
		self:movePosition(position)
	end
	if not state.backGrid or state.backGrid.gridPosX ~= state.grid.gridPosX or state.backGrid.gridPosY ~= state.grid.gridPosY then
		local backGrid = state.backGrid
		state.backGrid = state.grid
		self:resetGridUse(backGrid, state.grid)
	end
end

function Tomb:onTouchBegan(x, y)
	local isTouch = false
	local state = self.state
	local scene = self.scene
	if not state.touchPoint and scene.touchType=="none" then
		local groundPoint = scene.ground:convertToNodeSpace(CCPointMake(x, y))
		local grid = self.state.grid
		if scene.mapGrid:isTouchInGrid(groundPoint.x, groundPoint.y, grid.gridPosX, grid.gridPosY, grid.gridSize) then
			isTouch = true
		end
	end
	if isTouch then
		state.touchPoint = {x = x, y = y}
		scene.touchType = "build"
	end
	return isTouch
end

function Tomb:onTouchMoved(x, y)
	local state = self.state
	if state.touchPoint then
		local scene = self.scene
		if scene.touchType == "scene" then
			state.touchPoint = nil
			return true
		end
		local mov = math.abs(x-state.touchPoint.x) + math.abs(y-state.touchPoint.y)
		if mov > 20 then
			state.touchPoint = nil
			scene.touchType = "scene"
		end
	end
end

function Tomb:onTouchEnded(x, y)
	local state = self.state
	local scene = self.scene
	if state.touchPoint and scene.touchType=="build" then
		-- do sth
	end
	state.touchPoint = nil
end
	
function Tomb:onTouchCanceled(x, y)
	self.state.touchPoint = nil
end

function Tomb:setViewState(build)
	build:setScale(getParam("tombScale", 100)/100)
	local ssize = self.view:getContentSize()
	screen.autoSuitable(build, {x=getParam("tombOffx", 0)+ssize.width/2, y=getParam("TombOffy", 0), nodeAnchor=General.anchorBottom})		
end

function Tomb:removeView()
	self.view:removeFromParentAndCleanup(true)
	
	self.scene.mapGrid:resetGridUse(self.state.backGrid, nil)
	self.deleted = true
end

function Tomb:onTouches(eventType, x, y)
	if eventType == CCTOUCHBEGAN then
		return self:onTouchBegan(x, y)
	elseif eventType == CCTOUCHMOVED then
		return self:onTouchMoved(x, y)
	elseif eventType == CCTOUCHENDED then
		return self:onTouchEnded(x, y)
	else
		return self:onTouchCanceled(x, y)
	end
end

function Tomb:update(diff)
	local state = self.state
	if state.nightMode ~= UserData.isNight then
		state.nightMode = UserData.isNight
		if self.build then
			if state.nightMode then
				recurSetColor(self.build, General.nightColor)
			else
				recurSetColor(self.build, General.normalColor)
			end
		end
	end
end

function Tomb:ctor(gx, gy)
	self.initSetting = {gx, gy}
end

function Tomb:addToScene(scene)
	local state = {nightMode=false}
	local grid = {gridPosX=self.initSetting[1], gridPosY=self.initSetting[2], gridSize=1}
	
	state.grid = grid
	
	local bg = CCNode:create()
	local ssize = CCSizeMake(scene.mapGrid.sizeX, scene.mapGrid.sizeY)
	bg:setContentSize(ssize)
	screen.autoSuitable(bg, {nodeAnchor=General.anchorBottom})
	
	--需要LAYER来注册TOUCH事件
	local layer = CCLayer:create()
	bg:addChild(layer)
	
	self.view = bg
	self.layer = layer
	self.state=state
	self.scene=scene
	
	self.build = UI.createSpriteWithFile("images/buildTomb.png")
	self:setViewState(self.build)
	self.view:addChild(self.build)

	self.eventEntries = {update={inteval = 0.05, callback=self.update}}
	if scene.sceneType ~= SceneTypes.Battle and scene.sceneType ~= SceneTypes.Stage then
		self.eventEntries.touch = {multi=false, swallow=false, callback=self.onTouches}
	end
		
	self:resetGrid()
end