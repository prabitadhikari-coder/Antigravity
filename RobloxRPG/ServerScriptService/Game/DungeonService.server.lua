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
    
    -- Security: State Check
    if player:GetAttribute("IsTeleporting") then
        return false, "Already teleporting"
    end
    
    -- Security: Generic Cooldown
    local now = os.clock()
    local lastEnter = player:GetAttribute("LastDungeonEnter") or 0
    if now - lastEnter < 5 then -- 5 Second Cooldown
        return false, "Slow down"
    end
    
    player:SetAttribute("IsTeleporting", true)
    player:SetAttribute("LastDungeonEnter", now)
    
    -- In a real game with multiple places, we use TeleportService:ReserveServer
    -- For single-place (testing), we might just move them to a distant coordinate and spawn a copy.
    -- Let's simulate Multi-Place behaviour as it's cleaner for RPGs.
    
    print(player.Name .. " entering " .. dungeonId)
    
    -- local code = TeleportService:ReserveServer(dungeon.PlaceId)
    -- TeleportService:TeleportToPrivateServer(dungeon.PlaceId, code, {player})
    
    return true, "Teleporting..."
end

function DungeonService:GenerateFloor(floorNum, difficulty)
    -- Procedural Generation: Grid Based
    local floor = Instance.new("Folder")
    floor.Name = "Floor_" .. floorNum
    
    local gridSize = 5 + floorNum -- Larger floors as we go deeper
    local roomSize = 60
    
    local rooms = {} -- [x][z] = RoomType
    local generatedModels = {}
    
    -- 1. Helper to Determine Room Type
    -- Simple linear path for now + branches?
    -- Let's do random placement for demo.
    
    local startX, startZ = 0, 0
    rooms[startX] = {[startZ] = "Start"}
    
    -- Random Walk to find Boss Room
    local cx, cz = startX, startZ
    for i = 1, gridSize do
        local dir = math.random(1, 4)
        if dir == 1 then cx = cx + 1
        elseif dir == 2 then cx = cx - 1
        elseif dir == 3 then cz = cz + 1
        elseif dir == 4 then cz = cz - 1 end
        
        rooms[cx] = rooms[cx] or {}
        if not rooms[cx][cz] then
            rooms[cx][cz] = "Normal"
        end
        
        if i == gridSize then
            rooms[cx][cz] = "Boss" -- Last room is Boss
        end
    end
    
    -- 2. Instantiate Rooms
    for x, row in pairs(rooms) do
        for z, type in pairs(row) do
            local templateName = "Room_" .. type -- e.g. Room_Normal, Room_Boss
            -- Use placeholders if no template
            local part = Instance.new("Part")
            part.Name = templateName
            part.Size = Vector3.new(50, 20, 50)
            part.Position = Vector3.new(x * roomSize, 10, z * roomSize)
            part.Anchored = true
            part.Parent = floor
            
            -- Add Enemies based on difficulty
            if type == "Normal" then
                local EnemyAI = require(script.Parent.EnemyAI)
                if EnemyAI then
                    local mob = EnemyAI:SpawnEnemy({
                        Name = "Mob_Lvl"..difficulty,
                        Level = difficulty * 2,
                        Element = "Physical", -- Randomize later
                        Health = 50 * difficulty
                    })
                    if mob then 
                        mob:PivotTo(part.CFrame * CFrame.new(0, 5, 0)) 
                        mob.Parent = floor
                    end
                end
            end
        end
    end
    
    print("Generated Floor " .. floorNum .. " with Diff " .. difficulty .. " (Grid Walk)")
    return floor
end

return DungeonService
