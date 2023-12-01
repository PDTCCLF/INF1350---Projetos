--Aluno: Jerônimo Augusto Soares
--Aluno: Paulo de Tarso Fernandes

local botao1 = 3
local botao2 = 4
local botao3 = 5
local botao4 = 8
local meusbotoes = { botao1, botao2, botao3, botao4 }

local led1 = 0
local led2 = 6
local meusleds = { led1, led2 }

-- Trocar meuid em um dos jogadores
local meuid = "LIG4_A01"
local topic = "INF1350_LIG4"
local broker = "broker.hivemq.com"
local port = 1883


local matriz = {}
for i = 1, 6 do
  matriz[i] = {}
  for j = 1, 7 do
    matriz[i][j] = 0
  end
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


local function imprimeMatriz()
  local txt = ""
  for i = 6, 1, -1 do
    txt = txt .. "\n"
    for j = 1, 7 do
      txt = txt .. matriz[i][j] .. " "
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
  for i = 5, 1, -1 do
    if matriz[i][x] ~= 0 then
      matriz[i + 1][x] = peca
      break
    end
  end
  return true
end


local consts={
  led1=led1,
  led2=led2,
  matriz=matriz,
  estado="inicio",
  x=1,
  mysplit=mysplit,
  imprimeMatriz=imprimeMatriz,
  dropPiece=dropPiece,
  meuid=meuid,
  topic=topic
}


for _, ledi in ipairs(meusleds) do
  gpio.mode(ledi, gpio.OUTPUT)
  gpio.write(ledi, gpio.HIGH);
end






local maquina = dofile("maquina.lua").criaMaquina(consts)

for i, botaoi in ipairs(meusbotoes) do
  gpio.mode(botaoi, gpio.INPUT)
  local level
  if i == 4 then
    level = "up"
  else
    level = "down"
  end
  gpio.trig(botaoi, level, function(l, t)
    f = maquina[consts.estado] and maquina[consts.estado]["botao" .. i]
    if f ~= nil then
      f(l, t)
    end
  end)
end



function conecta_cliente()
  print("Conectando cliente")
  
  consts.m = mqtt.Client("INF1350_" .. meuid, 120)

  local function conexao_sucesso(client)
    print("Connected to MQTT broker")
    client:subscribe(topic, 0, function(client)
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

  consts.m:connect(broker, port, 0, conexao_sucesso, conexao_falha)
end
