local DataService = require(script.Parent.DataService)
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
