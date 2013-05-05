local Tentacle = {}

Tentacle = Class{function(self, state)
    self.state = state or Tentacle.idle
end}
Tentacle.COLLISION_GROUP = -100

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
        for i, seg in pairs(critter.segments) do
            seg.body:setAngularVelocity(0)
        end
        critter.state = Tentacle.idle
        critter.swingTime = nil
        critter.swingMaxTime = nil
        print("Ending swing")
    else
        critter.swingTime = critter.swingTime + dt
        for i, seg in pairs(critter.segments) do
            seg.body:setAngularVelocity((2*math.pi) * 3)
        end
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
    for i, seg in pairs(critter.segments) do
        love.graphics.polygon("fill",
            seg.body:getWorldPoints(seg.shape:getPoints()))
    end
end

function Tentacle.fromTmx(obj, game)
    if obj.type ~= 'Tentacle' then
        return
    end
    if not game.critters then
        game.critters = {}
    end
    local t = Tentacle()
    local x, y = obj.x, obj.y
    local segments = {}
    local segment
    local lp = love.physics
    local numSegments = obj.properties.numSegments
    local length = obj.properties.length
    local density = obj.properties.density or 100
    local segmentLen = length / numSegments
    local segmentWidth = obj.properties.segmentWidth
    for i = 1, numSegments do
        segment = {
            body = lp.newBody(game.world, x, y, "dynamic"),
            shape = lp.newRectangleShape(i * segmentLen, 0, segmentLen,
                                         segmentWidth),
        } 
        segment.fixture = lp.newFixture(segment.body, segment.shape, density)
        segment.fixture:setGroupIndex(Tentacle.COLLISION_GROUP)
        table.insert(segments, segment)
    end
    t.anchor = lp.newBody(game.world, x, y, "static")
    segments[1].pivot = lp.newRevoluteJoint(t.anchor,
        segments[1].body, x, y, false)
    for i = 2, numSegments do
        local s = segments[i]
        local sPrev = segments[i - 1]
        s.pivot = lp.newRevoluteJoint(sPrev.body, s.body,
            x + segmentLen * (i - 1), y, false)
        s.pivot:setLimits(-math.pi/2, math.pi/2)
    end
    t.segments = segments
    game.collider:register(t)
    table.insert(game.critters, t)
    print(string.format("Registered tentacle at (%s, %s)", x, y))
end

return Tentacle