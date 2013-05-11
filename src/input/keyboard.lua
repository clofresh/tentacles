local keyboard = {}

keyboard.update = function(player, dt)
    local dx = 0
    local dy = 0
    if love.keyboard.isDown("w") then
        dy = -player.speed
    elseif love.keyboard.isDown("s") then
        dy = player.speed
    end

    if love.keyboard.isDown("a") then
        dx = -player.speed
    elseif love.keyboard.isDown("d") then
        dx = player.speed
    end
    if dx ~= 0 or dy ~= 0 then
        player.velocity = vector(dx, dy)

        local targetAngle
        if dx >= 0 then
            targetAngle = math.atan(dy / dx)
        else
            targetAngle = math.atan(dy / dx) + (math.pi)
        end
        local angleDiff = targetAngle - player.dir
        if angleDiff ~= 0 then
            player.body:setAngle(targetAngle)
        end
    end
end

return keyboard