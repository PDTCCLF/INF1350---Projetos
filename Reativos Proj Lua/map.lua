local uf = require "uf"

local M = {}

local id = function (i, j)
  return i .. ":" .. j
end

local do_maze = function (map,_map)
  
  while #_map.walls > 0 do
    local w = 1
    local i = _map.walls[w].i
    local j = _map.walls[w].j
    
    --[[
    local w = math.random(1,#_map.walls)
    
    if i%2 == 0 then  -- check if horizontal or vertical wall
      if uf.union(_map.uf,id(i,j-1),id(i,j+1)) then
        map[i][j] = 3
      else
        table.insert(_map.cycles,_map.walls[w])
      end
    else
      if uf.union(_map.uf,id(i-1,j),id(i+1,j)) then
        map[i][j] = 2
      else
        table.insert(_map.cycles,_map.walls[w])
      end
    end
    --]]
    map[i][j] = 2
    table.remove(_map.walls,w)
  end
end

local do_doors = function (map)
  map[3][2] = 0
  map[2][3] = 0
  map[2][2] = 0
  map[map.ny-2][map.nx-1] = 0
  map[map.ny-1][map.nx-1] = 0
  map[map.ny-1][map.nx-2] = 0
end

local break_wall = function (map, xc, yc, r)
  for i=-r,r do
    for j=-r,r do
      if xc+j>0 and xc+j<map.nx and yc+i>0 and yc+i<map.ny then
        if map[yc+i][xc] ~= 1 then
          map[yc+i][xc] = 0
        end
        if map[yc][xc+j] ~= 1 then
          map[yc][xc+j] = 0
        end
      end
    end
  end
end

local explosion = function (map, xc, yc, r, sound)
  map[yc][xc] = 0
  map.hidden[yc][xc] = 4
  duracaoFogo = 120
  map.times[yc][xc] = duracaoFogo
  sound:play()
  for i=0,r do
    if yc+i>0 and yc+i<map.ny then
      if map[yc+i][xc] == 1 then
        break
      elseif map[yc+i][xc] ~= 0 then
        --map[yc+i][xc] = 0
        map.hidden[yc+i][xc] = 4
        map.times[yc+i][xc] = duracaoFogo
        break
      else
        map.hidden[yc+i][xc] = 4
        map.times[yc+i][xc] = duracaoFogo
      end
    end
  end
  
  for i=0,-r,-1 do
    if yc+i>0 and yc+i<map.ny then
      if map[yc+i][xc] == 1 then
        break
      elseif map[yc+i][xc] ~= 0 then
        --map[yc+i][xc] = 0
        map.hidden[yc+i][xc] = 4
        map.times[yc+i][xc] = duracaoFogo
        break
      else
        map.hidden[yc+i][xc] = 4
        map.times[yc+i][xc] = duracaoFogo
      end
    end
  end
  
  for j=0,r do
    if xc+j>0 and xc+j<map.ny then
      if map[yc][xc+j] == 1 then
        break
      elseif map[yc][xc+j] ~= 0 then
        --map[yc][xc+j] = 0
        map.hidden[yc][xc+j] = 4
        map.times[yc][xc+j] = duracaoFogo
        break
      else
        map.hidden[yc][xc+j] = 4
        map.times[yc][xc+j] = duracaoFogo
      end
    end
  end
  
  for j=0,-r,-1 do
    if xc+j>0 and xc+j<map.ny then
      if map[yc][xc+j] == 1 then
        break
      elseif map[yc][xc+j] ~= 0 then
        --map[yc][xc+j] = 0
        map.hidden[yc][xc+j] = 4
        map.times[yc][xc+j] = duracaoFogo
        break
      else
        map.hidden[yc][xc+j] = 4
        map.times[yc][xc+j] = duracaoFogo
      end
    end
  end
  
end

local place_bomb = function (map, x, y, r)
  map[y][x] = 3
  map.times[y][x] = 120
end


local empty_space = function (map, _map, empty)
  local n = #_map.cycles * empty
  for k = 1, n do
    local w = math.random(1,#_map.cycles)
    local i = _map.cycles[w].i
    local j = _map.cycles[w].j
    map[i][j] = true
    table.remove(_map.cycles,w)
  end
  -- eliminate isolated corners
  for i = 3, map.ny-2, 2 do
    for j = 3, map.nx-2, 2 do
      if map[i-1][j] and map[i+1][j] and map[i][j-1] and map[i][j+1] then
        map[i][j] = 1
      end
    end
  end
end

local update = function(map, soundEffects)
  for i = 1, map.ny do
    for j = 1, map.nx do
      if map.hidden[i][j] == 4 then
        if map[i][j] == 2 then
          map[i][j] = 0
        elseif map[i][j] == 3 then
          map:explosion(j,i,2,soundEffects[1])
        end
      end
      
      
      map.times[i][j] = map.times[i][j] - 1
      if map.times[i][j] == 0 then
        if map.hidden[i][j] == 4 then
          map.hidden[i][j] = 0
        end
        
        if map[i][j] == 3 then
          map:explosion(j,i,2,soundEffects[1])
        end
        
      end
      
    end
  end
end

local draw = function(map)
  local w,h = love.graphics.getWidth(),love.graphics.getHeight()
  local D = map.consts.D
  local nx,ny = map.consts.nx,map.consts.ny
  
  love.graphics.push()
  love.graphics.translate((w-D)/2,(h-D)/2)
  love.graphics.scale(D/nx,D/ny)
  
  local walls = map.walls
  local background = map.background
  local wall
  local sx,xy
  for i = 1, map.ny do
    for j = 1, map.nx do
      love.graphics.setColor(1.0,1.0,1.0)
      love.graphics.draw(background["image"],(j-1),(i-1),0,background["sx"],background["sy"])
      
      wall=walls[map[i][j]]
      if wall ~= nil then
        image = wall["image"]
        sx,sy = wall.sx,wall.sy
        love.graphics.draw(image,(j-1),(i-1),0,sx,sy)
      end
      
      wall=walls[map.hidden[i][j]]
      if wall ~= nil then
        image = wall["image"]
        sx,sy = wall.sx,wall.sy
        love.graphics.draw(image,(j-1),(i-1),0,sx,sy)
      end
      
    end
  end
  
  love.graphics.pop()
end

-- Create and return a new map
-- nx and ny represents the number of horizontal and vertical cells, respectively,
-- and must be odd numbers. Empty accounts for the amount of empty space. For 
-- empty=0.0, the returned map is a maze without cycles; for empty=1.0, the whole
-- domain is empty (without internal walls).
-- If doors are requested, they are placed at cells (2,ny) and (nx-1,1).
function M.create (consts, empty, soundEffects, walls, background) -- dimensions must be odd numbers
  local map = {nx=consts.nx, ny=consts.ny}
  local _map = {walls={}, cycles={}, uf=uf.create()}
  map.explosion = explosion
  map.break_wall = break_wall
  map.update = update
  map.place_bomb = place_bomb
  map.draw = draw
  map.hidden = {}
  map.times = {}
  map.walls = walls
  map.background = background
  map.consts = consts
  local nx,ny = consts.nx, consts.ny
  
  for i = 1, ny do
    map[i] = {}
    map.hidden[i] = {}
    map.times[i] = {}
    for j = 1, nx do
      map.hidden[i][j] = 0
      map.times[i][j] = -1
      uf.addnode(_map.uf,id(i,j))
      if i == 1 or j == 1 or i == ny or j == nx or ((i+1)%2==0 and (j+1)%2==0) then
        map[i][j] = 1
      --[[
      if i%2==0 and j%2==0 then
        map[i][j] = 0
        if i+1 ~= ny then
          table.insert(_map.walls,{i=i+1,j=j})
        end
        if j+1 ~= nx then
          table.insert(_map.walls,{i=i,j=j+1})
        end
        
      --]]
      
      
    
      else
        map[i][j] = 0
        table.insert(_map.walls,{i=i,j=j})
      end
    end
  end
  do_maze(map,_map)
  
  
  local function up()
    while true do
      map:update(soundEffects)
      coroutine.yield()
    end
  end
  
  map.up = coroutine.wrap(up)
  
  
  
  --empty_space(map,_map,empty)
  return map
end





return M