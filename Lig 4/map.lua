local M = {}

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
  local duracaoFogo = map.consts.duracaoFogo * map.consts.FPS
  map[yc][xc] = 0
  map.hidden[yc][xc] = 4
  map.times[yc][xc] = duracaoFogo
  
  sound:stop()
  sound:play()
  
  for i=0,r do
    if yc+i>0 and yc+i<map.ny then
      if map[yc+i][xc] == 1 then
        break
      elseif map[yc+i][xc] ~= 0 then
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
    if xc+j>0 and xc+j<map.nx then
      if map[yc][xc+j] == 1 then
        break
      elseif map[yc][xc+j] ~= 0 then
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
    if xc+j>0 and xc+j<map.nx then
      if map[yc][xc+j] == 1 then
        break
      elseif map[yc][xc+j] ~= 0 then
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
  map[y][x] = 1 
end


local update = function(map, soundEffects)
  for i = 1, map.ny do
    for j = 1, map.nx do
      if map.hidden[i][j] == 4 then
        if map[i][j] == 2 then
          map[i][j] = 5
        elseif map[i][j] == 3 then
          map:explosion(j,i,2,soundEffects[1])
        end
      end
      
      map.times[i][j] = map.times[i][j] - 1
      if map.times[i][j] == 0 then
        if map.hidden[i][j] == 4 then
          map.hidden[i][j] = 0
          map[i][j] = 0
        end
        if map[i][j] == 3 then
          map:explosion(j,i,2,soundEffects[1])
        end
      end
      
    end
  end
end

local function draw0(x,y,L,r)
  local function myStencilFunction()
     -- Draw four overlapping circles as a stencil.
     love.graphics.circle("fill", x+L/2, y+L/2, r)
  end
  
  love.graphics.stencil(myStencilFunction, "increment")
 
  -- Only allow drawing in areas which have stencil values that are less than 2.
  love.graphics.setStencilTest("less", 1)

  -- Draw a big rectangle.
  love.graphics.rectangle("fill", x, y, L, L)

  love.graphics.setStencilTest()


end


local draw = function(map)
  local w,h = love.graphics.getWidth(),love.graphics.getHeight()
  local D = map.consts.D
  local nx,ny = map.consts.nx,map.consts.ny
  local walls = map.walls
  local background = map.background
  local wall
  local sx,xy
  
  love.graphics.push()
  love.graphics.translate((w-D)/2,(h-D*ny/nx)/2)
  love.graphics.scale(D/nx,D/nx)
  
  
  
  
  for i = 1, map.ny do
    for j = 1, map.nx do
      local squareSize = 1
      
      if map.hidden[i][j] == 1 then
        love.graphics.setColor(1.0,1.0,0.0)
        love.graphics.circle("fill", (j - 1) * squareSize + squareSize / 2, (i - 1) * squareSize + squareSize / 2,squareSize / 2 - 0.1)
      elseif map.hidden[i][j] == 2 then
        love.graphics.setColor(0.0,0.0,1.0)
        love.graphics.circle("fill", (j - 1) * squareSize + squareSize / 2, (i - 1) * squareSize + squareSize / 2,squareSize / 2 - 0.1)
      end
    end
  end
    
    
  for i = 1, map.ny do
    for j = 1, map.nx do
      local squareSize = 1
      if map[i][j] == 0 then
          love.graphics.setColor(1.0,0.0,0.0)
          draw0((j - 1) * squareSize,  (i - 1) * squareSize, squareSize, squareSize/2 - 0.1)
      end
    end
  end
  
  love.graphics.pop()
end

local reinicia = function(map)
  for i = 1, map.ny do
    map[i] = {}
    map.hidden[i] = {}
    map.times[i] = {}
    for j = 1, map.nx do
      map.hidden[i][j] = 0
      map.times[i][j] = -1
      if i > 1 then
        map[i][j] = 0
      end
      if i == 1 and j == 1 then
        map.hidden[i][j] = 1
      elseif i == map.consts.ny and j == map.consts.nx then
        map.hidden[i][j] = 2
      end
    end
  end
end
  

function M.create (consts, empty, soundEffects, walls, background) -- dimensions must be odd numbers
  local map = {nx=consts.nx, ny=consts.ny}
  
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
  map.reinicia = reinicia
  
  local function up()
    while true do
      map:update(soundEffects)
      coroutine.yield()
    end
  end
  
  map.up = coroutine.wrap(up)
  
  reinicia(map)
  return map
end


return M