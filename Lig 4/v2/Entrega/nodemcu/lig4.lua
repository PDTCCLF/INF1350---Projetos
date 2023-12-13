--Aluno: Jerônimo Augusto Soares
--Aluno: Paulo de Tarso Fernandes

local botao1 = 3
local botao2 = 4
local botao3 = 5
local botao4 = 8
local meusbotoes = { botao1, botao2, botao3, botao4 }
local tempoAnterior = tmr.now()

local led1 = 0
local led2 = 6
local meusleds = { led1, led2 }

for _, ledi in ipairs(meusleds) do
  gpio.mode(ledi, gpio.OUTPUT)
  gpio.write(ledi, gpio.HIGH);
end

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


local config = dofile("config.lua")
print("meuid: "..config.meuid)

local consts = {
  led1 = led1,
  led2 = led2,
  estado = "inicio",
  x = 1,
  mysplit = mysplit,
  meuid = config.meuid,
  topic = config.topic
}

local maquina = dofile("maquina.lc").criaMaquina(consts)

for i, botaoi in ipairs(meusbotoes) do
  gpio.mode(botaoi, gpio.INPUT)
  local level
  if i == 4 then
    level = "up"
  else
    level = "down"
  end
  gpio.trig(botaoi, level, function(l, t)
    if tmr.now() - tempoAnterior < 250*1000 then
      return
    end
    tempoAnterior = tmr.now()
    f = maquina[consts.estado] and maquina[consts.estado]["botao" .. i]
    if f ~= nil then
      f(l, t)
    end
  end)
end


function conecta_cliente()
  print("Conectando cliente")

  consts.m = mqtt.Client("INF1350_" .. config.meuid, 120)

  local function conexao_sucesso(client)
    print("Connected to MQTT broker")
    client:subscribe(config.topic, 0, function(client)
      f = maquina[consts.estado] and maquina[consts.estado]["subscribe"]
      if f ~= nil then
        f(client)
      end
    end)
  end

  local function conexao_falha(client)
    f = maquina[consts.estado] and maquina[consts.estado]["confail"]
    if f ~= nil then
      f(client)
    end
  end

  consts.m:on("message", function(client, topic, message)
    f = maquina[consts.estado] and maquina[consts.estado]["message"]
    if f ~= nil then
      f(client, topic, message)
    end
  end)

  consts.m:on("offline", function(client)
    node.restart()
  end)

  consts.m:connect(config.broker, config.port, 0, conexao_sucesso, conexao_falha)
end
