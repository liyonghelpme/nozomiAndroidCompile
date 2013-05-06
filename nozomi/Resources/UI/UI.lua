UI = nil
do
    local function createAnimateSprite(duration, prefix, endNum, setting)
    	local params = setting or {}
    	local suffix = params.suffix or ".png"
    	local beginNum = params.beginNum or 0
    	local isRepeat = params.isRepeat
    	if isRepeat == nil then isRepeat = true end
    	local rollback = params.isRollback
    	local useExtend = params.useExtend
    	local sprite
    	
    	if useExtend then
    		sprite = CCExtendSprite:create(prefix .. beginNum .. suffix)
    	else
    		sprite = CCSprite:create(prefix .. beginNum .. suffix)
    	end
    	
        local animation = CCAnimation:create()
        for i = beginNum, endNum do
    	    animation:addSpriteFrameWithFileName(prefix .. i .. suffix)
    	end
    	if rollback then
    		for i = endNum-1, beginNum+1, -1 do
    	    	animation:addSpriteFrameWithFileName(prefix .. i .. suffix)
    		end
	    	animation:setDelayPerUnit(duration/(endNum-beginNum)/2)
	    	animation:setRestoreOriginalFrame(true)
    	else
	    	animation:setDelayPerUnit(duration/(endNum-beginNum+1))
	    	animation:setRestoreOriginalFrame(false)
	    end
        local animate = CCAnimate:create(animation)
    
    	if isRepeat then
    		sprite:runAction(CCRepeatForever:create(animate))
    	else
    		sprite:runAction(animate)
    	end
    	return sprite
    end
    
    local function createAnimateWithSpritesheet(duration, prefix, endNum, setting)
    	local params = setting or {}
    	local suffix = params.suffix or ".png"
    	local beginNum = params.beginNum or 0
    	local isRepeat = params.isRepeat
    	if isRepeat == nil then isRepeat = true end
    	local rollback = params.isRollback
    	--local useExtend = params.useExtend
    	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile(params.plist)
    	local sprite
    	
    	--if useExtend then
    	--	sprite = CCExtendSprite:create(prefix .. beginNum .. suffix)
    	--else
    	sprite = CCSprite:createWithSpriteFrameName(prefix .. beginNum .. suffix)
    	--end
    	
        local animation = CCAnimation:create()
        for i = beginNum, endNum do
    	    animation:addSpriteFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(prefix .. i .. suffix))
    	end
    	if rollback then
    		for i = endNum-1, beginNum+1, -1 do
    	    	animation:addSpriteFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(prefix .. i .. suffix))
    		end
	    	animation:setDelayPerUnit(duration/(endNum-beginNum)/2)
	    	animation:setRestoreOriginalFrame(true)
    	else
	    	animation:setDelayPerUnit(duration/(endNum-beginNum+1))
	    	animation:setRestoreOriginalFrame(false)
	    end
        local animate = CCAnimate:create(animation)
    
    	if isRepeat then
    		sprite:runAction(CCRepeatForever:create(animate))
    	else
    		sprite:runAction(animate)
    	end
    	return sprite
    end
    
    local function createBMFontLabel(text, fontName, fontSize, setting)
        local params = setting or {}
        local area = params.size or CCSizeMake(0, 0)
        local align = params.align or kCCTextAlignmentCenter
        local r, g, b = params.colorR or 255, params.colorG or 255, params.colorB or 255
	    local lineOffset = params.lineOffset or 0
        
        --if fontName==General.specialFont then
        	--fontSize = fontSize-2
        --end
        text = string.gsub(text, "'", "’")
        local label = nil
	    local baseSize = 35
	    local k = fontSize/baseSize
	    
        if area.width==0 then
	        label = CCLabelBMFont:create(text, fontName)
        	label:setLineOffset(lineOffset)
	    	label:setScale(k)
	    else
        	label = CCLabelBMFont:create(text, fontName, area.width, align)
        	label:setLineOffset(lineOffset)
        	while true do
		    	label:setScale(k)
	        	if area.height~=0 and label:getContentSize().height * k>area.height then
	        		fontSize = fontSize-1
	        		k = fontSize/baseSize
	        	else
	        		break
	        	end
	        end
	    end
        label:setColor(ccc3(r, g, b))
        return label
    end
    
    local function createTTFLabel(text, fontName, fontSize, setting)
    	local pos = string.find(fontName, ".fnt")
    	if pos then
    		return createBMFontLabel(text, fontName, fontSize, setting)
    	end
        local params = setting or {}
        local area = params.size or CCSizeMake(0, 0)
        local align = params.align or kCCTextAlignmentCenter
        local valign = params.valign or kCCVerticalTextAlignmentCenter
        local r, g, b = params.colorR or 255, params.colorG or 255, params.colorB or 255
        
        local label = CCLabelTTF:create(text, fontName, fontSize, area, align, valign)
        label:setColor(ccc3(r, g, b))
        
        --local tsize = label:getContentSize()
        --if area.width > 0 and tsize.width>area.width then
        --	label:setScaleX(area.width / tsize.width)
        --end
        --if area.height > 0 and tsize.height > area.height then
        --	label:setScaleY(area.height / tsize.height)
        --end
        return label
    end
    
    local function createSpriteWithFile(imageFile, size, isCae)
        local sprite = nil
        if isCae then
        	sprite = CCExtendSprite:create(imageFile)
        else
	        sprite = CCSprite:create(imageFile)
	    end
        if size then
            local oldSize = sprite:getContentSize()
            if oldSize.width ~= size.width then
                sprite:setScaleX(size.width/oldSize.width)
            end
            if oldSize.height ~= size.height then
                sprite:setScaleY(size.height/oldSize.height)
            end
        end
        return sprite
    end
    
    local function createScaleSprite(imageFile, size, isCae)
        local sprite = nil
        if isCae then
        	sprite = CCExtendSprite:create(imageFile)
        else
	        sprite = CCSprite:create(imageFile)
	    end
    	local tsize = sprite:getContentSize()
    	local scale1, scale2 = size.width/tsize.width, size.height/tsize.height
    	if scale1 > scale2 then scale1 = scale2 end
    	if scale1 < 1 then
    		sprite:setScale(scale1)
    	end
    	return sprite
    end
    
    local function defaultButtonTouchHandler()
	    local bScaleX, bScaleY = 1, 1
		return function(bIsTouched, nNode)
			if bIsTouched then
				bScaleX, bScaleY = nNode:getScaleX(), nNode:getScaleY()
				nNode:setScaleX(1.1 * bScaleX)
				nNode:setScaleY(1.1 * bScaleY)
				music.playEffect("music/but.mp3")
			else
				nNode:setScaleX(bScaleX)
				nNode:setScaleY(bScaleY)
			end
		end
    end
    
    local function specialButtonTouchHandler(bIsTouched, nNode)
		if bIsTouched then
			-- 列表框的声音
			music.playEffect("music/but.mp3")
			nNode:setScale(0.9)
			if nNode.setValOffset then
				nNode:setValOffset(20)
			end
		else
			nNode:setScale(1)
			if nNode.setValOffset then
				nNode:setValOffset(0)
			end
		end
	end
    
    local function createButton(size, callback, setting)
    	local params = setting or {}
    	local buttonImage = params.image
    	local buttonText = params.text
    	local priority = params.priority or display.DIALOG_BUTTON_PRI
    	
    	local node
    	if params.useExtendNode then
	    	node = CCExtendNode:create(CCSizeMake(0,0))
	    else
	    	node = CCNode:create()
	    end
	    
    	if buttonImage then
    		local sprite = nil
    		if size then
		    	sprite = createSpriteWithFile(buttonImage, size)
		    else
		    	sprite = createSpriteWithFile(buttonImage)
		    	size = sprite:getContentSize()
		    end
		    sprite:setAnchorPoint(General.anchorLeftBottom)
		    node:addChild(sprite)
	    end
	    
    	node:setContentSize(size)
    	
    	if buttonText then
    		local fontSize = params.fontSize or 18
    		local fontName = params.fontName or General.defaultFont
    		local colorR, colorG, colorB = params.colorR or 255, params.colorG or 255, params.colorB or 255
    		local lineOffset = params.lineOffset or 0
    		local label = createTTFLabel(buttonText, fontName, fontSize, {size = CCSizeMake(size.width*0.8, size.height), colorR = colorR, colorG = colorG, colorB = colorB, lineOffset=lineOffset})
	    	screen.autoSuitable(label, {nodeAnchor=General.anchorCenter, x=size.width/2, y=size.height/2})
    		node:addChild(label)
    	end
    	local nodeChangeHandler = params.nodeChangeHandler
    	if not nodeChangeHandler then
    		if params.useExtendNode then
    			nodeChangeHandler = specialButtonTouchHandler
    		else
	    		nodeChangeHandler = defaultButtonTouchHandler()
	    	end
    	end
    	simpleRegisterButton(node, {callback=callback, priority=priority, nodeChangeHandler=nodeChangeHandler, callbackParam=params.callbackParam})
    	return node
    end
    
    local function createSpecialButton(size, callback, setting)
    	local params = setting or {}
    	local buttonImage = params.image
    	local priority = params.priority or display.DIALOG_BUTTON_PRI
    	local callbackParam = params.callbackParam
    	
    	local node = CCExtendNode:create(size)
	    
    	if buttonImage then
    		local sprite = nil
    		sprite = createSpriteWithFile(buttonImage, size)
		    sprite:setAnchorPoint(General.anchorLeftBottom)
		    node:addChild(sprite)
	    end
    	
    	local layer = CCLayer:create()
    	
    	local isTouched = false
    	local state = {}
    	
    	local function onTouch(event, x, y)
    		if event==CCTOUCHBEGAN then
				if not isTouched and (isTouchInNode(node, x, y) or params.parentTouch and isTouchInNode(node:getParent(), x, y)) then
					isTouched = true
					specialButtonTouchHandler(isTouched, node)
					return true
				else
					return false
				end
    		elseif event==CCTOUCHMOVED then
    			local eTouched = (isTouchInNode(node, x, y) or params.parentTouch and isTouchInNode(node:getParent(), x, y))
    			if isTouched~=eTouched then
					isTouched = eTouched
					specialButtonTouchHandler(isTouched, node)
					state.tapTime = 0
					state.calling = false
				end
    		else
				if isTouched then
					isTouched = false
					specialButtonTouchHandler(isTouched, node)
					if event==CCTOUCHENDED then
						callback(callbackParam)
					end
					state.tapTime = 0
					state.calling = false
				end
    		end
    	end
    	
    	local function update(diff)
    		if isTouched then
    			state.tapTime = (state.tapTime or 0)+diff
    			if not state.calling then
	    			if state.tapTime > 1 then
	    				state.calling = true
	    				state.tapTime = 0
	    				callback(callbackParam)
	    			end
	    		else
	    			if state.tapTime>0.1 then
	    				state.tapTime = 0
	    				callback(callbackParam)
	    			end
	    		end
    		end
    	end
    	
    	simpleRegisterEvent(layer, {update={callback=update, inteval=0.1}, touch={callback=onTouch, priority=priority, multi=false, swallow=false}})
    	node:addChild(layer)
    	
    	return node
    end
    
    local function createNotice(text)
    	local bg = createTTFLabel(text, General.defaultFont, 24, {colorR=255, colorG=0, colorB=0, size=CCSizeMake(900, 0)})
		screen.autoSuitable(bg, {screenAnchor=General.anchorTop, y=-160, scaleType = screen.SCALE_CUT_EDGE})
		return bg
    end
    
    local function createSwitch(size, callback, on, setting)
    	local params = setting or {}
    	local onImage = params.onImage or "images/onButton.png"
    	local offImage = params.offImage or "images/offButton.png"
    	local priority = params.priority or display.DIALOG_BUTTON_PRI
    	
    	local node = CCNode:create()
    	node:setContentSize(size)
    	
    	local sprite = nil
    	if on then
    		sprite = createSpriteWithFile(onImage, size)
		else
		    sprite = createSpriteWithFile(offImage, size)
	    end
		sprite:setAnchorPoint(General.anchorLeftBottom)
		node:addChild(sprite)
		
		local state = on
		local function switchOn()
			state = not state
			if state then
				sprite:setTexture(CCTextureCache:sharedTextureCache():addImage(onImage))
			else
				sprite:setTexture(CCTextureCache:sharedTextureCache():addImage(offImage))
			end
			callback(state)
		end
	    
    	simpleRegisterButton(node, {callback=switchOn, priority=priority, nodeChangeHandler=doNothing})
    	return node
    end
    
    UI = {createAnimateWithSpritesheet = createAnimateWithSpritesheet, createAnimateSprite = createAnimateSprite, createLabel = createTTFLabel, createSpriteWithFile = createSpriteWithFile, createScaleSprite = createScaleSprite,
    		createButton = createButton, createSpecialButton=createSpecialButton, createSwitch = createSwitch, createNotice = createNotice,
    		defaultButtonTouchHandler = defaultButtonTouchHandler}
    		
    function UI.createTextInput(baseStr, fontName, fontSize, inputSize, align, limit, priority)
    	if not priority then
    		priority = display.DIALOG_BUTTON_PRI
    	end
    	local input = CCTextInput:create(baseStr, fontName, fontSize, inputSize, align, limit)
    	input:setTouchPriority(priority)
    	return input
    end
    
    function UI.createResourceNode(costType, costValue, size, setting)
    	local params = setting or {}
    	local colorR, colorG, colorB = params.colorR or 255, params.colorG or 255, params.colorB or 255
    	local bg = CCNode:create()
    	local temp
    	temp = UI.createLabel(tostring(costValue), "fonts/font3.fnt", math.floor(size*3/4), {colorR = colorR, colorG = colorG, colorB = colorB})
    	screen.autoSuitable(temp, {nodeAnchor=General.anchorLeft, x=0, y=size/2+(params.fontOffY or 0)})
    	bg:addChild(temp)
    	local l = temp:getContentSize().width * temp:getScaleX()
    	temp = UI.createScaleSprite("images/" .. costType .. ".png", CCSizeMake(size, size))
    	screen.autoSuitable(temp, {nodeAnchor=General.anchorCenter, x=l+size/2, y=size/2})
    	bg:addChild(temp)
    	bg:setContentSize(CCSizeMake(l+size, size))
    	return bg
    end
end

require "UI.ScrollView"
require "UI.TabView"
require "UI.Slider"
require "UI.PrintTTFLabel"
require "UI.Lightning"
require "UI.BloodProcess"
require "UI.DialogUI"

function UI.testChangeScene(isIn)
	local pz = {{0, 256}, {342, 0}, {0, 0}, {0, 512}, {684, 0}}
	local epz = {{530, 704}, {900, 386}, {800, 600}, {285, 840}, {1140, 280}}
	
	local a1, a2, b, c = 0, 0.18, 0.98, 0.14
	
	if not isIn then
		pz, epz = epz, pz
		a1, a2 = 0.16, 0.04
	end
	
	local batch = CCSpriteBatchNode:create("images/fog.png")
	batch:setContentSize(CCSizeMake(1024, 768))
	local t = getParam("actionTimeChangeScene", 1000)/1000
	
	for i=1, 5 do
		local temp, array
		
		temp = CCSprite:create("images/fog.png")
		temp:setScale(4)
		screen.autoSuitable(temp, {nodeAnchor=General.anchorRightTop, x=pz[i][1], y=pz[i][2]})
		batch:addChild(temp)
		array = CCArray:create()
		array:addObject(CCDelayTime:create(t*(a1+a2*(i-1))))
		array:addObject(CCMoveTo:create(t*(b-c*i), CCPointMake(epz[i][1], epz[i][2])))
		temp:runAction(CCSequence:create(array))
		
		temp = CCSprite:create("images/fog.png")
		temp:setScale(4)
		screen.autoSuitable(temp, {nodeAnchor=General.anchorLeftBottom, x=1024-pz[i][1], y=768-pz[i][2]})
		batch:addChild(temp)
		array = CCArray:create()
		array:addObject(CCDelayTime:create(t*(a1+a2*(i-1))))
		array:addObject(CCMoveTo:create(t*(b-c*i), CCPointMake(1024-epz[i][1], 768-epz[i][2])))
		temp:runAction(CCSequence:create(array))
	end
	screen.autoSuitable(batch, {screenAnchor=General.anchorCenter, scaleType=screen.SCALE_NORMAL})
	display.getCurrentScene().scene:addChild(batch, 10000)
	if isIn then
		delayRemove(t+1, batch)
	else
		delayRemove(10, batch)
	end
end

Action.test = UI.testChangeScene