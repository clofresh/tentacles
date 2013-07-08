local Debug = Class{function(self)
end}

function Debug:update(player, dt, current, prev)
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

return Debug
