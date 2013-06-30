local ATL = require("lib/atl").Loader
local Entities = require("src/map/entities")
Lighting = require("src/map/lighting")

ATL.path = "tmx/"

local Map = {}

function Map.load(filename)
    local map = ATL.load(filename)
    map.drawObjects = false

    Lighting.load(map("lighting"))
    Entities.load(map("entities"))

    return map
end

return Map
