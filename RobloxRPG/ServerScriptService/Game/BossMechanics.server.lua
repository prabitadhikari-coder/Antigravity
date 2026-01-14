
local B={}
function B:Phase(hp)
 if hp>70 then return 1 elseif hp>30 then return 2 else return 3 end
end
return B
