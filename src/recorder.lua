local Recorder = Class{function(self)
    self.state = self.idle
    self.recordKey = '\\'
    self.frameDelay = 1.0/30.0 -- 30 fps
    self.frames = {}
    self.saveThread = love.thread.newThread("recorder.saveThread",
                                            "src/data_thread.lua")
    self.saveThread:start()
end}

function Recorder:update(dt)
    self:state(dt)
end

function Recorder:idle(dt)
    if love.keyboard.isDown(self.recordKey) then
        print("Starting recording")
        self.state = self.recording
        self.waitingTime = 0
    end
end

function Recorder:recording(dt)
    local numFrames = #self.frames
    if numFrames >= 180 or not love.keyboard.isDown(self.recordKey) then
        print("Finished recording, saving " .. numFrames .. " frames to disk")
        self.state = self.saving
        self.waitingTime = 0
        self.saveThread:set('numFiles', numFrames)
    else
        self.waitingTime = self.waitingTime + dt
        if self.waitingTime >= self.frameDelay then
            table.insert(self.frames, love.graphics.newScreenshot())
            self.waitingTime = 0
        end
    end
end

function Recorder:saving(dt)
    local frameNum = #self.frames
    if frameNum > 0 then
        local frame = table.remove(self.frames)
        local filename = string.format("screenshot-%03d.png", frameNum)
        self.saveThread:set('data', frame)
        self.saveThread:set('filename', filename)
        self.waitingTime = 0
    else
        print("Finished queueing files to save")
        self.state = self.idle
    end
end

function Recorder:draw()
end

return Recorder