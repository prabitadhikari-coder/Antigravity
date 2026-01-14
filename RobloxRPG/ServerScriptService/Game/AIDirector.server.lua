local A={}
local S={}
function A:Track(i,e) S[i]=S[i] or {D=0};if e=='Death' then S[i].D+=1 end end
function A:Modifier(i) return (S[i] and S[i].D==0) and 1.25 or 1 end
return A
