local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Roact = require(ReplicatedStorage.Packages.React)
local ReactRoblox = require(ReplicatedStorage.Packages.ReactRoblox)

local e = Roact.createElement

local BackgroundComponent = require(script.parent.Background)

local controls = {
	duration = 30,
}

return {
	summary = "This is a Hoarcekat component that has been converted for flipbook!",
	react = Roact,
	controls = controls,
	reactRoblox = ReactRoblox,
	story = function(props)
		return e(BackgroundComponent, {
			duration = props.controls.duration,
		})
	end,
}
