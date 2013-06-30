local lk = love.keyboard
local keyboard = {
    pressed = {}
}

keyboard.update = function(player, dt)
    if lk.isDown("j") then
        player.weapon:primaryAttack(-3)
    elseif lk.isDown("k") then
        player.weapon:primaryAttack(3)
    else        
        local dx = 0
        local dy = 0
        if lk.isDown("w") then
            dy = -player.speed
        elseif lk.isDown("s") then
            dy = player.speed
        end

        if lk.isDown("a") then
            dx = -player.speed
        elseif lk.isDown("d") then
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
            player.body:setAngle(targetAngle)
        end
    end

    if lk.isDown("t") then
        if not keyboard.pressed.torch then
            player.torch.active = not player.torch.active
            keyboard.pressed.torch = true
        end
    elseif keyboard.pressed.torch then
        keyboard.pressed.torch = nil
    end

    if lk.isDown("1") then
        player.image = Images.hero1
    elseif lk.isDown("2") then
        player.image = Images.hero2
    end
end

return keyboard