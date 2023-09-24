local dfWidth, dfHeight = DFSIZE, DFSIZE
local margin = 6

local bombSprites = {}
bombSprites[0] = love.graphics.newImage('img/bomb/Bomb_f01.png')
bombSprites[1] = love.graphics.newImage('img/bomb/Bomb_f02.png')
bombSprites[2] = love.graphics.newImage('img/bomb/Bomb_f03.png')

local spriteTimer = 0
local spriteIndexMax = 2

local collisionElements = {}

Bomb = {}
Bomb.__index = Bomb

local function new(x, y)
  return setmetatable(
    {
      x = x,
      y = y,
      stateIndex = 0,
      bombTimer = 0
    },
    Bomb)
end

local function setTimer(self, dt)
  self.bombTimer=self.bombTimer+dt
  if self.bombTimer > 3 then
    self.bombTimer = 0
    if self.stateIndex < spriteIndexMax then
      self.stateIndex = self.stateIndex + 1
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

-- local function hit(self)
--   if #collisionElements == 0 then return nil end
--   for _, elementGroup in ipairs(collisionElements) do
--     for _, element in ipairs(elementGroup.elements) do
--       if checkCollision(math.floor(self.x + collisionMargin),
--                         math.floor(self.y + collisionMargin),
--                         self.width - collisionMargin,
--                         self.height - collisionMargin,
--         element.x, element.y, element.width, element.height) then
--           elementGroup.callback(self)
--         return true
--       end
--     end
--   end
-- end

-- function Creep:addCheckingCollision(elements, callback)
--   table.insert(collisionElements, { elements=elements, callback=callback})
-- end

function Bomb:exploded()
  return self.stateIndex == spriteIndexMax
end

function Bomb:update(dt)
  setTimer(self, dt)
end

function Bomb:draw()
  love.graphics.draw(bombSprites[self.stateIndex], self.x + margin, self.y + margin)
end


setmetatable(Bomb, { __call = function(_, ...) return new(...) end })

