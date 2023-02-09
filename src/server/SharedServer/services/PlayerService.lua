local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local PlayerService = Knit.CreateService({
	Name = "PlayerService",
	Client = {},
})

local Timer = require(ReplicatedStorage.Packages.Timer)

local Players = game:GetService("Players")

--TODO does getting a service require it to be loaded by lifecycle first?
local ModeratorService = Knit.GetService("ModeratorService")
local DataService = Knit.GetService("DataService")

local players = {}

--TODO maybe not use player as index but id?
function AddPlayer(player)
	players[player] = player
	DataService:AddNewPlayerData(player)
end

function RemovePlayer(player)
	players[player] = nil
	DataService:RemovePlayer(player)
end

function PlayerService:KnitStart()
	Timer.Simple(60, function()
		for _, player in pairs(PlayerService:GetPlayers()) do
			ModeratorService:CheckPlayerModerated(player)
		end
	end)
end

function PlayerService:KnitInit()
	ModeratorService = Knit.GetService("ModeratorService")
	Players.PlayerAdded:Connect(function(player)
		AddPlayer(player)
	end)

	for _, player in pairs(PlayerService:GetPlayers()) do
		AddPlayer(player)
	end

	Players.PlayerRemoving:Connect(function(player)
		RemovePlayer(player)
	end)
end

return PlayerService
