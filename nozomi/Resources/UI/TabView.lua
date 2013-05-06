do
	local function createTabView(size)
		local bg = CCNode:create()
		bg:setContentSize(size)
		local tabs = {}
		local tabsNum = 0
		local curTab = 1
		local function addTab(tab)
			if not tab.create then
				return false
			end
			tabsNum = tabsNum + 1
			tabs[tabsNum] = tab
			return true
		end
		
		local function changeTab(index)
			if index <=0 or index > tabsNum then
				return false
			end
			if index ~= curTab then
				local isShow = false
				if tabs[curTab].view then
					tabs[curTab].view:removeFromParentAndCleanup(false)
					isShow = true
				end
				curTab = index
				if isShow then
					local tab = tabs[index]
					if not tab.view then
						tab.view = tab.create(tab)
						tab.view:retain()
					end
					bg:addChild(tab.view)
				end
			end
		end
		
		local function pushTab(view)
			local isShow = false
			if tabs[curTab].view then
				tabs[curTab].view:removeFromParentAndCleanup(false)
				isShow = true
			end
			curTab = 0
			tabs[0] = {view=view}
			if isShow then
				bg:addChild(view)
			end
		end
		
		local function enterOrExit(isEnter)
			if tabsNum == 0 then
				return
			end
			if isEnter then
				local tab = tabs[curTab]
				if not tab.view then
					tab.view = tab.create(tab)
					bg:addChild(tab.view)
				elseif not tab.view:getParent() then
					-- 我觉得这种情况不可能发生
					bg:addChild(tab.view)
				end
				tab.view:retain()
			else
				for i = 1, tabsNum do
					if tabs[i].view then
						tabs[i].view:release()
					end
					if i ~= curTab then
						tabs[i].view = nil
					end
				end
			end
		end
		
		simpleRegisterEvent(bg, {enterOrExit = {callback = enterOrExit}})
		return {view = bg, addTab = addTab, pushTab=pushTab, changeTab = changeTab}
	end
	UI.createTabView = createTabView
end