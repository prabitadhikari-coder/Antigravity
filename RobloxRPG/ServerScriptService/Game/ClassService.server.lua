local DataService = require(script.Parent.DataService)

local ClassService = {}

-- Class Definitions
local CLASSES = {
    ["Knight"] = { -- Renamed from Warrior
        BaseHP = 150,
        BaseMana = 20,
        BaseAttack = 15,
        Description = "Strong melee fighter. Evolves to Paladin."
    },
    ["Paladin"] = {
        BaseHP = 200,
        BaseMana = 100,
        BaseAttack = 25,
        Description = "Holy warrior. High evolution of Knight."
    },
    ["Mage"] = {
        BaseHP = 80,
        BaseMana = 100,
        BaseAttack = 5,
        Description = "Master of elements. Evolves to Archmage."
    },
    ["Archmage"] = {
        BaseHP = 120,
        BaseMana = 200,
        BaseAttack = 10, -- Spells do the damage
        Description = "Supreme caster."
    },
    ["Demon"] = {
        BaseHP = 180,
        BaseMana = 50,
        BaseAttack = 30,
        Description = "Dark powers and high damage."
    },
     ["Thief"] = {
        BaseHP = 90,
        BaseMana = 40,
        BaseAttack = 20,
        Description = "Fast and deadly. Evolves to Assassin."
    },
    ["Assassin"] = {
        BaseHP = 110,
        BaseMana = 60,
        BaseAttack = 45,
        Description = "One-hit kill specialist."
    }
}

function ClassService:OnPlayerJoin(player)
    local class = player:GetAttribute("Class")
    if class == "None" or not CLASSES[class] then
        print(player.Name .. " has no class. Prompting selection?")
        -- In a real game, FireClient(PromptClassSelection)
        -- For now, auto-assign Warrior for testing if None
        self:SetClass(player, "Warrior")
    else
        self:ApplyClassStats(player, class)
    end
end

function ClassService:SetClass(player, className)
    if not CLASSES[className] then warn("Invalid class: "..className) return end
    
    player:SetAttribute("Class", className)
    self:ApplyClassStats(player, className)
    
    -- Save immediately to avoid data loss
    DataService:Save(player)
end

function ClassService:ApplyClassStats(player, className)
    local def = CLASSES[className]
    -- Apply stats usually means modifying the Character's Humanoid
    local char = player.Character or player.CharacterAdded:Wait()
    local hum = char:WaitForChild("Humanoid")
    
    -- basic scaling could be implemented here or in LevelingService
    hum.MaxHealth = def.BaseHP + (player:GetAttribute("Level") * 10)
    hum.Health = hum.MaxHealth
    
    -- Store Mana as an attribute on the Attribute
    player:SetAttribute("MaxMana", def.BaseMana)
    player:SetAttribute("Mana", def.BaseMana)
    
    print("Applied " .. className .. " stats to " .. player.Name)
end

-- Connect to CharacterAdded to re-apply stats on respawn
game:GetService("Players").PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function()
        local class = p:GetAttribute("Class")
        if class and class ~= "None" then
             -- Wait a frame for Humanoid
            task.wait()
            ClassService:ApplyClassStats(p, class)
        end
    end)
end)

return ClassService
