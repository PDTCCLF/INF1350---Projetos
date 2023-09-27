
local ava = {}

function ava.avatar_cria (imagens, pxi, pyi, teclas, consts, sound)
  local avatar = {}
  local M = consts.M
  local imagem = imagens.front[1]
  local iImg = 1
  local tempoImg = 0
  local tempoIntervalo = 1/24
  
  local velocidade = 1
  local x,y = pxi-1/2,pyi-1/2
  local raio_bomba = 2
  local is_alive = true

  M:break_wall(math.ceil(x),math.ceil(y),1)
  
  function avatar.update(dt)
    if is_alive then
      local x1,y1 = x,y
      local nx = consts.nx
      local ny = consts.ny
      local r = consts.r
      local dr = (velocidade+1)*dt*1.2
      
      local movFront = false
      local movBack = false
      local movLeft = false
      local movRight = false

      if love.keyboard.isDown(teclas.right) then
        movRight = true
        y1=y1
        x1=x1+dr
        local i1=math.ceil(y1)
        local j1=math.ceil(x1)
        if (j1==nx or M[i1][j1+1]~=0) and x1+r>j1 then
          x1=j1-r
        end
      end
    
      if love.keyboard.isDown(teclas.left) then
        movLeft = true
        y1=y1
        x1=x1-dr
        local i1=math.ceil(y1)
        local j1=math.ceil(x1)
        if (j1==1 or M[i1][j1-1]~=0) and x1-r<j1-1 then
          x1=j1-1+r
        end
      end
    
      if love.keyboard.isDown(teclas.up) then
        movBack = true
        y1=y1-dr
        x1=x1
        local i1=math.ceil(y1)
        local j1=math.ceil(x1)
        if (i1==1 or M[i1-1][j1]~=0) and y1-r<i1-1 then
          y1=i1-1+r
        end
      end
      
      if love.keyboard.isDown(teclas.down) then
        movFront = true
        y1=y1+dr
        x1=x1
        local i1=math.ceil(y1)
        local j1=math.ceil(x1)
        if (i1==ny or M[i1+1][j1]~=0) and y1+r>i1 then
          y1=i1-r
        end
      end
      
      local i1=math.ceil(y1)
      local j1=math.ceil(x1)
      if j1==nx or i1-1==0 or M[i1-1][j1+1]~=0 then
        local dx1,dy1=x1-j1,y1-(i1-1)
        local d=math.sqrt(dx1^2+dy1^2)
        if d<r then
          x1=x1+(r-d)*dx1/d
          y1=y1+(r-d)*dy1/d
        end
      end
      if j1==nx or i1==ny or M[i1+1][j1+1]~=0 then
        local dx1,dy1=x1-j1,y1-i1
        local d=math.sqrt(dx1^2+dy1^2)
        if d<r then
          x1=x1+(r-d)*dx1/d
          y1=y1+(r-d)*dy1/d
        end
      end
      if j1-1==0 or i1-1==0 or M[i1-1][j1-1]~=0 then
        local dx1,dy1=x1-(j1-1),y1-(i1-1)
        local d=math.sqrt(dx1^2+dy1^2)
        if d<r then
          x1=x1+(r-d)*dx1/d
          y1=y1+(r-d)*dy1/d
        end
      end
      if j1-1==0 or i1==ny or M[i1+1][j1-1]~=0 then
        local dx1,dy1=x1-(j1-1),y1-i1
        local d=math.sqrt(dx1^2+dy1^2)
        if d<r then
          x1=x1+(r-d)*dx1/d
          y1=y1+(r-d)*dy1/d
        end
      end
      
      tempoImg = tempoImg + dt
      
      if tempoImg > tempoIntervalo then
        tempoImg = tempoImg - tempoIntervalo
        
        if movFront then
          iImg = iImg + 1
          if iImg > #imagens.front then
            iImg = 1
          end
          imagem = imagens.front[iImg]
        elseif movBack then
          iImg = iImg + 1
          if iImg > #imagens.back then
            iImg = 1
          end
          imagem = imagens.back[iImg]
        elseif movRight then
          iImg = iImg + 1
          if iImg > #imagens.right then
            iImg = 1
          end
          imagem = imagens.right[iImg]
        elseif movLeft then
          iImg = iImg + 1
          if iImg > #imagens.left then
            iImg = 1
          end
          imagem = imagens.left[iImg]
        else
          iImg = 1
          imagem = imagens.front[iImg]
        end
      end
  
      if M.hidden[i1][j1] == 4 then
        is_alive = false
        sound:play()
      end
      
      x,y = x1,y1
    end
  end
  
  function avatar.keypressed(key)
    if key == teclas.A then
      local i1=math.ceil(y)
      local j1=math.ceil(x)
      
      M:place_bomb(j1,i1,raio_bomba)
      
    elseif key == teclas.t1 and velocidade < 3 then
      velocidade = velocidade + 0.25
    elseif key == teclas.t2 and velocidade > 1 then
      velocidade = velocidade - 0.25
    end
  end
  
  function avatar.draw()
    if is_alive then
      local D = consts.D
      local nx = consts.nx
      local ny = consts.ny
      local w,h = love.graphics.getWidth(),love.graphics.getHeight()
      local sxa,sya=(2*((D/nx)/3))/imagem:getWidth(),(2*((D/ny)/3))/imagem:getHeight()
      love.graphics.draw(imagem,(w-D)/2+(x*D/nx),(h-D)/2+(y*D/ny),0,sxa,sya,imagem:getWidth()/2,imagem:getHeight()/2)
    end
  end
  
  function avatar.status(operation)
    if operation == "check" then
      return is_alive
    elseif operation == "ressurect" then
      velocidade = 1
      x,y = pxi-1/2,pyi-1/2
      raio_bomba = 2
      iImg = 1
      tempoImg = 0
      is_alive = true
      M:break_wall(math.ceil(x),math.ceil(y),1)
    end
  end
  
  function avatar.draw2(x,y)
    local D = consts.D
    local nx = consts.nx
    local ny = consts.ny
    local w,h = love.graphics.getWidth(),love.graphics.getHeight()
    local sxa,sya=(2*((D/nx)/3))/imagem:getWidth(),(2*((D/ny)/3))/imagem:getHeight()
    iImg = 1
    imagem = imagens.front[iImg]
    love.graphics.draw(imagem,x,y,0,sxa,sya,imagem:getWidth()/2,imagem:getHeight()/2)
  end
  
  local function up()
    while true do
      avatar.update(1/consts.FPS)
      coroutine.yield()
    end
  end
  
  avatar.up = coroutine.wrap(up)
  
  return avatar
end

return ava