local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Knit = require(ReplicatedStorage.Packages.Knit)

local startUpGui = require(script.parent.parent.parent.Lobby.startUp.gui)

local PlayerController = Knit.CreateController({ Name = "PlayerController" })

function PlayerAdded(player)
	print("calling startUpGui module")
	startUpGui:start(player)
end

function PlayerController:KnitStart()
	Players.PlayerAdded:Connect(function(player)
		print("player now addded")
		PlayerAdded(player)
	end)

	for _, player in pairs(Players:GetPlayers()) do
		PlayerAdded(player)
	end

	Players.PlayerRemoving:Connect(function(player)
		self:PlayerRemoving(player)
	end)
end

function PlayerController:KnitInit() end

return PlayerController
