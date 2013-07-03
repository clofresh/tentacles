local Title = {}

function Title:draw()
    love.graphics.setColor(255, 255, 255)
    love.graphics.setFont(Fonts.large)
    local textWidth = 800
    local x = WIDTH / 3
    local y = HEIGHT / 3
    love.graphics.printf("Title of the game!", x, y, textWidth, "left")
    love.graphics.printf("Press Enter to start", x, y + 28,
                         textWidth, "left")    
end

function Title:keyreleased(key, code)
    if key == 'return' then
        Gamestate.switch(Game, "restart")
    end
end

return Title
