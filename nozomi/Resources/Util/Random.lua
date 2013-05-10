Random = class()

function Random:ctor(seed)
    self.seed = seed
    self.a = 36001
    self.b = 23451
    self.m = 8724232
end

function Random:random()
    self.seed = (self.seed * self.a + self.b)%self.m
    return self.seed/self.m
end

function Random:randomInt(max)
    local v = self:random()
    return math.ceil(max*v)
end