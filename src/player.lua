local joystick = require("src/input/joystick")
local keyboard = require("src/input/keyboard")
local mouse    = require("src/input/mouse")

local Player = Class{function(self, weapon)
    self.inputs = {joystick, keyboard, mouse}
    self.weapon = weapon
    self.health = 10
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
end}

function Player:type() return "Player" end
function Player:destroy()
    self.weapon:destroy()
    self.weapon = nil
    self.fixture:destroy()
    self.fixture = nil
    self.body:destroy()
    self.body = nil
    self.shape = nil
    self.inputs = nil
end

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
    player.blood:update(dt)

    local x, y = player.body:getWorldCenter()
    player.torch.x = x + 40
    player.torch.y = y
    game.lighting:addLight(player.torch)
end

function Player.draw(player)
    love.graphics.polygon("fill", player.body:getWorldPoints(
                                        player.shape:getPoints()))
    local x, y = player.body:getWorldCenter()
    local scaleFactor = 0.5
    love.graphics.draw(Images.hero, x, y, r, scaleFactor, scaleFactor, 69, 104)
    player.weapon:draw(player)
    love.graphics.draw(player.blood)
end

function Player.applyDamage(player, attack)
    if attack.damage then
        player.health = player.health - attack.damage
        if player.health <= 0 then
            player.destroyed = true
        end
    end
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
    player.fixture = love.physics.newFixture(player.body, player.shape, 1)
    player.body:setAngularDamping(5)
    player.torch = game.lighting:newLight(obj.x, obj.y, 5, 5, false)
    game:register(player)
    game.playerStart = vector(obj.x, obj.y)
end

return Player
