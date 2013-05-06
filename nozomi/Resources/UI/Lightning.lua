function UI.createLightning(size, length, thick, dismax, setting)
	local view = CCNode:create()
	local params = setting or {}
	local lightningMax = params.lightningMax or 1
	local fadeOutRate = params.rate or 3.3
	local fadeTime = 1/fadeOutRate
	print(fadeOutRate)
	view:setContentSize(size)
	
	local num, time=0, 0
	local lightnings = {}
	local function update(diff)
		time = time+diff
		local toDelete = {}
		for i, lightning in pairs(lightnings) do
			if lightning.endTime < time then
				table.insert(toDelete, i)
				lightning.view:removeFromParentAndCleanup(true)
				num = num - 1
			end
		end
		for _, i in pairs(toDelete) do
			lightnings[i] = nil
		end
		if num < lightningMax then
			local lightning = Lightning:create("", math.ceil(size.width/length)*2, length, thick, dismax)
			lightning:setColor(params.color or ccc3(51, 51, 178))
			lightning:setFadeOutRate(fadeOutRate)
			lightning:midDisplacement(0, 0, size.width, size.height, dismax)
			view:addChild(lightning)
			num = num + 1
			table.insert(lightnings, {view=lightning, endTime=time+fadeTime})
		end
	end
	simpleRegisterEvent(view, {update={callback=update, inteval=fadeTime/lightningMax}})
	return view
end