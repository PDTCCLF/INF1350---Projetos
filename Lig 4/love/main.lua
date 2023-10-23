--Aluno: Jerônimo Augusto Soares
--Aluno: Paulo de Tarso Fernandes
local mqtt = require("mqtt_library")
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

local meuid="LIG4_LOVE"
local broker="broker.hivemq.com"

function mysplit(inputstr, sep)
    if sep == nil then
        sep = "%s"
    end
    local t = {}
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
        table.insert(t, str)
    end
    return t
end

function love.load()
  love.window.setMode(D,D*ny/nx,{resizable = true})
  love.window.setTitle("Lig 4")
  
  
  --***************************Carregamento dos áudios*********************************************
  

  --local pathSounds="efeitos sonoros/"
  --local soundsNomes = {"peca.mp3","Victory Sound Effect.mp3"}
  
  --soundEffects = {}
  --for i, sound in pairs(soundsNomes) do
    --table.insert(soundEffects,love.audio.newSource(pathSounds..sound, "static"))
  --end
 
  --***************************Criação do mapa*********************************************
  
  consts = {["D"]=D,["nx"]=nx,["ny"]=ny,["r"]=r,["FPS"]=FPS,["duracaoFogo"]=duracaoFogo,["tempoBomba"]=tempoBomba}
  if estado == "jogo" then
    M=map.create(consts,0.0,soundEffects, walls, background)
  end
  consts.M = M
  
  love.graphics.setBackgroundColor(255,255,255)
  
  local function mqttcb (topic,msg)
    tmsg = mysplit(msg,",")
    
    if tmsg[2]=="MOV" then
        local x = tonumber(tmsg[3])
        M:movPiece(x)
    elseif tmsg[2]=="OK" then
        local x = tonumber(tmsg[3])
        M:movPiece(x)
        M:dropPiece()
    end
  end
  
  mqtt_client = mqtt.client.create(broker, 1883, mqttcb)
  
  -- Trocar XX pelo ID da etiqueta do seu NodeMCU
  mqtt_client:connect("cliente love A01")
  mqtt_client:subscribe({"INF1350_LIG4"})
  
  
end
  --***************************Criação dos avatares*********************************************
  


function love.update(dt)  
  mqtt_client:handler()
  
  if estado == "jogo" then
  
    tempoAcumulado = tempoAcumulado + dt
    if tempoAcumulado > 1/FPS then
      tempoAcumulado = tempoAcumulado - 1/FPS
      
      M:up()
    end  
  end  
end

function love.keypressed(key)
 if estado == "pause" then
    if key == "space" or key == "return" then
      estado = "jogo"
    end
  end
  if key == "." then
    M:dropPiece()
  elseif key == "left" then
    M:leftPiece()
  elseif key == "right" then
    M:rightPiece()
  end
  --mqtt_client:publish("paranodeA04", i)
end



function love.draw()
  
  --Desenho do mapa
  
  if estado == "jogo" then
    --if then

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
  consts.D = D
end

