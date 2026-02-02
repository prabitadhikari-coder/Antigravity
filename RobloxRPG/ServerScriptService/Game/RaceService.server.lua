local Definitions = require(game.ReplicatedStorage.GameData.Definitions)
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
