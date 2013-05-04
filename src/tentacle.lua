local Tentacle = {}

Tentacle = Class{function(self, pos, w, h, range)
    self.pos = pos
    self.w = w or 16
    self.h = h or 128
    self.range = range or 100
    self.state = Tentacle.idle
end}

function Tentacle:type() return "Tentacle" end

function Tentacle:canCollide(other)
    return false
end

function Tentacle.idle(critter, dt, game)
    if critter.idleTime == nil then
        critter.idleTime = 0
    elseif critter.idleTime > 10 then
        critter.state = Tentacle.swing
        critter.idleTime = 0
        critter.swingTime = 0
        critter.swingMaxTime = 2
        print("Starting swing")
    else
        critter.idleTime = critter.idleTime + dt        
    end
end

function Tentacle.swing(critter, dt, game)
    if critter.swingTime > critter.swingMaxTime then
        critter.tentacle:setAngularVelocity(0)
        critter.state = Tentacle.idle
        critter.swingTime = nil
        critter.swingMaxTime = nil
        print("Ending swing")
    else
        critter.swingTime = critter.swingTime + dt
        critter.tentacle:setAngularVelocity((2*math.pi) * 3)
    end
end

function Tentacle.extend(critter, dt, game)
    local target = critter.target
    if not target then
        critter.state = Tentacle.shink
    end
    if critter.w < 100 then
        critter.w = critter.w + 1
    else
        critter.state = Tentacle.shrink
    end
end

function Tentacle.shrink(critter, dt, game)
    if critter.w >= 10 then
        critter.w = critter.w - 1
    else
        critter.state = Tentacle.idle
    end
end

function Tentacle.update(critter, dt, game)
    critter.state(critter, dt, game)
end

function Tentacle.draw(critter)
    love.graphics.polygon("fill",
        critter.tentacle:getWorldPoints(critter.shape:getPoints()))
end

function Tentacle.register(critter, game)
    local pos = critter.pos
    critter.tentacle = love.physics.newBody(game.world, pos.x, pos.y, "dynamic")
    critter.tentacle:setAngularDamping(5)
    critter.anchor = love.physics.newBody(game.world, pos.x, pos.y, "static")
    critter.pivot = love.physics.newRevoluteJoint(critter.tentacle,
        critter.anchor, pos.x, pos.y, false)
    critter.shape = love.physics.newRectangleShape(0, critter.h / 2, critter.w, critter.h)
    critter.fixture = love.physics.newFixture(critter.tentacle, critter.shape, 100)
    game.collider:register(critter)
    table.insert(game.critters, critter)
    print(string.format("Registered tentacle at (%s, %s)", pos.x, pos.y))
end

function Tentacle.fromTmx(obj, game)
    if obj.type == 'Tentacle' then
        if not game.critters then
            game.critters = {}
        end
        local critter = Tentacle(vector(obj.x, obj.y))
        Tentacle.register(critter, game)
    end
end

return Tentacle