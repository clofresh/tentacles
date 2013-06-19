local effect = [[
    extern number ambient;
    extern number radius;
    extern vec2 pos;

    vec4 effect(vec4 color, Image texture, vec2 t_coords, vec2 s_coords) {
        vec4 pixel = Texel(texture, t_coords);
        float dist = length(s_coords - pos);
        if (pixel.a == 0.0) {
            return pixel;
        } else {
            return vec4(pixel.rgb, pixel.a + ambient - (dist / radius));
        }
    }
]]


local Lighting = Class{function(self, pos)
    self.stencil = love.graphics.newStencil(function()
        love.graphics.setColor(255, 255, 255, 255)
        love.graphics.circle("fill", 800, 600, 100)
    end)
    self.pos = pos
    self.effect = love.graphics.newPixelEffect(effect)
    self.effect:send("ambient", 0.1)
    self.effect:send("radius", 512.0)
end}

function Lighting:update(dt)
end

function Lighting:draw(pos)
    self.effect:send("pos", pos)
    love.graphics.setPixelEffect(self.effect)
end

return Lighting