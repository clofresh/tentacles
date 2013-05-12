local joystick = require("src/input/joystick")
local keyboard = require("src/input/keyboard")
local mouse    = require("src/input/mouse")

local Player = Class{function(self, weapon)
    self.inputs = {joystick, keyboard, mouse}
    self.weapon = weapon
end}

function Player:type() return "Player" end

function Player.update(player, dt, game)
    player.dir = player.body:getAngle()
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
    love.graphics.polygon("fill", player.body:getWorldPoints(
                                        player.shape:getPoints()))
    player.weapon:draw(player)
end

function Player.fromTmx(obj, game)
    local weapon = Stick()
    weapon.id = game:getId()
    local player = Player(weapon)
    player.speed = 128
    player.hitRadius = 60
    player.w = 24
    player.h = 32
    player.dir = 0
    game.player = player
    player.body = game.collider:newBody(obj.x, obj.y, "dynamic")
    player.shape = love.physics.newPolygonShape(
        -player.w / 2, -player.h / 2,
        player.w / 2, -player.h / 2,
        player.w * .75, 0,
        player.w / 2, player.h / 2,
        -player.w / 2, player.h / 2
    )
    player.fixture = love.physics.newFixture(player.body, player.shape, 10)
    player.body:setAngularDamping(5)
    game:register(player)
end

return Player
