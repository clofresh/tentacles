local Collider = Class{function(self)
    self.id = 0
    self.entities = {}
    self.world = love.physics.newWorld()
    local me = self
    self.world:setCallbacks(function(...)
        me:beginContact(...)
    end)
end}

function Collider:getId()
    self.id = self.id + 1
    return self.id
end

function Collider:update(dt)
    self.world:update(dt)
end

function Collider:newBody(...)
    return love.physics.newBody(self.world, ...)
end

function Collider:register(entity)
    if not entity.id then
        entity.id = self:getId()
    end
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

function Collider:destroy()
    for i=#self.entities, 1, -1 do
        local entity = self.entities[i]
        if entity and entity.destroy then
            entity:destroy()
        end
        table.remove(self.entities, i)
    end
    self.entities = nil
    self.world:setCallbacks(nil, nil, nil, nil)
    self.world:destroy()
    self.world = nil
end

function Collider:entityFromFixture(fixture)
    return self.entities[fixture:getUserData()]
end

function Collider:findInArea(x1, y1, x2, y2, shouldInclude)
    local results = {}
    local me = self
    local shouldInclude = shouldInclude or function(entity) return true end
    self.world:queryBoundingBox(x1, y1, x2, y2, function(fixture)
        local entity = me:entityFromFixture(fixture)
        if shouldInclude(entity) then
            table.insert(results, entity)
        end
        return true
    end)
    return results
end

local function applyForce(a, b, contact, order)
    local cx1, cy1, cx2, cy2 = contact:getPositions()
    local hit = vector(contact:getNormal()) * (vector(cx2, cy2):dist(vector(cx1, cy1)) * order)
    if order == -1 then
        a:getBody():applyForce(hit.x, hit.y)
    else
        b:getBody():applyForce(hit.x, hit.y)
    end
end

function Collider:beginContact(a, b, contact)
    local entityA = self:entityFromFixture(a)
    local entityB = self:entityFromFixture(b)
    local aType = entityA:type()
    local bType = entityB:type()

    if aType == "Attack" and bType == "Critter" then
        applyForce(a, b, contact, 1)
    elseif aType == "Critter" and bType == "Attack" then
        applyForce(a, b, contact, -1)
    elseif aType == "Attack" and bType == "Tentacle" then
        applyForce(a, b, contact, 1)
        Tentacle.applyDamage(entityB, entityA)
        entityB.blood:setPosition(contact:getPositions())
        entityB.blood:start()
    elseif aType == "Tentacle" and bType == "Attack" then
        applyForce(a, b, contact, -1)
        Tentacle.applyDamage(entityA, entityB)
        entityA.blood:setPosition(contact:getPositions())
        entityA.blood:start()
    elseif aType == "Tentacle" and bType == "Player" then
        applyForce(a, b, contact, 1)
        Player.applyDamage(entityB, entityA)
        entityB.blood:setPosition(contact:getPositions())
        entityB.blood:start()
    elseif aType == "Player" and bType == "Tentacle" then
        applyForce(a, b, contact, -1)
        Player.applyDamage(entityA, entityB)
        entityA.blood:setPosition(contact:getPositions())
        entityA.blood:start()
    end
end

return Collider