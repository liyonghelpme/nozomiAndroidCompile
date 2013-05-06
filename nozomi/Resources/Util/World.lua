-- 参考实现 http://www.policyalmanac.org/games/aStarTutorial.htm
-- https://github.com/liyonghelpme/PathFinder

require "Util.Class"
require "Util.heapq"

World = class()

--[[
startPoint 搜索起点
endPoint 搜索终点
cellNum 地图cellNum*cellNum 大小   内部表示会在地图边界加上一圈墙体 因此实际大小是(cellNum+2)*(cellNum+2) 有效坐标范围1-cellNum 
cells 记录地图每个网格的状态 nil 空白区域 Wall 障碍物 Start 开始位置 End 结束位置 

coff 将x y 坐标转化成 单一的key的系数 x*coff+y = key 默认1000


w = World()
w:initCell()
w:putStart(x, y)
w:putEnd(x, y)
w:putWall(x, y)
path = w:search()

]]--
function World:ctor(cellNum, coff)
    self.calGrid = nil
    self.startPoint = nil
    self.endPoint = nil
    self.cellNum = cellNum
    self.cellSize = 100
    if coff == nil then
        self.coff = 100000
    else
        self.coff = coff
    end
    self.allBuilds = {}
    self.prevGrids = {}
    self.typeNum = {}
    
    --当前只在攻击的时候使用该方法
    --当前帧是否已经搜索过路径
    self.searchYet = false
    --根据性能设定最大允许的每帧搜索士兵数量
    self.maxSearchNum = 1
    self.searchNum = 0
    self.passTime = 0
    self.frameRate = 0.016

    --经营场景
    self.scene = nil
end
function World:setScene(s)
    self.scene = s
end
--更新搜索状态 每固定时间 限制寻路的士兵数量
function World:update(dt)
    --print("update World State")
    self.searchYet = false
    self.searchNum = 0
end
--showGrid 显示每个网格的值
--只用于测试
--坐标变换  
--笛卡尔坐标 ---- 正则网格坐标 ---- 仿射网格坐标
--      nx = rount(x/46)  ny = round(y/34.5)            dx = RoundInt((nx+ny)/2) dy = RoundInt((ny-nx)/2) 
--      x = nx*46  y = ny*34.5            nx = dx-dy  ny = dx+dy

--得到最近的整数
function round(x)
    return math.floor(x+0.5)
end
function cartesianToNormal(x, y)
    return round(x/23), round(y/17.25)
end
function normalToAffine(nx, ny)
    return round((nx+ny)/2), round((ny-nx)/2)
end
function normalToCartesian(nx, ny)
    return nx*23, ny*17.25
end
function affineToNormal(dx, dy)
    return dx-dy, dx+dy
end
--我的affine坐标和梁浩然游戏内部的坐标的 x y 方向相反了 

function World:showGrid()
    if not self.debug then
        return
    end
    -- 0 0 坐标点位置
    local zx = 2080
    local zy = 195

    if self.calGrid ~= nil then
        self.calGrid:removeFromParentAndCleanup(true)
        self.calGrid = nil
    end
    self.calGrid = CCNode:create()
    self.calGrid:setPosition(0, 0)
    for x = 1, self.cellNum, 1 do
        for y = 1, self.cellNum, 1 do
            local key = self:getKey(x, y)
            if self.cells[key]['fScore'] ~= nil then
                --local temp = CCLabelTTF:create(self.cells[key]['fScore'].."", "Arial", 10)
                local temp = CCSprite:create("block.png")
                if self.cells[key]['isPath'] and not self.cells[key]['isReal'] then
                    temp:setColor(ccc3(0, 255, 0))
                elseif self.cells[key]['isReal'] then
                    temp:setColor(ccc3(0, 0, 255))
                elseif self.cells[key]['state'] ~= nil then
                    temp:setColor(ccc3(0, 255, 255))
                end
                temp:setOpacity(128)
                local cs = temp:getContentSize()
                temp:setScaleX(46/cs.width)
                temp:setScaleY(34.5/cs.height)
                self.calGrid:addChild(temp)
                local word = CCLabelTTF:create(""..self.cells[key]['fScore'], "Arial", 20)
                word:setColor(ccc3(255, 0, 0))
                word:setPosition(23, 17.5)
                word:setAnchorPoint(ccp(0.5, 0.5))
                temp:addChild(word)
                --我的坐标x y 轴 和 游戏中的 x y 轴相反
                local nx, ny = affineToNormal(y, x)
                local px, py = normalToCartesian(nx, ny)
                temp:setPosition(px+zx, py+zy+17.25)
            end
        end
    end
    self.scene.ground:addChild(self.calGrid, 10000)
    --是否显示调试块
    self.debug = false
end
function World:getKey(x, y)
    return x*self.coff+y
end
-- 初始化cells 
-- 每次生成路径都会修改cells的属性
-- 因此在下次搜索结束之前应该清空cells状态 
-- g 从start位置到当前的位置的开销
-- h 启发从当前位置到目标位置的开销
-- f = g+h
-- isPath 是否路径 isReal 是否光线最短路径
function World:initCell()
    self.cells = {}
    self.walls = {}
    self.path = {}
    for x = 1, self.cellNum, 1 do
        for y = 1, self.cellNum, 1 do
            self.cells[x*self.coff+y] = {state=nil, fScore=nil, gScore=nil, hScore=nil, parent=nil, isPath=nil, isReal=nil}
        end
    end
    for i = 0, self.cellNum+1, 1 do
        self.cells[0*self.coff+i] = {state='Solid', fScore=nil, gScore=nil, hScore=nil, parent=nil}
        self.cells[i*self.coff+0] = {state='Solid', fScore=nil, gScore=nil, hScore=nil, parent=nil}
        self.cells[(self.cellNum+1)*self.coff+i] = {state='Solid', fScore=nil, gScore=nil, hScore=nil, parent=nil}
        self.cells[i*self.coff+(self.cellNum+1)] = {state='Solid', fScore=nil, gScore=nil, hScore=nil, parent=nil}
    end
end
function World:putStart(x, y)
    self.startPoint = {x, y}
end
function World:putEnd(x, y)
    self.endPoint = {x, y}
end
function World:putWall(x, y)
    --print("putWall", x, y)
    self.cells[self:getKey(x, y)]['state'] = 'Wall'
end

function World:clearGrids(x, y, size)
	for i=1, size do
		for j=1, size do
			self.cells[self:getKey(x-1+i, y-1+j)]['state'] = nil
		end
	end
end

--陷阱 城墙 装饰
function World:setGrids(x, y, size)
	for i=1, size do
		for j=1, size do
			self.cells[self:getKey(x-1+i, y-1+j)]['state'] = 'Wall'
		end
	end
end

local function compareDis(a, b)
	return a[1] < b[1]
end

--普通 建筑物 
function World:setBuild(x, y, size, btype, obj)
	local fsize = (size-1)/2
	local cp = {x+fsize, y+fsize}
	self.typeNum[btype] = (self.typeNum[btype] or 0) + 1
	self.allBuilds[self:getKey(x, y)] = cp
    --for k, v in pairs(self.allBuilds) do
    --    print("allBuilding "..self:getXY(k))
    --end

	for i=x-6, x+size+5 do
		if i>0 and i<=self.cellNum then
			for j=y-6, y+size+5 do
				if j>0 and j<=self.cellNum then
					local dx, dy = math.abs(i-cp[1])-1-fsize, math.abs(j-cp[2])-1-fsize
					local dis=nil
					if dx>=0 then
						if dy<0 then
							dis = dx
						else
							dis = math.sqrt(dx*dx+dy*dy)
						end
					elseif dy>=0 then
						dis = dy
					else
						self.cells[self:getKey(i, j)]['state'] = 'Building'
                        --print("Place"..i.." "..j )
					end
					if dis then
						local prevGrid = self.prevGrids[self:getKey(i, j)]
						if not prevGrid then
							prevGrid = {}
							self.prevGrids[self:getKey(i, j)] = prevGrid
						end
						table.insert(prevGrid, {dis, cp, fsize, obj})
						table.sort(prevGrid, compareDis)
					end
				end
			end
		end
	end
    self:showGrid()
end

--清理建筑物的网格
function World:clearBuild(x, y, size, btype, obj)
	local fsize = (size-1)/2
	local cp = {x+fsize, y+fsize}
	self.allBuilds[self:getKey(x, y)] = nil
	self.typeNum[btype] = self.typeNum[btype] - 1
	for i=x-6, x+size+5 do
		if i>0 and i<=self.cellNum then
			for j=y-6, y+size+5 do
				if j>0 and j<=self.cellNum then
					local dx, dy = math.abs(i-cp[1])-1-fsize, math.abs(j-cp[2])-1-fsize
					local dis=nil
					if dx>=0 or dy>=0 then
						local prevGrid = self.prevGrids[self:getKey(i, j)]
						if prevGrid then
							local l = #prevGrid
							if l==1 then
								self.prevGrids[self:getKey(i, j)] = nil
							else
								for i=1, l do
									if prevGrid[i][4]==obj then
										table.remove(prevGrid, i)
										break
									end
								end
							end
						end
					else
						self.cells[self:getKey(i, j)]['state'] = nil
					end
				end
			end
		end
	end
end

-- 临边10 斜边 14
function World:calcG(x, y)
    local data = self.cells[self:getKey(x, y)]
    local parent = data['parent']
    local difX = math.abs(math.floor(parent/self.coff)-x)
    local difY = math.abs(parent%self.coff-y)
    local dist = 10
    -- 经营页面绕不过去城墙的时候 士兵可以穿过城墙
    --当前可以绕过5个城墙
    if data['state'] == 'Wall' then
        dist = 50
    elseif data['state'] == 'Building' then
        dist = 500
    elseif difX > 0 and difY > 0 then
        dist = 14
    end
    --print("calG "..dist)


    data['gScore'] = self.cells[parent]['gScore']+dist
end
function World:calcH(x, y, bx, by)
    local data = self.cells[self:getKey(x, y)]
	--if self.searchType=="attack" then
	--	data['hScore'] = 0
	--else
		local dx, dy = math.abs(self.endPoint[1]-x), math.abs(self.endPoint[2]-y)
		local score = (dx+dy)*10
		data['hScore'] = score
	--end
end
function World:calcF(x, y)
    local data = self.cells[self:getKey(x, y)]
    data['fScore'] = data['gScore']+data['hScore']
end
function World:pushQueue(x, y)
    local fScore = self.cells[self:getKey(x, y)]['fScore']
    heapq.heappush(self.openList, fScore)
    local fDict = self.pqDict[fScore]
    if fDict == nil then
        fDict = {}
    end
    table.insert(fDict, self:getKey(x, y))
    self.pqDict[fScore] = fDict
end

--检测邻居节点 城墙可以穿过去 普通建筑不可以
function World:checkNeibor(x, y)
    local neibors = {
        {x-1, y-1},
        {x, y-1},
        {x+1, y-1},
        {x+1, y},
        {x+1, y+1},
        {x, y+1},
        {x-1, y+1},
        {x-1, y}
    }

    for n, nv in ipairs(neibors) do
        local key = self:getKey(nv[1], nv[2]) 
        --对于城墙value+5

        --如果邻居点 是 终点则不用考虑 该点是否是Building 或者solid
        --(self.closedList[key] == nil and self.cells[key]['state'] ~= 'SOLID' and self.cells[key]['state'] ~= 'Building')  then
        --and nv[1] == self.endPoint[1] and nv[2] == self.endPoint[2]
        if self.closedList[key] == nil and self.cells[key]['state'] ~= 'Solid'  then  
            -- 检测是否已经在 openList 里面了
            local nS = self.cells[key]['fScore']
            local inOpen = false
            if nS ~= nil then
                local newPossible = self.pqDict[nS]
                if newPossible ~= nil then
                    for k, v in ipairs(newPossible) do
                        if v == key then
                            inOpen = true
                            break
                        end
                    end
                end
            end
            -- 已经在开放列表里面 检查是否更新
            if inOpen then
                local oldParent = self.cells[key]['parent']
                local oldGScore = self.cells[key]['gScore']
                local oldHScore = self.cells[key]['hScore']
                local oldFScore = self.cells[key]['fScore']

                self.cells[key]['parent'] = self:getKey(x, y)
                self:calcG(nv[1], nv[2])

                -- 新路径比原路径花费高 gScore  
                if self.cells[key]['gScore'] > oldGScore then
                    self.cells[key]['parent'] = oldParent
                    self.cells[key]['gScore'] = oldGScore
                    self.cells[key]['hScore'] = oldHScore
                    self.cells[key]['fScore'] = oldFScore
                else -- 删除旧的自己的优先级队列 重新压入优先级队列
                    self:calcH(nv[1], nv[2], x, y)
                    self:calcF(nv[1], nv[2])

                    local oldPossible = self.pqDict[oldFScore]
                    for k, v in ipairs(oldPossible) do
                        if v == key then
                            table.remove(oldPossible, k)
                            break
                        end
                    end
                    self:pushQueue(nv[1], nv[2])
                end
                    
            else --不在开放列表中 直接插入
                self.cells[key]['parent'] = self:getKey(x, y)
                self:calcG(nv[1], nv[2])
                self:calcH(nv[1], nv[2], x, y)
                self:calcF(nv[1], nv[2])

                self:pushQueue(nv[1], nv[2])
            end
        end
    end
    self.closedList[self:getKey(x, y)] = true
    --self:showGrid()
end
function World:getXY(pos)
    return math.floor(pos/self.coff), pos%self.coff
end


function World:search()
    self.searchNum = self.searchNum + 1
    if self.searchNum >= self.maxSearchNum then
        self.searchYet = true
    end

    self.openList = {}
    self.pqDict = {}
    self.closedList = {}

	local tempStart = {}
	if self.startPoint[1]<1 then
		tempStart[1] = 1
	elseif self.startPoint[1]>self.cellNum then
		tempStart[1] = self.cellNum
	end
	if self.startPoint[2]<1 then
		tempStart[2] = 1
	elseif self.startPoint[2]>self.cellNum then
		tempStart[2] = self.cellNum
	end
	if tempStart[1] then
		self.startPoint[1], tempStart[1] = tempStart[1], self.startPoint[1]
	end
	if tempStart[2] then
		self.startPoint[2], tempStart[2] = tempStart[2], self.startPoint[2]
	end

    self.cells[self:getKey(self.startPoint[1], self.startPoint[2])]['gScore'] = 0
    self:calcH(self.startPoint[1], self.startPoint[2])
    self:calcF(self.startPoint[1], self.startPoint[2])
    self:pushQueue(self.startPoint[1], self.startPoint[2])

    local startData = self.cells[self:getKey(self.startPoint[1], self.startPoint[2])]
    local endData = self.cells[self:getKey(self.endPoint[1], self.endPoint[2])]
    --print("start search " .. self.startPoint[1] .. " " .. self.startPoint[2] .." "..self.endPoint[1].." "..self.endPoint[2])
    --[[
    if startData['state'] == nil then
        print("startState nil")
    else
        print("startState"..startData['state'])
    end
    if endData['state'] == nil then
        print('endState nil')
    else
        print("endState "..endData['state'])
    end
    ]]--

    --获取openList 中第一个fScore
    while #(self.openList) > 0 do

        local fScore = heapq.heappop(self.openList)
        --print("listLen", #self.openList, fScore)
        local possible = self.pqDict[fScore]
        if #(possible) > 0 then
            local point = table.remove(possible) --这里可以加入随机性 在多个可能的点中选择一个点 用于改善路径的效果 
            local x, y = self:getXY(point)
            if x == self.endPoint[1] and y == self.endPoint[2] then
                break
            end
            self:checkNeibor(x, y)
        end
    end

    --包含从start到end的所有点
    local path = {self.endPoint}
    local parent = self.cells[self:getKey(self.endPoint[1], self.endPoint[2])]['parent']
    --print("getPath", parent)
    while parent ~= nil do
        local x, y = self:getXY(parent)
        table.insert(path, {x, y})
        if x == self.startPoint[1] and y == self.startPoint[2] then
        	if tempStart[1] or tempStart[2] then
        		table.insert(self.path, {tempStart[1] or self.startPoint[1], tempStart[2] or self.startPoint[2]})
        	end
            break    
        else
            self.cells[parent]['isPath'] = true
            table.insert(self.path, {x, y})
        end
        parent = self.cells[parent]["parent"]
    end
    
    local temp = {}
    for i = #path, 1, -1 do
        table.insert(temp, path[i])
        --print(path[i][1], path[i][2])
    end
    
    return temp
end

function World:searchAttack(range, fx, fy)
    self.searchNum = self.searchNum + 1
    if self.searchNum >= self.maxSearchNum then
        self.searchYet = true
    end
    self.openList = {}
    self.pqDict = {}
    self.closedList = {}
    
	local tempStart = {}
	if self.startPoint[1]<1 then
		tempStart[1] = 1
	elseif self.startPoint[1]>self.cellNum then
		tempStart[1] = self.cellNum
	end
	if self.startPoint[2]<1 then
		tempStart[2] = 1
	elseif self.startPoint[2]>self.cellNum then
		tempStart[2] = self.cellNum
	end
	if tempStart[1] then
		self.startPoint[1], tempStart[1] = tempStart[1], self.startPoint[1]
	end
	if tempStart[2] then
		self.startPoint[2], tempStart[2] = tempStart[2], self.startPoint[2]
	end
    self.searchType = "attack"
    
    local bx, by = self.startPoint[1]+fx, self.startPoint[2]+fy
    local minDis = nil
    for _, cp in pairs(self.allBuilds) do
    	local dx, dy = cp[1]-bx, cp[2]-by
    	local dis = dx*dx + dy*dy
    	if not minDis or dis<minDis then
    		minDis = dis
    		self.endPoint = cp
    	end
    end

    self.cells[self:getKey(self.startPoint[1], self.startPoint[2])]['gScore'] = 0
    self:calcH(self.startPoint[1], self.startPoint[2])
    self:calcF(self.startPoint[1], self.startPoint[2])
    self:pushQueue(self.startPoint[1], self.startPoint[2])

    --获取openList 中第一个fScore
    local parent, lastPoint, target
    while #(self.openList) > 0 do

        local fScore = heapq.heappop(self.openList)
        --print("listLen", #self.openList, fScore)
        local possible = self.pqDict[fScore]
        if #(possible) > 0 then
            local point = table.remove(possible) --这里可以加入随机性 在多个可能的点中选择一个点 用于改善路径的效果 
            local x, y = self:getXY(point)
            local prevGrid = self.prevGrids[self:getKey(x, y)]
            if prevGrid and prevGrid[1][1]<=range then
            	prevGrid = prevGrid[1]
            	local fsize = prevGrid[3]
            	local dx, dy = math.abs(x-prevGrid[2][1])-fsize-1, math.abs(y-prevGrid[2][2])-fsize-1
	            if dx < 0 then
	            	lastPoint = {math.random(), range-dy}
	            elseif dy<0 then
	            	lastPoint = {range-dx, math.random()}
	            else
	            	local rx, ry = math.random(), math.random()
	            	local a, b, c = (ry*ry)/(rx*rx)+1, 2*(dx+dy*ry/rx), dx*dx+dy*dy-range*range
	            	local zx = (math.sqrt(b*b-4*a*c)-b)/2/a
	            	lastPoint = {zx, zx*ry/rx}
	            end
            	parent = self.cells[self:getKey(x, y)]['parent']
            	if x==self.startPoint[1] and y==self.startPoint[2] then
            		dx, dy = math.abs(bx-prevGrid[2][1])-fsize-1, math.abs(by-prevGrid[2][2])-fsize-1
            		if (dx<0 and dy<=range) or (dy<0 and dx<=range) or (dx>=0 and dy>=0 and dx*dx+dy*dy<=range*range) then
            			self.searchType = nil
            			self.endPoint = nil
            			return {}, prevGrid[4]
            		end
            	end
            	if x<prevGrid[2][1] then
            		lastPoint[1] = 1-lastPoint[1]
            	end
            	if y<prevGrid[2][2] then
            		lastPoint[2] = 1-lastPoint[2]
            	end
            	lastPoint = {x+lastPoint[1], y+lastPoint[2]}
            	target = prevGrid[4]
                break
            end
            self:checkNeibor(x, y)
        end
    end

    --包含从start到end的所有点
    local path = {}
    --local parent = self.cells[self:getKey(self.endPoint[1], self.endPoint[2])]['parent']
    --print("getPath", parent)
    while parent ~= nil do
        local x, y = self:getXY(parent)
        table.insert(path, {x, y})
        if x == self.startPoint[1] and y == self.startPoint[2] then
        
        	if tempStart[1] or tempStart[2] then
        		table.insert(self.path, {tempStart[1] or self.startPoint[1], tempStart[2] or self.startPoint[2]})
        	end
            break    
        else
            self.cells[parent]['isPath'] = true
            table.insert(self.path, {x, y})
        end
        parent = self.cells[parent]["parent"]
    end
    
    local temp = {}
    for i = #path, 1, -1 do
        table.insert(temp, path[i])
        --print(path[i][1], path[i][2])
    end
    self.endPoint = nil
    self.searchType = nil
    return temp, target, lastPoint
end

function World:printCell()
    print("cur Board")
    local d
    for j = 0, self.cellNum+1, 1 do 
        for i = 0, self.cellNum+1, 1 do
            d = self.cells[self:getKey(i, j)]
            if d['state'] == nil then
                d['state'] = 'None'
            end
            io.write(string.format("%4s ", d['state'])) 
        end
        print() 
        for i = 0, self.cellNum+1, 1 do
            d = self.cells[self:getKey(i, j)]
            if d['gScore'] == nil then
                d['gScore'] = 0
            end
            io.write(string.format("%4d ", d['gScore'])) 
        end
        print()
        for i = 0, self.cellNum+1, 1 do
            d = self.cells[self:getKey(i, j)]
            if d['hScore'] == nil then
                d['hScore'] = 0
            end
            io.write(string.format("%4d ", d['hScore'])) 
        end
        print()

        for i = 0, self.cellNum+1, 1 do
            d = self.cells[self:getKey(i, j)]
            if d['fScore'] == nil then
                d['fScore'] = 0
            end
            io.write(string.format("%4d ", d['fScore'])) 
        end
        print()

        for i = 0, self.cellNum+1, 1 do
            d = self.cells[self:getKey(i, j)]
            if d['parent'] == nil then
                io.write(string.format("%4s ", "Pare"))
            else
                io.write(string.format("%d,%d ", self:getXY(d['parent']))) 
            end
        end
        print()
    end
end
function World:clearWorld()
	local cell
    if self.startPoint ~= nil then
    	cell = self.cells[self:getKey(self.startPoint[1], self.startPoint[2])]
    	if cell then
	        cell['state'] = nil
	    end
    end
    if self.endPoint ~= nil then
        cell = self.cells[self:getKey(self.endPoint[1], self.endPoint[2])]
    	if cell then
	        cell['state'] = nil
	    end
    end
    --[[
    for k, v in ipairs(self.walls) do
        cell = self.cells[self:getKey(v[1], v[2])]
    	if cell then
	        cell['state'] = nil
	    end
    end
    ]]--

    for k, v in ipairs(self.path) do
        cell = self.cells[self:getKey(v[1], v[2])]
    	if cell then
	        cell['state'] = nil
	    end
    end
    self.startPoint = nil
    self.endPoint = nil
    --self.walls = {}
    self.path = {}
end


--[[Test Case
MAP = {
0, 0, 0, 0, 0, 0, 0,  
0, 0, 0, 1, 0, 0, 0,  
0, 2, 0, 1, 0, 3, 0,  
0, 0, 0, 1, 0, 0, 0,  
0, 0, 0, 0, 0, 0, 0,  
0, 0, 0, 0, 0, 0, 0,  
0, 0, 0, 0, 0, 0, 0,  
}

world = World.new(7)
world:initCell()
for k, v in ipairs(MAP) do
    if v == 1 then
        world:putWall((k-1)%world.cellNum+1, math.floor((k-1)/world.cellNum)+1)
    elseif v == 2 then
        world:putStart((k-1)%world.cellNum+1, math.floor((k-1)/world.cellNum)+1)
    elseif v == 3 then
        world:putEnd((k-1)%world.cellNum+1, math.floor((k-1)/world.cellNum)+1)
    end
end
world:search()
world:printCell()
]]--

