require("love.filesystem")
require("love.image")

thread = love.thread.getThread()
love.filesystem.setIdentity('tentacle')

while true do
    local status, err = pcall(function() 
        datas = {}
        filenames = {}
        print("Waiting")
        numFiles = thread:demand('numFiles')
        print(string.format("Expecting to save %d files", numFiles))
        while numFiles > 0 do
            data = thread:demand("data")
            filename = thread:demand("filename")
            table.insert(datas, data)
            table.insert(filenames, filename)
            print("Queueing " .. filename)
            numFiles = numFiles - 1
        end
        for i, data in pairs(datas) do
            filename = filenames[i]
            print("Saving " .. filename)
            data:encode(filename)
        end
        print("Finished saving")
    end)
    if not status then
        print(err)
    end
end