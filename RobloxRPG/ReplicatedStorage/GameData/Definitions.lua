local LootTables = require(script.Parent.LootTables)
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
