local Entity = require("src/entities/entity")
local Enemy = class('Enemy', Entity) -- inherits Entity class

--[[ 
Enemy:initialize(world, x, y, w, h) -> loads a enemy into the world (bump)
  world -> world from bump where the map is going to be
  x     -> x position of the entity
  y     -> y position of the entity
  h     -> height of the entity
  w     -> width of the entity
  [NOTE] EVERY entity is a rectangle. It's not ideal, but is for simplicity and because bump doesn't support poligons (I think).
    Entity.initialize ...  -> adds enemy entity to the world
    self.name        -> player name
    self.type        -> entity type. useful for bump filters.
    self.gravity     -> arbitrary gravity number. every entity has a gravity value, 1000 its what 'fells right'.
    self.vx,vy       -> velocity values for the entity, main variables for movement.
    self.accx,accy   -> accelaration values for entity, the higher the value, the more acc you get (duh)
    self.friction    -> friction value, the higher the value, the harder is for the entity to move, and faster to stop
    self.maxSpeed    -> max horizontal (x) value

]]--
function Enemy:initialize(world, x, y, w, h)
  Entity.initialize(self,world,x,y,w,h)
  self.name         = "default-badboy"
  self.type         = "enemy"
  self.gravity      = 1000
  self.vx           = 0 -- velocity x
  self.vy           = 0 -- velocity y
  self.accx         = 1000 -- accelaration X
  self.accy         = 250 -- accelaration Y
  self.friction     = 2500
  self.isOnGround   = false -- check if the enemy  is on the ground or on top of another entity
  self.maxSpeed     = 300 -- enemy max horizontal speed
  self.hp           = 3
  self.isActive     = false
  self.debugMe      = true
 
end

function Enemy:draw() 
  if self.debugMe then self:debug(self) end  -- Draws debug messages and on-screen text
end

return Enemy
