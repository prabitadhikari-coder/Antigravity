local MagicService = {}

local ELEMENTS = {
    ["Fire"] = {WeakTo="Water", StrongAgainst="Nature"},
    ["Water"] = {WeakTo="Nature", StrongAgainst="Fire"},
    ["Nature"] = {WeakTo="Fire", StrongAgainst="Water"},
    ["Light"] = {WeakTo="Dark", StrongAgainst="Dark"},
    ["Dark"] = {WeakTo="Light", StrongAgainst="Light"},
    ["Physical"] = {WeakTo="None", StrongAgainst="None"}
}

function MagicService:GetMultiplier(attackType, defenderType)
    local attDef = ELEMENTS[attackType]
    if not attDef then return 1 end
    
    if attDef.StrongAgainst == defenderType then
        return 1.5
    elseif attDef.WeakTo == defenderType then
        return 0.5
    end
    
    return 1
end

function MagicService:GetColor(elementType)
    if elementType == "Fire" then return Color3.fromRGB(255, 100, 100) end
    if elementType == "Water" then return Color3.fromRGB(100, 100, 255) end
    if elementType == "Nature" then return Color3.fromRGB(100, 255, 100) end
    if elementType == "Light" then return Color3.fromRGB(255, 255, 200) end
    if elementType == "Dark" then return Color3.fromRGB(100, 0, 100) end
    return Color3.fromRGB(200, 200, 200)
end

return MagicService
