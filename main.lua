local ATL = require("lib/atl").Loader
local Camera = require("lib/hump/camera")
local Gamestate = require("lib/hump/gamestate")
local HC = require("lib/hardoncollider")
vector = require("lib/hump/vector")
Class = require("lib/hump/class")

local Player = require("src/player")
local Critter = require("src/critter")
ATL.path = "tmx/"

local Game = {}

function Game:init()
    local entities = {Player, Critter}
    self.collidables = {}

    self.collider = HC(100, function(dt, shapeA, shapeB, dx, dy)
        local thing1 = self.collidables[shapeA]
        local thing2 = self.collidables[shapeB]
        if thing1 and thing1:canCollide(thing2) then
            thing1.pos = thing1.pos + vector(dx, dy)
        end
        if thing2 and thing2:canCollide(thing1) then
            thing2.pos = thing2.pos - vector(dx, dy)
        end
    end)

    self.map = ATL.load("map0.tmx")
    self.map.drawObjects = false
    for i, obj in pairs(self.map("units").objects) do
        for j, loader in pairs(entities) do
            loader.fromTmx(obj, self)
        end
    end
    assert(self.player)
    assert(self.critters)
    self.cam = Camera(love.graphics.getWidth() / 2, self.player.pos.y)
    self:updateCamera()
end

function Game:updateCamera()
    self.cam.x = love.graphics.getWidth() / 2
    self.cam.y = self.player.pos.y
    local camWorldWidth = love.graphics.getWidth() / self.cam.scale
    local camWorldHeight = love.graphics.getHeight() / self.cam.scale
    local camWorldX = self.cam.x - (camWorldWidth / 2)
    local camWorldY = self.cam.y - (camWorldHeight / 2)
    self.map:setDrawRange(camWorldX, camWorldY,camWorldWidth, camWorldHeight)
end

function Game:update(dt)
    for i, critter in pairs(self.critters) do
        Critter.update(critter, dt)
    end
    local changed = self.player:update(dt, self)
    self.collider:update(dt)
    -- update camera
    if changed then
        self:updateCamera()
    end
end

function Game:draw()
    self.cam:draw(function()
        self.map:draw()
        self.player:draw()
        for i, critter in pairs(self.critters) do
            Critter.draw(critter)
        end
    end)
end

function love.load()
    Gamestate.registerEvents()
    Gamestate.switch(Game)
end
