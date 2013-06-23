local effect = [[
    extern number ts;   //Tile size
    extern number pwr;
    extern vec2 pos;    //Player position
    extern number brightness;
    extern number minLight;

    vec4 effect(vec4 color, Image tex, vec2 texCoords, vec2 pixelCoords) {
        vec4 val = Texel(tex, texCoords) * color;
        vec3 ambient = val.rgb * brightness;
        vec3 lightSource = val.rgb * ts * pwr / length(pos - pixelCoords);
        return vec4(max(ambient + lightSource, val.rgb * minLight),
                    val.a);
    }
]]


local Lighting = Class{function(self, pos)
    self.pos = pos
    self.nightEffect = love.graphics.newPixelEffect(effect)
    self.nightEffect:send("ts", 5)
    self.nightEffect:send("pwr", 0)
    self.nightEffect:send("brightness", 1.0)
    self.nightEffect:send("minLight", 0.001)
    self.state = self.day
    self.effect = self.nightEffect
    self.time = 0.0
    self.dayLength = 10.0
    self.sunsetLength = 10.0
    self.nightLength = 10.0
    self.sunriseLength = 10.0
    self.torchThreshold = 0.25
    self.torchPower = 5
end}

function Lighting:update(dt)
    self.time = self.time + dt
    self:state(dt)
end

function Lighting:day(dt)
    if self.time >= self.dayLength then
        self.time = 0.0
        self.state = self.sunset
        self.effect = self.nightEffect
        print("Sunset")
    end
end

function Lighting:night(dt)
    if self.time >= self.nightLength then
        self.time = 0.0
        self.state = self.sunrise
        print("Sunrise")
    end
end

function Lighting:sunset(dt)
    local brightness = 1 - (self.time / self.sunsetLength)
    self.nightEffect:send("brightness", brightness)
    if brightness <= self.torchThreshold then
        self.nightEffect:send("pwr", self.torchPower)
    end
    if self.time >= self.sunsetLength then
        self.time = 0.0
        self.state = self.night
        print("Night")
    end
end

function Lighting:sunrise(dt)
    local brightness = self.time / self.sunsetLength
    self.nightEffect:send("brightness", brightness)
    if brightness > self.torchThreshold then
        self.nightEffect:send("pwr", 0)
    end
    if self.time >= self.sunriseLength then
        self.time = 0.0
        self.state = self.day
        self.effect = nil
        print("Day")
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