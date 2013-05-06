
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
	require "Scene.StoryScene"
	require "Scene.PreBattleScene"
	require "Scene.CastleScene"
	
	math.randomseed(os.time()) 
	
	local function test(isSuc, result)
		if isSuc then
			local data = json.decode(result)
			local scene = OperationScene.new(UserData.userId)
			scene:initView()
			scene:initGround()
			scene:initData(data)
			scene:initMenu()
			display.runScene(scene)
		end
	end
	
    local function test2(isSuc, result)
        if isSuc then
            local r = json.decode(result)
            if r.code==0 then
                UserData.userId = r.uid
                if r.params then
	                params = r.params
	                for k, v in pairs(params) do
	                	PARAM[k] = v
	                end
	            end
                network.httpRequest("getData", test, {params={uid=UserData.userId}})
            end
        end
    end

    local function tempLogin()
        local username = CCUserDefault:sharedUserDefault():getStringForKey("username")
        if username and username~="" then
            print("username", username)
            network.httpRequest("login", test2, {isPost=true, params={username=username, nickname=CCUserDefault:sharedUserDefault():getStringForKey("nickname")}})
        else
            delayCallback(1, tempLogin)
        end
    end
    
    local function runLogoScene()
        local bg = CCLayerColor:create(ccc4(255, 255, 255, 255), General.winSize.width, General.winSize.height)
        
        local logo = UI.createSpriteWithFile("images/logo.png")
        screen.autoSuitable(logo, {screenAnchor=General.anchorCenter})
        bg:addChild(logo)
        
        logo:setScale(0)
        local t1 = getParam("actionTimeLogoAppear", 200)/1000
        local t2 = getParam("actionTimeLogoWait", 800)/1000
        logo:runAction(CCScaleTo:create(t1, 1, 1))
        
        display.runScene({view=bg})
        delayCallback(t1+t2, tempLogin)
    end
    
    CCUserDefault:sharedUserDefault():setStringForKey("username", "TEST6")
    CCUserDefault:sharedUserDefault():setStringForKey("nickname", "TEST6")
    
    print("CCUserDefault sharedUserDefault setStringForKey")
    runLogoScene()
    --require "Scene.TestScene"
    --display.runScene(TestScene.create())
end

xpcall(main, __G__TRACKBACK__)
