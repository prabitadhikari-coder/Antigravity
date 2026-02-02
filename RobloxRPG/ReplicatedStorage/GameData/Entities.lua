return {
    Races = {
        ["Human"] = {
            BaseStats = {Health=100, Mana=50},
            Traits = {"Versatile"},
            SkillTree = {
                {Skill="Sprint", Level=1},
                {Skill="Diplomacy", Level=10}
            }
        },
        ["Orc"] = {
            BaseStats = {Health=150, Mana=20},
            Traits = {"Strong"},
            SkillTree = {
                {Skill="WarCry", Level=1},
                {Skill="Berserk", Level=10}
            }
        },
        ["Elf"] = {
            BaseStats = {Health=80, Mana=100},
            Traits = {"Arcane"},
            SkillTree = {
                {Skill="ManaRegen", Level=1},
                {Skill="NatureTouch", Level=10}
            }
        }
    },
    
    Classes = {
        ["Warrior"] = {
            Type="Melee", 
            Element="Physical", 
            SkillTree = {
                {Skill="Slash", Level=1},
                {Skill="Block", Level=3},
                {Skill="Spin", Level=10},
                {Skill="Execute", Level=25}
            }
        },
        ["Mage"] = {
            Type="Ranged", 
            Element="Fire",
            SkillTree = {
                {Skill="Fireball", Level=1},
                {Skill="ManaShield", Level=5},
                {Skill="Meteor", Level=20}
            }
        },
        ["Rogue"] = {
            Type="Melee",
            Element="Physical",
            SkillTree = {
                {Skill="Stab", Level=1},
                {Skill="Invisibility", Level=5},
                {Skill="Poison", Level=15}
            }
        }
    }
}
