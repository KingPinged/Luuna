local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Roact = require(ReplicatedStorage.Packages.React)
local ReactRoblox = require(ReplicatedStorage.Packages.ReactRoblox)

local e = Roact.createElement

local Logo = require(script.parent.Logo)

local controls = {}

return {
	summary = "the logo that appears in game start ",
	react = Roact,
	reactRoblox = ReactRoblox,
	story = function()
		return e(Logo)
	end,
}
