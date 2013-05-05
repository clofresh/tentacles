local Collider = Class{function(self)
    self.entities = {}
    self.world = love.physics.newWorld()
    local me = self
    self.world:setCallbacks(function(...)
        me:beginContact(...)
    end)
end}

function Collider:update(dt)
    self.world:update(dt)
end

function Collider:newBody(...)
    return love.physics.newBody(self.world, ...)
end

function Collider:register(entity)
    assert(entity.id)
    local id = entity.id
    if entity.fixture then
        entity.fixture:setUserData(id)
    elseif entity.segments then
        for i, s in pairs(entity.segments) do
            s.fixture:setUserData(id)
        end
    else
        error("Can't register entity")
    end
    self.entities[id] = entity
end

function Collider:unregister(entity)
    local id
    if entity.fixture then
        id = entity.fixture:getUserData()
    elseif entity.segments then
        id = entity.segments[1].fixture:getUserData()
    else
        error("Can't unregister entity")
    end
    self.entities[id] = nil
end

function Collider:entityFromFixture(fixture)
    return self.entities[fixture:getUserData()]
end

function Collider:beginContact(a, b, contact)
    local entityA = self:entityFromFixture(a)
    local entityB = self:entityFromFixture(b)
    local aType = entityA:type()
    local bType = entityB:type()
    if aType == "Attack" and bType == "Critter" then
        local hit = vector(contact:getNormal())
        local toHit = b:getBody()
        local contactPosX, contactPosY = contact:getPositions()
        toHit:applyLinearImpulse(hit.x, hit.y, contactPosX, contactPosY)
    elseif aType == "Attack" and bType == "Tentacle" then
        Tentacle.applyDamage(entityB, entityA)
    elseif aType == "Tentacle" and bType == "Attack" then
        Tentacle.applyDamage(entityA, entityB)
    end
end

return Collider