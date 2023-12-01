local function verifica(matriz)
    local peca
    local pt = 0
    for i = 6, 1, -1 do
      for j = 1, 7 do
        peca = matriz[i][j]
        if peca ~= 0 then
          if i > 3 then
            pt = 1
            for k = 1, 3 do
              if matriz[i - k][j] == peca then
                pt = pt + 1
              end
            end
            if pt == 4 then return peca end
          end
          if j < 5 then
            pt = 1
            for k = 1, 3 do
              if matriz[i][j + k] == peca then
                pt = pt + 1
              end
            end
            if pt == 4 then return peca end
          end
  
          if i > 3 and j < 5 then
            pt = 1
            for k = 1, 3 do
              if matriz[i - k][j + k] == peca then
                pt = pt + 1
              end
            end
            if pt == 4 then return peca end
          end
  
          if i > 3 and j > 3 then
            pt = 1
            for k = 1, 3 do
              if matriz[i - k][j - k] == peca then
                pt = pt + 1
              end
            end
            if pt == 4 then return peca end
          end
        end
      end
    end
  
    return 0
  end
return verifica
