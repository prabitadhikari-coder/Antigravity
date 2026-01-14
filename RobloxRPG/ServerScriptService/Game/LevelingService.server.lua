local DataService = require(script.Parent.DataService)
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
