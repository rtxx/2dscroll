function drawMenus()
  if string.find(gameVars.ignoreDebugTextOnScene, gameVars.currentScene) then
    scenes:draw()
  end
end

function drawAll()
  drawMenus()
  scenes:draw()

  -- resets to default font after draw scenes 
  love.graphics.setFont(defaultFont)
end
