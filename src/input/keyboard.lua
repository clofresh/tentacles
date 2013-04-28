local keyboard = {}

keyboard.update = function(dt, game)
    local changed = false
    local dx = 0
    local dy = 0
    if love.keyboard.isDown("w") then
        dy = -game.player.speed
        changed = true
    elseif love.keyboard.isDown("s") then
        dy = game.player.speed
        changed = true
    end

    if love.keyboard.isDown("a") then
        dx = -game.player.speed
        changed = true
    elseif love.keyboard.isDown("d") then
        dx = game.player.speed
        changed = true
    end
    game.player.body:setLinearVelocity(dx, dy)
    return changed
end

return keyboard