SceneObj = {}

do
	SceneObj.registerSceneObj = function(node, scene, grid, callback, callbackParam)
		if scene.mapGrid.checkGridUsed(grid.gridPosX, grid.gridPosY, grid.gridSizeX, grid.gridSizeY) then
			return false
		end
		scene.mapGrid.setGridUse(true, grid.gridPosX, grid.gridPosY, grid.gridSizeX, grid.gridSizeY)
		local priority = display.SCENE_PRI + scene.mapGrid.convertToPosition(grid.gridPosX, grid.gridPosY, grid.gridSizeX, grid.gridSizeY).posY - 1120
		local state = {}
		
		local function onTouchBegan(x, y)
			if state.touchPoint or scene.isPlan then
				return false
			end
			local isTouch = false
			if not scene.sceneTouched then
				if isTouchInNode(node, x, y) then
					isTouch = true
				else
					local groundPoint = scene.ground:convertToNodeSpace(CCPointMake(x, y))
					if scene.mapGrid.isTouchInGrid(groundPoint.x, groundPoint.y, grid.gridPosX, grid.gridPosY) then
						isTouch = true
					end
				end
			end
			if isTouch then
				if scene.buildTouched or scene.isPlan then
					return false
				end
				state.touchPoint = {x = x, y = y}
				scene.buildTouched = true
			end
			return isTouch
		end

		local function onTouchMoved(x, y)
			if state.touchPoint then
				local mov = math.abs(x-state.touchPoint.x) + math.abs(y-state.touchPoint.y)
				local index = state.chooseItem
				local groundPoint = scene.ground:convertToNodeSpace(CCPointMake(x, y))
				if mov > 20 or not (isTouchInNode(node, x, y) or scene.mapGrid.isTouchInGrid(groundPoint.x, groundPoint.y, grid.gridPosX, grid.gridPosY)) then
					state.touchPoint = nil
					scene.buildTouched = false
				end
				return
			end
		end

		local function onTouchEnded(x, y)
			if state.touchPoint then
				callback(callbackParam)
				state.touchPoint = nil
				scene.buildTouched = false
			end
		end
		
		local function onTouchCanceled(x, y)
			state.touchPoint = nil
			scene.buildTouched = false
		end
		
		local function onTouch(eventType, x, y)
			if eventType == CCTOUCHBEGAN then
				return onTouchBegan(x, y)
			elseif eventType == CCTOUCHMOVED then
				return onTouchMoved(x, y)
			elseif eventType == CCTOUCHENDED then
				return onTouchEnded(x, y)
			else
				return onTouchCanceled(x, y)
			end
		end
		
		local layer = CCLayer:create()
		node:addChild(layer)
		simpleRegisterEvent(layer, {touch = {callback = onTouch, multi = false, priority = priority, swallow = false}})
	end
end