local Enemy = require("src/entities/enemy")
local Dumga = class('Dumga', Enemy) -- inherits Entity class

--[[
  dumga is a simple enemy and very dumb. he only goes left and right and changes direction if he
  hits another entity
]]--
function Dumga:initialize(world, x, y, w, h)
  Enemy.initialize(self,world,x,y,w,h)
  self.name         = "dumga-boy"
  self.type         = "dumga"

  self.hp           = 1
  self.accx         = 250 -- accelaration X
  self.maxSpeed     = 50 -- enemy max horizontal speed
  self.xDirection   = 1 -- 1 is left, -1 is right

  self.isActive     = true
  self.debugMe      = false

  self.sprite           = love.graphics.newImage(enemyAssets.dumga.sprite)
  self.spriteOffsetX    = 3 -- idk why 3 pixels, must investigate
  self.spriteOffsetY    = 3

  self.sounds       = {}
  self.sounds.hit   = love.audio.newSource(enemyAssets.sounds.dumga.hit, "static")
end

function Dumga:collisionFilter(entity)
  local type = entity.type
  if type == 'default' then -- if entity is set to default, then it slides
    return 'slide'
  elseif type == 'wall' then
    return 'slide'
  elseif type == 'dumga' then
    return 'bounce'
  elseif type == 'player' then
    return 'slide'
  end
end

function Dumga:checkIfOnGround(ny)
  if ny == -1 then -- player is colliding on top of other entity
    self.isOnGround = true
  elseif ny == 0 then -- entity is colliding on the side of other entity
    --print(self.name .. " collided on the side of other entity")
  elseif ny == 1 then -- entity is colliding on the bottom ide of other entity
  else
  end
end

function Dumga:checkSidesCollisions(col)
  
  if col.normal.y == -1 then -- entity is colliding on top of other entity
  elseif col.normal.y == 0 then -- entity is colliding on the side of other entity
    if self.x < col.other.x then -- left side
      self.vy = -self.accy
      if col.other.type == "player" then 
        if not col.other.isInvincible then
          col.other.hp = col.other.hp - 1
          col.other.vx, col.other.vy = 250 + col.other.vx, -150 + col.other.vy
          col.other.isInvincible = true
          col.other.timeSinceLastHit = os.time()
        end
      end
    else -- right side
      self.vy = -self.accy
      if col.other.type == "player" then 
        if not col.other.isInvincible then
          col.other.hp = col.other.hp - 1
          col.other.vx, col.other.vy = -250 + col.other.vx,-150 + col.other.vy
          col.other.isInvincible = true
          col.other.timeSinceLastHit = os.time()
        end
      end
    end
    if self.xDirection == 1 then
      self.xDirection = -1
    else
      self.xDirection = 1
    end   
  elseif col.normal.y == 1 then -- entity is colliding on the bottom ide of other entity
  else
  end
end

function Dumga:controls(dt)
  self.vx = self.vx - dt * (self.vx > 0 and self.friction or self.accx) * self.xDirection
end

function Dumga:checkHealth()
  if self.hp <= 0 then
    print(gameVars.bumpDebugText .. "'".. self.name .. "'" .. "is dead, removing from world.")
    self.isActive = false
    self:destroy()
  end
end

function Dumga:update(dt)
  if self.world:hasItem(self) and self.isActive then
    self:controls(dt)
    self:applyGravity(dt)
    self.isOnGround = false

    -- Cap the enemy speed
    if self.vx > self.maxSpeed then
      self.vx = self.maxSpeed
    elseif self.vx < -self.maxSpeed then
      self.vx = -self.maxSpeed
    end

    -- Set enemy goal coordinates, which is current x,y and adds velocity
    local goalX = self.x + self.vx * dt
    local goalY = self.y + self.vy * dt
    
    local actualX, actualY, collisions, len
    actualX, actualY, collisions, len = self.world:check(self, goalX, goalY, self.collisionFilter)

    -- moves the enemy  in the bump world
    actualX, actualY, collisions, len = self.world:move(self, goalX, goalY, self.collisionFilter)

    -- deals with collisions
    for i=1, len do
      bounciness = 0
      local col = collisions[i]
      self:changeVelocityByCollisionNormal(col.normal.x, col.normal.y, bounciness)
      self:checkIfOnGround(col.normal.y)
      self:checkSidesCollisions(col)
    end

    -- Updates players position with the actual x and y, wich is the position after the collisions
    self.x, self.y = actualX, actualY
    self:checkHealth()
  end
end

function Dumga:draw()
  if self.world:hasItem(self) and self.isActive then
    if self.debugMe then self:debug(self) end
    love.graphics.draw(self.sprite, self.x-self.spriteOffsetX, self.y-self.spriteOffsetY)
  end
end

return Dumga