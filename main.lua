local ATL = require("lib/atl").Loader
local Camera = require("lib/hump/camera")
local Gamestate = require("lib/hump/gamestate")
vector = require("lib/hump/vector")

local keyboard = require("src/input/keyboard")
local joystick = require("src/input/joystick")
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
        w = 32,
        h = 32,
        speed = 128,
        hitRadius = 16,
        draw = function(self)
            love.graphics.circle("fill", self.pos.x, self.pos.y, self.w)
            if self.hitPos then
                love.graphics.circle("fill", self.pos.x + self.hitPos.x,
                    self.pos.y + self.hitPos.y, self.hitRadius)
            end
        end
    }
    self.cam = Camera(love.graphics.getWidth() / 2, self.player.pos.y)
    self.inputs = {keyboard, joystick}
end

function Game:update(dt)
    local changed = false
    for i, input in pairs(self.inputs) do
        changed = input.update(self, dt) or changed
    end

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
