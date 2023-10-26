local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Roact = require(ReplicatedStorage.Packages.React)
local ReactRoblox = require(ReplicatedStorage.Packages.ReactRoblox)

local e = Roact.createElement

local BackgroundComponent = require(script.Parent.LoadingBackground)

local controls = {
	duration = 30,
}

return {
	summary = "The backgound that appears in game loading and teleport screen",
	react = Roact,
	controls = controls,
	reactRoblox = ReactRoblox,
	story = function(props)
		return e(BackgroundComponent, {
			duration = props.controls.duration,
		})
	end,
}
