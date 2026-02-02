return {
    -- Weapons
    ["Weapon_FireSword"] = {
        Type = "Weapon",
        Slot = "MainHand",
        Damage = 50,
        Element = "Fire",
        Rarity = "Rare",
        LevelReq = 10
    },
    ["Weapon_IronSword"] = {
        Type = "Weapon",
        Slot = "MainHand",
        Damage = 20,
        Element = "Physical",
        Rarity = "Common",
        LevelReq = 1
    },
    
    -- Armor
    ["Armor_FlamePlate"] = {
        Type = "Armor",
        Slot = "Armor",
        Defense = 30,
        Resist = {["Fire"] = 20},
        LevelReq = 15
    },
    
    -- Potions (Consumables)
    ["Potion_Small"] = {
        Type = "Consumable",
        Effect = "Heal",
        Power = 50,
        LevelReq = 1
    },
    ["Potion_Medium"] = {
        Type = "Consumable",
        Effect = "Heal",
        Power = 150,
        LevelReq = 10
    }
}
