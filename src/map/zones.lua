local Zones = {}

Zones.Exit = Class{function(self, name, x, y, w, h, properties, layer)
    self.name = name
    self.x = x
    self.y = y
    self.w = w
    self.h = h
    self.dest = properties.dest

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
        local px, py = player.body:getWorldCenter()
        for i, zone in pairs(self.objects) do
            if zone.dest
            and px > zone.x and px < zone.x + zone.w
            and py > zone.y and py < zone.y + zone.h then
                Gamestate.switch(MapTransition, zone)
           end
        end
    end
end

local get = function(self, name)
    return self.zones[name]
end

function Zones.load(layer)
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