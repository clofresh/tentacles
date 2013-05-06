local mouse = {}

mouse.update = function(player, dt, game)
    if love.mouse.isDown("l") then
        local x, y = game.cam:mousepos()
        local dir = vector(x, y) - vector(player.body:getPosition())
        player.weapon:primaryAttack(dir, player, dt, game)
    end
end

return mouse