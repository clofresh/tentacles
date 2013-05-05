local ATL = require("lib/atl").Loader
local Camera = require("lib/hump/camera")
local Gamestate = require("lib/hump/gamestate")
vector = require("lib/hump/vector")
Class = require("lib/hump/class")

local Player = require("src/player")
local Critter = require("src/critter")
local Collider = require("src/collider")
Tentacle = require("src/tentacle")
ATL.path = "tmx/"

local Game = {}

local entityTypes = {
    Player   = Player,
    Critter  = Critter,
    Tentacle = Tentacle,
}

function Game:init()
    self.collider = Collider
    self.world = love.physics.newWorld()
    self.world:setCallbacks(self.collider.beginContact)
    self.map = ATL.load("map0.tmx")
    self.map.drawObjects = false
    self.entities = {}
    for i, obj in pairs(self.map("units").objects) do
        entityTypes[obj.type].fromTmx(obj, self)
    end
    assert(self.player)
    self.cam = Camera(love.graphics.getWidth() / 2, self.player.pos.y)
    self:updateCamera()
end

function Game:register(entity)
    self.collider:register(entity)
    table.insert(self.entities, entity)
    print(string.format("Registered %s", tostring(entity)))
end

function Game:updateCamera()
    self.cam.x = love.graphics.getWidth() / 2
    self.cam.y = self.player.body:getY()

    local camWorldWidth = love.graphics.getWidth() / self.cam.scale
    local camWorldHeight = love.graphics.getHeight() / self.cam.scale
    local camWorldX = self.cam.x - (camWorldWidth / 2)
    local camWorldY = self.cam.y - (camWorldHeight / 2)
    self.map:setDrawRange(camWorldX, camWorldY,camWorldWidth, camWorldHeight)
end

function Game:update(dt)
    for i, entity in pairs(self.entities) do
        entityTypes[entity:type()].update(entity, dt, self)
    end
    self.world:update(dt)
    self:updateCamera()
end

function Game:draw()
    self.cam:draw(function()
        self.map:draw()
        for i, entity in pairs(self.entities) do
            entityTypes[entity:type()].draw(entity)
        end
    end)
end

function love.load()
    Gamestate.registerEvents()
    Gamestate.switch(Game)
end
