local EnemyAI = {}

-- Adaptive Stats
-- If an enemy takes X% damage from Fire, it gains Fire Res.

function EnemyAI:Spawn(enemyModel, level)
    enemyModel:SetAttribute("Level", level)
    enemyModel:SetAttribute("MaxHP", 100 * level)
    enemyModel.Humanoid.Health = enemyModel.Humanoid.MaxHealth
    
    -- Initialize Memory
    enemyModel:SetAttribute("DmgLog_Fire", 0)
    enemyModel:SetAttribute("DmgLog_Water", 0)
    -- ...
    
    -- Start AI Loop
    task.spawn(function()
        while enemyModel.Parent do
            self:Tick(enemyModel)
            task.wait(0.5)
        end
    end)
end

function EnemyAI:OnDamageTaken(enemy, damage, element)
    -- Log damage type
    local key = "DmgLog_" .. element
    local current = enemy:GetAttribute(key) or 0
    enemy:SetAttribute(key, current + damage)
    
    -- Adapt?
    local maxHP = enemy:GetAttribute("MaxHP")
    if current > maxHP * 0.3 then -- If taken 30% of HP from this element
        self:Adapt(enemy, element)
    end
end

function EnemyAI:Adapt(enemy, element)
    local currentRes = enemy:GetAttribute("Resist_" .. element) or 0
    if currentRes < 50 then -- Cap at 50%
        print(enemy.Name .. " adapted to " .. element .. "!")
        enemy:SetAttribute("Resist_" .. element, currentRes + 20)
        -- Reset log to avoid infinite loop of adapting immediately again
        enemy:SetAttribute("DmgLog_" .. element, 0)
        
        -- Visual Cue
        local cue = Instance.new("BillboardGui")
        -- ... Text: "Adapted!" inside enemy head
    end
end

function EnemyAI:Tick(n)
    local state = n:GetAttribute("State") or "Idle"
    local hum = n:FindFirstChild("Humanoid")
    if not hum then return end
    
    if hum.Health < hum.MaxHealth * 0.3 then
        -- Low Health Logic
        state = "Flee"
        -- Maybe switch target to Healer?
    else
        state = "Attack"
    end
    
    -- Simple Chase
    if state == "Attack" then
        local target = self:FindTarget(n)
        if target then
            hum:MoveTo(target.Position)
            -- Attack if close
        end
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
