--Aluno: Jerônimo Augusto Soares
--Aluno: Paulo de Tarso Fernandes
local mqtt = require("mqtt_library")
local map = require "map"

local M
local consts

local tempoAcumulado = 0

local nx,ny=7,7
local D=700
local tamFont = D/15
local FPS = 60

local meuid="LIG4_LOVE"
local broker="broker.hivemq.com"
--local broker="192.168.20.104"


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
  
  --***************************Criação do mapa*********************************************
  
  consts = {["D"]=D,["nx"]=nx,["ny"]=ny,["r"]=r,["FPS"]=FPS}
  M=map.create(consts)
  consts.M = M
  
  love.graphics.setBackgroundColor(255,255,255)
  
  --***************************Conexção com o mosquitto*********************************************
  
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
  
  mqtt_client:connect("INF1350_..meuid")
  mqtt_client:subscribe({"INF1350_LIG4"})
end
  

function love.update(dt)  
  mqtt_client:handler()
  
  tempoAcumulado = tempoAcumulado + dt
  if tempoAcumulado > 1/FPS then
    tempoAcumulado = tempoAcumulado - 1/FPS
    
    M:up()
  end
end


function love.keypressed(key)
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
  M:draw()
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
