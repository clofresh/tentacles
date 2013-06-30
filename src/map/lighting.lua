local nightEffect = love.graphics.newPixelEffect [[
    extern number ts;
    extern number pwr;
    extern vec4 lights[10]; // {x, y, size, power}
    extern number numLights;
    extern number brightness;
    extern number minLight;

    vec4 effect(vec4 color, Image tex, vec2 texCoords, vec2 pixelCoords) {
        vec4 val = Texel(tex, texCoords) * color;
        vec3 ambient = val.rgb * brightness;

        // Add the effect of the positional lights
        vec4 light;
        vec3 fullyLit;
        number scaledLight = 1.1 - brightness;
        for (int i = 0; i < numLights; i ++) {
            light = lights[i];
            fullyLit = val.rgb * light[2] * light[3] * scaledLight;
            ambient += fullyLit / length(light.rg - pixelCoords);
        }
        return vec4(max(ambient, val.rgb * minLight), val.a);
    }
]]

local Lighting = {}

function Lighting.newLight(x, y, size, power, active)
    if active == nil then
        active = true
    end
    return {
        x = x,
        y = y,
        size = size or 0,
        power = power or 0,
        active = active
    }
end

local update = function(self, dt, cam)
    local lights = {}
    for i, light in pairs(self.objects) do
        if light.active then
            local x, y = cam:cameraCoords(light.x, light.y)
            table.insert(lights, {x, HEIGHT - y, light.size, light.power})
        end
    end

    self.time = self.time + dt
    self:state(dt)

    if self.effect and #lights > 0 then
        self.effect:send("lights", unpack(lights))
        self.effect:send("numLights", #lights)
    end
end

local States = {}

function States.day(self, dt)
    if self.time >= self.dayLength then
        self.time = 0.0
        self.state = States.sunset
        self.effect = nightEffect
        print("Sunset")
    end
end

function States.night(self, dt)
    if self.time >= self.nightLength then
        self.time = 0.0
        self.state = States.sunrise
        print("Sunrise")
    end
end

function States.sunset(self, dt)
    local brightness = 1 - (self.time / self.sunsetLength)
    nightEffect:send("brightness", brightness)
    if self.time >= self.sunsetLength then
        self.time = 0.0
        self.state = States.night
        print("Night")
    end
end

function States.sunrise(self, dt)
    local brightness = self.time / self.sunsetLength
    nightEffect:send("brightness", brightness)
    if self.time >= self.sunriseLength then
        self.time = 0.0
        self.state = States.day
        print("Day")
    end
end

local draw = function(self)
    if self.effect then
        love.graphics.setPixelEffect(self.effect)
    else
        love.graphics.setPixelEffect()
    end
end

local register = function(self, light)
    table.insert(self.objects, light)
end

function Lighting.load(layer)
    layer.update = update
    layer.draw = draw
    layer.register = register
    layer:toCustomLayer(function(obj)
        return layer:register(Lighting.newLight(obj.x, obj.y,
            obj.properties.size, obj.properties.power))
    end)
    layer.state = States.day

    nightEffect:send("brightness", 1.0)
    nightEffect:send("minLight", 0.001)
    layer.effect = nightEffect
    layer.time = 0.0
    layer.dayLength = 10.0
    layer.sunsetLength = 10.0
    layer.nightLength = 10.0
    layer.sunriseLength = 10.0

end

return Lighting
