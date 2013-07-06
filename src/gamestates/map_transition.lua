local MapTransition = {}

function MapTransition:enter(prevState, exit)
    self.newMap = Map.load(exit.dest .. '.tmx')
    local cam = prevState.cam
    self.cam = cam
    self.exit = exit
    self.oldMap = prevState.map
    self.transitionTime = exit.transitionTime
    self.elapsedTime = 0.0

    -- Get where the player is in prevMap's coordinates
    local player = self.oldMap("entities").player
    local pX1, pY1 = player.body:getPosition()

    -- Get the camera position in prevMap's coordinates
    local start = vector(cam.x, cam.y)

    -- Compute newMap's dimensions in pixels
    local newMapWidth = self.newMap.width * self.newMap.tileWidth
    local newMapHeight = self.newMap.height * self.newMap.tileHeight

    -- Compute the player's position in newMap's coordinates
    local pX2 = pX1 - exit.ox
    local pY2 = pY1 - exit.oy

    -- What the camera's position would be in newMap's coordinates 
    local target = vector(Camera.computePos(pX2, pY2, newMapWidth, newMapHeight))

    -- Compute the displacement vector to get from the current camera's
    -- position to newMap's position if newMap were in prevMap's coordinates
    self.camDisplacement = target - start + vector(exit.ox, exit.oy)
end

function MapTransition:update(dt)
    local cam = self.cam
    local player = self.oldMap("entities").player
    local exit = self.exit

    self.elapsedTime = self.elapsedTime + dt

    if self.elapsedTime >= self.transitionTime then
       print("done transitioning")
       local pX = player.body:getX() - exit.ox
       local pY = player.body:getY() - exit.oy
       self.oldMap("entities").collider:unregister(player)
       self.oldMap("entities").collider:destroy()
       Game.map = self.newMap
       Game.map("zones").lastCheckpoint = vector(pX, pY)
       Player.resetPhysics(player, Game.map)
       Gamestate.switch(Game)
    else
        local percent = dt / self.transitionTime
        cam.x = cam.x + percent * self.camDisplacement.x
        cam.y = cam.y + percent * self.camDisplacement.y

        local camWorldWidth = WIDTH / cam.scale
        local camWorldHeight = HEIGHT / cam.scale
        local camWorldX = cam.x - (camWorldWidth / 2)
        local camWorldY = cam.y - (camWorldHeight / 2)
        self.oldMap:setDrawRange(camWorldX, camWorldY, camWorldWidth, camWorldHeight)
        self.newMap:setDrawRange(camWorldX - exit.ox, camWorldY - exit.oy, camWorldWidth, camWorldHeight)

        self.oldMap("lighting"):update(dt, cam)
        self.newMap("lighting"):update(dt, cam, self.exit.ox, self.exit.oy)
    end
end

function MapTransition:draw()
    self.cam:draw(function()
        love.graphics.push()
        love.graphics.translate(self.exit.ox, self.exit.oy)
        self.newMap:draw()
        love.graphics.pop()
        self.oldMap:draw()
    end)
end

return MapTransition