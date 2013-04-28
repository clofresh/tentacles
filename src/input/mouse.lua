local mouse = {}

mouse.update = function(dt, game)
    local changed = false
    local player = game.player
    local attack = player.attack
    if love.mouse.isDown("l") then
        local x, y = game.cam:mousepos()
        if not attack then
            local h = vector(x, y) - vector(player.body:getPosition())
            local angle
            if x < player.body:getX() then
                angle = math.acos(h.y / h:len())
            else
                angle = (2*math.pi) - math.acos(h.y / h:len())
            end

            attack = {
                body = love.physics.newBody(game.world, x, y, "dynamic"),
                shape = love.physics.newRectangleShape(0, 0, 5, player.hitRadius, angle),
                type = function() return "attack" end
            }
            attack.fixture = love.physics.newFixture(attack.body, attack.shape, 2)
            -- attack.fixture:setRestitution(0.9)
            attack.mouseJoint = love.physics.newMouseJoint(attack.body, x, y)
            attack.pivot = love.physics.newRevoluteJoint(attack.body,
                player.body, player.body:getX(), player.body:getY(), false)
            game.player.attack = attack
            game.collider:register(attack)
        else
            attack.mouseJoint:setTarget(x, y)
        end
    elseif attack then
        game.collider:unregister(attack)
        attack.body:destroy()
        player.attack = nil
    end
    return changed
end

return mouse