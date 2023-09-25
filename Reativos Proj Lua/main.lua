--Aluno: Jerônimo Augusto Soares
--Aluno: Paulo de Tarso Fernandes

local map = require "map"
local ava = require "avatar"
local estado = "jogo"
local numPartidas = 3
local M
local nx,ny=11,11
local D=800
local walls
local avatarA, avatarB
local r=1/2
local FPS = 60
local tempoAcumulado = 0
local tempoMorte = 0
local tempoRestart = 0
local consts
local background

local imgBombs
local iBomb
local FPSBomb = 6
local tempoBomb = 0

local soundEffects


function love.load()
  love.window.setMode(D,D,{resizable = true})
  
  
  --***************************Carregamento dos áudios*********************************************
  
  music=love.audio.newSource("musica/Bomberman 64 Music Opening Theme.mp3", "stream")
  music:play()

  local pathSounds="efeitos sonoros/"
  local soundsNomes = {"Explosion sound.mp3","Death sound.mp3"}
  
  soundEffects = {}
  for i, sound in pairs(soundsNomes) do
    table.insert(soundEffects,love.audio.newSource(pathSounds..sound, "static"))
  end
  
  --***************************Carregamento das imagens*********************************************
 
  --Background
  local background_img=love.graphics.newImage("imagens/mapa/background.png")
  background = {}
  background["image"] = background_img
  background["sx"] = 1/background_img:getWidth()
  background["sy"] = 1/background_img:getHeight()
  
  
  --Bombas
  local pathBombs="imagens/bomba/"
  local imgNomesBombs = {"Bomb_f01.png","Bomb_f02.png","Bomb_f03.png"}
  imgBombs = {}
  for i, img in pairs(imgNomesBombs) do
    table.insert(imgBombs,love.graphics.newImage(pathBombs..img))
  end
  iBomb=1
  
  --Paredes
  local area1,area2,area3=love.graphics.newImage("imagens/mapa/grass.jpg"),love.graphics.newImage("imagens/mapa/sponge.jpg"),love.graphics.newImage("imagens/mapa/fire.jpg")
  local imagens = {area1,area2,imgBombs[iBomb],area3}
  walls = {}
  for i, imagem in ipairs(imagens) do
    local wall = {}
    wall["image"] = imagem
    wall["sx"] = 1/imagem:getWidth()
    wall["sy"] = 1/imagem:getHeight()
    table.insert(walls,wall)
  end
 
  --AvatarA
  local pathAvatarAfront = "imagens/avatarA/front/"
  local pathAvatarAback = "imagens/avatarA/back/"
  local pathAvatarAright = "imagens/avatarA/right/"
  local pathAvatarAleft = "imagens/avatarA/left/"
  local imgNomesAfront = {"Bman_F_f00.png","Bman_F_f01.png","Bman_F_f02.png","Bman_F_f03.png","Bman_F_f04.png","Bman_F_f05.png","Bman_F_f06.png","Bman_F_f07.png"}
  local imgNomesAback = {"Bman_B_f00.png","Bman_B_f01.png","Bman_B_f02.png","Bman_B_f03.png","Bman_B_f04.png","Bman_B_f05.png","Bman_B_f06.png","Bman_B_f07.png"}
  local imgNomesAright = {"Bman_F_f00.png","Bman_F_f01.png","Bman_F_f02.png","Bman_F_f03.png","Bman_F_f04.png","Bman_F_f05.png","Bman_F_f06.png","Bman_F_f07.png"}
  local imgNomesAleft = {"Bman_F_f00.png","Bman_F_f01.png","Bman_F_f02.png","Bman_F_f03.png","Bman_F_f04.png","Bman_F_f05.png","Bman_F_f06.png","Bman_F_f07.png"}
  local profilesA = {}
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
  
  --AvatarB
  local pathAvatarBfront = "imagens/avatarB/front/"
  local pathAvatarBback = "imagens/avatarB/back/"
  local pathAvatarBright = "imagens/avatarB/right/"
  local pathAvatarBleft = "imagens/avatarB/left/"
  local imgNomesBfront = {"Creep_F_f00.png","Creep_F_f01.png","Creep_F_f02.png","Creep_F_f03.png","Creep_F_f04.png","Creep_F_f05.png"}
  local imgNomesBback = {"Creep_B_f00.png","Creep_B_f01.png","Creep_B_f02.png","Creep_B_f03.png","Creep_B_f04.png","Creep_B_f05.png"}
  local imgNomesBright = {"Creep_S_f00.png","Creep_S_f01.png","Creep_S_f02.png","Creep_S_f03.png","Creep_S_f04.png","Creep_S_f05.png","Creep_S_f06.png"}
  local imgNomesBleft = {"Creep_S_f00.png","Creep_S_f01.png","Creep_S_f02.png","Creep_S_f03.png","Creep_S_f04.png","Creep_S_f05.png","Creep_S_f06.png"}
  local profilesB = {}
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
  
  
  
  --***************************Criação do mapa*********************************************
  
  consts = {["D"]=D,["nx"]=nx,["ny"]=ny,["r"]=r,["FPS"]=FPS}
  if estado == "jogo" then
    M=map.create(consts,0.0,soundEffects, walls, background)
  end
  consts.M = M
  
  --***************************Criação dos avatares*********************************************
  
  local teclasA={["left"]="left",["right"]="right",["up"]="up",["down"]="down",["A"]="rshift"}
  local teclasB={["left"]="a",["right"]="d",["up"]="w",["down"]="s",["A"]="e"}
  
  --Teclas de teste
  teclasA.t1="."
  teclasA.t2=","
  teclasB.t1="."
  teclasB.t2=","
  
  avatarA = ava.avatar_cria(profilesA,2,2,teclasA,consts,soundEffects[2])
  avatarB = ava.avatar_cria(profilesB,nx-1,ny-1,teclasB,consts,soundEffects[2])
  
end



function love.update(dt)  
  tempoAcumulado = tempoAcumulado + dt
  if tempoAcumulado > 1/FPS then
    tempoAcumulado = tempoAcumulado - 1/FPS
    
    avatarA.up()
    avatarB.up()
    M:up()
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
  
  if avatarA.status("check") == false or avatarB.status("check") == false then
    tempoMorte = tempoMorte + dt
    if tempoMorte > 2 then
      music:stop()
      estado="fim de partida"
      numPartidas = numPartidas - 1
      tempoMorte = 0
    end
  end

  if estado == "fim de partida" then
    tempoRestart = tempoRestart + dt
    if tempoRestart > 2 and numPartidas > 0 then
      estado="jogo"
      if avatarA.status("check") == false then
        avatarA.status("change")
      elseif avatarB.status("check") == false then
        avatarB.status("change")
      end
    end
  end
end


function love.keypressed(key)
  avatarA.keypressed(key)
  avatarB.keypressed(key)
end


function love.draw()
  
  --Desenho do mapa
  if estado == "jogo" then
    M:draw()
    avatarA.draw()
    avatarB.draw()
  end
  
end

function love.resize(w, h)
  --Função executada quando alguém redimensiona a tela
  if w < h then
    D = w
  else
    D = h
  end
  consts.D = D
end

