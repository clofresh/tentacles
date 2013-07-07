-- Font from http://openfontlibrary.org/en/font/leo-arrow
FontSizes = {
    small  = 12,
    normal = 24,
    large  = 36,
}
Fonts = {}
Images = {}
Music = {}

local Assets ={}
function Assets.load()
    -- Fonts
    for size, val in pairs(FontSizes) do
        Fonts[size] = love.graphics.newFont("fonts/leo_arrow.ttf", val)
    end

    -- Images
    Images.blood = love.graphics.newImage("img/blood.gif")
    Images.seg1  = love.graphics.newImage("img/tentacle4_seg1.png")
    Images.seg2  = love.graphics.newImage("img/tentacle4_seg2.png")
    Images.seg3  = love.graphics.newImage("img/tentacle4_seg3.png")
    Images.blob  = love.graphics.newImage("img/blob.png")
    Images.hero1  = love.graphics.newImage("img/hero1.png")
    Images.hero2  = love.graphics.newImage("img/hero2.png")

    -- Sound
    Music.main = love.audio.newSource("sound/lawyersinlove.mp3")
end

return Assets