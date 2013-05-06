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
	if UserData.clan~=0 and text~="" then
		network.httpRequest("http://uhz000738.chinaw3.com:8004/send", doNothing, {params={uid=UserData.userId, cid=UserData.clan, name=UserData.userName, text=text, timeout=30}})
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
		local Y = 620
		for i=1, #msgs do
			if Y>0 then
				local msg = msgs[i]
				temp = UI.createSpriteWithFile("images/exp.png",CCSizeMake(29, 28))
				screen.autoSuitable(temp, {x=8, y=Y-31})
				bg:addChild(temp)
				temp = UI.createLabel(tostring(msg.level or 1), "fonts/font3.fnt", 33, {colorR = 255, colorG = 255, colorB = 255})
				screen.autoSuitable(temp, {x=23, y=Y-16, nodeAnchor=General.anchorCenter})
				bg:addChild(temp)
				local tempStr = StringManager.getString("You")
				if msg.uid~=UserData.userId then
					tempStr = msg.name
					
					temp = UI.createSpriteWithFile("images/chatRoomItemVisit.png",CCSizeMake(30, 31))
					screen.autoSuitable(temp, {x=69, y=Y-29})
					bg:addChild(temp)
				end
				temp = UI.createLabel(tempStr, "fonts/font1.fnt", 15, {colorR = 255, colorG = 255, colorB = 255})
				screen.autoSuitable(temp, {x=39, y=Y-16, nodeAnchor=General.anchorLeft})
				bg:addChild(temp)
				
				tempStr = StringManager.getString("Clan Member")
				temp = UI.createLabel(tempStr, "fonts/font1.fnt", 10, {colorR = 149, colorG = 148, colorB = 139})
				screen.autoSuitable(temp, {x=38, y=Y-31, nodeAnchor=General.anchorLeft})
				bg:addChild(temp)
				
				if msg.type=="msg" then
					temp = UI.createLabel(msg.text, "fonts/font1.fnt", 13, {colorR = 222, colorG = 215, colorB = 165, size=CCSizeMake(200, 0)})
					screen.autoSuitable(temp, {x=40, y=Y-47, nodeAnchor=General.anchorLeftTop})
					bg:addChild(temp)
					local lheight = temp:getContentSize().height * temp:getScale()
					Y = Y-47-lheight
				end
				
				tempStr = "Just Now"
				--StringManager.getFormatString("chatTimeAgo", {time=StringManager.getTimeString(0)
				temp = UI.createLabel(tempStr, "fonts/font1.fnt", 12, {colorR = 149, colorG = 148, colorB = 139})
				screen.autoSuitable(temp, {x=174, y=Y-11, nodeAnchor=General.anchorLeft})
				bg:addChild(temp)
				temp = UI.createSpriteWithFile("images/chatRoomSeperator.png",CCSizeMake(232, 2))
				screen.autoSuitable(temp, {x=14, y=Y-25})
				bg:addChild(temp)
				Y=Y-31
				
				--elseif msgs[i].type=="request" then
				--	temp = UI.createLabel(msgs[i].name .. " request troops:" .. msgs[i].property[2] .. "/" .. msgs[i].property[1], General.defaultFont, 20, {colorR = 255, colorG = 255, colorB = 255})
				--	screen.autoSuitable(temp, {x=9, y=Y-30, nodeAnchor=General.anchorLeft})
				--	bg:addChild(temp)
				--	local helps, canHelp = msgs[i].property[3], (UserData.userId~=msgs[i].uid and msgs[i].property[2]<msgs[i].property[1])
				--	if canHelp then
				--		for j=1, #helps, 2 do
				--			if helps[j]==UserData.userId then
				--				if helps[j+1]==5 then canHelp=false end
				--				break
				--			end
				--		end
				--	end
				--	if canHelp then
				--		temp = UI.createButton(CCSizeMake(100, 25), ChatRoom.donate, {callbackParam=msgs[i], priority=display.CHAT_BUTTON_PRI, image="images/dialogButtonGreen.png", text="donate", fontName=General.defaultFont, fontSize=20})
				--		screen.autoSuitable(temp, {x=128, y=Y-64, nodeAnchor=General.anchorCenter})
				--		bg:addChild(temp)
				--	end
				--end
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
	--temp = UI.createButton(CCSizeMake(38,40), display.showDialog, {callbackParam=ClanDialog, priority=display.CHAT_BUTTON_PRI, image="images/dialogItemButtonInfo.png"})
	--screen.autoSuitable(temp, {x=234, y=732, nodeAnchor=General.anchorCenter})
	--bg:addChild(temp)
	
	--temp = UI.createLabel(UserData.userName, General.defaultFont, 20, {colorR = 255, colorG = 255, colorB = 255})
	--screen.autoSuitable(temp, {x=50, y=716, nodeAnchor=General.anchorLeft})
	--bg:addChild(temp)
	--temp = UI.createSpriteWithFile("images/clanIconTest.png",CCSizeMake(30, 36))
	--screen.autoSuitable(temp, {x=14, y=705})
	--bg:addChild(temp)
	
	local temp, bg = nil
	bg = CCNode:create()
	bg:setContentSize(CCSizeMake(256, 768))
	ChatRoom.view = bg
	simpleRegisterButton(bg, {priority=display.MENU_BUTTON_PRI-1})
	screen.autoSuitable(bg,{screenAnchor=General.anchorLeftBottom, scaleType=screen.SCALE_HEIGHT_FIRST})
	temp = UI.createSpriteWithFile("images/chatRoomBg.png",CCSizeMake(258, 773))
	screen.autoSuitable(temp, {x=0, y=0})
	bg:addChild(temp)
	temp = UI.createSpriteWithFile("images/chatRoomSeperator.png",CCSizeMake(232, 2))
	screen.autoSuitable(temp, {x=14, y=626})
	bg:addChild(temp)
	temp = UI.createSpriteWithFile("images/dialogItemTextinput.png",CCSizeMake(184, 37))
	screen.autoSuitable(temp, {x=9, y=642})
	bg:addChild(temp)
	local input = UI.createTextInput("", General.defaultFont, 23, CCSizeMake(177, 31), 0, 12, display.CHAT_BUTTON_PRI)
	screen.autoSuitable(input, {x=9, y=642})
	bg:addChild(input)
	temp = UI.createButton(CCSizeMake(45, 39), onSendMessage, {callbackParam=input, image="images/chatRoomEnter.png", priority=display.CHAT_BUTTON_PRI})
	screen.autoSuitable(temp, {x=202, y=637})
	bg:addChild(temp)

	temp = UI.createSpriteWithFile("images/chatRoomButton.png",CCSizeMake(52, 139),true)
	screen.autoSuitable(temp, {x=251, y=328})
	bg:addChild(temp)
	local cbutton = temp
	temp = UI.createSpriteWithFile("images/chatRoomTriangle.png",CCSizeMake(23, 28))
	screen.autoSuitable(temp, {nodeAnchor=General.anchorCenter, x=26, y=69})
	cbutton:addChild(temp, 1, 1)
	ChatRoom.registerChatRoomButton(cbutton)
	
	local chatView = CCNode:create()
	chatView:setContentSize(bg:getContentSize())
	screen.autoSuitable(chatView)
	bg:addChild(chatView)
	ChatRoom.chatView = chatView
	
	if UserData.clan~=0 then
		ChatRoom.beginChat()
	end
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
	bg:setPositionX(squeeze(bg:getPositionX()+xoff, -258, 0))
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
	if boolValue then
		bg:runAction(CCMoveTo:create(0.1, CCPointMake(0, 0)))
	else
		bg:runAction(CCMoveTo:create(0.1, CCPointMake(-258, 0)))
	end
end