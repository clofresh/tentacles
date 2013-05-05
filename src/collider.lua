local Collider = {
    id = 0,
    entities = {}
}

function Collider:register(entity)
    Collider.id = Collider.id + 1
    local id = Collider.id
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
    if entityA:type() == "Attack" and entityB:type() == "Critter" then
        local hit = vector(contact:getNormal())
        local toHit = b:getBody()
        local contactPosX, contactPosY = contact:getPositions()
        contact:setRestitution(20)
        toHit:applyLinearImpulse(hit.x, hit.y, contactPosX, contactPosY)
    end
end

return Collider