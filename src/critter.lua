local Critter = Class{function(self, step)
    self.step = step or 50
end}

function Critter:type() return "Critter" end
function Critter:__tostring()
    return string.format("%s[%s]", self:type(), self.id)
end

function Critter.update(critter, dt, game)
    critter.body:setLinearVelocity(math.random(-critter.step, critter.step), math.random(-critter.step, critter.step))
end

function Critter.draw(critter)
    love.graphics.circle("fill", critter.body:getX(),
        critter.body:getY(), critter.shape:getRadius())
end

function Critter.fromTmx(obj, game)
    local critter = Critter(obj.properties.step)
    critter.body = love.physics.newBody(game.world, obj.x, obj.y, "dynamic")
    critter.shape = love.physics.newCircleShape(obj.width / 2)
    critter.fixture = love.physics.newFixture(critter.body, critter.shape, 10)
    critter.fixture:setRestitution(0.7)
    game:register(critter)
end

return Critter