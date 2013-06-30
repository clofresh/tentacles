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
Recorder = require("src/Recorder")
Map      = require("src/map")

Fonts = {}
Images = {}

WIDTH  = love.graphics.getWidth()
HEIGHT = love.graphics.getHeight()

local Game = {}
local GameOver = {}

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
    Images.hero1  = love.graphics.newImage("img/hero1.png")
    Images.hero2  = love.graphics.newImage("img/hero2.png")

    -- Set up the camera
    self.cam = Camera()

    -- Set up the map
    self.map = Map.load("map0.tmx")
    self:updateCamera(0)

    self.recorder = Recorder()
end

function Game:updateCamera(dt)
    self.cam.x = love.graphics.getWidth() / 2
    self.cam.y = self.map("entities").player.body:getY()

    local camWorldWidth = love.graphics.getWidth() / self.cam.scale
    local camWorldHeight = love.graphics.getHeight() / self.cam.scale
    local camWorldX = self.cam.x - (camWorldWidth / 2)
    local camWorldY = self.cam.y - (camWorldHeight / 2)
    self.map:setDrawRange(camWorldX, camWorldY,camWorldWidth, camWorldHeight)

    self.map("lighting"):update(dt, self.cam)
end

function Game:update(dt)
    -- if arg[#arg] == "-debug" then require("mobdebug").start() end
    self.map("entities"):update(dt)
    self:updateCamera(dt)
    self.recorder:update(dt)

    -- Check if we should change game state
    if self.map("entities").player.destroyed then
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
        self.map = Map.load("map0.tmx")
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
    local player = Game.map("entities").player
    local playerStart = Game.map("entities").playerStart
    player.destroyed = false
    player.health = 3
    player.body:setPosition(playerStart.x, playerStart.y)
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
