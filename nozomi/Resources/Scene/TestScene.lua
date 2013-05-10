TestScene = {}

function TestScene.create()
	local bg = CCLayerColor:create(ccc4(0, 0, 255, 255), General.winSize.width, General.winSize.height)
	
	local pz = {{0, 256}, {342, 0}, {0, 0}, {0, 512}, {684, 0}}
	local epz = {{530, 704}, {900, 386}, {800, 600}, {285, 840}, {1140, 280}}
	
	local a1, a2, b, c = 0, 0.18, 0.98, 0.14
	b, c = 1.08, 0.16
	local isIn = true
	if not isIn then
		pz, epz = epz, pz
		a1, a2 = 0.16, 0.04
	end
	
	local batch = CCSpriteBatchNode:create("images/fog.png")
	batch:setContentSize(CCSizeMake(1024, 768))
	local t = getParam("actionTimeChangeScene", 800)/1000
	if not isIn then
	    t = t*2
	end
	
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
	bg:addChild(batch, 10000)
	--if isIn then
	--	delayRemove(t+1, batch)
	--else
	--	delayRemove(10, batch)
	--end
	return {view=bg}
end