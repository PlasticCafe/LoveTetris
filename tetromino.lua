require 'point'
Tetromino = {}

function Tetromino:new(block, movable, color) 
    o = {}
    setmetatable(o, self)
    self.__index = self
    self = o
    self.block = block
    self.color = color
    self.movable = movable
    self.deleted = false
    if(self.color == nil) then
        self.color = {math.random(255), math.random(255), math.random(255)}
    end  
    
    if self.block.obj == nil then
        self.block.obj = {}
        for i = 1, #self.block.pieces do
           -- local tobj =  spawnObject("BlockSquare", {self.block.pieces[i].x, tetris.conf.pieceHeight, self.block.pieces[i].y})
            --setScaleForGameObject(tobj, tetris.conf.bScale, tetris.conf.bScale, tetris.conf.bScale)
            --lockObject(tobj)
            --table.insert(self.block.obj, tobj)
        end
    end
    
    return self
end

function Tetromino:getPieces()
    return self.block.pieces
end

function Tetromino:rotate(dir)
    if dir ~= -1 and dir ~= 1 then 
        return 
    end
    
    local tdim = {}
    local dim = self.block.dim
    local center = self.block.center
    local shift = Point:new()
    local tblock = {}
    --rotate dimensions
    if dir == -1 then
        tdim = {xmin = dim.ymin - center.y + center.x, ymin = -1*(dim.xmax - center.x) + center.y, xmax = dim.ymax - center.y + center.x, ymax = -1*(dim.xmin - center.x) + center.y}
    elseif dir == 1 then
        tdim = {xmin = -1*(dim.ymax - center.y) + center.x, ymin = dim.xmin - center.x + center.y, xmax = -1*(dim.ymin - center.y) + center.x, ymax = dim.xmax - center.x + center.y}    
    end
    
    --calculate required wall kick
    if tdim.xmin < 1 then
        shift.x = 1 - tdim.xmin
    elseif tdim.xmax > tetris.conf.bWidth then
        shift.x = tetris.conf.bWidth - tdim.xmax
    end
    
    if tdim.ymin < 1 then
        shift.y = 1 - tdim.ymin
    end
    
    if tdim.ymin ~= dim.ymin then
        shift.y = -1*(tdim.ymin - dim.ymin)
    end
    
    tdim.xmin = tdim.xmin + shift.x
    tdim.xmax = tdim.xmax + shift.x
    tdim.ymin = tdim.ymin + shift.y
    tdim.ymax = tdim.ymax + shift.y
    
    for i=1, #self.block.pieces do
        local tpiece = Point:new()
        if dir == 1 then
            tpiece.x = -1*(self.block.pieces[i].y - center.y) + center.x + shift.x
            tpiece.y = self.block.pieces[i].x - center.x + center.y + shift.y
        elseif dir == -1 then
            tpiece.x = self.block.pieces[i].y - center.y + center.x + shift.x
            tpiece.y = -1*(self.block.pieces[i].x - center.x) + center.y + shift.y           
        end
        table.insert(tblock, tpiece)
    end
    
    if tetris.checkCollision(tblock, 0, 0) then
        return
    else
        center = center + shift
        self.block.pieces = tblock
        self.block.dim = tdim
    end
    
    return
end

function Tetromino:playerShift(amount)
    local nPos = self.block.center + amount
    
    if self.block.dim.xmax + amount.x > tetris.conf.bWidth or self.block.dim.xmin + amount.x < 1  or self.block.dim.ymin + amount.y < 1 then
        return
    end
    
    if tetris.checkCollision(self.block.pieces, amount.x, amount.y) == true then 
        return 
    end
    
    self:move(nPos, false)
    return
end

function Tetromino:gravityShift()
    if self.locked then 
        return 
    end
   
    self:move(self.block.center + Point:new(0, -1), false)
    return
end

function Tetromino:move(npoint, edge)
    local delta = npoint - self.block.center
    if edge == true then
        delta.y = delta.y + (self.block.center.y - self.block.dim.ymin) --Move such that the bottom edge is on the coordinate
    end
    
    for i=1, #self.block.pieces do
        self.block.pieces[i] = self.block.pieces[i] + delta
    end
    
    self.block.center = self.block.center + delta
    self.block.dim.xmax = self.block.dim.xmax + delta.x
    self.block.dim.xmin = self.block.dim.xmin + delta.x
    self.block.dim.ymax = self.block.dim.ymax + delta.y
    self.block.dim.ymin = self.block.dim.ymin + delta.y
    return
end

function Tetromino:getPieces()
    return self.block.pieces
end

function Tetromino:getRows()
    local rows = {}
    local rowList = {}
    
    for i = 1, #self.block.pieces do
        rows[self.block.pieces[i].y] = 1
    end
    
    for k, v in pairs(rows) do
        table.insert(rowList, k)
    end
    
    return rowList
end

function Tetromino:isAboveRow(row)
    for i = 1, #self.block.pieces do
        if self.block.pieces[i].y > row then return true end
    end
    
    return false
end

function Tetromino:split(row) --return a new object with leftover pieces
    local keep = {}
    local give = {}
    local erase = {}
    local objk = {}
    local objg = {}
    local obje = {}
    for i = 1, #self.block.pieces do
        if self.block.pieces[i].y > row then
            table.insert(give, self.block.pieces[i])
            table.insert(objg, self.block.obj[i])
        elseif self.block.pieces[i].y < row then
            table.insert(keep, self.block.pieces[i])
            table.insert(objk, self.block.obj[i])
        else
            table.insert(erase, self.block.pieces[i])
            table.insert(obje, self.block.obj[i])
        end
    end
    
    for i = 1, #obje do
        destroyObject(obje[i])
    end
    
    if next(keep) == nil and next(give) == nil then --no pieces left
        tetris.updateTable(self, true)
        self.deleted = true
        return nil
    elseif next(give) == nil then --no pieces split off
        tetris.updateTable(erase, true, true)
        self.block.pieces = keep
        self.block.obj = objk
        return self
    elseif next(keep) == nil then --kept none, reuse ourselves
        tetris.updateTable(erase, true, true)
        self.block.pieces = give
        self.block.obj = objg
        return self
    else                          --make a new object and return it
        local npiece = Tetromino:new({['pieces'] = give, ['dim'] = self.block.dim, ['center'] = self.block.center, ['obj'] = objg},true, self.color)    
        tetris.updateTable(erase, true, true)
        self.block.pieces = keep
        tetris.updateTable(npiece, false)
        return npiece  --wrong dim, center, not needed anyway
    end
end
        
function Tetromino:isDeleted()
    return self.deleted
end

function Tetromino:isMovable()
    return self.movable
end

function Tetromino:updateCollision()
    self.locked = tetris.checkCollision(self.block.pieces, 0, -1)
    return self.locked
end

function Tetromino:render() 
    for i = 1, #self.block.pieces do
        self.block.obj[i].setPositionSmooth(self.block.pieces[i].x, tetris.conf.pieceHeight, self.block.pieces[i].y)
    end
end