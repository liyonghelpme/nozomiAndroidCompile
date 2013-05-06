ClanDialog = {}

do

	function ClanDialog.joinClanOver(suc, result)
		if suc then
			display.closeDialog()
			UserData.clan = json.decode(result).cid
			EventManager.sendMessage("EVENT_JOIN_CLAN", UserData.clan)
		end
	end
	
	function ClanDialog.onJoin(clanInfo)
		network.httpRequest("joinClan", ClanDialog.joinClanOver, {isPost=true, params={cid=clanInfo.id, uid=UserData.userId}})
	end
	
	function ClanDialog.reloadMyClan(bg, clanInfo)
		bg:removeAllChildrenWithCleanup(true)
		local temp
		
		for i, memberInfo in ipairs(clanInfo.memberInfos) do 
			temp = UI.createSpriteWithFile("images/dialogItemBgUser.png",CCSizeMake(817, 56))
			screen.autoSuitable(temp, {x=21, y=428-70*i})
			bg:addChild(temp)
			local temp1 = UI.createLabel(StringManager.getString("No." .. i .. " name:" .. memberInfo.name .. " score:" .. memberInfo.score), General.defaultFont, 25, {colorR = 0, colorG = 0, colorB = 0})
			screen.autoSuitable(temp1, {x=20, y=31, nodeAnchor=General.anchorLeft})
			temp:addChild(temp1)
		end
		
		temp = UI.createSpriteWithFile("images/dialogItemBgClan.png",CCSizeMake(809, 150))
		screen.autoSuitable(temp, {x=23, y=427})
		bg:addChild(temp)
		temp = UI.createLabel("Name:" .. clanInfo.name .. "\nScore:" .. clanInfo.score .. "\nMembers:" .. clanInfo.members .. "/50", General.defaultFont, 30)
		screen.autoSuitable(temp, {x=42, y=450})
		bg:addChild(temp)
		if UserData.clan==0 then
			temp = UI.createButton(CCSizeMake(87, 44), ClanDialog.onJoin, {callbackParam=clanInfo, image="images/dialogButtonGreen.png", text=StringManager.getString("Join"), fontSize=25, fontName=General.specialFont})
			screen.autoSuitable(temp, {x=775, y=458, nodeAnchor=General.anchorCenter})
			bg:addChild(temp)
		elseif UserData.clan == clanInfo.id then
			temp = UI.createButton(CCSizeMake(87, 44), ClanDialog.onLeave, {callbackParam=clanInfo, image="images/dialogButtonGreen.png", text=StringManager.getString("Leave"), fontSize=25, fontName=General.specialFont})
			screen.autoSuitable(temp, {x=775, y=458, nodeAnchor=General.anchorCenter})
			bg:addChild(temp)
		end
	end
	
	function ClanDialog.visitMyClan(suc, result, bg)
		if suc then
			local data = json.decode(result)
			ClanDialog.clanInfo = data
			ClanDialog.reloadMyClan(bg, data)
		end
	end
	
	function ClanDialog.createMyClanTab(params)
		local bg = CCNode:create()
		bg:setContentSize(CCSizeMake(858, 660))
		local clanInfo = params.clanInfo or ClanDialog.clanInfo
		if clanInfo then
			ClanDialog.reloadMyClan(bg, clanInfo)
		else
			network.httpRequest("getClanInfos", ClanDialog.visitMyClan, {params={cid=UserData.clan}, callbackParam=bg})
		end
		return bg
	end

	function ClanDialog.visitClanOver(suc, result, tabview)
		if suc then
			local data = json.decode(result)
			tabview.pushTab(ClanDialog.createMyClanTab({clanInfo=data}))
		end
	end

	function ClanDialog.visitClan(params)
		network.httpRequest("getClanInfos", ClanDialog.visitClanOver, {params={cid=params.cid}, callbackParam=params.tabview})
	end
	
	function ClanDialog.reloadClans(view, clans)
		view:removeAllChildrenWithCleanup(true)
		if #clans>0 then
			for i=1, #clans do
				local bg = CCNode:create()
				bg:setContentSize(CCSizeMake(817, 56))
				screen.autoSuitable(bg, {x=21, y=591-i*71})
				view:addChild(bg)
				
				temp = UI.createSpriteWithFile("images/dialogItemBgUser.png",CCSizeMake(817, 56))
				screen.autoSuitable(temp, {x=0, y=0})
				bg:addChild(temp)
				local clanInfo = clans[i]
				temp = UI.createLabel(clanInfo.name, General.defaultFont, 20, {colorR = 0, colorG = 0, colorB = 0})
				screen.autoSuitable(temp, {x=56, y=33, nodeAnchor=General.anchorLeft})
				bg:addChild(temp)
				temp = UI.createLabel(StringManager.getString("Members: " .. clanInfo.members .. "/50"), General.defaultFont, 20, {colorR = 0, colorG = 0, colorB = 0})
				screen.autoSuitable(temp, {x=482, y=34, nodeAnchor=General.anchorLeft})
				bg:addChild(temp)
				temp = UI.createSpriteWithFile("images/dialogItemBgScore.png",CCSizeMake(142, 41))
				screen.autoSuitable(temp, {x=660, y=8})
				bg:addChild(temp)
				temp = UI.createLabel(tostring(clanInfo.score), General.defaultFont, 25, {colorR = 0, colorG = 0, colorB = 0})
				screen.autoSuitable(temp, {x=708, y=29, nodeAnchor=General.anchorLeft})
				bg:addChild(temp)
				temp = UI.createLabel(StringManager.getString("Anyone can join"), General.defaultFont, 16, {colorR = 0, colorG = 0, colorB = 0})
				screen.autoSuitable(temp, {x=55, y=11, nodeAnchor=General.anchorLeft})
				bg:addChild(temp)
				temp = UI.createLabel(StringManager.getString("Tap to view details"), General.defaultFont, 16, {colorR = 0, colorG = 0, colorB = 0})
				screen.autoSuitable(temp, {x=187, y=11, nodeAnchor=General.anchorLeft})
				bg:addChild(temp)
				temp = UI.createSpriteWithFile("images/clanIconTest.png",CCSizeMake(30, 36))
				screen.autoSuitable(temp, {x=14, y=9})
				bg:addChild(temp)
				
				simpleRegisterButton(bg, {callback=ClanDialog.visitClan, callbackParam={cid=clanInfo.id, tabview=ClanDialog.tabview}, priority=display.DIALOG_BUTTON_PRI})
			end
		end
	end
	
	function ClanDialog.findClansOver(suc, result, view)
		if suc then
			local clans = json.decode(result)
			ClanDialog.clans = clans
			ClanDialog.reloadClans(view, clans)
		end
	end
	
	function ClanDialog.createClansTab(params)
		local bg = CCNode:create()
		bg:setContentSize(CCSizeMake(858, 660))
		local clans = params.clans or ClanDialog.clans
		if clans then
			ClanDialog.reloadClans(bg, clans)
		else
			network.httpRequest("findClans", ClanDialog.findClansOver, {callbackParam=bg})
		end
		return bg
	end
	
	function ClanDialog.createClanOver(suc, result)
		if suc then
			local data = json.decode(result)
			UserData.clan = data.cid
			display.closeDialog()
		end
	end
	
	function ClanDialog.onSave(params)
		local name = params[1]:getString()
		network.httpRequest("createClan", ClanDialog.createClanOver, {isPost=true, params={name=name, uid=UserData.userId}})
	end
	
	function ClanDialog.createCreateClanTab()
		local bg, temp = CCNode:create()
		bg:setContentSize(CCSizeMake(858, 660))
		
		temp = UI.createLabel("name:", General.defaultFont, 23, {colorR=0, colorG=0, colorB=0})
		screen.autoSuitable(temp, {nodeAnchor=General.anchorRight, x=310, y=360})
		bg:addChild(temp)
		local input = CCTextInput:create("", General.defaultFont, 23, CCSizeMake(230, 30), 0, 12)
		screen.autoSuitable(input, {x=429, y=360, nodeAnchor=General.anchorCenter})
		bg:addChild(input)
		input:setColor(ccc3(0,0,0))
		
		temp = UI.createButton(CCSizeMake(87, 44), ClanDialog.onSave, {callbackParam={input}, image="images/dialogButtonGreen.png", text=StringManager.getString("Save"), fontSize=25, fontName=General.specialFont})
		screen.autoSuitable(temp, {x=417, y=82, nodeAnchor=General.anchorCenter})
		bg:addChild(temp)
		
		return bg
	end
	
	function ClanDialog.searchClanOver(suc, result)
		if suc then
			local data=json.decode(result)
			ClanDialog.tabview.pushTab(ClanDialog.createClansTab({clans=data}))
		end
	end
	
	function ClanDialog.onSearch(input)
		local match = input:getString()
		network.httpRequest("searchClan", ClanDialog.searchClanOver, {params={match=match}})
	end
	
	function ClanDialog.createSearchTab()
		local bg, temp = CCNode:create()
		bg:setContentSize(CCSizeMake(858, 660))
		temp = UI.createLabel(StringManager.getString("Search Clan:"), General.defaultFont, 25, {colorR = 0, colorG = 0, colorB = 0})
		screen.autoSuitable(temp, {x=90, y=430, nodeAnchor=General.anchorLeft})
		bg:addChild(temp)
		temp = UI.createSpriteWithFile("images/dialogItemTextinput.png",CCSizeMake(349, 48))
		screen.autoSuitable(temp, {x=245, y=404})
		bg:addChild(temp)
		local input = CCTextInput:create("", General.defaultFont, 25, CCSizeMake(349, 48), 0, 12)
		screen.autoSuitable(input, {x=245, y=404})
		bg:addChild(input)
		input:setColor(ccc3(0,0,0))
		temp = UI.createButton(CCSizeMake(87, 44), ClanDialog.onSearch, {callbackParam=input, image="images/dialogButtonGreen.png", text=StringManager.getString("search"), fontSize=25, fontName=General.specialFont})
		screen.autoSuitable(temp, {x=661, y=432, nodeAnchor=General.anchorCenter})
		bg:addChild(temp)
		
		return bg
	end
	
	function ClanDialog.create()
		local temp, bg = nil
		bg = UI.createButton(CCSizeMake(858, 660), doNothing, {image="images/dialogBgTrain.png", priority=display.DIALOG_PRI, nodeChangeHandler = doNothing})
		screen.autoSuitable(bg, {screenAnchor=General.anchorCenter, scaleType = screen.SCALE_CUT_EDGE})
		temp = UI.createButton(CCSizeMake(45, 45), display.closeDialog, {image="images/buttonClose.png"})
		screen.autoSuitable(temp, {x=827, y=625, nodeAnchor=General.anchorCenter})
		bg:addChild(temp)
		UI.setShowAnimate(bg)
		
		local tabview = UI.createTabView(CCSizeMake(858, 660))
		
		if UserData.clan==0 then
			tabview.addTab({create=ClanDialog.createClansTab})
			tabview.addTab({create=ClanDialog.createCreateClanTab})
			tabview.addTab({create=ClanDialog.createSearchTab})
			temp = UI.createButton(CCSizeMake(217, 49), tabview.changeTab, {callbackParam=1, image="images/dialogItemTab.png", text=StringManager.getString("Join Clan"), fontName=General.defaultFont, fontSize=23, colorR = 0, colorG = 0, colorB = 0})
			screen.autoSuitable(temp, {x=224, y=615, nodeAnchor=General.anchorCenter})
			bg:addChild(temp)
			temp = UI.createButton(CCSizeMake(217, 49), tabview.changeTab, {callbackParam=2, image="images/dialogItemTab.png", text=StringManager.getString("Create Clan"), fontName=General.defaultFont, fontSize=23, colorR = 0, colorG = 0, colorB = 0})
			screen.autoSuitable(temp, {x=453, y=615, nodeAnchor=General.anchorCenter})
			bg:addChild(temp)
			temp = UI.createButton(CCSizeMake(217, 49), tabview.changeTab, {callbackParam=3, image="images/dialogItemTab.png", text=StringManager.getString("Search Clan"), fontName=General.defaultFont, fontSize=23, colorR = 0, colorG = 0, colorB = 0})
			screen.autoSuitable(temp, {x=682, y=615, nodeAnchor=General.anchorCenter})
			bg:addChild(temp)
		else
			tabview.addTab({create=ClanDialog.createMyClanTab})
			temp = UI.createButton(CCSizeMake(217, 49), tabview.changeTab, {callbackParam=1, image="images/dialogItemTab.png", text=StringManager.getString("My Clan"), fontName=General.defaultFont, fontSize=23, colorR = 0, colorG = 0, colorB = 0})
			screen.autoSuitable(temp, {x=224, y=615, nodeAnchor=General.anchorCenter})
			bg:addChild(temp)
		end
		
		screen.autoSuitable(tabview.view, {x=0, y=0})
		bg:addChild(tabview.view)
		
		ClanDialog.tabview = tabview
		
		--temp = UI.createButton(CCSizeMake(87, 44), onBack, {image="images/dialogButtonGreen.png", text=StringManager.getString("back"), fontSize=25, fontName=General.specialFont})
		--screen.autoSuitable(temp, {x=56, y=614, nodeAnchor=General.anchorCenter})
		--bg:addChild(temp)
		--temp = UI.createSpriteWithFile("images/back.png",CCSizeMake(48, 18))
		--screen.autoSuitable(temp, {x=35, y=606})
		--bg:addChild(temp)
		return bg
	end

end