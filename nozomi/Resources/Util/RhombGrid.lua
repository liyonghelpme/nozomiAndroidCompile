RhombGrid = class()

function RhombGrid:ctor(gridNodeSizeX, gridNodeSizeY, baseX, baseY)
	self.grids = {}
	self.baseX = baseX or 0
	self.baseY = baseY or 0
	self.sizeX = gridNodeSizeX
	self.sizeY = gridNodeSizeY
	self.limits = {}
end

function RhombGrid:setLimit(key, min, max)
	self.limits[key] = {min, max}
end

function RhombGrid:getGridKey(gridX, gridY)
	return gridX*10000 + gridY
end

function RhombGrid:getGrid(key, x, y)
	local grid = self.grids[self:getGridKey(x, y)]
	if grid then
		return grid[key]
	end
end

function RhombGrid:setGrid(key, x, y)
	local grid = self.grids[self:getGridKey(x, y)]
	if not grid then
		grid = {}
		self.grids[self:getGridKey(x, y)] = grid
	end
	grid[key] = {value=1}
	return grid[key]
end

function RhombGrid:checkGridEmpty(key, gx, gy, gsize, fx, fy)
	local limit = self.limits[key]
	if limit and (gx<limit[1] or gy<limit[1] or gx+gsize-1>limit[2] or gy+gsize-1>limit[2]) then
		return false
	end
	for i=1, gsize do
		for j=1, gsize do
			local x, y = gx+i-1, gy+j-1
			if fx and fy and x>=fx and x<fx+gsize and y>=fy and y<fy+gsize then
				--continue
			else
				local grid = self:getGrid(key, x, y)
				if grid and grid.value>0 then
					return false
				end
			end
		end
	end
	return true
end

function RhombGrid:setGridUse(key, gx, gy, gsize)
	for i=1, gsize do
		for j=1, gsize do
			local x, y = gx+i-1, gy+j-1
			local grid = self:getGrid(key, x, y)
			if grid then
				grid.value = grid.value + 1
			else
				self:setGrid(key, x, y)
			end
		end
	end
end

function RhombGrid:clearGridUse(key, gx, gy, gsize)
	for i=1, gsize do
		for j=1, gsize do
			local x, y = gx+i-1, gy+j-1
			local grid = self:getGrid(key, x, y)
			grid.value = grid.value - 1
		end
	end
end

-- 按居中的思路转换一个坐标到格子, x\y是坐标，gsize是几乘几的格子，scale表示格子数放大倍数，默认为1
function RhombGrid:convertToGrid(x, y, gsize, scale)
	scale = scale or 1
	local fx, fy = (x-self.baseX)*scale/self.sizeX, (y-self.baseY)*scale/self.sizeY
	local rx, ry = fy-fx,fx+fy
	local mathSize = ((gsize or 1)-1)/2
	local ret = {gridPosX=math.floor(rx-mathSize), gridPosY=math.floor(ry-mathSize), gridSize=gsize, scale=scale}
	ret.gridFloatX = rx - ret.gridPosX
	ret.gridFloatY = ry - ret.gridPosY
	return ret
end

-- 转换一个格子到其中下的坐标
function RhombGrid:convertToPosition(gx, gy)
	return {(gy-gx)*self.sizeX/2 + self.baseX, (gy+gx)*self.sizeY/2 + self.baseY}
end

function RhombGrid:isTouchInGrid(x, y, gx, gy, gsize)
	local grid = self:convertToGrid(x, y)
	if grid.gridPosX>=gx and grid.gridPosX<gx+gsize and grid.gridPosY>=gy and grid.gridPosY<gy+gsize then
		return true
	end
	return false
end

function RhombGrid:getGridDistance(ox, oy)
	local fx, fy = ox/self.sizeX, oy/self.sizeY
	local rx, ry = fy-fx, fx+fy
	return math.sqrt(rx*rx + ry*ry)
end