local GameOver = {}

function GameOver:enter(prevState, status)
    self.status = status
end

function GameOver:draw()
    local r, g, b, a = love.graphics.getColor()
    love.graphics.setColor(255, 0, 0)
    Game:draw()
    local textWidth = 800
    local textX = (love.graphics.getWidth() / Game.cam.scale / 2) - 64
    local textY = love.graphics.getHeight() / Game.cam.scale / 2

    love.graphics.setColor(255, 255, 255)
    love.graphics.setFont(Fonts.large)
    if self.status == "won" then
        love.graphics.printf("You won!", textX, textY, textWidth, "left")
        love.graphics.setFont(Fonts.normal)
        love.graphics.printf("Press Enter to restart", textX, textY + 28,
                             textWidth, "left")
    else
        if self.status == "died" then
            love.graphics.printf("You died.", textX, textY, textWidth, "left")
        else
            love.graphics.printf("Game Over.", textX, textY, textWidth, "left")
        end
        love.graphics.setFont(Fonts.normal)
        love.graphics.printf("Press Enter to continue", textX, textY + 28,
                             textWidth, "left")
    end
    love.graphics.setColor(r, g, b, a)
end

function GameOver:reset()
    local player = Game.map("entities").player
    player.destroyed = false
    player.health = 3
    if self.status == "won" then
        print("Restarting")
        Gamestate.switch(Game, "restart")
    else
        print("Continuing")
        local pos = Game.map("zones").lastCheckpoint
        player.body:setPosition(pos.x, pos.y)
        Gamestate.switch(Game)
    end
end

function GameOver:keyreleased(key, code)
    if key == 'return' then
        self:reset()
    end
end

function GameOver:joystickreleased(key, code)
    self:reset()
end

return GameOver