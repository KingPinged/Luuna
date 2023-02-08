local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local PlayerService = Knit.CreateService({
	Name = "PlayerService",
	Client = {},
})

local PlayerService = game:GetService("Players")

--TODO does getting a service require it to be loaded by lifecycle first?
local ModeratorService = Knit.GetService("ModeratorService")
local DataService = Knit.GetService("DataService")

local players = {}

--TODO maybe not use player as index but id?
function Playered(player)
	players[player] = player
	DataService:AddNewPlayerData(player)
end

function PlayerService:KnitStart() end

function PlayerService:KnitInit()
	ModeratorService = Knit.GetService("ModeratorService")
	PlayerService.PlayerAdded:Connect(function(player)
		Playered(player)
	end)

	for _, player in pairs(PlayerService:GetPlayers()) do
		Playered(player)
	end
end

return PlayerService
