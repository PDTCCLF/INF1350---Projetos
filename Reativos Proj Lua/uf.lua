-- Union and find
local M = {}

function M.create()
  return {}
end

function M.addnode (uf, i)
  uf[i] = {weight=1, parent=nil}
end

function M.union (uf, i, j)
  i = M.find(uf,i)
  j = M.find(uf,j)
  if i ~= j then
    if uf[i].weight < uf[j].weight then
      uf[i].parent = j
      uf[j].weight = uf[j].weight + uf[i].weight
    else
      uf[j].parent = i
      uf[i].weight = uf[i].weight + uf[j].weight
    end
    return true
  end
  return false
end

function M.find (uf, i)
  while uf[i].parent do
    i = uf[i].parent
  end
  return i
end

return M

