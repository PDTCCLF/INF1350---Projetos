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

local imgBombs
local iBomb
local FPSBomb = 6
local tempoBomb = 0

function love.load()
  love.window.setMode(D,D,{resizable = true})
  area1,area2,area3=love.graphics.newImage("imagens/mapa/grass.jpg"),love.graphics.newImage("imagens/mapa/sponge.jpg"),love.graphics.newImage("imagens/mapa/fire.jpg")
  nx,ny=11,11
  
  pathBombs="imagens/bomba/"
  imgNomesBombs = {"Bomb_f01.png","Bomb_f02.png","Bomb_f03.png"}

  imgBombs = {}
  for i, img in pairs(imgNomesBombs) do
    table.insert(imgBombs,love.graphics.newImage(pathBombs..img))
  end
  iBomb=1

  
  pathAvatarAfront = "imagens/avatarA/front/"
  pathAvatarAback = "imagens/avatarA/back/"
  pathAvatarAright = "imagens/avatarA/right/"
  pathAvatarAleft = "imagens/avatarA/left/"
  imgNomesAfront = {"Bman_F_f00.png","Bman_F_f01.png","Bman_F_f02.png","Bman_F_f03.png","Bman_F_f04.png","Bman_F_f05.png","Bman_F_f06.png","Bman_F_f07.png"}
  imgNomesAback = {"Bman_B_f00.png","Bman_B_f01.png","Bman_B_f02.png","Bman_B_f03.png","Bman_B_f04.png","Bman_B_f05.png","Bman_B_f06.png","Bman_B_f07.png"}
  imgNomesAright = {"Bman_F_f00.png","Bman_F_f01.png","Bman_F_f02.png","Bman_F_f03.png","Bman_F_f04.png","Bman_F_f05.png","Bman_F_f06.png","Bman_F_f07.png"}
  imgNomesAleft = {"Bman_F_f00.png","Bman_F_f01.png","Bman_F_f02.png","Bman_F_f03.png","Bman_F_f04.png","Bman_F_f05.png","Bman_F_f06.png","Bman_F_f07.png"}
  profilesA = {}
  profilesA.front = {}
  profilesA.back = {}
  profilesA.right = {}
  profilesA.left = {}
  for i ,img in pairs(imgNomesAfront) do
    table.insert(profilesA.front,love.graphics.newImage(pathAvatarAfront..img))
  end
  for i ,img in pairs(imgNomesAback) do
    table.insert(profilesA.back,love.graphics.newImage(pathAvatarAback..img))
  end
  for i ,img in pairs(imgNomesAright) do
    table.insert(profilesA.right,love.graphics.newImage(pathAvatarAright..img))
  end
  for i ,img in pairs(imgNomesAleft) do
    table.insert(profilesA.left,love.graphics.newImage(pathAvatarAleft..img))
  end
  
  pathAvatarBfront = "imagens/avatarB/front/"
  pathAvatarBback = "imagens/avatarB/back/"
  pathAvatarBright = "imagens/avatarB/right/"
  pathAvatarBleft = "imagens/avatarB/left/"
  imgNomesBfront = {"Creep_F_f00.png","Creep_F_f01.png","Creep_F_f02.png","Creep_F_f03.png","Creep_F_f04.png","Creep_F_f05.png"}
  imgNomesBback = {"Creep_B_f00.png","Creep_B_f01.png","Creep_B_f02.png","Creep_B_f03.png","Creep_B_f04.png","Creep_B_f05.png"}
  imgNomesBright = {"Creep_S_f00.png","Creep_S_f01.png","Creep_S_f02.png","Creep_S_f03.png","Creep_S_f04.png","Creep_S_f05.png","Creep_S_f06.png"}
  imgNomesBleft = {"Creep_S_f00.png","Creep_S_f01.png","Creep_S_f02.png","Creep_S_f03.png","Creep_S_f04.png","Creep_S_f05.png","Creep_S_f06.png"}
  profilesB = {}
  profilesB.front = {}
  profilesB.back = {}
  profilesB.right = {}
  profilesB.left = {}
  for i ,img in pairs(imgNomesBfront) do
    table.insert(profilesB.front,love.graphics.newImage(pathAvatarBfront..img))
  end
  for i ,img in pairs(imgNomesBback) do
    table.insert(profilesB.back,love.graphics.newImage(pathAvatarBback..img))
  end
  for i ,img in pairs(imgNomesBright) do
    table.insert(profilesB.right,love.graphics.newImage(pathAvatarBright..img))
  end
  for i ,img in pairs(imgNomesBleft) do
    table.insert(profilesB.left,love.graphics.newImage(pathAvatarBleft..img))
  end
  
  
  
  
  if estado == "jogo" then
    M=map.create(nx,ny,false,0.0)
    wall=area1
  end
  local imagens = {area1,area2,imgBombs[iBomb],area3}
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
  
  --avatarA = ava.avatar_cria(avatar2,2,2,teclasA,consts)
  avatarA = ava.avatar_cria(profilesA,2,2,teclasA,consts)
  avatarB = ava.avatar_cria(profilesB,nx-1,ny-1,teclasB,consts)
  
end


function love.update(dt)
  tempoAcumulado = tempoAcumulado + dt
  if tempoAcumulado > 1/FPS then
    avatarA.up()
    avatarB.up()
    tempoAcumulado = tempoAcumulado - 1/FPS
  end  
  
  tempoBomb = tempoBomb + dt
    
  if tempoBomb > 1/FPSBomb then
    tempoBomb = tempoBomb - 1/FPSBomb
    iBomb = iBomb + 1
    if iBomb > #imgBombs then
      iBomb = 1
    end
    walls[3].image = imgBombs[iBomb]
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

