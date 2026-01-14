local DataService = require(script.Parent.DataService)
local RemoteGuard = require(script.Parent.RemoteGuard)

local TradeService = {}
local ActiveTrades = {} -- {Player1 = {Partner=Player2, Offer={}, Locked=false}, Player2 = ...}

function TradeService:RequestTrade(p1, p2)
    -- Check distance, etc
    -- Notify P2
    return true
end

function TradeService:AddItem(player, itemId, amount)
    local trade = ActiveTrades[player]
    if not trade or trade.Locked then return end
    
    -- Verify ownership
    local inv = DataService:Get(player).Inventory
    if (inv[itemId] or 0) >= amount then
        trade.Offer[itemId] = (trade.Offer[itemId] or 0) + amount
    end
    
    -- Notify Partner to redraw UI
end

function TradeService:Lock(player)
    if ActiveTrades[player] then
        ActiveTrades[player].Locked = true
        -- If partner also locked, enable "Confirm" button
    end
end

function TradeService:Confirm(player)
    local t1 = ActiveTrades[player]
    local p2 = t1.Partner
    local t2 = ActiveTrades[p2]
    
    t1.Confirmed = true
    
    if t1.Confirmed and t2.Confirmed then
        self:ExecuteTrade(player, p2, t1.Offer, t2.Offer)
    end
end

function TradeService:ExecuteTrade(p1, p2, offer1, offer2)
    -- FINAL Verification check
    local d1 = DataService:Get(p1)
    local d2 = DataService:Get(p2)
    
    -- Transactional: Use pcall or carefully order operations
    -- 1. Remove items
    for item, amt in pairs(offer1) do d1.Inventory[item] -= amt end
    for item, amt in pairs(offer2) do d2.Inventory[item] -= amt end
    
    -- 2. Add items
    for item, amt in pairs(offer1) do d2.Inventory[item] = (d2.Inventory[item] or 0) + amt end
    for item, amt in pairs(offer2) do d1.Inventory[item] = (d1.Inventory[item] or 0) + amt end
    
    DataService:Save(p1)
    DataService:Save(p2)
    
    -- Close
    ActiveTrades[p1] = nil
    ActiveTrades[p2] = nil
    print("Trade Success")
end

return TradeService
