local Stick = {}

Stick = Class{function(self)
    self.maxSwingTime = 0.25
    self.maxCooldownTime = 0.125
    self.damage = 1
    self.torque = 100000
    self.state = self.idle
end}

function Stick:type() return "Attack" end

function Stick.idle(stick, player, dt, game)
    if stick.shouldSwing then
        stick.state = stick.swing
        stick.swingTime = 0
        local playerX, playerY = player.body:getPosition()
        local offset = player.w * 2
        local angle = player.body:getAngle() - math.pi / 4
        stickX = playerX + offset * math.cos(angle)
        stickY = playerY + offset * math.sin(angle)
        stick.body = game.collider:newBody(stickX, stickY, "dynamic")
        stick.shape = love.physics.newRectangleShape(0, 0,
            player.hitRadius, 5, angle)
        stick.fixture = love.physics.newFixture(stick.body, stick.shape, 2)
        stick.dJoint = love.physics.newDistanceJoint(player.body, stick.body,
            playerX, playerY, stickX, stickY, false)
        stick.rJoint = love.physics.newRevoluteJoint(player.body, stick.body,
            playerX, playerY, false)
        game.collider:register(stick)
    end
end

function Stick.swing(stick, player, dt, game)
    if not stick.shouldSwing or stick.swingTime > stick.maxSwingTime then
        stick.state = stick.cooldown
        stick.cooldownTime = 0
        stick.swingTime = nil
        game.collider:unregister(stick)
        stick.dJoint:destroy()
        stick.rJoint:destroy()
        stick.fixture:destroy()
        stick.body:destroy()
        stick.fixture = nil
        stick.body = nil
        stick.shape = nil
    else
        stick.swingTime = stick.swingTime + dt
        stick.body:applyTorque(stick.torque)
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

function Stick:primaryAttack()
    self.shouldSwing = true
end

function Stick.update(stick, player, dt, game)
    stick.state(stick, player, dt, game)
    stick.shouldSwing = false
end

function Stick.draw(stick)
    if stick.body and stick.shape then
        love.graphics.polygon("line", stick.body:getWorldPoints(
                                        stick.shape:getPoints()))
    end
end

return Stick