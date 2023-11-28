local Entity    = require("src/entities/entity")
local Map       = class('Map')

--[[ 
Map:init(mapPath,world) -> loads a map to the world (bump).
  mapPath -> path from system and world.
  world   -> world from bump where the map is going to be
   self.path is the location of the map
   self.data is probably the most important. it's where the data from STI is stored
   [NOTE] to be more straightfoward 'self.data' is set to 'map' in all the functions, so instead of self.data.objects, we can do map.objects 
--]]
function Map:initialize(mapPath,world)
  self.path     = mapPath
  self.world    = world
  self.data     = sti(self.path) -- saves info from STI
end

--[[ 
Map:getPlayer -> gets the player entity from the map. -> Returns player object
  this way we can position the player on a per map map basis and super easy to make adjustments
  loops all the layers and when it founds the 'player' entity, gets its info 
--]]
function Map:getPlayer()
  local playerObj
  local map = self.data
  
  if map.layers["playerSpawn"] then 
    -- Get player spawn object
    for k, obj in pairs(map.layers["playerSpawn"].objects) do
	    if obj.name == "player" then
		    playerObj = obj
		    break
	    end
    end
  end
  if playerObj == 'nill' then
    print("[ERROR] Cannot load 'Player' object! Please check '" .. self.path .. " ' if player object is present. ")
  else
    return playerObj
  end
end

--[[ 
Map:getEnemies() -> 
--]]
function Map:getEnemies()
  local map = self.data
  local enemies = {}
  
  if map.layers["enemySpawn"] then  
    for k, obj in pairs(map.layers["enemySpawn"].objects) do
      local enemy = {}
      enemy.x, enemy.y, enemy.width, enemy.height = obj.x, obj.y, obj.width, obj.height 
      -- if for some reason theres a enemy with no width or heigth then ignores it, otherwise it implodes
      if (enemy.width > 0) and (enemy.height > 0) then
        if obj.properties.type ~= nil then
          if obj.properties.type == "dumga" then
            enemy = Dumga(self.world, enemy.x, enemy.y, enemy.width, enemy.height)
            enemy.name = "dumga[".. tblLen(enemies) .."]"
          end --else if obj.properties.type == "" then
          
        else
          enemy = Enemy(self.world, enemy.x, enemy.y, enemy.width, enemy.height)
          enemy.name = "enemy[".. tblLen(enemies) .."]"
        end
        table.insert(enemies, enemy)
       end
    end
    return enemies
  else
    print("[ERROR] Cannot load layer 'enemySpawn' ! Please check '" .. self.path .. " . ")
  end
end

--[[ 
Map:getWalls() -> gets all the 'wall' entities from the map -> Returns an array with all 'wall' entities
  walls are all entities with collision and NO movement, which means a simple platform is considered a wall
  [NOTE] 'wall' entities MUST be draw and created in Tiled inside a layer named 'walls' 
  loops the layer 'walls' and adds to an array, named 'walls' and creates a entity per each one 'wall'
  if the wall object type is nil, then is defaults to the default ('default'), if not it gets its value from Tiled custom properties 
--]]
function Map:getWalls()
  local map = self.data
  local walls = {}
  
  if map.layers["walls"] then  
    for k, obj in pairs(map.layers["walls"].objects) do
      local wall = {}
      wall.x, wall.y, wall.width, wall.height = obj.x, obj.y, obj.width, obj.height 
      -- if for some reason theres a wall with no width or heigth then ignores it, otherwise it implodes
      if (wall.width > 0) and (wall.height > 0) then
        wall = Entity(self.world, wall.x, wall.y, wall.width, wall.height)
        if obj.properties.type ~= nil then
          wall.type = obj.properties.type
        end
        --wall.name = "wall[".. tblLen(walls) .."]"
        wall.name = "wall"
        table.insert(walls, wall)
       end
    end
    return walls
  else
    print("[ERROR] Cannot load layer 'walls' ! Please check '" .. self.path .. " . ")
  end
end

--[[ THIS FUNCTION UNDER TESTING ]]--
-- layers in Tiled must be a string
function Map:getDrawableLayers()
  local map = self.data
  local layers = {}
  
  for layerName, layerData in pairs(map.layers) do
    if layerData.properties.drawable == true then
      table.insert(layers, layerName)
    end
  end
      
  return layers
end 

--[[ THIS FUNCTION UNDER TESTING ]]--
-- if layers are explicit then it works, if we get them auto from map.layers them it stops working
-- found the issue (probably): apparently the order of the layers matters.
-- possible fix, hardcode all the names of the possible layers and check if they exist before draw them 
function Map:draw()
  local map = self.data
  layers = {"background","ground"}
  --layers = self:getDrawableLayers()
  max = tblLen(layers)  
  for i=1,max,1 do
    map:drawLayer(map.layers[layers[i]])
  end
end

-- helper function: gets total itens from a table
function tblLen(t)
  local n = 0
  for _ in pairs(t) do n = n + 1 end
  return n
end

return Map
