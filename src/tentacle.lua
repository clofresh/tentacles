local Tentacle = {}

Tentacle = Class{function(self, state)
    self.state = state or Tentacle.idle
end}
Tentacle.COLLISION_GROUP = -100

function Tentacle:type() return "Tentacle" end
function Tentacle:__tostring()
    return string.format("%s[%s]", self:type(), self.id)
end

function Tentacle.idle(tentacle, dt, game)
    if tentacle.idleTime == nil then
        tentacle.idleTime = 0
    end

    local x1, y1, x2, y2 = Tentacle.getRangeBox(tentacle)
    local nearby = game.collider:findInArea(x1, y1, x2, y2,
        function(entity)
            return entity:type() == "Player"
        end)

    if tentacle.idleTime > 10 or #nearby > 0 then
        tentacle.state = Tentacle.swing
        tentacle.idleTime = 0
        tentacle.swingTime = 0
        tentacle.swingMaxTime = 2
        print("Starting swing")
    else
        tentacle.idleTime = tentacle.idleTime + dt
    end
end

function Tentacle.getRangeBox(tentacle)
    local range = 0
    local x, y = tentacle.anchor:getWorldCenter()
    for i, segment in pairs(tentacle.segments) do
        range = range + segment.segmentLen
    end
    return x - range, y - range, x + range, y + range
end

function Tentacle.swing(tentacle, dt, game)
    if tentacle.swingTime > tentacle.swingMaxTime then
        for i, seg in pairs(tentacle.segments) do
            seg.body:setAngularVelocity(0)
        end
        tentacle.state = Tentacle.idle
        tentacle.swingTime = nil
        tentacle.swingMaxTime = nil
        print("Ending swing")
    else
        tentacle.swingTime = tentacle.swingTime + dt
        for i, seg in pairs(tentacle.segments) do
            seg.body:setAngularVelocity((2*math.pi) * 3)
        end
    end
end

function Tentacle.extend(tentacle, dt, game)
    local target = tentacle.target
    if not target then
        tentacle.state = Tentacle.shink
    end
    if tentacle.w < 100 then
        tentacle.w = tentacle.w + 1
    else
        tentacle.state = Tentacle.shrink
    end
end

function Tentacle.shrink(tentacle, dt, game)
    if tentacle.w >= 10 then
        tentacle.w = tentacle.w - 1
    else
        tentacle.state = Tentacle.idle
    end
end

function Tentacle.applyDamage(tentacle, attack)
    if #tentacle.segments > 0 then
        local segment = tentacle.segments[#tentacle.segments]
        segment.health = segment.health - attack.damage
        if segment.health <= 0 then
            segment.destroyed = true
        end
    end
end

function Tentacle.update(tentacle, dt, game)
    -- Iterate backwards through the segments so that if we remove one,
    -- we don't have to worry about the indexes shifting and skipping some
    for i=#tentacle.segments, 1, -1 do
        local segment = tentacle.segments[i]
        if segment.destroyed then
            print(string.format("%s: removing segment %d",
                tostring(tentacle), i))
            segment.pivot:destroy()
            segment.fixture:destroy()
            segment.body:destroy()
            table.remove(tentacle.segments, i)
        end
    end
    tentacle.destroyed = #tentacle.segments == 0
    if tentacle.destroyed then
        tentacle.anchor:destroy()
    else
        tentacle.state(tentacle, dt, game)
    end
end

function Tentacle.draw(tentacle)
    for i, seg in pairs(tentacle.segments) do
        love.graphics.polygon("fill",
            seg.body:getWorldPoints(seg.shape:getPoints()))
    end
end

function Tentacle.fromTmx(obj, game)
    -- Initialize the variables we'll be operating on
    local lp = love.physics
    local t = Tentacle()
    local x, y = obj.x, obj.y
    local numSegments = obj.properties.numSegments
    local length = obj.properties.length
    local density = obj.properties.density or 100
    local segmentWidth = obj.properties.segmentWidth
    local segmentLen = length / numSegments

    -- Generate the tentacle segments
    local segments = {}
    for i = 1, numSegments do
        local segment = {
            body = game.collider:newBody(x, y, "dynamic"),
            shape = lp.newRectangleShape(i * segmentLen, 0, segmentLen,
                                         segmentWidth),
            health = 10,
            segmentLen = segmentLen,
        } 
        segment.fixture = lp.newFixture(segment.body, segment.shape, density)
        segment.fixture:setGroupIndex(Tentacle.COLLISION_GROUP)
        table.insert(segments, segment)
    end

    -- Connect the tentacle segments with joints
    t.anchor = game.collider:newBody(x, y, "static")
    segments[1].pivot = lp.newRevoluteJoint(t.anchor,
        segments[1].body, x, y, false)
    for i = 2, numSegments do
        local s = segments[i]
        local sPrev = segments[i - 1]
        s.pivot = lp.newRevoluteJoint(sPrev.body, s.body,
            x + segmentLen * (i - 1), y, false)
        s.pivot:setLimits(-math.pi/2, math.pi/2)
    end

    -- Store everything in the proper place
    t.segments = segments
    game:register(t)
end



return Tentacle