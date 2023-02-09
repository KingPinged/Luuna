local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local PlayerService = Knit.CreateService({
	Name = "PlayerService",
	Client = {},
})

local Timer = require(ReplicatedStorage.Packages.Timer)

local Players = game:GetService("Players")

local ModeratorService
local DataService

local players = {}

--TODO maybe not use player as index but id?
function AddPlayer(player)
	if players[player] then
		return false
	end
	players[player] = player
	return DataService:AddNewPlayerData(player)
end

function RemovePlayer(player)
	players[player] = nil
	DataService:RemovePlayer(player)
end

function PlayerService:KnitStart()
	ModeratorService = Knit.GetService("ModeratorService")
	DataService = Knit.GetService("DataService")

	Players.PlayerAdded:Connect(function(player)
		AddPlayer(player)
	end)

	for _, player in pairs(Players:GetPlayers()) do
		AddPlayer(player)
	end

	Players.PlayerRemoving:Connect(function(player)
		RemovePlayer(player)
	end)

	Timer.Simple(60, function()
		for _, player in pairs(Players:GetPlayers()) do
			ModeratorService:CheckPlayerModerated(player)
		end
	end)
end

return PlayerService
