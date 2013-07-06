Camera   = require("src/camera")
Player   = require("src/player")
Stick    = require("src/weapon/stick")
Critter  = require("src/critter")
Collider = require("src/collider")
Tentacle = require("src/tentacle")
Obstacle = require("src/obstacle")
Recorder = require("src/Recorder")
Map      = require("src/map")
Hud      = require("src/hud")

Images = {}
Music = {}

local Game = {}

function Game:init()

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
    self.recorder = Recorder()

    -- Set up the HUD
    self.hud = Hud()

    -- Start the music
    Music.main = love.audio.newSource("sound/lawyersinlove.mp3")
    love.audio.play(Music.main)
end

function Game:update(dt)
    -- if arg[#arg] == "-debug" then require("mobdebug").start() end

    -- Update the entities
    local entities = self.map("entities")
    entities:update(dt)

    -- Update the camera's position
    if entities.player then
        local x, y = entities.player.body:getWorldCenter()
        self.cam:update(dt, x, y, self.map)
    end

    -- Update the lighting
    self.map("lighting"):update(dt, self.cam)

    -- Update the recorder, if it's enabled
    self.recorder:update(dt)

    self.map("zones"):update(dt)
    self.hud:update(dt)

    -- Check if we should change game state
    if (entities.player or {}).destroyed then
        Gamestate.switch(GameOver, "died")
    elseif numTentacles == 0 then
        Gamestate.switch(GameOver, "won")
    end
end

function Game:draw()
    self.cam:draw(function()
        self.map:draw()
    end)

    self.hud:draw()
end

function Game:enter(prevState, status)
    if status == "restart" then
        self.map = Map.load("0-start.tmx")
        self.map("zones").lastCheckpoint = self.map("zones"):get("playerStart")
        Player.load(self.map)
    end
    print("entering game " ..tostring(self.map))
    local player = self.map("entities").player
    if player and self.map("zones"):inExit(player.body:getWorldCenter()) then
        player.canExit = false
    else
        player.canExit = true
    end
end

return Game