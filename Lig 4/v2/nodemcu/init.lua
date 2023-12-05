tmr.delay(1000 * 1000 * 5)

print("INIT")
local led1 = 0
local led2 = 6
local meusleds = { led1, led2 }

for _, ledi in ipairs(meusleds) do
  gpio.mode(ledi, gpio.OUTPUT)
  gpio.write(ledi, gpio.LOW);
end

dofile('station.lua')
