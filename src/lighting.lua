local effect = [[
    extern number ts;   //Tile size
    extern number pwr;
    extern vec2 pos;    //Player position

    vec4 effect(vec4 colour, Image img, vec2 percent, vec2 pixel) {
        return Texel(img, percent) * (ts / length(pos - pixel) * pwr);
    }
]]


local Lighting = Class{function(self, pos)
    self.stencil = love.graphics.newStencil(function()
        love.graphics.setColor(255, 255, 255, 255)
        love.graphics.circle("fill", 800, 600, 100)
    end)
    self.pos = pos
    self.effect = love.graphics.newPixelEffect(effect)
    self.effect:send("ts", 64)
    self.effect:send("pwr", 1)
end}

function Lighting:update(dt)
    -- print(self.pos[1], self.pos[2])
end

function Lighting:draw(pos)
    -- local r, g, b, a = love.graphics.getColor()
    -- love.graphics.setInvertedStencil(self.stencil)
    -- love.graphics.setColor(0, 0, 0, 200)
    -- love.graphics.rectangle("fill", 0, 0, 1024, 768)
    -- love.graphics.setColor(r, g, b, a)
    self.effect:send("pos", pos)
    love.graphics.setPixelEffect(self.effect)
end

return Lighting