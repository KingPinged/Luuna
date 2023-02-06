local a = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")

local Roact = require(ReplicatedStorage.Packages.React)
local ReactRoblox = require(ReplicatedStorage.Packages.ReactRoblox)
local RoactSpring = require(ReplicatedStorage.Packages.RoactSpring)

local e = Roact.createElement

local Background = require(script.components.Background)
local menuButtons = require(script.components.MenuButtons)

function a:start(player)
	local root = ReactRoblox.createRoot(Instance.new("Folder"))
	root:render(ReactRoblox.createPortal({
		App = e("ScreenGui", { IgnoreGuiInset = true }, { background = e(Background), menuButtons = e(menuButtons) }),
	}, player.PlayerGui))
end

return a
