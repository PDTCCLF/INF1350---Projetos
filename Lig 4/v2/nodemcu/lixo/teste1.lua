print("Incicio teste1.lua")
print(node.heap())
if teste1 == nil then 
    teste1 = {}
end


local f = #teste1
teste1[f+1]={}
for i=1,128 do
    teste1[f+1][f+i]=f+i
end
print("f="..#teste1)

print("Final teste1.lua")
print(node.heap())
