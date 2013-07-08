local Blood = Class{function(self, particles)
    self.particles = particles or love.graphics.newParticleSystem(Images.blood, 100)
    self.particles:start()
    self.particles:setEmissionRate(100)
    self.particles:setSpeed(20, 100)
    self.particles:setGravity(100, 200)
    self.particles:setLifetime(0.125)
    self.particles:setParticleLife(0.25)
    self.particles:setDirection(180)
    self.particles:setSpread(20)
    self.particles:setSizes(0.5, 1, 1.5, 2)
    self.particles:setColors(255, 0, 0, 255, 55, 6, 5, 255)
    self.particles:stop()    
end}

function Blood:update(dt)
    self.particles:update(dt)
    return true
end

function Blood:trigger(contact)
    self.particles:setPosition(contact:getPositions())
    self.particles:start()
end

function Blood:draw()
    love.graphics.draw(self.particles)
end

return Blood