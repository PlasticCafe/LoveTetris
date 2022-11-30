require "tetrists"
tetris.init()
love.keyboard.setKeyRepeat(true)
gridCanvas = love.graphics.newCanvas(love.graphics.getWidth(), love.graphics.getHeight())
love.graphics.setCanvas(gridCanvas)
love.graphics.clear()
tetris.drawGrid()
love.graphics.setCanvas()
lasttime = love.timer.getTime()
function love.draw()
    lasttime = love.timer.getTime()
    tetris.update()
    love.graphics.setBackgroundColor(255,255,255)
    love.graphics.draw(gridCanvas)
    --tetris.drawGrid()
    tetris.render()
end

function love.keypressed(key, scancode, isrepeat)
    tetris.updateInput(scancode)
end

