local MapTransition = {}

function MapTransition:enter(prevState, exit)
    self.newMap = Map.load(exit.dest .. '.tmx')
    local cam = prevState.cam
    self.cam = cam
    self.exit = exit
    self.oldMap = prevState.map

    local offset = vector(exit.ox, exit.oy)
    local center2 = offset + vector(
        self.newMap.width * self.newMap.tileWidth / 2,
        self.newMap.height * self.newMap.tileHeight / 2)
    local left1   = cam.x - WIDTH / 2
    local top1    = cam.y - HEIGHT / 2
    local right1  = cam.x + WIDTH / 2
    local bottom1 = cam.y + HEIGHT / 2
    local left2   = exit.ox
    local top2    = exit.oy
    local right2  = exit.ox + self.newMap.width * self.newMap.tileWidth
    local bottom2 = exit.oy + self.newMap.height * self.newMap.tileHeight

    local vx
    if left1 >= left2 and right1 <= right2 then
        vx = 0
    else
        local furthest
        if math.abs(center2.x - left1) > math.abs(center2.x - right1) then
            furthest = left1
        else
            furthest = right1
        end
        if math.abs(furthest - left2) < math.abs(furthest - right2) then
            vx = left2 - furthest
        else
            vx = right2 - furthest
        end
    end

    local vy
    if top1 >= top2 and bottom1 <= bottom2 then
        vy = 0
    else
        local furthest
        if math.abs(center2.y - top1) > math.abs(center2.y - bottom1) then
            furthest = top1
        else
            furthest = bottom1
        end
        if math.abs(furthest - top2) < math.abs(furthest - bottom2) then
            vy = top2 - furthest
        else
            vy = bottom2 - furthest
        end
    end

    self.camDisplacement = vector(vx, vy)
    self.transitionTime = 1.0
    self.elapsedTime = 0.0
end

function MapTransition:update(dt)
    local cam = self.cam
    local player = self.oldMap("entities").player
    local exit = self.exit

    -- local left1   = cam.x - WIDTH / 2
    -- local top1    = cam.y - HEIGHT / 2
    -- local right1  = cam.x + WIDTH / 2
    -- local bottom1 = cam.y + HEIGHT / 2
    -- local left2   = exit.ox
    -- local top2    = exit.oy
    -- local right2  = exit.ox + self.newMap.width * self.newMap.tileWidth
    -- local bottom2 = exit.oy + self.newMap.height * self.newMap.tileHeight

    -- if left1 >= left2 and right1  <= right2 and
    --    top1  >= top2  and bottom1 <= bottom2 then
    self.elapsedTime = self.elapsedTime + dt

    if self.elapsedTime >= self.transitionTime then
       print("done transitioning")
       local pX = player.body:getX() - exit.ox
       local pY = player.body:getY() - exit.oy
       self.oldMap("entities").collider:destroy()
       Game.map = self.newMap
       local entities = Game.map("entities")
       player = Player.fromTmx({x=pX, y=pY}, entities)
       table.insert(entities.objects, player)
       Gamestate.switch(Game)
    else
        local percent = dt / self.transitionTime
        cam.x = cam.x + percent * self.camDisplacement.x
        cam.y = cam.y + percent * self.camDisplacement.y

        local camWorldWidth = love.graphics.getWidth() / cam.scale
        local camWorldHeight = love.graphics.getHeight() / cam.scale
        local camWorldX = cam.x - (camWorldWidth / 2)
        local camWorldY = cam.y - (camWorldHeight / 2)
        self.oldMap:setDrawRange(camWorldX, camWorldY, camWorldWidth, camWorldHeight)
        self.newMap:setDrawRange(camWorldX, camWorldY, camWorldWidth, camWorldHeight)

    end
end

function MapTransition:draw()
    self.cam:draw(function()
        self.oldMap:draw()
        love.graphics.push()
        love.graphics.translate(self.exit.ox, self.exit.oy)
        self.newMap:draw()
        love.graphics.pop()
    end)
end

return MapTransition