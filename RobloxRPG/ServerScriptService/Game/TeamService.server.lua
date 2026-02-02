local TeamService = {}
local Teams = {} -- Map<Player, TeamId>
local Parties = {} -- Map<PartyId, List<Player>>

-- Using Roblox Teams Service as backend for visual representation?
-- Or custom internal party system?
-- Let's do a lightweight Party System for "Tree System for all and team system"

function TeamService:CreateParty(leader)
    local id = game:GetService("HttpService"):GenerateGUID(false)
    Parties[id] = {Leader = leader, Members = {leader}}
    leader:SetAttribute("PartyId", id)
    return id
end

function TeamService:JoinParty(player, partyId)
    local party = Parties[partyId]
    if party and #party.Members < 5 then
        table.insert(party.Members, player)
        player:SetAttribute("PartyId", partyId)
        return true
    end
    return false
end

function TeamService:AreAllies(entity1, entity2)
    -- Handle Players
    if entity1:IsA("Player") and entity2:IsA("Player") then
        local p1 = entity1:GetAttribute("PartyId")
        local p2 = entity2:GetAttribute("PartyId")
        if p1 and p2 and p1 == p2 then return true end
    end
    
    -- Handle NPC vs Player (Tags?)
    -- Default: Different teams
    return false
end

return TeamService
