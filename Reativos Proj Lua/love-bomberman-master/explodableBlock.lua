local dfX, dfY = 0, 0
local dfWidth, dfHeight = DFSIZE, DFSIZE 
local explodableBlockImg = love.graphics.newImage('img/blocks/ExplodableBlock.png')

ExplodableBlock = {}
ExplodableBlock.__index = ExplodableBlock

local function new(x, y)
  return setmetatable(
    {
      x = x or dfX,
      y = y or dfY,
      width = width or dfWidth,
      height = height or dfHeight
    },
    ExplodableBlock)
end

function ExplodableBlock:draw()
  love.graphics.draw(explodableBlockImg, self.x, self.y)
end

setmetatable(ExplodableBlock, { __call = function(_, ...) return new(...) end })

