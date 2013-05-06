StoryScene = class()
require "Scene.CastleScene"

function StoryScene:ctor()
	self.view = CCNode:create()
	self.view:setContentSize(General.winSize)
	
	local next = UI.createButton(CCSizeMake(128, 128), self.nextFrame, {callbackParam=self, priority=display.MENU_BUTTON_PRI, text="next", fontName=General.specialFont, fontSize=30})
	screen.autoSuitable(next, {scaleType=screen.SCALE_NORMAL, nodeAnchor=General.anchorCenter, screenAnchor=General.anchorRightBottom, x=-64, y=64})
	self.view:addChild(next, 1)
	
	local skip = UI.createButton(CCSizeMake(128, 128), self.skipStory, {callbackParam=self, priority=display.MENU_BUTTON_PRI, text="skip", fontName=General.specialFont, fontSize=30})
	screen.autoSuitable(skip, {scaleType=screen.SCALE_NORMAL, nodeAnchor=General.anchorCenter, screenAnchor=General.anchorLeftBottom, x=64, y=64})
	self.view:addChild(skip, 1)
	
	self:nextFrame()
end

function StoryScene:nextFrame()
	self.frameIndex = (self.frameIndex or 0)+1
	print("next" .. self.frameIndex)
end

function StoryScene:skipStory()
	print("skip")
end