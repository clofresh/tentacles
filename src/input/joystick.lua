local dong = require("lib/dong/dong")
local joystick = {}

joystick.update = function(dt, game)
    -- xbox controller movement input
    local player = game.player
    local changed = false
    local lsX, lsY = dong.ls(1)
    local rsX, rsY = dong.rs(1)

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
    if swingX ~= 0 or swingY ~= 0 then
        local attack = {
            pos = player.pos + (vector(swingX, swingY) *
                              (game.player.radius + game.player.hitRadius)),
            radius = game.player.hitRadius,
            canCollide = function() return false end,
        }
        attack.hitShape = game.collider:addCircle(attack.pos.x, attack.pos.y,
                                                  attack.radius)
        game.collidables[attack.hitShape] = attack
        player.attack = attack
    else
        if player.attack then
            game.collidables[player.attack.hitShape] = nil
            game.collider:remove(player.attack.hitShape)
            player.attack = nil
        end
    end

    return changed
end

return joystick