require('bomb')
require('camera')
local dfX, dfY = 0, 0
local dfWidth, dfHeight = DFSIZE, DFSIZE * 2
local dfSpeed = 70

local workSprites = require('bombermanSprites')
local spriteTimer = 0
local spriteIndex = 0
local spriteIndexMax = 7

local collisionElements = {}
local collisionMargin = 12
local yMargin = 10

local maxBombs = 3
local canBombTimerMax = 0.2

Player = {}
Player.__index = Player

local function new(x, y)
  o = {
      x = x or dfX,
      y = (y or dfY) - collisionMargin,
      width = width or dfWidth,
      height = height or dfHeight,
      speed = speed or dfSpeed,
      walkDirection = 'down',
      maxBombs = maxBombs,
      bombs = {},
      canBomb = true,
      canBombTimer = 0
    }
  camera:newLayer(8, function()
    for _, bomb in ipairs(o.bombs) do
      bomb:draw()
    end
  end)
  return setmetatable(
    o,
    Player)
end

local function setTimer(dt)
  spriteTimer=spriteTimer+dt
  if spriteTimer > 0.1 then
    spriteTimer = 0
    spriteIndex = spriteIndex + 1
    if spriteIndex > spriteIndexMax then
      spriteIndex = 0
    end
  end
end

local function setCanBombTimer(self, dt)
  self.canBombTimer = self.canBombTimer - (1 * dt)
  if self.canBombTimer < 0 then
    self.canBomb = true
  end
end

local function checkCollision(x1,y1,w1,h1, x2,y2,w2,h2)
  local result =  x1 < x2+w2 and
         x2 < x1+w1 and
         y1 < y2+h2 and
         y2 < y1+h1
  -- if result then print(x1 .. ':' .. y1 .. ':' .. x2 .. ':' .. y2) end
  return result
end

local function hit(self)
  if #collisionElements == 0 then return nil end
  for _, elementGroup in ipairs(collisionElements) do
    for _, element in ipairs(elementGroup.elements) do
      if checkCollision(math.floor(self.x + collisionMargin),
                        math.floor(self.y + yMargin + collisionMargin) + dfWidth,
                        self.width - collisionMargin,
                        self.height - collisionMargin - dfWidth,
        element.x, element.y, element.width, element.height) then
        elementGroup.callback(self)
        return true
      end
    end
  end
end

local function setBombPosition(self)
  local blockX = math.floor((self.x + (DFSIZE/2)) / DFSIZE)
  local blockY = math.floor((self:actualY() + (DFSIZE/2)) / DFSIZE)
  return blockX * DFSIZE, blockY * DFSIZE
end

function Player:actualY()
  return self.y + dfWidth
end

function Player:addCheckingCollision(elements, callback)
  table.insert(collisionElements, { elements=elements, callback=callback})
end

function Player:update(dt)
  self.prevX, self.prevY = self.x, self.y
  if love.keyboard.isDown('left') then
    self.x = self.x - self.speed * dt
    self.walkDirection = 'left'
  elseif love.keyboard.isDown('right') then
    self.x = self.x + self.speed * dt
    self.walkDirection = 'right'
  elseif love.keyboard.isDown('up') then
    self.y = self.y - self.speed * dt
    self.walkDirection = 'up'
  elseif love.keyboard.isDown('down') then
    self.y = self.y + self.speed * dt
    self.walkDirection = 'down'
  end


  setCanBombTimer(self, dt)

  if love.keyboard.isDown(' ') then -- spacebar
    if (#self.bombs < self.maxBombs) and self.canBomb then
      x, y = setBombPosition(self)
      table.insert(self.bombs, Bomb(x, y))
      self.canBomb = false
      self.canBombTimer = canBombTimerMax
    end
  end

  if love.keyboard.isDown('left', 'right', 'up', 'down') then
    hit(self)
    setTimer(dt)
  end

  for _, bomb in ipairs(self.bombs) do
    bomb:update(dt)
    -- if bomb:exploded() then
    --   table.remove(bomb, _)
    -- end
  end
end

function Player:draw()
  if(self.walkDirection == 'left') then
    love.graphics.draw(workSprites['right'][spriteIndex], self.x, self.y, 0, -1, 1, self.width)
  else
    love.graphics.draw(workSprites[self.walkDirection][spriteIndex], self.x, self.y)
  end
end

function Player:resetPosition()
  self.x = self.prevX
  self.y = self.prevY
end

setmetatable(Player, { __call = function(_, ...) return new(...) end })

