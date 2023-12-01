tmr.delay(1000*1000*3)

print("INIT")
local led1 = 0
local led2 = 6
local meusleds = {led1, led2}

local botao1 = 3
local botao2 = 4
local botao3 = 5
local botao4 = 8
local meusbotoes = {botao1, botao2, botao3, botao4}

for _,ledi in ipairs (meusleds) do
    gpio.mode(ledi, gpio.OUTPUT)
    gpio.write(ledi, gpio.LOW);
end

dofile('station.lua')