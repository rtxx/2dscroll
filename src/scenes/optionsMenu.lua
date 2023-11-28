-- options menu scene
local scene = {}
scene.name = "optionsMenu"

-- menu entries for this scene
scene.menuEntries = {}
local pressedButton = nil

function scene:load()
  gameVars.currentScene = scene.name
  print(gameVars.scenesDebugText .. "New scene entered: ", scene.name)
  
  if #scene.menuEntries == 0 then
    local resolutionMenu = function () 
      print(gameVars.scenesDebugText .. "resolution") 
    end
    local soundMenu = function ()
          print(gameVars.scenesDebugText .. "sound")
        end
    local backMenu = function () scene.setScene("mainMenu") end

    newMenuEntry(scene.menuEntries, 2, 10, 200, 20, "resolution", resolutionMenu)
    newMenuEntry(scene.menuEntries, 2, 40, 200, 15, "sound", soundMenu)
    newMenuEntry(scene.menuEntries, 2, 70, 200, 15, "back", backMenu)
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
    scene.setScene("mainMenu")
  end
  if key == "1" then
    --scene.setScene("resolution")
    print(gameVars.scenesDebugText .. "resolution")
  end
  if key == "2" then
    --scene.setScene("sound")
    print(gameVars.scenesDebugText .. "sound")
  end
  if key == "3" then
    scene.setScene("mainMenu")
  end

end

return scene