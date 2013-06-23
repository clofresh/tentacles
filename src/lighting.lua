local effect = [[
    extern number ts;
    extern number pwr;
    extern vec4 lights[10];
    extern number numLights;
    extern number brightness;
    extern number minLight;

    vec4 effect(vec4 color, Image tex, vec2 texCoords, vec2 pixelCoords) {
        vec4 val = Texel(tex, texCoords) * color;
        vec3 ambient = val.rgb * brightness;

        // Add the effect of the positional lights
        for (int i = 0; i < numLights; i ++) {
            vec4 light = lights[i];
            vec3 fullyLit = val.rgb * light[2] * light[3];
            ambient += fullyLit / length(light.rg - pixelCoords);
        }
        return vec4(max(ambient, val.rgb * minLight), val.a);
    }
]]


local Lighting = Class{function(self, cam, lights)
    self.cam = cam
    self.lights = lights or {}
    self.nightEffect = love.graphics.newPixelEffect(effect)
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

function Lighting:newLight(x, y, size, power)
    return {
        x = x,
        y = y,
        size = size or 0,
        power = power or 0
    }
end

function Lighting:addLight(light)
    local x, y = self.cam:cameraCoords(light.x, light.y)
    table.insert(self.lights, {x, HEIGHT - y, light.size, light.power})
end

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
    if self.time >= self.sunsetLength then
        self.time = 0.0
        self.state = self.night
        print("Night")
    end
end

function Lighting:sunrise(dt)
    local brightness = self.time / self.sunsetLength
    self.nightEffect:send("brightness", brightness)
    if self.time >= self.sunriseLength then
        self.time = 0.0
        self.state = self.day
        self.effect = nil
        print("Day")
    end
end

function Lighting:draw(cam)
    if self.effect then
        self.nightEffect:send("lights", unpack(self.lights))
        self.nightEffect:send("numLights", #self.lights)
        love.graphics.setPixelEffect(self.nightEffect)
    else
        love.graphics.setPixelEffect()
    end
    self.lights = {}
end

return Lighting