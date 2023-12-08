--Aluno: Jerônimo Augusto Soares
--Aluno: Paulo de Tarso Fernandes
local mqtt = require("mqtt_library")
local map = require "map"
local cria_botao = dofile("botao.lua").cria_botao
local M
local consts

local tempoAcumulado = 0

local nx, ny = 7, 8
local D = 600
local tamFont = D / 20
local FPS = 60

local config = dofile("config.lua")
local meuid = config.meuid
local broker = config.broker
local port = config.port
local topic = config.topic

local botao, botaoEsq, botaoDir

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

local matriz = {}

local constsMaq = {
    matriz = matriz,
    estado = "listando",
    mysplit = mysplit,
    meuid = config.meuid,
    topic = config.topic,
    desenha = false
}
local maquina = dofile("maquina.lua").criaMaquina(constsMaq)



function love.load()
    love.window.setMode(D, D * ny / nx, { resizable = true })
    love.window.setTitle("Lig 4")
    love.graphics.setNewFont("PixelOperator8.ttf", tamFont)

    --***************************Criação do mapa*********************************************

    consts = { ["D"] = D, ["nx"] = nx, ["ny"] = ny - 1, ["r"] = r, ["FPS"] = FPS }
    M = map.create(consts)
    consts.M = M
    constsMaq.map = M

    love.graphics.setBackgroundColor(255, 255, 255)

    --***************************Conexção com o mosquitto*********************************************

    local function mqttcb(topic, msg)
        local f = maquina[constsMaq.estado] and maquina[constsMaq.estado]["message"]
        if f ~= nil then
            f(topic, msg)
        end
    end

    local w, h = love.graphics.getWidth(), love.graphics.getHeight()

    local larg, alt = D / 5, D / ny
    botaoEsq = cria_botao(w / 2 - D / 2, h / 2 - D * ny / nx / 2, larg, alt)
    botaoDir = cria_botao(w / 2 + D / 2 - larg, h / 2 - D * ny / nx / 2, larg, alt)

    larg, alt = D - 2 * larg, D / ny
    botao = cria_botao(w / 2 - larg / 2, h / 2 - D * ny / nx / 2, larg, alt)
    constsMaq.botao = botao
    botao:setColor(0, 1, 0)
    botao:setColorFont(0, 0, 0)

    botao:setTexto("Listando")
    botaoEsq:setTexto("<--")
    botaoDir:setTexto("-->")

    botaoEsq:setCallback(function()
        local f = maquina[constsMaq.estado] and maquina[constsMaq.estado]["botaoEsq"]
        if f ~= nil then
            f()
        end
    end)

    botaoDir:setCallback(function()
        local f = maquina[constsMaq.estado] and maquina[constsMaq.estado]["botaoDir"]
        if f ~= nil then
            f()
        end
    end)

    mqtt_client = mqtt.client.create(broker, port, mqttcb)

    mqtt_client:connect("INF1350_" .. meuid)
    mqtt_client:subscribe({ topic })

    constsMaq.client = mqtt_client
    local msgSend = meuid .. ",BROADCAST,NIL,ALL"
    mqtt_client:publish(topic, msgSend)
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
        botaoEsq:clicked(x, y)
        botaoDir:clicked(x, y)
    end
end

local function drawStr(text, xc, yc)
    local texto = "CARREGANDO..."
    local fonte = love.graphics.getFont()
    local larguraTexto = fonte:getWidth(text)
    local alturaTexto = fonte:getHeight(text)
    love.graphics.print(text, xc - larguraTexto / 2, yc - alturaTexto / 2)
end

function love.draw()
    if constsMaq.desenha then
        --Desenho do mapa
        M:draw()
    end

    botao:draw()
    botaoEsq:draw()
    botaoDir:draw()
end

function love.resize(w, h)
    --Função executada quando alguém redimensiona a tela
    if w / nx < h / ny then
        D = w
    else
        D = h * nx / ny
    end
    tamFont = D / 20
    love.graphics.setNewFont("PixelOperator8.ttf", tamFont)
    consts.D = D

    local larg, alt = D / 5, D / ny
    botaoEsq:setBounds(w / 2 - D / 2, h / 2 - D * ny / nx / 2, larg, alt)
    botaoDir:setBounds(w / 2 + D / 2 - larg, h / 2 - D * ny / nx / 2, larg, alt)

    larg, alt = D - 2 * larg, D / ny
    botao:setBounds(w / 2 - larg / 2, h / 2 - D * ny / nx / 2, larg, alt)
end
