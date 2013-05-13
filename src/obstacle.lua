local Obstacle = Class{function(self) end}
function Obstacle:type() return "Obstacle" end

function Obstacle.fromTmx(obj, game)
    local obstacle = Obstacle()
    obstacle.body = game.collider:newBody(
        obj.x + obj.width / 2, obj.y + obj.height / 2, "static")
    obstacle.shape = love.physics.newPolygonShape(unpack(obj.polyline))
    obstacle.fixture = love.physics.newFixture(obstacle.body, obstacle.shape, 10)
    game:register(obstacle)
end

return Obstacle