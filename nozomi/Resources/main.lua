
-- for CCLuaEngine traceback
function __G__TRACKBACK__(msg)
    print("----------------------------------------")
    print("LUA ERROR: " .. tostring(msg) .. "\n")
    print(debug.traceback())
    print("----------------------------------------")
end

local function main()
	print("begin")
	-- avoid memory leak
	collectgarbage("setpause", 100)
	collectgarbage("setstepmul", 5000)
	
	local cclog = function(...)
	    print(string.format(...))
	end
	
	
	--------------- must require
	require "Util.Util"
	require "General.General"
	require "UI.UI"
	require "UI.Effect"
	StringManager.init(StringManager.LANGUAGE_EN)
	
	--------------- test require
	require "param"
	
	--------------- program require
	require "data.StaticData"
	require "data.UserData"
	require "Scene.PreBattleScene"
	require "Scene.CastleScene"
	require "Scene.LoadingScene"
	
	math.randomseed(os.time()) 
	
    local function runLogoScene()
        local bg = CCLayerColor:create(ccc4(0, 0, 0, 255), General.winSize.width, General.winSize.height)
        
        local logo = UI.createSpriteWithFile("images/logo.png")
        screen.autoSuitable(logo, {screenAnchor=General.anchorCenter})
        bg:addChild(logo)
        
        logo:setScale(0)
        local t1 = getParam("actionTimeLogoAppear", 200)/1000
        local t2 = getParam("actionTimeLogoWait", 800)/1000
        logo:runAction(CCScaleTo:create(t1, 1, 1))
        
        display.runScene({view=bg})
        delayCallback(t1+t2, display.runScene, LoadingScene)
        
        CCTextureCache:sharedTextureCache():removeTextureForKey("images/logo.png")
    end
    
    CCUserDefault:sharedUserDefault():setStringForKey("username", "TEST2")
    CCUserDefault:sharedUserDefault():setStringForKey("nickname", "TEST2")
    
    --runLogoScene()
    UserData.noPerson = false
    display.runScene(LoadingScene)
    --require "Scene.TestScene"
    --display.runScene(TestScene.create())
end

xpcall(main, __G__TRACKBACK__)
