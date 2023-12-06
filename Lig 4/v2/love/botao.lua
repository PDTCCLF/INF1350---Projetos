local function cria_botao(x,y,larg,alt)
    botao = {
        x=x,
        y=y,
        alt=alt,
        larg=larg,
        cor={0,0,0},
        corFonte={1,1,1},
        callback=nil,
        texto = ""
    }

    function botao:setColor(r, g, b)
        self.cor = {r, g, b}
    end

    function botao:setColorFont(r, g, b)
        self.corFonte = {r, g, b}
    end

    function botao:setTexto(texto)
        self.texto = texto
    end

    function botao:setBounds(x, y, larg, alt)
        self.x = x
        self.y = y
        self.larg = larg
        self.alt = alt
    end
    
    function botao:draw()
        love.graphics.setColor(self.cor)
        love.graphics.rectangle("fill", self.x, self.y, self.larg, self.alt)

        love.graphics.setColor(self.corFonte)
        local fonte = love.graphics.getFont()
        local larguraTexto = fonte:getWidth(self.texto)
        local alturaTexto = fonte:getHeight(self.texto)
        love.graphics.print(self.texto, self.x + (self.larg - larguraTexto) / 2, self.y + (self.alt - alturaTexto) / 2)
    end


    function botao:clicked(x, y)
        if x > self.x and x < self.x + self.larg and y > self.y and y < self.y + self.alt then
            if self.callback then
                self.callback()
            end
            return true
        end
        return false
    end

    function botao:setCallback(callback)
        self.callback = callback
    end

    return botao
end

return {cria_botao=cria_botao}