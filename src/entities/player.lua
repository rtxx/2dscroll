local Entity = require("src/entities/entity")
local Player = class('Player', Entity) -- inherits Entity class

--[[ 
Player:initialize(world, x, y, w, h) -> loads a player into the world (bump)
  world -> world from bump where the map is going to be
  x     -> x position of the entity
  y     -> y position of the entity
  h     -> height of the entity
  w     -> width of the entity
  [NOTE] EVERY entity is a rectangle. It's not ideal, but is for simplicity and because bump doesn't support poligons (I think).
    Entity.initialize ...  -> adds player entity to the world
    self.name        -> player name
    self.type        -> entity type. useful for bump filters.
    self.gravity     -> arbitrary gravity number. every entity has a gravity value, 1000 its what 'fells right'.
    self.vx,vy       -> velocity values for the entity, main variables for movement.
    self.accx,accy   -> accelaration values for entity, the higher the value, the more acc you get (duh)
    self.friction    -> friction value, the higher the value, the harder is for the entity to move, and faster to stop
    self.maxSpeed    -> max horizontal (x) value
    self.jumpAcc     -> max vertical (y) value for jump 
    self.jumpKey     -> 'flag' to limit the player to only 1 jump, ie we cannot spam the jump key while isJumping is true

]]--
function Player:initialize(world, x, y, w, h)
  Entity.initialize(self,world,x,y,w,h)
  self.name         = "tux"
  self.type         = "player"
  self.gravity      = 1000
  self.vx           = 0 -- velocity x
  self.vy           = 0 -- velocity y
  self.accx         = 950 -- accelaration X
  self.accy         = 250 -- accelaration Y

  self.friction     = 2000
  self.isOnGround   = false -- check if the player is on the ground or on top of another entity
  self.maxSpeed     = 250 -- player max horizontal speed

  self.jumpAcc      = 350 -- player jump heigth
  self.nJumps       = 2 -- only allows jump key to work n times
  self.jumpKey      = self.nJumps 
  self.isJumping    = false

  self.hp           = 3

  self.isInvincible               = false
  self.invincibleDuration         = 3 -- in seconds
  self.currentInvincibleDuration  = 0
  self.timeSinceLastHit           = 0

  self.deadTime     = 5
  self.isActive     = false
  self.debugMe      = false

  self.spriteSheet  = love.graphics.newImage(playerAssets.spriteSheet)
  self.grid         = anim.newGrid( 12, 18, self.spriteSheet:getWidth(), self.spriteSheet:getHeight()) 
  self.animations       = {}
  self.animations.down  = anim.newAnimation( self.grid('1-4', 1), 0.2 )
  self.animations.left  = anim.newAnimation( self.grid('1-4', 2), 0.2 )
  self.animations.right = anim.newAnimation( self.grid('1-4', 3), 0.2 )
  self.animations.up    = anim.newAnimation( self.grid('1-4', 4), 0.2 )
  self.spriteOffsetX    = 3 -- idk why 3 pixels, must investigate
  self.spriteOffsetY    = 0
  self.anim             = self.animations.right -- default anim
  
  self.sounds       = {}
  self.sounds.hit   = love.audio.newSource(playerAssets.sounds.hit, "static")
  self.sounds.jump  = love.audio.newSource(playerAssets.sounds.jump, "static")
end

function Player:collisionFilter(entity)
  local type = entity.type
  if type == 'default' then -- if entity is set to default, then it slides
    return 'slide'
  elseif type == 'wall' then
    return 'slide'
  elseif type == 'enemy' then
    return 'slide'
  elseif type == 'dumga' then
    return 'slide'
  end
end

-- keyboard
function Player:keypressed(key, scancode, isrepeat)
  if key == "up" or key == "w" or key == "space" then
    if self.isJumping then
      self.jumpKey = self.jumpKey - 1
      if self.jumpKey > 0 then -- checks for double or more jumps
        self.vy = round(-self.jumpAcc)
        self.sounds.jump:play()
      end
    end
  end
end

function Player:keyreleased(key, scancode, isrepeat)
  -- if we release jump key then we set velocity y to some number and flags player with isJumping = false
  if key == "up" or key == "w" or key == "space" then
    if self.isJumping and self.jumpKey >= 0 then
      -- 0.5 so it won't feel 'jerky' on the way down
      self.vy = round((-self.vy * 0.5) * love.timer.getDelta())
    end
  end
end

-- joystick
function Player:gamepadpressed(joystick, button)
  if button == "a" then
    if self.isJumping then
      self.jumpKey = self.jumpKey - 1
      if self.jumpKey > 0 then -- checks for double or more jumps
        self.vy = round(-self.jumpAcc)
        self.sounds.jump:play()
      end
    end
  end
end

function Player:gamepadreleased(joystick, button)
  -- if we release jump key then we set velocity y to some number and flags player with isJumping = false
  if button == "a" then
    if self.isJumping and self.jumpKey > 0 then
      -- 0.5 so it won't feel 'jerky' on the way down
      self.vy = round((-self.vy * 0.5) * love.timer.getDelta())
    end
  end
end

function Player:controls(dt)
  -- joystick
  -- check if controller is plugged in
  if gameVars.controller ~= nil then 
    if gameVars.controller:isGamepadDown("a") then
      if not self.isJumping and self.jumpKey >= 0 then
        self.vy = round(-self.jumpAcc)
        self.isJumping = true
        self.anim = self.animations.up
        self.sounds.jump:play()
      end
    end 
    if gameVars.controller:isGamepadDown("dpright") then
      self.anim = self.animations.right
      if self.isOnGround then
        -- vx is equal to current vx value + delta time * ( if vx < 0 then multiplies friction else multiplies accx)
        self.vx = self.vx + dt * (self.vx < 0 and self.friction or self.accx)
        print(self.vx)
      else
        -- decreases mobility while on the air
        self.vx = self.vx + dt * (self.vx < 0 and self.friction * 0.25 or self.accx * 0.5)
      end
    elseif gameVars.controller:isGamepadDown("dpleft") then
      self.anim = self.animations.left
      if self.isOnGround then
        self.vx = self.vx - dt * (self.vx > 0 and self.friction or self.accx)
      else
        -- decreases mobility while on the air
        self.vx = self.vx - dt * (self.vx > 0 and self.friction * 0.25 or self.accx * 0.5)
      end
    else -- if player is not pressing movement keys; applies friction to player
      local brake = dt * (self.vx < 0 and self.friction or -self.friction)
      if math.abs(brake) > math.abs(self.vx) then
        self.vx = 0
      else
        self.vx = self.vx + brake
      end
    end
  else
    -- keyboard 
    if love.keyboard.isDown("up") or love.keyboard.isDown("space") then
      if not self.isJumping and self.jumpKey >= 0 then
        self.vy = round(-self.jumpAcc)
        self.isJumping = true
        self.anim = self.animations.up
        self.sounds.jump:play()
      end
    end 
    if love.keyboard.isDown("right") or love.keyboard.isDown("d") then
      self.anim = self.animations.right
      if self.isOnGround then
        -- vx is equal to current vx value + delta time * ( if vx < 0 then multiplies friction else multiplies accx)
        self.vx = self.vx + dt * (self.vx < 0 and self.friction or self.accx)
      else
        -- decreases mobility while on the air
        self.vx = self.vx + dt * (self.vx < 0 and self.friction * 0.25 or self.accx * 0.5)
      end
    elseif love.keyboard.isDown("left") or love.keyboard.isDown("a") then
      self.anim = self.animations.left
      if self.isOnGround then
        self.vx = self.vx - dt * (self.vx > 0 and self.friction or self.accx)
      else
        -- decreases mobility while on the air
        self.vx = self.vx - dt * (self.vx > 0 and self.friction * 0.25 or self.accx * 0.5)
      end
    else -- if player is not pressing movement keys; applies friction to player
      local brake = dt * (self.vx < 0 and self.friction or -self.friction)
      if math.abs(brake) > math.abs(self.vx) then
        self.vx = 0
      else
        self.vx = self.vx + brake
      end
    end
  end
end

function Player:checkIfOnGround(ny)
  if ny == -1 then -- player is colliding on top of other entity
    self.isOnGround = true
    self.isJumping = false
    self.jumpKey = self.nJumps
    self.sounds.jump:stop()
    self.sounds.hit:stop()
  elseif ny == 0 then -- player is colliding on the side of other entity
    --print(self.name .. " collided on the side of other entity")
  elseif ny == 1 then -- player is colliding on the bottom ide of other entity
  else
  end
end

function Player:checkSidesCollisions(col)
  if col.normal.y == -1 then -- player is colliding on top of other entity
    if col.other.type == "dumga" then self:collisionWithDumga(col.other,"top") end
  elseif col.normal.y == 0 then -- player is colliding on the side of other entity
    if self.x < col.other.x then -- left side
      if col.other.type == "dumga" then self:collisionWithDumga(col.other,"left") end
    else -- right side
      if col.other.type == "dumga" then self:collisionWithDumga(col.other,"right") end
    end
  elseif col.normal.y == 1 then -- player is colliding on the bottom ide of other entity
  else
  end
end

function Player:collisionWithDumga(dumga,side)
  if side == "top" then
    self.sounds.hit:play()
    self.vy = round(-self.jumpAcc * 0.75)
    print(gameVars.bumpDebugText .. "'".. dumga.name .. "' [hp: " .. dumga.hp .."] was hit by '" .. self.name .. "' [hp: " .. self.hp .. "]. '")
    dumga.hp = dumga.hp  - 1
  elseif side == "left" then
    if not self.isInvincible then
      print(gameVars.bumpDebugText .. "'".. dumga.name .. "' [hp: " .. dumga.hp .."] was hit by '" .. self.name .. "' [hp: " .. self.hp .. "]. '")
      self.hp = self.hp  - 1
      self.sounds.hit:stop()
      self.sounds.hit:play()
      self.isInvincible = true
      self.timeSinceLastHit = os.time()
    end
  elseif side == "right" then
    if not self.isInvincible then
      print(gameVars.bumpDebugText .. "'".. dumga.name .. "' [hp: " .. dumga.hp .."] was hit by '" .. self.name .. "' [hp: " .. self.hp .. "]. '")
      self.hp = self.hp  - 1
      self.sounds.hit:stop()
      self.sounds.hit:play()
      self.isInvincible = true
      self.timeSinceLastHit = os.time()
    end
  else -- "bottom"
  end
end

function Player:checkHealth(dt)
  if self.hp <= 0 then
    gameVars.gameover.active = true
    gameVars.gameover.reason = "player hp < 0"
    self.deadTime = self.deadTime - dt
    if self.deadTime < 0 then
      print(gameVars.bumpDebugText .. "'".. self.name .. "'" .. "is dead, removing from world.")
      self.isActive = false
      self.isInvincible = false
      self:destroy()
    end
  end
end

--[[
Player:setInvincible() -> Sets the player invicible for a period of time (seconds)
every time the player gets a hit, it receives a grace period where if he gets it again, it does NOT count.
for that, we get the last time the player get hit, then does the following comparison:
if the current os time is equal to the last hit time + the duration of the invicibility then we know the invicibility has passed
we can get the current inviciblity by doing the following: get the some between the last hit time + the current invicibility duration minus the current os time.
]]-- 
function Player:setInvincible()
  self.currentInvincibleDuration = (self.timeSinceLastHit + self.currentInvincibleDuration) - os.time()
  if os.time() == (self.timeSinceLastHit + self.invincibleDuration) then
    self.debugMe = false
    self.isInvincible = false
    self.currentInvincibleDuration = 0
    print(gameVars.systemDebugText .. "'"..self.name .. "' is no longer invicible")
  end
  return
end

function Player:update(dt)
  if self.world:hasItem(self) and self.isActive then 
    self:applyGravity(dt)

    if self.isInvincible then
      self:setInvincible()
    end

    if not gameVars.gameover.active then
      self:controls(dt)
    end
    self.isOnGround = false

    -- Cap the player speed
    if self.vx > self.maxSpeed then
      self.vx = self.maxSpeed
    elseif self.vx < -self.maxSpeed then
      self.vx = -self.maxSpeed
    end

    -- Set player goal coordinates, which is current x,y and adds velocity
    local goalX = self.x + self.vx * dt
    local goalY = self.y + self.vy * dt

    local actualX, actualY, collisions, len
  	actualX, actualY, collisions, len = self.world:check(self, goalX, goalY, self.collisionFilter)

    -- moves the player in the bump world
    actualX, actualY, collisions, len = self.world:move(self, goalX, goalY, self.collisionFilter)

    -- deals with collisions
    for i=1, len do
      local col = collisions[i]
      self:changeVelocityByCollisionNormal(col.normal.x, col.normal.y, bounciness)
      self:checkIfOnGround(col.normal.y)
      self:checkSidesCollisions(col)
    end

    -- Updates players position with the actual x and y, wich is the position after the collisions
  	self.x, self.y = actualX, actualY

    -- this tries to fix the weird black lines from STI and Tiled when moving the player
  	-- 'floors' the movement values ie (3.1 is 3 and -1.2 is -2), so it matchs the textures from Tiled (atleast that's what I understand)
  	self.x, self.y = round(self.x), round(self.y)
    if self.vx == 0 then
      self.anim:gotoFrame(2)
    end
    self.anim:update(dt) 
  end

  self:checkHealth(dt)
end

function Player:draw() 
  if self.debugMe then self:debug(self) end  -- Draws debug messages and on-screen text
  if not self.isInvincible then
    self.anim:draw(self.spriteSheet, self.x-self.spriteOffsetX, self.y-self.spriteOffsetY, nil, 2)
  else

    love.graphics.setColor(1,1,1,0.1 + math.abs(gameVars.currentPlayer.currentInvincibleDuration) / (gameVars.currentPlayer.invincibleDuration *100))
    self.anim:draw(self.spriteSheet, self.x-self.spriteOffsetX, self.y-self.spriteOffsetY, nil, 2)
    love.graphics.setColor(1,1,1,1)
  end
end

--https://stackoverflow.com/a/58411671 
function round(num)
  return num + (2^52 + 2^51) - (2^52 + 2^51)
end

return Player
