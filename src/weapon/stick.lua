local Stick = {}

Stick = Class{function(self)
    self.maxSwingTime = 0.25
    self.maxCooldownTime = 0.125
    self.damage = 1
    self.state = self.idle
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

function Stick.idle(stick, player, dt, game)
    if stick.swingSpeed ~= nil then
        stick.state = stick.swing
        stick.swingTime = 0
        local playerX, playerY = player.body:getPosition()
        local offset = player.w * 2
        local angle = player.body:getAngle() - (math.pi / 4 * stick.swingSpeed / math.abs(stick.swingSpeed))
        stickX = playerX + offset * math.cos(angle)
        stickY = playerY + offset * math.sin(angle)
        stick.body = game.collider:newBody(stickX, stickY, "dynamic")
        stick.shape = love.physics.newRectangleShape(0, 0,
            player.hitRadius, 5, angle)
        stick.fixture = love.physics.newFixture(stick.body, stick.shape, 1)
        stick.rJoint = love.physics.newRevoluteJoint(player.body, stick.body,
            playerX, playerY, false)
        game.collider:register(stick)
    end
end

function Stick.swing(stick, player, dt, game)
    if stick.swingSpeed == nil or stick.swingTime > stick.maxSwingTime then
        stick.swingSpeed = nil
        stick.state = stick.cooldown
        stick.cooldownTime = 0
        stick.swingTime = nil
        game.collider:unregister(stick)
        stick:destroy()
    else
        stick.swingTime = stick.swingTime + dt
        stick.body:setAngularVelocity((2*math.pi * stick.swingSpeed))
    end
end

function Stick.cooldown(stick, player, dt, game)
    if stick.cooldownTime > stick.maxCooldownTime then
        stick.state = stick.idle
        stick.cooldownTime = nil
    else
        stick.cooldownTime = stick.cooldownTime + dt
    end
end

function Stick:primaryAttack(speed)
    self.swingSpeed = speed
end

function Stick.update(stick, player, dt, game)
    if not stick.state then
        stick.state = Stick.idle
    end
    stick.state(stick, player, dt, game)
end

function Stick.draw(stick)
    if stick.body and stick.shape then
        love.graphics.polygon("line", stick.body:getWorldPoints(
                                        stick.shape:getPoints()))
    end
end

return Stick