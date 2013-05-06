require "Scene.CastleScene"
require "Scene.StoryScene"

LoadingScene = nil
do
	local function createLoadingScene()
	    local layer = CCLayer:create()
	
		local temp = nil
		local bg = UI.createSpriteWithFile("images/loadMain.png", CCSizeMake(1136,640))
		screen.autoSuitable(bg, {width=1136, height=640, screenAnchor=General.anchorCenter, scaleType=screen.SCALE_NORMAL})
		layer:addChild(bg)
		temp = UI.createSpriteWithFile("images/wangguoLogo.png", CCSizeMake(220,140))
		screen.autoSuitable(temp, {x=20, y=-15, screenAnchor=General.anchorLeftTop, scaleType=screen.SCALE_NORMAL})
		layer:addChild(temp)
		temp = UI.createSpriteWithFile("images/loadingWord.png", CCSizeMake(155,35))
		screen.autoSuitable(temp, {x=-66, y=-46, screenAnchor=General.anchorRightTop, scaleType=screen.SCALE_NORMAL})
		layer:addChild(temp)
	
		local circle = UI.createSpriteWithFile("images/loadingCircle.png", CCSizeMake(50,57))
		screen.autoSuitable(circle, {x=-37, y=-58, screenAnchor=General.anchorRightTop, scaleType=screen.SCALE_NORMAL, nodeAnchor=General.anchorCenter})
		circle:runAction(CCRepeatForever:create(CCRotateBy:create(getParam("loadingRotateTime",2000)/1000, 360)))
		layer:addChild(circle)
	
		local thunder = UI.createAnimateSprite(getParam("loadingThunderTime", 1100)/1000, "animate/lighting", 6)
		screen.autoSuitable(thunder, {y=35, screenAnchor=General.anchorBottom, scaleType=screen.SCALE_NORMAL})
		layer:addChild(thunder)
		
		local percentLabel = CCLabelBMFont:create("0%", "fonts/red.fnt", 32)
		percentLabel:setPosition(General.winSize.width/2, 137)
		screen.autoSuitable(percentLabel, {y=121, screenAnchor=General.anchorBottom, scaleType=screen.SCALE_NORMAL})
		layer:addChild(percentLabel);
		local function setPercentLabel(percent)
			percentLabel:setString(percent)
		end
		
		local cp = 0
		local state = nil
		local function update(diff)
			if cp==100 then
				if state == 2 then
					display.runScene(CastleScene)
				elseif state == 1 then
					display.runScene(StoryScene)
				end
				return
			end
			cp = cp + math.random(10)
			if cp > 100 then cp = 100 end
			setPercentLabel(cp .. "%")
		end
		local function test(isSuc, result)
			if isSuc then
				local dict = json.decode(result)
				if dict.ok then
					state = 1
				else
					state = 2
				end
			end
		end
		network.httpRequest("http://uhz000738.chinaw3.com:5000/test", test)
		simpleRegisterEvent(layer, {update={callback = update, inteval=0.2}})
	    return {view = layer, setPercent = setPercentLabel}
	end
	
	LoadingScene = {create = createLoadingScene}
end