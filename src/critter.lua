local Critter = Class{function(self, pos, radius)
    self.pos = pos
    self.radius = radius
    self.step = 50
end}

function Critter:canCollide(other)
    return true
end

function Critter.update(critter, dt, game)
    critter.pos = critter.pos 
        + vector(math.random(-critter.step, critter.step) * dt,
                 math.random(-critter.step, critter.step) * dt)

    critter.hitShape:moveTo(critter.pos.x, critter.pos.y)
end

function Critter.draw(critter)
    love.graphics.circle("fill", critter.pos.x, critter.pos.y, critter.radius)
end

function Critter.fromTmx(obj, game)
    if obj.type == 'Critter' then
        if not game.critters then
            game.critters = {}
        end
        local critter = Critter(vector(obj.x, obj.y), obj.width/2)
        table.insert(game.critters, critter)
        game.collider:register(critter)
    end
end

return Critter