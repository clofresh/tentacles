local Critter = Class{function(self, step)
    self.step = step or 50
end}

function Critter:type() return "Critter" end
function Critter:__tostring()
    return string.format("%s[%s]", self:type(), self.id)
end
function Critter:destroy()
    self.fixture:destroy()
    self.fixture = nil
    self.body:destroy()
    self.body = nil
    self.shape = nil
end

function Critter.update(critter, dt, game)
    critter.body:setLinearVelocity(math.random(-critter.step, critter.step), math.random(-critter.step, critter.step))
end

function Critter.draw(critter)
    local x, y = critter.body:getWorldCenter()
    local scaleFactor = critter.shape:getRadius() / 64
    love.graphics.draw(Images.blob, x, y, r, scaleFactor, scaleFactor, 160, 90)
    -- love.graphics.circle("fill", critter.body:getX(),
    --     critter.body:getY(), critter.shape:getRadius())
end

function Critter.fromTmx(obj, game)
    local critter = Critter(obj.properties.step)
    critter.body = game.collider:newBody(obj.x, obj.y, "dynamic")
    critter.shape = love.physics.newCircleShape(obj.width / 2)
    critter.fixture = love.physics.newFixture(critter.body, critter.shape, 1)
    critter.fixture:setRestitution(0.7)
    game:register(critter)
end

return Critter