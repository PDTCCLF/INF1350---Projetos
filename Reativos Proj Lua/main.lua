local map = require "map"
local ava = require "avatar"
local estado = "jogo"
local M
local nx,ny
local D=600
local walls
local avatarA, avatarB
local r=1/2
local FPS = 60
local tempoAcumulado = 0
local consts


function love.load()
  love.window.setMode(D,D,{resizable = true})
  area1,area2,area3=love.graphics.newImage("imagens/grass.jpg"),love.graphics.newImage("imagens/sponge.jpg"),love.graphics.newImage("imagens/fire.jpg")
  avatar1,avatar2,avatar3=love.graphics.newImage("imagens/cat.png"),love.graphics.newImage("imagens/dog.png"),love.graphics.newImage("imagens/raccoon.png")
  nx,ny=11,11
  
  if estado == "jogo" then
    M=map.create(nx,ny,false,0.0)
    wall=area1
  end
  local imagens = {area1,area2,area3}
  walls = {}
  for i, imagem in ipairs(imagens) do
    local wall
    wall = {}
    wall["image"] = imagem
    wall["sx"] = 1/imagem:getWidth()
    wall["sy"] = 1/imagem:getHeight()
    table.insert(walls,wall)
  end
  
  consts = {["D"]=D,["nx"]=nx,["ny"]=ny,["M"]=M,["r"]=r,["FPS"]=FPS}
  local teclasA={["left"]="left",["right"]="right",["up"]="up",["down"]="down",["A"]="rshift"}
  local teclasB={["left"]="a",["right"]="d",["up"]="w",["down"]="s",["A"]="e"}
  
  --Teclas de teste
  teclasA.t1="."
  teclasA.t2=","
  teclasB.t1="."
  teclasB.t2=","
  
  avatarA = ava.avatar_cria(avatar2,2,2,teclasA,consts)
  avatarB = ava.avatar_cria(avatar3,nx-1,ny-1,teclasB,consts)
  
end


function love.update(dt)
  tempoAcumulado = tempoAcumulado + dt
  if tempoAcumulado > 1/FPS then
    avatarA.up()
    avatarB.up()
    tempoAcumulado = tempoAcumulado - 1/FPS
  end  
end


function love.keypressed(key)
  avatarA.keypressed(key)
  avatarB.keypressed(key)
end


function love.draw()
  local w,h = love.graphics.getWidth(),love.graphics.getHeight()
  
  --Desenho do mapa
  love.graphics.push()
  love.graphics.translate((w-D)/2,(h-D)/2)
  love.graphics.scale(D/nx,D/ny)
  map.draw(M,walls)
  love.graphics.pop()
  
  avatarA.draw()
  avatarB.draw()
  
end

function love.resize(w, h)
  --Função executada quando alguém redimensiona a tela
  if w < h then
    D = w
  else
    D = h
  end
  consts.D = D
  --avatarA.set_D(D)
  --avatarB.set_D(D)
end

