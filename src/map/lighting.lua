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

local Lighting = {
    effect = nightEffect,
    time = 0.0,
    dayLength = 10.0,
    sunsetLength = 10.0,
    nightLength = 10.0,
    sunriseLength = 10.0,
}

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

local update = function(self, dt, cam, ox, oy)
    local lights = {}
    local ox = ox or 0
    local oy = oy or 0
    for i, light in pairs(self.objects) do
        if light.active then
            local x, y = cam:cameraCoords(light.x + ox, light.y + oy)
            table.insert(lights, {x, HEIGHT - y, light.size, light.power})
        end
    end

    Lighting.time = Lighting.time + dt
    Lighting.state(self, dt)

    if Lighting.effect then
        if #lights > 0 then
            Lighting.effect:send("lights", unpack(lights))
            Lighting.effect:send("numLights", #lights)
        else
            Lighting.effect:send("numLights", 0)
        end
    end
end

local States = {}

function States.day(self, dt)
    if Lighting.time >= Lighting.dayLength then
        Lighting.time = 0.0
        Lighting.state = States.sunset
        Lighting.effect = nightEffect
        print("Sunset")
    end
end

function States.night(self, dt)
    if Lighting.time >= Lighting.nightLength then
        Lighting.time = 0.0
        Lighting.state = States.sunrise
        print("Sunrise")
    end
end

function States.sunset(self, dt)
    local brightness = 1 - (Lighting.time / Lighting.sunsetLength)
    nightEffect:send("brightness", brightness)
    if Lighting.time >= Lighting.sunsetLength then
        Lighting.time = 0.0
        Lighting.state = States.night
        print("Night")
    end
end

function States.sunrise(self, dt)
    local brightness = Lighting.time / Lighting.sunsetLength
    nightEffect:send("brightness", brightness)
    if Lighting.time >= Lighting.sunriseLength then
        Lighting.time = 0.0
        Lighting.state = States.day
        print("Day")
    end
end

-- Initialize it to be daytime
Lighting.state = States.day
nightEffect:send("brightness", 1.0)
nightEffect:send("minLight", 0.001)

local draw = function(self)
    if Lighting.effect then
        love.graphics.setPixelEffect(Lighting.effect)
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
end

return Lighting
