local botao1 = 3
local botao2 = 4
local botao3 = 5
local botao4 = 8
local meusbotoes = {botao1, botao2, botao3, botao4}

local led1 = 0
local led2 = 6
local meusleds = {led1, led2}

local meuid = "LIG4_A01"
local topic = "INF1350_LIG4"

local estado = "inicio"



local m

for _,ledi in ipairs (meusleds) do
    gpio.mode(ledi, gpio.OUTPUT)
    gpio.write(ledi, gpio.HIGH);
end


local maquina = {
    inicio = {
        botao1=function(l,t)
            print("Botao 1 pressionado")
            end,
        botao2=function(l,t)
            print("Botao 2 pressionado")
            end,
        botao3=function(l,t)
            print("Botao 3 pressionado")
            end,
        botao4=function(l,t)
            print("Botao 4 pressionado")
            gpio.write(led1, gpio.LOW);
            gpio.write(led2, gpio.LOW);
            estado = "conectando"
            conecta_cliente()
            end
    },
    conectando = {
        subscribe=function(client)
            print("Conectado")
            print("Inscrito")
            gpio.write(led1, gpio.LOW);
            gpio.write(led2, gpio.HIGH);
            estado="jogo1"
            end,
        confail=function(client)
            gpio.write(led1, gpio.HIGH);
            gpio.write(led2, gpio.LOW);
            estado="inicio"
            end
    },
    
    jogo1 = {
        botao1=function(l,t)
            msg="<-<-<"
            m:publish(topic,msg,0,0, function(client) print(msg) end)
            end,
        botao2=function(l,t)
            msg=">->->"
            m:publish(topic,msg,0,0, function(client) print(msg) end)
            end,
        botao4=function(l,t)
            print("OK")
            gpio.write(led1, gpio.HIGH);
            gpio.write(led2, gpio.LOW);
            estado = "jogo2"
            end
    },
    jogo2 = {
        botao4=function(l,t)
            print("OK")
            gpio.write(led1, gpio.LOW);
            gpio.write(led2, gpio.HIGH);
            estado = "jogo1"
            end,
        message=function(client,topic,message)
            print(message)
            end
    }
    
}


for i, botaoi in ipairs (meusbotoes) do
    gpio.mode(botaoi, gpio.INPUT)
    local level
    if i == 4 then
        level = "up"
    else
        level = "down"
    end
    gpio.trig(botaoi, level, function(l,t)
            f = maquina[estado] and maquina[estado]["botao"..i]
            if f ~= nil then
                f(l,t)
            end
            
            --print("Botao "..i.." pressionado")
        end)
end



function conecta_cliente()
    print("Conectando cliente")
    m = mqtt.Client("INF1350_"..meuid, 120)
    --m:on("offline",offline)

    local function conexao_sucesso(client)
        print("Connected to MQTT broker")
        client:subscribe(topic, 0, function (client)
            f = maquina[estado] and maquina[estado]["subscribe"]
            if f ~= nil then
                f(client)
            end
            end)
    end

    local function conexao_falha(client)
        f = maquina[estado] and maquina[estado]["confail"]
        if f ~= nil then
            f(client)
        end
    end
    
    m:on("message",function(client,topic,message)
        f = maquina[estado] and maquina[estado]["menssage"]
            if f ~= nil then
                f(client,topic,message)
            end
        end)
    
    m:connect("broker.hivemq.com", 1883, 0, conexao_sucesso, conexao_falha)
end





