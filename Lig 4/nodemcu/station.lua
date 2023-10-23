-- Conexão: conectando-se a uma rede existente

local cred = dofile('credenciais.lua')

wificonf = {
 -- verificar ssid e senha
 ssid = cred.ssid,
 pwd = cred.pwd,
 got_ip_cb = function (con)
 print ("meu IP: ", con.IP)
 -- esperar obter IP para
 -- qualquer comunicação!!!
 end,
 save = false}
wifi.setmode(wifi.STATION)
wifi.sta.config(wificonf)
