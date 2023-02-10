local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Knit = require(ReplicatedStorage.Packages.Knit)

local React = require(ReplicatedStorage.Packages.React)
local ReactRoblox = require(ReplicatedStorage.Packages.ReactRoblox)

local e = React.createElement

local PreferredInput = require(ReplicatedStorage.Packages.Input).PreferredInput
local Keyboard = require(ReplicatedStorage.Packages.Input).Keyboard

local PlayerController = Knit.CreateController({ Name = "PlayerController" })

local TabList = require(ReplicatedStorage.gui.components.TabList)

local player = game.Players.LocalPlayer

function PlayerAdded(player) end

function RemovePlayer(player) end

function removeCoreGui()
	--remove some guis that are not needed at all
	game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)
	game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.EmotesMenu, false)
	game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
	game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Health, false)
end

function CreatePlayerList()
	--? does PrefferedInput work automatically sync as state?
	--local connection = PreferredInput.Observe(function(preferred) end)

	local root = ReactRoblox.createRoot(Instance.new("Folder"))

	local keyboard = Keyboard.new()

	keyboard.KeyDown:Connect(function(key)
		if Enum.KeyCode.Tab == key and PreferredInput.Current == "MouseKeyboard" then
			print("TEst")
			root:render(ReactRoblox.createPortal({
				App = e("ScreenGui", { IgnoreGuiInset = true, DisplayOrder = 100 }, {
					playerList = e(TabList),
				}),
			}, player.PlayerGui))
		end
	end)

	keyboard.KeyUp:Connect(function(key)
		if Enum.KeyCode.Tab == key and PreferredInput.Current == "MouseKeyboard" then
			--! mom im scared root wont exist when key up :(
			root:unmount()
		end
	end)

	--//connection:Disconnect()
end

function PlayerController:KnitStart()
	removeCoreGui()
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
