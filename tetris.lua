require 'screenobject'
require 'tetromino'
require 'point'
require 'levels'
require 'standardblocks'
tetris = {}


tetris.conf = {
    bHeight = 20,
    bWidth = 12,
    bScale = 20,
    pieceHeight = 4,
    levels = LevelList,    
    levelCount = #LevelList,
    standardBlocks = TetrisStandard,
    keys = {
        leftKey = "left", 
        rightKey = "right", 
        downKey = "down", 
        rotlKey = "j", 
        rotrKey = "k"
    }
}

tetris.state = {
    playerDir = 0, -- -1 = left, 1 = right, 2 = down, 0 = neutral
    playerRot = 0, -- -1 = 90deg, 1 = -90deg, 0 = neutral
    boardLut = {}, -- HxW lookup table for board {{{val=Tetromino}..{val=Tetromino}}..{{val=Tetromino}..{val=Tetromino}}}
    score = 0,
    highScore = 0,
    linesCleared = 0,
    level = 1,
    gameOver = false,
    started = false,
    nextBlock = nil,
    blockList = nil,
    activeBlock = false,
    gameObjectPool = {},
    blockList = {},
    lastTick = nil
}

tetris.UI = {

}

function tetris.init() 
    local cfg = tetris.conf
    math.randomseed(os.time())
    tetris.state.lastTick = love.timer.getTime()*1000
    tetris.state.board = ScreenObject:new(cfg.bWidth*cfg.bScale, cfg.bHeight*cfg.bScale, 0, 0, cfg.bScale, cfg.bScale)
    tetris.state.board:center()
    tetris.restart()
end


function tetris.restart()
    local cfg = tetris.conf
    
    if tetris.state.score > tetris.state.highScore then 
        tetris.state.highScore = tetris.state.score
    end
    
    tetris.state.score = 0
    tetris.state.linesCleared = 0
    tetris.state.level = 1
    tetris.generateLut()
    tetris.state.blockList = {}
    
    tblock = tetris.randomBlock(false)    
    tetris.state.activeBlock = Tetromino:new(tblock, true)
    tetris.state.activeBlock:move(Point:new(cfg.bWidth/2, cfg.bHeight + 1), true) 
    table.insert(tetris.state.blockList, tetris.state.activeBlock)   
    
    tblock = tetris.randomBlock(false)
    tetris.state.nextBlock = Tetromino:new(tblock, true)
    tetris.state.nextBlock:move(Point:new(cfg.bWidth + 10, cfg.bHeight))
    table.insert(tetris.state.blockList, tetris.state.nextBlock)
end    
    

function tetris.update()
    if tetris.state.activeBlock ~= false then
        if tetris.state.playerDir ~= 0 then
            if tetris.state.playerDir == -1 or tetris.state.playerDir == 1 then
                tetris.state.activeBlock:playerShift(Point:new(tetris.state.playerDir, 0))
            elseif tetris.state.playerDir == 2 then
                tetris.state.activeBlock:playerShift(Point:new(0, -1))
                lasttick = love.timer.getTime()*1000 --Reset down timer
            end
            
            tetris.state.playerDir = 0
        end
    
        if tetris.state.playerRot ~= 0 then
            tetris.state.activeBlock:rotate(tetris.state.playerRot)
            tetris.state.playerRot = 0
        end
        
        if (love.timer.getTime()*1000 - tetris.state.lastTick) > tetris.conf.levels[tetris.state.level].gameSpeed then
            tetris.tick()
            tetris.state.lastTick = love.timer.getTime()*1000
        end
    end
end

function tetris.tick()
    local cfg = tetris.conf
    local score = 0
    if tetris.state.activeBlock ~= false then
        if tetris.checkCollision(tetris.state.activeBlock:getPieces(), 0, -1) then --Active block has locked in place
            tetris.updateTable(tetris.state.activeBlock, false)        
            local erasedRows = tetris.updateRows(tetris.state.activeBlock:getRows()) --Erase rows and do gravity   
            tetris.state.activeBlock.locked = true
            if erasedRows > 0 then
                tetris.state.score = tetris.state.score + (erasedRows*erasedRows + 1)/0.002
                tetris.state.linesCleared = tetris.state.linesCleared + erasedRows
                tetris.state.level = math.floor(tetris.state.linesCleared/10) + 1
                if tetris.state.level > tetris.conf.levelCount then
                    tetris.state.level = tetris.conf.levelCount 
                end
            end
            
            for _, row in pairs(tetris.state.activeBlock:getRows()) do
                if row > tetris.conf.bHeight then
                    tetris.restart()
                    return
                end
            end
            
            tetris.state.activeBlock = tetris.state.nextBlock
            tetris.state.activeBlock:move(Point:new(cfg.bWidth/2, cfg.bHeight + 1), true)
            if(math.random(tetris.conf.levels[tetris.state.level].randomChance) == 1) then -- 1 in randomChance odds of getting a randomly made piece
                tetris.state.nextBlock = Tetromino:new(tetris.randomBlock(true, 6, 6, 6, 15), true) -- 666 for nightmare piece :gordon:
            else
                tetris.state.nextBlock = Tetromino:new(tetris.randomBlock(false))
            end

            tetris.state.nextBlock:move(Point:new(cfg.bWidth + 10, cfg.bHeight))
            table.insert(tetris.state.blockList, tetris.state.nextBlock)
        else        
            tetris.state.activeBlock:playerShift(Point:new(0, -1))
        end
    end
    --[[os.execute("cls")
    print("Current Score: " .. tetris.state.score)
    print("Lines Cleared: " .. tetris.state.linesCleared)
    print("Level: " .. tetris.state.level)--]]
 end
                    
            
function tetris.updateInput(key)
    if key == tetris.conf.keys.leftKey then
        tetris.state.playerDir = -1
    elseif key == tetris.conf.keys.rightKey then
        tetris.state.playerDir = 1
    elseif key == tetris.conf.keys.downKey then
        tetris.state.playerDir = 2
    elseif key == tetris.conf.keys.rotlKey then
        tetris.state.playerRot = -1
    elseif key == tetris.conf.keys.rotrKey then
        tetris.state.playerRot = 1
    end
    
    return
end

function tetris.render() 
    for i = 1, #tetris.state.blockList do
        local pieces = tetris.state.blockList[i].block.pieces
        local color = tetris.state.blockList[i].color      
        love.graphics.setColor(color[1], color[2], color[3])        
        for j = 1, #pieces do
            love.graphics.rectangle('fill', tetris.state.board:getX(pieces[j].x - 1), tetris.state.board:getY(tetris.conf.bHeight - pieces[j].y), tetris.conf.bScale, tetris.conf.bScale)
        end
    end
end

function tetris.renderTS()
    for i = 1, #tetris.state.blockList do
        tetris.state.blockList[i]:render()
    end
end

function tetris.randomBlock(generate, maxwidth, maxheight, maxsize, maxiter)
    local walktable = {}
    local block ={}
    local center ={}
    local tpiece = {}
    local priorPiece = nil
    local count = 0
    local dim = {xmax = nil, xmin = nil, ymax = nil, ymin = nil}
    
    if generate == false then --supply a random standard block
        local randBlock = tetris.conf.standardBlocks[math.random(#tetris.conf.standardBlocks)]
        local tblock = {}
        tblock.pieces = {}
        
        for i = 1, #randBlock.pieces do --Have to make a copy, else our block list is corrupted
            table.insert(tblock.pieces, Point:new(randBlock.pieces[i].x, randBlock.pieces[i].y))
        end
        
        tblock.center = Point:new(randBlock.center.x, randBlock.center.y)
        tblock.dim = {xmax = randBlock.dim.xmax, xmin = randBlock.dim.xmin, ymax = randBlock.dim.ymax, ymin = randBlock.dim.ymin}
        return tblock
    end
    
    priorPiece =  math.random(maxwidth*maxheight) --Start on random piece    
    if maxwidth < 1 or maxheight < 1 or (maxsize > maxwidth*maxheight)then
        return {} 
    end

    for index=1, maxheight*maxwidth do
        walktable[index] = false  --sparse table with stride maxwidth
    end
    
    walktable[priorPiece] = true
    tpiece = Point:new(priorPiece%maxwidth, math.ceil(priorPiece/maxwidth)) --Convert index to 2D coodinates (maxwidthXmaxheight)
    if (tpiece.x == 0) then --maxwidth%maxwidth = 0 so fix that
        tpiece.x = maxwidth 
    end 
    
    dim = {xmax = tpiece.x, xmin = tpiece.x, ymax = tpiece.y, ymin = tpiece.y}
    table.insert(block, tpiece) 
    count = count + 1
    for i = 1, maxiter  do
        local directions = {}      
        local newPiece = nil
        
        if(count >= maxsize) then
            break 
        end
        --Find directions open to walking
        if(priorPiece - maxwidth > 0) then
            table.insert(directions, priorPiece - maxwidth)
        end
        
        if(priorPiece + maxwidth < maxwidth*maxheight) then 
            table.insert(directions, priorPiece + maxwidth)
        end
        
        if(priorPiece % maxwidth ~= 0 ) then 
            table.insert(directions, priorPiece + 1)
        end
        
        if((priorPiece - 1) % maxwidth ~= 0 and priorPiece ~= 0) then 
            table.insert(directions, priorPiece - 1) 
        end
        
        if #directions == 0 then --No free directions, we're done
            break
        end
        
        newPiece = directions[math.random(#directions)]--Random direction if more than one     
        tpiece = Point:new(newPiece%maxwidth, math.ceil(newPiece/maxwidth))
        if (tpiece.x == 0) then tpiece.x = maxwidth end 
        
        if dim.xmax < tpiece.x then dim.xmax = tpiece.x end
        if dim.xmin > tpiece.x then dim.xmin = tpiece.x end
        if dim.ymax < tpiece.y then dim.ymax = tpiece.y end
        if dim.ymin > tpiece.y then dim.ymin = tpiece.y end 
        
        table.insert(block, tpiece)
        if(walktable[newPiece] == false) then
            count = count + 1 
            walktable[newPiece] = true                
        end
             
        priorPiece = newPiece
    end
    if(#block > 0) then
        center = Point:new(math.floor((dim.xmin+dim.xmax)/2), math.floor((dim.ymin+dim.ymax)/2)) --Calculate piece center
    end
    return {['pieces'] = block, ['center'] = center, ['dim'] = dim}
end

function tetris.generateLut() --Lua tables are sparce if mostly {} or nil. Pretty neat.
    tetris.state.boardLut = {}
    for i=1, tetris.conf.bHeight do
        tetris.state.boardLut[i] = {}    
        for j=1, tetris.conf.bWidth do
            tetris.state.boardLut[i][j] = nil
        end
    end
end

function tetris.checkCollision(pieces, offsetx, offsety)
    for i=1, #pieces do
        if pieces[i].y + offsety < 1 then --collision with bottom edge
            return true 
        end
        
        if pieces[i].y + offsety <= tetris.conf.bHeight and pieces[i].x + offsetx <= tetris.conf.bWidth then
            if tetris.state.boardLut[pieces[i].y + offsety][pieces[i].x + offsetx] ~= nil then --collision with another piece
                if tetris.state.boardLut[pieces[i].y + offsety][pieces[i].x + offsetx].locked == true then --don't collide with floating pieces
                    return true
                end
            end
        end
    end
    return false
end

function tetris.updateRows(rows) --erase full rows and run gravity
    print("Updating rows")
    local modified = 0 --erased row counter
    local lowRow = tetris.conf.bHeight --keep track of lowest modified row
    for i = 1, #rows do
        local full = true
        if rows[i] >= 1 and rows[i] <= tetris.conf.bHeight then
            for col = 1, tetris.conf.bWidth do
                if tetris.state.boardLut[rows[i]][col] == nil then
                    full = false
                    break
                end
            end
            
            if full then
                print("found full row")
                if rows[i] < lowRow then lowRow = rows[i] end             
                modified = modified + 1       
                for col = 1, tetris.conf.bWidth do
                    if tetris.state.boardLut[rows[i]][col] ~= nil then  --Once we start things could be nil 
                        local oblock = tetris.state.boardLut[rows[i]][col]
                        local nblock = oblock:split(rows[i]) --cutting a block in half give two blocks
                        if nblock ~= nil and oblock ~= nblock then --skip if the same block or totally erased
                            table.insert(tetris.state.blockList, nblock)
                        end
                    end
                end               
            end
        end
    end
    if modified > 0 then
        for i=#tetris.state.blockList,1,-1 do --prune blocks without pieces
            if tetris.state.blockList[i]:isDeleted() then
                table.remove(tetris.state.blockList, i)
            end
        end
        modified = modified + tetris.gravity(lowRow) --everything above this row will be checked for gravity
    end
    return modified
end
            
function tetris.updateTable(block, erase, raw) --write out the pieces in block to the lut
    local pieces = nil
    if raw == true then
        pieces = block
    else
        pieces = block:getPieces()
    end
    
    for i = 1, #pieces do
        if pieces[i].x >= 1 and pieces[i].x <= tetris.conf.bWidth and pieces[i].y >= 1 and pieces[i].y <= tetris.conf.bHeight then
            if erase then
                tetris.state.boardLut[pieces[i].y][pieces[i].x] = nil --erase instead of write
            else
                if raw ~= true then
                    tetris.state.boardLut[pieces[i].y][pieces[i].x] = block
                end
            end
        end
    end
    return
end
    
function tetris.gravity(row) --flood fill gravity
    local lowRow = tetris.conf.bHeight
    local highRow = 1
    local fallList = {}    
    local nrows = {} 
    
    if row < 1 or row >= tetris.conf.bHeight then return end   
    
    for i = 1, #tetris.state.blockList do --build list of foating blocks
        if tetris.state.blockList[i]:isAboveRow(row) then
            tetris.state.blockList[i].locked = false
            table.insert(fallList, tetris.state.blockList[i])
        end
    end
    
    while next(fallList) ~= nil do --don't quit until ther are no floating blocks
        local removed = 1
        while removed > 0 do --don't quit until no more pieces change into locked
            removed = 0
            for i = #fallList,1,-1 do
                if fallList[i]:updateCollision() then
                    for _, row in pairs(fallList[i]:getRows()) do
                        if row > highRow then highRow = row end
                        if row < lowRow then lowRow = row end
                    end               
                    table.remove(fallList, i)
                    removed = removed + 1
                end
            end
        end
        
        if next(fallList) == nil then break end
        
        for i = #fallList,1,-1 do --erase board states and shift one down
            tetris.updateTable(fallList[i], true) 
            fallList[i]:gravityShift() 
        end
        
        for i = #fallList,1,-1 do --restore board states after shifting all pieces, to avoid overwrites
            tetris.updateTable(fallList[i], false)
        end
    end

    print(lowRow .. " " .. highRow)
    for i = lowRow, highRow do
        table.insert(nrows, i)
    end
    
    return tetris.updateRows(nrows) --recursive call to support chaining
end    

function tetris.drawGrid()
    for h=0, tetris.conf.bHeight do
        for w=0, tetris.conf.bWidth do
            love.graphics.setColor(0, 0, 0)
            love.graphics.line(tetris.state.board:getX(w), tetris.state.board:getY(0), tetris.state.board:getX(w), tetris.state.board:getY(tetris.conf.bHeight))
            love.graphics.line(tetris.state.board:getX(0), tetris.state.board:getY(h), tetris.state.board:getX(tetris.conf.bWidth), tetris.state.board:getY(h))
        end
    end
end

function bakePiece()
    return spawnObject("BlockSquare", {200, 200, 200})
end