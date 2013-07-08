local Move = Class{function(self)
end}

function Move:update(dt, player, current, prev)
    player.dir = player.body:getAngle()

    local vx = 0
    local vy = 0
    local speed

    -- Determine the move speed
    if current.sprinting then
        speed = player.baseSpeed * 3
    else
        speed = player.baseSpeed
    end

    -- Determine the move x direction
    if current.dx and math.abs(current.dx) > 0.1 then
        vx = current.dx * speed
    end

    -- Determine the move y direction
    if current.dy and math.abs(current.dy) > 0.1 then
        vy = current.dy * speed
    end

    if vx ~= 0 or vy ~= 0 then
        -- If moved, set the velocity vector
        player.body:setLinearVelocity(vx, vy)

        -- And the direction the player is facing
        local targetAngle
        if vx >= 0 then
            targetAngle = math.atan(vy / vx)
        else
            targetAngle = math.atan(vy / vx) + (math.pi)
        end
        local angleDiff = targetAngle - player.dir
        player.body:setAngle(targetAngle)
    else
        player.body:setLinearVelocity(0, 0)
    end

    return true
end

return Move
