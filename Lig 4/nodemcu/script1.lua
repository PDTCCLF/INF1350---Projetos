-- MUDAR meu id!!!!
local meuid = "A04"
local m = mqtt.Client("clientid " .. meuid, 120)

function publica(c)
  c:publish("paraloveA04","alo de " .. meuid,0,0, 
            function(client) print("mandou!") end)
end

function novaInscricao (c)
  local msgsrec = 0
  function novamsg (c, t, m)
    print ("mensagem ".. msgsrec .. ", topico: ".. t .. ", dados: " .. m)
    msgsrec = msgsrec + 1
  end
  c:on("message", novamsg)
end

function conectado (client)
  publica(client)
  client:subscribe("paranodeA04", 0, novaInscricao)
end 

m:connect("139.82.100.100", 7981, false,
--m:connect("test.mosquitto.org", 1883, false, 
             conectado,
             function(client, reason) print("failed reason: "..reason) end)