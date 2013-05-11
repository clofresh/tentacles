local dong = require("lib/dong/dong")
local joystick = {}

joystick.update = function(player, dt, game)
    -- xbox controller movement input
    local lsX, lsY
    if love._os == "Windows" then
        lsX, lsY = dong.ls(1)
        rsY, rsX = dong.rs(1)
    else
        lsX, lsY = dong.ls(1)
        rsX, rsY = dong.rs(1)
    end

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

    -- xbox controller attack input
    if rsX and rsY then
        local swingX = 0
        local swingY = 0
        if math.abs(rsX) > 0.1 then
            swingX = rsX
        end
        if math.abs(rsY) > 0.1 then
            swingY = rsY
        end
        if swingX ~= 0 or swingY ~= 0 then
            local dir = vector(swingX, swingY):normalized() * player.hitRadius
            player.weapon:primaryAttack(dir, player, dt, game)
        end
    end
end

return joystick