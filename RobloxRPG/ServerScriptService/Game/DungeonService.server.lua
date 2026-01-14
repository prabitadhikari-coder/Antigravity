local TeleportService = game:GetService("TeleportService")
local DungeonService = {}

local DUNGEONS = {
    ["GoblinCave"] = {
        LevelReq = 1,
        PlaceId = 0, -- Replace with actual Place ID
        Floors = 3,
        Difficulty = 1
    },
    ["DragonLair"] = {
        LevelReq = 20,
        PlaceId = 0,
        Floors = 5,
        Difficulty = 5
    }
}

function DungeonService:EnterDungeon(player, dungeonId)
    local dungeon = DUNGEONS[dungeonId]
    if not dungeon then return false, "Invalid Dungeon" end
    
    local pLevel = player:GetAttribute("Level") or 1
    if pLevel < dungeon.LevelReq then
        return false, "Level too low (Req: " .. dungeon.LevelReq .. ")"
    end
    
    -- In a real game with multiple places, we use TeleportService:ReserveServer
    -- For single-place (testing), we might just move them to a distant coordinate and spawn a copy.
    -- Let's simulate Multi-Place behaviour as it's cleaner for RPGs.
    
    print(player.Name .. " entering " .. dungeonId)
    
    -- local code = TeleportService:ReserveServer(dungeon.PlaceId)
    -- TeleportService:TeleportToPrivateServer(dungeon.PlaceId, code, {player})
    
    return true, "Teleporting..."
end

function DungeonService:GenerateFloor(floorNum, difficulty)
    -- Procedural Generation Logic
    -- 1. Create Folder
    local floor = Instance.new("Folder")
    floor.Name = "Floor_" .. floorNum
    
    -- 2. Select Room Templates (Simplified)
    -- local rooms = ServerStorage.DungeonRooms[theme]:GetChildren()
    -- Connect rooms...
    
    print("Generated Floor " .. floorNum .. " with Diff " .. difficulty)
    return floor
end

return DungeonService
