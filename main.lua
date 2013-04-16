local ATL = require("lib/atl").Loader
local Camera = require("lib/hump/camera")
local Gamestate = require("lib/hump/gamestate")
local vector = require("lib/hump/vector")
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
    self.player = {
        pos = startPos,
        w = 64,
        h = 64,
        speed = 96,
        draw = function(self)
            love.graphics.rectangle("fill", self.pos.x, self.pos.y,
                                    self.w, self.h)
        end
    }
    self.cam = Camera(self.player.pos.x, self.player.pos.y)
end

function Game:update(dt)
    local changed = false
    if love.keyboard.isDown("w") then
        self.player.pos.y = self.player.pos.y - dt * self.player.speed
        changed = true
    elseif love.keyboard.isDown("s") then
        self.player.pos.y = self.player.pos.y + dt * self.player.speed
        changed = true
    end

    if love.keyboard.isDown("a") then
        self.player.pos.x = self.player.pos.x - dt * self.player.speed
        changed = true
    elseif love.keyboard.isDown("d") then
        self.player.pos.x = self.player.pos.x + dt * self.player.speed
        changed = true
    end

    if changed then
        self.cam.x, self.cam.y = self.player.pos.x, self.player.pos.y
    end

    local camWorldWidth = love.graphics.getWidth() / self.cam.scale
    local camWorldHeight = love.graphics.getHeight() / self.cam.scale
    local camWorldX = self.cam.x - (camWorldWidth / 2)
    local camWorldY = self.cam.y - (camWorldHeight / 2)
    self.map:setDrawRange(camWorldX, camWorldY, camWorldWidth, camWorldHeight)
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
