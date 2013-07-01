local ATL = require("lib/atl").Loader
local Entities = require("src/map/entities")
local Exits = require("src/map/exits")
Lighting = require("src/map/lighting")

ATL.path = "tmx/"

local Map = {
    layerTypes = {
        lighting = Lighting,
        entities = Entities,
        exits = Exits,
    }
}

function Map.load(filename)
    print("Loading map: " .. filename)
    local map = ATL.load(filename)
    map.drawObjects = false

    for layerType, Layer in pairs(Map.layerTypes) do
        local layer = map(layerType)
        print("Loading "..layerType)
        Layer.load(layer)
    end

    return map
end

return Map
