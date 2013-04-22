local Critter = Class{function(self, pos, radius)
    self.pos = pos
    self.radius = radius
    self.step = 50
end}

function Critter.update(critter, dt, game)
    critter.pos = critter.pos 
        + vector(math.random(-critter.step, critter.step) * dt,
                 math.random(-critter.step, critter.step) * dt)
end

function Critter.draw(critter)
    love.graphics.circle("fill", critter.pos.x, critter.pos.y, critter.radius)
end

function Critter.fromTmx(obj, game)
    if obj.type == 'Critter' then
        if not game.critters then
            game.critters = {}
        end
        table.insert(game.critters, Critter(vector(obj.x, obj.y), obj.width/2))
    end
end

return Critter