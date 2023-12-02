--[[
Functionality:
	- removes core guis ( backpack, emotes, health, playerlist, etc., bound to change)
	- Creates player list ( custom ) with TAB key hold
	- handles player data of EACH from this client's side
TODO:

]]
--

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

local playerList = {}

function PlayerAdded(player)
	--player already exists
	if playerList[player] then
		return
	end

	playerList[player] = {}
	--TODO: get specific data from server about player

	
end

function RemovePlayer(player)
	playerList[player] = nil
end

--remove some guis that are not needed at all
function removeCoreGui()
	game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)
	game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.EmotesMenu, false)
	game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
	game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Health, false)
end

-- create player list GUI
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
					playerList = e(TabList, { players = Players:GetPlayers(), info = {} }),
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

--when this script is run
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
