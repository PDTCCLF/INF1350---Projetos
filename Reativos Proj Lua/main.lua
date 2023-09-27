--Aluno: Jerônimo Augusto Soares
--Aluno: Paulo de Tarso Fernandes

local map = require "map"
local ava = require "avatar"

local M
local walls
local avatarA, avatarB
local soundEffects
local vencedor
local consts
local background
local imgBombs
local iBomb

local tempoAcumulado = 0
local tempoMorte = 0
local tempoRestart = 0
local tempoBomb = 0
local placar = {A=0, B=0}
local estado = "jogo"

local nx,ny=15,13
local D=800
local tamFont = D/15
local r=1/2
local FPS = 60

local FPSBomb = 6
local tempoBomba = 3
local duracaoFogo = 1
local maxPontos = 3


function drawCenteredText(rectX, rectY, rectWidth, rectHeight, text)
	local font       = love.graphics.getFont()
	local textWidth  = font:getWidth(text)
	local textHeight = font:getHeight()
	love.graphics.print(text, rectX+rectWidth/2, rectY+rectHeight/2, 0, 1, 1, textWidth/2, textHeight/2)
end


function love.load()
  love.window.setMode(D,D,{resizable = true})
  love.window.setTitle("Bomberman Reativos")
  love.graphics.setNewFont("PixelOperator8.ttf",tamFont)
  
  
  --***************************Carregamento dos áudios*********************************************
  
  music=love.audio.newSource("musica/Bomberman 64 Music Opening Theme.mp3", "stream")
  music:play()

  local pathSounds="efeitos sonoros/"
  local soundsNomes = {"minecraft-tnt-explosion.mp3","Death sound.mp3"}
  
  soundEffects = {}
  for i, sound in pairs(soundsNomes) do
    table.insert(soundEffects,love.audio.newSource(pathSounds..sound, "static"))
  end
  
  
  --***************************Carregamento das imagens*********************************************
 
  --Background
  local background_img=love.graphics.newImage("imagens/mapa/BackgroundTile.png")
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
  local area1,area2,area3,area4=love.graphics.newImage("imagens/mapa/SolidBlock.png"),love.graphics.newImage("imagens/mapa/tijolo.png"),love.graphics.newImage("imagens/mapa/fogo.png"),love.graphics.newImage("imagens/mapa/tijoloFogo.png")
  local imagens = {area1,area2,imgBombs[iBomb],area3,area4}
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
  
  consts = {["D"]=D,["nx"]=nx,["ny"]=ny,["r"]=r,["FPS"]=FPS,["duracaoFogo"]=duracaoFogo,["tempoBomba"]=tempoBomba}
  if estado == "jogo" then
    M=map.create(consts,0.0,soundEffects, walls, background)
  end
  consts.M = M
  
  
  --***************************Criação dos avatares*********************************************
  
  local teclasA={["left"]="a",["right"]="d",["up"]="w",["down"]="s",["A"]="e"}
  local teclasB={["left"]="left",["right"]="right",["up"]="up",["down"]="down",["A"]="rshift"}
  
  --Teclas de velocidade
  teclasA.t1="."
  teclasA.t2=","
  teclasB.t1="."
  teclasB.t2=","
  
  avatarA = ava.avatar_cria(profilesA,2,2,teclasA,consts,soundEffects[2])
  avatarB = ava.avatar_cria(profilesB,nx-1,ny-1,teclasB,consts,soundEffects[2])
  
end



function love.update(dt)  
  
  if estado == "jogo" then
  
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
    
    local sA = avatarA.status("check")
    local sB = avatarB.status("check")
    
    if not sA or not sB then
      estado = "morte"
      vencedor = nil
      if not sA and sB then
        placar.B = placar.B + 1
        vencedor = avatarB
      elseif sA and not sB then
        placar.A = placar.A + 1
        vencedor = avatarA
      end
    end
  
  elseif estado == "morte" then
    tempoMorte = tempoMorte + dt
    if tempoMorte > 2 then
      music:stop()
      local maior
      if placar.A > placar.B then
        maior = placar.A
      else
        maior = placar.B
      end
      if maior < maxPontos then
        estado="fim de partida"        
        tempoMorte = 0
        tempoRestart = 0
      else
        estado="fim de jogo"
      end
    end
  
  elseif estado == "fim de partida" then
    tempoRestart = tempoRestart + dt
    if tempoRestart > 2 then
      M:reinicia()
      music:play()
      avatarA.status("ressurect")
      avatarB.status("ressurect")
      estado="jogo"
    end
  end
  
end


function love.keypressed(key)
  if estado == "jogo" then
    avatarA.keypressed(key)
    avatarB.keypressed(key)
    if key == "space" or key == "return" then
      estado = "pause"
      music:pause()
    end
  elseif estado == "pause" then
    if key == "space" or key == "return" then
      estado = "jogo"
      music:play()
    end
  end
end



function love.draw()
  
  --Desenho do mapa
  
  if estado == "jogo" then
    if not music:isPlaying() then
      music:play()
    end
  end
  
  if estado == "jogo" or estado == "pause" or estado == "morte" then
    M:draw()
    avatarA.draw()
    avatarB.draw()
  
  elseif estado == "fim de partida" then
    local w,h = love.graphics.getWidth(),love.graphics.getHeight()
    local textoPlacar = placar.A.." x "..placar.B
    drawCenteredText(0,0, w, h + tamFont*(1), textoPlacar)
    
    avatarA.draw2(w/2+tamFont*(-2.5),h/2+tamFont*(0.5))
    avatarB.draw2(w/2+tamFont*2.5,h/2+tamFont*(0.5))
    
    if vencedor ~= nil then
      vencedor.draw2(w/2+tamFont*(-2.5),h/2+tamFont*(-2))
      drawCenteredText(0,0, w, h + tamFont*(-4), "  + 1 PT")
    else
      drawCenteredText(0,0, w, h + tamFont*(-4), "EMPATE")
    end
  
  elseif estado == "fim de jogo" then
    local w,h = love.graphics.getWidth(),love.graphics.getHeight()
    vencedor.draw2(w/2+tamFont*(-2.5),h/2+tamFont*(-2))
    drawCenteredText(0,0, w, h + tamFont*(-4), "   VENCEU")
    local textoPlacar = placar.A.." x "..placar.B
    drawCenteredText(0,0, w, h + tamFont*(1), textoPlacar)
  end
  
end

function love.resize(w, h)
  --Função executada quando alguém redimensiona a tela
  if w < h then
    D = w
  else
    D = h
  end
  tamFont = D/15
  love.graphics.setNewFont("PixelOperator8.ttf",tamFont)
  consts.D = D
end

