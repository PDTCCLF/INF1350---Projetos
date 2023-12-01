--Aluno: Jerônimo Augusto Soares
--Aluno: Paulo de Tarso Fernandes
local botao1 = 3
local botao2 = 4
local botao3 = 5
local botao4 = 8
local meusbotoes = {botao1, botao2, botao3, botao4}

local led1 = 0
local led2 = 6
local meusleds = {led1, led2}

-- Trocar meuid em um dos jogadores
local meuid = "LIG4_A01"
local topic = "INF1350_LIG4"
--local broker="broker.hivemq.com"
local broker="192.168.20.104"
local port = 1883
local estado = "inicio"

local m

for _,ledi in ipairs (meusleds) do
    gpio.mode(ledi, gpio.OUTPUT)
    gpio.write(ledi, gpio.HIGH);
end


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

local x = 1

local matriz = {}
for i=1,6 do
    matriz[i] = {}
    for j=1,7 do
        matriz[i][j] = 0
    end 
end


local function imprimeMatriz()
    local txt = ""
    for i=6,1,-1 do
        txt=txt.."\n"
        for j=1,7 do
            txt=txt..matriz[i][j].." "
        end 
    end
    print(txt)
end


local function dropPiece(peca)
    if matriz[6][x] ~= 0 then
        return false
    elseif matriz[1][x] == 0 then
        matriz[1][x] = peca
        return true
    end
    for i=5,1,-1 do
        if matriz[i][x] ~= 0 then
            matriz[i+1][x] = peca
            break
        end
    end
    return true
end


local function verifica()
    local peca
    local pt = 0
    for i=6,1,-1 do
        for j=1,7 do
            peca = matriz[i][j]
            if peca ~= 0 then
                if i > 3 then
                    pt = 1
                    for k=1,3 do
                        if matriz[i-k][j] == peca then
                            pt = pt + 1
                        end
                     end
                     if pt == 4 then return peca end
                 end
                 if j < 5 then
                    pt = 1
                    for k=1,3 do
                        if matriz[i][j+k] == peca then
                            pt = pt + 1
                        end
                     end
                     if pt == 4 then return peca end
                 end

                 if i > 3 and j < 5 then
                    pt = 1
                    for k=1,3 do
                        if matriz[i-k][j+k] == peca then
                            pt = pt + 1
                        end
                     end
                     if pt == 4 then return peca end
                 end

                 if i > 3 and j > 3 then
                    pt = 1
                    for k=1,3 do
                        if matriz[i-k][j-k] == peca then
                            pt = pt + 1
                        end
                     end
                     if pt == 4 then return peca end
                 end
            end
        end 
    end

    return 0
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
                
                msg = meuid..",SUB"
                m:publish(topic,msg,0,0, function(client) print(msg) end)
            end,
        confail=function(client)
                gpio.write(led1, gpio.HIGH);
                gpio.write(led2, gpio.LOW);
                estado="inicio"
            end
    },
    
    jogo1 = {
        botao1=function(l,t)
                print("<-<-<")
                x = (x-2)%7+1
                print("x="..x)
                msg = meuid..",MOV,"..x
                m:publish(topic,msg,0,0, function(client) print(msg) end)
            end,
        botao2=function(l,t)
                print(">->->")
                x = (x)%7+1
                print("x="..x)
                msg = meuid..",MOV,"..x
                m:publish(topic,msg,0,0, function(client) print(msg) end)
            end,
        botao4=function(l,t)
                gpio.write(led1, gpio.HIGH);
                gpio.write(led2, gpio.LOW);
                if dropPiece(1) then
                    print("OK")
                    imprimeMatriz()
    
                    msg = meuid..",OK,"..x
                    m:publish(topic,msg,0,0, function(client) print(msg) end)
                    estado = "jogo2"
    
                    if verifica() == 1 then
                        print("VOCE VENCEU!")
                        gpio.write(led1, gpio.HIGH);
                        gpio.write(led2, gpio.HIGH);
                        estado="final"
                    end
                else
                    print("Jogada invalida")
                end
            end,
            
        message=function(client,topic,message)
                tmsg = mysplit(message,",")
                if tmsg[1]==meuid then
                    return
                elseif tmsg[2]=="SUB" then
                    msg = meuid..",JOG"
                    m:publish(topic,msg,0,0, function(client) print(msg) end)
                elseif tmsg[2]=="JOG" then
                    gpio.write(led1, gpio.HIGH);
                    gpio.write(led2, gpio.LOW);
                    estado="jogo2"
                end
            end
    },
    jogo2 = {
        message=function(client,topic,message)
                tmsg = mysplit(message,",")
                if tmsg[1]==meuid then
                    return
                elseif tmsg[2]=="OK" then
                    print(message)
                    x = tonumber(tmsg[3])
                    dropPiece(2)
                    imprimeMatriz()
                    gpio.write(led1, gpio.LOW);
                    gpio.write(led2, gpio.HIGH);
                    estado = "jogo1"
    
                    if verifica() == 2 then
                        print("VOCE PERDEU!")
                        gpio.write(led1, gpio.HIGH);
                        gpio.write(led2, gpio.HIGH);
                        estado="final"
                    end
                end
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
        end)
end



function conecta_cliente()
    print("Conectando cliente")
    m = mqtt.Client("INF1350_"..meuid, 120)
    
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
            f = maquina[estado] and maquina[estado]["message"]
                if f ~= nil then
                    f(client,topic,message)
                end
        end)

    m:on("offline",function(client)
            node.restart()
        end)
    
    m:connect(broker, port, 0, conexao_sucesso, conexao_falha)
end

