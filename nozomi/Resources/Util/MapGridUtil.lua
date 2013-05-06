MapGridUtil = {}

do
	local WEIGHT1=20
	local WEIGHT2=14
	-- 在网格系统中进行寻路，返回一系列点集（不是格子集）
	-- TODO 在尖角拐点上不允许跨越; 为了避免在无路可走，障碍物允许在一定条件下穿越
	MapGridUtil.findWay = function(start, target, mapGrid, distance, isFly)
		local startGrid = mapGrid.convertToMapGrid(start.x, start.y)
		local endGrid = mapGrid.convertToMapGrid(target.x, target.y)
		
		
		local grids = mapGrid.grids
		local openNode = {}
		return {{x=target.x, y=target.y}}
	end
end