TestScene = {}

function TestScene.create()
	local bg = CCLayerColor:create(ccc4(0, 0, 255, 255), General.winSize.width, General.winSize.height)
	
	return {view=bg}
end