
local A={};local D={}
function A:Log(i,r) D[i]=(D[i] or 0)+r end
function A:Score(i) return D[i] or 0 end
return A
