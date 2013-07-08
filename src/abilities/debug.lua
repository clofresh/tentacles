local Debug = Class{function(self)
end}

function Debug:update(dt, player, current, prev)
    -- Toggle the hero image
    if current.toggleHero and not prev.toggleHero then
        if player.image == Images.hero1 then
            player.image = Images.hero2
        else
            player.image = Images.hero1
        end
    end
    return true
end

function Debug:draw(player)
    love.graphics.polygon("fill", player.body:getWorldPoints(
                                        player.shape:getPoints()))
end

return Debug
