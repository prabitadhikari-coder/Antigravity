local Players = game:GetService("Players")
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
