local keyboard = {}

keyboard.update = function(game, dt)
    local changed = false
    if love.keyboard.isDown("w") then
        game.player.pos.y = game.player.pos.y - dt * game.player.speed
        changed = true
    elseif love.keyboard.isDown("s") then
        game.player.pos.y = game.player.pos.y + dt * game.player.speed
        changed = true
    end

    if love.keyboard.isDown("a") then
        game.player.pos.x = game.player.pos.x - dt * game.player.speed
        changed = true
    elseif love.keyboard.isDown("d") then
        game.player.pos.x = game.player.pos.x + dt * game.player.speed
        changed = true
    end
    return changed
end

return keyboard