local Definitions = require(game.ReplicatedStorage.GameData.Definitions)
local LootService = require(script.Parent.LootService) -- For Death Loot

local EnemyAI = {}

function EnemyAI:SpawnEnemy(params)
    local id = params.ID or "Goblin"
    local data = Definitions.Enemies[id]
    
    -- 1. Try to find User Asset
    local assetFolder = game.ServerStorage:FindFirstChild("Assets")
    local enemyTemplate
    if assetFolder and assetFolder:FindFirstChild("Enemies") then
        enemyTemplate = assetFolder.Enemies:FindFirstChild(id)
    end
    
    local enemyModel
    if enemyTemplate then
        enemyModel = enemyTemplate:Clone()
        enemyModel.Name = id
        enemyModel:SetPrimaryPartCFrame(CFrame.new(params.Position or Vector3.new(0,5,0)))
    else
        -- 2. Fallback Dummy
        enemyModel = Instance.new("Model")
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
