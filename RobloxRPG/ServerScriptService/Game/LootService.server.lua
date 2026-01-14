
local L={}
local Tables={Common=70,Rare=25,Legendary=5}
function L:Roll()
 local r=math.random(100);local a=0
 for k,v in pairs(Tables) do a+=v;if r<=a then return k end end
end
return L
