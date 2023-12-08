--Aluno: Jerônimo Augusto Soares
--Aluno: Paulo de Tarso Fernandes


local mqtt = require("mqtt_library")

local config = dofile("config.lua")
local meuid = config.meuid
local broker = config.broker
local port = config.port
local topic = config.topic

local mqtt_client
local coTimer
local timeout = 60


local function mysplit(inputstr, sep)
    if sep == nil then
        sep = "%s"
    end
    local t = {}
    for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
        table.insert(t, str)
    end
    return t
end

local timer = function(tempo, callback)
    local tempo1 = os.time()
    while true do
        local dt = os.time() - tempo1
        if dt >= tempo then
            callback()
            break
        end
        coroutine.yield()
    end
end


coTimer = coroutine.create(timer)

print("meuid=" .. (meuid or "nil"))
print("broker=" .. (broker or "nil"))

criaMatrizVazia = dofile("matriz.lua")

local matriz = criaMatrizVazia()

local nomesSalas = {"a","ab","abc","abcd","g","gf","gfe","gfed"}

local salas = {}

for i,nome in ipairs(nomesSalas) do
    salas[nome]={}
    salas[nome].matriz = criaMatrizVazia()
    salas[nome].x = 1
    salas[nome].qtdJogadores = 0
    salas[nome].vez=1
    salas[nome].timer=nil
end

local function mqttcb(topic, msg)
    local tmsg = mysplit(msg, ",")
    if tmsg[1] == meuid then
        return
    end
    print("topic='" .. topic .. "' msg='" .. msg .. "'")

    if tmsg[2] == meuid or tmsg[2] == "BROADCAST" then
        if tmsg[3] == "NIL" then
            local msgSend = meuid .. "," .. tmsg[1] .. ","
            for _, nome in ipairs(nomesSalas) do
                local sala = salas[nome]
                local qtdJog = sala.qtdJogadores
                if qtdJog < 2 or tmsg[4] ~= nil then
                    msgSend = msgSend .. nome .. ";"
                end
            end
            msgSend = string.sub(msgSend, 0, -2)
            print(msgSend)
            mqtt_client:publish(topic, msgSend)
        else
            local sala = salas[tmsg[3]]
            local qtdJog = sala.qtdJogadores

            if tmsg[4] == "SUB" then
                -- node_id,BROADCAST,salax,SUB
                if qtdJog == 0 then
                    -- salas[tmsg[3]] = 1
                    sala.qtdJogadores = 1
                    local msgSend = meuid .. "," .. tmsg[1] .. "," .. tmsg[3] .. ",JOG1"
                    print(msgSend)
                    mqtt_client:publish(topic, msgSend)
                    sala.timer = coroutine.create(timer)
                    coroutine.resume(sala.timer, timeout, function ()
                        sala.matriz = criaMatrizVazia()
                        sala.x = 1
                        sala.qtdJogadores = 0
                        sala.vez=1
                        sala.timer=nil
                        local msgSend = meuid .. ",BROADCAST," .. tmsg[3] .. ",RESET"
                        print(msgSend)
                        mqtt_client:publish(topic, msgSend)
                    end)

                    -- server_id,OBS,salax,QTDJOG,valor
                    msgSend = meuid .. ",OBS," .. tmsg[3] .. ",QTDJOG,"
                    msgSend = msgSend..sala.qtdJogadores
                    print(msgSend)
                    mqtt_client:publish(topic, msgSend)
                elseif qtdJog == 1 then
                    -- salas[tmsg[3]] = 2
                    sala.qtdJogadores = 2
                    local msgSend = meuid .. "," .. tmsg[1] .. "," .. tmsg[3] .. ",JOG2"
                    print(msgSend)
                    mqtt_client:publish(topic, msgSend)
                    sala.timer = coroutine.create(timer)
                    coroutine.resume(sala.timer, timeout, function ()
                        sala.matriz = criaMatrizVazia()
                        sala.x = 1
                        sala.qtdJogadores = 0
                        sala.vez=1
                        sala.timer=nil
                        local msgSend = meuid .. ",BROADCAST," .. tmsg[3] .. ",RESET"
                        print(msgSend)
                        mqtt_client:publish(topic, msgSend)
                    end)


                    -- server_id,OBS,salax,QTDJOG,valor
                    msgSend = meuid .. ",OBS," .. tmsg[3] .. ",QTDJOG,"
                    msgSend = msgSend..sala.qtdJogadores
                    print(msgSend)
                    mqtt_client:publish(topic, msgSend)
                else
                    local msgSend = meuid .. "," .. tmsg[1] .. "," .. tmsg[3] .. ",NEG"
                    print(msgSend)
                    mqtt_client:publish(topic, msgSend)
                end
            elseif tmsg[4] == "MOV" then
                -- node_id,NIL,salax,MOV,valor
                sala.x = tonumber(tmsg[5])

                -- server_id,OBS,salax,MOV,valor
                local msgSend = meuid .. ",OBS," .. tmsg[3] .. ",MOV,"..sala.x
                print(msgSend)
                mqtt_client:publish(topic, msgSend)
                sala.timer = coroutine.create(timer)
                    coroutine.resume(sala.timer, timeout, function ()
                        sala.matriz = criaMatrizVazia()
                        sala.x = 1
                        sala.qtdJogadores = 0
                        sala.vez=1
                        sala.timer=nil
                        local msgSend = meuid .. ",BROADCAST," .. tmsg[3] .. ",RESET"
                        print(msgSend)
                        mqtt_client:publish(topic, msgSend)
                    end)


            elseif tmsg[4] == "OK" then
                -- node_id,NIL,salax,OK,valor
                sala.x = tonumber(tmsg[5])
                sala.matriz.dropPiece(sala.vez, sala.x)
                sala.vez = (sala.vez % 2)+1 
                
                -- server_id,OBS,salax,OK,valor
                local msgSend = meuid .. ",OBS," .. tmsg[3] .. ",OK,"..sala.x
                print(msgSend)
                mqtt_client:publish(topic, msgSend)
                local tempo
                if sala.matriz:verifica() ~= 0 then
                  tempo = 10
                else
                  tempo = timeout
                end
                
                sala.timer = coroutine.create(timer)
                coroutine.resume(sala.timer, tempo, function ()
                    sala.matriz = criaMatrizVazia()
                    sala.x = 1
                    sala.qtdJogadores = 0
                    sala.vez=1
                    sala.timer=nil
                    local msgSend = meuid .. ",BROADCAST," .. tmsg[3] .. ",RESET"
                    print(msgSend)
                    mqtt_client:publish(topic, msgSend)
                end)

                
                print(sala.matriz.toString())
            elseif tmsg[4] == "GET" then
                -- love_id,BROADCAST,salax,GET
                
                -- server_id,love_id,salax,MATRIZ,0102...,valor
                local msgSend = meuid .. "," .. tmsg[1] .. "," .. tmsg[3] .. ",MATRIZ,"
                msgSend = msgSend..sala.matriz.toString()..","..sala.x
                print(msgSend)
                mqtt_client:publish(topic, msgSend)

                -- server_id,OBS,salax,QTDJOG,valor
                msgSend = meuid .. "," .. tmsg[1] .. "," .. tmsg[3] .. ",QTDJOG,"
                msgSend = msgSend..sala.qtdJogadores
                print(msgSend)
                mqtt_client:publish(topic, msgSend)
                
            end
        end
    end


    -- tmsg = mysplit(msg, ",")

    -- if tmsg[2] == "MOV" then
    --     local x = tonumber(tmsg[3])

    -- elseif tmsg[2] == "OK" then
    --     local x = tonumber(tmsg[3])

    -- end
end

mqtt_client = mqtt.client.create(broker, port, mqttcb)

mqtt_client:connect("INF1350_" .. meuid)
mqtt_client:subscribe({ topic })


print("Inscrito")

coroutine.resume(coTimer, 4, function()
    print("A")
  end)

coroutine.resume(coTimer)

while true do
    mqtt_client:handler()
    for nome,sala in pairs(salas) do
      if sala.timer ~= nil then
        coroutine.resume(sala.timer)
      end
    end
end
