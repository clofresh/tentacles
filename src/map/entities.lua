local entityTypes = {
    Player   = Player,
    Critter  = Critter,
    Tentacle = Tentacle,
    Stick    = Stick,
    Obstacle = Obstacle,
}

local Entities = {}

local draw = function(self)
    table.sort(self.objects, function(entity1, entity2)
        local val1, val2
        if entity1.body then
            val1 = entity1.body:getY()
        else
            val1 = 0
        end
        if entity2.body then
            val2 = entity2.body:getY()
        else
            val2 = 0
        end
        return val1 < val2
    end)
    for i, entity in pairs(self.objects) do
        local Entity = entityTypes[entity:type()]
        if Entity and Entity.draw then
            Entity.draw(entity)
        end
    end
end

local update = function(self, dt)
    local numTentacles = 0
    for i=#self.objects, 1, -1 do
        local entity = self.objects[i]
        if entity.destroyed then
            print("Removing " .. tostring(entity))
            table.remove(self.objects, i)
        else
            local Entity = entityTypes[entity:type()]
            if Entity and Entity.update then
                Entity.update(entity, dt, self)
            end
            if entity:type() == "Tentacle" then
                numTentacles = numTentacles + 1
            end
        end
    end

    self.collider:update(dt)
end


function Entities.load(layer)
    layer.id = 0
    layer.update = update
    layer.draw = draw
    layer.collider = Collider()

    layer:toCustomLayer(function(obj)
        local entity = entityTypes[obj.type].fromTmx(obj, layer)
        print(string.format("Registered %s", tostring(entity)))
        return entity
    end)
    assert(layer.player)

    return layer
end

return Entities