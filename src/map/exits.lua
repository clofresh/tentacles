local Exits = {}

local Exit = Class{function(self, x, y, w, h, dest, ox, oy)
    self.x = x
    self.y = y
    self.w = w
    self.h = h
    self.dest = dest
    self.ox = ox
    self.oy = oy
end}

local update = function(self, dt)
    local player = self.map("entities").player
    local px, py = player.body:getWorldCenter()
    for i, exit in pairs(self.objects) do
        if  px > exit.x and px < exit.x + exit.w and
            py > exit.y and py < exit.y + exit.h then
            Gamestate.switch(MapTransition, exit)
       end
    end
end

function Exits.load(layer)
    layer.update = update
    local tileWidth = layer.map.tileWidth
    local tileHeight = layer.map.tileHeight
    layer:toCustomLayer(function(obj)
        return Exit(obj.x, obj.y, obj.width, obj.height, obj.properties.dest,
                    obj.properties.ox * tileWidth,
                    obj.properties.oy * tileHeight)
    end)

    return layer
end

return Exits