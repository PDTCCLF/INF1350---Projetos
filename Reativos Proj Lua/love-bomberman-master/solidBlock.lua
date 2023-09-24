local dfX, dfY = 0, 0
local dfWidth, dfHeight = DFSIZE, DFSIZE 
local solidBlockImg = love.graphics.newImage('img/blocks/SolidBlock.png')

SolidBlock = {}
SolidBlock.__index = SolidBlock

local function new(x, y)
  return setmetatable(
    {
      x = x or dfX,
      y = y or dfY,
      width = width or dfWidth,
      height = height or dfHeight
    },
    SolidBlock)
end

function SolidBlock:draw()
  love.graphics.draw(solidBlockImg, self.x, self.y)
end

setmetatable(SolidBlock, { __call = function(_, ...) return new(...) end })

