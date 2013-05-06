local Stick = {}

Stick = Class{function(self)
end}

function Stick:primaryAttack(dir, player, dt, game)
    local pos = dir + vector(player.body:getPosition())
    self.pos = pos
    if not self.attack then
        local angle
        if pos.x < player.body:getX() then
            angle = math.acos(dir.y / dir:len())
        else
            angle = (2*math.pi) - math.acos(dir.y / dir:len())
        end

        local attack = {
            body = game.collider:newBody(pos.x, pos.y, "dynamic"),
            shape = love.physics.newRectangleShape(0, 0, 5, player.hitRadius, angle),
            type = function() return "Attack" end,
            damage = 1,
            pos = pos,
        }
        attack.fixture = love.physics.newFixture(attack.body, attack.shape, 2)
        attack.mouseJoint = love.physics.newMouseJoint(attack.body, pos.x, pos.y)
        attack.pivot = love.physics.newRevoluteJoint(attack.body,
            player.body, player.body:getX(), player.body:getY(), false)
        player.attack = attack
        game:register(attack)
        self.attack = attack
    end
end

function Stick:stopAttack(player, dt, game)
    if self.attack then
        game.collider:unregister(self.attack)
        self.attack.mouseJoint:destroy()
        self.attack.pivot:destroy()
        self.attack.fixture:destroy()
        self.attack.body:destroy()
        self.attack = nil
    end
end

function Stick:update(player, dt, game)
    if self.attack then
        if self.pos then
            self.attack.mouseJoint:setTarget(self.pos.x, self.pos.y)
            self.pos = nil
        else
            self:stopAttack(player, dt, game)
        end
    end
end

function Stick:draw(player)
    if self.attack then
        love.graphics.polygon("line",
            self.attack.body:getWorldPoints(self.attack.shape:getPoints()))
    end
end

function Stick:idle()
end

function Stick:swing()
end

return Stick