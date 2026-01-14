local RunService = game:GetService("RunService")
local RemoteGuard = {}

-- Rate Limiting Configuration
local RATE_LIMITS = {
    ["Attack"] = {Max = 5, Interval = 1}, -- 5 attacks per second
    ["UseSkill"] = {Max = 3, Interval = 1},
    ["Interact"] = {Max = 2, Interval = 0.5},
}

local PlayerLimits = {}

function RemoteGuard:Validate(player, remoteName, args, schema)
    -- 1. Rate Check
    if not self:CheckRate(player, remoteName) then
        return false, "Rate Limit Exceeded"
    end
    
    -- 2. Schema Check (Basic Type Checking)
    if schema then
        for i, expectedType in ipairs(schema) do
            if type(args[i]) ~= expectedType then
                warn(string.format("Security: %s sent bad type (Arg %d: got %s, expected %s)", player.Name, i, type(args[i]), expectedType))
                return false, "Invalid Argument Type"
            end
        end
    end
    
    return true
end

function RemoteGuard:CheckRate(player, action)
    local limits = RATE_LIMITS[action]
    if not limits then return true end -- No limit defined
    
    local id = player.UserId
    PlayerLimits[id] = PlayerLimits[id] or {}
    local pLimit = PlayerLimits[id][action] or {Count = 0, LastCheck = os.clock()}
    
    local now = os.clock()
    if now - pLimit.LastCheck > limits.Interval then
        pLimit.Count = 0
        pLimit.LastCheck = now
    end
    
    pLimit.Count = pLimit.Count + 1
    PlayerLimits[id][action] = pLimit
    
    if pLimit.Count > limits.Max then
        warn("Security: " .. player.Name .. " exceeded rate limit for " .. action)
        return false
    end
    
    return true
end

-- Cleanup on leave
game:GetService("Players").PlayerRemoving:Connect(function(p)
    if PlayerLimits[p.UserId] then
        PlayerLimits[p.UserId] = nil
    end
end)

return RemoteGuard
