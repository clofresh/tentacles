local ATL = require("lib/atl").Loader
local Camera = require("lib/hump/camera")
local Gamestate = require("lib/hump/gamestate")
vector = require("lib/hump/vector")
Class = require("lib/hump/class")

local Player = require("src/player")
ATL.path = "tmx/"

local Game = {}

function Game:init()
    self.map = ATL.load("map0.tmx")
    self.map.drawObjects = false
    local startPos
    for i, unit in pairs(self.map("units").objects) do
        if unit.type == 'Start' then
            startPos = vector(unit.x, unit.y)
            break
        end
    end
    assert(startPos)
    self.player = Player(startPos, 32)
    self.player.speed = 128
    self.player.hitRadius = 16
    self.cam = Camera(love.graphics.getWidth() / 2, self.player.pos.y)
end

function Game:update(dt)
    local changed = self.player:update(dt, self)

    -- update camera
    if changed then
        self.cam.x = love.graphics.getWidth() / 2
        self.cam.y = self.player.pos.y
        local camWorldWidth = love.graphics.getWidth() / self.cam.scale
        local camWorldHeight = love.graphics.getHeight() / self.cam.scale
        local camWorldX = self.cam.x - (camWorldWidth / 2)
        local camWorldY = self.cam.y - (camWorldHeight / 2)
        self.map:setDrawRange(camWorldX, camWorldY,camWorldWidth,
                              camWorldHeight)
    end
end

function Game:draw()
    self.cam:draw(function()
        self.map:draw()
        self.player:draw()
    end)
end

function love.load()
    Gamestate.registerEvents()
    Gamestate.switch(Game)
end
