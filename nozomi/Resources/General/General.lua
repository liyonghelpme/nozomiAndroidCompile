General = {
    anchorLeftTop = CCPointMake(0, 1), anchorLeftBottom = CCPointMake(0, 0),
    anchorRightTop = CCPointMake(1, 1), anchorRightBottom = CCPointMake(1, 0),
    anchorCenter = CCPointMake(0.5, 0.5), anchorBottom = CCPointMake(0.5, 0),
    anchorTop = CCPointMake(0.5, 1), anchorLeft = CCPointMake(0, 0.5), 
    anchorRight = CCPointMake(1, 0.5);
    winSize = CCDirector:sharedDirector():getVisibleSize();
    defaultFont = "fonts/font1.fnt", specialFont = "fonts/font3.fnt";
    TOUCH_DOWN = 1, TOUCH_CANCEL = 2, TOUCH_CLICK = 3;
    nightColor = ccc3(200, 200, 200), normalColor = ccc3(255, 255, 255);
    darkAlpha=100
}

require "General.screen"
require "General.display"
require "General.timer"
require "General.network"
require "General.music"

require "General.StringManager"
require "General.EventManager"
require "General.Achievements"