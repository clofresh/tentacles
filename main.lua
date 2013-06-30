-- Global utilities
Class  = require("lib/hump/class")
vector = require("lib/hump/vector")

-- Game states
Gamestate = require("lib/hump/gamestate")
Game      = require("src/gamestates/game")
GameOver  = require("src/gamestates/game_over")

WIDTH  = love.graphics.getWidth()
HEIGHT = love.graphics.getHeight()

function love.load()
    Gamestate.registerEvents()
    Gamestate.switch(Game)
end
