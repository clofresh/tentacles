local mouse = {}

mouse.update = function(player, dt, game)
    if love.mouse.isDown("l") then
        player.weapon:primaryAttack()
    end
end

return mouse