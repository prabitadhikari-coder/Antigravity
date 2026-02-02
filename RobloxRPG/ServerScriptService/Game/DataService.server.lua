local DSS = game:GetService("DataStoreService")
local Store = DSS:GetDataStore("PLAYER_DATA_V3") -- Bump version for schema change
local D = {}

local DEFAULT_DATA = {
    Level = 1,
    XP = 0,
    Gold = 0,
    Class = "None",
    Skills = {}, -- {SkillName = Level}
    Talents = {}, -- {TalentID = Rank}
    Inventory = {}, -- {ItemID = Amount}
    Equipment = {
        MainHand = nil,
        OffHand = nil,
        Armor = nil
    },
    DungeonHistory = {}, -- {DungeonID = ClearCount}
    Reputation = 0,
    Cosmetics = {}
}

function D:Load(p)
    local success, data = pcall(function()
        return Store:GetAsync(p.UserId)
    end)
    
    if not success then
        warn("Failed to load data for " .. p.Name)
        -- Implement retry logic or kick to prevent data loss on save
    end
    
    data = data or {}
    
    -- Reconcile with defaults
    for k, v in pairs(DEFAULT_DATA) do
        if data[k] == nil then
            data[k] = v
        end
    end
    
    -- Set Attributes for easy replication/access
    p:SetAttribute("Level", data.Level)
    p:SetAttribute("XP", data.XP)
    p:SetAttribute("Gold", data.Gold)
    p:SetAttribute("Class", data.Class)
    p:SetAttribute("Reputation", data.Reputation)
    
    -- Store complex tables in a cache (attributes are limited to basic types usually, or use JSON)
    -- For now, we'll keep complex data in a Module-level cache or just raw tables if we don't need instant replication via attributes
    -- Let's use a Session Cache
    D.SessionData = D.SessionData or {}
    D.SessionData[p.UserId] = data
end

function D:Save(p, final)
    if not D.SessionData then return end
    local session = D.SessionData[p.UserId]
    if not session then return end
    
    -- Update session from attributes if changed there
    session.Level = p:GetAttribute("Level")
    session.XP = p:GetAttribute("XP")
    session.Gold = p:GetAttribute("Gold")
    session.Class = p:GetAttribute("Class")
    session.Reputation = p:GetAttribute("Reputation")
    
    local success, err = pcall(function()
        Store:SetAsync(p.UserId, session)
    end)
    
    if not success then
        warn("Failed to save data for " .. p.Name .. ": " .. err)
    end
    
    if final then
        D.SessionData[p.UserId] = nil
        print("Data saved & session closed for " .. p.Name)
    end
end

function D:Get(p)
    return D.SessionData[p.UserId]
end

return D
