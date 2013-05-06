do
	local function compare(a, b)
		return a.off < b.off
	end
	
	local function nodeChangeHandler(bIsTouched, nNode)
		if bIsTouched then
			-- ÁÐ±í¿òµÄÉùÒô
			--music.playEffect("music/but.mp3")
			nNode:setScale(0.99)
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
	
	local ScrollButton = {}
	ScrollButton.__index = ScrollButton
	
	function ScrollButton:executeTouchBegan(touchEvent, touch)
		nodeChangeHandler(true, self.view)
		self.nodeTouched = true
	end
	
	function ScrollButton:executeTouchMoved(touch, newPoint)
		local scrollView = self.scrollView
		if not touch.isMoved then
			scrollView:addChildTouch(touch.bx, touch.by)
			scrollView:changeChildTouch(touch.bx, touch.by, newPoint.x, newPoint.y)
		else
			scrollView:changeChildTouch(touch.x, touch.y, newPoint.x, newPoint.y)
		end
		if isTouchInNode(self.view, newPoint.x, newPoint.y) then
			if not self.nodeTouched then
				nodeChangeHandler(true, self.view)
				self.nodeTouched = true
			end
		else
			if self.nodeTouched then
				nodeChangeHandler(false, self.view)
				self.nodeTouched = false
			end
		end
	end
	
	function ScrollButton:executeTouchEnded(touch)
		nodeChangeHandler(false, self.view)
		self.nodeTouched = false
		if not touch.isMoved then
			self.clickedCallback(self.callbackParam)
		else
			self.scrollView:removeChildTouch(touch.x, touch.y)
		end
	end
	
	function ScrollButton:executeTouchCanceled(touch)
		if self.nodeTouched then
			nodeChangeHandler(false, self.view)
			self.nodeTouched = false
		end
		if touch.isMoved then
			self.scrollView:removeChildTouch(touch.x, touch.y)
		end
	end
	
	function ScrollButton:new(button, scrollView, callback, callbackParam)
		local self = {clickedCallback = callback, callbackParam=callbackParam, scrollView=scrollView, view=button}
		setmetatable(self, ScrollButton)
		
		local xm, ym = 0, 0
		if scrollView.isX then
			xm=1
		else
			ym=1
		end 
		
		Touch.registerMultiTouch(button, false, display.DIALOG_BUTTON_PRI, self, {XMOVE=xm, YMOVE=ym})
		
		return self
	end
	
	local ScrollView = {}
	ScrollView.__index = ScrollView
	
	function ScrollView:addItem(node, setting)
		local params = setting or {}
		local offx, offy = params.offx or 0, params.offy or 0
		local disx, disy = params.disx or 0, params.disy or 0
		local index = (params.index  or 1) - 1
		local rowmax = params.rowmax or 1
			
		local off, length, endoff = 0, 0, 0
		local nsize = node:getContentSize()
			
		local x, y = 0, 0
		if self.isX then
			x = math.floor(index / rowmax) * (nsize.width + disx) 
			y = (index % rowmax) * (nsize.height + disy)
			off = offx + x
			length = nsize.width
			endoff = disx/2
		else
			x = (index % rowmax) * (nsize.width + disx) 
			y = math.floor(index / rowmax) * (nsize.height + disy)
			off = offy + y
			length = nsize.height
			endoff = disy/2
		end
		node:setAnchorPoint(General.anchorCenter)
		node:setPosition(offx + x + nsize.width/2, -(y + offy + nsize.height/2))
		node:setVisible(false)
		self.bg:addChild(node)
		local newItem = {off = off, length = length, endoff = endoff, view = node}
		self.items[1 + #self.items] = newItem
	end
	
	function ScrollView:prepare()
		local items = self.items
		local size = self.view:getContentSize()
		local bg = self.bg
		local state = self.state
		
		table.sort(items, compare)
		local itemsNum = #items
		local lastItem = items[itemsNum]
		if lastItem == nil then
			lastItem = {off=0, length=0, endoff=0}
		end
		local rectmin, rectmax = 0, 0
		if self.isX then
			self.off_max = 0
			self.off_min = squeeze(size.width - (lastItem.off + lastItem.length + lastItem.endoff), nil, self.off_max)
			rectmin = -bg:getPositionX()
			rectmax = rectmin + size.width
		else
			self.off_min = size.height
			self.off_max = squeeze(lastItem.off + lastItem.length + lastItem.endoff, self.off_min)
			rectmax = bg:getPositionY()
			rectmin = rectmax - size.height
		end
		local index = 1
		while index<=itemsNum do
			local item = items[index]
			if item.off + item.length >= rectmin and item.off < rectmax then
				item.view:setVisible(true)
				if not state.first then state.first = index end
				state.last = index
			end
			index = index + 1
		end
		if #items == 0 then
			self.movable = false
		end
	end
	
	function ScrollView:refreshItem(direction, rectmin, rectmax)
		local items = self.items
		local state = self.state
		if direction == -1 then
			while state.first<=#items and items[state.first].off + items[state.first].length < rectmin do
				items[state.first].view:setVisible(false)
				state.first = state.first + 1
			end
			while state.last+1<=#items and items[state.last+1].off < rectmax do
				items[state.last+1].view:setVisible(true)
				state.last = state.last + 1
			end
		else
			while state.first-1>0 and items[state.first-1].off + items[state.first-1].length > rectmin do
				items[state.first-1].view:setVisible(true)
				state.first = state.first - 1
			end
			while state.last>0 and items[state.last].off > rectmax do
				items[state.last].view:setVisible(false)
				state.last = state.last - 1
			end
		end
	end
	
	function ScrollView:moveBy(off)
		if off == 0 then return end
		local rectmin, rectmax, direction = 0, 0, 1
		local bg = self.bg
		local size = self.view:getContentSize()
		if self.isX then
			local base = bg:getPositionX()
			rectmin = - (base + off)
			rectmax = rectmin + size.width
			bg:setPositionX(base + off)
			if off<0 then direction = -1 end
		else
			local base = bg:getPositionY()
			rectmax = base + off
			rectmin = rectmax - size.height
			bg:setPositionY(base + off)
			if off>0 then direction = -1 end
		end
		self:refreshItem(direction, rectmin, rectmax)
	end
	
	function ScrollView:getTouchPoint()
		local x, y, s = 0, 0, 0
		for _, point in pairs(self.selfTouches) do
			x = x+point.x
			y = y+point.y
			s = s+1
		end
		for _, point in pairs(self.childTouches) do
			x = x+point.x
			y = y+point.y
			s = s+1
		end
		if s~=0 then
			return {x=x/s, y=y/s}
		end
	end
	
	function ScrollView:executeTouchBegan(touchEvent, touch)
		if touchEvent then
			self.selfTouches = touchEvent.touches
		end
		self.state.touchPoint = self:getTouchPoint()
	end
	
	function ScrollView:addChildTouch(x, y)
		table.insert(self.childTouches, {x=x, y=y})
		self.state.touchPoint = self:getTouchPoint()
	end
	
	function ScrollView:executeTouchesMoved(touchEvent)
		if touchEvent then
			self.selfTouches = touchEvent.touches
		end
		if not self.movable then return end
		local state = self.state
		local touchPoint = self:getTouchPoint()
		local bg = self.bg
		local cPoint = bg:convertToNodeSpace(CCPointMake(touchPoint.x, touchPoint.y))
		local tcPoint = bg:convertToNodeSpace(CCPointMake(state.touchPoint.x, state.touchPoint.y))
		local off, base = nil
		if self.isX then
			off = cPoint.x - tcPoint.x
			base = bg:getPositionX()
		else
			off = cPoint.y - tcPoint.y
			base = bg:getPositionY()
		end
		if base<self.off_min or base>self.off_max then
			off = off/2
		end
		self:moveBy(off)
		state.touchPoint = touchPoint
	end
	
	function ScrollView:changeChildTouch(fx, fy, tx, ty)
		if fx==tx and fy==ty then return end
		for _, point in pairs(self.childTouches) do
			if point.x==fx and point.y==fy then
				point.x = tx
				point.y = ty
			end
		end
		self:executeTouchesMoved()
	end
	
	function ScrollView:executeTouchesEnded(touchEvent, touch)
		if touchEvent then
			self.selfTouches = touchEvent.touches
		end
		if not self.movable then return end
		local touchPoint = self:getTouchPoint()
		if touchPoint == nil then
			local base, bg = 0, self.bg
			if self.isX then
				base = bg:getPositionX()
			else
				base = bg:getPositionY()
			end
			local off=0
			if base<self.off_min then
				off = self.off_min - base
			elseif base>self.off_max then
				off = self.off_max - base
			end
			self:moveBy(off)
		end
	end
	
	function ScrollView:removeChildTouch(x, y)
		local rmKey = nil
		for key, point in pairs(self.childTouches) do
			if point.x==x and point.y==y then
				rmKey = key
				break
			end
		end
		self.childTouches[rmKey] = nil
		self:executeTouchesEnded()
	end
	
	function ScrollView:addChildTouchNode(node, callback, callbackParam)
		ScrollButton:new(node, self, callback, callbackParam)
	end
	
	function ScrollView:new(size, isX, priority)
		local clipNode = CCExtendNode:create(size, true)
		local layer = CCLayer:create()
		clipNode:addChild(layer)
		local bg = CCNode:create()
		bg:setAnchorPoint(General.anchorLeftBottom)
		bg:setPosition(0, size.height)
		clipNode:addChild(bg)
		
		local off_min, off_max = 0, 0
		local state = {}
		local items = {}
		
		local self = {view = clipNode, bg=bg, items=items, state=state, off_max=off_max, off_min=off_min, isX=isX, pageSize=pageSize, movable=true;
			selfTouches={}, childTouches={}}
		setmetatable(self, ScrollView)
		
		local xm, ym = 0, 0
		if isX then
			xm=1
		else
			ym=1
		end 
		Touch.registerMultiTouch(clipNode, true, priority or display.DIALOG_PRI, self, {XMOVE=xm, YMOVE=ym})
		return self
	end
	
	function UI.createScrollView(size, isX)
		return ScrollView:new(size, isX)
	end
	
	function UI.createScrollViewAuto(size, isX, params)
		local scrollView = ScrollView:new(size, isX, params.priority)
		local cellSize = params.size
		local cellUpdate = params.cellUpdate
		local offx, offy = params.offx or 0, params.offy or 0
		local disx, disy = params.disx or 0, params.disy or 0
		local beginIndex = params.beginIndex or 0
		local rowmax = params.rowmax or 1
		local infos = params.infos
		for i=1, #infos do
			local info = infos[i]
			if info.isNewLine then
				offx, offy = offx + (info.offx or 0), offy + (info.offy or 0)
				beginIndex = beginIndex - 1
			else
				local cell = CCExtendNode:create(cellSize, false)
				cellUpdate(cell, scrollView, info)
				scrollView:addItem(cell, {offx=offx, offy=offy, disx=disx, disy=disy, index=i+beginIndex, rowmax=rowmax})
			end
		end
		scrollView:prepare()
		if params.dismovable then
			scrollView.movable = false
		end
		return scrollView
	end
end