
local E={}
function E:Spend(p,g)
 local gold=p:GetAttribute('Gold')
 if gold>=g then p:SetAttribute('Gold',gold-g) return true end
end
return E
