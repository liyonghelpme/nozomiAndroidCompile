-- 用于拷贝一个table，只拷贝字符串或数值类型
function copyData(oldTable)
	local newTable = {}
	for i, v in pairs(oldTable) do
		if type(v) == "number" or type(v) == "string" then
			newTable[i] = v
		end
	end
	return newTable
end

function cmpData(oldData, newData)
	for k, v in pairs(oldData) do
		local diff = false
		if newData[k]==nil then 
			diff = true
		elseif type(v)~="table" then
			if v~=newData[k] then diff = true end
		else
			diff = not cmpData(v, newData[k])
		end
		if diff then return false end
	end
	for k, v in pairs(newData) do
		if oldData[k]==nil then return false end
	end
	return true
end

-- 用于获取一个限制范围之后的数值
function squeeze(value, min, max)
	if min and value<min then
		return min
	elseif max and value>max then
		return max
	else
		return value
	end
end

-- 延时异步调用，不要滥用
function delayCallback(delay, callback, params)
	local entryId = nil
	local function callOnce()
		callback(params)
		if entryId then
			CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(entryId)
		end
	end
	entryId = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(callOnce, delay, false)
end

-- 延时删除节点，主要用于某些显示之后不需要维持其存在，但仍需要动画完毕后才进行的自动删除
function delayRemove(delay, node)
	node:retain()
	local function removeAndRelease()
		node:removeFromParentAndCleanup(true)
		node:release()
	end
	delayCallback(delay, removeAndRelease)
end

-- 啥都不做的空方法
function doNothing()
end

function changeFunction(entry, delegate)
	if not entry.changed then
		entry.changed = true
		local baseCallback = entry.callback
		entry.callback = function(...)
			return baseCallback(delegate, ...)
		end
	end
end

-- 为一个节点注册事件，包括点击和更新事件
function simpleRegisterEvent(node, events, delegate)
	if not events then
		return
	end
	local update = events.update
	local touch = events.touch
	local other = events.enterOrExit
	local entryId = nil
	if touch then
		if delegate then
			changeFunction(touch, delegate)
		end
		node:registerScriptTouchHandler(touch.callback, touch.multi, touch.priority, touch.swallow)
		node:setTouchEnabled(true)
	end
	if delegate then
		if update then
			changeFunction(update, delegate)
		end
		if other and not other.changed then
			changeFunction(other, delegate)
		end
	end
	local function onEnterOrExit(eventType)
		if eventType.name=="enter" then
			if update and not update.pause and not entryId then
				entryId = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(update.callback, update.inteval or 1, false)
			end
			if other then
				other.callback(true)
			end
		elseif eventType.name=="exit" then
			if update and not update.pause then
				CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(entryId)
				entryId = nil
			end
			if other then
				other.callback(false)
			end
		end
	end
	node:registerScriptHandler(onEnterOrExit)
	if node:getParent() then
		onEnterOrExit({name="enter"})
	end
end

-- 判断一个点击是否在节点上
function isTouchInNode(node, x, y, alphaTouch)
	local parent = node
	while parent do
		if not parent:isVisible() then
			return false
		end
		parent = parent:getParent()
	end
	local point = node:convertToNodeSpace(CCPointMake(x,y))
	local size = node:getContentSize()
	if point.x >0 and point.y > 0 and point.x < size.width and point.y < size.height then
		if alphaTouch then
			return not node:isAlphaTouched(point)
		else
			return true
		end
	else
		return false
	end
end

-- 注册一个按钮的点击事件
function simpleRegisterButton(node, setting)
	local layer = CCLayer:create()
	local isTouched = false
	node:addChild(layer)
	
	local params = setting or {}
	
	local buttonTouched = params.nodeChangeHandler
	
	local clickedCallback = params.callback or doNothing
	local callbackParam = params.callbackParam
	local priority = params.priority or -1
	local alphaTouch = params.alphaTouch
	
	local function onTouchBegan(x, y)
		if not isTouched and isTouchInNode(node, x, y, alphaTouch) then
			isTouched = true
			if buttonTouched then
				buttonTouched(isTouched, node)
			end
			return true
		else
			return false
		end
	end
	
	local function onTouchMoved(x, y)
		if isTouched and not isTouchInNode(node, x, y) then
			isTouched = false
			if buttonTouched then
				buttonTouched(isTouched, node)
			end
		elseif not isTouched and isTouchInNode(node, x, y) then
			isTouched = true
			if buttonTouched then
				buttonTouched(isTouched, node)
			end
		end
	end
	
	local function onTouchEnded(eventType)
		if isTouched then
			isTouched = false
			if buttonTouched then
				buttonTouched(isTouched, node)
			end
			if eventType==CCTOUCHENDED then
				clickedCallback(callbackParam)
			end
		end
	end
	
	local function onTouch(eventType, x, y)
		if eventType == CCTOUCHBEGAN then
			return onTouchBegan(x, y)
		elseif eventType == CCTOUCHMOVED then
			return onTouchMoved(x, y)
		else
			return onTouchEnded(eventType)
		end
	end
	
	layer:registerScriptTouchHandler(onTouch, false, priority, true)
	layer:setTouchEnabled(true)
	--local function onEnterOrExit(eventType)
	--	if eventType.name=="enter" then
	--		layer:registerScriptTouchHandler(onTouch, false, priority, true)
	--		layer:setTouchEnabled(true)
	--	elseif eventType.name=="exit" then
	--		layer:setTouchEnabled(false)
	--	end
	--end
	--layer:registerScriptHandler(onEnterOrExit)
end

function recurSetColor(sprite, color)
	CCSprite.setColor(sprite, color)
	
	local childs = CCNode.getChildrenCount(sprite)
	if childs > 0 then
		local children = CCNode.getChildren(sprite)
		for i=0, childs-1 do
			recurSetColor(children:objectAtIndex(i), color)
		end
	end
end

require "Util.Class"
require "Util.character"
require "Util.json"
require "Util.queue"
require "Util.Action"
require "Util.MapGrid"
require "Util.RhombGrid"

require "Util.Touch"
require "Util.World"
require "Util.Ray"