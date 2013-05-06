--参考实现  http://dev.mothteeth.com/2011/11/2d-ray-casting-on-a-grid-in-as3/
--设定起始点 和 终点 判断两点之间是否存在墙体
--x y dx dy p0 p1 tar0 tar1 
--在网格地图上每个点沿着射线方向第一个交点必然和 最近的X或者 Y轴相交，只需要判断是和X 先相交 还是和Y 先相交 
Ray = class()
function Ray:ctor(a, b, world)
    self.a = a
    self.b = b
    self.world = world
end
--  返回相交的所有网格
function Ray:checkCollision()
    --保存该光线检测过的网格
    self.checkedGrid = {}
    local x, y = self.a[1], self.a[2] --当前的点所在网格
    local vector = {self.b[1]-self.a[1], self.b[2]-self.a[2]}--运动方向
    local dx = 0
    local dy = 0
    --根据运动方向计算下一个移动网格的偏移值
    if vector[1] > 0 then
        dx = 1
    elseif vector[1] < 0 then
        dx = -1
    end
    if vector[2] > 0 then
        dy = 1
    elseif vector[2] < 0 then
        dy = -1
    end

    --操作对象当前的位置
    local p0 = x*self.world.cellSize+self.world.cellSize/2
    local p1 = y*self.world.cellSize+self.world.cellSize/2

    --操作对象可能的下一个位置
    local tar0 = x
    if dx > 0 then
        tar0 = tar0 + dx
    end
    local tar1 = y
    if dy > 0 then
        tar1 = tar1 + dy
    end

    tar0 = tar0*self.world.cellSize
    tar1 = tar1*self.world.cellSize

    table.insert(self.checkedGrid, {x, y})
    self.count = 0


    while (x ~= self.b[1] or y ~= self.b[2]) and self.count < 2*(math.abs(vector[1])+math.abs(vector[2]))  do
        self.count = self.count + 1

        -- 小心速度 = 0 的情况
        local t0, t1
        if vector[1] ~= 0 then
            t0 = math.abs((tar0-p0)/vector[1])
        else
            t0 = 9999999
        end
        if vector[2] ~= 0 then
            t1 = math.abs((tar1-p1)/vector[2])
        else
            t1 = 9999999
        end

        
        --根据运动时间较小的得到最近的相邻网格
        -- Y 方向先相交
        if t0 > t1 then
            x = x
            y = y + dy
            p0 = p0+t1*vector[1]
            p1 = tar1
        else
            x = x + dx
            y = y
            p0 = tar0
            p1 = p1+t0*vector[2]
        end
        tar0 = x
        tar1 = y
        if dx > 0 then
            tar0 = tar0 + dx
        end
        if dy > 0 then
            tar1 = tar1 + dy
        end
        tar0 = tar0*self.world.cellSize
        tar1 = tar1*self.world.cellSize

        table.insert(self.checkedGrid, {x, y})
        --增加新的建筑类型 需要增加新的障碍物判断
        --state == Wall Solid Building 
        if self.world.cells[self.world:getKey(x, y)]['state'] ~= nil then
            return true
        end
    end
    return false
end



