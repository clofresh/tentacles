-- Global utilities
Class  = require("lib/hump/class")
vector = require("lib/hump/vector")
math.clamp = function(val, min, max)
    return math.min(math.max(val, min), max)
end

-- Game states
Gamestate     = require("lib/hump/gamestate")
Game          = require("src/gamestates/game")
MapTransition = require("src/gamestates/map_transition")
GameOver      = require("src/gamestates/game_over")

WIDTH  = love.graphics.getWidth()
HEIGHT = love.graphics.getHeight()

function love.load()
    Gamestate.registerEvents()
    Gamestate.switch(Game)
end
