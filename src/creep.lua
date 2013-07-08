local Creep = Class{function(self)
    self.cells = {}
    self.time = 0
end}

local getCell = function(cells, x, y, default)
    local row = cells[y]
    if row and row[x] ~= nil then
        return row[x]
    else
        return default
    end
end

local addCell = function(cells, x, y, val)
    local row = cells[y]
    if row then
        row[x] = val
    else
        cells[y] = {[x] = val}
    end
end

local removeCell = function(cells, x, y)
    local row = cells[y]
    if row then
        row[x] = nil
    end
end

function Creep:addCell(x, y)
    addCell(self.cells, x, y, true)
end

function Creep:removeCell(x, y)
    removeCell(self.cells, x, y)
end

function Creep:update(dt)
    self.time = self.time + dt
    if self.time < 1 then
        return
    end

    local counts = {}
    for y, row in pairs(self.cells) do
        for x, isAlive in pairs(row) do
            if isAlive then
                for yy = y - 1, y + 1 do
                    for xx = x - 1, x + 1 do
                        local count = getCell(counts, xx, yy, 0) + 1
                        addCell(counts, xx, yy, count)
                    end
                end
            end
        end
    end

    for y, row in pairs(counts) do
        for x, count in pairs(row) do
            local hasCell = getCell(self.cells, x, y)
            if count >= 6 and hasCell then
                removeCell(self.cells, x, y)
            elseif count == 3 and not hasCell then
                addCell(self.cells, x, y, true)
            end
        end
    end
    self.time = 0
end

function Creep:draw()
    for y, row in pairs(self.cells) do
        for x, isAlive in pairs(row) do
            if isAlive then
                love.graphics.draw(Images.creep, x * 32, y * 32)
            end
        end
    end
end

return Creep
