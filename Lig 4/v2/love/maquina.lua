local function criaMaquina(consts)
    local mysplit = consts.mysplit
    local matriz = consts.matriz
    local topic = consts.topic
    local meuid = consts.meuid
    local tabela_salas = {}
    consts.ind_sala = 1
    local maquina

    maquina = {
        listando = {
            message = function(topic, msg)
                local tmsg = mysplit(msg, ",")
                if tmsg[1] == meuid then
                    return
                elseif tmsg[2] == meuid then
                    --server_id,node_id,sala1;sala2;...
                    tabela_salas = mysplit(tmsg[3], ";")

                    consts.estado = "carregando"
                    consts.desenha = false
                    -- love_id,BROADCAST,salax,GET
                    local sala = tabela_salas[consts.ind_sala]
                    consts.botao:setTexto(sala .. "...")
                    local msgSend = meuid .. ",BROADCAST," .. sala .. ",GET"
                    consts.client:publish(topic, msgSend)
                end
            end
        },

        carregando = {
            message = function(topic, msg)
                local tmsg = mysplit(msg, ",")
                if tmsg[1] == meuid then
                    return
                elseif tmsg[2] == meuid or tmsg[2] == "OBS" then
                    local sala = tabela_salas[consts.ind_sala]
                    if sala ~= tmsg[3] then return end

                    if tmsg[4] == "MATRIZ" then
                        -- server_id,love_id,salax,MATRIZ,0000000;000...,valor
                        local tStrMap = mysplit(tmsg[5], ";")
                        consts.map:redefine(tStrMap)
                        consts.map:movPiece(tonumber(tmsg[6]))
                        consts.desenha = true
                    end

                    if tmsg[4] == "QTDJOG" then
                        -- server_id,OBS,salax,QTDJOG,valor
                        consts.qtdJogadores = tonumber(tmsg[5])
                        consts.botao:setTexto(sala .. ": " .. consts.qtdJogadores .. "/2")

                        if consts.qtdJogadores == 2 then
                            consts.estado = "jogo"
                        end
                    end
                end
            end,
            botaoEsq = function()
                consts.ind_sala = consts.ind_sala - 1
                if consts.ind_sala < 1 then
                    consts.ind_sala = #tabela_salas
                end

                consts.estado = "carregando"
                consts.desenha = false
                -- love_id,BROADCAST,salax,GET
                local sala = tabela_salas[consts.ind_sala]
                consts.botao:setTexto(sala .. "...")
                local msgSend = meuid .. ",BROADCAST," .. sala .. ",GET"
                consts.client:publish(topic, msgSend)
            end,

            botaoDir = function()
                consts.ind_sala = consts.ind_sala + 1
                if consts.ind_sala > #tabela_salas then
                    consts.ind_sala = 1
                end

                consts.estado = "carregando"
                consts.desenha = false
                -- love_id,BROADCAST,salax,GET
                local sala = tabela_salas[consts.ind_sala]
                consts.botao:setTexto(sala .. "...")
                local msgSend = meuid .. ",BROADCAST," .. sala .. ",GET"
                consts.client:publish(topic, msgSend)
            end
        },

        jogo = {
            message = function(topic, msg)
                local tmsg = mysplit(msg, ",")
                if tmsg[1] == meuid then
                    return
                elseif tmsg[2] == "OBS" or tmsg[2] == meuid then
                    local sala = tabela_salas[consts.ind_sala]
                    if sala ~= tmsg[3] then return end

                    if tmsg[4] == "MOV" then
                        -- server_id,OBS,salax,MOV,valor
                        consts.map:movPiece(tonumber(tmsg[5]))
                    elseif tmsg[4] == "OK" then
                        -- server_id,OBS,salax,OK,valor
                        if tonumber(tmsg[5]) == 0 then return end
                        consts.map:movPiece(tonumber(tmsg[5]))
                        consts.map:dropPiece()
                    end
                elseif tmsg[2] == "BROADCAST" then
                    local sala = tabela_salas[consts.ind_sala]
                    if sala ~= tmsg[3] then return end
                    -- server_id,BROADCAST,salax,RESET


                    if tmsg[4] == "RESET" then
                        consts.estado = "carregando"
                        consts.desenha = false
                        -- love_id,BROADCAST,salax,GET
                        consts.botao:setTexto(sala .. "...")
                        local msgSend = meuid .. ",BROADCAST," .. sala .. ",GET"
                        consts.client:publish(topic, msgSend)
                    end
                end
            end,

            botaoEsq = function()
                consts.estado = "carregando"
                local f = maquina[consts.estado]["botaoEsq"]
                f()
            end,

            botaoDir = function()
                consts.estado = "carregando"
                local f = maquina[consts.estado]["botaoDir"]
                f()
            end
        },
    }
    return maquina
end

return { criaMaquina = criaMaquina }
