
local M={}
function M:Compute(dmg,critC,critM,armor,resist)
 local crit=math.random()<critC and critM or 1
 local mitig=math.clamp(1-(armor+resist)/200,0.1,1)
 return math.floor(dmg*crit*mitig)
end
return M
