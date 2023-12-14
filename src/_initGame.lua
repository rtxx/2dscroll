function loadGlobalVars()
  -- gameVars is a table with useful data from the game
  gameVars = {}

  -- loading libs
  screen        = require("lib/push/push")
  scenesInit    = require("lib/scenery/scenery")
  flux          = require("lib/flux/flux")
  bump          = require("lib/bump/bump")
  class         = require("lib/middleclass/middleclass")
  sti           = require("lib/sti/sti")
  camera        = require("lib/STALKER-X/Camera")
  anim          = require("lib/anim8/anim8")
  tween         = require("lib/tween/tween")
  yui           = require("lib/yui")

  
  -- loading game class's
  Map       = require("src/map")
  Entity    = require("src/entities/entity")
  Player    = require("src/entities/player")
  Enemy     = require("src/entities/enemy")
  Dumga     = require("src/entities/dumga")
  
  -- assets
  -- fonts
  font                      = {}
  font.menu                 = "assets/fonts/pixeldroidMenuRegular.ttf"

  -- maps
  maps                      = {}
  maps.lvl0                 = {} 
  maps.lvl0.map             = "assets/levels/lvl0/map.lua"
  maps.lvl0.sounds          = {}
  maps.lvl0.sounds.music    = "assets/levels/lvl0/music.wav"

  maps.lvl1                 = {} 
  maps.lvl1.map             = "assets/levels/lvl1/map.lua"
  maps.lvl1.sounds          = {}
  maps.lvl1.sounds.music    = "assets/levels/lvl1/music.wav"

  -- player
  playerAssets              = {}
  playerAssets.spriteSheet  = "assets/player/player-sheet.png"
  playerAssets.sounds       = {}
  playerAssets.sounds.jump  = "assets/player/jump"
  playerAssets.sounds.hit   = "assets/player/hit"

  -- enemies
  enemyAssets                   = {}
  enemyAssets.sounds            = {}
  -- dumga assets
  enemyAssets.dumga             = {}
  enemyAssets.sounds.dumga      = {}
  enemyAssets.dumga.sprite      = "assets/dumga/dumga.png"
  enemyAssets.sounds.dumga.hit  = "assets/dumga/hit"
end

function initGame()
  loadGlobalVars()
  gameVars.name             = "2dscroll"
  gameVars.version          = "alpha 1"
  gameVars.author           = "Rui 'redbeard' Teixeira"

  gameVars.genericError     = "Oh no! Something went wrong... "
  gameVars.genericText      = "Hey there."
  gameVars.systemDebugText  = "[SYSTEM] "
  gameVars.scenesDebugText  = "[SCENEMANAGER] "
  gameVars.bumpDebugText    = "[BUMP] "
  gameVars.stiDebugText     = "[STI] "
  
  gameVars.currentScene           = nil
  gameVars.ignoreDebugTextOnScene = "mainMenu optionsMenu"

  gameVars.currentPlayer        = nil
  gameVars.currentPlayerCamera  = nil

  gameVars.gameover         = {}
  gameVars.gameover.active  = false
  gameVars.gameover.reason  = ""
  gameVars.gameover.music   = ""
  
  gameVars.colors = {}
  for i=0, 15 do
    gameVars.colors[i] = {}
  end
  
  gameVars.colors[0].name   = "black" 
  gameVars.colors[0].hex    = "#000000"
  gameVars.colors[0].r      = 0 
  gameVars.colors[0].g      = 0
  gameVars.colors[0].b      = 0
  gameVars.colors[1].name   = "dark-blue" 
  gameVars.colors[1].hex    = "#1D2B53"
  gameVars.colors[1].r      = 29
  gameVars.colors[1].g      = 43
  gameVars.colors[1].b      = 83
  gameVars.colors[2].name   = "dark-purple" 
  gameVars.colors[2].hex    = "#7E2553"
  gameVars.colors[2].r      = 126
  gameVars.colors[2].g      = 37
  gameVars.colors[2].b      = 83
  --[[ 
  pico8 pallete
  0 		#000000 	0, 0, 0 	black
  1 		#1D2B53 	29, 43, 83 	dark-blue
  2 		#7E2553 	126, 37, 83 	dark-purple
  3 		#008751 	0, 135, 81 	dark-green
  4 		#AB5236 	171, 82, 54 	brown
  5 		#5F574F 	95, 87, 79 	dark-grey
  6 		#C2C3C7 	194, 195, 199 	light-grey
  7 		#FFF1E8 	255, 241, 232 	white
  8 		#FF004D 	255, 0, 77 	red
  9 		#FFA300 	255, 163, 0 	orange
  10 		#FFEC27 	255, 236, 39 	yellow
  11 		#00E436 	0, 228, 54 	green
  12 		#29ADFF 	41, 173, 255 	blue
  13 		#83769C 	131, 118, 156 	lavender
  14 		#FF77A8 	255, 119, 168 	pink
  15 		#FFCCAA 	255, 204, 170 	light-peach 
  --]]
 
  -- print welcome line
  --love.graphics.setBackgroundColor(43/255, 165/255, 223/255)
  love.graphics.setBackgroundColor(gameVars.colors[1].r /255, gameVars.colors[1].g /255, gameVars.colors[1].b /255)
  print(gameVars.systemDebugText .. "Welcome to " .. gameVars.name .. "!")

  -- screen setup
  local width, height = love.window.getDesktopDimensions()
  --local width, height = 1280, 720

  gameVars.windowSizeW = width
  gameVars.windowSizeH = height
  gameVars.gameSizeW   = gameVars.windowSizeW / 3
  gameVars.gameSizeH   = gameVars.windowSizeH / 3

  love.window.setMode(gameVars.windowSizeW, gameVars.windowSizeH, {resizable = false, vsync = 1, fullscreen = true}) 
  screen.setupScreen(gameVars.gameSizeW, gameVars.gameSizeH, {upscale = "pixel-perfect"})

  -- scenes setup
  scenes = scenesInit("mainMenu","src/scenes")
  scenes:load()

  -- initialize ui
  defaultFont = love.graphics.newFont(font.menu, 16)
  menuFont = love.graphics.newFont(font.menu, 32)
  
  -- initialize sound
  love.audio.setVolume(0.1)
  
  -- controller (testing)
  gameVars.controller = love.joystick.getJoysticks()[1] or nil

end

-- callbacks
-- input
function love.keypressed(key, scancode, isrepeat)
  scenes:keypressed(key, scancode, isrepeat)

  if gameVars.currentPlayer ~= nil then
    gameVars.currentPlayer:keypressed(key, scancode, isrepeat)
  end
  
function love.keyreleased(key, scancode, isrepeat)
  if gameVars.currentPlayer ~= nil then
    gameVars.currentPlayer:keyreleased(key, scancode, isrepeat)
  end
end

function love.gamepadpressed(joystick, button)
  if gameVars.currentPlayer ~= nil then
    gameVars.currentPlayer:gamepadpressed(joystick, button)
  end
end
  
function love.gamepadreleased(joystick, button)
  if gameVars.currentPlayer ~= nil then
    gameVars.currentPlayer:gamepadreleased(joystick, button)
  end
end

  -- F1 -> Restart game
  if key == "f1" then
    print(gameVars.systemDebugText .. "Restarting...")
    love.event.quit("restart") 
  end	
  -- F11 -> Fullscreen toggle
  if key == "f11" then
    fullscreen = not fullscreen
    love.window.setFullscreen(fullscreen, "exclusive")
    print(gameVars.systemDebugText .. "Fullscreen: " .. tostring(fullscreen))
  end
end

function love.mousepressed(mx, my, mouseButton)
  scenes:mousepressed(mx, my, mouseButton)
end

function love.mousereleased(mx, my, mouseButton)
  scenes:mousereleased(mx, my, mouseButton)
end

-- misc
-- Make sure push follows LÖVE's resizes
function love.resize(width, height)
  screen.resize(width, height)
  print(gameVars.systemDebugText .. "Resolution set to " .. width .. "x" .. height ) 
end

function love.quit()
  print(gameVars.systemDebugText .. "Bye.")
end

--[[
-- custom error handler in case of a crash
-- delete to get the default error window from love2d
function love.errorhandler(msg, layer)
  local title = gameVars.genericError .. gameVars.name .. " just crashed."
  local message = (debug.traceback("Error: " .. tostring(msg), 1+(layer or 1)):gsub("\n[^\n]+$", ""))
  print(message)

  local buttons = {"OK", escapebutton = 1}
  local pressedbutton = love.window.showMessageBox(title, message, buttons)
end
--]]
