
local ava = {}

function ava.avatar_cria (_imagem, pxi, pyi,teclas,consts)
  local avatar = {}
  local imagem = _imagem
  local velocidade = 1
  local x,y = pxi-1/2,pyi-1/2
  local D = consts.D
  local nx = consts.nx
  local ny = consts.ny
  local M = consts.M
  local r = consts.r
  local raio_bomba = 2
  
  M:break_wall(math.ceil(x),math.ceil(y),1)
  
  function avatar.update(dt)
    local x1,y1 = x,y
    local dr = (velocidade+1)*dt*1.2
    if love.keyboard.isDown(teclas.right) then
      y1=y1
      x1=x1+dr
      local i1=math.ceil(y1)
      local j1=math.ceil(x1)
      if (j1==nx or M[i1][j1+1]~=0) and x1+r>j1 then
        x1=j1-r
      end
    end
  
    if love.keyboard.isDown(teclas.left) then
        y1=y1
        x1=x1-dr
        local i1=math.ceil(y1)
        local j1=math.ceil(x1)
        if (j1==1 or M[i1][j1-1]~=0) and x1-r<j1-1 then
          x1=j1-1+r
        end
    end
  
    if love.keyboard.isDown(teclas.up) then
        y1=y1-dr
        x1=x1
        local i1=math.ceil(y1)
        local j1=math.ceil(x1)
        if (i1==1 or M[i1-1][j1]~=0) and y1-r<i1-1 then
          y1=i1-1+r
        end
      end
      
      if love.keyboard.isDown(teclas.down) then
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
    x,y = x1,y1
    
  end
  
  function avatar.keypressed(key)
    if key == teclas.A then
      local i1=math.ceil(y)
      local j1=math.ceil(x)
      M:explosion(j1,i1,raio_bomba)
      
    elseif key == teclas.t1 and velocidade < 3 then
      velocidade = velocidade + 0.25
    elseif key == teclas.t2 and velocidade > 0 then
      velocidade = velocidade - 0.25
    end
  end
  
  function avatar.draw()
    local w,h = love.graphics.getWidth(),love.graphics.getHeight()
    local sxa,sya=(2*((D/nx)/3))/imagem:getWidth(),(2*((D/ny)/3))/imagem:getHeight()
    love.graphics.draw(imagem,(w-D)/2+(x*D/nx),(h-D)/2+(y*D/ny),0,sxa,sya,imagem:getWidth()/2,imagem:getHeight()/2)
  end
  
  function avatar.set_D(_D)
    D = _D
  end
  
  return avatar
end

return ava