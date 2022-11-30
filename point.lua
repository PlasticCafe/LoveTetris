Point = {}

function Point:new(x, y)
    o = {}
    setmetatable(o, self)
    self.__index = self
    self.__add = function(t1, t2) return Point:new(t1.x + t2.x, t1.y + t2.y) end
    self.__sub = function(t1, t2) return Point:new(t1.x - t2.x, t1.y - t2.y) end
    self = o
    self.x = x or 0
    self.y = y or 0
    return o
end
