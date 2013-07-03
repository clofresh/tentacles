-- Global utilities
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

WIDTH  = love.graphics.getWidth()
HEIGHT = love.graphics.getHeight()

-- Font from http://openfontlibrary.org/en/font/leo-arrow
Fonts = {
    small  = love.graphics.newFont("fonts/leo_arrow.ttf", 12),
    normal = love.graphics.newFont("fonts/leo_arrow.ttf", 24),
    large  = love.graphics.newFont("fonts/leo_arrow.ttf", 36),
}

function love.load()
    Gamestate.registerEvents()
    Gamestate.switch(Title)
end
