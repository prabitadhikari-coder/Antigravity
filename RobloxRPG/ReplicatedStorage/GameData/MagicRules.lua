return {
    Elements = {
        "Physical", "Dark", "Light", "Space", "Time", "Air", "Ground", 
        "Fire", "Water", "Gravity", "Vacuum", "Fate", "Luck", 
        "Life", "Death", "Illusion", "Reality", "Ice", "Sand", "Mud"
    },
    
    PolarOpposites = {
        ["Dark"] = "Light",
        ["Light"] = "Dark",
        ["Space"] = "Time",
        ["Time"] = "Space",
        ["Air"] = "Ground",
        ["Ground"] = "Air",
        ["Fire"] = "Water",
        ["Water"] = "Fire",
        ["Gravity"] = "Vacuum",
        ["Vacuum"] = "Gravity",
        ["Fate"] = "Luck",
        ["Luck"] = "Fate",
        ["Life"] = "Death",
        ["Death"] = "Life",
        ["Illusion"] = "Reality",
        ["Reality"] = "Illusion",
        ["Ice"] = "Water",
        ["Sand"] = "Mud",
        ["Mud"] = "Sand"
    },
    
    -- Magic Skill Trees (Unlock by Player Level)
    SkillTrees = {
        ["Fire"] = {
            {Skill="Ember", Level=1},
            {Skill="Fireball", Level=5},
            {Skill="Inferno", Level=15},
            {Skill="Meteor", Level=30},
        },
        ["Water"] = {
            {Skill="Splash", Level=1},
            {Skill="Wave", Level=5},
            {Skill="Tsunami", Level=20},
        },
        ["Nature"] = {
            {Skill="Vine", Level=1},
            {Skill="Roots", Level=5},
            {Skill="ForestWrath", Level=15},
        },
        ["Physical"] = {
            {Skill="Punch", Level=1},
            {Skill="Kick", Level=3},
            {Skill="Slash", Level=5},
        },
        -- Default fallback for others
        ["Default"] = {
            {Skill="GenericBlast", Level=1}
        }
    }
}
