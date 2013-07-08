local Torch = {}

local update = function(self, player, dt, current, prev)
    local x, y = player.body:getWorldCenter()
    self.x = x + 40
    self.y = y

    -- Toggle the torch
    if current.toggleTorch and not prev.toggleTorch then
        self.active = not self.active
    end

    return true
end

function Torch.init(self, ...)
    local torch = Lighting.newLight(...)
    torch.update = update
    return torch
end

return setmetatable(Torch, {__call = Torch.init})