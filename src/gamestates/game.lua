local Camera = require("lib/hump/camera")
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
end

function Game:update(dt)
    -- if arg[#arg] == "-debug" then require("mobdebug").start() end

    -- Update the entities
    local entities = self.map("entities")
    entities:update(dt)

    -- Update the camera's position
    if entities.player then
        local x, y = entities.player.body:getWorldCenter()
        self.cam.x = math.clamp(x, WIDTH / 2,
            self.map.width * self.map.tileWidth - WIDTH / 2)
        self.cam.y = math.clamp(y, HEIGHT / 2,
            self.map.height * self.map.tileHeight - HEIGHT / 2)

        -- Update the map's draw range
        local camWorldWidth = WIDTH / self.cam.scale
        local camWorldHeight = HEIGHT / self.cam.scale
        local camWorldX = self.cam.x - (camWorldWidth / 2)
        local camWorldY = self.cam.y - (camWorldHeight / 2)
        self.map:setDrawRange(camWorldX, camWorldY,camWorldWidth, camWorldHeight)
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
        self.map = Map.load("map0.tmx")
        local entities = self.map("entities")
        Player.load(entities, self.map("zones"):get("playerStart"))
    end
    print("entering game " ..tostring(self.map))
end

return Game