push = require 'lib.push'
Gamestate = require 'lib.hump.gamestate'

require 'states.Menu'
require 'states.Play'
require 'states.Pause'
require 'states.Win'
require 'states.GameOver'
require 'states.HighScore'
require 'objects.Player'
require 'objects.Bullet'
require 'objects.Enemy'
require 'objects.Boss'

VIRTUAL_WIDTH = 320
VIRTUAL_HEIGHT = 150 
WINDOW_WIDTH = 900
WINDOW_HEIGHT = 600

function love.load()
    love.graphics.setDefaultFilter('nearest', 'nearest')
    love.window.setTitle('The Dimensional Traveler')

    gFonts = {
        small = love.graphics.newFont(8),
        medium = love.graphics.newFont(16),
        large = love.graphics.newFont(32)
    }
    
   
    for _, font in pairs(gFonts) do
        font:setFilter('nearest', 'nearest')
    end

    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = true,
        vsync = true
    })

    Gamestate.switch(Menu)
end

function love.resize(w, h)
    push:resize(w, h)
end

function love.update(dt)
    Gamestate.update(dt)
end

function love.keypressed(key)
    Gamestate.keypressed(key)
end

function love.draw()
    push:start()
        Gamestate.draw()
    push:finish()
end