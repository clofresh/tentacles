local joystick = require("src/input/joystick")
local keyboard = require("src/input/keyboard")
local mouse    = require("src/input/mouse")

local Player = Class{function(self, pos, radius)
    self.pos = pos
    self.radius = radius
    self.inputs = {joystick, keyboard, mouse}
end}

function Player:type() return "Player" end

function Player.update(player, dt, game)
    for i, input in pairs(player.inputs) do
        input.update(player, dt, game)
    end
end

function Player.draw(player)
    love.graphics.circle("fill", player.body:getX(), player.body:getY(),
        player.shape:getRadius())
    if player.attack then
        love.graphics.polygon("line", player.attack.body:getWorldPoints(
            player.attack.shape:getPoints()))
    end
end

function Player.fromTmx(obj, game)
    local player = Player(vector(obj.x, obj.y), 32)
    player.speed = 128
    player.hitRadius = 60
    game.player = player
    local pos = player.pos
    player.body = love.physics.newBody(game.world, pos.x, pos.y, "dynamic")
    player.shape = love.physics.newCircleShape(player.radius)
    player.fixture = love.physics.newFixture(player.body, player.shape)
    game:register(player)
end

return Player
