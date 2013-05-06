MapGrid = nil
do
	local function createMapGrid(gridNodeSizeX, gridNodeSizeY, baseX, baseY)
		local grids = {}
		baseX, baseY = baseX or 0, baseY or 0
		
		local function getGridKey(gridX, gridY)
			return gridX*10000 + gridY
		end
		
		local function checkGridUsed(gridPosX, gridPosY, gridSizeX, gridSizeY)
			if gridPosX%2 ~= gridPosY%2 then
				return true
			end
			for i=1, gridSizeX do
				for j=1, gridSizeY do
					if grids[getGridKey(gridPosX - i + j, gridPosY + i + j - 2)] then
						return true
					end
				end
			end
			return false
		end
		
		local function checkGridMovable(gridPosX, gridPosY, gridSizeX, gridSizeY, gridOffX, gridOffY)
			if gridPosX%2 ~= gridPosY%2 then
				return false
			end
			if (gridPosX+gridOffX)%2 ~= (gridPosY+gridOffY)%2 then
				return false
			end
			for i=1, gridSizeX do
				for j=1, gridSizeY do
					local gkey = getGridKey(gridPosX+gridOffX - i + j, gridPosY+gridOffY + i + j - 2)
					if grids[gkey] and (grids[gkey].gridPosX~=gridPosX or grids[gkey].gridPosY~=gridPosY) then
						return false
					end
				end
			end
			return true
		end

		local function setGridUse(use, gridPosX, gridPosY, gridSizeX, gridSizeY)
			if gridPosX%2 ~= gridPosY%2 then
				return false
			end
			if use then
				if not checkGridUsed(gridPosX, gridPosY, gridSizeX, gridSizeY) then
					local gridInfo = {gridPosX = gridPosX, gridPosY = gridPosY, gridSizeX = gridSizeX, gridSizeY = gridSizeY}
					for i=1, gridSizeX do
						for j=1, gridSizeY do
							grids[getGridKey(gridPosX - i + j, gridPosY + i + j - 2)] = gridInfo
						end
					end
					return true
				end
			else
				local oldGrid = grids[getGridKey(gridPosX, gridPosY)]
				if oldGrid and oldGrid.gridPosX == gridPosX and oldGrid.gridPosY == gridPosY then
					for i=1, oldGrid.gridSizeX do
						for j=1, oldGrid.gridSizeY do
							grids[getGridKey(gridPosX - i + j, gridPosY + i + j - 2)] = nil
						end
					end
					return true
				end
			end	
			return false	
		end
		
		-- 假定都是以中间靠下为坐标点, 格子同样； 这是将建筑坐标转变成GRID的方法
		local function convertToMapGrid(posX, posY, gridSizeX, gridSizeY)
			gridSizeX = gridSizeX or 1
			gridSizeY = gridSizeY or 1
			local rx = (posX - baseX)/gridNodeSizeX + (gridSizeY - gridSizeX)/2
			local ry = (posY - baseY)/gridNodeSizeY + 1
			local irx, iry = math.floor(rx), math.floor(ry)
			if irx%2 ~= iry%2 then irx=irx-1 end
			local frx, fry = rx-irx, ry-iry
			if frx<1 then
				if frx+fry>1 then
					irx, iry = irx+1, iry+1
				end
			else
				if frx-fry>1 then
					irx = irx+2
				else
					irx, iry = irx+1, iry+1
				end
			end
			return {gridPosX = irx, gridPosY = iry, gridSizeX = gridSizeX, gridSizeY = gridSizeY}
		end
		
		-- 假定都是以中间靠下为坐标点, 格子同样；这是将触摸点转变成GRID的方法
		local function convertTouchMapGrid(posX, posY)
			local rx = (posX - baseX)/gridNodeSizeX
			local ry = (posY - baseY)/gridNodeSizeY
			local irx, iry = math.floor(rx), math.floor(ry)
			if irx%2 ~= iry%2 then irx=irx-1 end
			local frx, fry = rx-irx, ry-iry
			if frx<1 then
				if frx+fry>1 then
					irx, iry = irx+1, iry+1
				end
			else
				if frx-fry>1 then
					irx = irx+2
				else
					irx, iry = irx+1, iry+1
				end
			end
			local px = -(irx  * gridNodeSizeX + baseX - posX)/gridNodeSizeX
			local py = -((iry-1) * gridNodeSizeY + baseY - posY)/gridNodeSizeY
			rx, ry = (py-px)/2, (py+px)/2
			return {gridPosX = irx, gridPosY = iry, gridFloatX=rx, gridFloatY=ry}
		end
		
		local function convertToPosition(gridPosX, gridPosY, gridSizeX, gridSizeY)
			local posX = (gridPosX - (gridSizeY - gridSizeX)/2) * gridNodeSizeX + baseX
			local posY = (gridPosY-1) * gridNodeSizeY + baseY
			return {posX = posX, posY = posY, gridSizeX = gridSizeX, gridSizeY = gridSizeY}
		end
		
		local function isTouchInGrid(posX, posY, gridPosX, gridPosY)
			local grid = grids[getGridKey(gridPosX, gridPosY)]
			if grid then
				local touchGridPoint = convertTouchMapGrid(posX, posY)
				local touchGrid = grids[getGridKey(touchGridPoint.gridPosX, touchGridPoint.gridPosY)]
				if touchGrid and touchGrid.gridPosX == grid.gridPosX and touchGrid.gridPosY == grid.gridPosY then
					return true
				end
			end
			return false
		end
		
		return {grids = grids; gridNodeSizeX = gridNodeSizeX, gridNodeSizeY = gridNodeSizeY; 
		getGridKey = getGridKey, isTouchInGrid = isTouchInGrid, convertToPosition = convertToPosition, 
		convertTouchMapGrid = convertTouchMapGrid, convertToMapGrid = convertToMapGrid, setGridUse = setGridUse, checkGridUsed = checkGridUsed,
		checkGridMovable = checkGridMovable}
	end
	MapGrid = {create = createMapGrid}
end