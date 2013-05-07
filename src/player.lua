local joystick = require("src/input/joystick")
local keyboard = require("src/input/keyboard")
local mouse    = require("src/input/mouse")
local Stick    = require("src/weapon/stick")

local Player = Class{function(self)
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
    local x1, y1, x2, y2, x3, y3, x4, y4 = player.shape:getPoints()
    local dir = player.dir
    x1, y1 = rotate(x1, y1, dir)
    x2, y2 = rotate(x2, y2, dir)
    x3, y3 = rotate(x3, y3, dir)
    x4, y4 = rotate(x4, y4, dir)
    love.graphics.polygon("fill", player.body:getWorldPoints(x1, y1,
        x2, y2, x3, y3, x4, y4))
    player.weapon:draw(player)
end

function rotate(x, y, r)
    return x * math.cos(r) - y * math.sin(r), x * math.sin(r) + y * math.cos(r)
end

function Player.fromTmx(obj, game)
    local player = Player()
    player.speed = 128
    player.hitRadius = 60
    player.w = 24
    player.h = 32
    player.dir = 0
    game.player = player
    player.body = game.collider:newBody(obj.x, obj.y, "dynamic")
    player.shape = love.physics.newRectangleShape(player.w, player.h)
    player.fixture = love.physics.newFixture(player.body, player.shape)
    player.body:setAngularDamping(5)
    game:register(player)
end

return Player
