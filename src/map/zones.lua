local Zones = {
    defaultTransitionTime = 0.75
}

Zones.Exit = Class{function(self, name, x, y, w, h, properties, layer)
    self.name = name
    self.x = x
    self.y = y
    self.w = w
    self.h = h
    self.dest = properties.dest
    self.transitionTime = properties.transitionTime or Zones.defaultTransitionTime

    self.ox = properties.ox * layer.map.tileWidth
    self.oy = properties.oy * layer.map.tileHeight
end}

Zones.Zone = Class{function(self, name, x, y, w, h, _properties)
    self.name = name
    self.x = x
    self.y = y
    self.w = w
    self.h = h
end}

local update = function(self, dt)
    local player = self.map("entities").player
    if player then
        local exit = self:inExit(player.body:getWorldCenter())
        if exit and player.canExit then
            Gamestate.switch(MapTransition, exit)
        elseif not exit and not player.canExit then
            player.canExit = true
        end
    end
end

local inExit = function(self, x, y)
    for i, zone in pairs(self.objects) do
        if zone.dest
        and x > zone.x and x < zone.x + zone.w
        and y > zone.y and y < zone.y + zone.h then
            return zone
       end
    end
end

local get = function(self, name)
    return self.zones[name]
end

function Zones.load(layer)
    layer.inExit = inExit
    layer.update = update
    layer.get = get
    layer.zones = {}
    layer:toCustomLayer(function(obj)
        local ZoneType = Zones[obj.type]
        if ZoneType then
            local zone = ZoneType(obj.name,
                obj.x, obj.y, obj.width, obj.height, obj.properties, layer)
            if zone.name then
                assert(not layer.zones[zone.name])
                layer.zones[zone.name] = zone
            end
            return zone
        else
            return nil
        end
    end)

    return layer
end

return Zones