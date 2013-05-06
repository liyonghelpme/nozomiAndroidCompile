require "General.EventManager"

do
	local SCENE_PRI = 0
	local MENU_PRI = -10000
	local MENU_BUTTON_PRI = -10001
	local CHAT_PRI = -15000
	local CHAT_BUTTON_PRI = -15001
	local DARK_PRI = -19999
	local DIALOG_PRI = -20000
	local DIALOG_BUTTON_PRI = -20001
	local NOTICE_PRI = -30000
	local NOTICE_BUTTON_PRI = -30001
	
	local SCENE_ZORDER = 0
	local DIALOG_ZORDER = 1
	local NOTICE_ZORDER = 2
	
	local director = CCDirector:sharedDirector()
	local sceneStack = {}
	local curDialog = nil
	local notices = {}
	local nid = 0
	
	local function closeDialog()
		if curDialog then
			EventManager.sendMessage("EVENT_DIALOG_CLOSE", curDialog)
			local size = curDialog.view:getContentSize()
			curDialog.deleted = true
			if size.width>0 and size.width<General.winSize.width and size.height>0 and size.height<General.winSize.height then
				curDialog.view:runAction(CCEaseBackIn:create(CCScaleTo:create(0.25, 0, 0)))
				delayRemove(0.25, curDialog.dialog)
			else
				curDialog.dialog:removeFromParentAndCleanup(true)
			end
			curDialog = nil
		end
	end
	
	local function showDialog(dialog, autoPop)
		if curDialog then
			closeDialog()
		end
		if type(dialog) == "table" and (not dialog.view) then
			if dialog.create then
				dialog = dialog.create()
			elseif dialog.new then
				dialog = dialog.new()
			end
		end
		if type(dialog) == "userdata" then
			dialog = {view = dialog}
		end
		local function darkCallback()
			if autoPop then
				closeDialog()
			end
		end
		local node = UI.createButton(General.winSize, darkCallback, {priority = DARK_PRI, nodeChangeHandler = doNothing})
		
		node:setContentSize(General.winSize)
		node:setAnchorPoint(General.anchorLeftBottom)
		local dark = CCLayerColor:create(ccc4(0, 0, 0, General.darkAlpha), General.winSize.width, General.winSize.height)
		screen.autoSuitable(dark)
		node:addChild(dark)
		
		node:addChild(dialog.view)
		dialog.dialog = node
		curDialog = dialog
		EventManager.sendMessage("EVENT_DIALOG_OPEN", curDialog)
		director:getRunningScene():addChild(node, DIALOG_ZORDER)
	end
	
	local function popNotice(id)
		if notices[id] then
			notices[id]:removeFromParentAndCleanup(true)
			notices[id] = nil
		end
	end
	
	local function pushNotice(node, clear)
		local delayTime = 3
		local outArray = CCArray:create()
		local outTime = 1
		
		local my = node:getContentSize().height
		nid = nid + 1
		
		local sactions = CCArray:create()
		sactions:addObject(CCDelayTime:create(delayTime))
		sactions:addObject(CCFadeOut:create(outTime))
		node:runAction(CCSequence:create(sactions))
		delayCallback(delayTime + outTime, popNotice, nid)
		director:getRunningScene():addChild(node, NOTICE_ZORDER)
		for id, node in pairs(notices) do
			local clearTime = 0.3
			if clear then
				popNotice(id)
			else
				node:setPositionY(node:getPositionY()+1.1*my)
			end
		end
		notices[nid] = node
	end
	
	local function clearScene()
		nid = 0
		notices = {}
		closeDialog()
	end
	
	local function runScene(scene)
		if type(scene) == "table" and not scene.view then
			scene = scene.new()
		end
		if type(scene) == "userdata" then
			scene = {view = scene}
		end
		
		local cocos_scene = CCScene:create()
		cocos_scene:addChild(scene.view, SCENE_ZORDER)
		scene.scene = cocos_scene
		clearScene()
		
		local depth = #sceneStack
		if depth == 0 then
			director:runWithScene(scene.scene)
			sceneStack[1] = scene
		else
			director:replaceScene(scene.scene)
			sceneStack[depth] = scene
		end
		if scene.sceneType and #sceneStack==2 then
			Action.test()
		end
	end
	
	local function pushScene(scene)
		if type(scene) == "table" and not scene.view then
			scene = scene.new()
		end
		if type(scene) == "userdata" then
			scene = {view = scene}
		end
		clearScene()
		local cocos_scene = CCScene:create()
		cocos_scene:addChild(scene.view)
		scene.scene = cocos_scene
		director:pushScene(scene.scene)
		sceneStack[1 + #sceneStack] = scene
		if scene.sceneType then
			Action.test()
		end
	end
	
	local function popScene()
		clearScene()
		director:popScene()
		sceneStack[#sceneStack] = nil
		
		Action.test()
	end
	
	display = {SCENE_PRI = SCENE_PRI, MENU_PRI=MENU_PRI, MENU_BUTTON_PRI=MENU_BUTTON_PRI, DARK_PRI=DARK_PRI, DIALOG_PRI=DIALOG_PRI, DIALOG_BUTTON_PRI=DIALOG_BUTTON_PRI, NOTICE_PRI=NOTICE_PRI, NOTICE_BUTTON_PRI = NOTICE_BUTTON_PRI;
	closeDialog = closeDialog, showDialog = showDialog, pushNotice = pushNotice, runScene=runScene, pushScene=pushScene, popScene = popScene}
	
	function display.getCurrentScene()
		return sceneStack[#sceneStack]
	end
	
	function display.isDialogShow()
		return curDialog
	end
end