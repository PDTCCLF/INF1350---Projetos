--Aluno: Jerônimo Augusto Soares
--Aluno: Paulo de Tarso Fernandes
local mqtt = require("mqtt_library")
local map = require "map"
local cria_botao = dofile("botao.lua").cria_botao
local M
local consts

local tempoAcumulado = 0

local nx, ny = 7, 8
local D = 700
local tamFont = D / 20
local FPS = 60
local flag = false

local config = dofile("config.lua")
local meuid = config.meuid
local broker = config.broker
local port = config.port
local topic = config.topic

local botao

function mysplit(inputstr, sep)
    if sep == nil then
        sep = "%s"
    end
    local t = {}
    for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
        table.insert(t, str)
    end
    return t
end

function love.load()
    love.window.setMode(D, D * ny / nx, { resizable = true })
    love.window.setTitle("Lig 4")
    love.graphics.setNewFont("PixelOperator8.ttf",tamFont)

    --***************************Criação do mapa*********************************************

    consts = { ["D"] = D, ["nx"] = nx, ["ny"] = ny-1, ["r"] = r, ["FPS"] = FPS }
    M = map.create(consts)
    consts.M = M

    love.graphics.setBackgroundColor(255, 255, 255)

    --***************************Conexção com o mosquitto*********************************************

    local function mqttcb(topic, msg)
        tmsg = mysplit(msg, ",")

        if tmsg[2] == "MOV" then
            local x = tonumber(tmsg[3])
            M:movPiece(x)
        elseif tmsg[2] == "OK" then
            local x = tonumber(tmsg[3])
            M:movPiece(x)
            M:dropPiece()
        end
    end

    mqtt_client = mqtt.client.create(broker, port, mqttcb)

    mqtt_client:connect("INF1350_" .. meuid)
    mqtt_client:subscribe({ topic })


    local w,h = love.graphics.getWidth(),love.graphics.getHeight()

    botao = cria_botao(w/2-D/5,h/2-D/20,D*2/5,D*2/20)

    botao:setColor(1,0,1)
    botao:setCallback(function ()
        flag = not flag
    end)

    botao:setTexto("Pressione")



end

function love.update(dt)
    mqtt_client:handler()

    tempoAcumulado = tempoAcumulado + dt
    if tempoAcumulado > 1 / FPS then
        tempoAcumulado = tempoAcumulado - 1 / FPS

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

function love.mousepressed(x, y, button, istouch, presses)
    if button == 1 then -- O número 1 corresponde ao botão esquerdo do mouse
        botao:clicked(x, y)
        -- print("O botão esquerdo do mouse foi clicado na posição x = " .. x .. ", y = " .. y)
    end
end

function love.draw()
    --Desenho do mapa
    if flag then
        M:draw()
    end
    botao:draw()
end

function love.resize(w, h)
    --Função executada quando alguém redimensiona a tela
    if w / nx < h / ny then
        D = w
    else
        D = h * nx / ny
    end
    tamFont = D / 20
    love.graphics.setNewFont("PixelOperator8.ttf",tamFont)
    consts.D = D

    botao:setBounds(w/2-D/5,h/2-D/20,D*2/5,D*2/20)

end
