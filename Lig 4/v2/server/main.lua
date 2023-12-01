--Aluno: Jerônimo Augusto Soares
--Aluno: Paulo de Tarso Fernandes


local mqtt = require("mqtt_library")

local config = dofile("config.lua")


local meuid=config.meuid
local broker=config.broker
local mqtt_client
local coTimer


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







local timer = function (tempo)
    local tempo1 = os.time()
    while true do
        --local dt = os.difftime(os.time(),tempo1)
        local dt = os.time() - tempo1
        if  dt >= tempo then
            
            print("Timer executou "..dt)
            tempo1 = os.time()
        end
        coroutine.yield()
    end
end


coTimer = coroutine.create(timer)

print("meuid="..(meuid or "nil"))
print("broker="..(broker or "nil"))



local salas = {
    ["a"]=0,
    ["b"]=0,
    ["c"]=0,
    ["d"]=0,
    ["e"]=0,
}

local function mqttcb(topic, msg)
    print("topic='"..topic.."' msg='"..msg.."'")
    local tmsg = mysplit(msg,",")
    if tmsg[1]==meuid then
        return
    end

    if tmsg[2]==meuid or tmsg[2]=="BROADCAST" then
        if tmsg[3]=="NIL" then
            local msgSend = meuid..","..tmsg[1]..","
            for sala,valor in pairs(salas) do
                if valor < 2 then
                    msgSend = msgSend..sala..";"
                end
            end
            msgSend = string.sub(msgSend,0,-2)
            mqtt_client:publish(topic,msgSend)
        else
            local qtd = salas[tmsg[3]] or 2
            if qtd == 0 then
                salas[tmsg[3]] = 1
                local msgSend = meuid..","..tmsg[1]..","..tmsg[3]..",JOG1"
                mqtt_client:publish(topic,msgSend)
            elseif qtd == 1 then
                salas[tmsg[3]] = 2
                local msgSend = meuid..","..tmsg[1]..","..tmsg[3]..",JOG2"
                mqtt_client:publish(topic,msgSend)
            else
                local msgSend = meuid..","..tmsg[1]..","..tmsg[3]..",NEG"
                mqtt_client:publish(topic,msgSend)
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

mqtt_client = mqtt.client.create(broker, 1883, mqttcb)

mqtt_client:connect("INF1350_"..meuid)
mqtt_client:subscribe({ "INF1350_LIG4" })


print("Inscrito")

coroutine.resume(coTimer,1)
while true do
    mqtt_client:handler()
    -- coroutine.resume(coTimer)
end

