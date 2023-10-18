--Aluno: Jerônimo Augusto Soares
--Aluno: Paulo de Tarso Fernandes

local map = require "map"

local M
local walls
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

local nx,ny=7,7
local D=700
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
  love.window.setMode(D,D*ny/nx,{resizable = true})
  love.window.setTitle("Lig 4")
  love.graphics.setNewFont("PixelOperator8.ttf",tamFont)
  
  
  --***************************Carregamento dos áudios*********************************************
  
  music=love.audio.newSource("musica/Bomberman 64 Music Opening Theme.mp3", "stream")
  --music:play()

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
 
  --***************************Criação do mapa*********************************************
  
  consts = {["D"]=D,["nx"]=nx,["ny"]=ny,["r"]=r,["FPS"]=FPS,["duracaoFogo"]=duracaoFogo,["tempoBomba"]=tempoBomba}
  if estado == "jogo" then
    M=map.create(consts,0.0,soundEffects, walls, background)
  end
  consts.M = M
  
  love.graphics.setBackgroundColor(255,255,255)
  
end
  --***************************Criação dos avatares*********************************************
  


function love.update(dt)  
  
  if estado == "jogo" then
  
    tempoAcumulado = tempoAcumulado + dt
    if tempoAcumulado > 1/FPS then
      tempoAcumulado = tempoAcumulado - 1/FPS
      
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
    
end
  
end


function love.keypressed(key)
 if estado == "pause" then
    if key == "space" or key == "return" then
      estado = "jogo"
      --music:play()
    end
  end
  if key == "." then
    M:dropPiece()
  elseif key == "left" then
    M:leftPiece()
  elseif key == "right" then
    M:rightPiece()
  end
    
end



function love.draw()
  
  --Desenho do mapa
  
  if estado == "jogo" then
    --if not music:isPlaying() then
      --music:play()
    --end
  end
  
  if estado == "jogo" or estado == "pause" or estado == "morte" then
    M:draw()
  end
end



function love.resize(w, h)
  --Função executada quando alguém redimensiona a tela
  if w/nx < h/ny then
    D = w
  else
    D = h*nx/ny
  end
  tamFont = D/15
  love.graphics.setNewFont("PixelOperator8.ttf",tamFont)
  consts.D = D
end

