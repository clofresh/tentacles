local Camera = require("lib/hump/camera")
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

local Game = {}

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

    self.recorder = Recorder()
end

function Game:update(dt)
    -- if arg[#arg] == "-debug" then require("mobdebug").start() end

    -- Update the entities
    self.map("entities"):update(dt)

    -- Update the camera's position
    self.cam.x = love.graphics.getWidth() / 2
    self.cam.y = self.map("entities").player.body:getY()

    -- Update the map's draw range
    local camWorldWidth = love.graphics.getWidth() / self.cam.scale
    local camWorldHeight = love.graphics.getHeight() / self.cam.scale
    local camWorldX = self.cam.x - (camWorldWidth / 2)
    local camWorldY = self.cam.y - (camWorldHeight / 2)
    self.map:setDrawRange(camWorldX, camWorldY,camWorldWidth, camWorldHeight)

    -- Update the lighting
    self.map("lighting"):update(dt, self.cam)

    -- Update the recorder, if it's enabled
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

return Game