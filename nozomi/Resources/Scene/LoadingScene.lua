require "data.TipsData"
require "Dialog.WaitAttackDialog"

LoadingScene = class()

function LoadingScene:ctor()
	local bg = CCNode:create()
	self.view = bg
	
	local temp = nil
    temp = UI.createSpriteWithFile("images/loadingBack.png")
    screen.autoSuitable(temp, {screenAnchor=General.anchorCenter, scaleType=screen.SCALE_NORMAL})
    bg:addChild(temp)
    
    CCTextureCache:sharedTextureCache():removeTextureForKey("images/loadingBack.png")
    
    temp = UI.createSpriteWithFile("images/loadingTitle.png")
    screen.autoSuitable(temp, {screenAnchor=General.anchorTop, scaleType=screen.SCALE_NORMAL, x=-17})
    bg:addChild(temp)
    
    CCTextureCache:sharedTextureCache():removeTextureForKey("images/loadingTitle.png")
    
    temp = UI.createSpriteWithFile("images/tipsBg.png",CCSizeMake(518, 67))
    screen.autoSuitable(temp, {screenAnchor=General.anchorBottom, scaleType=screen.SCALE_NORMAL, x=0, y=12})
    bg:addChild(temp)
    local temp1 = UI.createLabel(TipsData.getTip(), "fonts/font3.fnt", 14, {colorR = 255, colorG = 255, colorB = 255, size=CCSizeMake(506, 50)})
    screen.autoSuitable(temp1, {x=259, y=34, nodeAnchor=General.anchorCenter})
    temp:addChild(temp1)
    CCTextureCache:sharedTextureCache():removeTextureForKey("images/tipsBg.png")
    
    temp = UI.createSpriteWithFile("images/loadingProcessBack.png",CCSizeMake(283, 25))
    screen.autoSuitable(temp, {screenAnchor=General.anchorBottom, scaleType=screen.SCALE_NORMAL, x=0, y=66})
    bg:addChild(temp)
    local filler = UI.createSpriteWithFile("images/loadingProcessFiller.png",CCSizeMake(279, 20))
    screen.autoSuitable(filler, {x=2, y=3})
    temp:addChild(filler)
    local fillerSize = filler:getContentSize()
    
    CCTextureCache:sharedTextureCache():removeTextureForKey("images/loadingProcessBack.png")
    CCTextureCache:sharedTextureCache():removeTextureForKey("images/loadingProcessFiller.png")
    
    local infoLabel = UI.createLabel(StringManager.getString("labelLoading"), "fonts/font3.fnt", 16, {colorR = 255, colorG = 255, colorB = 255})
    screen.autoSuitable(infoLabel, {x=132, y=29, nodeAnchor=General.anchorTop})
    temp:addChild(infoLabel)
    
    local function setPercent(percent)
    	filler:setTextureRect(CCRectMake(0, 0, fillerSize.width*percent/100, fillerSize.height))
    end
    setPercent(0)
    local cp = 0
    local loadData = nil
    local function update(diff)
    	if cp==100 then
            if loadData then
    			local scene = OperationScene.new(false)
    			scene:initView()
    			scene:initGround()
    			scene:initData(loadData)
    			scene:initMenu()
    			display.runScene(scene)
    			
    			-- TEST
    			CCSpriteBatchNode:create("images/fog.png")
            end
            return
    	end
    	cp = cp + math.random(10)
    	if cp > 100 then cp = 100 end
    	setPercent(cp)
    end
    local requestData = nil
    local function requestSelfData(isSuc, result)
    	if isSuc then
            local data = json.decode(result)
            if data.attackTime then
                if not display.isDialogShow() then
                    display.showDialog(WaitAttackDialog.new(data.attackTime))
                end
                delayCallback(squeeze(data.attackTime, 5, 30), requestData)
            else
                loadData = data
            end
        else
            print("test")
    	end
    end
    
    requestData = function()
        network.httpRequest("getData", requestSelfData, {params={uid=UserData.userId, login=1}})
    end
    local function requestSelfId(isSuc, result)
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
	            requestData()
            end
        else
            print("test")
    	end
    end
    local function readyToLoad()
        local username = CCUserDefault:sharedUserDefault():getStringForKey("username")
        if username and username~="" then
            print("username", username)
            network.httpRequest("login", requestSelfId, {isPost=true, params={username=username, nickname=CCUserDefault:sharedUserDefault():getStringForKey("nickname")}})
        else
            delayCallback(1, readyToLoad)
        end
    end
    readyToLoad()
    simpleRegisterEvent(bg, {update={callback = update, inteval=0.2}})
end