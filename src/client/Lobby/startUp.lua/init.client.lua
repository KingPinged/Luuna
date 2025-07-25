--[[
Functionality:
	This startup is separate from knit starer.
	- Creates the main menu
	- Creates the background
	- Creates the logo
	- Creates the menu buttons
TODO:
	change to modulescript ->
		make reference by starter.client.lua
]]
--

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Roact = require(ReplicatedStorage.Packages:WaitForChild("React"))
local ReactRoblox = require(ReplicatedStorage.Packages.ReactRoblox)
local RoactSpring = require(ReplicatedStorage.Packages.RoactSpring)

local e = Roact.createElement

local Background = require(ReplicatedStorage.gui.components.MenuBackground)
local menuButtons = require(ReplicatedStorage.gui.components.MenuButtons)
local Logo = require(ReplicatedStorage.gui.components.Logo)

function ScreenGui()
	local logoFinish, setLogoFinish = Roact.useState(false)

	return e("ScreenGui", { IgnoreGuiInset = true }, {
		background = e(Background),
		menuButtons = e(menuButtons, { logoFinish = logoFinish }),
		logo = e(Logo, { setLogoFinish = setLogoFinish }),
	})
end

function start(player)
	local root = ReactRoblox.createRoot(Instance.new("Folder"))
	root:render(ReactRoblox.createPortal({
		App = e(ScreenGui),
	}, player.PlayerGui))
end

return start
