local keyboard = require("src/input/keyboard")
local joystick = require("src/input/joystick")

local Player = Class{function(self, pos, radius)
    self.pos = pos
    self.radius = radius
    self.inputs = {keyboard, joystick}
end}

function Player:update(dt, game)
    local changed = false
    for i, input in pairs(self.inputs) do
        changed = input.update(dt, game) or changed
    end
    return changed
end

function Player:draw()
    love.graphics.circle("fill", self.pos.x, self.pos.y, self.radius)
    if self.hitPos then
        love.graphics.circle("fill", self.pos.x + self.hitPos.x,
            self.pos.y + self.hitPos.y, self.hitRadius)
    end
end

function Player.fromTmx(obj, game)
    if obj.type == 'Player' then
        local player = Player(vector(obj.x, obj.y), 32)
        player.speed = 128
        player.hitRadius = 16
        game.player = player
    end
end

return Player
