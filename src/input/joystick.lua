local dong = require("lib/dong/dong")
local joystick = {}

joystick.update = function(game, dt)
    -- xbox controller movement input
    local changed = false
    local lsX, lsY = dong.ls(1)
    local rsX, rsY = dong.rs(1)

    if lsX and lsY then
        if math.abs(lsX) > 0.1 then
            game.player.pos.x = game.player.pos.x
                                + dt * game.player.speed * lsX
            changed = true
        end

        if math.abs(lsY) > 0.1 then
            game.player.pos.y = game.player.pos.y
                                + dt * game.player.speed * lsY
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
    if swingX ~= 0 or swingY ~= 0 then
        game.player.hitPos = vector(swingX, swingY) *
                                (game.player.w + game.player.hitRadius)
    else
        game.player.hitPos = nil
    end

    return changed
end

return joystick