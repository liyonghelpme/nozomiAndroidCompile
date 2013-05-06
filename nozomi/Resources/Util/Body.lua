require "Util.Ray"
Body = class()
function Body:ctor(world)
    self.world = world
end
-- 设定移动的开始位置和结束位置
function Body:setStartEnd(startPoint, endPoint)
    self.startPoint = startPoint
    self.endPoint = endPoint
    self.position = {self.startPoint[1]*self.world.cellSize+self.world.cellSize/2, self.startPoint[2]*self.world.cellSize+self.world.cellSize/2}
    self.speed = 100
end
-- 0 1 2 ray2 判断是否和网格相交 有wall的网格 如果不相交 则删除
-- 没有相交 j+1 继续判断 直到 没有path点了
-- 相交则 i = j  优化j 之后的路径
-- 3种情况
function Body:straighten()
    local i = 1
    local j = 3
    local tempPath = {self.path[1]}
    while j <= #self.path do
        local ray = Ray.new(self.path[i], self.path[j], self.world)
        local ret = ray:checkCollision()
        if not ret then
            j = j + 1
        else --该位置j发生碰撞 则前一个位置是可以到达的
            i = j-1
            j = i + 2
            table.insert(tempPath, self.path[i])
        end
    end
    table.insert(tempPath, self.path[#self.path])
    self.path = tempPath
end
-- 获取世界给的路径 进行拉直 设定实际的路径
function Body:setPath(path)
    self.path = path
    self:straighten() -- 调整路径直线化


    self.curGrid = 1
    self.nextGrid = nil
    self.velocity = {0, 0}
    self.totalTime = 0
    self.passTime = 0
    self.position = {self.path[1][1]*self.world.cellSize+self.world.cellSize/2, self.path[1][2]*self.world.cellSize+self.world.cellSize/2}
    if #path > 1 then
        self.nextGrid = 2

        self:calculateVelocity()
    end

end
-- 计算士兵的速度
function Body:calculateVelocity()
    local nextPos = self.path[self.nextGrid]
    nextPos = {nextPos[1]*self.world.cellSize+self.world.cellSize/2, nextPos[2]*self.world.cellSize+self.world.cellSize/2}
    self.tarPos = nextPos
    local curPos = self.position



    local vector = {nextPos[1]-curPos[1], nextPos[2]-curPos[2]}
    local length = math.sqrt(vector[1]*vector[1]+vector[2]*vector[2])


    self.velocity = {self.speed*vector[1]/length, self.speed*vector[2]/length}
    self.totalTime = length/self.speed
    self.passTime = 0

    print("calculateVelocity", curPos[1], curPos[2], nextPos[1], nextPos[2], vector[1], vector[2], length, self.totalTime)
    print("velocit")
end
-- 作为一个球体来绘制 并逐渐更新下一个位置
-- return true false 来表示是否移动到目的地
-- 怎么判断 牵引力 和 目标力？ 如何判定移动到了 目标位置？
function Body:doMove(delta)
    if self.nextGrid ~= nil then
        if self.passTime >= self.totalTime then
            self.curGrid = self.nextGrid
            self.nextGrid = self.curGrid + 1
            if self.nextGrid > #self.path then
                self.nextGrid = nil
            else
                self:calculateVelocity()             
            end
        elseif self.nextGrid ~= nil then
            self.position[1] = self.position[1] + self.velocity[1]*delta
            self.position[2] = self.position[2] + self.velocity[2]*delta
            self.passTime = self.passTime + delta        
        end
    end
end
function Body:draw()
    love.graphics.setColor(205, 204, 102)
    love.graphics.circle("fill", self.position[1], self.position[2], self.world.cellSize/3)

    if self.tarPos ~= nil then
        love.graphics.setColor(100, 0, 200)
        love.graphics.circle("fill", self.tarPos[1], self.tarPos[2], self.world.cellSize/3)
    end
    if self.velocity ~= nil then
        love.graphics.setColor(20, 200, 20)
        love.graphics.line(self.position[1], self.position[2], self.position[1]+self.velocity[1], self.position[2]+self.velocity[2])
    end
end
