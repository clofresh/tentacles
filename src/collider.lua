local HC = require("lib/hardoncollider")

local Collider = Class{function(self)
    self.collidables = {}
    self.collider = HC(100, function(dt, shapeA, shapeB, dx, dy)
        local thing1 = self.collidables[shapeA]
        local thing2 = self.collidables[shapeB]
        if thing1 and thing1:canCollide(thing2) then
            thing1.pos = thing1.pos + vector(dx, dy)
        end
        if thing2 and thing2:canCollide(thing1) then
            thing2.pos = thing2.pos - vector(dx, dy)
        end
    end)
end}

function Collider:update(dt)
    self.collider:update(dt)
end

function Collider:register(thing)
    thing.hitShape = self.collider:addCircle(thing.pos.x, thing.pos.y, thing.radius)
    self.collidables[thing.hitShape] = thing
end

function Collider:unregister(thing)
    self.collider:remove(thing.hitShape)
    self.collidables[thing.hitShape] = nil
end

return Collider