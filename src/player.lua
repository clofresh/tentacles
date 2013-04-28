local joystick = require("src/input/joystick")
local keyboard = require("src/input/keyboard")
local mouse    = require("src/input/mouse")

local Player = Class{function(self, pos, radius)
    self.pos = pos
    self.radius = radius
    self.inputs = {joystick, keyboard, mouse}
end}

function Player:canCollide(other)
    return false
end

function Player:update(dt, game)
    local changed = false
    for i, input in pairs(self.inputs) do
        changed = input.update(dt, game) or changed
    end
    return changed
end

function Player:draw()
    love.graphics.circle("fill", self.body:getX(), self.body:getY(), self.shape:getRadius())
    if self.attack then
        love.graphics.polygon("line", self.attack.body:getWorldPoints(self.attack.shape:getPoints()))
    end
end

function Player:type()
    return "player"
end

function Player.fromTmx(obj, game)
    if obj.type == 'Player' then
        local player = Player(vector(obj.x, obj.y), 32)
        player.speed = 128
        player.hitRadius = 60
        game.player = player
        local pos = player.pos
        player.body = love.physics.newBody(game.world, pos.x, pos.y, "dynamic")
        player.shape = love.physics.newCircleShape(player.radius)
        player.fixture = love.physics.newFixture(player.body, player.shape)
        game.collider:register(player)
    end
end

return Player
