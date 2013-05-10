ChatRoom = {messages={}}

local function eventHandler(eventType, params)
	if eventType == EventManager.eventType.EVENT_JOIN_CLAN then
		ChatRoom.beginChat()
	end
end

EventManager.registerEventMonitor({"EVENT_JOIN_CLAN"}, eventHandler)

local function onSendMessage(input)
	local text = input:getString()
	input:setString("")
	if text~="" then
		network.httpRequest("sendFeedback", doNothing, {isPost=true, params={uid=UserData.userId, name=UserData.userName, text=text}, timeout=30})
		table.insert(ChatRoom.messages, {uid=UserData.userId, name=UserData.userName, text=text, type="msg", level=UserData.ulevel})
		table.insert(ChatRoom.messages, {uid=0, name="Caesars", text=StringManager.getString("messageThankforFeedback"), type="msg"})
		ChatRoom.reloadChats()
	end
end

function ChatRoom.beginChat(beginTime)
	network.httpRequest("http://uhz000738.chinaw3.com:8004/recv", ChatRoom.receiveChat, {params={uid=UserData.userId, cid=UserData.clan, since=(beginTime or 0)}, callbackParam=beginTime, timeout=30})
end

function ChatRoom.receiveChat(suc, result, lastTime)
	print(suc, result, lastTime)
	if suc then
		local msgs = json.decode(result).messages
		for i=1, #msgs do
			local msg = msgs[i]
			if msg[5]=="msg" then
				table.insert(ChatRoom.messages, 1, {uid=msg[1], name=msg[2], text=msg[3], type=msg[5]})
			elseif msg[5]=="request" then
				local oldMsgs = ChatRoom.messages
				for j=1, #oldMsgs do
					if oldMsgs[j].type=="request" and oldMsgs[j].uid==msg[1] then
						table.remove(oldMsgs, j)
						break
					end
				end
				table.insert(ChatRoom.messages, 1, {uid=msg[1], name=msg[2], property=msg[3], type=msg[5]})
			elseif msg[5]=="donate" then
				local oldMsgs = ChatRoom.messages
				if msg[6] then
					for j=1, #oldMsgs do
						if oldMsgs[j].type=="request" and oldMsgs[j].uid==msg[1] then
							if oldMsgs[j].property[2]<msg[6] then
								oldMsgs[j].property[2] = msg[6]
							end
							break
						end
					end
				end
				if msg[1] == UserData.userId then
					display.pushNotice(UI.createNotice("You receive one " + StringManager.getString("dataSoldierName" .. msg[2])))
				end
			end
		end
		if #msgs>0 then
			lastTime = msgs[#msgs][4]
		else
			lastTime = lastTime+1
		end
		ChatRoom.reloadChats()
	end
	ChatRoom.beginChat(lastTime)
end

function ChatRoom.reloadChats()
	if ChatRoom.chatView then
		local bg=ChatRoom.chatView
		bg:removeAllChildrenWithCleanup(true)
		
		local msgs = ChatRoom.messages
		local temp
		local Y = 582
		for i=1, #msgs do
			if Y>0 then
				local msg = msgs[i]
                temp = UI.createSpriteWithFile("images/exp.png",CCSizeMake(43, 41))
                screen.autoSuitable(temp, {x=9, y=Y-41})
                bg:addChild(temp)
                temp = UI.createLabel(tostring(msg.level or 1), "fonts/font3.fnt", 18, {colorR = 255, colorG = 255, colorB = 255, lineOffset=-12})
                screen.autoSuitable(temp, {x=30, y=Y-19, nodeAnchor=General.anchorCenter})
                bg:addChild(temp)
				local tempStr = StringManager.getString("You")
				if msg.uid~=UserData.userId then
					tempStr = msg.name
					
					--temp = UI.createSpriteWithFile("images/chatRoomItemVisit.png",CCSizeMake(30, 31))
					--screen.autoSuitable(temp, {x=69, y=Y-29})
					--bg:addChild(temp)
				end
                temp = UI.createLabel(tempStr, "fonts/font1.fnt", 22, {colorR = 255, colorG = 255, colorB = 255})
                screen.autoSuitable(temp, {x=55, y=Y-20, nodeAnchor=General.anchorLeft})
                bg:addChild(temp)
				
				--tempStr = StringManager.getString("Clan Member")
                --temp = UI.createLabel(tempStr, "fonts/font1.fnt", 15, {colorR = 149, colorG = 148, colorB = 139})
                --screen.autoSuitable(temp, {x=57, y=Y-42, nodeAnchor=General.anchorLeft})
                --bg:addChild(temp)
				
				if msg.type=="msg" then
                    temp = UI.createLabel(msg.text, "fonts/font1.fnt", 20, {colorR = 222, colorG = 215, colorB = 165, size=CCSizeMake(310, 0), align=kCCTextAlignmentLeft})
                    screen.autoSuitable(temp, {x=19, y=Y-56, nodeAnchor=General.anchorLeftTop})
                    bg:addChild(temp)
					local lheight = temp:getContentSize().height * temp:getScale()
					Y = Y-lheight
				end
				
				tempStr = "Just Now"
				--StringManager.getFormatString("chatTimeAgo", {time=StringManager.getTimeString(0)
				
                temp = UI.createLabel(tempStr, "fonts/font1.fnt", 18, {colorR = 149, colorG = 148, colorB = 139})
                screen.autoSuitable(temp, {x=353, y=Y-73, nodeAnchor=General.anchorRight})
                bg:addChild(temp)
				temp = UI.createSpriteWithFile("images/chatRoomSeperator.png",CCSizeMake(336, 2))
                screen.autoSuitable(temp, {x=17, y=Y-92})
                bg:addChild(temp)
				Y=Y-100
			end
		end
	end
end

function ChatRoom.donate(target)
	network.httpRequest("http://uhz000738.chinaw3.com:8004/donate", doNothing, {params={uid=UserData.userId, toUid=target.uid, cid=UserData.clan, sid=1, slevel=1, space=1}})
	local helps = target.property[3]
	local isNew = true
	for i=1, #helps, 2 do
		if helps[i]==UserData.userId then
			helps[i+1] = helps[i+1]+1
			isNew = false
			break
		end
	end
	if isNew then
		table.insert(helps, UserData.userId)
		table.insert(helps, 1)
	end
end

function ChatRoom.create()
	
	local temp, bg = nil
	bg = CCNode:create()
	bg:setContentSize(CCSizeMake(372, 768))
	ChatRoom.view = bg
	simpleRegisterButton(bg, {priority=display.MENU_BUTTON_PRI-1})
	screen.autoSuitable(bg,{screenAnchor=General.anchorLeftBottom, scaleType=screen.SCALE_HEIGHT_FIRST,x=-372})
	ChatRoom.xoff = bg:getPositionX()
    temp = UI.createSpriteWithFile("images/chatRoomBg.png",CCSizeMake(372, 773))
    screen.autoSuitable(temp, {x=0, y=-3})
    bg:addChild(temp)
	
    temp = UI.createSpriteWithFile("images/chatRoomSeperator.png",CCSizeMake(336, 2))
    screen.autoSuitable(temp, {x=17, y=688})
    bg:addChild(temp)
    temp = UI.createSpriteWithFile("images/dialogItemTextinput.png",CCSizeMake(285, 37))
    screen.autoSuitable(temp, {x=14, y=704})
    bg:addChild(temp)
	local input = UI.createTextInput("", General.defaultFont, 37, CCSizeMake(285, 37), 0, 140, display.CHAT_BUTTON_PRI)
	screen.autoSuitable(input, {x=14, y=704})
	bg:addChild(input)
	temp = UI.createButton(CCSizeMake(45, 37), onSendMessage, {callbackParam=input, image="images/chatRoomEnter.png", priority=display.CHAT_BUTTON_PRI})
	screen.autoSuitable(temp, {nodeAnchor=General.anchorCenter, x=333, y=720})
	bg:addChild(temp)
	
    temp = UI.createSpriteWithFile("images/chatRoomSeperator.png",CCSizeMake(336, 2))
    screen.autoSuitable(temp, {x=17, y=596})
    bg:addChild(temp)
    temp = UI.createLabel(StringManager.getString("labelNozomiFeedback"), "fonts/font1.fnt", 20, {colorR = 107, colorG = 219, colorB = 0, size=CCSize(340, 0), align=kCCTextAlignmentLeft})
    screen.autoSuitable(temp, {x=18, y=641, nodeAnchor=General.anchorLeft})
    bg:addChild(temp)
    
    temp = UI.createSpriteWithFile("images/chatRoomButton.png",CCSizeMake(52, 139))
    screen.autoSuitable(temp, {x=365, y=325})
    bg:addChild(temp)
	local cbutton = temp
    temp = UI.createSpriteWithFile("images/chatRoomTriangle.png",CCSizeMake(18, 32))
    screen.autoSuitable(temp, {nodeAnchor=General.anchorCenter, x=31, y=67})
    cbutton:addChild(temp, 1, 1)
	ChatRoom.registerChatRoomButton(cbutton)
	
	local chatView = CCNode:create()
	chatView:setContentSize(bg:getContentSize())
	screen.autoSuitable(chatView)
	bg:addChild(chatView)
	ChatRoom.chatView = chatView
	--if UserData.clan~=0 then
	--	ChatRoom.beginChat()
	--end
	ChatRoom.setVisible(false)
	return bg
end

function ChatRoom.registerChatRoomButton(but)
	ChatRoom.roomButton = but
	ChatRoom.touchlist = queue.create(2)
	local layer = CCLayer:create()
	but:addChild(layer)
	
	layer:registerScriptTouchHandler(ChatRoom.onTouch, false, display.MENU_BUTTON_PRI-2, true)
	layer:setTouchEnabled(true)
end

function ChatRoom.onTouch(eventType, x, y)
	if eventType == CCTOUCHBEGAN then
		return ChatRoom.onTouchBegan(x, y)
	elseif eventType == CCTOUCHMOVED then
		return ChatRoom.onTouchMoved(x, y)
	else
		return ChatRoom.onTouchEnded(x, y)
	end
end

function ChatRoom.onTouchBegan(x, y)
	if ChatRoom.roomButton and isTouchInNode(ChatRoom.roomButton, x, y) then
		--ChatRoom.roomButton:setValOffset(20)
		ChatRoom.touchPoint = {x, y}
		ChatRoom.touchlist.push({time=timer.getTime(), point = ChatRoom.touchPoint})
		print("touch hit")
		return true
	end
end

function ChatRoom.onTouchMoved(x, y)
	local point = {x, y}
	local xoff = x-ChatRoom.touchPoint[1]
	ChatRoom.touchPoint = point
	local bg = ChatRoom.view
	bg:setPositionX(squeeze(bg:getPositionX()+xoff, ChatRoom.xoff, 0))
	ChatRoom.touchlist.push({time=timer.getTime(), point = {x,y}})
end

function ChatRoom.onTouchEnded(x, y)
	if ChatRoom.touchPoint then
		local touchlist = ChatRoom.touchlist
		local isOver = false
		if touchlist.size()==2 then
			local t1, t2 = touchlist.get(1), touchlist.get(2)
			local stime = t1.time - t2.time
			local xoff = t1.point[1] - t2.point[1]
			if stime < 0.3 and math.abs(xoff)>10 then
				print(xoff)
				ChatRoom.setVisible(xoff>0)
				isOver = true
			end
		end
		if not isOver and isTouchInNode(ChatRoom.roomButton, x, y) then
			ChatRoom.setVisible(not ChatRoom.visible)
		else
			ChatRoom.setVisible(ChatRoom.visible)
		end
		ChatRoom.touchPoint = nil
	end
end

function ChatRoom.setVisible(boolValue)
	ChatRoom.visible = boolValue
	local bg = ChatRoom.view
	bg:stopAllActions()
	local tri = ChatRoom.roomButton:getChildByTag(1)
	if boolValue then
	    tri:setScaleX(-1)
		bg:runAction(CCMoveTo:create(0.1, CCPointMake(0, 0)))
	else
	    tri:setScaleX(1)
		bg:runAction(CCMoveTo:create(0.1, CCPointMake(ChatRoom.xoff, 0)))
	end
end