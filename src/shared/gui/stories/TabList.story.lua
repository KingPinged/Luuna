local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Roact = require(ReplicatedStorage.Packages.React)
local ReactRoblox = require(ReplicatedStorage.Packages.ReactRoblox)

local e = Roact.createElement

local TabList = require(script.Parent.Parent.components.TabList)

return {
	summary = "The gui that appears on tab press",
	react = Roact,
	reactRoblox = ReactRoblox,
	story = e(TabList),
}
