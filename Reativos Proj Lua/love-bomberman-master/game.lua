require('player')
require('solidBlock')
require('floorBlock')
require('explodableBlock')
require('creep')
math.randomseed(os.time())

local player = nil
local solidBlocks, floorBlocks, explodableBlocks, creeps = {}, {}, {}, {}
local dfWidth = DFSIZE
local gameDimension = {rows = 9, columns = 11}
local mapPath = "maps/m%s"
local playerSign, solidBlockSign, floorBlockSign, blankSign = 'P', '#', ' ', ' '
local blankTiles = {}
local explodableBlockAmount = 25
local creepAmount = 3

Game = {}
Game.__index = Game

local function initPosition(mapString, char)
  local x,y = 0,0
  local tileString = mapString
  local width = #(tileString:match("[^\n]+"))
  local positions = {}

  for row in tileString:gmatch("[^\n]+") do
    assert(#row == width, 'Map is not aligned: width of row ' .. tostring(y) .. ' should be ' .. tostring(width) .. ', but it is ' .. tostring(#row))
    x = 0
    for tile in row:gmatch(".") do
      if tile == char then
        table.insert(positions, {x*dfWidth, y*dfWidth})
      end
      x = x + 1
    end
    y = y + 1
  end
  return positions
end

local function randomTile()
  return table.remove(blankTiles, math.random(#blankTiles))
end

local function new(stage)
  local o = {
      stage = stage,
      mapString = require(string.format(mapPath, stage))
  }
  blankTiles = initPosition(o.mapString, blankSign)
  return setmetatable(
    o, Game)
end

local function initExplodableBlockPosition()
  local coords = {}
  for i = 1, explodableBlockAmount do
    table.insert(coords, randomTile())
  end
  return coords
end

local function initCreepPosition()
  local coords = {}
  for i = 1, creepAmount do
    table.insert(coords, randomTile())
  end
  return coords
end

function Game:loadPlayer()
  local coords = initPosition(self.mapString, playerSign)
  if not player then
    player = Player(coords[1][1], (coords[1][2] - dfWidth))
  else
    print("Switch map")
  end
  return player
end

function Game:loadSolidBlocks()
  local coords = initPosition(self.mapString, solidBlockSign)
  for i, coord in ipairs(coords) do
    table.insert(solidBlocks, SolidBlock(coord[1], coord[2]))
  end
  return solidBlocks
end

function Game:loadFloor()
  for row = 0, gameDimension.rows-1 do
    for column = 0, gameDimension.columns-1 do
      table.insert(floorBlocks, FloorBlock(column * dfWidth, row * dfWidth))
    end
  end
  return floorBlocks
end

function Game:loadExplodableBlocks()
  local coords = initExplodableBlockPosition()
  for i, coord in ipairs(coords) do
    table.insert(explodableBlocks, ExplodableBlock(coord[1], coord[2]))
  end
  return explodableBlocks
end

function Game:loadCreeps()
  local coords = initCreepPosition()
  for i, coord in ipairs(coords) do
    table.insert(creeps, Creep(coord[1], coord[2]))
  end
  return creeps
end

setmetatable(Game, { __call = function(_, ...) return new(...) end })
