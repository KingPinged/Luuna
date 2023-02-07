local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local PlayerJoinService = Knit.CreateService {
    Name = "PlayerJoinService",
    Client = {},
}

local PlayerService = game:GetService("Players")

--todo does getting a service require it to be loaded by lifecycle first? 
local ModeratorService 

local players = {}

--todo maybe not use player as index but id?
function PlayerJoined(player)
    players[player] = player


end

function PlayerJoinService:KnitStart()
    
end


function PlayerJoinService:KnitInit()
    ModeratorService = Knit.GetService("ModeratorService")
    PlayerService.PlayerAdded:Connect(function(player)
        PlayerJoined(player)
    end)

     for _, player in pairs(PlayerService:GetPlayers()) do
        PlayerJoined(player)
    end
end


return PlayerJoinService
