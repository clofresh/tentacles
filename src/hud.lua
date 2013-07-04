local locations = {
    topleft     = { translation={0, 0},                direction={1, 1}  },
    bottomright = { translation={WIDTH - 100, HEIGHT - 32}, direction={1, -1} },
}

local Hud = Class{function(self, widgets)
    self.widgets = widgets or {
        bottomright = Hud.System()
    }
end}

function Hud:set(location, widget)
    self.widgets[location] = widget
end

function Hud:update(dt)
    for i, widget in pairs(self.widgets) do
        widget:update(dt)
    end
end

function Hud:draw()
    for locationName, widget in pairs(self.widgets) do
        local location = locations[locationName]
        if location then
            love.graphics.push()
            love.graphics.translate(unpack(location.translation))
            widget:draw(unpack(location.direction))
            love.graphics.pop()
        end
    end
end

Hud.System = Class{function(self)
    self.fps = 0
    self.mem = 0
    self.fontSize = "small"
end}

function Hud.System:update(dt)
    self.fps = love.timer.getFPS()
    self.mem = math.floor(collectgarbage("count"))
    self.output = {
        string.format("FPS: %d", self.fps),
        string.format("Mem: %dKB", self.mem),
    }
end

function Hud.System:draw(dirX, dirY)
    Hud.printLines(self.output, self.fontSize, dirX, dirY)
end

function Hud.printLines(lines, fontSize, dirX, dirY)
    love.graphics.setFont(Fonts[fontSize])
    local lineHeight = FontSizes[fontSize]
    for i, line in pairs(lines) do
        local y
        if dirY > 0 then
            y = i * lineHeight
        else
            y = (#lines - i + 1) * lineHeight
        end
        love.graphics.print(line, 0, y)
    end
end

return Hud