local joystick = require("src/input/joystick")
local keyboard = require("src/input/keyboard")
local mouse    = require("src/input/mouse")
local Stick    = require("src/weapon/stick")

local Player = Class{function(self, pos, radius)
    self.pos = pos
    self.radius = radius
    self.inputs = {joystick, keyboard, mouse}
    self.weapon = Stick()
end}

function Player:type() return "Player" end

function Player.update(player, dt, game)
    for i, input in pairs(player.inputs) do
        input.update(player, dt, game)
    end
    if player.velocity then
        player.body:setLinearVelocity(player.velocity.x, player.velocity.y)
        player.velocity = nil
    else
        player.body:setLinearVelocity(0, 0)
    end
    player.weapon:update(player, dt, game)
end

function Player.draw(player)
    love.graphics.circle("fill", player.body:getX(), player.body:getY(),
        player.shape:getRadius())
    player.weapon:draw(player)
end

function Player.fromTmx(obj, game)
    local player = Player(vector(obj.x, obj.y), 32)
    player.speed = 128
    player.hitRadius = 60
    game.player = player
    local pos = player.pos
    player.body = game.collider:newBody(pos.x, pos.y, "dynamic")
    player.shape = love.physics.newCircleShape(player.radius)
    player.fixture = love.physics.newFixture(player.body, player.shape)
    game:register(player)
end

return Player
