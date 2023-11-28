function drawMenus()
  if string.find(gameVars.ignoreDebugTextOnScene, gameVars.currentScene) then
    scenes:draw()
  end

end

function drawAll()
  drawMenus()
  scenes:draw()
  --if not string.find(gameVars.ignoreDebugTextOnScene, gameVars.currentScene) then
    --screen.start()
  --    scenes:draw()
  --  --screen.finish()
  --end  
end
