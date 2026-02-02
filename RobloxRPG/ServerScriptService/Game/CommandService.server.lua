local Players = game:GetService("Players")
local DataService = require(script.Parent.DataService)
local ClassService = require(script.Parent.ClassService)
local SkillService = require(script.Parent.SkillService)
local ItemData = require(game.ReplicatedStorage.GameData.ItemData)

local CommandService = {}

local ADMINS = {
    [game.CreatorId] = true, -- Place Owner
    -- Add UserID here manually if testing in Team Create
}

-- Format: /cmd arg1 arg2
Players.PlayerAdded:Connect(function(player)
    player.Chatted:Connect(function(msg)
        -- if not ADMINS[player.UserId] then return end -- Comment out for Studio Testing
        
        local args = string.split(msg, " ")
        local cmd = string.lower(args[1])
        
        if cmd == "/gold" then
            local amt = tonumber(args[2])
            if amt then
                DataService:Get(player).Gold = amt
                DataService:Save(player)
                print("Set Gold to " .. amt)
            end
            
        elseif cmd == "/level" then
            local lvl = tonumber(args[2])
            if lvl then
                player:SetAttribute("Level", lvl)
                DataService:Save(player)
                print("Set Level to " .. lvl)
                -- Re-apply class stats
                ClassService:ApplyClassStats(player, player:GetAttribute("Class"))
            end
            
        elseif cmd == "/class" then
            local cls = args[2]
            ClassService:SetClass(player, cls)
            print("Set Class to " .. cls)
            
        elseif cmd == "/give" then
            local item = args[2]
            if ItemData[item] then
                local d = DataService:Get(player)
                d.Inventory = d.Inventory or {}
                d.Inventory[item] = (d.Inventory[item] or 0) + 1
                DataService:Save(player)
                print("Gave " .. item)
            else
                print("Item not found")
            end
        end
    end)
end)

return CommandService
