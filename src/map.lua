local ATL = require("lib/atl").Loader
local Entities = require("src/map/entities")
local Zones = require("src/map/zones")
Lighting = require("src/map/lighting")

ATL.path = "tmx/"

local Map = {
    layerTypes = {
        lighting = Lighting,
        entities = Entities,
        zones = Zones,
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
