
local P={}
local C={}
function P:Roll(p)
 C[p]=C[p] or 0
 C[p]+=1
 if C[p]>=50 then C[p]=0 return 'Legendary' end
end
return P
