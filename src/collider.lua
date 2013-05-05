local Collider = {
    entities = {}
}

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
    Collider.entities[id] = entity
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
    Collider.entities[id] = nil
end

function Collider:entityFromFixture(fixture)
    return self.entities[fixture:getUserData()]
end

function Collider.beginContact(a, b, contact)
    local entityA = Collider:entityFromFixture(a)
    local entityB = Collider:entityFromFixture(b)
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