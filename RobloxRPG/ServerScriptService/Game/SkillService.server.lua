local DataService = require(script.Parent.DataService)
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
