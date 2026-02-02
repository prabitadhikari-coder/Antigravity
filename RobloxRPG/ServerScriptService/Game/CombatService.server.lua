local Telemetry = require(script.Parent.TelemetryService)
local RemoteGuard = require(script.Parent.RemoteGuard)
local CombatMath = require(script.Parent.CombatMath)
local MagicService = require(script.Parent.MagicService)

local CombatService = {}

-- Create Remotes
local CombatRemote = Instance.new("RemoteEvent")
CombatRemote.Name = "CombatEvent"
if not game.ReplicatedStorage:FindFirstChild("GameRemotes") then
    local f = Instance.new("Folder")
    f.Name = "GameRemotes"
    f.Parent = game.ReplicatedStorage
end
CombatRemote.Parent = game.ReplicatedStorage.GameRemotes

function CombatService:ApplyDamage(attacker, target, context)
    -- context: {Base, Element, IsCrit}
    
    -- Validator: Check distances (Server-Side)
    -- Validator: Check distances (Server-Side)
    local char1
    if attacker:IsA("Player") then
        char1 = attacker.Character
    elseif attacker:IsA("Model") then
        char1 = attacker
    end

    local char2 = target.Parent -- Assuming target is Humanoid, parent is Character
    if not char1 or not char2 then return end
    
    local dist = (char1.PrimaryPart.Position - char2.PrimaryPart.Position).Magnitude
    if dist > 15 and context.Type == "Melee" then
        warn("Reach exploit detected from " .. attacker.Name)
        return
    end

    local dmg = context.Base
    
    -- 1. Apply Elemental Multiplier
    -- 1. Apply Elemental Multiplier & Polar Interaction
    local mult, status = MagicService:GetInteractionResult(attacker, target, context.Element)
    dmg = dmg * mult
    
    if status == "Negated" or status == "Clash Null" then
        -- Feedback for negation
         CombatRemote:FireAllClients("CombatText", target.Parent, "BLOCKED!", Color3.fromRGB(150, 150, 150))
         return -- No damage deals
    end
    
    -- 2. Apply CombatMath (Crit/Mitigation)
    -- Assuming target has attributes for stats, or we fetch from DataService if Player
    local armor = target.Parent:GetAttribute("Armor") or 0
    local resist = target.Parent:GetAttribute("Resist") or 0
    
    dmg = CombatMath:Compute(dmg, 0.1, 2.0, armor, resist) -- 10% crit chance default
    
    -- 3. Apply
    target.Health = math.max(0, target.Health - dmg)
    
    -- 4. Telemetry/Feedback
    Telemetry:Log("DMG", {
        Attacker = attacker.Name, 
        Target = target.Parent.Name, 
        Amount = dmg, 
        Element = context.Element
    })
    
    -- Notify clients (simplified)
    CombatRemote:FireAllClients("DamageNumber", target.Parent, dmg, MagicService:GetColor(context.Element))
    
    -- Kill Check
    if target.Health <= 0 then
        -- Award XP via LevelingService (require strictly to avoid cyclic dep issues if possible, or use Event)
        -- Ideally use a Signal/BindableEvent here.
        -- For now, simple print
        print(attacker.Name .. " killed " .. target.Parent.Name)
    end
end

CombatRemote.OnServerEvent:Connect(function(player, action, ...)
    local args = {...}
    if action == "Attack" then
        local target = args[1]
        
        -- 1. Rate Limit & Type Check (RemoteGuard)
        if not RemoteGuard:Validate(player, "Attack", {target}, {"Instance"}) then return end
        
        -- 2. Explicit Cooldown Check (Gameplay Logic)
        local lastAttack = player:GetAttribute("LastAttack") or 0
        local now = os.clock()
        if now - lastAttack < 0.5 then -- Global 0.5s cooldown for basic attacks
            return 
        end
        player:SetAttribute("LastAttack", now)
        
        -- Simplified Base Damage calculation from Player Stats
        local baseDmg = 10 
        local class = player:GetAttribute("Class")
        -- if class == "Warrior" then baseDmg = 20 end ... (Fetched from ClassService ideally)
        
        CombatService:ApplyDamage(player, target, {
            Base = baseDmg,
            Element = "Physical", -- Fetch from weapon
            Type = "Melee"
        })
    end
end)

return CombatService
