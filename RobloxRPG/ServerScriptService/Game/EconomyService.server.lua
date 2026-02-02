
local DataService = require(script.Parent.DataService)

local EconomyService = {}

-- Gold Management
function EconomyService:Spend(player, amount)
    local data = DataService:Get(player)
    if data.Gold >= amount then 
        data.Gold = data.Gold - amount
        player:SetAttribute("Gold", data.Gold)
        return true 
    end
    return false
end

function EconomyService:Earn(player, amount)
    local data = DataService:Get(player)
    data.Gold = data.Gold + amount
    player:SetAttribute("Gold", data.Gold)
end

-- Inventory Management
function EconomyService:AddItem(player, itemName, amount)
    amount = amount or 1
    if amount <= 0 then return false end -- Prevent negative add
    
    local data = DataService:Get(player)
    data.Inventory = data.Inventory or {}
    
    data.Inventory[itemName] = (data.Inventory[itemName] or 0) + amount
    -- Fire Client Event for UI Update?
    return true
end

function EconomyService:RemoveItem(player, itemName, amount)
    amount = amount or 1
    if amount <= 0 then return false end
    
    local data = DataService:Get(player)
    data.Inventory = data.Inventory or {}
    
    if (data.Inventory[itemName] or 0) >= amount then
        data.Inventory[itemName] = data.Inventory[itemName] - amount
        if data.Inventory[itemName] <= 0 then
            data.Inventory[itemName] = nil -- Clean up
        end
        return true
    end
    return false
end

function EconomyService:HasItem(player, itemName, amount)
    amount = amount or 1
    local data = DataService:Get(player)
    return (data and data.Inventory and (data.Inventory[itemName] or 0) >= amount)
end

return EconomyService
