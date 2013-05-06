screen = nil
do
	local baseWidth, baseHeight = 1024, 768
	local scaleCache = {}
	
	local SCALE_HEIGHT_FIRST = 1
	local SCALE_WIDTH_FIRST = 2
	local SCALE_NORMAL = 3
	local SCALE_CUT_EDGE = 4
	local SCALE_NOT = 5

	local function getScalePolicy(width, height)
		if not width or width<=0 then width = baseWidth end
		if not height or height<=0 then height = baseHeight end
		local policy = scaleCache[width .. "_" .. height]
		if not policy then
			policy = {}
			local scale1, scale2 = General.winSize.width/width, General.winSize.height/height
			policy[SCALE_HEIGHT_FIRST] = scale2
			policy[SCALE_WIDTH_FIRST] = scale1
			if scale1>scale2 then
				scale1, scale2 = scale2, scale1
			end
			policy[SCALE_NORMAL] = scale2
			policy[SCALE_CUT_EDGE] = scale1
			policy[SCALE_NOT] = 1
			scaleCache[width .. "_" .. height] = policy
		end
		return policy
	end
	local function autoSuitable(node, setting)
		local params = setting or {}
		local width, height = params.width, params.height
		local offx, offy = params.x or 0, params.y or 0
		local screenAnchor = params.screenAnchor or General.anchorLeftBottom
		local scaleType = params.scaleType or SCALE_NOT
		local nodeAnchor = params.nodeAnchor or screenAnchor
		
		local policy = getScalePolicy(width, height)
		local scale = params.scale or policy[scaleType]
		
		node:setScaleX(node:getScaleX() * scale)
		node:setScaleY(node:getScaleY() * scale)
		node:setAnchorPoint(nodeAnchor)
		node:setPosition(screenAnchor.x * General.winSize.width + offx * scale, screenAnchor.y * General.winSize.height + offy *scale)
		return scale
	end
	
	screen = {SCALE_HEIGHT_FIRST = SCALE_HEIGHT_FIRST, SCALE_WIDTH_FIRST = SCALE_WIDTH_FIRST,
		SCALE_NORMAL = SCALE_NORMAL ,SCALE_CUT_EDGE = SCALE_CUT_EDGE;
		getScalePolicy = getScalePolicy, autoSuitable = autoSuitable
	}
end