local ATL = require("lib/atl").Loader
local Camera = require("lib/hump/camera")
local Gamestate = require("lib/hump/gamestate")
vector = require("lib/hump/vector")
Class = require("lib/hump/class")

Player   = require("src/player")
Stick    = require("src/weapon/stick")
Critter  = require("src/critter")
Collider = require("src/collider")
Tentacle = require("src/tentacle")
ATL.path = "tmx/"

Fonts = {}

local Game = {
    id = 0,
}
local GameOver = {}

local entityTypes = {
    Player   = Player,
    Critter  = Critter,
    Tentacle = Tentacle,
    Stick    = Stick,
}

function Game:init()
    -- Font from http://openfontlibrary.org/en/font/leo-arrow
    Fonts.normal = love.graphics.newFont("fonts/leo_arrow.ttf", 24);
    Fonts.large = love.graphics.newFont("fonts/leo_arrow.ttf", 36);

    -- Set up the map
    self.collider = Collider()
    self.map = ATL.load("map0.tmx")
    self.map.drawObjects = false
    self.entities = {}
    for i, obj in pairs(self.map("units").objects) do
        entityTypes[obj.type].fromTmx(obj, self)
    end
    assert(self.player)

    -- Set up the camera
    self.cam = Camera(love.graphics.getWidth() / 2, self.player.body:getY())
    self:updateCamera()
end

function Game:getId()
    self.id = self.id + 1
    return self.id
end

function Game:register(entity)
    entity.id = self:getId()
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
    for i=#self.entities, 1, -1 do
        local entity = self.entities[i]
        if entity.destroyed then
            print("Removing " .. tostring(entity))
            table.remove(self.entities, i)
        else
            local Entity = entityTypes[entity:type()]
            if Entity then
                Entity.update(entity, dt, self)
            end
        end
    end
    self.collider:update(dt)
    self:updateCamera()
    if self.player.destroyed then
        Gamestate.switch(GameOver)
    end
end

function Game:draw()
    self.cam:draw(function()
        self.map:draw()
        for i, entity in pairs(self.entities) do
            local Entity = entityTypes[entity:type()]
            if Entity then
                Entity.draw(entity)
            end
        end
    end)
end

function GameOver:draw()
    local r, g, b, a = love.graphics.getColor()
    love.graphics.setColor(255, 0, 0)
    Game:draw()
    local textWidth = 800
    local textX = (love.graphics.getWidth() / Game.cam.scale / 2) - 64
    local textY = love.graphics.getHeight() / Game.cam.scale / 2

    love.graphics.setColor(255, 255, 255)
    love.graphics.setFont(Fonts.large)
    love.graphics.printf("Game Over.", textX, textY, textWidth, "left")
    love.graphics.setFont(Fonts.normal)
    love.graphics.printf("Press Enter to continue", textX, textY + 28,
                         textWidth, "left")
    love.graphics.setColor(r, g, b, a)
end

function GameOver:keyreleased(key, code)
    if key == 'return' then
        Game.player.destroyed = false
        Game.player.health = 3
        Game.player.body:setPosition(Game.playerStart.x, Game.playerStart.y)
        print("restarting")
        Gamestate.switch(Game)
    end
end

function love.load()
    Gamestate.registerEvents()
    Gamestate.switch(Game)
end
