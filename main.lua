-- Global utilities
WIDTH  = love.graphics.getWidth()
HEIGHT = love.graphics.getHeight()

Class  = require("lib/hump/class")
vector = require("lib/hump/vector")
math.clamp = function(val, min, max)
    return math.min(math.max(val, min), max)
end

-- Game states
Gamestate     = require("lib/hump/gamestate")
Title         = require("src/gamestates/title")
Game          = require("src/gamestates/game")
MapTransition = require("src/gamestates/map_transition")
GameOver      = require("src/gamestates/game_over")

-- Font from http://openfontlibrary.org/en/font/leo-arrow
FontSizes = {
    small  = 12,
    normal = 24,
    large  = 36,
}
Fonts = {}

for size, val in pairs(FontSizes) do
    Fonts[size] = love.graphics.newFont("fonts/leo_arrow.ttf", val)
end

function love.load()
    Gamestate.registerEvents()
    Gamestate.switch(Title)
end
