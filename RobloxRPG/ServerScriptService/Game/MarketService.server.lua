local DataService = require(script.Parent.DataService)
local RemoteGuard = require(script.Parent.RemoteGuard)

local MarketService = {}
local UserListings = {} -- {ListingID = {Seller=UserId, Item=ItemData, Price=100}}

local LISTING_ID_COUNTER = 1

function MarketService:ListItem(player, itemId, price)
    -- Security: Validate Input
    if type(price) ~= "number" or price <= 0 then return false, "Invalid Price" end
    if math.floor(price) ~= price then return false, "Price must be integer" end
    
    -- Check ownership (Atomic in single-thread lua context if no yields)
    local data = DataService:Get(player)
    local inventory = data.Inventory or {}
    
    if (inventory[itemId] or 0) <= 0 then return false, "Item not owned" end
    
    -- Deduct Item IMMEDIATELY
    inventory[itemId] = inventory[itemId] - 1
    if inventory[itemId] <= 0 then inventory[itemId] = nil end
    
    -- Save Logic (Yields, but state is updated in memory already)
    DataService:Save(player)
    
    -- Create Listing
    local id = LISTING_ID_COUNTER
    LISTING_ID_COUNTER += 1
    
    UserListings[id] = {
        Seller = player.UserId,
        Item = itemId,
        Price = price
    }
    
    return true, "Item Listed"
end

function MarketService:BuyItem(buyer, listingId)
    local listing = UserListings[listingId]
    if not listing then return false, "Listing not found" end
    
    -- Anti-Scalping: Purchase Cooldown (Prevent "Buying Everything")
    local lastBuy = buyer:GetAttribute("LastMarketBuy") or 0
    local now = os.clock()
    if now - lastBuy < 3 then -- 3 Seconds between allowed purchases
        return false, "Market Cooldown (Anti-Scalp)"
    end
    
    -- Race Condition Fix: Remove listing IMMEDIATELY to lock it
    UserListings[listingId] = nil 
    
    local dBuyer = DataService:Get(buyer)
    
    -- Check Gold
    if dBuyer.Gold < listing.Price then 
        -- Refund listing to market if failed
        UserListings[listingId] = listing 
        return false, "Not enough gold" 
    end
    
    -- Process Transaction
    dBuyer.Gold -= listing.Price
    dBuyer.Inventory[listing.Item] = (dBuyer.Inventory[listing.Item] or 0) + 1
    
    -- Pay Seller (Offline or Online)
    local seller = game.Players:GetPlayerByUserId(listing.Seller)
    if seller then
        local dSeller = DataService:Get(seller)
        if dSeller then
            dSeller.Gold += listing.Price
            DataService:Save(seller)
        end
    else
        -- Logic for offline handling would go here
    end
    
    DataService:Save(buyer)
    buyer:SetAttribute("LastMarketBuy", os.clock())
    -- No need to remove listing here, it's already gone.
    
    return true, "Bought " .. listing.Item
end

-- NPC Shops
function MarketService:BuyFromNPC(player, itemId, price)
    local d = DataService:Get(player)
    if d.Gold >= price then
        d.Gold -= price
        d.Inventory[itemId] = (d.Inventory[itemId] or 0) + 1
        DataService:Save(player)
        return true
    end
    return false
end

return MarketService
