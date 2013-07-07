local lk = love.keyboard
local keyboard = {}

keyboard.getInput = function(events)
    if lk.isDown("j") then
        events.attackLeft = true
    end

    if lk.isDown("k") then
        events.attackRight = true
    end

    if lk.isDown("a") then
        events.dx = -1
    elseif lk.isDown("d") then
        events.dx = 1
    end

    if lk.isDown("w") then
        events.dy = -1
    elseif lk.isDown("s") then
        events.dy = 1
    end

    if lk.isDown("lshift") then
        events.sprinting = true
    end

    if lk.isDown("t") then
        events.toggleTorch = true
    end

    if lk.isDown("1") then
        events.toggleHero = true
    end

    return events
end

return keyboard