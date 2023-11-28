-- Represents a single drawable object
-- All objects inside the world (bump) are an Entity class. (the player, the platforms, the enemies, projectiles, etc...)
-- Everything that can be drawn to the screen (except the map and ui) is an Entity class.
local Entity = class('Entity')

--[[ 
Entity:initialize(world, x, y, w, h) -> loads a entity into the world (bump)
  world -> world from bump where the map is going to be
  x     -> x position of the entity
  y     -> y position of the entity
  h     -> height of the entity
  w     -> width of the entity
  [NOTE] EVERY entity is a rectangle. It's not ideal, but is for simplicity and because bump doesn't support poligons.
    self.world, ...  -> Stores the world,x,y,w,h of the new entity
    self.name        -> default name
    self.type        -> entity type. useful for bump filters. by default its default, wich in turn, its the slide collision in bump
    self.gravity     -> arbitrary gravity number. every entity has a gravity value, 16 its what 'fells right'.
    self.vx,vy       -> velocity values for the entity, main variables for movement.
    self.accx,accy   -> accelaration values for entity, the higher the value, the more acc you get (duh)
    self.friction    -> friction value, the higher the value, the harder is for the entity to move, and faster to stop
    self.world:add() -> adds the entity to the bump world, with all our values set and ready to go
]]--
function Entity:initialize(world, x, y, w, h)
  self.world, self.x, self.y, self.w, self.h = world, x, y, w, h
  self.name     = "default-entity-name"
  self.type     = "default" -- type is for bump and collision detection
  self.gravity  = 1000
  self.debugMe  = false
  
  self.world:add(self,x,y,w,h) -- add entity to the world
end

-- Get position of entity
function Entity:getPos()
  return self.x, self.y
end

-- Set position of entity
function Entity:setPos(x,y)
  self.x, self.y = x, y
end

-- Set width and height of entity
function Entity:setWH(w,h)
  self.w, self.h = w, h
end

-- Get rectangle data of entity
function Entity:getRect()
  return self.x, self.y, self.w, self.h
end

-- Get center of entity
function Entity:getCenter()
  return self.x + self.w / 2,
         self.y + self.h / 2
end

-- Set position of entity
function Entity:setVel(x,y)
  self.vx, self.vy = x,y
end

function Entity:applyGravity(dt)
  self.vy = self.vy + self.gravity * dt
end

-- from bump.lua demo
function Entity:changeVelocityByCollisionNormal(nx, ny, bounciness)
  bounciness = bounciness or 0
  local vx, vy = self.vx, self.vy

  if (nx < 0 and vx > 0) or (nx > 0 and vx < 0) then
    vx = -vx * bounciness
  end

  if (ny < 0 and vy > 0) or (ny > 0 and vy < 0) then
    vy = -vy * bounciness
  end

  self.vx, self.vy = vx, vy
end

-- Remove entity from world
function Entity:destroy()
  self.world:remove(self)
end

function Entity:update(dt) 
end

function Entity:draw()
  if self.debugMe then self:debug(self) end  -- Draws debug messages and on-screen text
end

function Entity:debug(e)
  if e.type == "player" then
  love.graphics.printf(e.name .."\n"
                    .. "hp " .. e.hp .. "\n"
                    , e.x, e.y+16,128,"left") 
                    
  elseif e.type == "enemy" then
  love.graphics.printf(e.name .."\n"
                    .. e.type .."\n"
                    .. "hp " .. e.hp .. "\n"
                    , e.x, e.y+16,128,"left") 
  else
  -- Prints name, x, y of all entities
  love.graphics.printf(e.name .."\n"
                    .. e.type .."\n"
                    .. "x " .. e.x .. "\n"
                    .. "y " .. e.y .. "\n"
                    , e.x, e.y+16,128,"left")
  end     
    
  -- prints rectangle over entities
  love.graphics.rectangle("line", e.x, e.y, e.w, e.h )
end

return Entity
