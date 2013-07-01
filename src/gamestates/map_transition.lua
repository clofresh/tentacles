local MapTransition = {}

function MapTransition:enter(prevState, exit)
    self.newMap = Map.load(exit.dest .. '.tmx')
    local cam = prevState.cam
    self.camVelocity = (vector(exit.ox, exit.oy)
        - vector(cam.x - WIDTH / 2, cam.y - HEIGHT / 2)):normalized() * 5000
    self.cam = cam
    self.exit = exit
    self.oldMap = prevState.map
end

function MapTransition:update(dt)
    local cam = self.cam
    local player = self.oldMap("entities").player
    local exit = self.exit
    local x = cam.x - WIDTH / 2
    local y = cam.y - HEIGHT / 2
    local len = (vector(exit.ox, exit.oy) - vector(x, y)):len() 
    print(len)
    if len < 20 then
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
        cam.x = cam.x + dt * self.camVelocity.x
        cam.y = cam.y + dt * self.camVelocity.y
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