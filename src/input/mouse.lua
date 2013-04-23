local mouse = {}

mouse.update = function(dt, game)
    local changed = false
    if love.mouse.isDown("l") then
        local x, y = love.mouse.getPosition()
        -- converts the mouse coordinates from viewport coordinates to absolute
        -- coordinates.
        local mousePos = vector(x,
            y + game.cam.y - (love.graphics.getHeight() / 2))
        local player = game.player
        if player.attack then
            game.collider:unregister(player.attack)
            player.attack = nil
        end
        local attackVec = mousePos - player.pos
        local maxAttackDist = player.radius + player.hitRadius 
        if attackVec:len() > maxAttackDist then
            attackVec = attackVec:normalized() * maxAttackDist
        end
        local attack = {
            pos = player.pos + attackVec,
            radius = player.hitRadius,
            canCollide = function() return false end,
        }
        game.collider:register(attack)
        player.attack = attack
    end
    return changed
end

return mouse