local HumpCam = require("lib/hump/camera")

local Camera = {}

local update = function(self, dt, x, y, map)
    local mapWidth = map.width * map.tileWidth
    local mapHeight = map.height * map.tileHeight
    self.x, self.y = Camera.computePos(x, y, mapWidth, mapHeight)

    -- Update the map's draw range
    local camWorldWidth = WIDTH / self.scale
    local camWorldHeight = HEIGHT / self.scale
    local camWorldX = self.x - (camWorldWidth / 2)
    local camWorldY = self.y - (camWorldHeight / 2)
    map:setDrawRange(camWorldX, camWorldY,camWorldWidth, camWorldHeight)

end

function Camera.init()
    local cam = HumpCam()
    cam.update = update
    return cam
end

function Camera.computePos(x, y, mapWidth, mapHeight, screenWidth,
                                                      screenHeight)
    local screenWidth = screenWidth or WIDTH
    local screenHeight = screenHeight or HEIGHT

    local outX, outY
    local screenCenterX = screenWidth / 2
    local screenCenterY = screenHeight / 2
    if mapWidth > screenWidth then
        outX = math.clamp(x, screenCenterX, mapWidth - screenCenterX)
    else
        outX = mapWidth / 2
    end

    if mapHeight > screenHeight then
        outY = math.clamp(y, screenCenterY, mapHeight - screenCenterY)
    else
        outY = mapHeight / 2
    end

    return outX, outY
end


return setmetatable(Camera, {
    __call = Camera.init
})
