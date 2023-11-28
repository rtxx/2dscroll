-- idea from https://libreddit.kavin.rocks/r/love2d/comments/11crfva/how_to_use_gui_libraries/
-- main menu scene
local scene = {}
scene.name = "mainMenu"

-- menu entries for this scene
scene.menuEntries = {}
local pressedButton = nil -- store the button so we don't have to loop on mouseRelease


function scene:load()
  gameVars.currentScene = scene.name
  print(gameVars.scenesDebugText .. "New scene entered: ", scene.name)
  collectgarbage("collect")
  print(gameVars.systemDebugText .. "Garbage collector actived")
  --[[
  sceneIntroTitle = { x = 50, y = 50, alpha = 1, str = scene.name }                                                                                             
    
  flux.to(sceneIntroTitle, 2, { alpha = 1 })
      :ease("quadinout")
      :after(sceneIntroTitle, 2, { alpha = 0 })
      :ease("quadout")
  --]]
  if gameVars.currentPlayer ~= nil then
    gameVars.currentPlayer.isActive = false
  end
  --player.active = false
  if #scene.menuEntries == 0 then
    local newGameMenu = function () 
      scene.setScene("lvl0")
    end

    local loadGameMenu = function () 
      print("load game menu") 
    end

    local optionsMenu = function () 
      scene.setScene("optionsMenu")
    end

    local exitGame = function () 
      love.event.quit()
    end
    
    -- menu,x,y,w,h,text,function
    newMenuEntry(scene.menuEntries,(gameVars.windowSizeW / 2) - 200, (gameVars.windowSizeH / 2) + 10, 200, 20, "new game", newGameMenu)
    newMenuEntry(scene.menuEntries,(gameVars.windowSizeW / 2) - 200, (gameVars.windowSizeH / 2) + 40, 200, 20, "load game", loadGameMenu)
    newMenuEntry(scene.menuEntries,(gameVars.windowSizeW / 2) - 200, (gameVars.windowSizeH / 2) + 70, 200, 20, "options", optionsMenu)
    newMenuEntry(scene.menuEntries,(gameVars.windowSizeW / 2) - 200, (gameVars.windowSizeH / 2) + 100, 200, 20, "exit", exitGame)
  end
end

function scene:update(dt)
  updateMenuEntries(scene.menuEntries)
end

function scene:draw()
  drawMenuEntries(scene.menuEntries)
end

function scene:pause()
end

function scene:mousepressed(mx,my,mouseButton)
  --local mx, my = screen.toGame(mx,my)
  if mouseButton ~= 1 then return end
  for i, button in ipairs(scene.menuEntries) do
    if isMouseOnButton(button, mx, my) then
      button.state = "pressed"
      pressedButton = button -- store the button so we don't have to loop on mouseRelease
    end
  end
end

function scene:mousereleased(mx,my,mouseButton)
  --mx, my = screen.toGame(mx,my)
  if pressedButton ~= nil and isMouseOnButton(pressedButton, mx, my) then
    pressedButton.state = "idle"
    pressedButton.fn()
    pressedButton = nil
  else
    pressedButton = nil
  end
end

function scene:keypressed(key, scancode, isrepeat)
  if key == "escape" then
    love.event.quit()
  end
  if key == "1" then
    scene.setScene("lvl0")
  end
  if key == "2" then
    --scene.setScene("loadgame")
    print(gameVars.scenesDebugText .. "Load game menu")
  end
  if key == "3" then
    scene.setScene("optionsMenu")
  end
  if key == "4" then
    love.event.quit()
  end
end

-- these functions are reutilized on the other scenes
function newMenuEntry(menu, x, y, width, height, text, fn)
  table.insert(menu, {
                      x = x,
                      y = y,
                      width = width,
                      height = height,
                      state = "idle",
                      text = text,
                      fn = fn
                  }
              )
end

function isMouseOnButton(button, mx, my)
  if button.x <= mx and button.x + button.width >= mx and button.y <= my and button.y + button.height >= my then
    return true
  else
    return false
  end
end

function drawMenuEntries(menu)
  for _, button in ipairs(menu) do
    if button.state == "hover" then
      love.graphics.setColor(1,0,0)
      love.graphics.setColor(gameVars.colors[2].r /255,gameVars.colors[2].g /255,gameVars.colors[2].b /255)
    elseif button.state == "pressed" then
      --love.graphics.setColor(0,1,0)
      love.graphics.setColor(gameVars.colors[1].r /255,gameVars.colors[1].g /255,gameVars.colors[1].b /255)
    else
      love.graphics.setColor(1,1,1)
    end
    love.graphics.rectangle("line", button.x, button.y, button.width, button.height)
    love.graphics.print(button.text, button.x, button.y)
  end
end

function updateMenuEntries(menu)
  --local gmx, gmy = love.mouse.getPosition()
  --local mx, my = screen.toGame(gmx,gmy)
  local mx, my = love.mouse.getPosition()
  
  for _, button in ipairs(menu) do
    if isMouseOnButton(button, mx, my) and button.state ~= "pressed" then
      button.state = "hover"
    elseif not isMouseOnButton(button, mx, my) then
      button.state = "idle"
    end
  end
end

return scene
