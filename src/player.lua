local joystick = require("src/input/joystick")
local keyboard = require("src/input/keyboard")
local mouse    = require("src/input/mouse")

-- Player abilities
local Move     = require("src/abilities/move")
local Roll     = require("src/abilities/roll")
local Stick    = require("src/abilities/stick")
local Torch    = require("src/abilities/torch")

local PlayerStats = Class{function(self, player)
    self.player = player
end}

function PlayerStats:update(dt)
    self.output = {}
    if self.player.health then
        table.insert(self.output, string.format("Health: %f", self.player.health))
    end
    if self.player.body then
        self.pos = vector(self.player.body:getWorldCenter())
        table.insert(self.output, string.format("Pos: %f, %f", self.pos.x, self.pos.y))
    end
end

function PlayerStats:draw(dirX, dirY)
    Hud.printLines(self.output, "small", dirX, dirY)
end


local Player = Class{function(self)
    self.inputs = {joystick, keyboard, mouse}
    self.health = 10
    self.image = Images.hero1
    self.blood = love.graphics.newParticleSystem(Images.blood, 100)
    self.blood:start()
    self.blood:setEmissionRate(100)
    self.blood:setSpeed(20, 100)
    self.blood:setGravity(100, 200)
    self.blood:setLifetime(0.125)
    self.blood:setParticleLife(0.25)
    self.blood:setDirection(180)
    self.blood:setSpread(20)
    self.blood:setSizes(0.5, 1, 1.5, 2)
    self.blood:setColors(255, 0, 0, 255, 55, 6, 5, 255)
    self.blood:stop()
    self.stats = PlayerStats(self)
    self.inputQueue = {}
    self.abilities = {
        weapon = Stick(),
        roll = Roll(),
        move = Move(),
    }
end}

function Player:type() return "Player" end
function Player:destroy()
    self.abilities.weapon:destroy()
    self.abilities.weapon = nil
    self.fixture:destroy()
    self.fixture = nil
    self.body:destroy()
    self.body = nil
    self.shape = nil
    self.inputs = nil
end

function Player:update(dt, game)
    self.dir = self.body:getAngle()

    -- Collect and process any inputs
    local events = {}
    for i, input in pairs(self.inputs) do
        events = input.getInput(events)
    end
    self:queueInput(dt, events)
    self:processInputQueue(dt)

    -- Update other stuff
    self.blood:update(dt)
end

function Player:queueInput(dt, events)
    table.insert(self.inputQueue, events)
end

function Player:processInputQueue(dt)

    -- Pop the last two set of events from the input queue
    local queueLen = #self.inputQueue
    local current = table.remove(self.inputQueue) or {}
    local prev = table.remove(self.inputQueue) or {}

    -- Toggle the hero image
    if current.toggleHero and not prev.toggleHero then
        if self.image == Images.hero1 then
            self.image = Images.hero2
        else
            self.image = Images.hero1
        end
    end

    -- Update abilities
    for i, ability in pairs(self.abilities) do
        local shouldContinue = ability:update(self, dt, current, prev)
        if not shouldContinue then
            break
        end
    end

    -- Requeue the current input, which will be the prev input next frame
    table.insert(self.inputQueue, current)

end

function Player:draw()
    love.graphics.polygon("fill", self.body:getWorldPoints(
                                        self.shape:getPoints()))
    local x, y = self.body:getWorldCenter()
    local scaleFactor = 0.5
    love.graphics.draw(self.image, x, y, r, scaleFactor, scaleFactor, 69, 104)
    self.abilities.weapon:draw(self)
    love.graphics.draw(self.blood)
end

function Player:applyDamage(attack)
    if attack.damage then
        self.health = self.health - attack.damage
        if self.health <= 0 then
            self.destroyed = true
        end
    end
end

function Player:resetPhysics(map, pos)
    local entities = map("entities")
    if not pos then
        pos = map("zones").lastCheckpoint
    end

    self.body = entities.collider:newBody(pos.x, pos.y, "dynamic")
    self.shape = love.physics.newPolygonShape(
        -self.w / 2, -self.h / 2,
        self.w / 2, -self.h / 2,
        self.w * .75, 0,
        self.w / 2, self.h / 2,
        -self.w / 2, self.h / 2
    )
    self.fixture = love.physics.newFixture(self.body, self.shape, 1)
    self.body:setAngularDamping(5)
    entities:registerPlayer(self)

    self.abilities.torch = Torch(pos.x, pos.y, 5, 5, false)
    map("lighting"):register(self.abilities.torch)
end

function Player.load(map, start)
    local player = Player()
    player.baseSpeed = 128
    player.sprinting = false
    player.hitRadius = 60
    player.w = 24
    player.h = 32
    player.dir = 0

    player:resetPhysics(map, start)
    Game.hud:set("topleft", player.stats)
    return player
end

return Player
