ScreenObject = {}

function ScreenObject:new(width, height, posx, posy, scalex, scaley)
    o = {}
    setmetatable(o, self)
    self.__index = self
    self = o
    self.width = width
    self.height = height
    self.posx = posx
    self.posy = posy
    self.scalex = scalex
    self.scaley = scaley
    return o
end

function ScreenObject:getX(dX)
    return dX*self.scalex + self.posx
end

function ScreenObject:getY(dY)
    return dY*self.scaley + self.posy
end

function ScreenObject:centerX()
    local screenWidth = love.graphics.getWidth()
    self.posx = screenWidth/2 - self.width/2
end

function ScreenObject:centerY()
    local screenHeight = love.graphics.getHeight()
    self.posy = screenHeight/2 - self.height/2
end

function ScreenObject:center()
    self:centerX()
    self:centerY()
end

function ScreenObject:move(x, y)
    self.posx = x
    self.posy = y
end