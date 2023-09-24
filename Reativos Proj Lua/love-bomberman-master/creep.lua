local dfX, dfY = 0, 0
local dfWidth, dfHeight = DFSIZE, DFSIZE
local dfSpeed = 60

local workSprites = require('creepSprites')
local spriteTimer = 0
local spriteIndex = 0
local spriteIndexMax = 5

local collisionElements = {}
local collisionMargin = 0

local directions = { 'left', 'right', 'up', 'down' }

Creep = {}
Creep.__index = Creep

local function new(x, y)
  return setmetatable(
    {
      x = x or dfX,
      y = (y or dfY) - collisionMargin,
      width = width or dfWidth,
      height = height or dfHeight,
      speed = speed or dfSpeed,
      walkDirection = directions[math.random(#directions)]
    },
    Creep)
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
                        math.floor(self.y + collisionMargin),
                        self.width - collisionMargin,
                        self.height - collisionMargin,
        element.x, element.y, element.width, element.height) then
          elementGroup.callback(self)
        return true
      end
    end
  end
end

local function decideWalk(self)
  local position = 0
  if self.walkDirection == 'right' or self.walkDirection == 'left' then
    position = self.x
  elseif self.walkDirection == 'up' or self.walkDirection == 'down' then
    position = self.y
  end

  if math.floor(position) % DFSIZE == 0 then
    self.walkDirection = directions[math.random(#directions)]
  end
end

function Creep:addCheckingCollision(elements, callback)
  table.insert(collisionElements, { elements=elements, callback=callback})
end

function Creep:update(dt)
  decideWalk(self)
  self.prevX, self.prevY = self.x, self.y
  if self.walkDirection =='left' then
    self.x = self.x - self.speed * dt
  elseif self.walkDirection =='right' then
    self.x = self.x + self.speed * dt
  elseif self.walkDirection == 'up' then
    self.y = self.y - self.speed * dt
  elseif self.walkDirection == 'down' then
    self.y = self.y + self.speed * dt
  end

  if self.walkDirection =='left' or
     self.walkDirection =='right' or
     self.walkDirection == 'up' or
     self.walkDirection == 'down' then
    hit(self)
    setTimer(dt)
  end
end

function Creep:draw()
  if(self.walkDirection == 'left') then
    love.graphics.draw(workSprites['right'][spriteIndex], self.x, self.y, 0, -1, 1, self.width)
  else
    love.graphics.draw(workSprites[self.walkDirection][spriteIndex], self.x, self.y)
  end
end

function Creep:resetPosition()
  self.x = self.prevX
  self.y = self.prevY
  decideWalk(self)
end

setmetatable(Creep, { __call = function(_, ...) return new(...) end })

