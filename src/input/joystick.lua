local dong = require("lib/dong/dong")
local joystick = {}

joystick.update = function(player, dt)
    -- xbox controller movement input
    local changed = false

    local lsX, lsY
    if love._os == "Windows" then
        lsX, lsY = dong.ls(1)
        rsY, rsX = dong.rs(1)
    else
        lsX, lsY = dong.ls(1)
        rsX, rsY = dong.rs(1)
    end

    if lsX and lsY then
        if math.abs(lsX) > 0.1 then
            player.pos.x = player.pos.x + dt * player.speed * lsX
            changed = true
        end

        if math.abs(lsY) > 0.1 then
            player.pos.y = player.pos.y + dt * player.speed * lsY
            changed = true
        end
    end

    -- xbox controller attack input
    local swingX = 0
    local swingY = 0
    if rsX and rsY then
        if math.abs(rsX) > 0.1 then
            swingX = rsX
        end
        if math.abs(rsY) > 0.1 then
            swingY = rsY
        end
    end

    return changed
end

return joystick