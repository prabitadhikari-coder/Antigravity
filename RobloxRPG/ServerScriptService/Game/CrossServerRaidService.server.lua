local MS=game:GetService("MemoryStoreService"):GetSortedMap("Raid")
local TP=game:GetService("TeleportService")
return {
 Mark=function(_,p,r,pl)MS:SetAsync(tostring(p.UserId),{R=r,P=pl},600)end,
 TryRejoin=function(_,p)local d=MS:GetAsync(tostring(p.UserId));if d then TP:Teleport(d.P,p) end end
}
