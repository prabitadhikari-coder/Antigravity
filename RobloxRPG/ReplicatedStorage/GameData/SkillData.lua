return {
    -- Fire
    ["Ember"] = {Mana=5, Cooldown=1, DamageMult=1.0, Type="Ranged", Element="Fire"},
    ["Fireball"] = {Mana=20, Cooldown=3, DamageMult=2.0, Type="Ranged", Element="Fire"},
    ["Inferno"] = {Mana=50, Cooldown=15, DamageMult=4.0, Type="AOE", Element="Fire"},
    ["Meteor"] = {Mana=100, Cooldown=60, DamageMult=10.0, Type="Ultimate", Element="Fire"},
    
    -- Water
    ["Splash"] = {Mana=5, Cooldown=1, DamageMult=1.0, Type="Ranged", Element="Water"},
    ["Wave"] = {Mana=20, Cooldown=5, DamageMult=2.0, Type="Line", Element="Water"},
    ["Tsunami"] = {Mana=60, Cooldown=20, DamageMult=5.0, Type="AOE", Element="Water"},
    
    -- Nature
    ["Vine"] = {Mana=10, Cooldown=3, DamageMult=1.2, Type="Ranged", Element="Nature"},
    ["Roots"] = {Mana=30, Cooldown=10, DamageMult=2.0, Type="AOE", Element="Nature", Effect="Root"},
    
    -- Physical
    ["Punch"] = {Mana=0, Cooldown=0.5, DamageMult=1.0, Type="Melee"},
    ["Slash"] = {Mana=10, Cooldown=2, DamageMult=1.5, Type="Melee"},
    
    -- Healer
    ["Heal"] = {Mana=15, Cooldown=5, HealAmount=20, Type="Support"},
    
    -- Defensive
    ["Sprint"] = {Mana=10, Cooldown=10, Duration=5},
    ["WarCry"] = {Mana=30, Cooldown=20, Buff="Damage"},
    ["ManaRegen"] = {Mana=0, Cooldown=60, Buff="Mana"}
}
