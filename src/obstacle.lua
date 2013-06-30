local Obstacle = Class{function(self) end}
function Obstacle:type() return "Obstacle" end

function Obstacle.fromTmx(obj, layer)
    local obstacle = Obstacle()
    obstacle.body = layer.collider:newBody(
        obj.x + obj.width / 2, obj.y + obj.height / 2, "static")
    obstacle.shape = love.physics.newRectangleShape(obj.width, obj.height)
    obstacle.fixture = love.physics.newFixture(obstacle.body, obstacle.shape, 10)
    layer.collider:register(obstacle)
    return obstacle
end

return Obstacle