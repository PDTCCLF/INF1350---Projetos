local matriz = {}
local beep = dofile("beep.lua")
for i = 1, 6 do
  matriz[i] = {}
  for j = 1, 7 do
    matriz[i][j] = 0
  end
end


function matriz.imprime()
  local txt = ""
  for i = 6, 1, -1 do
    txt = txt .. "\n"
    for j = 1, 7 do
      txt = txt .. matriz[i][j] .. " "
    end
  end
  print(txt)
end

function matriz.dropPiece(peca, x)
  local dt = 160
  local notas = {}
  notas[2] = { 1000, 200 }
  if matriz[6][x] ~= 0 then
    return false
  elseif matriz[1][x] == 0 then
    matriz[1][x] = peca
    dt = dt * 6
    notas[1] = { 1, dt }
    beep(notas)
    return true
  end
  for i = 5, 1, -1 do
    if matriz[i][x] ~= 0 then
      matriz[i + 1][x] = peca
      dt = dt * (6-i)
      break
    end
  end
  notas[1] = { 1, dt }
  beep(notas)
  return true
end

function matriz.verifica()
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

return matriz
