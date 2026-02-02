local Definitions = require(game.ReplicatedStorage.GameData.Definitions)

local LootService = {}

function LootService:RollTable(tableName)
    local tableData = Definitions.LootTables[tableName]
    if not tableData then return nil end
    
    -- Calculate Total Weight
    local totalWeight = 0
    for _, entry in ipairs(tableData) do
        totalWeight = totalWeight + (entry.Weight or 0)
    end
    
    -- Roll
    local r = math.random(1, totalWeight)
    local current = 0
    
    for _, entry in ipairs(tableData) do
        current = current + (entry.Weight or 0)
        if r <= current then
            -- Return a copy to avoid mutating definition
            return {
                Item = entry.Item,
                Amount = entry.Amount or 1 -- Handle Amount Range Logic here if needed
            }
        end
    end
    
    return nil
end

function LootService:DropLoot(position, tableName)
    local loot = self:RollTable(tableName)
    if loot then
        print("Dropped " .. loot.Item .. " at " .. tostring(position))
        -- Spawn Physical Part or Orb
    end
end

return LootService
