-- ���ڿ���һ��table��ֻ�����ַ�������ֵ����
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

-- ���ڻ�ȡһ�����Ʒ�Χ֮�����ֵ
function squeeze(value, min, max)
	if min and value<min then
		return min
	elseif max and value>max then
		return max
	else
		return value
	end
end

-- ��ʱ�첽���ã���Ҫ����
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

-- ��ʱɾ���ڵ㣬��Ҫ����ĳЩ��ʾ֮����Ҫά������ڣ�������Ҫ������Ϻ�Ž��е��Զ�ɾ��
function delayRemove(delay, node)
	node:retain()
	local function removeAndRelease()
		node:removeFromParentAndCleanup(true)
		node:release()
	end
	delayCallback(delay, removeAndRelease)
end

-- ɶ�������Ŀշ���
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

-- Ϊһ���ڵ�ע���¼�����������͸����¼�
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

-- �ж�һ������Ƿ��ڽڵ���
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

-- ע��һ����ť�ĵ���¼�
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

function printArray(arr)
    local res = ""
    for k, v in ipairs(arr) do
        res = res .. v
    end
    print(res)
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