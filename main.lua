local ATL = require("lib/atl").Loader
local Camera = require("lib/hump/camera")
local Gamestate = require("lib/hump/gamestate")
vector = require("lib/hump/vector")
Class = require("lib/hump/class")

local Player = require("src/player")
local Critter = require("src/critter")
local Tentacle = require("src/tentacle")
ATL.path = "tmx/"

local Game = {}
local Collider = {
    id = 0,
    entities = {}
}

local entities = {
    Player   = Player,
    Critter  = Critter,
    Tentacle = Tentacle,
}

function Collider:register(entity)
    Collider.id = Collider.id + 1
    local id = Collider.id
    if entity.fixture then
        entity.fixture:setUserData(id)
    elseif entity.segments then
        for i, s in pairs(entity.segments) do
            s.fixture:setUserData(id)
        end
    else
        error("Can't register entity")
    end
    Collider.entities[id] = entity
end

function Collider:unregister(entity)
    local id
    if entity.fixture then
        id = entity.fixture:getUserData()
    elseif entity.segments then
        id = entity.segments[1].fixture:getUserData()
    else
        error("Can't unregister entity")
    end
    Collider.entities[id] = nil
end

function Collider:entityFromFixture(fixture)
    return self.entities[fixture:getUserData()]
end

function Collider.beginContact(a, b, contact)
    local entityA = Collider:entityFromFixture(a)
    local entityB = Collider:entityFromFixture(b)
    if entityA:type() == "Attack" and entityB:type() == "Critter" then
        local hit = vector(contact:getNormal())
        local toHit = b:getBody()
        local contactPosX, contactPosY = contact:getPositions()
        contact:setRestitution(20)
        toHit:applyLinearImpulse(hit.x, hit.y, contactPosX, contactPosY)
    end
end

function Game:init()
    self.collider = Collider
    self.world = love.physics.newWorld()
    self.world:setCallbacks(self.collider.beginContact)
    self.map = ATL.load("map0.tmx")
    self.map.drawObjects = false
    self.critters = {}
    for i, obj in pairs(self.map("units").objects) do
        for j, loader in pairs(entities) do
            loader.fromTmx(obj, self)
        end
    end
    assert(self.player)
    self.cam = Camera(love.graphics.getWidth() / 2, self.player.pos.y)
    self:updateCamera()
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
    for i, critter in pairs(self.critters) do
        entities[critter:type()].update(critter, dt)
    end
    local changed = self.player:update(dt, self)
    self.world:update(dt)
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
            entities[critter:type()].draw(critter)
        end
    end)
end

function love.load()
    Gamestate.registerEvents()
    Gamestate.switch(Game)
end
