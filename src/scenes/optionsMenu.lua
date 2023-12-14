-- options menu scene
local scene = {}
scene.name = "optionsMenu"

-- menu entries for this scene
scene.menuEntries = {}

function scene:load()
  gameVars.currentScene = scene.name
  print(gameVars.scenesDebugText .. "New scene entered: ", scene.name)
  
  local w, h = 500, 100
  local x = math.floor((gameVars.windowSizeW - w) / 2)
  local y = math.floor((gameVars.windowSizeH - h) / 2)

  ui = yui.Ui:new {
      x = x, y = y,

      yui.Rows {
          yui.Label {
              w = w, h = h / 2,
              text = "options"
          },
          yui.Spacer,
          yui.Button {
              text = "back",
              onHit = function() scene.setScene("mainMenu") end
          }
      }
  }
  
end

function scene:update(dt)
  ui:update(dt)
end

function scene:draw()
  love.graphics.setFont(menuFont)
  ui:draw()
end

function scene:pause()
end

function scene:mousepressed(mx,my,mouseButton)
end

function scene:mousereleased(mx,my,mouseButton)
end

function scene:keypressed(key, scancode, isrepeat)
  if key == "escape" then
    scene.setScene("mainMenu")
  end
end

return scene