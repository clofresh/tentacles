local Roll = Class{function(self)
    self:reset()
end}
Roll.maxAngle = math.pi / 2

function Roll:update(player, dt, current, prev)
    self.time = self.time + dt
    return self:state(player, dt, current, prev)
end

function Roll:idle(player, dt, current, prev)
    if current.dx or current.dy then
        local d = vector(current.dx or 0, current.dy or 0)
        if not self.inputDir then
            -- Initial direction
            self.inputDir = d
        elseif d.x ~= 0 or d.y ~= 0 then
            local angle = math.acos((d * self.inputDir) / (d:len() * self.inputDir:len()))
            if angle >= Roll.maxAngle then
                -- Changed direction too much, reset
                self:reset()
            end
        end
    elseif not (current.dx or current.dy) and self.inputDir then
        -- Pressed a direction, then let go
        self.state = self.netural
    end
    return true
end

function Roll:netural(player, dt, current, prev)
    if self.time <= 0.5 then
        local d = vector(current.dx or 0, current.dy or 0)
        if d.x ~= 0 or d.y ~= 0 then
            local angle = math.acos((d * self.inputDir) / (d:len() * self.inputDir:len()))
            if angle < Roll.maxAngle then
                -- Rollin'
                self.time = 0
                self.rollDir = d:normalized()
                self.state = self.rolling
            else
                -- Pressed a different direction than the initial one
                self:reset()
            end
        end
    else
        -- Timed out
        self:reset()
    end
    return true
end

function Roll:rolling(player, dt, current, prev)
    if self.time > 0.075 then
        self:reset()
        return true
    else
        local rollVel = self.rollDir * 1000
        player.body:setLinearVelocity(rollVel.x, rollVel.y)
        return false
    end
end

function Roll:reset()
    self.time = 0
    self.state = Roll.idle
    self.inputDir = nil
    self.rollDir = nil
end

return Roll