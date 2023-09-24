local dfX, dfY = 0, 0
local dfWidth, dfHeight = DFSIZE, DFSIZE 
local floorBlockImg = love.graphics.newImage('img/blocks/BackgroundTile.png')

FloorBlock = {}
FloorBlock.__index = FloorBlock

local function new(x, y)
  return setmetatable(
    {
      x = x or dfX,
      y = y or dfY,
      width = width or dfWidth,
      height = height or dfHeight
    },
    FloorBlock)
end

function FloorBlock:draw()
  love.graphics.draw(floorBlockImg, self.x, self.y)
end

setmetatable(FloorBlock, { __call = function(_, ...) return new(...) end })

