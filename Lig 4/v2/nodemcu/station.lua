-- Conexão: conectando-se a uma rede existente

local cred = dofile('credenciais.lua')

wificonf = {
    -- verificar ssid e senha
    ssid = cred.ssid,
    pwd = cred.pwd,
    got_ip_cb = function (con)
        print ("meu IP: ", con.IP)
        local led1 = 0
        local led2 = 6
        local meusleds = {led1, led2}
        for _,ledi in ipairs (meusleds) do
            gpio.mode(ledi, gpio.OUTPUT)
            gpio.write(ledi, gpio.HIGH);
        end
        print(node.heap())
        dofile('lig4.lua')
        -- esperar obter IP para
        -- qualquer comunicação!!!
        end,
    save = false}

wifi.setmode(wifi.STATION)
wifi.sta.config(wificonf)
