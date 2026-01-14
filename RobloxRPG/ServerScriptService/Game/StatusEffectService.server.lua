
local S={}
function S:Apply(t,e,d)
 t:SetAttribute(e,true)
 task.delay(d,function() t:SetAttribute(e,false) end)
end
return S
