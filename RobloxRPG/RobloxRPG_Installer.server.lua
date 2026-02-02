local function create(class, name, parent, source) local s = Instance.new(class, parent) s.Name = name s.Source = source end
local RS = game:GetService('ReplicatedStorage') local SSS = game:GetService('ServerScriptService')
local GD = RS:FindFirstChild('GameData') or Instance.new('Folder', RS) GD.Name = 'GameData'
local G = SSS:FindFirstChild('Game') or Instance.new('Folder', SSS) G.Name = 'Game'

create('ModuleScript', 'Affixes', GD, [[return {}]])

create('ModuleScript', 'Definitions', GD, [[local LootTables = require(script.Parent.LootTables)
local MagicRules = require(script.Parent.MagicRules)
local Entities = require(script.Parent.Entities)
local SkillData = require(script.Parent.SkillData)
local ItemData = require(script.Parent.ItemData)
local EnemyData = require(script.Parent.EnemyData)

local Definitions = {}

-- Aggregate Data
Definitions.LootTables = LootTables

Definitions.Elements = MagicRules.Elements
Definitions.PolarOpposites = MagicRules.PolarOpposites
Definitions.MagicStartingSkills = MagicRules.StartingSkills
Definitions.MagicSkillTrees = MagicRules.SkillTrees

Definitions.Races = Entities.Races
Definitions.Classes = Entities.Classes

Definitions.Skills = SkillData
Definitions.Items = ItemData
Definitions.Enemies = EnemyData

return Definitions
]])

create('ModuleScript', 'EnemyData', GD, [[return {
    ["Goblin"] = {
        Health = 50,
        Damage = 10,
        Element = "Physical",
        Weapon = "Club",
        LootTable = "Global_Common",
        AttackType = "Melee"
    },
    ["FireElemental"] = {
        Health = 200,
        Damage = 25,
        Element = "Fire",
        Weapon = "InfernoFists",
        LootTable = "Boss_Fire",
        AttackType = "Ranged"
    },
    ["Dungeon_Skeleton"] = {
        Health = 80,
        Damage = 15,
        Element = "Dark",
        Weapon = "BoneBow",
        LootTable = "Dungeon_Chest",
        AttackType = "Ranged"
    }
}
]])

create('ModuleScript', 'Entities', GD, [[return {
    Races = {
        ["Human"] = {
            BaseStats = {Health=100, Mana=50},
            Traits = {"Versatile"},
            SkillTree = {
                {Skill="Sprint", Level=1},
                {Skill="Diplomacy", Level=10}
            }
        },
        ["Orc"] = {
            BaseStats = {Health=150, Mana=20},
            Traits = {"Strong"},
            SkillTree = {
                {Skill="WarCry", Level=1},
                {Skill="Berserk", Level=10}
            }
        },
        ["Elf"] = {
            BaseStats = {Health=80, Mana=100},
            Traits = {"Arcane"},
            SkillTree = {
                {Skill="ManaRegen", Level=1},
                {Skill="NatureTouch", Level=10}
            }
        }
    },
    
    Classes = {
        ["Warrior"] = {
            Type="Melee", 
            Element="Physical", 
            SkillTree = {
                {Skill="Slash", Level=1},
                {Skill="Block", Level=3},
                {Skill="Spin", Level=10},
                {Skill="Execute", Level=25}
            }
        },
        ["Mage"] = {
            Type="Ranged", 
            Element="Fire",
            SkillTree = {
                {Skill="Fireball", Level=1},
                {Skill="ManaShield", Level=5},
                {Skill="Meteor", Level=20}
            }
        },
        ["Rogue"] = {
            Type="Melee",
            Element="Physical",
            SkillTree = {
                {Skill="Stab", Level=1},
                {Skill="Invisibility", Level=5},
                {Skill="Poison", Level=15}
            }
        }
    }
}
]])

create('ModuleScript', 'ItemData', GD, [[return {
    -- Weapons
    ["Weapon_FireSword"] = {
        Type = "Weapon",
        Slot = "MainHand",
        Damage = 50,
        Element = "Fire",
        Rarity = "Rare",
        LevelReq = 10
    },
    ["Weapon_IronSword"] = {
        Type = "Weapon",
        Slot = "MainHand",
        Damage = 20,
        Element = "Physical",
        Rarity = "Common",
        LevelReq = 1
    },
    
    -- Armor
    ["Armor_FlamePlate"] = {
        Type = "Armor",
        Slot = "Armor",
        Defense = 30,
        Resist = {["Fire"] = 20},
        LevelReq = 15
    },
    
    -- Potions (Consumables)
    ["Potion_Small"] = {
        Type = "Consumable",
        Effect = "Heal",
        Power = 50,
        LevelReq = 1
    },
    ["Potion_Medium"] = {
        Type = "Consumable",
        Effect = "Heal",
        Power = 150,
        LevelReq = 10
    }
}
]])

create('ModuleScript', 'LootTables', GD, [[return {
    ["Global_Common"] = {
        {Item="Gold", Amount={Min=5, Max=20}, Weight=100},
        {Item="Potion_Small", Weight=20},
    },
    ["Boss_Fire"] = {
        {Item="Gold", Amount={Min=100, Max=500}, Weight=100},
        {Item="Weapon_FireSword", Weight=10},
        {Item="Armor_FlamePlate", Weight=5},
    },
    ["Dungeon_Chest"] = {
        {Item="Gold", Amount={Min=50, Max=100}, Weight=100},
        {Item="Potion_Medium", Weight=30},
        {Item="Scroll_Identify", Weight=15},
    }
}
]])

create('ModuleScript', 'MagicRules', GD, [[return {
    Elements = {
        "Physical", "Dark", "Light", "Space", "Time", "Air", "Ground", 
        "Fire", "Water", "Gravity", "Vacuum", "Fate", "Luck", 
        "Life", "Death", "Illusion", "Reality", "Ice", "Sand", "Mud"
    },
    
    PolarOpposites = {
        ["Dark"] = "Light",
        ["Light"] = "Dark",
        ["Space"] = "Time",
        ["Time"] = "Space",
        ["Air"] = "Ground",
        ["Ground"] = "Air",
        ["Fire"] = "Water",
        ["Water"] = "Fire",
        ["Gravity"] = "Vacuum",
        ["Vacuum"] = "Gravity",
        ["Fate"] = "Luck",
        ["Luck"] = "Fate",
        ["Life"] = "Death",
        ["Death"] = "Life",
        ["Illusion"] = "Reality",
        ["Reality"] = "Illusion",
        ["Ice"] = "Water",
        ["Sand"] = "Mud",
        ["Mud"] = "Sand"
    },
    
    -- Magic Skill Trees (Unlock by Player Level)
    SkillTrees = {
        ["Fire"] = {
            {Skill="Ember", Level=1},
            {Skill="Fireball", Level=5},
            {Skill="Inferno", Level=15},
            {Skill="Meteor", Level=30},
        },
        ["Water"] = {
            {Skill="Splash", Level=1},
            {Skill="Wave", Level=5},
            {Skill="Tsunami", Level=20},
        },
        ["Nature"] = {
            {Skill="Vine", Level=1},
            {Skill="Roots", Level=5},
            {Skill="ForestWrath", Level=15},
        },
        ["Physical"] = {
            {Skill="Punch", Level=1},
            {Skill="Kick", Level=3},
            {Skill="Slash", Level=5},
        },
        -- Default fallback for others
        ["Default"] = {
            {Skill="GenericBlast", Level=1}
        }
    }
}
]])

create('ModuleScript', 'SkillData', GD, [[return {
    -- Fire
    ["Ember"] = {Mana=5, Cooldown=1, DamageMult=1.0, Type="Ranged", Element="Fire"},
    ["Fireball"] = {Mana=20, Cooldown=3, DamageMult=2.0, Type="Ranged", Element="Fire"},
    ["Inferno"] = {Mana=50, Cooldown=15, DamageMult=4.0, Type="AOE", Element="Fire"},
    ["Meteor"] = {Mana=100, Cooldown=60, DamageMult=10.0, Type="Ultimate", Element="Fire"},
    
    -- Water
    ["Splash"] = {Mana=5, Cooldown=1, DamageMult=1.0, Type="Ranged", Element="Water"},
    ["Wave"] = {Mana=20, Cooldown=5, DamageMult=2.0, Type="Line", Element="Water"},
    ["Tsunami"] = {Mana=60, Cooldown=20, DamageMult=5.0, Type="AOE", Element="Water"},
    
    -- Nature
    ["Vine"] = {Mana=10, Cooldown=3, DamageMult=1.2, Type="Ranged", Element="Nature"},
    ["Roots"] = {Mana=30, Cooldown=10, DamageMult=2.0, Type="AOE", Element="Nature", Effect="Root"},
    
    -- Physical
    ["Punch"] = {Mana=0, Cooldown=0.5, DamageMult=1.0, Type="Melee"},
    ["Slash"] = {Mana=10, Cooldown=2, DamageMult=1.5, Type="Melee"},
    
    -- Healer
    ["Heal"] = {Mana=15, Cooldown=5, HealAmount=20, Type="Support"},
    
    -- Defensive
    ["Sprint"] = {Mana=10, Cooldown=10, Duration=5},
    ["WarCry"] = {Mana=30, Cooldown=20, Buff="Damage"},
    ["ManaRegen"] = {Mana=0, Cooldown=60, Buff="Mana"}
}
]])

create('ModuleScript', 'Skills', GD, [[return {Warrior={Slash={Damage=25,Cooldown=3}}}]])

create('ModuleScript', 'Talents', GD, [[return {Warrior={}}]])

create('Script', 'ClassService.server', G, [[local DataService = require(script.Parent.DataService)
local Definitions = require(game.ReplicatedStorage.GameData.Definitions)

local ClassService = {}

function ClassService:SetClass(player, className)
    local classDef = Definitions.Classes[className]
    if not classDef then return false, "Class not found" end
    
    player:SetAttribute("Class", className)
    
    -- Learn Tree Skills (Level 1s)
    local SkillService = require(script.Parent.SkillService)
    if classDef.SkillTree then
        for _, node in ipairs(classDef.SkillTree) do
            if node.Level <= 1 then
                SkillService:LearnSkill(player, node.Skill)
            end
        end
    end
    
    -- Apply Stats
    self:ApplyClassStats(player, className)
    
    -- Update Data
    DataService:Save(player)
    
    return true
end

function ClassService:ApplyClassStats(player, className)
    local def = Definitions.Classes[className]
    if not def then return end
    
    local char = player.Character
    if char then
        local hum = char:FindFirstChild("Humanoid")
        if hum and def.BaseStats then
            local level = player:GetAttribute("Level") or 1
            hum.MaxHealth = def.BaseStats.Health + (level * 10)
            hum.Health = hum.MaxHealth
            
            player:SetAttribute("MaxMana", def.BaseStats.Mana + (level * 5))
            player:SetAttribute("Mana", player:GetAttribute("MaxMana"))
        end
    end
end

-- Connect to CharacterAdded to re-apply stats on respawn
game:GetService("Players").PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function()
        local class = p:GetAttribute("Class")
        if class and Definitions.Classes[class] then
            task.wait()
            ClassService:ApplyClassStats(p, class)
        end
    end)
end)

return ClassService
]])

create('Script', 'CombatMath.server', G, [[
local M={}
function M:Compute(dmg,critC,critM,armor,resist)
 local crit=math.random()<critC and critM or 1
 local mitig=math.clamp(1-(armor+resist)/200,0.1,1)
 return math.floor(dmg*crit*mitig)
end
return M
]])

create('Script', 'CombatService.server', G, [[local Telemetry = require(script.Parent.TelemetryService)
local RemoteGuard = require(script.Parent.RemoteGuard)
local CombatMath = require(script.Parent.CombatMath)
local MagicService = require(script.Parent.MagicService)

local CombatService = {}

-- Create Remotes
local CombatRemote = Instance.new("RemoteEvent")
CombatRemote.Name = "CombatEvent"
if not game.ReplicatedStorage:FindFirstChild("GameRemotes") then
    local f = Instance.new("Folder")
    f.Name = "GameRemotes"
    f.Parent = game.ReplicatedStorage
end
CombatRemote.Parent = game.ReplicatedStorage.GameRemotes

function CombatService:ApplyDamage(attacker, target, context)
    -- context: {Base, Element, IsCrit}
    
    -- Validator: Check distances (Server-Side)
    -- Validator: Check distances (Server-Side)
    local char1
    if attacker:IsA("Player") then
        char1 = attacker.Character
    elseif attacker:IsA("Model") then
        char1 = attacker
    end

    local char2 = target.Parent -- Assuming target is Humanoid, parent is Character
    if not char1 or not char2 then return end
    
    local dist = (char1.PrimaryPart.Position - char2.PrimaryPart.Position).Magnitude
    if dist > 15 and context.Type == "Melee" then
        warn("Reach exploit detected from " .. attacker.Name)
        return
    end

    local dmg = context.Base
    
    -- 1. Apply Elemental Multiplier
    -- 1. Apply Elemental Multiplier & Polar Interaction
    local mult, status = MagicService:GetInteractionResult(attacker, target, context.Element)
    dmg = dmg * mult
    
    if status == "Negated" or status == "Clash Null" then
        -- Feedback for negation
         CombatRemote:FireAllClients("CombatText", target.Parent, "BLOCKED!", Color3.fromRGB(150, 150, 150))
         return -- No damage deals
    end
    
    -- 2. Apply CombatMath (Crit/Mitigation)
    -- Assuming target has attributes for stats, or we fetch from DataService if Player
    local armor = target.Parent:GetAttribute("Armor") or 0
    local resist = target.Parent:GetAttribute("Resist") or 0
    
    dmg = CombatMath:Compute(dmg, 0.1, 2.0, armor, resist) -- 10% crit chance default
    
    -- 3. Apply
    target.Health = math.max(0, target.Health - dmg)
    
    -- 4. Telemetry/Feedback
    Telemetry:Log("DMG", {
        Attacker = attacker.Name, 
        Target = target.Parent.Name, 
        Amount = dmg, 
        Element = context.Element
    })
    
    -- Notify clients (simplified)
    CombatRemote:FireAllClients("DamageNumber", target.Parent, dmg, MagicService:GetColor(context.Element))
    
    -- Kill Check
    if target.Health <= 0 then
        -- Award XP via LevelingService (require strictly to avoid cyclic dep issues if possible, or use Event)
        -- Ideally use a Signal/BindableEvent here.
        -- For now, simple print
        print(attacker.Name .. " killed " .. target.Parent.Name)
    end
end

CombatRemote.OnServerEvent:Connect(function(player, action, ...)
    local args = {...}
    if action == "Attack" then
        local target = args[1]
        
        -- 1. Rate Limit & Type Check (RemoteGuard)
        if not RemoteGuard:Validate(player, "Attack", {target}, {"Instance"}) then return end
        
        -- 2. Explicit Cooldown Check (Gameplay Logic)
        local lastAttack = player:GetAttribute("LastAttack") or 0
        local now = os.clock()
        if now - lastAttack < 0.5 then -- Global 0.5s cooldown for basic attacks
            return 
        end
        player:SetAttribute("LastAttack", now)
        
        -- Simplified Base Damage calculation from Player Stats
        local baseDmg = 10 
        local class = player:GetAttribute("Class")
        -- if class == "Warrior" then baseDmg = 20 end ... (Fetched from ClassService ideally)
        
        CombatService:ApplyDamage(player, target, {
            Base = baseDmg,
            Element = "Physical", -- Fetch from weapon
            Type = "Melee"
        })
    end
end)

return CombatService
]])

create('Script', 'CommandService.server', G, [[local Players = game:GetService("Players")
local DataService = require(script.Parent.DataService)
local ClassService = require(script.Parent.ClassService)
local SkillService = require(script.Parent.SkillService)
local ItemData = require(game.ReplicatedStorage.GameData.ItemData)

local CommandService = {}

local ADMINS = {
    [game.CreatorId] = true, -- Place Owner
    -- Add UserID here manually if testing in Team Create
}

-- Format: /cmd arg1 arg2
Players.PlayerAdded:Connect(function(player)
    player.Chatted:Connect(function(msg)
        -- if not ADMINS[player.UserId] then return end -- Comment out for Studio Testing
        
        local args = string.split(msg, " ")
        local cmd = string.lower(args[1])
        
        if cmd == "/gold" then
            local amt = tonumber(args[2])
            if amt then
                DataService:Get(player).Gold = amt
                DataService:Save(player)
                print("Set Gold to " .. amt)
            end
            
        elseif cmd == "/level" then
            local lvl = tonumber(args[2])
            if lvl then
                player:SetAttribute("Level", lvl)
                DataService:Save(player)
                print("Set Level to " .. lvl)
                -- Re-apply class stats
                ClassService:ApplyClassStats(player, player:GetAttribute("Class"))
            end
            
        elseif cmd == "/class" then
            local cls = args[2]
            ClassService:SetClass(player, cls)
            print("Set Class to " .. cls)
            
        elseif cmd == "/give" then
            local item = args[2]
            if ItemData[item] then
                local d = DataService:Get(player)
                d.Inventory = d.Inventory or {}
                d.Inventory[item] = (d.Inventory[item] or 0) + 1
                DataService:Save(player)
                print("Gave " .. item)
            else
                print("Item not found")
            end
        end
    end)
end)

return CommandService
]])

create('Script', 'DataService.server', G, [[local DSS = game:GetService("DataStoreService")
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
]])

create('Script', 'DungeonService.server', G, [[local TeleportService = game:GetService("TeleportService")
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
]])

create('Script', 'EconomyService.server', G, [[
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
]])

create('Script', 'EnemyAI.server', G, [[local Definitions = require(game.ReplicatedStorage.GameData.Definitions)
local LootService = require(script.Parent.LootService) -- For Death Loot

local EnemyAI = {}

function EnemyAI:SpawnEnemy(params)
    local id = params.ID or "Goblin"
    local data = Definitions.Enemies[id]
    
    local enemyModel = Instance.new("Model")
    enemyModel.Name = id
    
    local root = Instance.new("Part")
    root.Name = "HumanoidRootPart"
    root.Size = Vector3.new(2, 5, 2)
    root.Anchored = false
    root.CanCollide = true
    root.Position = params.Position or Vector3.new(0, 5, 0)
    root.Parent = enemyModel
    enemyModel.PrimaryPart = root
    
    local hum = Instance.new("Humanoid")
    hum.Parent = enemyModel
    
    -- Stats
    local level = params.Level or 1
    
    if data then
        -- Load from Config
        hum.MaxHealth = data.Health + (level * 10)
        enemyModel:SetAttribute("DamageBase", data.Damage + level)
        enemyModel:SetAttribute("Element", data.Element)
        enemyModel:SetAttribute("LootTable", data.LootTable)
        enemyModel:SetAttribute("AttackType", data.AttackType)
    else
        -- Fallback Proc Gen
        hum.MaxHealth = 100 * level
        enemyModel:SetAttribute("DamageBase", 10 * level)
        enemyModel:SetAttribute("Element", params.Element or "Physical")
    end
    
    hum.Health = hum.MaxHealth
    
    enemyModel:SetAttribute("Level", level)
    enemyModel:SetAttribute("MaxHP", hum.MaxHealth)
    enemyModel.Parent = workspace
    
    -- Death Listener for Loot
    hum.Died:Connect(function()
        local table = enemyModel:GetAttribute("LootTable")
        if table then
            LootService:DropLoot(root.Position, table)
        end
        task.wait(2)
        enemyModel:Destroy()
    end)

    -- Start AI Loop
    task.spawn(function()
        while enemyModel.Parent and hum.Health > 0 do
            self:Tick(enemyModel)
            task.wait(0.5)
        end
    end)
    
    return enemyModel
end

function EnemyAI:Tick(n)
    local state = n:GetAttribute("State") or "Idle"
    local hum = n:FindFirstChild("Humanoid")
    if not hum then return end
    
    local target = self:FindTarget(n)
    if target then
        hum:MoveTo(target.HumanoidRootPart.Position)
        
        -- Attack Logic
        local attackDist = (n.PrimaryPart.Position - target.HumanoidRootPart.Position).Magnitude
        if attackDist < 5 then
            local now = os.clock()
            local lastAttack = n:GetAttribute("LastAttack") or 0
            if now - lastAttack > 2 then -- 2 second cooldown
                n:SetAttribute("LastAttack", now)
                
                local CombatService = require(script.Parent.CombatService) 
                local dmgBase = n:GetAttribute("DamageBase") or 10
                
                CombatService:ApplyDamage(n, target.Humanoid, {
                    Base = dmgBase,
                    Element = n:GetAttribute("Element") or "Physical",
                    Type = "Melee"
                })
            end
        end
    end
end

function EnemyAI:OnDamageTaken(enemy, damage, element)
    -- Log damage type for adaptation
    local key = "DmgLog_" .. element
    local current = enemy:GetAttribute(key) or 0
    enemy:SetAttribute(key, current + damage)
    
    local maxHP = enemy:GetAttribute("MaxHP")
    if maxHP and current > maxHP * 0.3 then
        self:Adapt(enemy, element)
    end
end

function EnemyAI:Adapt(enemy, element)
    local currentRes = enemy:GetAttribute("Resist_" .. element) or 0
    if currentRes < 50 then
        enemy:SetAttribute("Resist_" .. element, currentRes + 20)
        enemy:SetAttribute("DmgLog_" .. element, 0)
        print(enemy.Name .. " adapted to " .. element)
    end
end

function EnemyAI:FindTarget(npc)
    -- Find closest player
    local best = nil
    local dist = 100
    for _, p in ipairs(game.Players:GetPlayers()) do
        if p.Character and p.Character.PrimaryPart then
            local d = (p.Character.PrimaryPart.Position - npc.PrimaryPart.Position).Magnitude
            if d < dist then
                dist = d
                best = p.Character.PrimaryPart
            end
        end
    end
    return best
end

return EnemyAI
]])

create('Script', 'GameInit.server', G, [[local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local GameModules = ServerScriptService.Game

-- Load Core Services
local DataService = require(GameModules.DataService)
local RemoteGuard = require(GameModules.RemoteGuard)
local Cross = require(GameModules.CrossServerRaidService)

-- Load Gameplay Services
-- We use safely require them. In a real Framework we might use a module loader.
local Services = {
    Class = require(GameModules.ClassService),
    Skill = require(GameModules.SkillService),
    Leveling = require(GameModules.LevelingService),
    Combat = require(GameModules.CombatService),
    -- Add others as we build them
}

-- Init
print("--- Starting RPG Game Services ---")

Players.PlayerAdded:Connect(function(p)
    print(p.Name .. " joining...")
    DataService:Load(p)
    
    -- Initialize player state in other services if needed
    Services.Class:OnPlayerJoin(p)
    Services.Leveling:OnPlayerJoin(p)
    
    task.delay(2, function() Cross:TryRejoin(p) end)
end)

Players.PlayerRemoving:Connect(function(p)
    DataService:Save(p)
end)

-- Auto-Save Loop
task.spawn(function()
    while true do
        task.wait(60)
        for _, p in ipairs(Players:GetPlayers()) do
            DataService:Save(p)
        end
    end
end)
]])

create('Script', 'LevelingService.server', G, [[local DataService = require(script.Parent.DataService)
local ClassService = require(script.Parent.ClassService)

local LevelingService = {}

local BASE_XP = 100
local XP_MULTIPLIER = 1.2

function LevelingService:OnPlayerJoin(player)
    -- Initialize UI or listeners
end

function LevelingService:GetXPForLevel(level)
    return math.floor(BASE_XP * (XP_MULTIPLIER ^ (level - 1)))
end

function LevelingService:AddXP(player, amount)
    local currentXP = player:GetAttribute("XP")
    local currentLevel = player:GetAttribute("Level")
    
    currentXP = currentXP + amount
    
    local loops = 0
    while currentXP >= self:GetXPForLevel(currentLevel) and loops < 10 do
        currentXP = currentXP - self:GetXPForLevel(currentLevel)
        currentLevel = currentLevel + 1
        self:LevelUp(player, currentLevel)
        loops = loops + 1
    end
    
    player:SetAttribute("XP", currentXP)
    player:SetAttribute("Level", currentLevel)
    
    -- Save
    -- (DataService auto-saves periodically, but good to flag dirty if we had a cache)
end

function LevelingService:LevelUp(player, newLevel)
    print(player.Name .. " Leveled Up to " .. newLevel .. "!")
    -- Increase stats via ClassService
    local class = player:GetAttribute("Class")
    if class ~= "None" then
        ClassService:ApplyClassStats(player, class)
    end
    
    -- Full heal on level up
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.Health = player.Character.Humanoid.MaxHealth
    end
    
    -- Potentially award Skill Points here
end

return LevelingService
]])

create('Script', 'LootService.server', G, [[local Definitions = require(game.ReplicatedStorage.GameData.Definitions)

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
]])

create('Script', 'MagicService.server', G, [[local Definitions = require(game.ReplicatedStorage.GameData.Definitions)

local MagicService = {}

-- Helper to get element color
function MagicService:GetColor(elementType)
    -- Simplified map
    local colors = {
        Fire = Color3.fromRGB(255, 80, 80),
        Water = Color3.fromRGB(80, 80, 255),
        Nature = Color3.fromRGB(80, 255, 80),
        Light = Color3.fromRGB(255, 255, 200),
        Dark = Color3.fromRGB(100, 0, 100),
        Physical = Color3.fromRGB(200, 200, 200),
        Space = Color3.fromRGB(150, 0, 255),
        Time = Color3.fromRGB(0, 255, 200),
        Gravity = Color3.fromRGB(50, 0, 100),
        Vacuum = Color3.fromRGB(20, 20, 20),
        Life = Color3.fromRGB(255, 255, 255),
        Death = Color3.fromRGB(10, 10, 10),
        Fate = Color3.fromRGB(255, 215, 0),
        Luck = Color3.fromRGB(0, 255, 0),
        Illusion = Color3.fromRGB(255, 100, 255),
        Reality = Color3.fromRGB(100, 100, 100),
        Sand = Color3.fromRGB(237, 201, 175),
        Mud = Color3.fromRGB(101, 67, 33),
        Ice = Color3.fromRGB(173, 216, 230)
    }
    return colors[elementType] or Color3.new(1,1,1)
end

-- Check if two elements are Polar Opposites
function MagicService:IsPolarOpposite(elem1, elem2)
    -- Direct check mapping
    if Definitions.PolarOpposites[elem1] == elem2 then return true end
    -- Reverse check implicit in map, but explicit check implies bi-directional
    -- Check for special case Ice/Water if not fully strictly mapped
    if (elem1 == "Ice" and elem2 == "Water") or (elem1 == "Water" and elem2 == "Ice") then
        return true
    end
    return false
end

-- Standard Interactions for Non-Polar cases
local STANDARD_RELATIONS = {
    ["Fire"] = {StrongAgainst="Nature", WeakTo="Water"}, -- Note: Water is Polar to Fire, so checking Polar first overrides this.
    ["Water"] = {StrongAgainst="Fire", WeakTo="Nature"},
    ["Nature"] = {StrongAgainst="Water", WeakTo="Fire"},
    -- Add others if needed or rely on Neutral default
}

-- Core Interaction Logic
function MagicService:GetInteractionResult(attacker, target, attackElement)
    -- 1. Identify Target Element
    local targetElement = target.Parent:GetAttribute("Element") or "Physical"
    
    local multiplier = 1.0
    local status = "Neutral"
    
    -- 2. Check Polar Opposite First (Highest Priority as per User Request)
    if self:IsPolarOpposite(attackElement, targetElement) then
        local attLevel = attacker:GetAttribute("Level") or 1
        local defLevel = target.Parent:GetAttribute("Level") or 1 
        
        -- Polar Logic: Level Clash determines outcome.
        -- Winner gets Neutral damage (1.0). Loser gets Negated (0).
        if attLevel > defLevel then
            multiplier = 1.0 
            status = "Overpower"
        elseif attLevel < defLevel then
            multiplier = 0 
            status = "Negated"
        else
            -- Equal Level = Null
            multiplier = 0
            status = "Clash Null"
        end
        return multiplier, status
    end

    -- 3. If NOT Polar, use Standard Weak/Strong Logic
    local relation = STANDARD_RELATIONS[attackElement]
    if relation then
        if relation.StrongAgainst == targetElement then
            multiplier = 1.5
            status = "Strong"
        elseif relation.WeakTo == targetElement then
            multiplier = 0.5
            status = "Weak"
        end
    end
    
    return multiplier, status
end

return MagicService
]])

create('Script', 'MarketService.server', G, [[local DataService = require(script.Parent.DataService)
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
]])

create('Script', 'RaceService.server', G, [[local Definitions = require(game.ReplicatedStorage.GameData.Definitions)
local DataService = require(script.Parent.DataService)

local RaceService = {}

function RaceService:SetRace(player, raceName)
    if not Definitions.Races[raceName] then return false, "Invalid Race" end
    
    player:SetAttribute("Race", raceName)
    
    -- Apply Stats
    local stats = Definitions.Races[raceName].BaseStats
    player:SetAttribute("BaseStats_HP", stats.Health)
    player:SetAttribute("BaseStats_Mana", stats.Mana)
    
    -- Recalculate Totals (Could be in StatService)
    local char = player.Character
    if char then
        local hum = char:FindFirstChild("Humanoid")
        if hum then
            hum.MaxHealth = stats.Health -- simplified for now
            hum.Health = hum.MaxHealth
        end
    end
    
    DataService:Save(player)
    return true
end

-- Hook into join
game:GetService("Players").PlayerAdded:Connect(function(p)
     p.CharacterAdded:Connect(function()
        local r = p:GetAttribute("Race")
        if r then
             task.wait()
             RaceService:SetRace(p, r)
        end
     end)
end)

return RaceService
]])

create('Script', 'RemoteGuard.server', G, [[local RunService = game:GetService("RunService")
local RemoteGuard = {}

-- Rate Limiting Configuration
local RATE_LIMITS = {
    ["Attack"] = {Max = 5, Interval = 1}, -- 5 attacks per second
    ["UseSkill"] = {Max = 3, Interval = 1},
    ["Interact"] = {Max = 2, Interval = 0.5},
}

local PlayerLimits = {}

function RemoteGuard:Validate(player, remoteName, args, schema)
    -- 1. Rate Check
    if not self:CheckRate(player, remoteName) then
        return false, "Rate Limit Exceeded"
    end
    
    -- 2. Schema Check (Basic Type Checking)
    if schema then
        for i, expectedType in ipairs(schema) do
            if type(args[i]) ~= expectedType then
                warn(string.format("Security: %s sent bad type (Arg %d: got %s, expected %s)", player.Name, i, type(args[i]), expectedType))
                return false, "Invalid Argument Type"
            end
        end
    end
    
    return true
end

function RemoteGuard:CheckRate(player, action)
    local limits = RATE_LIMITS[action]
    if not limits then return true end -- No limit defined
    
    local id = player.UserId
    PlayerLimits[id] = PlayerLimits[id] or {}
    local pLimit = PlayerLimits[id][action] or {Count = 0, LastCheck = os.clock()}
    
    local now = os.clock()
    if now - pLimit.LastCheck > limits.Interval then
        pLimit.Count = 0
        pLimit.LastCheck = now
    end
    
    pLimit.Count = pLimit.Count + 1
    PlayerLimits[id][action] = pLimit
    
    if pLimit.Count > limits.Max then
        warn("Security: " .. player.Name .. " exceeded rate limit for " .. action)
        return false
    end
    
    return true
end

-- Cleanup on leave
game:GetService("Players").PlayerRemoving:Connect(function(p)
    if PlayerLimits[p.UserId] then
        PlayerLimits[p.UserId] = nil
    end
end)

return RemoteGuard
]])

create('Script', 'SkillService.server', G, [[local DataService = require(script.Parent.DataService)
local RemoteGuard = require(script.Parent.RemoteGuard)

local SkillService = {}

local Definitions = require(game.ReplicatedStorage.GameData.Definitions)

-- Remote for learning skills
local SkillRemote = Instance.new("RemoteEvent")
SkillRemote.Name = "LearnSkill"
if not game.ReplicatedStorage:FindFirstChild("GameRemotes") then
    local folder = Instance.new("Folder")
    folder.Name = "GameRemotes"
    folder.Parent = game.ReplicatedStorage
end
SkillRemote.Parent = game.ReplicatedStorage.GameRemotes

function SkillService:LearnSkill(player, skillName)
    local element = player:GetAttribute("Element")
    local class = player:GetAttribute("Class")
    local race = player:GetAttribute("Race")
    local level = player:GetAttribute("Level") or 1
    
    -- 1. Search ALL Trees for Requirement
    local reqData = nil
    
    -- Function to check a tree list
    local function checkTree(treeList)
        if not treeList then return end
        for _, node in ipairs(treeList) do
            if node.Skill == skillName then
                reqData = node
                return true
            end
        end
    end
    
    -- Check Magic Tree
    if element and Definitions.MagicSkillTrees[element] then
        if checkTree(Definitions.MagicSkillTrees[element]) then end
    end
    
    -- Check Class Tree
    if not reqData and class and Definitions.Classes[class] then
        checkTree(Definitions.Classes[class].SkillTree)
    end
    
    -- Check Race Tree
    if not reqData and race and Definitions.Races[race] then
        checkTree(Definitions.Races[race].SkillTree)
    end
    
    if not reqData then return false, "Skill not found in your Magic, Class, or Race trees" end
    
    -- 2. Check Requirements
    if level < reqData.Level then return false, "Level too low (Req: " .. reqData.Level .. ")" end
    
    -- 3. Update Data
    local currentSkills = DataService:Get(player).Skills or {}
    local currentRank = currentSkills[skillName] or 0
    
    if currentRank >= 1 then return false, "Already learned" end 
    
    currentSkills[skillName] = 1
    DataService:Get(player).Skills = currentSkills
    DataService:Save(player) 
    
    return true, "Skill learned"
end

function SkillService:CastSkill(player, skillName)
    -- 1. Validate Learned
    local data = DataService:Get(player)
    local rank = (data.Skills and data.Skills[skillName]) or 0
    if rank <= 0 then return false, "Skill not learned" end
    
    -- 2. Validate Resources (Mana/Cooldown)
    -- Simplified: No Cooldown tracking in this snippet, but ideally check LastCast_[Skill]
    
    -- 3. Execute Logic
    -- In a real system, we'd load a ModuleScript per skill. 
    -- For now, hardcode a few test skills using Definitions or Switch
    
    local CombatService = require(script.Parent.CombatService)
    local char = player.Character
    if not char then return end
    
    if skillName == "Slash" then
        -- AOE around player
        local center = char.PrimaryPart.Position
        for _, enemy in ipairs(workspace:GetChildren()) do
            if enemy:FindFirstChild("Humanoid") and enemy ~= char then
                local dist = (enemy.PrimaryPart.Position - center).Magnitude
                if dist < 10 then
                    CombatService:ApplyDamage(player, enemy.Humanoid, {
                        Base = 15 * rank,
                        Element = "Physical", -- Fetch from weapon?
                        Type = "Melee"
                    })
                end
            end
        end
        return true, "Slash Cast"
        
    elseif skillName == "Fireball" then
        -- Projectile Logic (Simplified as instant hit for backend demo)
        -- Ideally, spawn projectile, OnTouch -> ApplyDamage
        -- Here we just find nearest target
        return true, "Fireball Cast (Projectile Logic needed)"
    end
    
    return false, "Skill logic not found"
end

SkillRemote.OnServerEvent:Connect(function(player, action, arg1)
    if action == "Learn" then
       if not RemoteGuard:Validate(player, "LearnSkill", {arg1}, {"string"}) then return end
       SkillService:LearnSkill(player, arg1)
       
    elseif action == "Cast" then
       if not RemoteGuard:Validate(player, "UseSkill", {arg1}, {"string"}) then return end
       SkillService:CastSkill(player, arg1)
    end
end)

return SkillService
]])

create('Script', 'StatusEffectService.server', G, [[
local S={}
function S:Apply(t,e,d)
 t:SetAttribute(e,true)
 task.delay(d,function() t:SetAttribute(e,false) end)
end
return S
]])

create('Script', 'TeamService.server', G, [[local TeamService = {}
local Teams = {} -- Map<Player, TeamId>
local Parties = {} -- Map<PartyId, List<Player>>

-- Using Roblox Teams Service as backend for visual representation?
-- Or custom internal party system?
-- Let's do a lightweight Party System for "Tree System for all and team system"

function TeamService:CreateParty(leader)
    local id = game:GetService("HttpService"):GenerateGUID(false)
    Parties[id] = {Leader = leader, Members = {leader}}
    leader:SetAttribute("PartyId", id)
    return id
end

function TeamService:JoinParty(player, partyId)
    local party = Parties[partyId]
    if party and #party.Members < 5 then
        table.insert(party.Members, player)
        player:SetAttribute("PartyId", partyId)
        return true
    end
    return false
end

function TeamService:AreAllies(entity1, entity2)
    -- Handle Players
    if entity1:IsA("Player") and entity2:IsA("Player") then
        local p1 = entity1:GetAttribute("PartyId")
        local p2 = entity2:GetAttribute("PartyId")
        if p1 and p2 and p1 == p2 then return true end
    end
    
    -- Handle NPC vs Player (Tags?)
    -- Default: Different teams
    return false
end

return TeamService
]])

create('Script', 'TradeService.server', G, [[local DataService = require(script.Parent.DataService)
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
]])
