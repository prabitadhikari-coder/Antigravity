local DataService = require(script.Parent.DataService)
local RemoteGuard = require(script.Parent.RemoteGuard)

local MarketService = {}
local UserListings = {} -- {ListingID = {Seller=UserId, Item=ItemData, Price=100}}

local LISTING_ID_COUNTER = 1

function MarketService:ListItem(player, itemId, price)
    -- Check ownership
    local inventory = DataService:Get(player).Inventory or {}
    if (inventory[itemId] or 0) <= 0 then return false, "Item not owned" end
    
    -- Deduct Item
    inventory[itemId] = inventory[itemId] - 1
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
    
    local dBuyer = DataService:Get(buyer)
    if dBuyer.Gold < listing.Price then return false, "Not enough gold" end
    
    -- Process Transaction
    dBuyer.Gold -= listing.Price
    dBuyer.Inventory[listing.Item] = (dBuyer.Inventory[listing.Item] or 0) + 1
    
    -- Pay Seller (Offline or Online)
    -- If online, find player. If offline, load DataStore ?
    -- Simplified: Assume online or use OfflineDataService (not implemented fully here).
    -- For safety, we only support online sellers in this MVP or "Mail" system later.
    local seller = game.Players:GetPlayerByUserId(listing.Seller)
    if seller then
        local dSeller = DataService:Get(seller)
        dSeller.Gold += listing.Price
        DataService:Save(seller)
    else
        -- TODO: Implement Offline Inbox
        warn("Seller offline, gold sent to void (Need Inbox)")
    end
    
    DataService:Save(buyer)
    UserListings[listingId] = nil -- Remove listing
    
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
