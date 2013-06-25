local dong = require("lib/dong/dong")
local joystick = {
    pressed = {}
}

joystick.update = function(player, dt, game)
    -- xbox controller movement input
    local joyNum = 1

    if dong.isDown(joyNum, "A") then
        player.weapon:primaryAttack(-3)
    elseif dong.isDown(joyNum, "X") then
        player.weapon:primaryAttack(3)
    else
        lsX, lsY = dong.ls(joyNum)

        if lsX and lsY then
            local dx = 0
            local dy = 0
            if math.abs(lsX) > 0.1 then
                dx = player.speed * lsX
            end
            if math.abs(lsY) > 0.1 then
                dy = player.speed * lsY
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
    end

    if dong.isDown(joyNum, "Y") then
        if not joystick.pressed.torch then
            player.torch.active = not player.torch.active
            joystick.pressed.torch = true
        end
    elseif joystick.pressed.torch then
        joystick.pressed.torch = nil
    end
end

return joystick