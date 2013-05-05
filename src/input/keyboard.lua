local keyboard = {}

keyboard.update = function(player, dt)
    local changed = false
    local dx = 0
    local dy = 0
    if love.keyboard.isDown("w") then
        dy = -player.speed
        changed = true
    elseif love.keyboard.isDown("s") then
        dy = player.speed
        changed = true
    end

    if love.keyboard.isDown("a") then
        dx = -player.speed
        changed = true
    elseif love.keyboard.isDown("d") then
        dx = player.speed
        changed = true
    end
    player.body:setLinearVelocity(dx, dy)
    return changed
end

return keyboard