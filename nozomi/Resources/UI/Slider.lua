do
	local function createSlider(size, isX, tabsNum, blockNode, callback, setting)
		local params = setting or {}
		local bg = CCNode:create()
		bg:setContentSize(size)
		
		local curTab = params.tabIndex or 1
		local edge = params.edge or -10
		
		local nodeChangeHandler = params.nodeChangeHandler or doNothing
		
		nodeChangeHandler(false)
		callback(curTab)
		blockNode:setAnchorPoint(General.anchorCenter)
		if isX then
			blockNode:setPosition((curTab - 0.5) * size.width/tabsNum , size.height/2)
		else
			blockNode:setPosition(size.width/2 , (curTab - 0.5) * size.height/tabsNum)
		end
		bg:addChild(blockNode)
		
		local state = {}
		
		local function onTouchBegan(x, y)
			if state.touchPoint then
				return false
			end
			if isTouchInNode(bg, x, y) or isTouchInNode(blockNode, x, y) then
				state.touchPoint = {x = x, y = y}
				if not isTouchInNode(blockNode, x, y) then
					local targetPoint = bg:convertToNodeSpace(CCPointMake(x, y))
					local offx, offy = 0, 0
					if isX then
						offx = squeeze(targetPoint.x, -edge, size.width + edge) - blockNode:getPositionX()
					else
						offy = squeeze(targetPoint.y, -edge, size.height + edge) - blockNode:getPositionY()
					end
					local actionTime = math.abs(offx + offy)/2000
					local curTime = timer.getTime()
					if state.isMoving and state.moveEndTime>curTime then
						blockNode:stopAllActions()
					end
					state.isMoving = true
					state.moveEndTime = curTime + actionTime
					state.moveTarget = {x=targetPoint.x, y=targetPoint.y}
					blockNode:runAction(CCMoveBy:create(actionTime, CCPointMake(offx, offy)))
				end
				nodeChangeHandler(true)
				return true
			end
		end

		local function onTouchMoved(x, y)
			if state.touchPoint then
				local curTime = timer.getTime()
				local targetPoint = bg:convertToNodeSpace(CCPointMake(x, y))
				if state.isMoving and state.moveEndTime>curTime then
					local offx, offy = 0, 0
					if isX then
						if math.abs(targetPoint.x - state.moveTarget.x) > size.width/2/tabsNum then
							offx = squeeze(targetPoint.x, -edge, size.width + edge) - blockNode:getPositionX()
						end
					else
						if math.abs(targetPoint.y - state.moveTarget.y) > size.height/2/tabsNum then
							offy = squeeze(targetPoint.y, -edge, size.height + edge) - blockNode:getPositionY()
						end
					end
					if offx~=0 or offy~=0 then
						blockNode:stopAllActions()
						local actionTime = math.abs(offx + offy)/2000
						state.moveEndTime = curTime + actionTime
						state.moveTarget = {x=targetPoint.x, y=targetPoint.y}
						blockNode:runAction(CCMoveBy:create(actionTime, CCPointMake(offx, offy)))
					end
				else
					local baseTargetPoint = bg:convertToNodeSpace(CCPointMake(state.touchPoint.x, state.touchPoint.y))
					if isX then
						local px = blockNode:getPositionX()
						blockNode:setPositionX(squeeze(px + targetPoint.x - baseTargetPoint.x, -edge, size.width+edge))
					else
						local py = blockNode:getPositionY()
						blockNode:setPositionY(squeeze(py + targetPoint.y - baseTargetPoint.y, -edge, size.height+edge))
					end
				end
				state.touchPoint = {x=x, y=y}
			end
		end

		local function onTouchEnded(x, y)
			state.touchPoint = nil
			local curTime = timer.getTime()
			local tx, ty = 0, 0
			local px, py = blockNode:getPosition()
			if state.isMoving and state.moveEndTime>curTime then
				blockNode:stopAllActions()
				local targetPoint = bg:convertToNodeSpace(CCPointMake(x, y))
				tx, ty = targetPoint.x, targetPoint.y
			else
				tx, ty = px, py
			end
			local offx, offy = 0, 0
			local newTab = curTab
			if isX then
				newTab = squeeze(math.floor(tx / size.width * tabsNum)+1, 1, tabsNum)
				offx = (newTab - 0.5) * size.width / tabsNum - px
			else
				newTab = squeeze(math.floor(ty / size.height * tabsNum)+1, 1, tabsNum)
				offy = (newTab - 0.5) * size.height / tabsNum - py
			end
			local actionTime = math.abs(offx + offy)/2000
			state.isMoving = true
			state.moveEndTime = curTime + actionTime	
			state.moveTarget = {x=offx+px, y=offy+py}
			blockNode:runAction(CCMoveBy:create(actionTime, CCPointMake(offx, offy)))
			nodeChangeHandler(false)
			if newTab ~= curTab then
				curTab = newTab
				callback(curTab)
			end
		end

		local function onTouch(eventType, x, y)
			if eventType == CCTOUCHBEGAN then
				return onTouchBegan(x, y)
			elseif eventType == CCTOUCHMOVED then
				return onTouchMoved(x, y)
			else
				return onTouchEnded(x, y)
			end
		end
		
		local layer = CCLayer:create()
		bg:addChild(layer)
		simpleRegisterEvent(layer, {touch = {callback = onTouch, multi = false, priority = display.DIALOG_PRI, swallow = true}})
		return bg
	end
	
	UI.createSlider = createSlider
end