local Critter = Class{function(self, pos, radius)
    self.pos = pos
    self.radius = radius
    self.step = 50
end}

function Critter:canCollide(other)
    return true
end

function Critter:type()
    return "Critter"
end

function Critter.register(critter, game)
    local pos = critter.pos
    critter.body = love.physics.newBody(game.world, pos.x, pos.y, "dynamic")
    critter.shape = love.physics.newCircleShape(critter.radius)
    critter.fixture = love.physics.newFixture(critter.body, critter.shape, 0.1)
    critter.fixture:setRestitution(100)
    game.collider:register(critter)
    table.insert(game.critters, critter)
    print(string.format("Registered critter at (%s, %s)", pos.x, pos.y))
end

function Critter.update(critter, dt, game)
    critter.body:setLinearVelocity(math.random(-critter.step, critter.step), math.random(-critter.step, critter.step))
end

function Critter.draw(critter)
    love.graphics.circle("fill", critter.body:getX(),
        critter.body:getY(), critter.shape:getRadius())
end

function Critter.fromTmx(obj, game)
    if obj.type == 'Critter' then
        if not game.critters then
            game.critters = {}
        end
        local critter = Critter(vector(obj.x, obj.y), obj.width/2)
        Critter.register(critter, game)
    end
end

return Critter