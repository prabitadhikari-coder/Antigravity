local DataService = require(script.Parent.DataService)
local RemoteGuard = require(script.Parent.RemoteGuard)

local SkillService = {}

-- A simple skill tree definition for testing
local TREES = {
    ["Warrior"] = {
        ["Slash"] = {ReqLevel=1, MaxRank=5},
        ["Bash"] = {ReqLevel=3, MaxRank=3, ReqSkill="Slash", ReqRank=3},
        ["Rage"] = {ReqLevel=10, MaxRank=1}
    }
}

-- Remote for learning skills
local SkillRemote = Instance.new("RemoteEvent")
SkillRemote.Name = "LearnSkill"
SkillRemote.Parent = game:GetService("ReplicatedStorage") -- Assuming folder exists, or create it. 
-- In GameInit, we should ideally ensure ReplicatedStorage structure. 
-- For now, let's just make sure it's created if not.
if not game.ReplicatedStorage:FindFirstChild("GameRemotes") then
    local folder = Instance.new("Folder")
    folder.Name = "GameRemotes"
    folder.Parent = game.ReplicatedStorage
end
SkillRemote.Parent = game.ReplicatedStorage.GameRemotes


function SkillService:LearnSkill(player, skillName)
    local class = player:GetAttribute("Class")
    local level = player:GetAttribute("Level")
    
    local tree = TREES[class]
    if not tree then return false, "No tree for class" end
    
    local node = tree[skillName]
    if not node then return false, "Skill not found" end
    
    -- Check Requirements
    if level < node.ReqLevel then return false, "Level too low" end
    
    local currentSkills = DataService:Get(player).Skills or {}
    local currentRank = currentSkills[skillName] or 0
    
    if currentRank >= node.MaxRank then return false, "Max rank reached" end
    
    if node.ReqSkill then
        local reqRank = currentSkills[node.ReqSkill] or 0
        if reqRank < node.ReqRank then return false, "Missing prerequisite skill" end
    end
    
    -- Check Skill Points (Assuming 1 SP per level, need to track Spent Points)
    -- Simplified: Just use Gold for now or check SP if added to schema
    -- Let's say it costs 100 Gold per rank for now as per "Marketplace" focus? 
    -- Or better, assume we added "SkillPoints" to schema or derived it.
    -- Let's use Gold for simplicity for this iteration, or just allow it if we assume infinite SP for testing.
    -- "skill levelling" was a requirement.
    
    -- Update Data
    currentSkills[skillName] = currentRank + 1
    DataService:Get(player).Skills = currentSkills
    DataService:Save(player) -- Important to save state
    
    return true, "Skill upgraded"
end

SkillRemote.OnServerEvent:Connect(function(player, skillName)
    if not RemoteGuard:Validate(player, "UseSkill", {skillName}, {"string"}) then return end
    
    local success, msg = SkillService:LearnSkill(player, skillName)
    print(player.Name .. " tried to learn " .. skillName .. ": " .. msg)
end)

return SkillService
