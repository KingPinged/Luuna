local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages:WaitForChild("React"))
local ReactRoblox = require(ReplicatedStorage.Packages.ReactRoblox)

return {
	react = React,
	reactRoblox = ReactRoblox,
	storyRoots = {
		ReplicatedStorage.gui.stories,
	},
}
