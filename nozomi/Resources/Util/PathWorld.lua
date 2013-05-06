require "Util.Class"
require "Util.heapq"

PathWorld = class()

function PathWorld:ctor(min, max)
    self.coff = 10000
    self.allBuilds = {}
    self.prevGrids = {}
    self.typeNum = {}
    self.min = min
    self.max = max
    self.cells = {}
    self.hdata = {}
    self.walls = {}

    --当前帧 是否搜索名额已经满了
    self.searchYet = false
    --每帧最多的搜索士兵数量 根据具体性能设定
    self.maxSearchNum = 3
end

function PathWorld:getKey(x, y)
    return x*self.coff+y
end

local function compareDis(a, b)
	return a[1] < b[1]
end

function PathWorld:setBuild(x, y, size, btype, obj)
	local fsize = (size-1)/2
	local cp = {x+fsize, y+fsize}
	local bkey = self:getKey(x, y)
	self.typeNum[btype] = (self.typeNum[btype] or 0) + 1
	self.allBuilds[bkey] = cp
	for i=x-6, x+size+5 do
		if i>=self.min and i<self.max then
			for j=y-6, y+size+5 do
				if j>=self.min and j<self.max then
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
						self.cells[self:getKey(i, j)] = btype
					end
					if dis then
						local prevGrid = self.prevGrids[self:getKey(i, j)]
						if not prevGrid then
							prevGrid = {}
							self.prevGrids[self:getKey(i, j)] = prevGrid
						end
						table.insert(prevGrid, {dis, cp, fsize, obj, bkey})
						table.sort(prevGrid, compareDis)
					end
				end
			end
		end
	end
end

function PathWorld:clearBuild(x, y, size, btype, obj)
	local fsize = (size-1)/2
	local cp = {x+fsize, y+fsize}
	local bkey = self:getKey(x, y)
	self.allBuilds[bkey] = nil
	self.typeNum[btype] = self.typeNum[btype] - 1
	for i=x-6, x+size+5 do
		if i>=self.min and i<self.max then
			for j=y-6, y+size+5 do
				if j>=self.min and j<self.max then
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
									if prevGrid[i][5]==bkey then
										table.remove(prevGrid, i)
										break
									end
								end
							end
						end
					else
						self.cells[self:getKey(i, j)] = nil
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
    if difX > 0 and difY > 0 then
        dist = 10
    end
    data['gScore'] = self.cells[parent]['gScore']+dist
end

-- 获取启发式数值
function PathWorld:calcH(x, y, btype)
	local key = self:getKey(x, y)
    local data = self.cells[key]
		local dx, dy = math.abs(self.endPoint[1]-x), math.abs(self.endPoint[2]-y)
		local score = (dx+dy)*10
		data['hScore'] = score
	end
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
        if self.cells[key]['state'] ~= 'Wall' and self.closedList[key] == nil then
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
end
function World:getXY(pos)
    return math.floor(pos/self.coff), pos%self.coff
end


function World:search()
    self.openList = {}
    self.pqDict = {}
    self.closedList = {}

    self.cells[self:getKey(self.startPoint[1], self.startPoint[2])]['gScore'] = 0
    self:calcH(self.startPoint[1], self.startPoint[2])
    self:calcF(self.startPoint[1], self.startPoint[2])
    self:pushQueue(self.startPoint[1], self.startPoint[2])


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
            break    
        else
            self.cells[parent]['state'] = 'Path'
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
    self.openList = {}
    self.pqDict = {}
    self.closedList = {}
    
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
            break    
        else
            self.cells[parent]['state'] = 'Path'
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
    if self.startPoint ~= nil then
        self.cells[self:getKey(self.startPoint[1], self.startPoint[2])]['state'] = nil
    end
    if self.endPoint ~= nil then
        self.cells[self:getKey(self.endPoint[1], self.endPoint[2])]['state'] = nil
    end
    --[[
    for k, v in ipairs(self.walls) do
        self.cells[self:getKey(v[1], v[2])]['state'] = nil
    end
    ]]--

    for k, v in ipairs(self.path) do
        self.cells[self:getKey(v[1], v[2])]['state'] = nil
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

