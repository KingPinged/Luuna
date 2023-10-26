local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Roact = require(ReplicatedStorage.Packages.React)
local ReactRoblox = require(ReplicatedStorage.Packages.ReactRoblox)

local e = Roact.createElement

local MenuButtons = require(script.Parent.Parent.components.MenuButtons)

return {
	summary = "the buttons that appear in game start",
	react = Roact,
	reactRoblox = ReactRoblox,
	story = e(MenuButtons, { logoFinish = true }),
}
