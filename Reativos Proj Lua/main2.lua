local map = require "map"
function newButton(text,fn)
    return {text=text,fn=fn,now = false,last = false}
end
  
local buttons = {}
local font
local start
local menubg
local exit
local sound
local nosound
local title
local surprise
local surprise1
local surprise2
local music
local mute
local status="1"
local difficulty
local area1,area2,area3
local avatar
local avatar1,avatar2,avatar3
local enemy
local tlimit
local e_exist
local t_exist
local M
local nx,ny
local r=1/3
local x,y
local x1,y1
local D=600
local time=0
local wall
local background
local ending=10
  
function love.load()
  love.window.setMode(600,600)
  math.randomseed(os.time())
  background=love.graphics.newImage("background.png")
  font=love.graphics.newFont("ariblk.ttf",30)
  menubg=love.graphics.newImage("menubackground.png")
  title=love.graphics.newImage("Logo Menu.png")
  area1,area2,area3=love.graphics.newImage("grass.jpg"),love.graphics.newImage("sponge.jpg"),love.graphics.newImage("fire.jpg")
  avatar1,avatar2,avatar3=love.graphics.newImage("cat.png"),love.graphics.newImage("dog.png"),love.graphics.newImage("raccoon.png")
  enemy=love.graphics.newImage("octo.png")
  surprise1=love.graphics.newImage("surprise.png")
  surprise2=love.audio.newSource("happynoises.mp3", "stream")
  music=love.audio.newSource("Pizza.mp3", "stream")
  music:play()
  table.insert(buttons,newButton("",
      function()
        status="2"
      end))
  table.insert(buttons, newButton("",
      function()
        love.event.quit()
      end))
  table.insert(buttons, newButton("",
      function()
        if music:isPlaying() then
          music:pause()
          mute=true
        else
          music:play()
          mute=false
        end
      end))
  start=love.graphics.newImage("Start Menu.png")
  exit=love.graphics.newImage("Exit Menu.png")
  sound=love.graphics.newImage("sound.png")
  nosound=love.graphics.newImage("mute.png")
  table.insert(buttons,newButton("Easy",
      function()
        difficulty=21
        nx,ny=difficulty,difficulty
        M=map.create(nx,ny,true,0.0)
        x,y=nx-1-r,r
        x1,y1=2-1/2,ny-1/2
        tlimit=30
        status="3"
      end))
  table.insert(buttons,newButton("Medium",
      function()
        difficulty=31
        nx,ny=difficulty,difficulty
        M=map.create(nx,ny,true,0.0)
        x,y=nx-1-r,r
        x1,y1=2-1/2,ny-1/2
        tlimit=60
        status="3"
      end))
  table.insert(buttons,newButton("Hard",
      function()
        difficulty=41
        nx,ny=difficulty,difficulty
        M=map.create(nx,ny,true,0.0)
        x,y=nx-1-r,r
        x1,y1=2-1/2,ny-1/2
        tlimit=90
        status="3"
      end))
  table.insert(buttons,newButton("Cat",
      function()
        avatar=avatar1
        if wall~=nil then
          status="4"
        end
      end))
  table.insert(buttons,newButton("Dog",
      function()
        avatar=avatar2
        if wall~=nil then
          status="4"
        end
      end))
  table.insert(buttons,newButton("Raccoon",
      function()
        avatar=avatar3
        if wall~=nil then
          status="4"
        end
      end))
  table.insert(buttons,newButton("Grass",
      function()
        wall=area1
        if avatar~=nil then
          status="4"
        end
      end))
  table.insert(buttons,newButton("Water",
      function()
        wall=area2
        if avatar~=nil then
          status="4"
        end
      end))
  table.insert(buttons,newButton("Fire",
      function()
        wall=area3
        if avatar~=nil then
          status="4"
        end
      end))
  table.insert(buttons,newButton("No enemy",
      function()
        e_exist=false
        if t_exist~=nil then
          status="On"
        end
      end))
  table.insert(buttons,newButton("No time limit",
      function()
        t_exist=false
        if e_exist~=nil then
          status="On"
        end
      end))
  table.insert(buttons,newButton("Enemy",
      function()
        e_exist=true
        if t_exist~=nil then
          status="On"
        end
      end))
  table.insert(buttons,newButton("Time limit",
      function()
        t_exist=true
        if e_exist~=nil then
          status="On"
        end
      end))
end

function love.keypressed(key)
  if key=="s" then
    if status~="On" and status~="Pause" and status~="Game over" and love.keyboard.isDown("space") then
      surprise=true
    end
  end
  if key=="space" then
    if status=="On" then
      status="Pause"
    elseif status=="Pause" then
      status="On"
    end
  end
  if key=="q" and status=="Pause" then
    love.event.quit()
  end
end

function love.update(dt)
  if not music:isPlaying() and not mute then
    music:play()
  end
  
  if status=="On" then
    time=time+dt
    
    if e_exist==true then
      local i=math.ceil(y)
      local j=math.ceil(x)
      local v=3
      if ((j==nx or M[i][j+1]==false) and j-x<r+0.1) or ((j==nx or i==1 or M[i-1][j+1]==false) and math.sqrt((j-x)^2+(y-(i-1))^2)<r+0.2 and M[i-1][j]==true) then
        y=y-0.1*v
        x=x
        i=math.ceil(y)
        j=math.ceil(x)
        if (i==1 or M[i-1][j]==false) and y-r<i-1 then
          y=i-1+r
          x=x-0.1*v
        end
      elseif ((i==ny or M[i+1][j]==false) and i-y<r+0.1) or ((j==nx or i==ny or M[i+1][j+1]==false) and math.sqrt((j-x)^2+(i-y)^2)<r+0.2 and M[i+1][j]==true) then
        y=y
        x=x+0.1*v
        i=math.ceil(y)
        j=math.ceil(x)
        if (j==nx or M[i][j+1]==false) and x+r>j then
          x=j-r
        end
      elseif ((j==1 or M[i][j-1]==false) and x-(j-1)<r+0.1) or ((j==1 or i==ny or M[i+1][j-1]==false) and math.sqrt((x-(j-1))^2+(i-y)^2)<r+0.2 and M[i+1][j]==true) then
        y=y+0.1*v
        x=x
        i=math.ceil(y)
        j=math.ceil(x)
        if (i==ny or M[i+1][j]==false) and y+r>i then
          y=i-r
        end
      elseif ((i==1 or M[i-1][j]==false) and y-(i-1)<r+0.1) or ((j==1 or i==1 or M[i-1][j-1]==false) and math.sqrt((x-(j-1))^2+(y-(i-1))^2)<r+0.2 and M[i-1][j]) then
        y=y
        x=x-0.1*v
        i=math.ceil(y)
        j=math.ceil(x)
        if (j==1 or M[i][j-1]==false) and x-r<j-1 then
          x=j-1+r
        end
      end 
      i=math.ceil(y)
      j=math.ceil(x)
      if j==nx or i-1==0 or M[i-1][j+1]==false then
        local dx,dy=x-j,y-(i-1)
        local d=math.sqrt(dx^2+dy^2)
        if d<r then
          x=x+(r-d)*dx/d
          y=y+(r-d)*dy/d
        end
      end
      if j==nx or i==ny or M[i+1][j+1]==false then
        local dx,dy=x-j,y-i
        local d=math.sqrt(dx^2+dy^2)
        if d<r then
          x=x+(r-d)*dx/d
          y=y+(r-d)*dy/d
        end
      end
      if j-1==0 or i-1==0 or M[i-1][j-1]==false then
        local dx,dy=x-(j-1),y-(i-1)
        local d=math.sqrt(dx^2+dy^2)
        if d<r then
          x=x+(r-d)*dx/d
          y=y+(r-d)*dy/d
        end
      end
      if j-1==0 or i==ny or M[i+1][j-1]==false then
        local dx,dy=x-(j-1),y-i
        local d=math.sqrt(dx^2+dy^2)
        if d<r then
          x=x+(r-d)*dx/d
          y=y+(r-d)*dy/d
        end
      end
    end

    if love.keyboard.isDown("up") then
      y1=y1-0.1
      x1=x1
      local i1=math.ceil(y1)
      local j1=math.ceil(x1)
      if (i1==1 or M[i1-1][j1]==false) and y1-r<i1-1 then
        y1=i1-1+r
      end
    end
    if love.keyboard.isDown("down") then
      y1=y1+0.1
      x1=x1
      local i1=math.ceil(y1)
      local j1=math.ceil(x1)
      if (i1==ny or M[i1+1][j1]==false) and y1+r>i1 then
        y1=i1-r
      end
    end
    if love.keyboard.isDown("right") then
      y1=y1
      x1=x1+0.1
      local i1=math.ceil(y1)
      local j1=math.ceil(x1)
      if (j1==nx or M[i1][j1+1]==false) and x1+r>j1 then
        x1=j1-r
      end
    end
    if love.keyboard.isDown("left") then
      y1=y1
      x1=x1-0.1
      local i1=math.ceil(y1)
      local j1=math.ceil(x1)
      if (j1==1 or M[i1][j1-1]==false) and x1-r<j1-1 then
        x1=j1-1+r
      end
    end
    local i1=math.ceil(y1)
    local j1=math.ceil(x1)
    if j1==nx or i1-1==0 or M[i1-1][j1+1]==false then
      local dx1,dy1=x1-j1,y1-(i1-1)
      local d=math.sqrt(dx1^2+dy1^2)
      if d<r then
        x1=x1+(r-d)*dx1/d
        y1=y1+(r-d)*dy1/d
      end
    end
    if j1==nx or i1==ny or M[i1+1][j1+1]==false then
      local dx1,dy1=x1-j1,y1-i1
      local d=math.sqrt(dx1^2+dy1^2)
      if d<r then
        x1=x1+(r-d)*dx1/d
        y1=y1+(r-d)*dy1/d
      end
    end
    if j1-1==0 or i1-1==0 or M[i1-1][j1-1]==false then
      local dx1,dy1=x1-(j1-1),y1-(i1-1)
      local d=math.sqrt(dx1^2+dy1^2)
      if d<r then
        x1=x1+(r-d)*dx1/d
        y1=y1+(r-d)*dy1/d
      end
    end
    if j1-1==0 or i1==ny or M[i1+1][j1-1]==false then
      local dx1,dy1=x1-(j1-1),y1-i1
      local d=math.sqrt(dx1^2+dy1^2)
      if d<r then
        x1=x1+(r-d)*dx1/d
        y1=y1+(r-d)*dy1/d
      end
    end
  end
  
  if status=="On" and (math.ceil(y1)-1==0 or (t_exist==true and time>tlimit) or (e_exist==true and math.abs(x1-x)<=2*r and math.abs(y1-y)<=2*r)) then
    status="Game over"
  end
  if status=="Game over" then
    ending=ending-dt
    if ending<0 then
      love.event.quit()
    end
  end
end
  
function love.draw()
  local w,h = love.graphics.getWidth(),love.graphics.getHeight()
  love.graphics.setColor(1.0,1.0,1.0)
  local sxm,sym=w/menubg:getWidth(),h/menubg:getHeight()
  love.graphics.draw(menubg,0,0,0,sxm,sym)
  local sxt,syt=((w/2)+100)/title:getWidth(),(h/6)/title:getHeight()
  love.graphics.draw(title,(w/2)-((w/2)+100)/2,15,0,sxt,syt)
  local button_width = w * (1/3)
  local BUTTON_HEIGHT = h * (1/10)
  local margin = 16
  if status=="1" then
    local total_height = (BUTTON_HEIGHT + margin) * 3
    local cursor_y = 0
    for i, button in ipairs(buttons) do
      if i<4 then
        button.last = button.now
        local bx = (w/2) - (button_width/2)
        local by = (h/2) - (BUTTON_HEIGHT/2) + cursor_y
        love.graphics.setColor(0.1,0.1,0.2)
        local mx, my = love.mouse.getPosition()
        local hot = mx > bx and mx < bx + button_width and my > by and my < by + BUTTON_HEIGHT
        if hot then
          love.graphics.setColor(0.8,0.8,0.9)
        end
        button.now = love.mouse.isDown(1)
        if love.mouse.isDown(1)==true then
          love.timer.sleep(0.1)
        end
        love.timer.sleep(0)
        if button.now and not button.last and hot then
          button.fn()
        end
        if i==1 then
          local sxb,syb=button_width/start:getWidth(),BUTTON_HEIGHT/start:getHeight()
          love.graphics.draw(start,bx,by,0,sxb,syb)
        elseif i==2 then
          local sxb,syb=button_width/exit:getWidth(),BUTTON_HEIGHT/exit:getHeight()
          love.graphics.draw(exit,bx,by,0,sxb,syb)
        elseif i==3 then
          local sxb,syb=button_width/sound:getWidth(),BUTTON_HEIGHT/sound:getHeight()
          if mute then
            love.graphics.draw(nosound,bx,by,0,sxb,syb)
          else
            love.graphics.draw(sound,bx,by,0,sxb,syb)
          end
        end
        cursor_y = cursor_y + (BUTTON_HEIGHT + margin)
      end
    end
    
  elseif status=="2" then
    local total_height = (BUTTON_HEIGHT + margin) * 3
    local cursor_y = 0
    love.graphics.setColor(0,0,0)
    love.graphics.rectangle("fill",300,200,button_width,BUTTON_HEIGHT)
    love.graphics.rectangle("fill",20,200,270,total_height+margin+BUTTON_HEIGHT)
    love.graphics.setColor(1.0,1.0,1.0)
    love.graphics.print("Controls:",font,25,200)
    love.graphics.print("-Use up, down,",font,25,235)
    love.graphics.print("right and left",font,25,265)
    love.graphics.print("for movement",font,25,295)
    love.graphics.print("-Use space to",font,25,345)
    love.graphics.print("pause",font,25,375)
    love.graphics.print("-Use q to quit",font,25,425)
    love.graphics.print("(in pause)",font,25,455)
    love.graphics.print("Difficulty:",font,310,206)
    for i, button in ipairs(buttons) do
      if i>3 and i<7 then
        button.last = button.now
        local bx = (w/2) - (button_width/2)
        local by = (h/2) - (BUTTON_HEIGHT/2) + cursor_y
        love.graphics.setColor(0.1,0.1,0.2)
        local mx, my = love.mouse.getPosition()
        local hot = mx > bx + 100 and mx < bx + 100 + button_width and my > by and my < by + BUTTON_HEIGHT
        if hot then
          love.graphics.setColor(0.8,0.8,0.9)
        end
        button.now = love.mouse.isDown(1)
        if love.mouse.isDown(1)==true then
          love.timer.sleep(0.1)
        end
        love.timer.sleep(0)
        if button.now and not button.last and hot then
          button.fn()
        end
        love.graphics.rectangle("fill",bx+100,by,button_width,BUTTON_HEIGHT)
        love.graphics.setColor(0,0,0)
        local textW = font:getWidth(button.text)
        local textH = font:getHeight(button.text)
        love.graphics.print(button.text,font,((w/2) - textW/2)+100,(by + textH/2)-10)
        cursor_y = cursor_y + (BUTTON_HEIGHT + margin)
      end
    end
  elseif status=="3" then
    local total_height = (BUTTON_HEIGHT + margin) * 3
    local cursor_y = -30
    local cursor_y1 = -30
    love.graphics.setColor(0,0,0)
    love.graphics.rectangle("fill",515,130,50,290)
    love.graphics.rectangle("fill",15,130,50,130)
    love.graphics.setColor(1.0,1.0,1.0)
    love.graphics.draw(avatar1,350,240-BUTTON_HEIGHT-25,0,(button_width-100)/avatar1:getWidth(),(BUTTON_HEIGHT+20)/avatar1:getWidth())
    love.graphics.draw(area1,80,240-BUTTON_HEIGHT-20,0,button_width/area1:getWidth(),(BUTTON_HEIGHT+100)/area1:getWidth())
    love.graphics.draw(avatar2,350,391-BUTTON_HEIGHT-25,0,(button_width-100)/avatar2:getWidth(),(BUTTON_HEIGHT+20)/avatar2:getWidth())
    love.graphics.draw(area2,80,391-BUTTON_HEIGHT-20,0,button_width/area2:getWidth(),(BUTTON_HEIGHT+100)/area2:getWidth())
    love.graphics.draw(avatar3,350,542-BUTTON_HEIGHT-20,0,(button_width-100)/avatar3:getWidth(),(BUTTON_HEIGHT+20)/avatar3:getWidth())
    love.graphics.draw(area3,80,542-BUTTON_HEIGHT-20,0,button_width/area3:getWidth(),(BUTTON_HEIGHT+100)/area3:getWidth())
    love.graphics.print("C",font,525,130)
    love.graphics.print("h",font,525,155)
    love.graphics.print("a",font,525,185)
    love.graphics.print("r",font,525,215)
    love.graphics.print("a",font,525,245)
    love.graphics.print("c",font,525,275)
    love.graphics.print("t",font,525,305)
    love.graphics.print("e",font,525,335)
    love.graphics.print("r",font,525,365)
    love.graphics.print("A",font,25,130)
    love.graphics.print("r",font,25,155)
    love.graphics.print("e",font,25,185)
    love.graphics.print("a",font,25,215)
    for i, button in ipairs(buttons) do
      if i>6 and i<10 then
        button.last = button.now
        local bx = (w/2) - (button_width/2)
        local by = (h/2) - (BUTTON_HEIGHT/2) + cursor_y
        love.graphics.setColor(0.1,0.1,0.2)
        local mx, my = love.mouse.getPosition()
        local hot = mx > bx + 100 and mx < bx + 100 + button_width and my > by and my < by + BUTTON_HEIGHT
        if hot then
          love.graphics.setColor(0.8,0.8,0.9)
        end
        button.now = love.mouse.isDown(1)
        if love.mouse.isDown(1)==true then
          love.timer.sleep(0.1)
        end
        love.timer.sleep(0)
        if button.now and not button.last and hot then
          button.fn()
        end
        love.graphics.rectangle("fill",bx+100,by,button_width,BUTTON_HEIGHT)
        love.graphics.setColor(0,0,0)
        local textW = font:getWidth(button.text)
        local textH = font:getHeight(button.text)
        love.graphics.print(button.text,font,(w/2) - textW/2+100,(by + textH/2)-10)
        cursor_y = cursor_y + (BUTTON_HEIGHT + margin)+75
      elseif i>9 and i<13 then
        button.last = button.now
        local bx = (w/2) - (button_width/2)
        local by = (h/2) - (BUTTON_HEIGHT/2) + cursor_y1
        love.graphics.setColor(0.1,0.1,0.2)
        local mx, my = love.mouse.getPosition()
        local hot = mx > bx - 120 and mx < bx - 120 + button_width and my > by and my < by + BUTTON_HEIGHT
        if hot then
          love.graphics.setColor(0.8,0.8,0.9)
        end
        button.now = love.mouse.isDown(1)
        if love.mouse.isDown(1)==true then
          love.timer.sleep(0.1)
        end
        love.timer.sleep(0)
        if button.now and not button.last and hot then
          button.fn()
        end
        love.graphics.rectangle("fill",bx-120,by,button_width,BUTTON_HEIGHT)
        love.graphics.setColor(0,0,0)
        local textW = font:getWidth(button.text)
        local textH = font:getHeight(button.text)
        love.graphics.print(button.text,font,((w/2) - textW/2)-120,(by + textH/2)-10)
        cursor_y1 = cursor_y1 + (BUTTON_HEIGHT + margin)+75
      end
    end
  elseif status=="4" then
    local total_height = (BUTTON_HEIGHT + margin) * 2
    local cursor_y = 30
    local cursor_y1 = 30
    love.graphics.draw(enemy,80,240-BUTTON_HEIGHT-50,0,button_width/enemy:getWidth(),(BUTTON_HEIGHT+100)/enemy:getWidth())
    love.graphics.setColor(0,0,0)
    love.graphics.rectangle("fill",80,391-BUTTON_HEIGHT+60,button_width,BUTTON_HEIGHT)
    love.graphics.setColor(1.0,1.0,1.0)
    love.graphics.print(tlimit.."s",font,80+70,391-BUTTON_HEIGHT+70)
    for i, button in ipairs(buttons) do
      if i>12 and i<15 then
        button.last = button.now
        local bx = (w/2) - (button_width/2)
        local by = (h/2) - (BUTTON_HEIGHT/2) + cursor_y
        love.graphics.setColor(0.1,0.1,0.2)
        local mx, my = love.mouse.getPosition()
        local hot = mx > bx + 100 and mx < bx + 100 + button_width and my > by and my < by + BUTTON_HEIGHT
        if hot then
          love.graphics.setColor(0.8,0.8,0.9)
        end
        button.now = love.mouse.isDown(1)
        if love.mouse.isDown(1)==true then
          love.timer.sleep(0.1)
        end
        love.timer.sleep(0)
        if button.now and not button.last and hot then
          button.fn()
        end
        love.graphics.rectangle("fill",bx+100,by,button_width,BUTTON_HEIGHT)
        love.graphics.setColor(0,0,0)
        local textW = font:getWidth(button.text)
        local textH = font:getHeight(button.text)
        love.graphics.print(button.text,font,(w/2) - textW/2+110,(by + textH/2)-10,0,0.9)
        cursor_y = cursor_y + (BUTTON_HEIGHT + margin)+75
      elseif i>14 and i<17 then
        button.last = button.now
        local bx = (w/2) - (button_width/2)
        local by = (h/2) - (BUTTON_HEIGHT/2) + cursor_y1
        love.graphics.setColor(0.1,0.1,0.2)
        local mx, my = love.mouse.getPosition()
        local hot = mx > bx - 120 and mx < bx - 120 + button_width and my > by and my < by + BUTTON_HEIGHT
        if hot then
          love.graphics.setColor(0.8,0.8,0.9)
        end
        button.now = love.mouse.isDown(1)
        if love.mouse.isDown(1)==true then
          love.timer.sleep(0.1)
        end
        love.timer.sleep(0)
        if button.now and not button.last and hot then
          button.fn()
        end
        love.graphics.rectangle("fill",bx-120,by,button_width,BUTTON_HEIGHT)
        love.graphics.setColor(0,0,0)
        local textW = font:getWidth(button.text)
        local textH = font:getHeight(button.text)
        love.graphics.print(button.text,font,((w/2) - textW/2)-120,(by + textH/2)-10)
        cursor_y1 = cursor_y1 + (BUTTON_HEIGHT + margin)+75
      end
    end
  
  elseif status=="Game over" then
    local sxm,sym=w/menubg:getWidth(),h/menubg:getHeight()
    love.graphics.draw(menubg,0,0,0,sxm,sym)
    love.graphics.setLineWidth(10)
    love.graphics.setColor(0,0,0)
    love.graphics.rectangle("fill",100,185,400,270)
    love.graphics.setColor(1.0,1.0,1.0)
    if math.ceil(y1)-1==0 then
      if surprise then
        love.graphics.draw(surprise1,0,0,0,w/surprise1:getWidth(),h/surprise1:getHeight())
        if music:isPlaying() then
          music:stop()
        end
        surprise2:play()
      else
        love.graphics.print("Congratulations!",font,160,255)
        love.graphics.print("Time: "..string.format("%.2f",time).." seconds",font,125,355)
      end
    else
      love.graphics.print("Game over!",font,210,290)
    end
  elseif status=="Pause" then
    local sxm,sym=w/menubg:getWidth(),h/menubg:getHeight()
    love.graphics.draw(menubg,0,0,0,sxm,sym)
    love.graphics.setLineWidth(10)
    love.graphics.setColor(0,0,0)
    love.graphics.rectangle("fill",100,200,400,170)
    love.graphics.setColor(1.0,1.0,1.0)
    love.graphics.print("Press space to return",font,125,210)
    love.graphics.print("Press q to quit",font,170,300)
  elseif status=="On" then
    local sx,sy=(D/nx)/background:getWidth(),(D/ny)/background:getHeight()
    for a=0,h,(D/ny) do
      for b=0,w,(D/nx) do
        love.graphics.draw(background,b,a,0,sx,sy)
      end
    end
    love.graphics.push()
     love.graphics.translate((w-D)/2,(h-D)/2)
     love.graphics.scale(D/nx,D/ny)
     map.draw(M,wall)
    love.graphics.pop()
    local sxa,sya=(2*((D/nx)/3))/avatar:getWidth(),(2*((D/ny)/3))/avatar:getHeight()
    love.graphics.draw(avatar,(w-D)/2+(x1*D/nx),(h-D)/2+(y1*D/ny),0,sxa,sya,avatar:getWidth()/2,avatar:getHeight()/2)
    if e_exist==true then
      local sxe,sye=(2*((D/nx)/3))/enemy:getWidth(),(2*((D/ny)/3))/enemy:getHeight()
      love.graphics.draw(enemy,(w-D)/2+(x*D/nx),(h-D)/2+(y*D/ny),0,sxe,sye,enemy:getWidth()/2,enemy:getHeight()/2)
    end
  end
end