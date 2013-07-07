local mouse = {}

mouse.getInput = function(events)
    if love.mouse.isDown("l") then
        events.attackLeft = true
    end
    return events
end

return mouse