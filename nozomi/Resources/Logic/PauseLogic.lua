local pauseTime = 0
local isPause = false
local function pauseAndResume(event)
    if event==EventManager.eventType.EVENT_COCOS_PAUSE then
        CCNative:clearLocalNotification()
        -- 首先同步所有数据
        local scene = display.getCurrentScene[1]
        scene:updateLogic(300)
        
        local minTime=10
        local curTime = timer.getTime()
        local shieldEndTime = (UserData.shieldTime or 0)-curTime
        if shieldEndTime>1800+minTime then
            CCNative:postNotification(shieldEndTime-1800, StringManager.getString("noticeShieldExpired"))
        end
        
        local zombieTime = (UserData.zombieShieldTime or 0)-curTime
        if zombieTime>minTime then
            CCNative:postNotification(zombieTime, StringManager.getString("noticeZombieExpired"))
        end
        
        for _, build in pairs(scene.builds) do
            if not build.deleted and build.buildState==BuildStates.STATE_BUILDING and build.buildInfo.btype~=5 then
                CCNative:postNotification(build.buildEndTime-curTime, StringManager.getFormatString("noticeBuildFinish", {name=StringManager.getString("dataBuildName" .. build.buildData.bid)}))
            end
        end
        
        local trainEndTime = SoldierLogic.getTrainEndTime()
        if trainEndTime>minTime then
            CCNative:postNotification(zombieTime, StringManager.getString("noticeTrainOver"))
        end
        isPause = true
    elseif event==EventManager.eventType.EVENT_COCOS_RESUME and isPause then
        CCNative:clearLocalNotification()
        isPause = false
    end
end

EventManager.registerEventMonitor({"EVENT_COCOS_PAUSE", "EVENT_COCOS_RESUME"}, pauseAndResume)