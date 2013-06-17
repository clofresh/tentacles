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
Obstacle = require("src/obstacle")
Lighting = require("src/lighting")
ATL.path = "tmx/"

Fonts = {}
Images = {}

WIDTH  = love.graphics.getWidth()
HEIGHT = love.graphics.getHeight()

local Game = {
    id = 0,
}
local GameOver = {}

local entityTypes = {
    Player   = Player,
    Critter  = Critter,
    Tentacle = Tentacle,
    Stick    = Stick,
    Obstacle = Obstacle,
}

function Game:init()
    -- Font from http://openfontlibrary.org/en/font/leo-arrow
    Fonts.small = love.graphics.newFont("fonts/leo_arrow.ttf", 12);
    Fonts.normal = love.graphics.newFont("fonts/leo_arrow.ttf", 24);
    Fonts.large = love.graphics.newFont("fonts/leo_arrow.ttf", 36);

    -- Images
    Images.blood = love.graphics.newImage("img/blood.gif")
    Images.seg1  = love.graphics.newImage("img/tentacle4_seg1.png")
    Images.seg2  = love.graphics.newImage("img/tentacle4_seg2.png")
    Images.seg3  = love.graphics.newImage("img/tentacle4_seg3.png")
    Images.blob  = love.graphics.newImage("img/blob.png")
    Images.hero  = love.graphics.newImage("img/hero2.png")

    -- Set up the map
    self.map = self:loadMap("map0.tmx")

    -- Set up the camera
    self.cam = Camera(love.graphics.getWidth() / 2, self.player.body:getY())
    self:updateCamera()

    self.lighting = Lighting()
end

function Game:loadMap(map)
    map = ATL.load(map)
    map.drawObjects = false

    if self.collider then
        self.collider:destroy()
        self.collider = nil
    end
    self.collider = Collider()

    self.entities = {}
    local units = map("units")
    units:toCustomLayer(function(obj)
        entityTypes[obj.type].fromTmx(obj, self)
    end)
    local slf = self
    function units:draw()
        local x, y = slf.cam:cameraCoords(slf.player.body:getWorldCenter())
        slf.lighting:draw({x, HEIGHT - y})
        table.sort(slf.entities, function(entity1, entity2)
            local val1, val2
            if entity1.body then
                val1 = entity1.body:getY()
            else
                val1 = 0
            end
            if entity2.body then
                val2 = entity2.body:getY()
            else
                val2 = 0
            end
            return val1 < val2
        end)
        for i, entity in pairs(slf.entities) do
            local Entity = entityTypes[entity:type()]
            if Entity and Entity.draw then
                Entity.draw(entity)
            end
        end
    end
    assert(self.player)
    return map
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
    -- if arg[#arg] == "-debug" then require("mobdebug").start() end
    local numTentacles = 0
    for i=#self.entities, 1, -1 do
        local entity = self.entities[i]
        if entity.destroyed then
            print("Removing " .. tostring(entity))
            table.remove(self.entities, i)
        else
            local Entity = entityTypes[entity:type()]
            if Entity and Entity.update then
                Entity.update(entity, dt, self)
            end
            if entity:type() == "Tentacle" then
                numTentacles = numTentacles + 1
            end
        end
    end
    self.collider:update(dt)
    self:updateCamera()

    -- Check if we should change game state
    if self.player.destroyed then
        Gamestate.switch(GameOver, "died")
    elseif numTentacles == 0 then
        Gamestate.switch(GameOver, "won")
    end
end

function Game:draw()
    self.cam:draw(function()
        self.map:draw()
    end)

    love.graphics.setFont(Fonts.small)
    love.graphics.print(
        string.format("FPS: %d", love.timer.getFPS()),
        1, 12
    )

    love.graphics.print(
        string.format("Mem: %dKB", math.floor(collectgarbage("count"))),
        1, 24
    )
end

function Game:enter(prevState, status)
    if status == "restart" then
        self.map = self:loadMap("map0.tmx")
    end
end

function GameOver:enter(prevState, status)
    self.status = status
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
    if self.status == "won" then
        love.graphics.printf("You won!", textX, textY, textWidth, "left")
        love.graphics.setFont(Fonts.normal)
        love.graphics.printf("Press Enter to restart", textX, textY + 28,
                             textWidth, "left")
    else
        if self.status == "died" then
            love.graphics.printf("You died.", textX, textY, textWidth, "left")
        else
            love.graphics.printf("Game Over.", textX, textY, textWidth, "left")
        end
        love.graphics.setFont(Fonts.normal)
        love.graphics.printf("Press Enter to continue", textX, textY + 28,
                             textWidth, "left")
    end
    love.graphics.setColor(r, g, b, a)
end

function GameOver:reset()
    Game.player.destroyed = false
    Game.player.health = 3
    Game.player.body:setPosition(Game.playerStart.x, Game.playerStart.y)
    if self.status == "won" then
        print("Restarting")
        Gamestate.switch(Game, "restart")
    else
        print("Continuing")
        Gamestate.switch(Game)
    end
end

function GameOver:keyreleased(key, code)
    if key == 'return' then
        self:reset()
    end
end

function GameOver:joystickreleased(key, code)
    self:reset()
end

function love.load()
    Gamestate.registerEvents()
    Gamestate.switch(Game)
end
