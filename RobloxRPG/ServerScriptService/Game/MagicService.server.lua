local Definitions = require(game.ReplicatedStorage.GameData.Definitions)

local MagicService = {}

-- Helper to get element color
function MagicService:GetColor(elementType)
    -- Simplified map
    local colors = {
        Fire = Color3.fromRGB(255, 80, 80),
        Water = Color3.fromRGB(80, 80, 255),
        Nature = Color3.fromRGB(80, 255, 80),
        Light = Color3.fromRGB(255, 255, 200),
        Dark = Color3.fromRGB(100, 0, 100),
        Physical = Color3.fromRGB(200, 200, 200),
        Space = Color3.fromRGB(150, 0, 255),
        Time = Color3.fromRGB(0, 255, 200),
        Gravity = Color3.fromRGB(50, 0, 100),
        Vacuum = Color3.fromRGB(20, 20, 20),
        Life = Color3.fromRGB(255, 255, 255),
        Death = Color3.fromRGB(10, 10, 10),
        Fate = Color3.fromRGB(255, 215, 0),
        Luck = Color3.fromRGB(0, 255, 0),
        Illusion = Color3.fromRGB(255, 100, 255),
        Reality = Color3.fromRGB(100, 100, 100),
        Sand = Color3.fromRGB(237, 201, 175),
        Mud = Color3.fromRGB(101, 67, 33),
        Ice = Color3.fromRGB(173, 216, 230)
    }
    return colors[elementType] or Color3.new(1,1,1)
end

-- Check if two elements are Polar Opposites
function MagicService:IsPolarOpposite(elem1, elem2)
    -- Direct check mapping
    if Definitions.PolarOpposites[elem1] == elem2 then return true end
    -- Reverse check implicit in map, but explicit check implies bi-directional
    -- Check for special case Ice/Water if not fully strictly mapped
    if (elem1 == "Ice" and elem2 == "Water") or (elem1 == "Water" and elem2 == "Ice") then
        return true
    end
    return false
end

-- Standard Interactions for Non-Polar cases
local STANDARD_RELATIONS = {
    ["Fire"] = {StrongAgainst="Nature", WeakTo="Water"}, -- Note: Water is Polar to Fire, so checking Polar first overrides this.
    ["Water"] = {StrongAgainst="Fire", WeakTo="Nature"},
    ["Nature"] = {StrongAgainst="Water", WeakTo="Fire"},
    -- Add others if needed or rely on Neutral default
}

-- Core Interaction Logic
function MagicService:GetInteractionResult(attacker, target, attackElement)
    -- 1. Identify Target Element
    local targetElement = target.Parent:GetAttribute("Element") or "Physical"
    
    local multiplier = 1.0
    local status = "Neutral"
    
    -- 2. Check Polar Opposite First (Highest Priority as per User Request)
    if self:IsPolarOpposite(attackElement, targetElement) then
        local attLevel = attacker:GetAttribute("Level") or 1
        local defLevel = target.Parent:GetAttribute("Level") or 1 
        
        -- Polar Logic: Level Clash determines outcome.
        -- Winner gets Neutral damage (1.0). Loser gets Negated (0).
        if attLevel > defLevel then
            multiplier = 1.0 
            status = "Overpower"
        elseif attLevel < defLevel then
            multiplier = 0 
            status = "Negated"
        else
            -- Equal Level = Null
            multiplier = 0
            status = "Clash Null"
        end
        return multiplier, status
    end

    -- 3. If NOT Polar, use Standard Weak/Strong Logic
    local relation = STANDARD_RELATIONS[attackElement]
    if relation then
        if relation.StrongAgainst == targetElement then
            multiplier = 1.5
            status = "Strong"
        elseif relation.WeakTo == targetElement then
            multiplier = 0.5
            status = "Weak"
        end
    end
    
    return multiplier, status
end

return MagicService
