DFSIZE = 64
drawingLayers = {}
require('game')
require('camera')


function love.load(args)
  camera.layers = {}
  game = Game(1)

  bombs = {}

  player = game:loadPlayer()

  floorBlocks = game:loadFloor()

  solidBlocks = game:loadSolidBlocks()
  player:addCheckingCollision(solidBlocks, player.resetPosition)

  explodableBlocks = game:loadExplodableBlocks()
  player:addCheckingCollision(explodableBlocks, player.resetPosition)

  creeps = game:loadCreeps()
  for _, creep in ipairs(creeps) do
    creep:addCheckingCollision(solidBlocks, creep.resetPosition)
    creep:addCheckingCollision(explodableBlocks, creep.resetPosition)
  end

  camera:newLayer(1, function()
    for _, floorBlock in ipairs(floorBlocks) do
      floorBlock:draw()
    end
  end)

  camera:newLayer(2, function()
    for _, solidBlock in ipairs(solidBlocks) do
      solidBlock:draw()
    end
  end)

  camera:newLayer(3, function()
    for _, explodableBlock in ipairs(explodableBlocks) do
      explodableBlock:draw()
    end
  end)
  camera:newLayer(4, function()
    for _, creep in ipairs(creeps) do
      creep:draw()
    end
  end)
  camera:newLayer(10, function()
    player:draw()
  end)
end

function love.update(dt)
  -- bombs = player.bombs
  -- bind bomb collision to creeps
  player:update(dt)

  for _, creep in ipairs(creeps) do
    creep:update(dt)
  end
end

function love.draw()

  camera:draw()

end
