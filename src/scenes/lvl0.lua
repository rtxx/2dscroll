-- lvl0 (test) - scene
local scene         = {}
local world         = nil
local gameMap       = nil
local levelEntities = nil

function scene:load()
  scene.name            = "lvl0"
  gameVars.currentScene = scene.name
  print(gameVars.scenesDebugText .. "New scene entered: ", scene.name)
  
  levelEntities         = {}
  levelEntities.walls   = {}
  levelEntities.enemies = {}
  
  -- when gameover is triggered this flag will allow 'stuff' to run only once
  self.gameoverTrigger  = false

  -- loads new world
  local cellSize        = 32
  world                 = bump.newWorld(cellSize)
  gameMap               = Map:new(maps.lvl0.map, world)
  print(gameVars.bumpDebugText .. "New world created with cell size of " .. cellSize)

  -- map : load entities
  -- player
  local playerObjFromMap  = gameMap:getPlayer()
  -- walls
  levelEntities.walls     = gameMap:getWalls()
  -- enemies
  levelEntities.enemies   = gameMap:getEnemies()
  
  -- player init
  player = Player:new(world,playerObjFromMap.x,playerObjFromMap.y,playerObjFromMap.width,playerObjFromMap.height)
  gameVars.currentPlayer        = player
  zoom = 1
  gameVars.currentPlayerCamera  = camera(gameVars.gameSizeW/2,gameVars.gameSizeH/2, gameVars.gameSizeW,gameVars.gameSizeH,zoom)
  gameVars.currentPlayerCamera:setFollowStyle('PLATFORMER')
  gameVars.currentPlayerCamera:follow(player.x, player.y)
  
  introText = { x = -200, y = gameVars.windowSizeW / 4, str = scene.name }
  flux.to(introText, 5, { x = 2000}):ease("quadin")

  gameoverText      = { x = gameVars.windowSizeW / 4, y = -100, str = nil}
  gameoverText.str  = "GAMEOVER!"

  print(gameVars.bumpDebugText .. "Entities from map loaded to world")

  player.isActive     = true
  playerObjFromMap    = nil
  musicBackground     = love.audio.newSource(maps.lvl0.sounds.music, "stream")
  print(gameVars.systemDebugText .. "Load complete")
  musicBackground:play()

end

function scene:update(dt)
  if gameVars.currentPlayer ~= nil then
    if gameVars.currentPlayer.isActive then
      gameVars.currentPlayer:update(dt)
      gameVars.currentPlayerCamera:update()
      gameVars.currentPlayerCamera:follow(player.x, player.y)
      if levelEntities.walls ~= nil then
        for _, wall in pairs(levelEntities.walls) do
          wall:update()
        end
      end
      if levelEntities.enemies ~= nil  then
        for k, enemy in pairs(levelEntities.enemies) do
          enemy:update(dt)
        end
      end
    end
  end

  if gameVars.gameover.active then
    musicBackground:stop()  
    if not self.gameoverTrigger then
      print(gameVars.systemDebugText .. "Gameover!")
      print(gameVars.systemDebugText .. "Reason: " .. gameVars.gameover.reason)
      flux.to(gameoverText, gameVars.currentPlayer.deadTime, { y = 400}):ease("cubicinout")
      deadTime = gameVars.currentPlayer.deadTime
      self.gameoverTrigger = true
    end

    deadTime = deadTime - dt
    if deadTime <= 0 then
      deadTime = nil
      scene:gameOver()
    end
  end
end

function scene:draw()
  if gameVars.currentPlayer ~= nil then
    if gameVars.currentPlayer.isActive then
      screen.start()
      gameVars.currentPlayerCamera:attach()
        gameMap:draw()
        gameVars.currentPlayer:draw() 
        -- simple debug draw
        if levelEntities.walls ~= nil  then
          for k, wall in pairs(levelEntities.walls) do
            wall:draw()
          end
        end
        if levelEntities.enemies ~= nil  then
          for k, enemy in pairs(levelEntities.enemies) do
            if enemy.isActive then
              enemy:draw()
            end
          end
        end
      gameVars.currentPlayerCamera:detach()
      screen.finish()
    end
  end
  
  local currentTotalEntities = world:countItems()

  love.graphics.setColor(gameVars.colors[2].r /255,gameVars.colors[2].g /255,gameVars.colors[2].b /255)
  love.graphics.print("lvl0", gameVars.windowSizeW-100, 10)
  love.graphics.print("entities: " .. currentTotalEntities, gameVars.windowSizeW-100, 20)
  love.graphics.print("hp: " .. tostring(gameVars.currentPlayer.hp), gameVars.windowSizeW-100, 30)
  --love.graphics.print("invic: " .. math.abs(gameVars.currentPlayer.currentInvincibleDuration) / (gameVars.currentPlayer.invincibleDuration *100) , gameVars.windowSizeW-100, 40)
  --love.graphics.print("jumpkey: " .. gameVars.currentPlayer.jumpKey, gameVars.windowSizeW-100, 40)
 
  love.graphics.print(introText.str, introText.x, introText.y,0,8,8)
  if gameVars.gameover.active then
    love.graphics.print(gameoverText.str, gameoverText.x, gameoverText.y,0,8,8)
  end
  love.graphics.setColor(1,1,1)
end

function scene:pause()
  love.graphics.print(gameVars.scenesDebugText .. "Game is paused")
  scene.paused = true
  --player.active = false
end

function scene:gameOver()
  levelEntities = nil
  world = nil
  print(gameVars.bumpDebugText .. "world destroyed")
  map = nil
  print(gameVars.stiDebugText .. "map destroyed")
  musicBackground = nil
  gameVars.gameover.active = false
  scene.setScene("mainMenu")
end

function scene:keypressed(key, scancode, isrepeat)
  if key == "escape" then
    if scene.paused == true then
      scene.paused = false
      --player.active = true
    else
      levelEntities = nil
      world = nil
      print(gameVars.bumpDebugText .. "world destroyed")
      map = nil
      print(gameVars.stiDebugText .. "map destroyed")
      musicBackground:stop()
      musicBackground = nil
      gameVars.gameover.active = false
      scene.setScene("mainMenu")
    end
  end
  if key == "p" then
    scene:pause()   
  end
  if key == "k" then
  end
  if key == "+" then
    zoom = 2
  end
  if key == "-" then
    zoom = 1
  end
end

return scene
