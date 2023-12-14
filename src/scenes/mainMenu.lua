-- idea from https://libreddit.kavin.rocks/r/love2d/comments/11crfva/how_to_use_gui_libraries/
-- main menu scene
local scene = {}
scene.name = "mainMenu"


function scene:load()
  gameVars.currentScene = scene.name
  print(gameVars.scenesDebugText .. "New scene entered: ", scene.name)
  collectgarbage("collect")
  print(gameVars.systemDebugText .. "Garbage collector actived")

  if gameVars.currentPlayer ~= nil then
    gameVars.currentPlayer.isActive = false
  end
  
  local w, h = 500, 100
  local x = math.floor((gameVars.windowSizeW - w) / 2)
  local y = math.floor((gameVars.windowSizeH - h) / 2)
  ui = yui.Ui:new {
      x = x, y = y,

      yui.Rows {
          yui.Label {
              w = w, h = h / 2,
              text = gameVars.name
          },
          yui.Label {
              w = w, h = h / 2,
              text = gameVars.version
          },
          yui.Spacer,
          yui.Button {
              text = "start",
              onHit = function() scene.setScene("lvl0") end
          },
          yui.Button {
              text = "options",
              onHit = function() scene.setScene("optionsMenu") end
          },
          yui.Button {
              text = "exit",
              onHit = function() love.event.quit() end
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
    love.event.quit()
  end
end

return scene
