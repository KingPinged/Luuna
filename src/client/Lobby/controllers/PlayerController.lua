local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Knit = require(ReplicatedStorage.Packages.Knit)

local PreferredInput = require(ReplicatedStorage.Packages.Input).PreferredInput
local Keyboard = require(ReplicatedStorage.Packages.Input).Keyboard

local PlayerController = Knit.CreateController({ Name = "PlayerController" })

local player = game.Players.LocalPlayer

function PlayerAdded(player) end

function RemovePlayer(player) end

function CreatePlayerList()
	--remove some guis that are not needed at all
	game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)
	game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.EmotesMenu, false)
	game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
	game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Health, false)

	--? does PrefferedInput work automatically sync as state?
	--local connection = PreferredInput.Observe(function(preferred) end)

	Keyboard.KeyDown:Connect(function(key)
		if Enum.KeyCode.Tab == key and PreferredInput.current == "MouseKeyboard" then
			--TODO make the playerlist visible like in minecraft
		end
	end)

	Keyboard.KeyUp:Connect(function(key)
		if Enum.KeyCode.Tab == key and PreferredInput.current == "MouseKeyboard" then
			--TODO make the playerlist NOT visible like in minecraft
		end
	end)

	--//connection:Disconnect()
end

function PlayerController:KnitStart()
	CreatePlayerList()
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
