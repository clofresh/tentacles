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
    self.pos = pos
    self.nightEffect = love.graphics.newPixelEffect(effect)
    self.nightEffect:send("ts", 5)
    self.nightEffect:send("pwr", 5)
    self.nightEffect:send("ambient", {0.1, 0.1, 0.2, 0.0})
    self.state = self.day
    self.time = 0.0
    self.dayLength = 10.0
    self.nightLength = 10.0
end}

function Lighting:update(dt)
    self.time = self.time + dt
    self:state(dt)
end

function Lighting:day(dt)
    if self.time >= self.dayLength then
        self.time = 0.0
        self.state = self.night
        self.effect = self.nightEffect
    end
end

function Lighting:night(dt)
    if self.time >= self.nightLength then
        self.time = 0.0
        self.state = self.day
        self.effect = nil
    end
end

function Lighting:draw(pos)
    if self.effect then
        local pos = {pos[1] + 40, pos[2]}
        self.nightEffect:send("pos", pos)
        love.graphics.setPixelEffect(self.nightEffect)
    else
        love.graphics.setPixelEffect()
    end
end

return Lighting