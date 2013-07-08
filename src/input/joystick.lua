local dong = require("lib/dong/dong")
local joystick = {}

joystick.getInput = function(events)
    -- xbox controller movement input
    local joyNum = 1

    if dong.isDown(joyNum, "A") then
        events.attackLeft = true
    end

    if dong.isDown(joyNum, "X") then
        events.attackRight = true
    end

    events.dx, events.dy = dong.ls(joyNum)

    if dong.isDown(joyNum, "Y") then
        events.toggleTorch = true
    end

    return events
end

return joystick