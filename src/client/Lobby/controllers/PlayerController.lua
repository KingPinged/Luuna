local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Knit = require(ReplicatedStorage.Packages.Knit)

local PlayerController = Knit.CreateController({ Name = "PlayerController" })

function PlayerAdded(player) end

function RemovePlayer(player) end

function PlayerController:KnitStart()
	Players.PlayerAdded:Connect(function(player)
		print("player now addded")
		PlayerAdded(player)
	end)

	for _, player in pairs(Players:GetPlayers()) do
		PlayerAdded(player)
	end

	Players.PlayerRemoving:Connect(function(player)
		RemovePlayer(player)
	end)
end

return PlayerController
