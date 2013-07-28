local Stick = {}

Stick = Class{function(self)
    self.maxSwingTime = 0.25
    self.maxCooldownTime = 0.125
    self.damage = 1
    self.state = self.idle
    self.image = Images.sword
end}

function Stick:type() return "Attack" end
function Stick:destroy()
    if self.dJoint then
        self.dJoint:destroy()
        self.dJoint = nil
    end
    if self.jRoint then
        self.rJoint:destroy()
        self.rJoint = nil
    end
    if self.fixture then
        self.fixture:destroy()
        self.fixture = nil
    end
    if self.body then
        self.body:destroy()
        self.body = nil
    end
    self.shape = nil
    self.state = nil
end

function Stick:idle(dt, player, current, prev)
    if self.swingSpeed ~= nil then
        self.state = self.swing
        self.swingTime = 0
        local playerX, playerY = player.body:getPosition()
        local offset = player.w * 2
        local angle = player.body:getAngle() - (math.pi / 4 * self.swingSpeed / math.abs(self.swingSpeed))
        local stickX = playerX + offset * math.cos(angle)
        local stickY = playerY + offset * math.sin(angle)
        self.body = Game.map("entities").collider:newBody(stickX, stickY, "dynamic")
        self.body:setAngle(angle)
        self.shape = love.physics.newRectangleShape(0, 0,
            player.hitRadius, 5)
        self.fixture = love.physics.newFixture(self.body, self.shape, 1)
        self.rJoint = love.physics.newRevoluteJoint(player.body, self.body,
            playerX, playerY, false)
        Game.map("entities").collider:register(self)
        return false
    else
        return true
    end
end

function Stick:swing(dt, player, current, prev)
    if self.swingSpeed == nil or self.swingTime > self.maxSwingTime then
        self.swingSpeed = nil
        self.state = self.cooldown
        self.cooldownTime = 0
        self.swingTime = nil
        Game.map("entities").collider:unregister(self)
        self:destroy()
        return true
    else
        self.swingTime = self.swingTime + dt
        self.body:setAngularVelocity((2*math.pi * self.swingSpeed))
        return false
    end
end

function Stick:cooldown(dt, player, current, prev)
    if self.cooldownTime > self.maxCooldownTime then
        self.state = self.idle
        self.cooldownTime = nil
    else
        self.cooldownTime = self.cooldownTime + dt
    end
    return true
end

function Stick:update(dt, player, current, prev)
    if not self.state then
        self.state = Stick.idle
    end

    if current.attackLeft then
        self.swingSpeed = -3
    elseif current.attackRight then
        self.swingSpeed = 3
    else
        self.swingSpeed = nil
    end

    return self:state(dt, player, current, prev)
end

function Stick:draw()
    if self.body and self.shape then
        local x, y = self.body:getPosition()
        local angle = self.body:getAngle()
        local scaleFactor = 0.15
        love.graphics.draw(self.image, x, y, angle, scaleFactor, scaleFactor,
            230, 65)
        love.graphics.polygon("line", self.body:getWorldPoints(
                                        self.shape:getPoints()))
    end
end

return Stick