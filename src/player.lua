local joystick = require("src/input/joystick")
local keyboard = require("src/input/keyboard")
local mouse    = require("src/input/mouse")

-- Player abilities
local Blood    = require("src/abilities/blood")
local Debug    = require("src/abilities/debug")
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
    self.stats = PlayerStats(self)
    self.abilities = {
        debug = Debug(),
        weapon = Stick(),
        roll = Roll(),
        move = Move(),
        blood = Blood(),
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
    self.id = nil
end

function Player:update(dt, game)
    -- Collect and process any inputs
    local current = {}
    for i, input in pairs(self.inputs) do
        current = input.getInput(current)
    end

    -- Update abilities
    for i, ability in pairs(self.abilities) do
        local shouldContinue = ability:update(dt, self, current, self.prev)
        if not shouldContinue then
            break
        end
    end

    -- Save the current input as the next frame's prev input
    self.prev = current
end

function Player:draw()
    -- Draw the player image
    local x, y = self.body:getWorldCenter()
    local scaleFactor = 0.5
    love.graphics.draw(self.image, x, y, r, scaleFactor, scaleFactor, 69, 104)

    for i, ability in pairs(self.abilities) do
        if ability.draw then
            ability:draw(self)
        end
    end
end

function Player:applyDamage(attack, contact)
    if attack.damage then
        self.health = self.health - attack.damage
        if self.health <= 0 then
            self.destroyed = true
        end
        self.abilities.blood:trigger(contact)
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
    Map.register(map("lighting"), self.abilities.torch)
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
