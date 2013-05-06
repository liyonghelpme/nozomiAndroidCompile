require "Logic.ResourceLogic"
require "Logic.SoldierLogic"
require "Logic.BattleLogic"
require "Logic.ZombieLogic"
require "Logic.CrystalLogic"
require "Logic.GuideLogic"
require "Mould.FlyObject"
require "Mould.Tomb"
require "Mould.Build"
require "Mould.Soldier"
require "Mould.NPC"
require "Mould.Zombie"
require "Mould.Builder"
require "Dialog.AlertDialog"
require "Scene.MenuLayer"
require "Scene.BattleMenuLayer"
require "Scene.ReplayMenuLayer"
require "Scene.ChatRoom"
require "Scene.MapGridView"

CastleScene = class()

local SIZEX, SIZEY = 4090, 3068
local GRIDSIZEX, GRIDSIZEY = 92, 69
local GRIDOFFX, GRIDOFFY = 2080, 195
--local scMin, scMax = 0.5, 4

function CastleScene:ctor()
	self.speed=1
	self.touchType="none"
	self.SIZEX=SIZEX
	self.SIZEY=SIZEY
	self.stateInfo={}
	self.inertia = {enable = false, touchlist = queue.create(2), speedX=0, speedY=0}
	
	--music.playBackgroundMusic("music/business.mp3")
	
	local sceneScaleMin = screen.getScalePolicy(SIZEX, SIZEY)[screen.SCALE_NORMAL]
	self.scMin = sceneScaleMin
	self.scMax = getParam("mapScaleMax", 400)/100*sceneScaleMin
	sceneScaleMin = nil
	
    self.mapGrid = RhombGrid.new(GRIDSIZEX, GRIDSIZEY, GRIDOFFX, GRIDOFFY)
    self.mapGrid:setLimit(GridKeys.Build, 1, 40)
	
    local w = World.new(84, 1000)
	w:initCell()
	self.mapWorld = w
    self.mapWorld:setScene(self)

    self.updateEntry = nil
end

function CastleScene:initView()
	self.view = CCLayer:create()
	
	local ground = CCNode:create()
	screen.autoSuitable(ground, {screenAnchor=General.anchorCenter, nodeAnchor=General.anchorLeftBottom, x=-SIZEX/2, y=-SIZEY/2, scaleType=screen.SCALE_NORMAL, scale=self.scMin*4})
	self.view:addChild(ground)
	self.ground = ground
	
	local sky = CCNode:create()
	self.ground:addChild(sky, 10000)
	self.sky = sky
	
	-- 覆盖层贴图，让整体变色
	local colorFilter = CCLayerColor:create(ccc4(255,255,255,255), SIZEX, SIZEY)
	screen.autoSuitable(colorFilter)
	self.ground:addChild(colorFilter, 20)
	local blend = ccBlendFunc:new()
	--blend.src = 0x0306
	--blend.dst = 1
	blend.src = 0
	blend.dst = 0x0300
	colorFilter:setBlendFunc(blend)
	self.colorFilter = colorFilter
	
    --local batch = CCSpriteBatchNode:create("images/buildItemGridRed.png", 1600)
    --for i=1,40 do
    --	for j=1, 40 do
	--        	local gx, gy = 40 - i + j, i + j -2
	--        	local tmp = UI.createSpriteWithFile("images/buildItemGridRed.png", CCSize(GRIDSIZEX+2, GRIDSIZEY+2))
	--        	local pos = self.mapGrid:convertToPosition(i, j, 1)
	--        	screen.autoSuitable(tmp, {nodeAnchor=General.anchorBottom, x=pos[1], y=pos[2]-1})
	--        	batch:addChild(tmp)
	--        	tmp:setOpacity(150)
	--        	--local tmp1 = UI.createLabel(grids[i], General.defaultFont, 20, {colorR=255, colorG=0, colorB=0})
	--        	--screen.autoSuitable(tmp1,{nodeAnchor=General.anchorCenter, x=32, y=16})
	--        	--tmp:addChild(tmp1)
    --    	end
    --    end
    --self.ground:addChild(batch, 1)
    
	self.mapGridView = MapGridView.new(GRIDSIZEX, GRIDSIZEY, GRIDOFFX, GRIDOFFY)
	self.ground:addChild(self.mapGridView.view, 1)
	self.mapGridView.view:setVisible(false)
	
	simpleRegisterEvent(self.view, {update={callback = self.update, inteval = 0}, touch={callback = self.onTouch, multi = true, priority = display.SCENE_PRI, swallow = false}, enterOrExit ={callback = self.enterOrExit}}, self)
end

function CastleScene:initGround()
	-- land
	for i = 0, 3 do
		local land = UI.createSpriteWithFile("images/background/background" .. i .. ".png")
		screen.autoSuitable(land, {nodeAnchor=General.anchorLeftTop, x=(i%2)*2044, y=SIZEY - 2044*math.floor(i/2)})
		land:setScale(2)
		self.ground:addChild(land, 0)
	end
	
	self:initFogs()
end

function CastleScene:initFogs()
	local bg = self.sky
	
	local gsize = getParam("fogMoveSize", 60)/10
	local t = getParam("fogMoveTime", 10000)/1000
	
	local x, y = gsize * GRIDSIZEX, gsize * GRIDSIZEY
	
	temp = UI.createSpriteWithFile("images/sceneFog.png")
	screen.autoSuitable(temp, {x=0, y=0})
	temp:setScale(16)
	bg:addChild(temp, 30000)
	
	temp = UI.createSpriteWithFile("images/sceneCloudUp.png")
	screen.autoSuitable(temp, {x=-1042, y=1664})
	temp:setScale(16)
	bg:addChild(temp, 30000)
	temp:runAction(Action.createVibration(t, x, y))
	
	temp = UI.createSpriteWithFile("images/sceneCloudDown.png")
	screen.autoSuitable(temp, {x=2464, y=-352})
	temp:setScale(16)
	bg:addChild(temp, 30000)
	temp:runAction(Action.createVibration(t, x, y))
end

function CastleScene:initBuilds(initInfo)
	self.builds = {}
	self.walls = {}
	self.soldiers = {}
	local bnum = #(initInfo.builds)
	local bcache = {}
	for i=1, bnum do
		local build = initInfo.builds[i]
		bcache[build.bid] = (bcache[build.bid] or 0)+1
		local setting = {buildIndex=bcache[build.bid], initGridX=math.floor(build.grid/10000), initGridY=build.grid%10000, level=build.level, time=build.time}
		if build.extend then
			for k, v in pairs(build.extend) do
				setting[k] = v
			end
		end
		self.builds[build.buildIndex] = Build.create(build.bid, self, setting)
	end
end

function CastleScene:moveTo(dx, dy)
	local scale = self.ground:getScale()
	dx = squeeze(dx, General.winSize.width-self.SIZEX * scale, 0)
	dy = squeeze(dy, General.winSize.height-self.SIZEY * scale, 0)
	self.ground:setPosition(dx, dy)
end

function CastleScene:moveBy(x, y)
	local cx, cy = self.ground:getPosition()
	self:moveTo(cx + x, cy + y)
end

function CastleScene:scaleTo(scale, centerX, centerY)
	scale = squeeze(scale, self.scMin, self.scMax)
	if not (centerX and centerY) then
		centerX, centerY = General.winSize.width/2, General.winSize.height/2
	end

	local oldWorldCenter = CCPointMake(centerX, centerY)
	local nodeCenter = self.ground:convertToNodeSpace(oldWorldCenter)

	self.ground:setScale(scale)
	local newWorldCenter = self.ground:convertToWorldSpace(nodeCenter)
	self:moveBy(oldWorldCenter.x - newWorldCenter.x, oldWorldCenter.y - newWorldCenter.y)
end
		
-- 选定地图上某点移到中心的ACTION
function CastleScene:runScaleAndMoveToCenterAction(scale, nodeX, nodeY)
	scale = squeeze(scale, self.scMin, self.scMax)
	if not (nodeX and nodeY) then
		nodeX, nodeY = self.SIZEX/2, self.SIZEY/2
	end
			
	local posx, posy = self.ground:getPosition()
	local curScale = self.ground:getScale()
	local targetPos = CCPointMake(General.winSize.width/2 - nodeX * scale, General.winSize.height/2 - nodeY * scale)

	self.stateInfo.movAction = {baseX = posx, baseY = posy, baseScale = curScale, deltaX = targetPos.x - posx, deltaY = targetPos.y - posy, deltaScale = scale - curScale}
	self.stateInfo.moving = true
	self.stateInfo.totalTime = getParam("menuInTime", 500)/1000
	self.stateInfo.time = 0
end

function CastleScene:onTouchBegan(touches)
	local touchNum = table.getn(touches)/2
	self.stateInfo.touchNum = touchNum
	if touchNum==1 then
		self.stateInfo.touchPoint = {touches[1], touches[2]}
		if self.singleTouchBegin then
			self:singleTouchBegin()
		end
	else
		self.stateInfo.touchPoint = {(touches[1] + touches[3])/2, (touches[2] + touches[4])/2}
		self.stateInfo.length = math.sqrt((touches[1]-touches[3])^2 + (touches[2]-touches[4])^2)
	end
	self.inertia.enable = false
	self.inertia.touchlist.clear()
end

function CastleScene:onTouchMoved(touches)
	local touchNum = table.getn(touches)/2
	local state = self.stateInfo
	state.touchNum = touchNum
	if touchNum==1 then
		if state.touchPoint then
			local ox, oy = touches[1] - state.touchPoint[1], touches[2] - state.touchPoint[2]
			state.moving = false
			if self.touchType == "scene" then
				self:moveBy(ox, oy)
			elseif self.singleTouchMove then
				self:singleTouchMove(ox, oy)
			end
		end
		state.touchPoint = {touches[1], touches[2]}
		if self.touchType == "scene" then
			self.inertia.touchlist.push({time=timer.getTime(), point = state.touchPoint})
		end
	else
		if self.singleLock then
			return
		end
		local newPoint = {(touches[1] + touches[3])/2, (touches[2] + touches[4])/2}
		local newLength = math.sqrt((touches[1]-touches[3])^2 + (touches[2]-touches[4])^2)
		if state.touchPoint and state.length then
			self:moveBy(newPoint[1] - state.touchPoint[1], newPoint[2] - state.touchPoint[2])
			self:scaleTo(self.ground:getScale()*newLength/state.length, newPoint[1], newPoint[2])
		end
		self.touchType = "scene"
		state.moving = false
		state.touchPoint = newPoint
		state.length = newLength
	end
end

function CastleScene:singleTouchMove(ox, oy)
	if self.touchType=="none" then
		self:moveBy(ox, oy)
		self.touchType = "scene"
	end
end

function CastleScene:onTouchEnded(touches)
	local touchNum = table.getn(touches)/2
	local state = self.stateInfo
	if not state.touchNum then return end
	state.touchNum = state.touchNum - touchNum
	if state.touchNum == 0 then
		if self.touchType=="none" and self.singleTouchEnd then
			self:singleTouchEnd()
		elseif self.touchType=="scene" then
			if self.inertia.touchlist.size() == 2 then
				local t1, t2 = self.inertia.touchlist.get(1), self.inertia.touchlist.get(2)
				local stime = t1.time - t2.time
				if stime < 0.3 then
					if stime < 0.015 then stime=0.015 end
					self.inertia.touchlist.clear()
					self.inertia.speedX, self.inertia.speedY = (t1.point[1] - t2.point[1])/stime, (t1.point[2] - t2.point[2])/stime
					self.inertia.enable = true
				end
			end
		end
		self.touchType = "none"
		self.singleLock = false
	end
	state.touchTime = nil
	state.touchPoint = nil
	state.length = nil
end

function CastleScene:onTouch(eventType, touches)
	if eventType == CCTOUCHBEGAN then
		return self:onTouchBegan(touches)
	elseif eventType == CCTOUCHMOVED then
		return self:onTouchMoved(touches)
	else
		return self:onTouchEnded(touches)
	end
end

function CastleScene:updateNightMode()
	if true then return end
	if UserSetting.nightMode or UserData.isNight then
		local dtime = timer.getDayTime()
		local isTimeNight = UserSetting.nightMode --and (dtime<21600 or dtime>=64800)
		if isTimeNight ~= UserData.isNight then
			UserData.isNight = isTimeNight
			if isTimeNight then
				self.colorFilter:setColor(General.nightColor)
			else
				self.colorFilter:setColor(General.normalColor)
			end
		end
	end
end

function CastleScene:update(diff)
	self.logicDiff = (self.logicDiff or 0) + diff
	if self.logicDiff > 0.1 then
		self:updateLogic(self.logicDiff)
		self:updateNightMode()
		self.logicDiff = 0
	end
	
	local state = self.stateInfo
	if state.moving then
		state.time = state.time + diff
		local action = state.movAction
		local delta = state.time/state.totalTime
		if action.deltaScale < 0 then
			delta = Action.sinein(delta)
		else
			delta = Action.sineout(delta)
		end
		self.ground:setScale(action.baseScale + action.deltaScale * delta)
		self:moveTo(action.baseX + action.deltaX * delta, action.baseY + action.deltaY * delta)
				
		if state.time >= state.totalTime then
			state.moving = false
		end
	elseif self.inertia.enable then
		local mov = diff*(math.abs(self.inertia.speedX) + math.abs(self.inertia.speedY))
		if mov>1 then
			self:moveBy(self.inertia.speedX * diff, self.inertia.speedY * diff)
			self.inertia.speedX, self.inertia.speedY = self.inertia.speedX*0.9, self.inertia.speedY*0.9
		else
			self.inertia.enable = false
		end
	end
end

function CastleScene:enterOrExit(isEnter)
	if isEnter then
		self.isShow = true
		if not self.monitorId then
			self.monitorId = EventManager.registerEventMonitor(self.monitorEvents, self.eventHandler, self)
		end
        local updateWorld = function(diff) 
            self.mapWorld:update(diff)
        end
        self.updateEntry = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(updateWorld, 0, false)
	else
		self.isShow = false
		EventManager.removeEventMonitor(self.monitorId)
		self.monitorId = nil
        CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.updateEntry)
	end
end

function CastleScene:showBuildingArea()
	
	local areaAlpha = getParam("buildingAreaAlpha", 38)
	local lineAlpha = getParam("buildingLineAlpha", 100)
	
	local sactions = CCArray:create()
	sactions:addObject(CCAlphaTo:create(0.5, 0, areaAlpha))
	sactions:addObject(CCDelayTime:create(2))
	sactions:addObject(CCAlphaTo:create(0.5, areaAlpha, 0))
	
	self.mapGridView.blockBatch:stopAllActions()
	self.mapGridView.blockBatch:runAction(CCSequence:create(sactions))
	
	sactions = CCArray:create()
	sactions:addObject(CCAlphaTo:create(0.5, 0, lineAlpha))
	sactions:addObject(CCDelayTime:create(2))
	sactions:addObject(CCAlphaTo:create(0.5, lineAlpha, 0))
	
	self.mapGridView.linesBatch:stopAllActions()
	self.mapGridView.linesBatch:runAction(CCSequence:create(sactions))
end

function CastleScene:getMaxLevel(bid)
	local maxLevel = 0
	for i, build in pairs(self.builds) do
		if build.buildData.bid==bid and build.buildLevel>maxLevel then
			maxLevel = build.buildLevel
		end
	end
	return maxLevel
end

OperationScene = class(CastleScene)

function OperationScene:ctor(uid)
	if UserData.userId == uid then
		self.sceneType = SceneTypes.Operation
	else
		self.sceneType = SceneTypes.Visit
	end
	self.monitorEvents = {"EVENT_BUY_BUILD", "EVENT_BUY_SOLDIER", "EVENT_GUIDE_STEP"}
	self.synOver = true
	self.synTime = 0
end

function OperationScene:initMenu()
	local menu = MenuLayer.new(self)
	self.view:addChild(menu.view)
	self.menu = menu
	
	--local chatRoom = ChatRoom.create()
	--self.view:addChild(chatRoom)
end

function OperationScene:initData(initInfo)
	if type(initInfo) == "string" then
		initInfo = json.decode(initInfo)
	end
	if not self.monitorId then
		self.monitorId = EventManager.registerEventMonitor(self.monitorEvents, self.eventHandler, self)
	end
	SoldierLogic.init()
	Achievements.init(initInfo.achieves)
	Build.init()
	local obsNum = 0
	for i, build in pairs(initInfo.builds) do
		local bid = build.bid
		Build.incBuild(bid)
		if bid>=4000 and bid<5000 then
			obsNum = obsNum+1
		end
		EventManager.sendMessage("EVENT_BUILD_UPDATE", {bid=build.bid, level=build.level})
	end
	if initInfo.serverTime then
		timer.setServerTime(initInfo.serverTime)
		UserData.userScore = initInfo.score
		UserData.lastSynTime = timer.getTime(initInfo.lastSynTime)
		UserData.shieldTime = timer.getTime(initInfo.shieldTime)
		UserData.userName = initInfo.name
		UserData.clan = initInfo.clan
		
		local guideValue = initInfo.guide
		if guideValue==0 then
			GuideLogic.init(1, nil, self)
		else
			GuideLogic.init(math.floor(guideValue/100), guideValue%100, self)
		end
	end
	self:initBuilds(initInfo)
	-- TEST
	print("start", os.time())
	for i=obsNum+1, 40 do
		local bid
		while true do
			bid = 3999+math.random(18)
			if bid<4015 and bid~=4010 and bid~=4011 and bid~=4005 then break end
		end
		local b = Build.create(bid, nil, {})
		local gx, gy 
		while true do
			gx, gy = math.random(40), math.random(40)
			if self.mapGrid:checkGridEmpty(GridKeys.Build, gx, gy, b.buildData.gridSize) then
				break
			end
		end
		b:addToScene(self, {initGridX=gx, initGridY=gy})
		table.insert(self.builds, b)
	end
	print("end", os.time())
	-- TEST
	self.initInfo = initInfo
	SoldierLogic.updateSoldierList()
	
	--TEST
	
	local zombieView = MapGridView.new(GRIDSIZEX/2, GRIDSIZEY/2, 927, 2580)
	zombieView:setGridUse(GridKeys.Build, 1, 1, 7)
	zombieView:setGridUse(GridKeys.Build, 8, 1, 7)
	zombieView.view:runAction(CCAlphaTo:create(0, 100, 100))
	self.ground:addChild(zombieView.view, 1)
	
	local zombieView2 = MapGridView.new(GRIDSIZEX/2, GRIDSIZEY/2, 700, -100)
	zombieView2:setGridUse(GridKeys.Build, 1, 1, 6)
	zombieView2:setGridUse(GridKeys.Build, 1, 7, 4)
	zombieView2:setGridUse(GridKeys.Build, 0, 10, 5)
	zombieView2:setGridUse(GridKeys.Build, 0, 15, 4)
	zombieView2:setGridUse(GridKeys.Build, 1, 18, 4)
	zombieView2:setGridUse(GridKeys.Build, 4, 19, 7)
	zombieView2:clearGridUse(GridKeys.Build, 5, 20, 6)
	zombieView2:setGridUse(GridKeys.Build, 11, 19, 2)
	zombieView2:setGridUse(GridKeys.Build, 7, 1, 5)
	zombieView2:setGridUse(GridKeys.Build, 12, 1, 3)
	zombieView2:setGridUse(GridKeys.Build, 12, 2, 4)
	zombieView2:setGridUse(GridKeys.Build, 16, 2, 5)
	zombieView2:setGridUse(GridKeys.Build, 21, 3, 3)
	zombieView2:setGridUse(GridKeys.Build, 21, 4, 3)
	zombieView2:setGridUse(GridKeys.Build, 13, 13, 11)
	zombieView2:setGridUse(GridKeys.Build, 13, 24, 2)
	zombieView2:setGridUse(GridKeys.Build, 15, 24, 2)
	zombieView2:setGridUse(GridKeys.Build, 17, 24, 2)
	zombieView2:setGridUse(GridKeys.Build, 19, 24, 2)
	zombieView2:setGridUse(GridKeys.Build, 21, 24, 2)
	zombieView2:clearGridUse(GridKeys.Build, 16, 13, 7)
	zombieView2:clearGridUse(GridKeys.Build, 23, 13, 1)
	zombieView2:clearGridUse(GridKeys.Build, 13, 22, 1)
	zombieView2:clearGridUse(GridKeys.Build, 13, 23, 1)
	zombieView2.view:runAction(CCAlphaTo:create(0, 100, 100))
	self.ground:addChild(zombieView2.view, 1)
	
	zombieView2.view:setVisible(false)
	zombieView.view:setVisible(false)
	
	for i=1, 7 do
		--local z=Zombie.new(math.random(2)+10, {mapGrid=zombieView2}, 1.05)
		--z:addToScene(self)
	end
	for i=1, 4 do
		--local z=Zombie.new(math.random(2)+10, {mapGrid=zombieView}, 0.8)
		--z:addToScene(self)
	end
	--TEST 
end

function OperationScene:singleTouchMove(ox, oy)
	if self.touchType=="none" then
		self:moveBy(ox, oy)
		self.touchType = "scene"
	end
end

function OperationScene:singleTouchEnd()
	if self.focusBuild and not self.buyingBuild then
		self.focusBuild:releaseFocus()
	end
end

function OperationScene:updateLogic(diff)
	local function synDataOver(suc, result)
		if suc then
			self.synOver = true
		else
		end
	end
	self.synTime = self.synTime+diff
	if self.synTime>30 then
		if self.synOver then
			local deleteIndex = {}
			local buildMap = {}
			for i, binfo in pairs(self.initInfo.builds) do
				buildMap[binfo.buildIndex] = {index=i, info=binfo}
			end
			local delete, update={}, {}
			for i, build in pairs(self.builds) do
				if build.deleted then
					table.insert(deleteIndex, i)
				else
					local binfo = build:getBaseInfo()
					binfo.buildIndex = i
					if not buildMap[i] then
						table.insert(update, binfo)
						table.insert(self.initInfo.builds, binfo)
					else
						if not cmpData(binfo, buildMap[i].info) then
							table.insert(update, binfo)
							self.initInfo.builds[buildMap[i].index] = binfo
						end
						buildMap[i] = nil
					end
				end
			end
			for i, todel in pairs(buildMap) do
				table.insert(delete, i)
				self.initInfo.builds[todel.index] = nil
			end
			for _, i in pairs(deleteIndex) do
				self.builds[i] = nil
			end
				
			local params, needSyn = {uid=UserData.userId}, false
			
			if #delete > 0 then
				params.delete = json.encode(delete)
				needSyn = true
			end
			if #update > 0 then
				params.update = json.encode(update)
				needSyn = true
			end
			local shieldTime = timer.getServerTime(UserData.shieldTime)
			if shieldTime ~= self.initInfo.shieldTime then
				self.initInfo.shieldTime = shieldTime
				params.shieldTime = shieldTime
				needSyn = true
			end
			
			local oldAchieves = self.initInfo.achieves
			local newAchieves = Achievements.getAchievements()
			local tempMap = {}
			local updateAchieves = {}
			for i=1, #newAchieves do
				local a = newAchieves[i]
				tempMap[a[1]] = a
			end
			for i=1, #oldAchieves do
				local a = oldAchieves[i]
				local b = tempMap[a[1]]
				if b and (b[2]~=a[2] or b[3]~=a[3]) then
					a[2] = b[2]
					a[3] = b[3]
					table.insert(updateAchieves, a)
				end
			end
			if #updateAchieves > 0 then
				needSyn = true
				params.achieves = json.encode(updateAchieves)
			end
			
			local guideValue = (GuideLogic.step or 0)* 100 + (GuideLogic.num or 0)
			if guideValue~=self.initInfo.guide then
				needSyn = true
				params.guide = guideValue
			end
			
			if needSyn then
				self.synOver = false
				print(json.encode(params))
				network.httpRequest("synData", synDataOver, {isPost=true, params=params})
			end
		end
		self.synTime = 0
	end
end

function OperationScene:eventHandler(eventType, params)
	if eventType == EventManager.eventType.EVENT_BUY_BUILD then
		local bid = params
		local isContinue = false
		if type(params)=="table" then
			bid = params.buildData.bid
			isContinue = true
		end
		local info = Build.getBuildStoreInfo(bid)
		if info.buildsNum == info.totalMax then
			display.pushNotice(UI.createNotice(StringManager.getString("noticeBuildErrorTotal")))
			return
		elseif info.buildsNum == info.levelLimit then
			if info.buildsNum==0 then
				display.pushNotice(UI.createNotice(StringManager.getFormatString("noticeBuildErrorUnlock", {name=StringManager.getString("dataBuildName" .. TOWN_BID), level=info.nextLevel})))
			else
				display.pushNotice(UI.createNotice(StringManager.getFormatString("noticeBuildErrorMore", {name=StringManager.getString("dataBuildName" .. TOWN_BID), level=info.nextLevel})))
			end
			return
		else
			display.closeDialog()
		end
			
		if self.buyingBuild then
			self.buyingBuild:buyOver(false)
			self.buyingBuild = nil
		end
		local setting = {isBuying=true, buildIndex=info.buildsNum+1}
		if isContinue then
			local dir = {-1, 0}
			local g2 = params.buildView.state.grid
			if params.lastBuild then
				local g1 = params.lastBuild.buildView.state.grid
				local ox, oy =g2.gridPosX-g1.gridPosX, g2.gridPosY-g1.gridPosY
				local mx, my = math.abs(ox), math.abs(oy)
				if mx>my then
					dir = {ox/mx, 0}
				else
					dir = {0, oy/my}
				end
			end
			local gsize = params.buildView.state.grid.gridSize
			dir = {dir[1]*gsize, dir[2]*gsize}
			while g2.gridPosX+dir[1]<1 or g2.gridPosX+dir[1]>41-gsize or g2.gridPosY+dir[2]<1 or g2.gridPosY+dir[2]>41-gsize do
				dir = {-dir[2], dir[1]}
			end
			setting.initGridX = g2.gridPosX+dir[1]
			setting.initGridY = g2.gridPosY+dir[2]
		end
		self.buyingBuild = Build.create(bid, self, setting)
		if isContinue then
			self.buyingBuild.lastBuild = params
		end
	elseif eventType == EventManager.eventType.EVENT_BUY_SOLDIER then
		local soldier
		if params.from then
			soldier = SoldierHelper.create(params.sid, {level=UserData.researchLevel[params.sid]})
			soldier:addToScene(self, {params.from.buildView.view:getPosition()})
			soldier:setMoveArround(params.to)
		else
			soldier = SoldierHelper.create(params.sid, {arround=params.to, level=UserData.researchLevel[params.sid]})
			soldier:addToScene(self)
		end
		table.insert(params.to.soldiers,soldier)
	elseif eventType == EventManager.eventType.EVENT_GUIDE_STEP then
		if params[1]=="build" then
			local bid = params[2]
			for _, build in pairs(self.builds) do
				if build.buildData.bid == bid then
					local pt = GuideLogic.addPointer(0)
					local bview = build.buildView.view
					pt:setPosition(bview:getContentSize().width/2, build:getBuildY())
					bview:addChild(pt)
					break
				end
			end
		end
	end
end

BattleScene = class(CastleScene)

function BattleScene:ctor(isStage)
	if isStage then
		self.sceneType = SceneTypes.Stage
	else
		self.sceneType = SceneTypes.Battle
	end
	self.monitorEvents = {}
end

function BattleScene:initMenu()
	local menu 
	if self.sceneType == SceneTypes.Stage then
		menu = StageMenuLayer.new(self)
	else
		menu = BattleMenuLayer.new(self)
	end
	self.view:addChild(menu.view)
	self.menu = menu
end

function BattleScene:initData(initInfo)
	if type(initInfo) == "string" then
		initInfo = json.decode(initInfo)
	end
	BattleLogic.init()
	BattleLogic.computeScore(initInfo.score)
	self:initBuilds(initInfo)
	self.initInfo = initInfo
	
	UI.createAnimateSprite(1, "animate/build/bombFire_", 21, {isRepeat=false})
	UI.createAnimateSprite(1, "animate/build/bombChip_", 29, {isRepeat=false})
	UI.createAnimateWithSpritesheet(1, "nozomiFire_", 10, {isRepeat=false, plist="animate/build/nozomiFire.plist"})
	UI.createAnimateWithSpritesheet(1, "wallFire_", 10, {isRepeat=false, plist="animate/build/wallFire.plist"})
	UI.createAnimateWithSpritesheet(1, "nozomiChip_", 8, {isRepeat=false, plist="animate/build/nozomiChip.plist"})
	UI.createAnimateWithSpritesheet(1, "wallChip_", 7, {isRepeat=false, plist="animate/build/wallChip.plist"})
end

function BattleScene:singleTouchBegin()
	self.stateInfo.touchTime = timer.getTime()
end

function BattleScene:singleTouchMove(ox, oy)
	if (self.touchType~="soldier" and math.abs(ox)+math.abs(oy)>10) then
		self:moveBy(ox, oy)
		self.touchType = "scene"
	end
end

function BattleScene:singleTouchEnd()
	if self.stateInfo.touchPoint then
		self.menu:executeSelectItem(self.stateInfo.touchPoint)
	end
end

function BattleScene:updateLogic(diff)
	local state = self.stateInfo
	if (self.touchType=="none" or self.touchType=="soldier") and state.touchPoint then
		if self.touchType=="none" then
			if state.touchTime and timer.getTime() - state.touchTime > 0.5 then
				self.touchType = "soldier"
				self.singleLock = true
			end
		elseif state.touchTime and timer.getTime() - state.touchTime > getParam("soldierCallInteval", 200)/1000 then
			if self.menu:executeSelectItem(state.touchPoint) then
				state.touchTime = timer.getTime()
			else
				self.touchType = "scene"
				self.singleLock = false
			end
		end
	end
end

function BattleScene:eventHandler(eventType, params)

end

ZombieScene = class(CastleScene)

function ZombieScene:ctor()
	self.monitorEvents = {}
	self.sceneType=SceneTypes.Zombie
	ZombieLogic.init()
	self:initView()
	self:initGround()
	self:initBuilds(UserData.baseScene.initInfo)
	self:initMenu()
end

function ZombieScene:initMenu()
	local menu = ZombieMenuLayer.new(self)
	self.view:addChild(menu.view)
	self.menu = menu
end

function ZombieScene:singleTouchMove(ox, oy)
	if self.touchType=="none" then
		self:moveBy(ox, oy)
		self.touchType = "scene"
	end
end

function ZombieScene:singleTouchEnd()
	if self.focusBuild and not self.buyingBuild then
		self.focusBuild:releaseFocus()
	end
end

function ZombieScene:updateLogic(diff)
end

function ZombieScene:eventHandler(eventType, params)
	if eventType == EventManager.eventType.EVENT_BUY_BUILD then
		if self.buyingBuild then
			self.buyingBuild:buyOver(false)
			self.buyingBuild = nil
		end
		self.buyingBuild = Build.create(params.bid, self, {isBuying=true, buildIndex=params.buildsNum+1})
	elseif eventType == EventManager.eventType.EVENT_BUY_SOLDIER then
		local soldier
		if self.isShow then
			soldier = Soldier.new(params.sid)
			soldier:addToScene(self, {params.from.view:getPositionX(), params.from.view:getPositionY()})
			soldier:setMoveArround(params.to)
		else
			soldier = Soldier.new(params.sid, {arround=params.to})
			soldier:addToScene(self)
		end
		table.insert(params.to.soldiers,soldier)
	end
end

ReplayScene = class(CastleScene)

function ReplayScene:ctor(menuParam)
	self.replayFile = io.open(CCFileUtils:getWriteablePath() .. "replay.txt")
	self.monitorEvents = {}
	self.sceneType = SceneTypes.Battle
	local result = self.replayFile:read()
	local data = json.decode(result)
	self.pause = true
	self:initView()
	self:initGround()
	self:initBuilds(data)
	self:initMenu(menuParam)
	self.time = 0
	self.cmdTime = nil
	BattleLogic.battleEnd = nil
	math.randomseed(self.replayFile:read())
end

function ReplayScene:reloadScene(menuParam)
	display.runScene(ReplayScene.new(menuParam))
end

function ReplayScene:eventHandler()

end

function ReplayScene:initMenu(menuParam)
	local menu = ReplayMenuLayer.new(self, menuParam)
	self.view:addChild(menu.view)
	self.menu = menu
end

function ReplayScene:updateLogic(diff)
	if not self.pause then
		self.time = (self.time or 0)+ diff
		while not self.cmdTime or self.time>self.cmdTime do
			if self.cmdTime then
				if self.cmd[2]=="s" then
					local soldier = SoldierHelper.create(self.cmd[3], {isFighting=true})
					soldier:addToScene(self, {self.cmd[4], self.cmd[5]})
					table.insert(self.soldiers, soldier)
				elseif self.cmd[2]=="e" then
					BattleLogic.battleEnd = true
					self.pause = true
					self.menu:addReplayView(true)
					self.replayFile:close()
					break
				end
				self.cmdTime = nil
			end
			self.cmd = json.decode(self.replayFile:read())
			self.cmdTime = self.cmd[1]
		end
	end
end
