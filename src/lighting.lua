local effect = [[
    extern number ts;   //Tile size
    extern number pwr;
    extern vec2 pos;    //Player position
    extern vec4 ambient;

    vec4 effect(vec4 colour, Image img, vec2 percent, vec2 pixel) {
        return (Texel(img, percent) * (ts / length(pos - pixel) * pwr)) + ambient;
    }
]]


local Lighting = Class{function(self, pos)
    self.stencil = love.graphics.newStencil(function()
        love.graphics.setColor(255, 255, 255, 255)
        love.graphics.circle("fill", 800, 600, 100)
    end)
    self.pos = pos
    self.effect = love.graphics.newPixelEffect(effect)
    self.effect:send("ts", 5)
    self.effect:send("pwr", 5)
    self.effect:send("ambient", {0.1, 0.1, 0.2, 0.0})
end}

function Lighting:update(dt)
end

function Lighting:draw(pos)
    local pos = {pos[1] + 40, pos[2]}
    self.effect:send("pos", pos)
    love.graphics.setPixelEffect(self.effect)
end

return Lighting